# Fictions API - Backend

FastAPI backend for the Fictions application.

## Tech Stack

- Python 3.11+
- FastAPI (async web framework)
- MongoDB (database)
- Motor (async MongoDB driver)
- JWT authentication (python-jose)
- bcrypt (password hashing)
- SlowAPI (rate limiting)

## Project Structure

```
backend/
├── src/
│   ├── main.py              # FastAPI app entry point
│   ├── config/
│   │   ├── settings.py      # App configuration
│   │   └── database.py      # MongoDB connection
│   ├── models/
│   │   ├── user.py          # User model
│   │   └── fiction.py       # Fiction model
│   ├── routers/
│   │   ├── auth.py          # Authentication endpoints
│   │   └── fictions.py      # Fiction CRUD endpoints
│   ├── middleware/
│   │   ├── auth.py          # JWT verification
│   │   └── rate_limiter.py  # Rate limiting
│   └── utils/
│       └── password.py      # Password hashing utilities
├── Dockerfile               # Multi-stage Docker build
└── requirements.txt         # Python dependencies
```

## Local Development

### Prerequisites

- Python 3.11+
- MongoDB running on localhost:27017

### Run Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export MONGODB_URI="mongodb://localhost:27017/fictions_db"
export JWT_SECRET="dev-secret-key"

# Run server
cd src
uvicorn main:app --reload --host 0.0.0.0 --port 3000
```

Visit `http://localhost:3000/api/docs` for Swagger UI.

## Docker

### Build Image

```bash
docker build -t fictions-api .
```

### Run Container

```bash
docker run -p 3000:3000 \
  -e MONGODB_URI="mongodb://host.docker.internal:27017/fictions_db" \
  -e JWT_SECRET="dev-secret-key" \
  fictions-api
```

## API Endpoints

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/health` | GET | Health check | No |
| `/api/docs` | GET | Swagger UI | No |
| `/api/auth/register` | POST | Register user | No |
| `/api/auth/login` | POST | Login user | No |
| `/api/fictions/` | GET | List fictions | Yes |
| `/api/fictions/` | POST | Create fiction | Yes |
| `/api/fictions/{id}` | GET | Get fiction | Yes |
| `/api/fictions/{id}` | PUT | Update fiction | Yes |
| `/api/fictions/{id}` | DELETE | Delete fiction | Yes |

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MONGODB_URI` | MongoDB connection string | `mongodb://localhost:27017/fictions_db` |
| `JWT_SECRET` | Secret key for JWT tokens | Required |
| `PORT` | Server port | `3000` |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | `100` |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window (ms) | `900000` (15 min) |

## Authentication

- JWT tokens with 24-hour expiry
- bcrypt password hashing
- Bearer token authentication

## Rate Limiting

- 100 requests per 15 minutes per IP
- Applies to all API endpoints
- Returns 429 Too Many Requests when exceeded

