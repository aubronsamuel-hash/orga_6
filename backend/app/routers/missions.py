from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..db import get_db
from .. import models, schemas

router = APIRouter(prefix="/missions", tags=["missions"])

@router.post("", response_model=schemas.MissionOut, status_code=201)
def create_mission(payload: schemas.MissionCreate, db: Session = Depends(get_db)):
    mission = models.Mission(title=payload.title, location=payload.location)
    db.add(mission)
    db.commit()
    db.refresh(mission)
    return mission

@router.get("", response_model=list[schemas.MissionOut])
def list_missions(db: Session = Depends(get_db)):
    return db.query(models.Mission).order_by(models.Mission.id.asc()).all()

@router.get("/{mission_id}", response_model=schemas.MissionOut)
def get_mission(mission_id: int, db: Session = Depends(get_db)):
    mission = db.get(models.Mission, mission_id)
    if not mission:
        raise HTTPException(status_code=404, detail="not_found")
    return mission

@router.patch("/{mission_id}", response_model=schemas.MissionOut)
def update_mission(mission_id: int, payload: schemas.MissionUpdate, db: Session = Depends(get_db)):
    mission = db.get(models.Mission, mission_id)
    if not mission:
        raise HTTPException(status_code=404, detail="not_found")
    if payload.title is not None:
        mission.title = payload.title
    if payload.location is not None:
        mission.location = payload.location
    db.commit()
    db.refresh(mission)
    return mission

@router.delete("/{mission_id}", status_code=204)
def delete_mission(mission_id: int, db: Session = Depends(get_db)):
    mission = db.get(models.Mission, mission_id)
    if not mission:
        return
    db.delete(mission)
    db.commit()
