import pandas as pd
import geopandas as gpd
from shapely.geometry import Point
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def preprocess_data(file_path: str,
                    geojson_path: str = "all-wilayas.geojson",
                    save_cleaned_path: str = "cleaned_pdv_data.csv") -> dict:
    """
    Preprocess PDV data: clean invalid rows and filter by geographic boundary.
    """
    logger.info(f"Preprocessing started for file: {file_path}")

    if not os.path.exists(file_path):
        raise FileNotFoundError(f"CSV file not found: {file_path}")
    if not os.path.exists(geojson_path):
        raise FileNotFoundError(f"GeoJSON file not found: {geojson_path}")

    df = pd.read_csv(file_path)
    original_count = len(df)
    logger.info(f"Loaded {original_count} rows")

    # Drop rows with missing values
    nan_count = df.isna().any(axis=1).sum()
    df.dropna(inplace=True)
    logger.info(f"Dropped {nan_count} rows with NaN values")

    # Check for required columns
    required_cols = ['Wilaya', 'Latitude', 'Longitude']
    missing = [col for col in required_cols if col not in df.columns]
    if missing:
        raise ValueError(f"Missing columns: {missing}")

    # Normalize wilaya names and filter
    df['Wilaya'] = df['Wilaya'].astype(str).str.lower()
    unique_wilayas = df['Wilaya'].unique()
    logger.info(f"Found wilayas: {unique_wilayas}")
    
    target_wilaya = unique_wilayas[0]
    df = df[df['Wilaya'] == target_wilaya]

    # Clean coordinate values
    df['Latitude'] = pd.to_numeric(df['Latitude'], errors='coerce')
    df['Longitude'] = pd.to_numeric(df['Longitude'], errors='coerce')
    invalid_coords = df[df['Latitude'].isna() | df['Longitude'].isna()].shape[0]
    df.dropna(subset=['Latitude', 'Longitude'], inplace=True)
    logger.info(f"Dropped {invalid_coords} rows with invalid coordinates")

    # Validate geographic bounds for Algeria
    in_bounds = df[
        (df['Latitude'] >= 19) & (df['Latitude'] <= 37) &
        (df['Longitude'] >= -9) & (df['Longitude'] <= 12)
    ]
    out_of_bounds_count = len(df) - len(in_bounds)
    df = in_bounds
    logger.info(f"Removed {out_of_bounds_count} rows outside Algeria bounds")

    # Load geojson and get target polygon
    wilayas_gdf = gpd.read_file(geojson_path)
    target_geom = wilayas_gdf[wilayas_gdf['name'].str.lower() == target_wilaya]
    if target_geom.empty:
        available = wilayas_gdf['name'].str.lower().tolist()
        raise ValueError(f"Wilaya '{target_wilaya}' not found. Available: {available}")
    polygon = target_geom.geometry.values[0]

    # Spatial filtering
    gdf = gpd.GeoDataFrame(df, geometry=gpd.points_from_xy(df['Longitude'], df['Latitude']), crs="EPSG:4326")
    gdf['inside'] = gdf.geometry.within(polygon)
    cleaned_df = gdf[gdf['inside']].drop(columns=['geometry', 'inside']).copy()
    outside_boundary = len(gdf) - len(cleaned_df)
    logger.info(f"Removed {outside_boundary} rows outside polygon")

    # Save result
    cleaned_df.to_csv(save_cleaned_path, index=False)
    logger.info(f"Saved cleaned data to {save_cleaned_path}")

    return {
        "dataframe": cleaned_df,
        "stats": {
            "original_count": original_count,
            "nan_dropped": nan_count,
            "invalid_coords": invalid_coords,
            "invalid_range": out_of_bounds_count,
            "outside_boundary": outside_boundary,
            "final_count": len(cleaned_df)
        }
    }
