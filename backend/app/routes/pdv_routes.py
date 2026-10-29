from urllib import request
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
import os
import shutil
import tempfile
import json
from pydantic import BaseModel
from app.services.clustering_service import run_clustering_pipeline
import logging
from pathlib import Path
from ..ml.add_pdv import assign_and_rebalance_pdv
from ..ml.delete_pdv import delete_pdv_and_rebalance


# Set up logger
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

router = APIRouter()

@router.post("/upload-csv/")
async def upload_csv(
    file: UploadFile = File(...),
    n_clusters: int = Form(5)
):
    """
    Upload a CSV file for clustering PDV data
    
    Args:
        file: CSV file with PDV data including Latitude and Longitude columns
        n_clusters: Number of clusters to create (default: 5)
    
    Returns:
        Dictionary with clustering results
    """
    try:
        logger.info(f"Received file: {file.filename}, n_clusters: {n_clusters}")
        
        # Create a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.csv') as temp_file:
            temp_file_path = temp_file.name
            # Copy the file content to the temporary file
            shutil.copyfileobj(file.file, temp_file)
        
        logger.info(f"Saved uploaded file to temporary location: {temp_file_path}")
        
        # Run clustering pipeline
        results = run_clustering_pipeline(temp_file_path, n_clusters=n_clusters)
        
        # Clean up the temporary file
        os.unlink(temp_file_path)
        
        # Return results
        if not results.get("success", False):
            logger.error(f"Clustering pipeline failed: {results.get('error', 'Unknown error')}")
            raise HTTPException(status_code=500, detail=results.get("error", "Clustering pipeline failed"))
            
        logger.info("Clustering completed successfully")
        return results
    
    except Exception as e:
        logger.exception("Error processing upload")
        # Clean up the temporary file if it exists
        if 'temp_file_path' in locals() and os.path.exists(temp_file_path):
            os.unlink(temp_file_path)
            
        # Raise HTTP exception
        raise HTTPException(status_code=500, detail=str(e))
    
@router.post("/rerun/")
async def rerun_clustering(
    n_clusters: int = Form(...)
):
    """
    Re-run KMeans + rebalancing on the previously-cleaned CSV,
    overwrite the JSON files in Wilaya_CSVs, and return the final clusters.
    """
    try:
        logger.info(f"Rerunning clustering with n_clusters={n_clusters}")
        
        # Path to the cleaned CSV you wrote on the first upload
        from pathlib import Path
        import json
        
        backend = Path(__file__).resolve().parent.parent.parent
        cleaned_csv = backend / "Wilaya_CSVs" / "cleaned_pdv_data.csv"
        
        if not cleaned_csv.exists():
            logger.error("No cleaned CSV found at path: {}".format(cleaned_csv))
            raise HTTPException(400, "No cleaned CSV found. Upload first.")

        logger.info(f"Using cleaned CSV at: {cleaned_csv}")

        # Re-run just the clustering & balancing steps
        from app.services.clustering_service import run_kmeans_workload, run_rebalancing
        
        # This will overwrite initial_clusters.json & best_workload_parameters.json:
        logger.info(f"Running KMeans with n_clusters={n_clusters}")
        km = run_kmeans_workload(str(cleaned_csv), n_clusters=n_clusters)
        
        # And overwrite rebalanced_clusters.json:
        logger.info("Running rebalancing")
        rb = run_rebalancing(
            cluster_json_path=str(backend / "Wilaya_CSVs" / "initial_clusters.json"),
            params_path=str(backend / "Wilaya_CSVs" / "best_workload_parameters.json"),
            output_path=str(backend / "Wilaya_CSVs" / "rebalanced_clusters.json")
        )

        # Return the new rebalanced JSON content:
        final_path = backend / "Wilaya_CSVs" / "rebalanced_clusters.json"
        logger.info(f"Reading final results from: {final_path}")
        
        if not final_path.exists():
            logger.error(f"Final results file not found at: {final_path}")
            raise HTTPException(500, "Failed to generate rebalanced clusters")
            
        try:
            final_results = json.loads(final_path.read_text(encoding="utf-8"))
            logger.info("Successfully loaded rebalanced clusters")
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON: {e}")
            raise HTTPException(500, f"Failed to parse rebalanced clusters JSON: {e}")

        return {
            "success": True,
            "kmeans": km,
            "rebalancing": rb,
            "rebalanced_clusters": final_results
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Error re-running clustering: {e}")
        raise HTTPException(500, str(e))
    





# For GET /clusters/
@router.get("/clusters/")
async def get_clusters():
    """
    Return the latest rebalanced_clusters.json as a dict of cluster_i → [pdvs…].
    """
    backend = Path(__file__).resolve().parent.parent.parent
    path = backend / "Wilaya_CSVs" / "rebalanced_clusters.json"
    if not path.exists():
        raise HTTPException(status_code=404, detail="No cluster file yet. Upload first.")
    return json.loads(path.read_text(encoding="utf-8"))

# Define request body using Pydantic
class AssignPDVRequest(BaseModel):
    pdv: dict
    wilaya_boundaries: dict
    threshold: float = 5.0  # default value

# For POST /assign-pdv
@router.post("/assign-pdv")
async def assign_pdv(data: AssignPDVRequest):
    result = assign_and_rebalance_pdv(data.pdv, data.wilaya_boundaries, data.threshold)
    return result





class DeletePDVRequest(BaseModel):
    latitude: float
    longitude: float

@router.post("/delete-pdv")
def delete_pdv(request: DeletePDVRequest):
    result = delete_pdv_and_rebalance(request.dict())
    return result