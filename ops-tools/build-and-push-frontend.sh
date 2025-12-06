#!/bin/bash
set -e

echo "=========================================="
echo "🏗️  Building and Pushing Frontend to ECR"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get AWS account ID
echo -e "${YELLOW}📋 Getting AWS account ID...${NC}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"

# Get ECR URL from Terraform
echo -e "${YELLOW}📋 Getting Frontend ECR URL from Terraform...${NC}"
cd ../infrastructure/terraform-eks
FRONTEND_ECR_URL=$(terraform output -raw frontend_ecr_repository_url 2>/dev/null || echo "${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/fictions-api-frontend-development")
cd ../../

echo -e "${GREEN}✅ Frontend ECR URL: ${FRONTEND_ECR_URL}${NC}"

# Login to ECR
echo -e "${YELLOW}🔐 Logging into ECR...${NC}"
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
echo -e "${GREEN}✅ Logged into ECR${NC}"

# Build frontend image
echo -e "${YELLOW}🐳 Building frontend Docker image...${NC}"
cd frontend
docker build -t fictions-frontend:latest .
cd ..
echo -e "${GREEN}✅ Frontend image built${NC}"

# Tag image
echo -e "${YELLOW}🏷️  Tagging image...${NC}"
docker tag fictions-frontend:latest ${FRONTEND_ECR_URL}:latest
docker tag fictions-frontend:latest ${FRONTEND_ECR_URL}:$(date +%Y%m%d-%H%M%S)
echo -e "${GREEN}✅ Image tagged${NC}"

# Push to ECR
echo -e "${YELLOW}📤 Pushing image to ECR...${NC}"
docker push ${FRONTEND_ECR_URL}:latest
docker push ${FRONTEND_ECR_URL}:$(date +%Y%m%d-%H%M%S)
echo -e "${GREEN}✅ Image pushed to ECR${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}🎉 Frontend image successfully pushed!${NC}"
echo "=========================================="
echo ""
echo "Frontend ECR: ${FRONTEND_ECR_URL}"
echo ""
echo "Next steps:"
echo "1. Update kubernetes/frontend-deployment.yaml with: ${FRONTEND_ECR_URL}:latest"
echo "2. Deploy to Kubernetes"

