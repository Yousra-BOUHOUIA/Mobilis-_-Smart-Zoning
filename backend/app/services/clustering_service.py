# app/services/clustering_service.py

import os
import json
import math
from pathlib import Path

import pandas as pd
import numpy as np
from sklearn.cluster import KMeans

# ────────────────────────────────────────────────────────────────────────────────
#  Directory setup
# ────────────────────────────────────────────────────────────────────────────────
BACKEND_DIR = Path(__file__).resolve().parent.parent.parent  # …/backend
OUTPUT_DIR  = BACKEND_DIR / "Wilaya_CSVs"                   # …/backend/Wilaya_CSVs
OUTPUT_DIR.mkdir(exist_ok=True)

# ────────────────────────────────────────────────────────────────────────────────
#  Step 1: Preprocessing (CSV only)
# ────────────────────────────────────────────────────────────────────────────────
def preprocess_data(
    file_path: str,
    save_cleaned_path: str = str(OUTPUT_DIR / "cleaned_pdv_data.csv")
) -> str:
    """
    Read CSV, drop rows with any missing values, write cleaned CSV, return its path.
    """
    df = pd.read_csv(file_path)
    df_clean = df.dropna()
    df_clean.to_csv(save_cleaned_path, index=False)
    return save_cleaned_path

# ────────────────────────────────────────────────────────────────────────────────
#  Step 2: KMeans + JSON dumps for initial clusters & best params
# ────────────────────────────────────────────────────────────────────────────────
def haversine(lat1, lon1, lat2, lon2):
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * \
        math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    return 2 * R * math.asin(math.sqrt(a))

def run_kmeans_workload(csv_path: str, n_clusters: int = 5):
    """
    Run KMeans on numeric columns in the cleaned CSV,
    write initial_clusters.json and best_workload_parameters.json,
    return metadata.
    """
    df = pd.read_csv(csv_path)
    
    # Use only numeric columns for clustering
    num_df = df.select_dtypes(include=[np.number]).fillna(0)
    if num_df.shape[1] == 0:
        raise ValueError("No numeric columns found for clustering")
        
    coords = num_df.to_numpy()
    model = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
    labels = model.fit_predict(coords)
    df['cluster'] = labels

    # Build cluster data for JSON
    cluster_data = []
    for i in range(n_clusters):
        pts = df[df['cluster'] == i]
        center = model.cluster_centers_[i].tolist()
        cluster_data.append({
            "cluster_id": i,
            "center": center,
            "num_points": len(pts),
            "rows": pts.to_dict(orient='records')
        })

    # Find best alpha/beta by workload variance
    alphas = np.linspace(0.1, 2, 20)
    betas   = {a: np.linspace(a+0.5, 5, 20) for a in alphas}
    best = {"variance": float('inf'), "alpha": None, "beta": None, "workloads": None}

    for a in alphas:
        for b in betas[a]:
            workloads = [a*c["num_points"] + b*sum(center) for c, center in zip(cluster_data, model.cluster_centers_)]
            norm = [w/sum(workloads)*100 for w in workloads]
            var  = np.var(norm)
            if var < best["variance"]:
                best.update({"variance": var, "alpha": a, "beta": b, "workloads": norm})

    # Write initial_clusters.json
    init_path = OUTPUT_DIR / "initial_clusters.json"
    with open(init_path, 'w', encoding='utf-8') as f:
        json.dump(
            {"clusters": cluster_data},
            f, ensure_ascii=False, indent=2
        )

    # Write best_workload_parameters.json
    best_path = OUTPUT_DIR / "best_workload_parameters.json"
    with open(best_path, 'w', encoding='utf-8') as f:
        json.dump(
            {"best_alpha": best["alpha"],
             "best_beta": best["beta"],
             "workloads": best["workloads"]},
            f, ensure_ascii=False, indent=2
        )

    return {
        "clusters": cluster_data,
        "best_alpha": best["alpha"],
        "best_beta": best["beta"],
        "output_files": {
            "initial": init_path.name,
            "best_params": best_path.name
        }
    }

# ────────────────────────────────────────────────────────────────────────────────
#  Step 3: Rebalancing + JSON dump
# ────────────────────────────────────────────────────────────────────────────────
def run_rebalancing(
    cluster_json_path: str = str(OUTPUT_DIR / "initial_clusters.json"),
    params_path:        str = str(OUTPUT_DIR / "best_workload_parameters.json"),
    output_path:        str = str(OUTPUT_DIR / "rebalanced_clusters.json")
):
    """
    Read initial + params JSON, rebalance clusters, write rebalanced_clusters.json.
    """
    with open(cluster_json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)["clusters"]
    with open(params_path, 'r', encoding='utf-8') as f:
        params = json.load(f)

    alpha, beta = params["best_alpha"], params["best_beta"]

    # Flatten all points
    all_pts = []
    for c in data:
        for row in c["rows"]:
            row["cluster"] = c["cluster_id"]
            all_pts.append(row)

    # Variance fn: here just based on counts
    def variance(groups):
        counts = [len(groups[i]) for i in sorted(groups)]
        w = [alpha*counts[i] + beta*sum(counts) for i in range(len(counts))]
        return np.var(w)

    # Initial grouping
    groups = {}
    for p in all_pts:
        groups.setdefault(p["cluster"], []).append(p)

    # Rebalance: simple heuristic—no movement in this CSV-only example
    # (you can implement your own )

    # Write rebalanced_clusters.json = same as initial
    out = {f"cluster_{i}": groups[i] for i in groups}
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    return {"success": True, "rebalanced_file": Path(output_path).name}

# ────────────────────────────────────────────────────────────────────────────────
#  Orchestrator called by FastAPI
# ────────────────────────────────────────────────────────────────────────────────
def run_clustering_pipeline(file_path: str, n_clusters: int = 5):
    """
    Full pipeline: preprocess → kmeans → rebalancing
    """
    cleaned_csv = preprocess_data(file_path)
    k_out       = run_kmeans_workload(cleaned_csv, n_clusters=n_clusters)
    r_out       = run_rebalancing()
    return {
        "success": True,
        "files": {
            "cleaned_csv": Path(cleaned_csv).name,
            "initial":     "initial_clusters.json",
            "best_params": "best_workload_parameters.json",
            "rebalanced":  "rebalanced_clusters.json"
        },
        "kmeans":     k_out,
        "rebalancing": r_out
    }
