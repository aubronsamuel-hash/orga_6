from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from ..db import get_db
from .. import models, schemas

router = APIRouter(prefix="/assignments", tags=["assignments"])

@router.post("", response_model=schemas.AssignmentOut, status_code=201)
def create_assignment(payload: schemas.AssignmentCreate, db: Session = Depends(get_db)):
    if payload.start_at >= payload.end_at:
        raise HTTPException(status_code=400, detail="invalid_timespan")
    a = models.Assignment(
        user_id=payload.user_id,
        mission_id=payload.mission_id,
        role=payload.role,
        start_at=payload.start_at,
        end_at=payload.end_at,
    )
    db.add(a)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="duplicate_or_foreignkey")
    db.refresh(a)
    return a

@router.get("", response_model=list[schemas.AssignmentOut])
def list_assignments(db: Session = Depends(get_db)):
    return db.query(models.Assignment).order_by(models.Assignment.id.asc()).all()

@router.get("/{assignment_id}", response_model=schemas.AssignmentOut)
def get_assignment(assignment_id: int, db: Session = Depends(get_db)):
    a = db.get(models.Assignment, assignment_id)
    if not a:
        raise HTTPException(status_code=404, detail="not_found")
    return a

@router.delete("/{assignment_id}", status_code=204)
def delete_assignment(assignment_id: int, db: Session = Depends(get_db)):
    a = db.get(models.Assignment, assignment_id)
    if not a:
        return
    db.delete(a)
    db.commit()
