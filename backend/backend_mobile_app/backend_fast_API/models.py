from sqlalchemy import Column, Integer, String, Float, Boolean, JSON, Date, UniqueConstraint
from .database import Base

class User(Base):
    __tablename__ = 'users'
    
    id_users = Column(Integer, primary_key=True, index=True)
    fullname = Column(String)
    email = Column(String, unique=True)
    phone = Column(String)
    manager = Column(String)
    password = Column(String)  

class OptimalPath(Base):
    __tablename__ = 'optimal_paths'
    
    id = Column(Integer, primary_key=True, index=True)
    pdv_key = Column(String)
    commune = Column(String)
    daira = Column(String)
    wilaya = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    visit_order = Column(Integer)
    status = Column(Boolean, default=False)
    total_distance = Column(Float)
    created_at = Column(String)  # Store as ISO format string

class WorkStats(Base):
    __tablename__ = 'work_stats'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(255), nullable=False)
    date = Column(Date, nullable=False)
    scanned_count = Column(Integer, nullable=False)
    total_count = Column(Integer, nullable=False)
    percent = Column(Float, nullable=False)
    
    # Add unique constraint for user_id and date combination
    __table_args__ = (
        UniqueConstraint('user_id', 'date', name='unique_user_date'),
    )

