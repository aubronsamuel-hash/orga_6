from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import bcrypt
from ..db import get_db
from .. import models, schemas

router = APIRouter(prefix="/users", tags=["users"])

@router.post("", response_model=schemas.UserOut, status_code=201)
def create_user(payload: schemas.UserCreate, db: Session = Depends(get_db)):
    exists = db.query(models.User).filter(models.User.email == payload.email).first()
    if exists:
        raise HTTPException(status_code=409, detail="email_exists")
    pwd_hash = ""
    if payload.password:
        pwd_hash = bcrypt.hashpw(payload.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    user = models.User(email=payload.email, full_name=payload.full_name, password_hash=pwd_hash)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.get("", response_model=list[schemas.UserOut])
def list_users(db: Session = Depends(get_db)):
    return db.query(models.User).order_by(models.User.id.asc()).all()

@router.get("/{user_id}", response_model=schemas.UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.get(models.User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="not_found")
    return user

@router.patch("/{user_id}", response_model=schemas.UserOut)
def update_user(user_id: int, payload: schemas.UserUpdate, db: Session = Depends(get_db)):
    user = db.get(models.User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="not_found")
    if payload.full_name is not None:
        user.full_name = payload.full_name
    db.commit()
    db.refresh(user)
    return user

@router.delete("/{user_id}", status_code=204)
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.get(models.User, user_id)
    if not user:
        return
    db.delete(user)
    db.commit()
