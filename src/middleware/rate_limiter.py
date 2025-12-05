"""
Rate limiting middleware
"""
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from fastapi import Request, Response
from fastapi.responses import JSONResponse

from ..config.settings import settings

# Initialize rate limiter
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=[f"{settings.rate_limit_max_requests}/{settings.rate_limit_window_ms}ms"]
)


def rate_limit_exceeded_handler(request: Request, exc: RateLimitExceeded) -> Response:
    """
    Custom handler for rate limit exceeded errors
    
    Args:
        request: FastAPI request
        exc: RateLimitExceeded exception
    
    Returns:
        JSON response with error message
    """
    return JSONResponse(
        status_code=429,
        content={
            "error": "Too Many Requests",
            "message": "Rate limit exceeded. Please try again later.",
            "detail": str(exc.detail)
        }
    )

