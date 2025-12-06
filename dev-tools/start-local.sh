#!/bin/bash

##############################################################################
# Developer Local Environment Setup
# For: Application Developers
# Purpose: Quick local development environment (no AWS/K8s knowledge needed)
##############################################################################

set -e

echo "=========================================="
echo "👨‍💻 Starting Local Development Environment"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check prerequisites
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker not found.${NC}"
        echo "   Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker daemon not running.${NC}"
        echo "   Please start Docker Desktop"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker is ready${NC}"
}

# Check docker-compose
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ docker-compose not found.${NC}"
        echo "   Please install docker-compose"
        exit 1
    fi
    
    echo -e "${GREEN}✅ docker-compose is ready${NC}"
}

# Main
main() {
    echo "📋 Checking prerequisites..."
    check_docker
    check_docker_compose
    echo ""
    
    echo "🐳 Starting services..."
    echo "   • MongoDB (database)"
    echo "   • Fictions API (FastAPI app)"
    echo ""
    
    # Start services
    docker-compose up -d
    
    echo ""
    echo -e "${GREEN}✅ Services started successfully!${NC}"
    echo ""
    
    # Wait for services to be healthy
    echo "⏳ Waiting for services to be ready..."
    sleep 5
    
    # Check health
    if curl -s http://localhost:3000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API is healthy!${NC}"
    else
        echo -e "${YELLOW}⚠️  API is starting... (this may take a minute)${NC}"
    fi
    
    echo ""
    echo "=========================================="
    echo "🎉 Development Environment Ready!"
    echo "=========================================="
    echo ""
    echo "🌐 FULL-STACK APPLICATION:"
    echo ""
    echo "   Frontend (React UI):"
    echo "   👉 http://localhost"
    echo "   👉 http://localhost:80"
    echo ""
    echo "   Backend API (FastAPI):"
    echo "   👉 http://localhost:3000"
    echo "   👉 http://localhost:3000/api/docs (Swagger UI)"
    echo ""
    echo "   Database (MongoDB):"
    echo "   👉 localhost:27017"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🧪 TESTING OPTIONS:"
    echo ""
    echo "   Option 1: Use Frontend (Recommended):"
    echo "   • Open http://localhost in browser"
    echo "   • Interactive UI for all features"
    echo ""
    echo "   Option 2: Use Swagger UI (API Testing):"
    echo "   • Open http://localhost:3000/api/docs"
    echo "   • Test API directly in browser"
    echo ""
    echo "   Option 3: Use curl (Command Line):"
    echo "   • ./dev-tools/test-api.sh"
    echo "   • curl http://localhost:3000/health"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🛠️  USEFUL COMMANDS:"
    echo ""
    echo "   View logs:"
    echo "   • docker-compose logs -f"
    echo "   • docker-compose logs -f frontend"
    echo "   • docker-compose logs -f api"
    echo "   • docker-compose logs -f mongodb"
    echo ""
    echo "   Stop services:"
    echo "   • ./dev-tools/stop-local.sh"
    echo ""
    echo "💡 Tips:"
    echo "   • Edit backend: backend/src/"
    echo "   • Edit frontend: frontend/src/"
    echo "   • Changes auto-reload!"
    echo ""
}

main

