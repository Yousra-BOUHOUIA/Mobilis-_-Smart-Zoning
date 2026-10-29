import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
import math
import json
import os

def haversine(lat1, lon1, lat2, lon2):
    R = 6371
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (math.sin(d_lat / 2)**2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(d_lon / 2)**2)
    return 2 * R * math.asin(math.sqrt(a))

def run_kmeans_workload(df, n_clusters=7):
    if 'Latitude' not in df.columns or 'Longitude' not in df.columns:
        raise ValueError("DataFrame must contain 'Latitude' and 'Longitude' columns")

    coords = df[['Latitude', 'Longitude']].to_numpy()
    coords_rad = np.radians(coords)

    kmeans = KMeans(n_clusters=n_clusters, init='k-means++', n_init=10, random_state=42)
    kmeans.fit(coords_rad)
    df['cluster'] = kmeans.labels_

    cluster_data = []
    for i in range(kmeans.n_clusters):
        centroid = np.degrees(kmeans.cluster_centers_[i])
        centroid_lon, centroid_lat = centroid[1], centroid[0]
        cluster_pdv = df[df['cluster'] == i]

        distances = [
            haversine(centroid_lat, centroid_lon, row['Latitude'], row['Longitude'])
            for _, row in cluster_pdv.iterrows()
        ]
        avg_distance = sum(distances) / len(distances) if distances else 0

        pdvs = [
            {
                "pdv": row['Nom du point de vente'],
                "cluster": int(row['cluster']),
                "longitude": row['Longitude'],
                "latitude": row['Latitude']
            }
            for _, row in cluster_pdv.iterrows()
        ]

        cluster_data.append({
            "cluster_id": i,
            "centroid": {"longitude": centroid_lon, "latitude": centroid_lat},
            "avg_distance_km": avg_distance,
            "num_of_pdvs": len(pdvs),
            "pdvs": pdvs
        })

    alphas = np.linspace(0.1, 2, 20)
    betas_per_alpha = {a: np.linspace(a + 0.5, 5, 20) for a in alphas}
    best_alpha, best_beta, best_workloads = None, None, None
    min_variance = float('inf')

    for alpha in alphas:
        for beta in betas_per_alpha[alpha]:
            raw_workloads = [alpha * c['avg_distance_km'] + beta * c['num_of_pdvs'] for c in cluster_data]
            total = sum(raw_workloads)
            normed = [w / total * 100 for w in raw_workloads]
            variance = np.var(normed)

            if variance < min_variance:
                min_variance = variance
                best_alpha, best_beta, best_workloads = alpha, beta, normed

    output_folder = os.path.join(os.getcwd(), "Wilaya_CSVs")
    os.makedirs(output_folder, exist_ok=True)

    # Save initial clusters
    cluster_json = {
        f"cluster_{c['cluster_id']}": {
            "centroid": c["centroid"],
            "avg_distance_km": c["avg_distance_km"],
            "num_of_pdvs": c["num_of_pdvs"],
            "pdvs": c["pdvs"]
        }
        for c in cluster_data
    }

    with open(os.path.join(output_folder, "initial_clusters.json"), "w", encoding="utf-8") as f:
        json.dump(cluster_json, f, ensure_ascii=False, indent=4)

    # Save best alpha and beta
    best_params = {
        "best_alpha": best_alpha,
        "best_beta": best_beta,
        "cluster_workloads": {
            f"cluster_{i}": round(w, 2) for i, w in enumerate(best_workloads)
        }
    }

    with open(os.path.join(output_folder, "best_workload_parameters.json"), "w", encoding="utf-8") as f:
        json.dump(best_params, f, ensure_ascii=False, indent=4)

    return {
        "clusters": cluster_data,
        "best_alpha": best_alpha,
        "best_beta": best_beta,
        "output_files": {
            "initial_clusters": "initial_clusters.json",
            "best_parameters": "best_workload_parameters.json"
        }
    }
