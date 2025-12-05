"""
User model and schemas
"""

from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional
from datetime import datetime
from bson import ObjectId


class PyObjectId(ObjectId):
    """Custom ObjectId type for Pydantic"""

    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return ObjectId(v)


class UserBase(BaseModel):
    """Base user schema"""

    username: str = Field(..., min_length=3, max_length=30)
    email: EmailStr

    @field_validator("username")
    @classmethod
    def username_alphanumeric(cls, v):
        if not v.replace("_", "").replace("-", "").isalnum():
            raise ValueError("Username must be alphanumeric")
        return v


class UserCreate(UserBase):
    """Schema for user registration"""

    password: str = Field(..., min_length=6, max_length=100)

    @field_validator("password")
    @classmethod
    def password_strength(cls, v):
        if len(v) < 6:
            raise ValueError("Password must be at least 6 characters")
        return v


class UserLogin(BaseModel):
    """Schema for user login"""

    email: EmailStr
    password: str


class User(UserBase):
    """User model with all fields"""

    id: str = Field(default_factory=lambda: str(ObjectId()), alias="_id")
    password_hash: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        populate_by_name = True
        json_encoders = {ObjectId: str}
        json_schema_extra = {
            "example": {
                "username": "johndoe",
                "email": "john@example.com",
                "created_at": "2024-12-04T10:00:00",
            }
        }


class UserResponse(BaseModel):
    """User response schema (without password)"""

    id: str = Field(alias="_id")
    username: str
    email: EmailStr
    created_at: datetime

    class Config:
        populate_by_name = True


class Token(BaseModel):
    """JWT token response"""

    token: str
    token_type: str = "bearer"
    user: UserResponse


class TokenData(BaseModel):
    """JWT token payload data"""

    user_id: Optional[str] = None
