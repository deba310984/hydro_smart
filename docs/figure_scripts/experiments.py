"""
HydroSmart — experimental suite for the IEEE research paper.

Every figure and number in the paper is produced by this script from the
project's own training pipeline (ml_backend/train_model.py) and its own
sensor dataset (feeds.csv). Nothing is copied from an external source.

Outputs: figs/*.png at 300 dpi, results.json with every measured value.
"""
import importlib.util
import json
import os
import sys
import time
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

from sklearn.ensemble import (
    HistGradientBoostingClassifier, RandomForestClassifier, ExtraTreesClassifier)
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold
from sklearn.metrics import (
    accuracy_score, f1_score, confusion_matrix, classification_report,
    top_k_accuracy_score, cohen_kappa_score)
from sklearn.inspection import permutation_importance

warnings.filterwarnings("ignore")

REPO = Path(r"C:\hydro_smart")
OUT = Path(__file__).parent / "figs"
OUT.mkdir(exist_ok=True)
SEED = 42
DPI = 300

# ── IEEE-friendly plot style: Times, small type, no chartjunk ──
plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["Times New Roman", "DejaVu Serif"],
    "font.size": 8,
    "axes.labelsize": 8,
    "axes.titlesize": 8.5,
    "xtick.labelsize": 7,
    "ytick.labelsize": 7,
    "legend.fontsize": 7,
    "axes.grid": True,
    "grid.alpha": 0.25,
    "grid.linewidth": 0.4,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "axes.linewidth": 0.6,
    "xtick.major.width": 0.6,
    "ytick.major.width": 0.6,
    "lines.linewidth": 1.2,
    "figure.dpi": DPI,
    "savefig.dpi": DPI,
    "savefig.bbox": "tight",
    "savefig.pad_inches": 0.02,
})

# IEEE column widths in inches
COL = 3.45
FULL = 7.16

GREEN = "#2E6B34"
GOLD = "#B8860B"
TERRA = "#C0603A"
BLUE = "#2C5F8A"
GREY = "#5A5A5A"
PALETTE = [GREEN, BLUE, GOLD, TERRA, "#6A4C93", "#3E7C7B", "#8A5A44"]

R = {}  # results dict


def log(m):
    print(m, flush=True)


# ──────────────────────────────────────────────────────────
# Load the project's own training module
# ──────────────────────────────────────────────────────────
spec = importlib.util.spec_from_file_location("tm", REPO / "ml_backend" / "train_model.py")
tm = importlib.util.module_from_spec(spec)
sys.argv = ["experiments"]
spec.loader.exec_module(tm)
log(f"Loaded pipeline: {len(tm.CROP_PROFILES)} crops, {len(tm.ALL_LOCATIONS)} states")

R["n_crops"] = len(tm.CROP_PROFILES)
R["n_states"] = len(tm.ALL_LOCATIONS)
R["crops"] = sorted(tm.CROP_PROFILES.keys())
R["states"] = list(tm.ALL_LOCATIONS)

FEATURES = ["temperature", "humidity", "location_enc", "month",
            "month_sin", "month_cos", "temp_hum_interaction", "dew_point", "vpd"]


def build_xy(df, feature_subset=None):
    """Replicate the production feature pipeline exactly."""
    d = tm.add_engineered_features(df)
    le_loc, le_crop = LabelEncoder(), LabelEncoder()
    d["location_enc"] = le_loc.fit_transform(d["location"])
    d["crop_enc"] = le_crop.fit_transform(d["crop"])
    cols = feature_subset or FEATURES
    X = d[cols].values.astype(float)
    y = d["crop_enc"].values
    if "location_enc" in cols:
        li = cols.index("location_enc")
        si = [i for i in range(len(cols)) if i != li]
    else:
        si = list(range(len(cols)))
    sc = StandardScaler()
    X[:, si] = sc.fit_transform(X[:, si])
    return X, y, le_crop


# ──────────────────────────────────────────────────────────
# Dataset
# ──────────────────────────────────────────────────────────
N = 150_000
log(f"Generating dataset ({N:,})...")
t0 = time.perf_counter()
df = tm.generate_synthetic_dataset(N, sensor_data=None)
R["gen_time_s"] = round(time.perf_counter() - t0, 2)
R["n_samples"] = int(len(df))
log(f"  {len(df):,} samples in {R['gen_time_s']}s")

