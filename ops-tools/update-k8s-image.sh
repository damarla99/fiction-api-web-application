#!/bin/bash
set -e

# ============================================================================
# Update Kubernetes Deployment Images Script
# ============================================================================
# This script updates ECR image URLs in kubernetes deployment files
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🔧 Update Kubernetes Deployment Images${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get ECR URLs from Terraform output
echo -e "${YELLOW}1️⃣  Getting ECR repository URLs from Terraform...${NC}"
cd ../infrastructure/terraform-eks

if [ ! -f "terraform.tfstate" ]; then
    echo -e "${RED}❌ Terraform state not found${NC}"
    echo "Please run 'terraform apply' first to create the infrastructure."
    exit 1
fi

BACKEND_ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "")
FRONTEND_ECR_URL=$(terraform output -raw frontend_ecr_repository_url 2>/dev/null || echo "")

if [ -z "$BACKEND_ECR_URL" ]; then
    echo -e "${RED}❌ Could not get backend ECR repository URL${NC}"
    exit 1
fi

if [ -z "$FRONTEND_ECR_URL" ]; then
    echo -e "${RED}❌ Could not get frontend ECR repository URL${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Backend ECR:  $BACKEND_ECR_URL${NC}"
echo -e "${GREEN}✅ Frontend ECR: $FRONTEND_ECR_URL${NC}"
echo ""

cd ../../kubernetes

# Update backend deployment
echo -e "${YELLOW}2️⃣  Updating backend deployment...${NC}"
cp backend-deployment.yaml backend-deployment.yaml.backup

if grep -q "<BACKEND_ECR_URL>" backend-deployment.yaml || grep -q "<YOUR_ECR_REPO_URL>" backend-deployment.yaml; then
    sed -i.tmp "s|<BACKEND_ECR_URL>:latest\|<YOUR_ECR_REPO_URL>:latest|$BACKEND_ECR_URL:latest|g" backend-deployment.yaml
    rm -f backend-deployment.yaml.tmp
    echo -e "${GREEN}✅ Updated backend-deployment.yaml${NC}"
else
    echo -e "${YELLOW}⚠️  Backend backend-deployment.yaml already has an ECR URL${NC}"
fi

# Update frontend deployment
echo -e "${YELLOW}3️⃣  Updating frontend deployment...${NC}"
cp frontend-deployment.yaml frontend-deployment.yaml.backup 2>/dev/null || true

if grep -q "<FRONTEND_ECR_URL>" frontend-deployment.yaml 2>/dev/null; then
    sed -i.tmp "s|<FRONTEND_ECR_URL>:latest|$FRONTEND_ECR_URL:latest|g" frontend-deployment.yaml
    rm -f frontend-deployment.yaml.tmp
    echo -e "${GREEN}✅ Updated frontend-deployment.yaml${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend frontend-deployment.yaml already has an ECR URL${NC}"
fi

echo ""
echo -e "${YELLOW}📝 Current image configurations:${NC}"
echo ""
echo "Backend:"
grep "image:" backend-deployment.yaml | grep -v "#" || echo "  (not found)"
echo ""
echo "Frontend:"
grep "image:" frontend-deployment.yaml 2>/dev/null | grep -v "#" || echo "  (not found)"
echo ""

echo -e "${GREEN}✅ Done!${NC}"
echo ""
echo "Next steps:"
echo "  1. Build and push images:"
echo "     cd ops-tools"
echo "     ./build-and-push.sh         # Backend"
echo "     ./build-and-push-frontend.sh  # Frontend"
echo ""
echo "  2. Deploy to Kubernetes:"
echo "     ./deploy-kubectl.sh"
echo ""

