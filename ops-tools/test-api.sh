#!/bin/bash

# Simple API Test Script
# Make sure the application is running before executing this script

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Testing Fictions API...${NC}\n"

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Health Check${NC}"
HEALTH=$(curl -s ${BASE_URL}/health)
if [[ $HEALTH == *"success"* ]]; then
    echo -e "${GREEN}✓ Health check passed${NC}\n"
else
    echo -e "${RED}✗ Health check failed${NC}\n"
    exit 1
fi

# Test 2: Register User
echo -e "${YELLOW}Test 2: Register User${NC}"
REGISTER_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/auth/register \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser'$RANDOM'",
        "email": "test'$RANDOM'@example.com",
        "password": "password123"
    }')

if [[ $REGISTER_RESPONSE == *"success"* ]]; then
    echo -e "${GREEN}✓ User registration passed${NC}"
    TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo -e "${YELLOW}Token: ${TOKEN:0:20}...${NC}\n"
else
    echo -e "${RED}✗ User registration failed${NC}"
    echo $REGISTER_RESPONSE
    exit 1
fi

# Test 3: Create Fiction
echo -e "${YELLOW}Test 3: Create Fiction${NC}"
CREATE_RESPONSE=$(curl -s -X POST ${BASE_URL}/api/fictions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "title": "Test Fiction",
        "author": "Test Author",
        "genre": "fantasy",
        "description": "A test fiction for API testing",
        "content": "Once upon a time in a test environment...",
        "tags": ["test", "automation"],
        "status": "published"
    }')

if [[ $CREATE_RESPONSE == *"success"* ]]; then
    echo -e "${GREEN}✓ Fiction creation passed${NC}"
    FICTION_ID=$(echo $CREATE_RESPONSE | grep -o '"_id":"[^"]*' | cut -d'"' -f4)
    echo -e "${YELLOW}Fiction ID: ${FICTION_ID}${NC}\n"
else
    echo -e "${RED}✗ Fiction creation failed${NC}"
    echo $CREATE_RESPONSE
    exit 1
fi

# Test 4: Get All Fictions
echo -e "${YELLOW}Test 4: Get All Fictions${NC}"
GET_ALL=$(curl -s ${BASE_URL}/api/fictions)
if [[ $GET_ALL == *"success"* ]]; then
    echo -e "${GREEN}✓ Get all fictions passed${NC}\n"
else
    echo -e "${RED}✗ Get all fictions failed${NC}\n"
fi

# Test 5: Get Single Fiction
echo -e "${YELLOW}Test 5: Get Single Fiction${NC}"
GET_ONE=$(curl -s ${BASE_URL}/api/fictions/${FICTION_ID})
if [[ $GET_ONE == *"success"* ]]; then
    echo -e "${GREEN}✓ Get single fiction passed${NC}\n"
else
    echo -e "${RED}✗ Get single fiction failed${NC}\n"
fi

# Test 6: Update Fiction
echo -e "${YELLOW}Test 6: Update Fiction${NC}"
UPDATE_RESPONSE=$(curl -s -X PUT ${BASE_URL}/api/fictions/${FICTION_ID} \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "title": "Updated Test Fiction",
        "rating": 4.5
    }')

if [[ $UPDATE_RESPONSE == *"success"* ]]; then
    echo -e "${GREEN}✓ Fiction update passed${NC}\n"
else
    echo -e "${RED}✗ Fiction update failed${NC}\n"
fi

# Test 7: Get My Fictions
echo -e "${YELLOW}Test 7: Get My Fictions${NC}"
MY_FICTIONS=$(curl -s ${BASE_URL}/api/fictions/user/me \
    -H "Authorization: Bearer $TOKEN")
if [[ $MY_FICTIONS == *"success"* ]]; then
    echo -e "${GREEN}✓ Get my fictions passed${NC}\n"
else
    echo -e "${RED}✗ Get my fictions failed${NC}\n"
fi

# Test 8: Delete Fiction
echo -e "${YELLOW}Test 8: Delete Fiction${NC}"
DELETE_RESPONSE=$(curl -s -X DELETE ${BASE_URL}/api/fictions/${FICTION_ID} \
    -H "Authorization: Bearer $TOKEN")

if [[ $DELETE_RESPONSE == *"success"* ]]; then
    echo -e "${GREEN}✓ Fiction deletion passed${NC}\n"
else
    echo -e "${RED}✗ Fiction deletion failed${NC}\n"
fi

# Test 9: Rate Limiting
echo -e "${YELLOW}Test 9: Rate Limiting${NC}"
echo -e "${YELLOW}Making multiple rapid requests...${NC}"
for i in {1..5}; do
    curl -s ${BASE_URL}/health > /dev/null
done
RATE_LIMIT=$(curl -s -I ${BASE_URL}/health | grep -i "ratelimit")
if [[ $RATE_LIMIT == *"RateLimit"* ]]; then
    echo -e "${GREEN}✓ Rate limiting headers present${NC}\n"
else
    echo -e "${YELLOW}⚠ Rate limiting headers not found (may be expected)${NC}\n"
fi

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}All critical tests passed! ✓${NC}"
echo -e "${GREEN}==================================${NC}"

