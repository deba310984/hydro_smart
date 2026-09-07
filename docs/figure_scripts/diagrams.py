"""System architecture and pipeline diagrams for the HydroSmart IEEE paper.
Drawn from scratch in matplotlib - no external assets."""
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Rectangle

OUT = Path(__file__).parent / "figs"
OUT.mkdir(exist_ok=True)

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["Times New Roman", "DejaVu Serif"],
    "savefig.dpi": 300, "savefig.bbox": "tight", "savefig.pad_inches": 0.02,
})

GREEN = "#2E6B34"; LGREEN = "#E8F1E9"
BLUE = "#2C5F8A";  LBLUE = "#E5EDF4"
GOLD = "#B8860B";  LGOLD = "#F7EFDC"
TERRA = "#C0603A"; LTERRA = "#F7E9E3"
GREY = "#5A5A5A";  LGREY = "#F0F0F0"

COL, FULL = 3.45, 7.16


def box(ax, x, y, w, h, label, fc, ec, fs=6.6, bold=False, sub=None):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                                boxstyle="round,pad=0.008,rounding_size=0.02",
                                facecolor=fc, edgecolor=ec, linewidth=0.9))
    if sub:
        ax.text(x + w / 2, y + h * 0.62, label, ha="center", va="center",
                fontsize=fs, color="#1A1A1A", fontweight="bold" if bold else "normal")
        ax.text(x + w / 2, y + h * 0.27, sub, ha="center", va="center",
                fontsize=fs - 1.3, color=GREY, style="italic")
    else:
        ax.text(x + w / 2, y + h / 2, label, ha="center", va="center",
                fontsize=fs, color="#1A1A1A", fontweight="bold" if bold else "normal")


def arrow(ax, p1, p2, color=GREY, style="-|>", rad=0.0, lw=0.85, ls="-"):
    ax.add_patch(FancyArrowPatch(p1, p2, arrowstyle=style, mutation_scale=7,
                                 color=color, linewidth=lw, linestyle=ls,
                                 connectionstyle=f"arc3,rad={rad}",
                                 shrinkA=1.5, shrinkB=1.5))


# ══════════════════════════════════════════════════════════
# FIG: System architecture (full width)
# ══════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(FULL, 2.95))
ax.set_xlim(0, 100); ax.set_ylim(0, 49); ax.axis("off")

# Tier bands (boxes sit above a clear routing lane at the bottom)
tiers = [(1.0, 20.0, "PHYSICAL / EDGE", LTERRA, TERRA),
         (23.0, 24.0, "CLOUD SERVICES", LBLUE, BLUE),
         (49.0, 24.0, "INFERENCE", LGOLD, GOLD),
         (75.0, 24.0, "APPLICATION", LGREEN, GREEN)]
for x, w, name, fc, ec in tiers:
    ax.add_patch(Rectangle((x, 7.0), w, 36.5, facecolor=fc, edgecolor="none", alpha=0.45))
    ax.text(x + w / 2, 46.2, name, ha="center", va="center", fontsize=6.4,
            color=ec, fontweight="bold", linespacing=1.35)

ROWS = [32.0, 24.6, 17.2, 9.8]   # top -> bottom
H = 6.0

# Edge tier
box(ax, 2.2, ROWS[0], 17.6, H, "JXCT pH probe", LTERRA, TERRA, sub="4-20 mA loop")
box(ax, 2.2, ROWS[1], 17.6, H, "ESP32 (Xtensa)", LTERRA, TERRA, sub="ADC1 / GPIO34")
box(ax, 2.2, ROWS[2], 17.6, H, "Median filter +", LTERRA, TERRA, sub="2-point calibration")
box(ax, 2.2, ROWS[3], 17.6, H, "Wi-Fi 802.11n", LTERRA, TERRA, sub="TLS uplink")
for k in range(3):
    arrow(ax, (11.0, ROWS[k]), (11.0, ROWS[k + 1] + H), TERRA)

# Cloud tier
box(ax, 24.2, ROWS[0], 21.6, H, "Firebase Realtime DB", LBLUE, BLUE, sub="asia-southeast1")
box(ax, 24.2, ROWS[1], 21.6, H, "Firebase Auth", LBLUE, BLUE, sub="anon + email")
box(ax, 24.2, ROWS[2], 21.6, H, "Cloud Firestore", LBLUE, BLUE, sub="user & farm records")
box(ax, 24.2, ROWS[3], 21.6, H, "External REST APIs", LBLUE, BLUE, sub="Open-Meteo, AGMARKNET")

# Inference tier
box(ax, 50.2, ROWS[0], 21.6, H, "FastAPI service", LGOLD, GOLD, sub="Render, 512 MB")
box(ax, 50.2, ROWS[1], 21.6, H, "Feature pipeline", LGOLD, GOLD, sub="9 features, scaler")
box(ax, 50.2, ROWS[2], 21.6, H, "HistGB classifier", LGOLD, GOLD, sub="26.7 MB artifact")
box(ax, 50.2, ROWS[3], 21.6, H, "TFLite leaf model", LGOLD, GOLD, sub="on-device CNN")

