"""
Authentication routes
"""
from fastapi import APIRouter, HTTPException, status, Request
from datetime import timedelta, datetime
from bson import ObjectId

from ..models.user import UserCreate, UserLogin, Token, UserResponse
from ..config.database import get_users_collection
from ..config.settings import settings
from ..utils.password import hash_password, verify_password
from ..middleware.auth import create_access_token
from ..middleware.rate_limiter import limiter

router = APIRouter()


@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
@limiter.limit(settings.auth_rate_limit)
async def register(request: Request, user_data: UserCreate):
    """
    Register a new user

    Args:
        user_data: User registration data

    Returns:
        JWT token and user data

    Raises:
        HTTPException: If username or email already exists
    """
    users = get_users_collection()

    # Check if user already exists
    existing_user = await users.find_one({
        "$or": [
            {"email": user_data.email},
            {"username": user_data.username}
        ]
    })

    if existing_user:
        if existing_user.get("email") == user_data.email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken"
            )

    # Create new user
    user_dict = {
        "_id": str(ObjectId()),
        "username": user_data.username,
        "email": user_data.email,
        "password_hash": hash_password(user_data.password),
        "created_at": datetime.utcnow().isoformat()
    }

    await users.insert_one(user_dict)

    # Create access token
    access_token = create_access_token(
        data={"sub": user_dict["_id"]},
        expires_delta=timedelta(hours=settings.jwt_expiration_hours)
    )

    # Prepare user response
    user_response = UserResponse(
        _id=user_dict["_id"],
        username=user_dict["username"],
        email=user_dict["email"],
        created_at=user_dict["created_at"]
    )

    return Token(token=access_token, user=user_response)


@router.post("/login", response_model=Token)
@limiter.limit(settings.auth_rate_limit)
async def login(request: Request, credentials: UserLogin):
    """
    Login user

    Args:
        credentials: User login credentials

    Returns:
        JWT token and user data

    Raises:
        HTTPException: If credentials are invalid
    """
    users = get_users_collection()

    # Find user by email
    user = await users.find_one({"email": credentials.email})

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Verify password
    if not verify_password(credentials.password, user["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Create access token
    access_token = create_access_token(
        data={"sub": user["_id"]},
        expires_delta=timedelta(hours=settings.jwt_expiration_hours)
    )

    # Prepare user response
    user_response = UserResponse(
        _id=user["_id"],
        username=user["username"],
        email=user["email"],
        created_at=user["created_at"]
    )

    return Token(token=access_token, user=user_response)
