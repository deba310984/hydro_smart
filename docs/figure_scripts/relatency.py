"""Corrected latency benchmark.

The first pass measured ~1096 ms for a single-sample predict, which is not a
real inference cost: sklearn's HistGradientBoosting spins up an OpenMP thread
pool on every predict() call, and that fixed overhead dominates completely at
small batch sizes (batch 512 cost barely more than batch 1). Pinning the pool
to one thread measures the actual arithmetic, which is what a paper should
report. We record both, since the threaded figure is what a naive deployment
would see.
"""
import os
# must precede the sklearn/numpy import
os.environ["OMP_NUM_THREADS"] = "1"
os.environ["OPENBLAS_NUM_THREADS"] = "1"
os.environ["MKL_NUM_THREADS"] = "1"

import importlib.util, json, sys, time
from pathlib import Path
import numpy as np
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
import warnings; warnings.filterwarnings("ignore")

REPO = Path(r"C:\hydro_smart")
DIR = Path(__file__).parent
SEED = 42

spec = importlib.util.spec_from_file_location("tm", REPO / "ml_backend" / "train_model.py")
tm = importlib.util.module_from_spec(spec); sys.argv = ["x"]; spec.loader.exec_module(tm)

FEATURES = ["temperature", "humidity", "location_enc", "month",
            "month_sin", "month_cos", "temp_hum_interaction", "dew_point", "vpd"]

df = tm.generate_synthetic_dataset(150_000, sensor_data=None)
d = tm.add_engineered_features(df)
d["location_enc"] = LabelEncoder().fit_transform(d["location"])
y = LabelEncoder().fit_transform(d["crop"])
X = d[FEATURES].values.astype(float)
li = FEATURES.index("location_enc")
si = [i for i in range(len(FEATURES)) if i != li]
X[:, si] = StandardScaler().fit_transform(X[:, si])
Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=SEED, stratify=y)

print("training...", flush=True)
hgb = HistGradientBoostingClassifier(max_iter=400, learning_rate=0.10, min_samples_leaf=20,
                                     l2_regularization=0.1, early_stopping=False,
                                     random_state=SEED).fit(Xtr, ytr)
knn = KNeighborsClassifier(n_neighbors=15, n_jobs=1).fit(Xtr, ytr)

def bench(model, name):
    out = {}
    for bs in [1, 8, 32, 128, 512]:
        xs = Xte[:bs]
        for _ in range(8):
            model.predict(xs)
        ts = []
        for _ in range(80):
            t0 = time.perf_counter(); model.predict(xs); ts.append((time.perf_counter() - t0) * 1000)
        ts = np.array(ts)
        out[bs] = dict(mean=float(ts.mean()), p50=float(np.percentile(ts, 50)),
                       p95=float(np.percentile(ts, 95)),
                       per_sample_ms=float(ts.mean() / bs))
        print(f"  {name:6s} batch={bs:4d} mean={ts.mean():8.3f}ms "
              f"p95={np.percentile(ts,95):8.3f}ms per-sample={ts.mean()/bs:8.4f}ms", flush=True)
    return out

print("\nsingle-threaded latency:")
res = {"hgb": bench(hgb, "HistGB"), "knn": bench(knn, "kNN")}

R = json.load(open(DIR / "results.json"))
R["latency_threaded"] = R["latency"]          # keep the original measurement
R["latency"] = res["hgb"]                      # corrected, single-threaded
R["latency_knn"] = res["knn"]
R["latency_note"] = ("Single-threaded (OMP_NUM_THREADS=1). The multi-threaded "
                     "measurement is retained as latency_threaded and is dominated "
                     "by per-call thread-pool setup at small batch sizes.")
json.dump(R, open(DIR / "results.json", "w"), indent=2, default=str)
print("\nupdated results.json")
