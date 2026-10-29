import json
import copy
from math import radians, sin, cos, sqrt, atan2
import numpy as np

# ------------------ [HAVERSINE FUNCTION] ------------------
def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth radius in kilometers
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c

# ------------------ [GROUP PDVs BY CLUSTER] ------------------
def group_pdvs_by_cluster(pdv_list):
    grouped = {}
    for pdv in pdv_list:
        c = pdv['cluster']
        if c not in grouped:
            grouped[c] = []
        grouped[c].append(pdv)
    return grouped

# ------------------ [COMPUTE CLUSTER STATS] ------------------
def compute_cluster_stats(grouped, centroids, alpha, beta):
    stats = []
    for cid, pdvs in grouped.items():
        lat, lon = centroids[cid]
        dists = [haversine(lat, lon, pdv['latitude'], pdv['longitude']) for pdv in pdvs]
        avg_dist = sum(dists) / len(dists) if dists else 0
        workload = alpha * avg_dist + beta * len(pdvs)
        stats.append(workload)
    return stats

# ------------------ [COMPUTE INITIAL VARIANCE] ------------------
def compute_initial_variance(all_pdvs, centroids, alpha, beta):
    initial_grouped = group_pdvs_by_cluster(all_pdvs)
    initial_workloads = compute_cluster_stats(initial_grouped, centroids, alpha, beta)
    initial_variance = np.var(initial_workloads)
    return initial_variance

# ------------------ [ASSIGN PDVs TO NEAREST CENTROID] ------------------
def assign_to_nearest_centroid(all_pdvs, centroids):
    assigned = []
    for pdv in all_pdvs:
        min_dist = float('inf')
        nearest_cluster = None
        for cid, (clat, clon) in centroids.items():
            dist = haversine(pdv['latitude'], pdv['longitude'], clat, clon)
            if dist < min_dist:
                min_dist = dist
                nearest_cluster = cid
        pdv['cluster'] = nearest_cluster
        assigned.append(pdv)
    return assigned

# ------------------ [PHASE 2: BALANCE REFINEMENT] ------------------
def try_rebalance(all_pdvs, centroids, alpha, beta, epsilon=1):
    print(f"\n[PHASE 1] Assigning PDVs to closest centroid...")
    pdvs = assign_to_nearest_centroid(copy.deepcopy(all_pdvs), centroids)

    print(f"[PHASE 2] Balancing workload with ε = {epsilon} km threshold...")
    improved = True

    while improved:
        improved = False
        grouped = group_pdvs_by_cluster(pdvs)
        current_variance = np.var(compute_cluster_stats(grouped, centroids, alpha, beta))

        for pdv in pdvs:
            original_cluster = pdv['cluster']
            original_centroid = centroids[original_cluster]
            original_dist = haversine(pdv['latitude'], pdv['longitude'], *original_centroid)

            for new_cluster, new_centroid in centroids.items():
                if new_cluster == original_cluster:
                    continue
                new_dist = haversine(pdv['latitude'], pdv['longitude'], *new_centroid)

                if new_dist - original_dist > epsilon:
                    continue

                pdv['cluster'] = new_cluster
                grouped_temp = group_pdvs_by_cluster(pdvs)
                new_variance = np.var(compute_cluster_stats(grouped_temp, centroids, alpha, beta))

                if new_variance < current_variance:
                    print(f"Moved PDV to cluster {new_cluster} (↓ variance)")
                    improved = True
                    current_variance = new_variance
                    break
                else:
                    pdv['cluster'] = original_cluster

    return pdvs, current_variance

# ------------------ [RUN REBALANCE] ------------------
def run_rebalancing(cluster_json_path="initial_clusters.json", params_path="best_workload_parameters.json", output_path="rebalanced_clusters.json"):
    with open(cluster_json_path, "r", encoding="utf-8") as f:
        cluster_data = json.load(f)

    with open(params_path, "r", encoding="utf-8") as f:
        best_params = json.load(f)

    alpha = best_params['best_alpha']
    beta = best_params['best_beta']

    # Flatten all PDVs
    all_pdvs = []
    for cid, cluster in cluster_data.items():
        for pdv in cluster['pdvs']:
            pdv['cluster'] = int(cid.split("_")[1])  
            all_pdvs.append(pdv)

    centroids = {
        int(cid.split("_")[1]): (c['centroid']['latitude'], c['centroid']['longitude'])
        for cid, c in cluster_data.items()
    }

    initial_variance = compute_initial_variance(all_pdvs, centroids, alpha, beta)
    print(f"Initial variance: {round(initial_variance, 4)}")

    rebalanced_pdvs, final_variance = try_rebalance(all_pdvs, centroids, alpha, beta)

    rebalanced_clusters = group_pdvs_by_cluster(rebalanced_pdvs)

    # ------------------ [SAVE TO JSON] ------------------
    rebalanced_json = {}
    for cid, pdvs in rebalanced_clusters.items():
        lat, lon = centroids[cid]
        avg_dist = sum(haversine(lat, lon, pdv['latitude'], pdv['longitude']) for pdv in pdvs) / len(pdvs)
        rebalanced_json[f"cluster_{cid}"] = {
            "centroid": {"latitude": lat, "longitude": lon},
            "avg_distance_km": avg_dist,
            "num_of_pdvs": len(pdvs),
            "pdvs": pdvs
        }

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(rebalanced_json, f, ensure_ascii=False, indent=4)

    print(f" >> Rebalanced clusters saved to '{output_path}'")
    print(f"New variance {round(final_variance, 4)}")

    return {
        "success": True,
        "initial_variance": initial_variance,
        "final_variance": final_variance,
        "rebalanced_file": output_path
    }
