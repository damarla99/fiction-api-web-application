"""
Fiction model and schemas
"""

from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime
from bson import ObjectId


class FictionBase(BaseModel):
    """Base fiction schema"""

    title: str = Field(..., min_length=1, max_length=200)
    author: str = Field(..., min_length=1, max_length=100)
    genre: str = Field(..., min_length=1, max_length=50)
    description: str = Field(..., max_length=500)
    content: str = Field(..., min_length=1)

    @field_validator("genre")
    @classmethod
    def genre_valid(cls, v):
        valid_genres = [
            "fantasy",
            "sci-fi",
            "mystery",
            "romance",
            "thriller",
            "horror",
            "adventure",
            "drama",
            "comedy",
            "other",
        ]
        if v.lower() not in valid_genres:
            raise ValueError(f'Genre must be one of: {", ".join(valid_genres)}')
        return v.lower()


class FictionCreate(FictionBase):
    """Schema for creating fiction"""

    pass


class FictionUpdate(BaseModel):
    """Schema for updating fiction"""

    title: Optional[str] = Field(None, min_length=1, max_length=200)
    author: Optional[str] = Field(None, min_length=1, max_length=100)
    genre: Optional[str] = Field(None, min_length=1, max_length=50)
    description: Optional[str] = Field(None, max_length=500)
    content: Optional[str] = Field(None, min_length=1)

    @field_validator("genre")
    @classmethod
    def genre_valid(cls, v):
        if v is None:
            return v
        valid_genres = [
            "fantasy",
            "sci-fi",
            "mystery",
            "romance",
            "thriller",
            "horror",
            "adventure",
            "drama",
            "comedy",
            "other",
        ]
        if v.lower() not in valid_genres:
            raise ValueError(f'Genre must be one of: {", ".join(valid_genres)}')
        return v.lower()


class Fiction(FictionBase):
    """Fiction model with all fields"""

    id: str = Field(default_factory=lambda: str(ObjectId()), alias="_id")
    created_by: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        populate_by_name = True
        json_encoders = {ObjectId: str}
        json_schema_extra = {
            "example": {
                "title": "The Great Adventure",
                "author": "John Doe",
                "genre": "fantasy",
                "description": "An epic tale of adventure",
                "content": "Once upon a time...",
                "created_by": "user123",
                "created_at": "2024-12-04T10:00:00",
                "updated_at": "2024-12-04T10:00:00",
            }
        }


class FictionResponse(BaseModel):
    """Fiction response schema"""

    id: str = Field(alias="_id")
    title: str
    author: str
    genre: str
    description: str
    content: str
    created_by: str
    created_at: datetime
    updated_at: datetime

    class Config:
        populate_by_name = True