X, y, le_crop = build_xy(df)
CROPS = list(le_crop.classes_)
Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=SEED, stratify=y)
R["n_train"], R["n_test"] = int(len(Xtr)), int(len(Xte))


# ══════════════════════════════════════════════════════════
# EXP 1 — classifier comparison
# ══════════════════════════════════════════════════════════
log("\n[E1] Classifier comparison")
MODELS = {
    "Gaussian NB": GaussianNB(),
    "Logistic Reg.": LogisticRegression(max_iter=400, n_jobs=-1),
    "Decision Tree": DecisionTreeClassifier(random_state=SEED),
    "k-NN (k=15)": KNeighborsClassifier(n_neighbors=15, n_jobs=-1),
    "Extra Trees": ExtraTreesClassifier(n_estimators=120, n_jobs=-1, random_state=SEED),
    "Random Forest": RandomForestClassifier(n_estimators=120, n_jobs=-1, random_state=SEED),
    "HistGB (ours)": HistGradientBoostingClassifier(
        max_iter=400, learning_rate=0.10, min_samples_leaf=20,
        l2_regularization=0.1, early_stopping=False, random_state=SEED),
}
comp = []
for name, mdl in MODELS.items():
    t0 = time.perf_counter()
    mdl.fit(Xtr, ytr)
    ttrain = time.perf_counter() - t0
    t0 = time.perf_counter()
    pred = mdl.predict(Xte)
    tinfer = (time.perf_counter() - t0) / len(Xte) * 1e6  # microseconds/sample
    acc = accuracy_score(yte, pred)
    f1m = f1_score(yte, pred, average="macro")
    import pickle
    size_mb = len(pickle.dumps(mdl)) / 1e6
    comp.append(dict(model=name, accuracy=acc, macro_f1=f1m,
                     train_s=ttrain, infer_us=tinfer, size_mb=size_mb))
    log(f"  {name:16s} acc={acc:.4f} f1={f1m:.4f} train={ttrain:6.1f}s "
        f"infer={tinfer:6.1f}us size={size_mb:8.2f}MB")
R["comparison"] = comp

best = MODELS["HistGB (ours)"]
pred = best.predict(Xte)
proba = best.predict_proba(Xte)
R["accuracy"] = float(accuracy_score(yte, pred))
R["macro_f1"] = float(f1_score(yte, pred, average="macro"))
R["weighted_f1"] = float(f1_score(yte, pred, average="weighted"))
R["kappa"] = float(cohen_kappa_score(yte, pred))
R["top3"] = float(top_k_accuracy_score(yte, proba, k=3, labels=np.arange(len(CROPS))))
R["top5"] = float(top_k_accuracy_score(yte, proba, k=5, labels=np.arange(len(CROPS))))
log(f"  top-1={R['accuracy']:.4f} top-3={R['top3']:.4f} top-5={R['top5']:.4f} kappa={R['kappa']:.4f}")

log("  5-fold CV...")
cv = cross_val_score(
    HistGradientBoostingClassifier(max_iter=400, learning_rate=0.10, min_samples_leaf=20,
                                   l2_regularization=0.1, early_stopping=False, random_state=SEED),
    X, y, cv=StratifiedKFold(5, shuffle=True, random_state=SEED), n_jobs=-1)
R["cv_mean"], R["cv_std"] = float(cv.mean()), float(cv.std())
log(f"  CV={cv.mean():.4f} +/- {cv.std():.4f}")

# Fig 1 — accuracy vs cost
fig, ax = plt.subplots(figsize=(COL, 2.5))
cd = sorted(comp, key=lambda r: r["accuracy"])
names = [c["model"] for c in cd]
accs = [c["accuracy"] * 100 for c in cd]
cols = [GREEN if "ours" in n else GREY for n in names]
b = ax.barh(names, accs, color=cols, height=0.62, edgecolor="none")
for r, a in zip(b, accs):
    ax.text(a + 0.7, r.get_y() + r.get_height() / 2, f"{a:.1f}", va="center", fontsize=6.5)
ax.set_xlabel("Top-1 test accuracy (%)")
ax.set_xlim(0, 104)
ax.yaxis.grid(False)
fig.savefig(OUT / "fig_model_comparison.png")
plt.close(fig)

