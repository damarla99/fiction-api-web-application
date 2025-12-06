#!/bin/bash
set -e

# ============================================================================
# Build and Push Docker Image to ECR
# ============================================================================
# This script builds the Docker image and pushes it to AWS ECR
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🐳 Build and Push Docker Image to ECR${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Configuration
AWS_REGION="us-east-1"
IMAGE_TAG="${1:-latest}"

# ============================================================================
# Step 1: Get ECR repository URL
# ============================================================================
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

# Extract AWS account ID from ECR URL
AWS_ACCOUNT_ID=$(echo $ECR_URL | cut -d'.' -f1)

# ============================================================================
# Step 2: Login to ECR
# ============================================================================
echo -e "${YELLOW}2️⃣  Logging in to ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo -e "${GREEN}✅ Logged in to ECR${NC}"
echo ""

# ============================================================================
# Step 3: Build Docker image
# ============================================================================
echo -e "${YELLOW}3️⃣  Building Docker image...${NC}"
cd ../../

docker build -t fictions-api:$IMAGE_TAG ./backend

echo -e "${GREEN}✅ Docker image built successfully${NC}"
echo ""

# ============================================================================
# Step 4: Tag image for ECR
# ============================================================================
echo -e "${YELLOW}4️⃣  Tagging image for ECR...${NC}"
docker tag fictions-api:$IMAGE_TAG $ECR_URL:$IMAGE_TAG

echo -e "${GREEN}✅ Image tagged: $ECR_URL:$IMAGE_TAG${NC}"
echo ""

# ============================================================================
# Step 5: Push image to ECR
# ============================================================================
echo -e "${YELLOW}5️⃣  Pushing image to ECR...${NC}"
docker push $ECR_URL:$IMAGE_TAG

echo ""
echo -e "${GREEN}✅ Image pushed successfully!${NC}"
echo ""

# ============================================================================
# Step 6: Verify image in ECR
# ============================================================================
echo -e "${YELLOW}6️⃣  Verifying image in ECR...${NC}"
aws ecr describe-images \
  --repository-name fictions-api-development \
  --region $AWS_REGION \
  --query 'imageDetails[*].[imageTags[0],imagePushedAt]' \
  --output table

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Build and Push Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📦 Image Details:${NC}"
echo "   Repository: $ECR_URL"
echo "   Tag:        $IMAGE_TAG"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "   1. Update backend-deployment.yaml (if needed):"
echo "      cd ops-tools && ./update-k8s-image.sh"
echo ""
echo "   2. Deploy to Kubernetes:"
echo "      ./deploy-kubectl.sh"
echo ""
echo "   3. Or update existing deployment:"
echo "      kubectl set image deployment/fictions-api \\"
echo "        fictions-api=$ECR_URL:$IMAGE_TAG -n fictions-app"
echo ""
echo -e "${GREEN}✅ Done!${NC}"

