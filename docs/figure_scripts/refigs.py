"""Redraw the ablation figure.

The first version implied a cumulative improvement that the measurement does
not support: the whole range spans 0.15 pp, which is one cross-validation
standard deviation, and the sequence is not even monotonic. The honest chart
shows the noise band so the reader can see the differences are not resolvable.
"""
import json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

DIR = Path(__file__).parent
OUT = DIR / "figs"
R = json.load(open(DIR / "results.json"))

plt.rcParams.update({
    "font.family": "serif", "font.serif": ["Times New Roman", "DejaVu Serif"],
    "font.size": 8, "axes.labelsize": 8, "xtick.labelsize": 7, "ytick.labelsize": 7,
    "legend.fontsize": 6.5, "axes.grid": True, "grid.alpha": 0.25, "grid.linewidth": 0.4,
    "axes.spines.top": False, "axes.spines.right": False, "axes.linewidth": 0.6,
    "savefig.dpi": 300, "savefig.bbox": "tight", "savefig.pad_inches": 0.02,
})
COL = 3.45
GREEN, GREY, TERRA = "#2E6B34", "#5A5A5A", "#C0603A"

abl = R["ablation"]
labs = ["Raw only\n(T, RH, state, month)", "+ cyclical\nmonth",
        "+ T x RH\ninteraction", "+ dew point\n& VPD (full)"]
vals = [a["accuracy"] * 100 for a in abl]
base = vals[0]
sd = R["cv_std"] * 100          # cross-validation SD, in percentage points

fig, ax = plt.subplots(figsize=(COL, 2.5))
ax.axhspan(base - sd, base + sd, color=GREY, alpha=0.16, zorder=0)
ax.axhline(base, color=GREY, lw=0.8, ls="--", zorder=1)

bars = ax.bar(range(len(labs)), vals, color=[GREY, GREY, GREY, GREEN],
              width=0.58, edgecolor="none", zorder=3)
for i, (b, v) in enumerate(zip(bars, vals)):
    ax.text(b.get_x() + b.get_width() / 2, v + 0.035, f"{v:.2f}",
            ha="center", fontsize=6.6, zorder=4)
    if i:
        d = v - base
        # white, inside the bar: the previous green-on-green was invisible
        ax.text(b.get_x() + b.get_width() / 2, min(vals) - 0.30,
                f"{d:+.2f} pp", ha="center", fontsize=6.2,
                color="white", zorder=5)

ax.text(0.02, 0.94, f"shaded: ±1 CV SD (±{sd:.2f} pp)", transform=ax.transAxes,
        fontsize=6.2, color=GREY, va="top")
ax.set_xticks(range(len(labs)))
ax.set_xticklabels(labs, fontsize=6.3)
ax.set_ylabel("Top-1 accuracy (%)")
ax.set_ylim(min(vals) - 0.45, max(vals) + 0.30)
ax.xaxis.grid(False)
fig.savefig(OUT / "fig_ablation.png")
plt.close(fig)
print(f"ablation range {min(vals):.2f}-{max(vals):.2f} pp, CV SD {sd:.3f} pp -> "
      f"{'WITHIN noise' if (max(vals)-min(vals)) < 2*sd else 'resolvable'}")

# ── corrected latency figure (single-threaded), HistGB vs k-NN ──
if "latency_knn" in R:
    fig, ax = plt.subplots(figsize=(COL, 2.2))
    bs = sorted(int(k) for k in R["latency"].keys())
    h = [R["latency"][str(b)]["per_sample_ms"] * 1000 for b in bs]
    k = [R["latency_knn"][str(b)]["per_sample_ms"] * 1000 for b in bs]
    ax.plot(bs, h, "o-", color=GREEN, ms=3.4, label="HistGB (deployed)")
    ax.plot(bs, k, "s--", color=TERRA, ms=3.2, label="k-NN")
    ax.set_xscale("log", base=2); ax.set_yscale("log")
    ax.set_xticks(bs); ax.set_xticklabels(bs)
    ax.set_xlabel("Batch size")
    ax.set_ylabel("Amortised cost per sample (µs)")
    ax.legend(frameon=False, loc="upper right")
    fig.savefig(OUT / "fig_latency.png")
    plt.close(fig)
    print("redrew fig_latency.png")

