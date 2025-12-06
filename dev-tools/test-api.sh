#!/bin/bash

##############################################################################
# API Testing Script for Developers
# Tests all CRUD operations locally
##############################################################################

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "🧪 Testing Fictions API"
echo "=========================================="
echo ""

# Test 1: Health Check
echo "1️⃣  Testing health endpoint..."
HEALTH=$(curl -s $BASE_URL/health)
if echo $HEALTH | grep -q "ok"; then
    echo -e "${GREEN}✅ Health check passed${NC}"
else
    echo -e "${RED}❌ Health check failed${NC}"
    exit 1
fi
echo ""

# Test 2: Register User
echo "2️⃣  Registering test user..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testdev",
    "email": "dev@example.com",
    "password": "password123"
  }')

if echo $REGISTER_RESPONSE | grep -q "token"; then
    echo -e "${GREEN}✅ User registration successful${NC}"
else
    echo -e "${YELLOW}⚠️  User might already exist (this is OK)${NC}"
fi
echo ""

# Test 3: Login
echo "3️⃣  Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "dev@example.com",
    "password": "password123"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

if [ -n "$TOKEN" ]; then
    echo -e "${GREEN}✅ Login successful${NC}"
else
    echo -e "${RED}❌ Login failed${NC}"
    echo "Response: $LOGIN_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Create Fiction
echo "4️⃣  Creating a fiction..."
CREATE_RESPONSE=$(curl -s -L -X POST $BASE_URL/api/fictions/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Dev Test Story",
    "author": "Developer",
    "genre": "fantasy",
    "description": "A test story created by developer",
    "content": "Once upon a time, a developer wrote some code..."
  }')

FICTION_ID=$(echo $CREATE_RESPONSE | grep -o '"_id":"[^"]*' | grep -o '[^"]*$')

if [ -n "$FICTION_ID" ]; then
    echo -e "${GREEN}✅ Fiction created successfully${NC}"
    echo "   Fiction ID: $FICTION_ID"
else
    echo -e "${RED}❌ Fiction creation failed${NC}"
    echo "Response: $CREATE_RESPONSE"
    echo "Token used: ${TOKEN:0:20}..."
    exit 1
fi
echo ""

# Test 5: Get All Fictions
echo "5️⃣  Fetching all fictions..."
GET_ALL=$(curl -s -L $BASE_URL/api/fictions/)

if echo $GET_ALL | grep -q "Dev Test Story"; then
    echo -e "${GREEN}✅ Successfully retrieved fictions${NC}"
else
    echo -e "${RED}❌ Failed to retrieve fictions${NC}"
    exit 1
fi
echo ""

# Test 6: Get Single Fiction
echo "6️⃣  Fetching single fiction..."
GET_ONE=$(curl -s -L $BASE_URL/api/fictions/$FICTION_ID)

if echo $GET_ONE | grep -q "Dev Test Story"; then
    echo -e "${GREEN}✅ Successfully retrieved single fiction${NC}"
else
    echo -e "${RED}❌ Failed to retrieve single fiction${NC}"
    exit 1
fi
echo ""

# Test 7: Update Fiction
echo "7️⃣  Updating fiction..."
UPDATE_RESPONSE=$(curl -s -L -X PUT $BASE_URL/api/fictions/$FICTION_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated Test Story",
    "content": "This content has been updated by the developer."
  }')

if echo $UPDATE_RESPONSE | grep -q "Updated Test Story"; then
    echo -e "${GREEN}✅ Fiction updated successfully${NC}"
else
    echo -e "${RED}❌ Fiction update failed${NC}"
    exit 1
fi
echo ""

# Test 8: Delete Fiction
echo "8️⃣  Deleting fiction..."
DELETE_RESPONSE=$(curl -s -L -X DELETE $BASE_URL/api/fictions/$FICTION_ID \
  -H "Authorization: Bearer $TOKEN")

if echo $DELETE_RESPONSE | grep -q "deleted"; then
    echo -e "${GREEN}✅ Fiction deleted successfully${NC}"
else
    echo -e "${RED}❌ Fiction deletion failed${NC}"
    exit 1
fi
echo ""

echo "=========================================="
echo -e "${GREEN}✅ All API tests passed!${NC}"
echo "=========================================="
echo ""
echo "📝 Summary:"
echo "   • Health check: ✅"
echo "   • User registration: ✅"
echo "   • User login: ✅"
echo "   • Create fiction: ✅"
echo "   • Get all fictions: ✅"
echo "   • Get single fiction: ✅"
echo "   • Update fiction: ✅"
echo "   • Delete fiction: ✅"
echo ""
echo "🎉 Your API is working perfectly!"
echo ""

