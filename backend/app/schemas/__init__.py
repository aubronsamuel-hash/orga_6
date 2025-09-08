from datetime import datetime
from pydantic import BaseModel, EmailStr, Field

class UserBase(BaseModel):
    email: EmailStr
    full_name: str = Field(min_length=1, max_length=255)

class UserCreate(UserBase):
    pass

class UserUpdate(BaseModel):
    full_name: str | None = Field(default=None, min_length=1, max_length=255)

class UserOut(UserBase):
    id: int
    class Config:
        from_attributes = True

class MissionBase(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    location: str | None = None

class MissionCreate(MissionBase):
    pass

class MissionUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=255)
    location: str | None = None

class MissionOut(MissionBase):
    id: int
    class Config:
        from_attributes = True

class AssignmentBase(BaseModel):
    user_id: int
    mission_id: int
    role: str = Field(min_length=1, max_length=80)
    start_at: datetime
    end_at: datetime

class AssignmentCreate(AssignmentBase):
    pass

class AssignmentOut(AssignmentBase):
    id: int
    class Config:
        from_attributes = True
