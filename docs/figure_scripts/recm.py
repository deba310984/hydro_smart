"""Regenerate the confusion matrix at its final printed size.

Capping the previous 6.2 in figure down to 3.5 in shrank its cell labels to
about 4.5 pt, below what IEEE figures should carry. Drawing it at the size it
will actually occupy keeps the type at ~5.5 pt with no downscaling. The matrix
is also persisted to results.json so it need not be retrained again.
"""
import importlib.util, json, sys, warnings
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix
warnings.filterwarnings("ignore")

REPO = Path(r"C:\hydro_smart")
DIR = Path(__file__).parent
OUT = DIR / "figs"
SEED = 42

spec = importlib.util.spec_from_file_location("tm", REPO / "ml_backend" / "train_model.py")
tm = importlib.util.module_from_spec(spec); sys.argv = ["x"]; spec.loader.exec_module(tm)

FEATURES = ["temperature", "humidity", "location_enc", "month",
            "month_sin", "month_cos", "temp_hum_interaction", "dew_point", "vpd"]

df = tm.generate_synthetic_dataset(150_000, sensor_data=None)
d = tm.add_engineered_features(df)
d["location_enc"] = LabelEncoder().fit_transform(d["location"])
le = LabelEncoder(); y = le.fit_transform(d["crop"])
CROPS = list(le.classes_)
X = d[FEATURES].values.astype(float)
li = FEATURES.index("location_enc")
si = [i for i in range(len(FEATURES)) if i != li]
X[:, si] = StandardScaler().fit_transform(X[:, si])
Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=SEED, stratify=y)

print("training...", flush=True)
m = HistGradientBoostingClassifier(max_iter=400, learning_rate=0.10, min_samples_leaf=20,
                                   l2_regularization=0.1, early_stopping=False,
                                   random_state=SEED).fit(Xtr, ytr)
pred = m.predict(Xte)
cm = confusion_matrix(yte, pred, normalize="true") * 100
print("accuracy check:", (pred == yte).mean())

plt.rcParams.update({
    "font.family": "serif", "font.serif": ["Times New Roman", "DejaVu Serif"],
    "savefig.dpi": 300, "savefig.bbox": "tight", "savefig.pad_inches": 0.02,
})
# Drawn at the size it is placed: 4.55 x 3.95 in, so no downscaling shrinks type.
fig, ax = plt.subplots(figsize=(4.55, 3.95))
im = ax.imshow(cm, cmap="Greens", vmin=0, vmax=100, aspect="equal")
ax.set_xticks(range(len(CROPS))); ax.set_xticklabels(CROPS, rotation=90, fontsize=5.6)
ax.set_yticks(range(len(CROPS))); ax.set_yticklabels(CROPS, fontsize=5.6)
ax.set_xlabel("Predicted class", fontsize=7)
ax.set_ylabel("True class", fontsize=7)
for i in range(len(CROPS)):
    for j in range(len(CROPS)):
        v = cm[i, j]
        if v >= 4:
            ax.text(j, i, f"{v:.0f}", ha="center", va="center", fontsize=5.2,
                    color="white" if v > 55 else "#222222")
ax.grid(False)
ax.tick_params(length=1.6, width=0.5)
cb = fig.colorbar(im, ax=ax, fraction=0.043, pad=0.02)
cb.set_label("Row-normalised recall (%)", fontsize=6.2)
cb.ax.tick_params(labelsize=5.6, length=1.6, width=0.5)
fig.savefig(OUT / "fig_confusion_matrix.png")
plt.close(fig)

R = json.load(open(DIR / "results.json"))
R["confusion_matrix_pct"] = cm.round(3).tolist()
R["confusion_labels"] = CROPS
json.dump(R, open(DIR / "results.json", "w"), indent=2, default=str)
import struct
w, h = struct.unpack(">II", (OUT / "fig_confusion_matrix.png").read_bytes()[16:24])
print(f"redrew confusion matrix: {w}x{h}px, aspect {h/w:.3f}")