# App tier
box(ax, 76.2, ROWS[0], 21.6, H, "Flutter UI", LGREEN, GREEN, sub="Riverpod state")
box(ax, 76.2, ROWS[1], 21.6, H, "Live pH dashboard", LGREEN, GREEN, sub="60 s staleness gate")
box(ax, 76.2, ROWS[2], 21.6, H, "Crop advisor", LGREEN, GREEN, sub="top-3 + confidence")
box(ax, 76.2, ROWS[3], 21.6, H, "Market / subsidy", LGREEN, GREEN, sub="offline fallback")

# Cross-tier flows - confined to the gutters between bands
arrow(ax, (19.8, ROWS[0] + H / 2), (24.2, ROWS[0] + H / 2), TERRA, lw=1.1)
arrow(ax, (45.8, ROWS[1] + H / 2), (50.2, ROWS[1] + H / 2), BLUE, lw=1.1)
arrow(ax, (71.8, ROWS[2] + H / 2), (76.2, ROWS[2] + H / 2), GOLD, lw=1.1)
arrow(ax, (45.8, ROWS[0] + H / 2), (76.2, ROWS[0] + H / 2), BLUE, lw=1.0, rad=-0.32)

ax.text(21.9, ROWS[0] + H + 1.0, "pH", fontsize=5.6, color=TERRA, ha="center", style="italic")
ax.text(61.0, 40.3, "live pH stream (bypasses inference)", fontsize=5.6, color=BLUE,
        ha="center", style="italic")
ax.text(48.0, ROWS[1] + H + 0.6, "context", fontsize=5.6, color=BLUE, ha="center", style="italic")
ax.text(74.0, ROWS[2] + H + 0.6, "top-k", fontsize=5.6, color=GOLD, ha="center", style="italic")

# Return path along the clear bottom lane
LANE = 3.4
arrow(ax, (87.0, ROWS[3]), (87.0, LANE), GREEN, lw=1.0)
arrow(ax, (87.0, LANE), (35.0, LANE), GREEN, lw=1.0)
arrow(ax, (35.0, LANE), (35.0, ROWS[3]), GREEN, lw=1.0)
ax.text(61.0, LANE + 1.0, "REST queries: weather, mandi prices, subsidy schemes",
        fontsize=5.8, color=GREEN, ha="center", style="italic")

fig.savefig(OUT / "fig_architecture.png")
plt.close(fig)


# ══════════════════════════════════════════════════════════
# FIG: ML pipeline (column width)
# ══════════════════════════════════════════════════════════
fig, ax = plt.subplots(figsize=(COL, 3.65))
ax.set_xlim(0, 66); ax.set_ylim(0, 100); ax.axis("off")

box(ax, 3, 90, 54, 8.0, "Agronomic knowledge base", LGREEN, GREEN, fs=7, bold=True,
    sub="20 crops x 19 states, 10 agro-climatic zones")
box(ax, 3, 78, 25, 8.0, "Profile sampling", LGREY, GREY, fs=6.5,
    sub="Gaussian noise")
box(ax, 32, 78, 25, 8.0, "Sensor injection", LTERRA, TERRA, fs=6.5,
    sub="10%, optional")
box(ax, 3, 66, 54, 8.0, "Balanced corpus: 150,000 samples", LGREY, GREY, fs=7,
    sub="7,500 per class")
box(ax, 3, 54, 54, 8.0, "Feature engineering", LGOLD, GOLD, fs=7, bold=True,
    sub="cyclical month, T x RH, dew point, VPD")
box(ax, 3, 42, 54, 8.0, "Standardisation + label encoding", LGREY, GREY, fs=6.7,
    sub="location_enc left unscaled")
box(ax, 3, 30, 25, 8.0, "Train 120,000", LBLUE, BLUE, fs=6.5, sub="80%")
box(ax, 32, 30, 25, 8.0, "Test 30,000", LBLUE, BLUE, fs=6.5, sub="20%, stratified")
box(ax, 3, 18, 54, 8.0, "HistGradientBoosting", LGOLD, GOLD, fs=7, bold=True,
    sub="400 iter, lr 0.10, L2 0.1")
box(ax, 3, 6, 54, 8.0, "Evaluation", LGREEN, GREEN, fs=7, bold=True,
    sub="accuracy, macro-F1, 5-fold CV, permutation importance")

arrow(ax, (30, 90), (15.5, 86.2), GREEN)
arrow(ax, (30, 90), (44.5, 86.2), TERRA, ls=(0, (2.5, 1.5)))
arrow(ax, (15.5, 78), (25, 74.2), GREY)
arrow(ax, (44.5, 78), (35, 74.2), TERRA, ls=(0, (2.5, 1.5)))
arrow(ax, (30, 66), (30, 62.2), GREY)
arrow(ax, (30, 54), (30, 50.2), GOLD)
arrow(ax, (30, 42), (15.5, 38.2), GREY)
arrow(ax, (30, 42), (44.5, 38.2), GREY)
arrow(ax, (15.5, 30), (25, 26.2), BLUE)
arrow(ax, (30, 18), (30, 14.2), GOLD)
# held-out test path routed clear of the model box
arrow(ax, (57, 34.0), (61.5, 34.0), BLUE)
arrow(ax, (61.5, 34.0), (61.5, 10.0), BLUE)
arrow(ax, (61.5, 10.0), (57, 10.0), BLUE)
ax.text(63.4, 22.0, "held out", fontsize=5.4, color=BLUE, style="italic",
        rotation=90, ha="center", va="center")
fig.savefig(OUT / "fig_pipeline.png")
plt.close(fig)

print("wrote fig_architecture.png, fig_pipeline.png")
