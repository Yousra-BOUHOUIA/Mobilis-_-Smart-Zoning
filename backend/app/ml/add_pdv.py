import os
import json
import pandas as pd

from app.ml.cluster_rebalancer import haversine

def assign_and_rebalance_pdv(new_pdv, wilaya_boundaries, threshold):
    # Check if the CSV file exists
    if not os.path.exists("cleaned_pdv_data.csv"):
        return {"status": "error", "message": "cleaned_pdv_data.csv file not found"}

    # Proceed to read the CSV file
    df_cleaned = pd.read_csv("cleaned_pdv_data.csv")

    with open("rebalanced_clusters.json", "r", encoding="utf-8") as f:
        rebalanced_clusters = json.load(f)

    with open("best_workload_parameters.json", "r", encoding="utf-8") as f:
        best_params = json.load(f)

    alpha = best_params['best_alpha']
    beta = best_params['best_beta']

    centroids = {
        int(cid.split('_')[1]): (
            cluster_data["centroid"]["latitude"],
            cluster_data["centroid"]["longitude"]
        )
        for cid, cluster_data in rebalanced_clusters.items()
    }

    def is_within_wilaya(pdv, wilaya_boundaries):
        lat_min, lat_max, lon_min, lon_max = wilaya_boundaries
        return lat_min <= pdv["latitude"] <= lat_max and lon_min <= pdv["longitude"] <= lon_max

    def update_cluster_stats(cluster_key, cluster_data):
        pdvs = cluster_data[cluster_key]["pdvs"]
        centroid = cluster_data[cluster_key]["centroid"]
        total_distance = sum(
            haversine(pdv['latitude'], pdv['longitude'], centroid["latitude"], centroid["longitude"])
            for pdv in pdvs
        )
        avg_distance = total_distance / len(pdvs) if pdvs else 0
        cluster_data[cluster_key]["avg_distance_km"] = avg_distance
        cluster_data[cluster_key]["num_of_pdvs"] = len(pdvs)

    def assign_pdv_to_cluster(new_pdv, centroids, clusters, alpha, beta, threshold):
        def initial_nearest_cluster(pdv, centroids):
            min_dist = float('inf')
            best_cid = None
            for cid, centroid in centroids.items():
                dist = haversine(pdv["latitude"], pdv["longitude"], centroid[0], centroid[1])
                if dist < min_dist:
                    min_dist = dist
                    best_cid = cid
            return best_cid

        def calculate_single_workload(cluster, alpha, beta):
            return alpha * cluster["avg_distance_km"] + beta * cluster["num_of_pdvs"]

        def rebalance_cluster(overloaded_cid):
            cluster_key = f"cluster_{overloaded_cid}"
            centroid = centroids[overloaded_cid]
            cluster_pdvs = clusters[cluster_key]["pdvs"]

            while True:
                farthest_pdv = max(
                    cluster_pdvs,
                    key=lambda pdv: haversine(pdv["latitude"], pdv["longitude"], centroid[0], centroid[1])
                )
                distances = sorted(
                    [(cid, haversine(farthest_pdv["latitude"], farthest_pdv["longitude"], centroids[cid][0], centroids[cid][1]))
                     for cid in centroids if cid != overloaded_cid],
                    key=lambda x: x[1]
                )

                moved = False
                for target_cid, _ in distances:
                    target_key = f"cluster_{target_cid}"
                    cluster_pdvs.remove(farthest_pdv)
                    clusters[target_key]["pdvs"].append(farthest_pdv)
                    farthest_pdv["cluster"] = target_cid

                    update_cluster_stats(cluster_key, clusters)
                    update_cluster_stats(target_key, clusters)

                    new_workload = calculate_single_workload(clusters[cluster_key], alpha, beta)

                    if new_workload <= threshold:
                        moved = True
                        break
                    else:
                        clusters[target_key]["pdvs"].remove(farthest_pdv)
                        cluster_pdvs.append(farthest_pdv)
                        farthest_pdv["cluster"] = overloaded_cid
                        update_cluster_stats(cluster_key, clusters)
                        update_cluster_stats(target_key, clusters)

                if not moved or new_workload <= threshold:
                    break

        best_cluster = initial_nearest_cluster(new_pdv, centroids)
        new_pdv["cluster"] = best_cluster
        clusters[f"cluster_{best_cluster}"]["pdvs"].append(new_pdv)
        update_cluster_stats(f"cluster_{best_cluster}", clusters)

        workloads = {
            cid: calculate_single_workload(cluster, alpha, beta)
            for cid, cluster in clusters.items()
        }
        max_workload = max(workloads.values())
        min_workload = min(workloads.values())
        threshold_new = max_workload - min_workload

        if threshold_new > threshold:
            rebalance_cluster(best_cluster)

        return new_pdv, clusters

    if is_within_wilaya(new_pdv, wilaya_boundaries):
        updated_pdv, updated_clusters = assign_pdv_to_cluster(new_pdv, centroids, rebalanced_clusters, alpha, beta, threshold)

        cluster_id = updated_pdv["cluster"]
        cluster_key = f"cluster_{cluster_id}"
        if cluster_key not in updated_clusters:
            updated_clusters[cluster_key] = {"centroid": centroids[cluster_id], "pdvs": []}
        updated_clusters[cluster_key]["pdvs"].append(updated_pdv)
        update_cluster_stats(cluster_key, updated_clusters)

        with open("rebalanced_add_clusters.json", "w", encoding="utf-8") as f:
            json.dump(updated_clusters, f, ensure_ascii=False, indent=4)

        return {"status": "success", "assigned_cluster": cluster_id}
    else:
        return {"status": "out_of_bounds", "message": "PDV is outside the managed wilaya."}
