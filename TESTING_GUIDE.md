# Testing Guide

## 🧪 How to Test the Application

### **Option 1: End-to-End Testing (Full Stack) - RECOMMENDED**

Test the complete application with frontend + backend + database.

**Start:**
```bash
./dev-tools/start-local.sh
```

**Access:**
- **Frontend UI:** http://localhost (or http://localhost:80)
- **Backend API:** http://localhost:3000
- **Swagger UI:** http://localhost:3000/api/docs

**Test Flow:**
1. Open http://localhost in browser
2. Register a new user
3. Login
4. Create fictions
5. Edit/Delete your fictions
6. Logout and test with another user

**Stop:**
```bash
./dev-tools/stop-local.sh
```

---

### **Option 2: Backend-Only Testing (API Testing)**

Test only the backend API without the frontend UI.

**Start:**
```bash
docker-compose up -d mongodb api
```

**Access:**
- **Backend API:** http://localhost:3000
- **Swagger UI:** http://localhost:3000/api/docs (Interactive API testing)
- **Health Check:** http://localhost:3000/health

**Test Methods:**

**Method 1: Swagger UI (Interactive - Easiest)**
1. Open http://localhost:3000/api/docs
2. Click on any endpoint
3. Click "Try it out"
4. Fill in the request body
5. Click "Execute"
6. See the response

**Method 2: Automated Script**
```bash
./dev-tools/test-api.sh
```

**Method 3: Manual curl Commands**
```bash
# Health check
curl http://localhost:3000/health

# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "test123"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'

# Copy the token from login response
export TOKEN="paste-token-here"

# Create fiction
curl -X POST http://localhost:3000/api/fictions/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Test Story",
    "author": "Test Author",
    "genre": "fantasy",
    "description": "A test story",
    "content": "Once upon a time..."
  }'

# Get all fictions
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/fictions/
```

**Stop:**
```bash
docker-compose down
```

---

### **Option 3: Frontend-Only Testing (UI Development)**

Test only the frontend with backend in Docker.

**Start:**
```bash
# Terminal 1: Start backend
docker-compose up -d mongodb api

# Terminal 2: Start frontend in dev mode
cd frontend
npm install
npm run dev
```

**Access:**
- **Frontend (Dev):** http://localhost:5173
- **Backend API:** http://localhost:3000

**Stop:**
```bash
# Terminal 2: Ctrl+C to stop frontend

# Terminal 1: Stop backend
docker-compose down
```

---

## 📊 Comparison

| Feature | End-to-End | Backend-Only | Frontend-Only |
|---------|-----------|--------------|---------------|
| **Command** | `./dev-tools/start-local.sh` | `docker-compose up -d mongodb api` | `npm run dev` (+ backend) |
| **Frontend** | ✅ http://localhost:80 | ❌ Not running | ✅ http://localhost:5173 |
| **Backend** | ✅ http://localhost:3000 | ✅ http://localhost:3000 | ✅ http://localhost:3000 |
| **Database** | ✅ Running | ✅ Running | ✅ Running |
| **Use Case** | Complete testing | API testing | UI development |
| **Best For** | Demos, final testing | Backend dev, API testing | Frontend dev, styling |

---

## 🎯 What is End-to-End Testing?

**End-to-End (E2E) Testing** means testing the **complete user flow** from start to finish:

```
User's Browser
  ↓
Frontend (React UI) - http://localhost:80
  ↓ API calls
Backend (FastAPI) - http://localhost:3000
  ↓ Database queries
MongoDB - localhost:27017
```

**Example E2E Test Flow:**
1. User opens frontend in browser (http://localhost)
2. User registers → Frontend sends request to Backend → Backend saves to MongoDB
3. User logs in → Backend verifies credentials from MongoDB → Returns JWT token
4. User creates fiction → Frontend sends with JWT → Backend validates & saves to MongoDB
5. User sees fiction list → Frontend fetches from Backend → Backend queries MongoDB

**This tests the ENTIRE stack working together!**

---

## ✅ Quick Reference

**I want to...**

- **Demo the full application** → `./dev-tools/start-local.sh` → Open http://localhost
- **Test the API only** → Open http://localhost:3000/api/docs (Swagger UI)
- **Test with curl** → `./dev-tools/test-api.sh`
- **Develop frontend** → Backend in Docker + `npm run dev`
- **Develop backend** → Change code in `backend/src/`, auto-reloads!

---

## 🐛 Troubleshooting

**Problem: Can't access http://localhost**
```bash
# Check if frontend is running
docker-compose ps

# Check frontend logs
docker-compose logs frontend

# Restart frontend
docker-compose restart frontend
```

**Problem: Frontend shows but API fails**
```bash
# Check if backend is running
curl http://localhost:3000/health

# Check backend logs
docker-compose logs api

# Restart backend
docker-compose restart api
```

**Problem: Port already in use**
```bash
# Stop everything
./dev-tools/stop-local.sh
docker-compose down

# Start fresh
./dev-tools/start-local.sh
```

