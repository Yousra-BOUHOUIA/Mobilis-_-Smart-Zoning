# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import logging
from app.routes import pdv_routes

# --- Logging setup (do this before you instantiate FastAPI) ---
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(),           # Log to console
        logging.FileHandler("app.log")     # Log to file
    ]
)
logger = logging.getLogger(__name__)
logger.info("Starting Smart Zoning API")

# --- FastAPI app ---
app = FastAPI(
    title="Smart Zoning API",
    description="API for Smart Zoning and PDV management",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# INCLUDE THE CORRECT ROUTER
from app.routes import pdv_routes
app.include_router(pdv_routes.router, prefix="/pdv", tags=["PDV"])

@app.get("/")
async def root():
    return {"message": "Welcome to the Smart Zoning API"}

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
