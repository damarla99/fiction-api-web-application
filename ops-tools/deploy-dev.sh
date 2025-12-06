#!/bin/bash

##############################################################################
# Development Deployment Script for Fictions API on AWS EKS
# Simple, cost-optimized setup for development/testing
##############################################################################

set -e

echo "=========================================="
echo "🚀 Fictions API - Development Deployment"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
check_prerequisites() {
    echo "📋 Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform not found. Please install: https://www.terraform.io/downloads${NC}"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI not found. Please install: https://aws.amazon.com/cli/${NC}"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl not found. Please install: https://kubernetes.io/docs/tasks/tools/${NC}"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker not found. Please install: https://docs.docker.com/get-docker/${NC}"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}❌ AWS credentials not configured. Run: aws configure${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites met!${NC}"
    echo ""
}

# Display configuration
display_config() {
    echo "⚙️  Development Configuration:"
    echo "   • Environment: development"
    echo "   • Region: us-east-1"
    echo "   • Node Type: t3.small (1 node)"
    echo "   • App Replicas: 1"
    echo "   • NAT Gateways: 1 (cost optimized)"
    echo "   • MongoDB: In-cluster StatefulSet"
    echo "   • Estimated Cost: ~$120-150/month"
    echo ""
}

# Deploy infrastructure
deploy_infrastructure() {
    echo "🏗️  Deploying AWS EKS infrastructure..."
    echo ""
    
    cd infrastructure/terraform-eks
    
    # Initialize Terraform
    echo "Initializing Terraform..."
    terraform init
    
    echo ""
    echo -e "${YELLOW}📊 Terraform will create:${NC}"
    echo "   • VPC with 2 availability zones"
    echo "   • EKS cluster (Kubernetes 1.28)"
    echo "   • 1 worker node (t3.small)"
    echo "   • Network Load Balancer"
    echo "   • ECR repository"
    echo "   • MongoDB StatefulSet"
    echo ""
    
    # Plan
    echo "Planning infrastructure changes..."
    terraform plan
    
    echo ""
    read -p "Do you want to continue with deployment? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Deployment cancelled."
        exit 0
    fi
    
    # Apply
    echo ""
    echo "Deploying infrastructure (this takes ~15-20 minutes)..."
    terraform apply -auto-approve
    
    echo -e "${GREEN}✅ Infrastructure deployed!${NC}"
    echo ""
    
    cd ../..
}

# Configure kubectl
configure_kubectl() {
    echo "⚙️  Configuring kubectl..."
    
    aws eks update-kubeconfig --region us-east-1 --name fictions-api
    
    echo -e "${GREEN}✅ kubectl configured!${NC}"
    echo ""
    
    echo "Waiting for nodes to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    echo -e "${GREEN}✅ EKS cluster is ready!${NC}"
    echo ""
}

# Build and deploy application
build_and_deploy() {
    echo "🐳 Building and deploying application..."
    echo ""
    
    # Get ECR URL
    cd infrastructure/terraform-eks
    ECR_URL=$(terraform output -raw ecr_repository_url)
    cd ../..
    
    echo "ECR Repository: $ECR_URL"
    echo ""
    
    # Build Docker image
    echo "Building Docker image..."
    docker build -t fictions-api:dev .
    
    # Login to ECR
    echo "Logging in to ECR..."
    aws ecr get-login-password --region us-east-1 | \
        docker login --username AWS --password-stdin $ECR_URL
    
    # Tag and push
    echo "Pushing image to ECR..."
    docker tag fictions-api:dev $ECR_URL:latest
    docker push $ECR_URL:latest
    
    echo -e "${GREEN}✅ Image pushed to ECR!${NC}"
    echo ""
    
    # Restart deployment
    echo "Deploying to Kubernetes..."
    kubectl rollout restart deployment/fictions-api -n fictions-app
    
    echo "Waiting for deployment to complete..."
    kubectl rollout status deployment/fictions-api -n fictions-app --timeout=300s
    
    echo -e "${GREEN}✅ Application deployed!${NC}"
    echo ""
}

# Get application URL
get_app_url() {
    echo "🌐 Getting application URL..."
    echo ""
    
    echo "Waiting for Load Balancer to be ready..."
    sleep 10
    
    APP_URL=$(kubectl get svc fictions-api -n fictions-app \
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")
    
    if [ "$APP_URL" = "pending" ] || [ -z "$APP_URL" ]; then
        echo -e "${YELLOW}⏳ Load Balancer is still provisioning...${NC}"
        echo "   Run this command to check status:"
        echo "   kubectl get svc fictions-api -n fictions-app"
    else
        echo -e "${GREEN}✅ Application is accessible at:${NC}"
        echo "   http://$APP_URL"
        echo ""
        echo "   Health check: http://$APP_URL/health"
    fi
    echo ""
}

# Display summary
display_summary() {
    echo "=========================================="
    echo "✅ Development Deployment Complete!"
    echo "=========================================="
    echo ""
    echo "📝 Quick Commands:"
    echo ""
    echo "   # View pods"
    echo "   kubectl get pods -n fictions-app"
    echo ""
    echo "   # View logs"
    echo "   kubectl logs -f deployment/fictions-api -n fictions-app"
    echo ""
    echo "   # Get application URL"
    echo "   kubectl get svc fictions-api-service -n fictions-app"
    echo ""
    echo "   # Scale application"
    echo "   kubectl scale deployment fictions-api -n fictions-app --replicas=2"
    echo ""
    echo "   # Destroy everything (save costs when not using)"
    echo "   cd infrastructure/terraform-eks && terraform destroy"
    echo ""
    echo "💰 Cost Saving Tips:"
    echo "   • Run 'terraform destroy' when not using (saves ~$150/month)"
    echo "   • Scale pods to 0: kubectl scale deployment fictions-api -n fictions-app --replicas=0"
    echo ""
    echo "📚 Documentation:"
    echo "   • Full guide: EKS_DEPLOYMENT.md"
    echo "   • Quick start: QUICK_START_EKS.md"
    echo "   • API docs: API_DOCUMENTATION.md"
    echo ""
}

# Main execution
main() {
    check_prerequisites
    display_config
    
    read -p "Continue with deployment? (yes/no): " start_confirm
    if [ "$start_confirm" != "yes" ]; then
        echo "Deployment cancelled."
        exit 0
    fi
    
    echo ""
    
    deploy_infrastructure
    configure_kubectl
    build_and_deploy
    get_app_url
    display_summary
}

# Run main function
main

