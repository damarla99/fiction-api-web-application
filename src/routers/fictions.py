"""
Fictions CRUD routes
"""
from fastapi import APIRouter, HTTPException, status, Depends, Request
from typing import List
from datetime import datetime

from ..models.fiction import FictionCreate, FictionUpdate, FictionResponse
from ..config.database import get_fictions_collection
from ..middleware.auth import get_current_user
from ..middleware.rate_limiter import limiter
from ..config.settings import settings
from ..models.user import TokenData
from bson import ObjectId

router = APIRouter()


@router.get("/", response_model=List[FictionResponse])
@limiter.limit(settings.api_rate_limit)
async def get_all_fictions(request: Request):
    """
    Get all fictions

    Returns:
        List of all fictions
    """
    fictions = get_fictions_collection()

    fiction_list = await fictions.find().to_list(1000)

    return fiction_list


@router.get("/{fiction_id}", response_model=FictionResponse)
@limiter.limit(settings.api_rate_limit)
async def get_fiction(request: Request, fiction_id: str):
    """
    Get a single fiction by ID

    Args:
        fiction_id: Fiction ID

    Returns:
        Fiction data

    Raises:
        HTTPException: If fiction not found
    """
    fictions = get_fictions_collection()

    fiction = await fictions.find_one({"_id": fiction_id})

    if not fiction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fiction not found"
        )

    return fiction


@router.post("/", response_model=FictionResponse, status_code=status.HTTP_201_CREATED)
@limiter.limit(settings.api_rate_limit)
async def create_fiction(
    request: Request,
    fiction_data: FictionCreate,
    current_user: TokenData = Depends(get_current_user)
):
    """
    Create a new fiction

    Args:
        fiction_data: Fiction creation data
        current_user: Current authenticated user

    Returns:
        Created fiction data
    """
    fictions = get_fictions_collection()

    # Create fiction document
    fiction_dict = {
        "_id": str(ObjectId()),
        **fiction_data.model_dump(),
        "created_by": current_user.user_id,
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat()
    }

    await fictions.insert_one(fiction_dict)

    return fiction_dict


@router.put("/{fiction_id}", response_model=FictionResponse)
@limiter.limit(settings.api_rate_limit)
async def update_fiction(
    request: Request,
    fiction_id: str,
    fiction_update: FictionUpdate,
    current_user: TokenData = Depends(get_current_user)
):
    """
    Update a fiction

    Args:
        fiction_id: Fiction ID
        fiction_update: Fiction update data
        current_user: Current authenticated user

    Returns:
        Updated fiction data

    Raises:
        HTTPException: If fiction not found or user not authorized
    """
    fictions = get_fictions_collection()

    # Check if fiction exists and user is the creator
    fiction = await fictions.find_one({
        "_id": fiction_id,
        "created_by": current_user.user_id
    })

    if not fiction:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fiction not found or you don't have permission to update it"
        )

    # Prepare update data (only include fields that were provided)
    update_data = {
        k: v for k, v in fiction_update.model_dump(exclude_unset=True).items()
        if v is not None
    }

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields to update"
        )

    update_data["updated_at"] = datetime.utcnow().isoformat()

    # Update fiction
    await fictions.update_one(
        {"_id": fiction_id},
        {"$set": update_data}
    )

    # Return updated fiction
    updated_fiction = await fictions.find_one({"_id": fiction_id})

    return updated_fiction


@router.delete("/{fiction_id}", status_code=status.HTTP_200_OK)
@limiter.limit(settings.api_rate_limit)
async def delete_fiction(
    request: Request,
    fiction_id: str,
    current_user: TokenData = Depends(get_current_user)
):
    """
    Delete a fiction

    Args:
        fiction_id: Fiction ID
        current_user: Current authenticated user

    Returns:
        Success message

    Raises:
        HTTPException: If fiction not found or user not authorized
    """
    fictions = get_fictions_collection()

    # Delete fiction (only if user is the creator)
    result = await fictions.delete_one({
        "_id": fiction_id,
        "created_by": current_user.user_id
    })

    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fiction not found or you don't have permission to delete it"
        )

    return {"message": "Fiction deleted successfully"}
