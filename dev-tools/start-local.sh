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
    echo "📍 Your API is running at:"
    echo "   http://localhost:3000"
    echo ""
    echo "🏥 Health check:"
    echo "   curl http://localhost:3000/health"
    echo ""
    echo "📊 View logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "📝 Quick API Test:"
    echo "   ./dev-tools/test-api.sh"
    echo ""
    echo "🛑 Stop services:"
    echo "   ./dev-tools/stop-local.sh"
    echo ""
    echo "💡 Tips for Developers:"
    echo "   • Edit code in src/ directory"
    echo "   • API auto-restarts on code changes (via uvicorn --reload)"
    echo "   • Database persists data in docker volumes"
    echo "   • No AWS or Kubernetes knowledge needed!"
    echo ""
}

main

