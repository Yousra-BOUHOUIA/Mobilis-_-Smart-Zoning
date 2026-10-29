import json
import statistics
import os
import logging

from ..ml.add_pdv import assign_and_rebalance_pdv
from app.ml.cluster_rebalancer import haversine

def calculate_workload_variance(clusters, alpha, beta):
    workloads = [
        alpha * c["avg_distance_km"] + beta * c["num_of_pdvs"]
        for c in clusters.values()
    ]
    total = sum(workloads)
    if total == 0:
        return 0.0
    percentages = [(w / total) * 100 for w in workloads]
    return statistics.variance(percentages)

def delete_pdv_and_rebalance(pdv_to_delete: dict):
    file_path = "rebalanced_add_clusters.json"
    if not os.path.exists(file_path):
        logging.error(f"File '{file_path}' not found, cannot proceed with deletion and rebalancing.")
        return {"success": False, "message": f"File '{file_path}' not found."}
    
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            rebalanced_clusters = json.load(f)
    except Exception as e:
        logging.error(f"Error reading file '{file_path}': {e}")
        return {"success": False, "message": f"Error reading file '{file_path}': {e}"}

    file_path_best_params = "best_workload_parameters.json"
    if not os.path.exists(file_path_best_params):
        logging.error(f"File '{file_path_best_params}' not found.")
        return {"success": False, "message": f"File '{file_path_best_params}' not found."}
    
    try:
        with open(file_path_best_params, "r", encoding="utf-8") as f:
            best_params = json.load(f)
    except Exception as e:
        logging.error(f"Error reading file '{file_path_best_params}': {e}")
        return {"success": False, "message": f"Error reading file '{file_path_best_params}': {e}"}

    alpha = best_params['best_alpha']
    beta = best_params['best_beta']

    variance_before = calculate_workload_variance(rebalanced_clusters, alpha, beta)

    deleted = False
    deleted_cluster_key = None
    for cluster_key, cluster in rebalanced_clusters.items():
        pdvs = cluster["pdvs"]
        for pdv in pdvs:
            if (abs(pdv["latitude"] - pdv_to_delete["latitude"]) < 1e-6 and
                abs(pdv["longitude"] - pdv_to_delete["longitude"]) < 1e-6):
                pdvs.remove(pdv)
                update_cluster_stats(cluster_key, rebalanced_clusters)
                deleted = True
                deleted_cluster_key = cluster_key
                break
        if deleted:
            break

    if not deleted:
        return {"success": False, "message": "PDV not found in any cluster."}

    # Try to rebalance
    remaining_pdvs = rebalanced_clusters[deleted_cluster_key]["pdvs"]
    if remaining_pdvs:
        reference = pdv_to_delete
        closest_pdv = min(remaining_pdvs, key=lambda p: haversine(
            p["latitude"], p["longitude"], reference["latitude"], reference["longitude"]
        ))

        closest_cluster_key = None
        closest_distance = float("inf")

        for cid, c in rebalanced_clusters.items():
            if cid == deleted_cluster_key or not c["pdvs"]:
                continue
            cluster_center_lat = sum(p["latitude"] for p in c["pdvs"]) / len(c["pdvs"])
            cluster_center_lon = sum(p["longitude"] for p in c["pdvs"]) / len(c["pdvs"])
            dist = haversine(closest_pdv["latitude"], closest_pdv["longitude"], cluster_center_lat, cluster_center_lon)
            if dist < closest_distance:
                closest_distance = dist
                closest_cluster_key = cid

        if closest_cluster_key:
            rebalanced_clusters[deleted_cluster_key]["pdvs"].remove(closest_pdv)
            rebalanced_clusters[closest_cluster_key]["pdvs"].append(closest_pdv)
            update_cluster_stats(deleted_cluster_key, rebalanced_clusters)
            update_cluster_stats(closest_cluster_key, rebalanced_clusters)

    variance_after = calculate_workload_variance(rebalanced_clusters, alpha, beta)

    output_file_path = "rebalanced_delete_clusters.json"
    try:
        with open(output_file_path, "w", encoding="utf-8") as f:
            json.dump(rebalanced_clusters, f, ensure_ascii=False, indent=4)
    except Exception as e:
        logging.error(f"Error writing to file '{output_file_path}': {e}")
        return {"success": False, "message": f"Error writing to file '{output_file_path}': {e}"}

    return {
        "success": True,
        "variance_before": variance_before,
        "variance_after": variance_after,
    }
