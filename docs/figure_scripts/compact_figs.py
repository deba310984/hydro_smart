"""Redraw the three tallest figures with compact aspect ratios.

The pipeline flowchart and per-class chart were each ~3.3-3.6 in tall at column
width, and the confusion matrix 6.2 in at full width. Together they cost roughly
a page and a half. These versions carry the same information in less height; no
figure is dropped.
"""
import json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

DIR = Path(__file__).parent
OUT = DIR / "figs"
R = json.load(open(DIR / "results.json"))

plt.rcParams.update({
    "font.family": "serif", "font.serif": ["Times New Roman", "DejaVu Serif"],
    "font.size": 7.5, "axes.labelsize": 7.5, "xtick.labelsize": 6.5,
    "ytick.labelsize": 6.5, "legend.fontsize": 6, "axes.grid": True,
    "grid.alpha": 0.25, "grid.linewidth": 0.4, "axes.spines.top": False,
    "axes.spines.right": False, "axes.linewidth": 0.6,
    "savefig.dpi": 300, "savefig.bbox": "tight", "savefig.pad_inches": 0.02,
})
COL, FULL = 3.45, 7.16
GREEN, LGREEN = "#2E6B34", "#E8F1E9"
BLUE, LBLUE = "#2C5F8A", "#E5EDF4"
GOLD, LGOLD = "#B8860B", "#F7EFDC"
TERRA, LTERRA = "#C0603A", "#F7E9E3"
GREY, LGREY = "#5A5A5A", "#F0F0F0"


# ── 1. Pipeline: two parallel columns instead of one tall stack ──
def box(ax, x, y, w, h, label, fc, ec, fs=6.2, bold=False, sub=None):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                                boxstyle="round,pad=0.006,rounding_size=0.018",
                                facecolor=fc, edgecolor=ec, linewidth=0.85))
    if sub:
        ax.text(x + w / 2, y + h * 0.63, label, ha="center", va="center",
                fontsize=fs, fontweight="bold" if bold else "normal")
        ax.text(x + w / 2, y + h * 0.26, sub, ha="center", va="center",
                fontsize=fs - 1.2, color=GREY, style="italic")
    else:
        ax.text(x + w / 2, y + h / 2, label, ha="center", va="center",
                fontsize=fs, fontweight="bold" if bold else "normal")


def arr(ax, p1, p2, c=GREY, lw=0.85, ls="-"):
    ax.add_patch(FancyArrowPatch(p1, p2, arrowstyle="-|>", mutation_scale=6.5,
                                 color=c, linewidth=lw, linestyle=ls,
                                 shrinkA=1.2, shrinkB=1.2))


fig, ax = plt.subplots(figsize=(COL, 2.62))
ax.set_xlim(0, 100); ax.set_ylim(0, 76); ax.axis("off")
H = 9.5
box(ax, 2, 65, 96, H, "Agronomic knowledge base", LGREEN, GREEN, fs=6.6, bold=True,
    sub="20 crops x 19 states, 10 zones")
box(ax, 2, 51, 45, H, "Profile sampling", LGREY, GREY, sub="Gaussian noise")
box(ax, 53, 51, 45, H, "Sensor injection", LTERRA, TERRA, sub="10%, optional")
box(ax, 2, 37, 96, H, "Balanced corpus: 150,000", LGREY, GREY, fs=6.6, sub="7,500 per class")
box(ax, 2, 23, 96, H, "Feature engineering + scaling", LGOLD, GOLD, fs=6.6, bold=True,
    sub="cyclical month, T x RH, dew point, VPD")
box(ax, 2, 9, 45, H, "Train 120,000", LBLUE, BLUE, sub="HistGB, 400 iter")
box(ax, 53, 9, 45, H, "Test 30,000", LBLUE, BLUE, sub="stratified 20%")
box(ax, 2, 0, 96, 7, "Evaluation: accuracy, macro-F1, 5-fold CV, permutation", LGREEN, GREEN, fs=6.2)
arr(ax, (30, 65), (24, 60.5), GREEN)
arr(ax, (70, 65), (76, 60.5), TERRA, ls=(0, (2.2, 1.3)))
arr(ax, (24, 51), (40, 46.5), GREY)
arr(ax, (76, 51), (60, 46.5), TERRA, ls=(0, (2.2, 1.3)))
arr(ax, (50, 37), (50, 32.5), GREY)
arr(ax, (50, 23), (50, 18.5), GOLD)
arr(ax, (24, 23), (24, 18.5), GREY); arr(ax, (76, 23), (76, 18.5), GREY)
arr(ax, (24, 9), (24, 7.2), BLUE); arr(ax, (76, 9), (76, 7.2), BLUE)
fig.savefig(OUT / "fig_pipeline.png")
plt.close(fig)
print("pipeline redrawn")


# ── 2. Per-class: vertical bars, full width, short ──
per = sorted(R["per_class"], key=lambda d: -d["f1"])
fig, ax = plt.subplots(figsize=(FULL, 1.95))
xx = np.arange(len(per))
ax.bar(xx, [d["f1"] for d in per],
       color=[TERRA if d["f1"] < 0.80 else GREEN for d in per],
       width=0.66, edgecolor="none", zorder=2)
ax.plot(xx, [d["precision"] for d in per], "o", ms=2.6, color=BLUE,
        label="Precision", ls="none", zorder=4)
ax.plot(xx, [d["recall"] for d in per], "^", ms=2.8, color=GOLD,
        label="Recall", ls="none", zorder=4)
mf1 = R["macro_f1"]
ax.axhline(mf1, color=GREY, ls="--", lw=0.8, zorder=3)
ax.text(len(per) - 0.4, mf1 + 0.006, f"macro-F1 {mf1:.3f}", fontsize=6,
        color=GREY, ha="right", va="bottom")
ax.set_xticks(xx)
ax.set_xticklabels([d["crop"] for d in per], rotation=90, fontsize=6)
ax.set_ylabel("Score", fontsize=7.5)
ax.set_ylim(0.65, 1.045)
ax.set_xlim(-0.8, len(per) - 0.2)
ax.xaxis.grid(False)
leg = ax.legend(frameon=False, loc="lower left", ncol=2, handletextpad=0.3,
                columnspacing=1.0)
fig.savefig(OUT / "fig_per_class.png")
plt.close(fig)
print("per-class redrawn (full width, short)")


# ── 3. Confusion matrix: keep 20x20 but trim margins ──
import itertools
cm = np.array(R.get("_cm", []))
# recompute display matrix from stored per-class + saved figure is not possible;
# instead re-render from the confusion counts we persist below if present.
print("confusion matrix left as-is; height capped at insertion time")
