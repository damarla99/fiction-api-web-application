#!/bin/bash
set -e

# ============================================================================
# Update Kubernetes Deployment Image Script
# ============================================================================
# This script updates the ECR image URL in kubernetes/deployment.yaml
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🔧 Update Kubernetes Deployment Image${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get ECR URL from Terraform output
echo -e "${YELLOW}1️⃣  Getting ECR repository URL from Terraform...${NC}"
cd ../infrastructure/terraform-eks

if [ ! -f "terraform.tfstate" ]; then
    echo -e "${RED}❌ Terraform state not found${NC}"
    echo "Please run 'terraform apply' first to create the infrastructure."
    exit 1
fi

ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "")

if [ -z "$ECR_URL" ]; then
    echo -e "${RED}❌ Could not get ECR repository URL${NC}"
    echo "Make sure Terraform has been applied successfully."
    exit 1
fi

echo -e "${GREEN}✅ ECR URL: $ECR_URL${NC}"
echo ""

# Update deployment.yaml
echo -e "${YELLOW}2️⃣  Updating kubernetes/deployment.yaml...${NC}"
cd ../../kubernetes

# Create backup
cp deployment.yaml deployment.yaml.backup

# Update the image URL
if grep -q "<YOUR_ECR_REPO_URL>" deployment.yaml; then
    # Replace placeholder
    sed -i.tmp "s|<YOUR_ECR_REPO_URL>|$ECR_URL|g" deployment.yaml
    rm -f deployment.yaml.tmp
    echo -e "${GREEN}✅ Updated deployment.yaml with ECR URL${NC}"
else
    # Already has a URL, update it
    sed -i.tmp "s|image:.*|image: $ECR_URL:latest|" deployment.yaml
    rm -f deployment.yaml.tmp
    echo -e "${GREEN}✅ Updated existing ECR URL in deployment.yaml${NC}"
fi

echo ""
echo -e "${YELLOW}📝 Current image configuration:${NC}"
grep "image:" deployment.yaml | grep -v "#"
echo ""

echo -e "${GREEN}✅ Done!${NC}"
echo ""
echo "Next steps:"
echo "  1. Build and push Docker image:"
echo "     ./build-and-push.sh"
echo ""
echo "  2. Deploy to Kubernetes:"
echo "     ./deploy-kubectl.sh"
echo ""