# ── accuracy vs size: labels were colliding; place them explicitly ──
cmp = R["comparison"]
fig, ax = plt.subplots(figsize=(COL, 2.45))
BLUE = "#2C5F8A"
# (dx, dy) in points, and horizontal alignment, tuned per point
OFFS = {
    "Gaussian NB":   (0, -11, "center"),
    "Logistic Reg.": (0,   7, "center"),
    "Decision Tree": (-6, -11, "right"),
    "k-NN (k=15)":   (-7,   4, "right"),
    "HistGB (ours)": (9,  -3, "left"),
    "Random Forest": (0,   7, "center"),
    "Extra Trees":   (0, -11, "center"),
}
for c in cmp:
    is_ours = "ours" in c["model"]
    ax.scatter(max(c["size_mb"], 2e-3), c["accuracy"] * 100,
               marker="*" if is_ours else "o", s=200 if is_ours else 32,
               color=GREEN if is_ours else BLUE, zorder=4,
               edgecolor="white", linewidth=0.5)
    dx, dy, ha = OFFS[c["model"]]
    ax.annotate(c["model"].replace(" (ours)", " (deployed)"),
                (max(c["size_mb"], 2e-3), c["accuracy"] * 100),
                textcoords="offset points", xytext=(dx, dy), ha=ha,
                fontsize=5.9, zorder=5)
ax.axvline(512, color=TERRA, ls="--", lw=0.9, zorder=2)
ax.text(512, 63, "512 MB limit ", color=TERRA, fontsize=6.0,
        rotation=90, va="center", ha="right")
ax.set_xscale("log")
ax.set_xlim(1e-3, 2e4)
ax.set_ylim(52, 95)
ax.set_xlabel("Serialised model size (MB, log scale)")
ax.set_ylabel("Top-1 accuracy (%)")
fig.savefig(OUT / "fig_accuracy_vs_size.png")
plt.close(fig)
print("redrew fig_accuracy_vs_size.png")

# ── per-class: legend was overlapping the lowest bars ──
BLUE = "#2C5F8A"; GOLD = "#B8860B"
order = sorted(R["per_class"], key=lambda d: d["f1"])
fig, ax = plt.subplots(figsize=(COL, 3.5))
yy = np.arange(len(order))
ax.barh(yy, [d["f1"] for d in order],
        color=[TERRA if d["f1"] < 0.80 else GREEN for d in order],
        height=0.66, edgecolor="none", zorder=2)
ax.plot([d["precision"] for d in order], yy, "o", ms=2.6, color=BLUE,
        label="Precision", zorder=5, linestyle="none")
ax.plot([d["recall"] for d in order], yy, "^", ms=2.8, color=GOLD,
        label="Recall", zorder=5, linestyle="none")
mf1 = R["macro_f1"]
ax.axvline(mf1, color="#5A5A5A", ls="--", lw=0.8, zorder=3)
ax.text(mf1 - 0.004, len(order) - 0.4, f"macro-F1 {mf1:.3f}", fontsize=6,
        color="#5A5A5A", ha="right", va="top")
ax.set_yticks(yy); ax.set_yticklabels([d["crop"] for d in order], fontsize=6.4)
ax.set_xlabel("Score")
ax.set_xlim(0.55, 1.04)
ax.set_ylim(-0.9, len(order) - 0.4)
leg = ax.legend(frameon=True, loc="lower right", ncol=2, handletextpad=0.3,
                columnspacing=0.9, borderpad=0.35)
leg.get_frame().set_edgecolor("#CCCCCC"); leg.get_frame().set_linewidth(0.5)
leg.get_frame().set_facecolor("white"); leg.set_zorder(9)
ax.yaxis.grid(False)
fig.savefig(OUT / "fig_per_class.png")
plt.close(fig)
print("redrew fig_per_class.png")

# ── sensor profile: the time-series panels came out empty because the
#    all-NaN latitude/longitude/elevation columns survived the resample and
#    dropna(how='any') then removed every row. Select the two fields first.
import pandas as pd
FULL = 7.16
sf = pd.read_csv(r"C:\hydro_smart\feeds.csv", on_bad_lines="skip", engine="python")
for c in ["field1", "field2"]:
    sf[c] = pd.to_numeric(sf[c], errors="coerce")
sf["ts"] = pd.to_datetime(sf["created_at"], errors="coerce", utc=True)
s = sf.dropna(subset=["field1", "field2", "ts"])
s = s[(s["field1"] > 0) & (s["field2"] > 0)]
# Do NOT dropna: leaving the gaps as NaN makes matplotlib break the line,
# rather than drawing a straight interpolation across a 22-day outage.
ts_sorted = s["ts"].sort_values()
_d = ts_sorted.diff()
OUTAGES = [(ts_sorted.iloc[i - 1], ts_sorted.iloc[i])
           for i in np.where(_d > pd.Timedelta("2D"))[0]]
