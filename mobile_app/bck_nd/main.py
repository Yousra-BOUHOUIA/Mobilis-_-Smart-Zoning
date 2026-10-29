"""import subprocess
from pathlib import Path
import logging
from fastapi import FastAPI, Request, Response, Depends, HTTPException, status
from fastapi.responses import JSONResponse, HTMLResponse
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from .database import SessionLocal, engine
from . import models
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, validator
import hashlib
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from datetime import datetime, timedelta, date
from typing import Optional
import json
import os
from .Optimal_path import main as generate_optimal_path
import sys

# Get the absolute path to the directory containing main.py
BASE_DIR = Path(__file__).resolve().parent

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# Configure CORS with more specific settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://192.168.18.68"],  # Your Flutter app's IP
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# JWT Settings
SECRET_KEY = "your-secret-key-keep-it-secret"  # In production, use a secure secret key
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/login")

# Pydantic models
class UserCreate(BaseModel):
    fullname: str
    email: EmailStr
    phone: str
    manager: str
    password: str
    
    @validator('password')
    def password_must_be_strong(cls, v):
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters')
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id_users: int
    fullname: str
    email: str
    phone: str
    manager: str
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class StatModel(BaseModel):
    user_id: str
    date: date
    scanned_count: int
    total_count: int
    percent: float

# Add this Pydantic model for password change
class PasswordChange(BaseModel):
    current_password: str
    new_password: str
    
    @validator('new_password')
    def password_must_be_strong(cls, v):
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters')
        return v

# Add this Pydantic model for profile update
class ProfileUpdate(BaseModel):
    fullname: str
    email: EmailStr
    phone: str
    manager: str

# Helper function to hash passwords
def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Root endpoint
@app.get("/")
def read_root():
    return {"message": "FastAPI with PostgreSQL working!"}

# User registration endpoint
@app.post("/api/signup", status_code=status.HTTP_201_CREATED)
def signup(user: UserCreate, db: Session = Depends(get_db)):
    try:
        logger.info(f"Signup attempt for email: {user.email}")
        
        # Check if user already exists
        existing_user = db.query(models.User).filter(models.User.email == user.email).first()
        if existing_user:
            logger.warning(f"Signup failed: Email already registered: {user.email}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, 
                detail="Email already registered"
            )
        
        # Create new user with hashed password
        hashed_password = hash_password(user.password)
        db_user = models.User(
            fullname=user.fullname,
            email=user.email,
            phone=user.phone,
            manager=user.manager,
            password=hashed_password
        )
        
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        
        logger.info(f"User registered successfully: {user.email}")
        
        # Return user without password
        return {
            "message": "User registered successfully", 
            "user": {
                "id_users": db_user.id_users,
                "fullname": db_user.fullname,
                "email": db_user.email,
                "phone": db_user.phone,
                "manager": db_user.manager
            }
        }
        
    except IntegrityError as e:
        db.rollback()
        logger.error(f"Database integrity error during signup: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Email already registered"
        )
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error during signup: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Registration failed: {str(e)}"
        )

# Token model
class Token(BaseModel):
    access_token: str
    token_type: str

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(models.User).filter(models.User.email == email).first()
    if user is None:
        raise credentials_exception
    return user

# Update the login endpoint to include token generation
@app.post("/api/login", response_model=Token)
def login(user_data: UserLogin, db: Session = Depends(get_db)):
    try:
        logger.info(f"Login attempt for email: {user_data.email}")
        
        # Find user by email
        user = db.query(models.User).filter(models.User.email == user_data.email).first()
        
        if not user or hash_password(user_data.password) != user.password:
            logger.warning(f"Login failed: Invalid credentials for {user_data.email}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,  
                detail="Invalid email or password"
            )
        
        # Generate access token
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.email}, expires_delta=access_token_expires
        )
        
        logger.info(f"Login successful: {user_data.email}")
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id_users": user.id_users,
                "fullname": user.fullname,
                "email": user.email,
                "phone": user.phone,
                "manager": user.manager
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error during login: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Login failed: {str(e)}"
        )

# Update the profile endpoint
@app.get("/api/users/profile")
async def get_user_profile(current_user: models.User = Depends(get_current_user)):
    return {
        "success": True,
        "user": {
            "id_users": current_user.id_users,
            "fullname": current_user.fullname,
            "email": current_user.email,
            "phone": current_user.phone,
            "manager": current_user.manager
        }
    }

def run_path_generation():
    try:
        # Add the current directory to Python path
        sys.path.append(str(BASE_DIR))
        
        # Import and run the optimal path generation
        from Optimal_path import main as generate_optimal_path
        generate_optimal_path()
        
        # Verify the path.json was created
        path_file = BASE_DIR / "path.json"
        if not path_file.exists():
            raise Exception("Path generation completed but path.json was not created")
            
        return True
    except Exception as e:
        print(f"Error in path generation: {str(e)}")
        return False

@app.post("/run-path-generation")
async def generate_path():
    try:
        if run_path_generation():
            return JSONResponse(content={"message": "Path generation completed successfully"})
        else:
            return JSONResponse(content={"error": "Failed to generate path"}, status_code=500)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/optimal-path")
async def get_optimal_path():
    try:
        path_file = BASE_DIR / "path.json"
        
        # If path.json doesn't exist, try to generate it
        if not path_file.exists():
            if not run_path_generation():
                return JSONResponse(content={"error": "Failed to generate path"}, status_code=500)
        
        # Read the path
        with open(path_file, "r", encoding="utf-8") as f:
            path_data = json.load(f)
        return JSONResponse(content=path_data)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/pdvs")
async def get_pdvs():
    try:
        pdvs_file = BASE_DIR / "PDVs.json"
        if not pdvs_file.exists():
            return JSONResponse(content={"error": "PDVs.json not found"}, status_code=404)
            
        with open(pdvs_file, "r", encoding="utf-8") as f:
            pdvs_data = json.load(f)
        return JSONResponse(content=pdvs_data)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.get("/optimal_path_map", response_class=HTMLResponse)
async def get_optimal_path_map():
    try:
        html_file = BASE_DIR / "optimal_path_map.html"
        if not html_file.exists():
            return JSONResponse(content={"detail": "optimal_path_map.html not found"}, status_code=404)
            
        with open(html_file, "r", encoding="utf-8") as f:
            html_content = f.read()
            
        return HTMLResponse(content=html_content)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.post("/update-pdv-status")
async def update_pdv_status(pdv_id: str, status: bool):
    try:
        path_file = BASE_DIR / "path.json"
        if not path_file.exists():
            return JSONResponse(content={"error": "path.json not found"}, status_code=404)
            
        with open(path_file, "r", encoding="utf-8") as f:
            path_data = json.load(f)
        
        # Update status
        for pdv in path_data['optimal_path']:
            if pdv['key'] == pdv_id:
                pdv['status'] = status
                break
        
        # Save updated path
        with open(path_file, "w", encoding="utf-8") as f:
            json.dump(path_data, f, indent=4, ensure_ascii=False)
        
        return JSONResponse(content={"message": "Status updated successfully"})
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

@app.post("/execute-optimal-path")
async def execute_optimal_path():
    try:
        # Get the directory of the current file
        current_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Path to optimalpath.py
        script_path = os.path.join(current_dir, "Optimal_path.py")
        
        # Execute the script
        result = subprocess.run(['python', script_path], 
                              capture_output=True, 
                              text=True)
        
        if result.returncode == 0:
            return JSONResponse(content={"message": "Optimal path generation completed successfully"})
        else:
            return JSONResponse(
                content={"error": f"Script execution failed: {result.stderr}"}, 
                status_code=500
            )
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

# --- Save or Update Stat ---
@app.post('/save-stat')
def save_stat(stat: StatModel, db: Session = Depends(get_db)):
    try:
        # Check if record exists
        existing_stat = db.query(models.WorkStats).filter(
            models.WorkStats.user_id == stat.user_id,
            models.WorkStats.date == stat.date
        ).first()
        
        if existing_stat:
            # Update existing record
            existing_stat.scanned_count = stat.scanned_count
            existing_stat.total_count = stat.total_count
            existing_stat.percent = stat.percent
        else:
            # Create new record
            new_stat = models.WorkStats(
                user_id=stat.user_id,
                date=stat.date,
                scanned_count=stat.scanned_count,
                total_count=stat.total_count,
                percent=stat.percent
            )
            db.add(new_stat)
        
        db.commit()
        return {"success": True}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# --- Get Last 7 Days Stats ---
@app.get('/get-stats')
def get_stats(user_id: str, db: Session = Depends(get_db)):
    try:
        stats = db.query(models.WorkStats).filter(
            models.WorkStats.user_id == user_id
        ).order_by(
            models.WorkStats.date.desc()
        ).limit(7).all()
        
        # Return as list of dicts, newest first
        return [{"date": str(stat.date), "percent": stat.percent} for stat in reversed(stats)]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/users/delete-account")
async def delete_account(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        logger.info(f"Delete account attempt for user: {current_user.email}")
        
        # Delete user's stats first (if any)
        db.query(models.WorkStats).filter(models.WorkStats.user_id == str(current_user.id_users)).delete()
        
        # Delete the user
        db.delete(current_user)
        db.commit()
        
        logger.info(f"Account deleted successfully for user: {current_user.email}")
        
        return {
            "message": "Account deleted successfully",
            "success": True
        }
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting account for user {current_user.email}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete account: {str(e)}"
        )

# Add this new endpoint for password change
@app.post("/api/users/change-password")
async def change_password(
    password_data: PasswordChange,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        logger.info(f"Password change attempt for user: {current_user.email}")
        
        # Verify current password
        if hash_password(password_data.current_password) != current_user.password:
            logger.warning(f"Password change failed: Invalid current password for user {current_user.email}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password is incorrect"
            )
        
        # Check if new password is same as current
        if password_data.current_password == password_data.new_password:
            logger.warning(f"Password change failed: New password same as current for user {current_user.email}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="New password must be different from current password"
            )
        
        # Update password
        current_user.password = hash_password(password_data.new_password)
        db.commit()
        
        logger.info(f"Password changed successfully for user: {current_user.email}")
        
        return {
            "message": "Password changed successfully",
            "success": True
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error changing password for user {current_user.email}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to change password: {str(e)}"
        )

# Add this new endpoint for profile update
@app.put("/api/users/update")
async def update_profile(
    profile_data: ProfileUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        logger.info(f"Profile update attempt for user: {current_user.email}")
        
        # Check if email is being changed and if it's already taken
        if profile_data.email != current_user.email:
            existing_user = db.query(models.User).filter(
                models.User.email == profile_data.email,
                models.User.id_users != current_user.id_users
            ).first()
            
            if existing_user:
                logger.warning(f"Profile update failed: Email {profile_data.email} already registered")
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email already registered"
                )
        
        # Update user profile
        current_user.fullname = profile_data.fullname
        current_user.email = profile_data.email
        current_user.phone = profile_data.phone
        current_user.manager = profile_data.manager
        
        db.commit()
        db.refresh(current_user)
        
        logger.info(f"Profile updated successfully for user: {current_user.email}")
        
        return {
            "message": "Profile updated successfully",
            "success": True,
            "user": {
                "id_users": current_user.id_users,
                "fullname": current_user.fullname,
                "email": current_user.email,
                "phone": current_user.phone,
                "manager": current_user.manager
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error updating profile for user {current_user.email}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile: {str(e)}"
        )

#.\venv\Scripts\activate
#uvicorn backend_fast_API.main:app --reload   
#uvicorn backend_fast_API.main:app --host 0.0.0.0 --port 8000 """