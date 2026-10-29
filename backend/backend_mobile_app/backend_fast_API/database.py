from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os
from dotenv import load_dotenv
from pathlib import Path

# Get the directory where this file is located
BASE_DIR = Path(__file__).resolve().parent

# Load environment variables from .env file
env_path = BASE_DIR / ".env"
load_dotenv(dotenv_path=env_path)

# Get database URL from environment or use a default for development
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("Warning: DATABASE_URL not found in environment!")
    DATABASE_URL = "postgresql://postgres:123456789@localhost:5432/Mobilis"
    print(f"Using default DATABASE_URL: {DATABASE_URL}")
else:
    print(f"Connected to: {DATABASE_URL}")

# Create SQLAlchemy engine
engine = create_engine(DATABASE_URL)

# Create session factory
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

# Base class for models
Base = declarative_base()