# Fig 2 — accuracy vs model size (log)
fig, ax = plt.subplots(figsize=(COL, 2.3))
for c in comp:
    m = "o" if "ours" not in c["model"] else "*"
    s = 34 if "ours" not in c["model"] else 190
    col = GREEN if "ours" in c["model"] else BLUE
    ax.scatter(c["size_mb"], c["accuracy"] * 100, marker=m, s=s, color=col,
               zorder=3, edgecolor="white", linewidth=0.5)
    ax.annotate(c["model"], (c["size_mb"], c["accuracy"] * 100),
                textcoords="offset points", xytext=(0, -9), ha="center", fontsize=6)
ax.axvline(512, color=TERRA, ls="--", lw=0.9)
ax.text(512, 42, " 512 MB host limit", color=TERRA, fontsize=6.5, rotation=90, va="bottom")
ax.set_xscale("log")
ax.set_xlabel("Serialised model size (MB, log scale)")
ax.set_ylabel("Top-1 accuracy (%)")
ax.set_ylim(35, 100)
fig.savefig(OUT / "fig_accuracy_vs_size.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 2 — feature ablation
# ══════════════════════════════════════════════════════════
log("\n[E2] Feature ablation")
SETS = {
    "Raw only\n(T, RH, state, month)": ["temperature", "humidity", "location_enc", "month"],
    "+ cyclical\nmonth": ["temperature", "humidity", "location_enc", "month", "month_sin", "month_cos"],
    "+ T x RH\ninteraction": ["temperature", "humidity", "location_enc", "month", "month_sin",
                              "month_cos", "temp_hum_interaction"],
    "+ dew point\n& VPD (full)": FEATURES,
}
abl = []
for label, cols in SETS.items():
    Xa, ya, _ = build_xy(df, cols)
    a_tr, a_te, b_tr, b_te = train_test_split(Xa, ya, test_size=0.2, random_state=SEED, stratify=ya)
    m = HistGradientBoostingClassifier(max_iter=400, learning_rate=0.10, min_samples_leaf=20,
                                       l2_regularization=0.1, early_stopping=False, random_state=SEED)
    m.fit(a_tr, b_tr)
    p = m.predict(a_te)
    abl.append(dict(label=label.replace("\n", " "), n_feat=len(cols),
                    accuracy=float(accuracy_score(b_te, p)),
                    macro_f1=float(f1_score(b_te, p, average="macro"))))
    log(f"  {label.replace(chr(10),' '):32s} n={len(cols)} acc={abl[-1]['accuracy']:.4f}")
R["ablation"] = abl

fig, ax = plt.subplots(figsize=(COL, 2.35))
labs = list(SETS.keys())
vals = [a["accuracy"] * 100 for a in abl]
bars = ax.bar(range(len(labs)), vals, color=[GREY, GREY, GREY, GREEN], width=0.6, edgecolor="none")
base = vals[0]
for i, (bar, v) in enumerate(zip(bars, vals)):
    ax.text(bar.get_x() + bar.get_width() / 2, v + 0.25, f"{v:.2f}", ha="center", fontsize=6.5)
    if i:
        ax.text(bar.get_x() + bar.get_width() / 2, base - 1.4, f"+{v-base:.2f}",
                ha="center", fontsize=6, color=GREEN)
ax.set_xticks(range(len(labs)))
ax.set_xticklabels(labs, fontsize=6.3)
ax.set_ylabel("Top-1 accuracy (%)")
ax.set_ylim(min(vals) - 2.5, max(vals) + 1.6)
ax.xaxis.grid(False)
fig.savefig(OUT / "fig_ablation.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 3 — learning curve
# ══════════════════════════════════════════════════════════
log("\n[E3] Learning curve")
sizes = [2_000, 5_000, 10_000, 20_000, 40_000, 70_000, 100_000, 120_000]
lc = []
for s in sizes:
    idx = np.random.RandomState(SEED).choice(len(Xtr), s, replace=False)
    m = HistGradientBoostingClassifier(max_iter=400, learning_rate=0.10, min_samples_leaf=20,
                                       l2_regularization=0.1, early_stopping=False, random_state=SEED)
    m.fit(Xtr[idx], ytr[idx])
    tr = accuracy_score(ytr[idx], m.predict(Xtr[idx]))
    te = accuracy_score(yte, m.predict(Xte))
    lc.append(dict(n=s, train=float(tr), test=float(te)))
    log(f"  n={s:7,d} train={tr:.4f} test={te:.4f}")
R["learning_curve"] = lc

fig, ax = plt.subplots(figsize=(COL, 2.3))
ns = [d["n"] for d in lc]
ax.plot(ns, [d["train"] * 100 for d in lc], "o-", color=BLUE, ms=3.2, label="Training")
ax.plot(ns, [d["test"] * 100 for d in lc], "s-", color=GREEN, ms=3.2, label="Held-out test")
ax.fill_between(ns, [d["test"] * 100 for d in lc], [d["train"] * 100 for d in lc],
                color=GREY, alpha=0.10)
ax.set_xlabel("Training samples")
ax.set_ylabel("Accuracy (%)")
ax.legend(frameon=False, loc="lower right")
ax.set_xscale("log")
fig.savefig(OUT / "fig_learning_curve.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 4 — confusion matrix (full width)
# ══════════════════════════════════════════════════════════
log("\n[E4] Confusion matrix")
cm = confusion_matrix(yte, pred, normalize="true") * 100
fig, ax = plt.subplots(figsize=(FULL * 0.62, FULL * 0.58))
im = ax.imshow(cm, cmap="Greens", vmin=0, vmax=100, aspect="equal")
ax.set_xticks(range(len(CROPS)));  ax.set_xticklabels(CROPS, rotation=90, fontsize=6)
ax.set_yticks(range(len(CROPS)));  ax.set_yticklabels(CROPS, fontsize=6)
ax.set_xlabel("Predicted class", fontsize=8)
ax.set_ylabel("True class", fontsize=8)
for i in range(len(CROPS)):
    for j in range(len(CROPS)):
        v = cm[i, j]
        if v >= 4:
            ax.text(j, i, f"{v:.0f}", ha="center", va="center", fontsize=5,
                    color="white" if v > 55 else "#222222")
ax.grid(False)
cb = fig.colorbar(im, ax=ax, fraction=0.043, pad=0.02)
cb.set_label("Row-normalised recall (%)", fontsize=7)
cb.ax.tick_params(labelsize=6)
fig.savefig(OUT / "fig_confusion_matrix.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 5 — per-class metrics
# ══════════════════════════════════════════════════════════
log("\n[E5] Per-class metrics")
rep = classification_report(yte, pred, target_names=CROPS, output_dict=True, zero_division=0)
per = [dict(crop=c, precision=rep[c]["precision"], recall=rep[c]["recall"],
            f1=rep[c]["f1-score"], support=int(rep[c]["support"])) for c in CROPS]
R["per_class"] = per

order = sorted(per, key=lambda d: d["f1"])
fig, ax = plt.subplots(figsize=(COL, 3.5))
yy = np.arange(len(order))
ax.barh(yy, [d["f1"] for d in order], color=[TERRA if d["f1"] < 0.80 else GREEN for d in order],
        height=0.66, edgecolor="none")
ax.plot([d["precision"] for d in order], yy, "o", ms=2.6, color=BLUE, label="Precision", zorder=4)
ax.plot([d["recall"] for d in order], yy, "^", ms=2.8, color=GOLD, label="Recall", zorder=4)
ax.axvline(R["macro_f1"], color=GREY, ls="--", lw=0.8)
ax.text(R["macro_f1"], len(order) - 0.2, f" macro-F1 {R['macro_f1']:.3f}", fontsize=6, color=GREY)
ax.set_yticks(yy); ax.set_yticklabels([d["crop"] for d in order], fontsize=6.4)
ax.set_xlabel("Score")
ax.set_xlim(0.55, 1.03)
ax.legend(frameon=False, loc="lower left", ncol=2)
ax.yaxis.grid(False)
fig.savefig(OUT / "fig_per_class.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 6 — permutation importance
# ══════════════════════════════════════════════════════════
log("\n[E6] Permutation importance")
npb = min(6000, len(Xte))
pi = permutation_importance(best, Xte[:npb], yte[:npb], n_repeats=8,
                            random_state=SEED, n_jobs=-1)
imp = sorted(zip(FEATURES, pi.importances_mean, pi.importances_std),
             key=lambda t: t[1])
R["importance"] = [dict(feature=f, mean=float(m), std=float(s)) for f, m, s in reversed(imp)]
for f, m, s in reversed(imp):
    log(f"  {f:22s} {m:.4f} +/- {s:.4f}")

fig, ax = plt.subplots(figsize=(COL, 2.4))
fs = [f.replace("_", " ") for f, _, _ in imp]
ms = [m for _, m, _ in imp]
ss = [s for _, _, s in imp]
derived = {"month sin", "month cos", "temp hum interaction", "dew point", "vpd"}
cols = [GOLD if f in derived else GREEN for f in fs]
ax.barh(fs, ms, xerr=ss, color=cols, height=0.62, edgecolor="none",
        error_kw=dict(lw=0.6, ecolor=GREY, capsize=1.5))
ax.set_xlabel("Decrease in accuracy when permuted")
ax.yaxis.grid(False)
from matplotlib.patches import Patch
ax.legend(handles=[Patch(facecolor=GREEN, label="Measured / supplied"),
                   Patch(facecolor=GOLD, label="Engineered")],
          frameon=False, loc="lower right")
fig.savefig(OUT / "fig_importance.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 7 — feeds.csv sensor dataset
# ══════════════════════════════════════════════════════════
log("\n[E7] Sensor dataset (feeds.csv)")
sf = pd.read_csv(REPO / "feeds.csv", on_bad_lines="skip", engine="python")
for c in ["field1", "field2", "field3"]:
    sf[c] = pd.to_numeric(sf[c], errors="coerce")
sf["ts"] = pd.to_datetime(sf["created_at"], errors="coerce", utc=True)
s = sf.dropna(subset=["field1", "field2", "ts"])
s = s[(s["field1"] > 0) & (s["field2"] > 0)]
R["sensor"] = dict(
    raw_rows=int(len(sf)), usable_rows=int(len(s)),
    start=str(s["ts"].min()), end=str(s["ts"].max()),
    temp_mean=float(s["field1"].mean()), temp_min=float(s["field1"].min()),
    temp_max=float(s["field1"].max()), temp_std=float(s["field1"].std()),
    hum_mean=float(s["field2"].mean()), hum_min=float(s["field2"].min()),
    hum_max=float(s["field2"].max()), hum_std=float(s["field2"].std()),
    corr=float(s["field1"].corr(s["field2"])),
)
log(f"  {len(s):,} usable | T {s['field1'].mean():.1f}C | RH {s['field2'].mean():.1f}% "
    f"| r={R['sensor']['corr']:.3f}")

# Fig — sensor time series + distributions (full width)
fig = plt.figure(figsize=(FULL, 2.5))
gs = fig.add_gridspec(2, 3, width_ratios=[2.15, 1, 1], hspace=0.45, wspace=0.32)

sd = s.set_index("ts").resample("6h").mean(numeric_only=True).dropna()
axa = fig.add_subplot(gs[0, 0])
axa.plot(sd.index, sd["field1"], color=TERRA, lw=0.8)
axa.set_ylabel("T (°C)")
axa.tick_params(labelbottom=False)
axb = fig.add_subplot(gs[1, 0], sharex=axa)
axb.plot(sd.index, sd["field2"], color=BLUE, lw=0.8)
axb.set_ylabel("RH (%)")
for a in (axa, axb):
    a.tick_params(labelsize=6)
plt.setp(axb.get_xticklabels(), rotation=0, fontsize=6)

axc = fig.add_subplot(gs[:, 1])
axc.hist(s["field1"], bins=44, color=TERRA, alpha=0.85, edgecolor="none")
axc.set_xlabel("Temperature (°C)"); axc.set_ylabel("Readings")
axc.axvline(s["field1"].mean(), color="black", ls="--", lw=0.8)

axd = fig.add_subplot(gs[:, 2])
axd.hist(s["field2"], bins=44, color=BLUE, alpha=0.85, edgecolor="none")
axd.set_xlabel("Relative humidity (%)")
axd.axvline(s["field2"].mean(), color="black", ls="--", lw=0.8)
fig.savefig(OUT / "fig_sensor_profile.png")
plt.close(fig)

# Fig — coverage: sensor envelope vs crop profile bands
fig, ax = plt.subplots(figsize=(COL, 2.7))
ax.scatter(df["temperature"][:6000], df["humidity"][:6000], s=1.2, color=GREEN,
           alpha=0.10, label="Synthetic training space", rasterized=True)
ax.scatter(s["field1"][::12], s["field2"][::12], s=1.2, color=TERRA, alpha=0.30,
           label="Measured sensor readings", rasterized=True)
ax.set_xlabel("Temperature (°C)"); ax.set_ylabel("Relative humidity (%)")
lg = ax.legend(frameon=False, loc="upper right", markerscale=6)
for h in lg.legend_handles:
    h.set_alpha(1)
fig.savefig(OUT / "fig_coverage.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 8 — sensor-augmented training
# ══════════════════════════════════════════════════════════
log("\n[E8] Sensor-augmented training")
sens = tm.load_sensor_data(str(REPO / "feeds.csv"))
df_aug = tm.generate_synthetic_dataset(N, sensor_data=sens)
Xg, yg, le2 = build_xy(df_aug)
g_tr, g_te, h_tr, h_te = train_test_split(Xg, yg, test_size=0.2, random_state=SEED, stratify=yg)
m_aug = HistGradientBoostingClassifier(max_iter=400, learning_rate=0.10, min_samples_leaf=20,
                                       l2_regularization=0.1, early_stopping=False, random_state=SEED)
m_aug.fit(g_tr, h_tr)
p_aug = m_aug.predict(g_te)
R["augmented"] = dict(
    n_samples=int(len(df_aug)),
    accuracy=float(accuracy_score(h_te, p_aug)),
    macro_f1=float(f1_score(h_te, p_aug, average="macro")),
)
log(f"  augmented n={len(df_aug):,} acc={R['augmented']['accuracy']:.4f}")


# ══════════════════════════════════════════════════════════
# EXP 9 — inference latency
# ══════════════════════════════════════════════════════════
log("\n[E9] Inference latency")
lat = {}
for bs in [1, 8, 32, 128, 512]:
    xs = Xte[:bs]
    for _ in range(5):
        best.predict(xs)
    ts = []
    for _ in range(60):
        t0 = time.perf_counter()
        best.predict(xs)
        ts.append((time.perf_counter() - t0) * 1000)
    lat[bs] = dict(mean=float(np.mean(ts)), p50=float(np.percentile(ts, 50)),
                   p95=float(np.percentile(ts, 95)),
                   per_sample_ms=float(np.mean(ts) / bs))
    log(f"  batch={bs:4d} mean={np.mean(ts):7.3f}ms per-sample={np.mean(ts)/bs:.4f}ms")
R["latency"] = lat

fig, ax = plt.subplots(figsize=(COL, 2.1))
bs = list(lat.keys())
ax.plot(bs, [lat[b]["mean"] for b in bs], "o-", color=GREEN, ms=3.4, label="Batch latency")
ax2 = ax.twinx()
ax2.plot(bs, [lat[b]["per_sample_ms"] * 1000 for b in bs], "s--", color=TERRA, ms=3.2,
         label="Per-sample")
ax2.set_ylabel("Per-sample (µs)", color=TERRA, fontsize=7.5)
ax2.tick_params(labelcolor=TERRA, labelsize=6.5)
ax2.grid(False); ax2.set_yscale("log")
ax.set_xscale("log", base=2)
ax.set_xticks(bs); ax.set_xticklabels(bs)
ax.set_xlabel("Batch size"); ax.set_ylabel("Batch latency (ms)", color=GREEN, fontsize=7.5)
ax.tick_params(labelcolor=GREEN)
fig.savefig(OUT / "fig_latency.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 10 — class overlap (explains the error floor)
# ══════════════════════════════════════════════════════════
log("\n[E10] Class overlap analysis")
ov = np.zeros((len(CROPS), len(CROPS)))
prof = tm.CROP_PROFILES
for i, a in enumerate(CROPS):
    for j, b in enumerate(CROPS):
        ta, tb = prof[a]["temp"], prof[b]["temp"]
        ha, hb = prof[a]["humidity"], prof[b]["humidity"]
        t_ov = max(0, min(ta[1], tb[1]) - max(ta[0], tb[0]))
        h_ov = max(0, min(ha[1], hb[1]) - max(ha[0], hb[0]))
        t_un = max(ta[1], tb[1]) - min(ta[0], tb[0])
        h_un = max(ha[1], hb[1]) - min(ha[0], hb[0])
        sa = set(prof[a]["locations"]); sb = set(prof[b]["locations"])
        ms = set(prof[a]["months"]); mb = set(prof[b]["months"])
        loc_j = len(sa & sb) / max(1, len(sa | sb))
        mon_j = len(ms & mb) / max(1, len(ms | mb))
        ov[i, j] = (t_ov / t_un) * (h_ov / h_un) * loc_j * mon_j

off = ov.copy(); np.fill_diagonal(off, 0)
cmn = confusion_matrix(yte, pred, normalize="true")
cmo = cmn.copy(); np.fill_diagonal(cmo, 0)
mask = ~np.eye(len(CROPS), dtype=bool)
corr = float(np.corrcoef(off[mask], cmo[mask])[0, 1])
R["overlap_confusion_corr"] = corr
f1s = np.array([rep[c]["f1-score"] for c in CROPS])
ovl_tot = off.sum(axis=1)
R["overlap_f1_corr"] = float(np.corrcoef(ovl_tot, f1s)[0, 1])
log(f"  corr(profile overlap, confusion) = {corr:.3f}")
log(f"  corr(total overlap, per-class F1) = {R['overlap_f1_corr']:.3f}")

fig, ax = plt.subplots(figsize=(COL, 2.5))
ax.scatter(ovl_tot, f1s, s=20, color=GREEN, alpha=0.8, edgecolor="white", linewidth=0.4)
z = np.polyfit(ovl_tot, f1s, 1)
xs_ = np.linspace(ovl_tot.min(), ovl_tot.max(), 50)
ax.plot(xs_, np.polyval(z, xs_), "--", color=TERRA, lw=1)
for i, c in enumerate(CROPS):
    if f1s[i] < 0.80 or ovl_tot[i] > np.percentile(ovl_tot, 88):
        ax.annotate(c, (ovl_tot[i], f1s[i]), fontsize=5.6,
                    textcoords="offset points", xytext=(3, 3))
ax.set_xlabel("Cumulative agronomic-profile overlap with other crops")
ax.set_ylabel("Per-class F1")
ax.text(0.97, 0.94, f"r = {R['overlap_f1_corr']:.2f}", transform=ax.transAxes,
        ha="right", fontsize=7, color=TERRA)
fig.savefig(OUT / "fig_overlap.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# EXP 11 — confidence calibration / reliability
# ══════════════════════════════════════════════════════════
log("\n[E11] Reliability")
conf = proba.max(axis=1)
correct = (pred == yte).astype(float)
bins = np.linspace(0, 1, 11)
bi = np.digitize(conf, bins) - 1
xs_, ys_, ns_ = [], [], []
ece = 0.0
for k in range(10):
    m_ = bi == k
    if m_.sum() > 30:
        xs_.append(conf[m_].mean()); ys_.append(correct[m_].mean()); ns_.append(int(m_.sum()))
        ece += m_.sum() / len(conf) * abs(correct[m_].mean() - conf[m_].mean())
R["ece"] = float(ece)
R["mean_confidence"] = float(conf.mean())
log(f"  ECE={ece:.4f} mean-conf={conf.mean():.4f}")

fig, ax = plt.subplots(figsize=(COL, 2.3))
ax.plot([0, 1], [0, 1], ":", color=GREY, lw=0.9, label="Perfect calibration")
ax.plot(xs_, ys_, "o-", color=GREEN, ms=3.6, label="HistGB (ours)")
ax.set_xlabel("Mean predicted confidence"); ax.set_ylabel("Empirical accuracy")
ax.set_xlim(0, 1); ax.set_ylim(0, 1)
ax.legend(frameon=False, loc="upper left")
ax.text(0.97, 0.06, f"ECE = {ece:.3f}", transform=ax.transAxes, ha="right", fontsize=7)
fig.savefig(OUT / "fig_reliability.png")
plt.close(fig)

json.dump(R, open(Path(__file__).parent / "results.json", "w"), indent=2, default=str)
log("\n" + "=" * 60)
log(f"Wrote {len(list(OUT.glob('*.png')))} figures + results.json")
log(f"HEADLINE: acc={R['accuracy']:.4f} macroF1={R['macro_f1']:.4f} "
    f"top3={R['top3']:.4f} CV={R['cv_mean']:.4f}+/-{R['cv_std']:.4f}")