sd = s.set_index("ts")[["field1", "field2"]].resample("6h").mean()
span = s["ts"].max() - s["ts"].min()
gaps = s["ts"].sort_values().diff()
gap_tot = gaps[gaps > pd.Timedelta("1h")].sum()
cover = (span - gap_tot) / span
print(f"  span {span.days} d, actual coverage {cover*100:.1f}%")

import matplotlib.dates as mdates
fig = plt.figure(figsize=(FULL, 2.5))
gs = fig.add_gridspec(2, 3, width_ratios=[2.15, 1, 1], hspace=0.30, wspace=0.34)
axa = fig.add_subplot(gs[0, 0])
axa.plot(sd.index, sd["field1"], color=TERRA, lw=0.9)
axa.set_ylabel("T (°C)"); axa.tick_params(labelbottom=False, labelsize=6.5)
axb = fig.add_subplot(gs[1, 0], sharex=axa)
axb.plot(sd.index, sd["field2"], color=BLUE, lw=0.9)
axb.set_ylabel("RH (%)"); axb.tick_params(labelsize=6.5)
axb.xaxis.set_major_locator(mdates.MonthLocator())
axb.xaxis.set_major_formatter(mdates.DateFormatter("%d %b"))
axb.xaxis.set_minor_locator(mdates.DayLocator(interval=7))
for lbl in axb.get_xticklabels():
    lbl.set_fontsize(6.2)
# mark the two long outages
for a in (axa, axb):
    for t0, t1 in OUTAGES:
        a.axvspan(t0, t1, color="#BBBBBB", alpha=0.30, lw=0, zorder=0)
axa.text(0.985, 0.86, f"recording covers {cover*100:.0f}% of the span",
         transform=axa.transAxes, fontsize=5.8, color="#5A5A5A", ha="right")

axc = fig.add_subplot(gs[:, 1])
axc.hist(s["field1"], bins=44, color=TERRA, alpha=0.9, edgecolor="none")
axc.set_xlabel("Temperature (°C)"); axc.set_ylabel("Readings")
axc.axvline(s["field1"].mean(), color="black", ls="--", lw=0.8)
axd = fig.add_subplot(gs[:, 2])
axd.hist(s["field2"], bins=44, color=BLUE, alpha=0.9, edgecolor="none")
axd.set_xlabel("Relative humidity (%)")
axd.axvline(s["field2"].mean(), color="black", ls="--", lw=0.8)
fig.savefig(OUT / "fig_sensor_profile.png")
plt.close(fig)
R["sensor"]["span_days"] = float(span.total_seconds() / 86400)
R["sensor"]["coverage_frac"] = float(cover)
json.dump(R, open(DIR / "results.json", "w"), indent=2, default=str)
print("redrew fig_sensor_profile.png")

# ── learning curve: annotate the persistent gap rather than implying convergence
lc = R["learning_curve"]
ns = [d["n"] for d in lc]
tr = [d["train"] * 100 for d in lc]
te = [d["test"] * 100 for d in lc]
fig, ax = plt.subplots(figsize=(COL, 2.35))
ax.fill_between(ns, te, tr, color=TERRA, alpha=0.10, zorder=1)
ax.plot(ns, tr, "o-", color=BLUE, ms=3.2, label="Training", zorder=3)
ax.plot(ns, te, "s-", color=GREEN, ms=3.2, label="Held-out test", zorder=3)
g0, g1 = tr[0] - te[0], tr[-1] - te[-1]
ax.annotate("", xy=(ns[-1], tr[-1]), xytext=(ns[-1], te[-1]),
            arrowprops=dict(arrowstyle="<->", color=TERRA, lw=0.8))
ax.text(ns[-1] * 0.93, (tr[-1] + te[-1]) / 2, f"{g1:.1f} pp\ngap",
        fontsize=6, color=TERRA, ha="right", va="center")
ax.text(0.03, 0.55, f"gap narrows {g0:.1f} → {g1:.1f} pp\nbut does not close",
        transform=ax.transAxes, fontsize=6, color=TERRA, va="center")
ax.set_xscale("log")
ax.set_xlabel("Training samples"); ax.set_ylabel("Accuracy (%)")
ax.legend(frameon=False, loc="center right", bbox_to_anchor=(1.0, 0.34))
fig.savefig(OUT / "fig_learning_curve.png")
plt.close(fig)
print(f"redrew fig_learning_curve.png (gap {g0:.1f} -> {g1:.1f} pp)")
