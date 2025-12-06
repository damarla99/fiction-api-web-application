#!/bin/bash
set -e

# ============================================================================
# Kubectl Deployment Script for Fictions API
# ============================================================================
# This script deploys the application to EKS using kubectl and YAML manifests
# Prerequisite: EKS cluster must already exist (created via Terraform)
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="fictions-app"
KUBECTL_DIR="../kubernetes"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🚀 Deploying Fictions API to EKS using kubectl${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================================================
# Step 1: Verify kubectl is configured
# ============================================================================
echo -e "${YELLOW}1️⃣  Verifying kubectl configuration...${NC}"
if ! kubectl cluster-info &>/dev/null; then
    echo -e "${RED}❌ kubectl is not configured to access a cluster${NC}"
    echo ""
    echo "Please configure kubectl first:"
    echo "  aws eks update-kubeconfig --region us-east-1 --name fictions-api"
    exit 1
fi

CLUSTER_NAME=$(kubectl config current-context)
echo -e "${GREEN}✅ Connected to cluster: $CLUSTER_NAME${NC}"
echo ""

# ============================================================================
# Step 2: Verify nodes are ready
# ============================================================================
echo -e "${YELLOW}2️⃣  Checking EKS nodes...${NC}"
NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$NODE_COUNT" -eq 0 ]; then
    echo -e "${RED}❌ No nodes found in cluster${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Found $NODE_COUNT node(s)${NC}"
kubectl get nodes
echo ""

# ============================================================================
# Step 3: Check if backend deployment has ECR URL
# ============================================================================
echo -e "${YELLOW}3️⃣  Checking deployment configuration...${NC}"
if grep -q "<YOUR_ECR_REPO_URL>" "$KUBECTL_DIR/backend-deployment.yaml"; then
    echo -e "${RED}❌ backend-deployment.yaml still has placeholder ECR URL${NC}"
    echo ""
    echo "Please update the image URL in kubernetes/backend-deployment.yaml:"
    echo "  1. Get ECR URL: terraform output ecr_repository_url"
    echo "  2. Replace <YOUR_ECR_REPO_URL> with your actual ECR URL"
    echo ""
    exit 1
fi
echo -e "${GREEN}✅ backend-deployment.yaml is configured${NC}"
echo ""

# ============================================================================
# Step 4: Check if secrets are updated
# ============================================================================
echo -e "${YELLOW}4️⃣  Checking secrets configuration...${NC}"
if grep -q "dev-secret-change-me-in-production" "$KUBECTL_DIR/secrets.yaml"; then
    echo -e "${YELLOW}⚠️  Using default dev secrets (OK for development)${NC}"
    echo "   For production, please update kubernetes/secrets.yaml"
else
    echo -e "${GREEN}✅ Custom secrets configured${NC}"
fi
echo ""

# ============================================================================
# Step 5: Deploy Kubernetes resources
# ============================================================================
echo -e "${YELLOW}5️⃣  Deploying Kubernetes resources...${NC}"
echo ""

# Deploy in order
echo "📦 Creating namespace..."
kubectl apply -f "$KUBECTL_DIR/namespace.yaml"

echo "📦 Creating ConfigMap..."
kubectl apply -f "$KUBECTL_DIR/configmap.yaml"

echo "📦 Creating Secrets..."
kubectl apply -f "$KUBECTL_DIR/secrets.yaml"

echo "📦 Deploying MongoDB..."
kubectl apply -f "$KUBECTL_DIR/mongodb.yaml"

# Wait for MongoDB to be ready
echo ""
echo -e "${YELLOW}⏳ Waiting for MongoDB to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=mongodb -n $NAMESPACE --timeout=120s || true

echo ""
echo "📦 Deploying Backend API..."
kubectl apply -f "$KUBECTL_DIR/backend-deployment.yaml"
kubectl apply -f "$KUBECTL_DIR/backend-service.yaml"

echo "📦 Deploying Frontend..."
kubectl apply -f "$KUBECTL_DIR/frontend-deployment.yaml"
kubectl apply -f "$KUBECTL_DIR/frontend-service.yaml"

echo "📦 Creating Ingress (ALB)..."
kubectl apply -f "$KUBECTL_DIR/ingress.yaml"

echo "📦 Creating HPA (Horizontal Pod Autoscaler)..."
kubectl apply -f "$KUBECTL_DIR/hpa.yaml"

echo ""
echo -e "${GREEN}✅ All resources deployed successfully!${NC}"
echo ""

# ============================================================================
# Step 6: Wait for pods to be ready
# ============================================================================
echo -e "${YELLOW}6️⃣  Waiting for pods to be ready...${NC}"
echo ""

echo "⏳ Waiting for API pods..."
kubectl wait --for=condition=ready pod -l app=fictions-api -n $NAMESPACE --timeout=120s || true

echo ""
echo -e "${YELLOW}📊 Current pod status:${NC}"
kubectl get pods -n $NAMESPACE
echo ""

# ============================================================================
# Step 7: Get ALB URL from Ingress
# ============================================================================
echo -e "${YELLOW}7️⃣  Getting Application Load Balancer URL...${NC}"
echo ""
echo "⏳ Waiting for ALB to provision via Ingress (this may take 2-3 minutes)..."
echo ""

# Wait for Ingress to get an ALB hostname
MAX_WAIT=180  # 3 minutes
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    ALB_URL=$(kubectl get ingress fictions-app-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    
    if [ -n "$ALB_URL" ]; then
        break
    fi
    
    echo -n "."
    sleep 5
    WAITED=$((WAITED + 5))
done

echo ""
echo ""

if [ -z "$ALB_URL" ]; then
    echo -e "${YELLOW}⚠️  ALB is still provisioning${NC}"
    echo ""
    echo "Check status with:"
    echo "  kubectl get ingress fictions-app-ingress -n $NAMESPACE -w"
else
    echo -e "${GREEN}✅ ALB is ready!${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Deployment Complete!${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}📍 Application URLs:${NC}"
    echo ""
    echo "   Frontend:  http://$ALB_URL"
    echo "   Backend:   http://$ALB_URL/api"
    echo "   Health:    http://$ALB_URL/health"
    echo "   API Docs:  http://$ALB_URL/api/docs"
    echo ""
    echo -e "${YELLOW}🧪 Test Commands:${NC}"
    echo ""
    echo "   # Test backend health"
    echo "   curl http://$ALB_URL/health"
    echo ""
    echo "   # Open frontend in browser"
    echo "   open http://$ALB_URL"
    echo ""
    echo "   # Open API docs"
    echo "   open http://$ALB_URL/api/docs"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

echo ""
echo -e "${YELLOW}📊 Useful Commands:${NC}"
echo ""
echo "   # View all resources"
echo "   kubectl get all -n $NAMESPACE"
echo ""
echo "   # View logs"
echo "   kubectl logs -n $NAMESPACE deployment/fictions-api -f"
echo ""
echo "   # Restart deployment"
echo "   kubectl rollout restart deployment/fictions-api -n $NAMESPACE"
echo ""
echo "   # Scale deployment"
echo "   kubectl scale deployment/fictions-api --replicas=3 -n $NAMESPACE"
echo ""
echo "   # Delete deployment"
echo "   kubectl delete -f $KUBECTL_DIR/"
echo ""
echo -e "${GREEN}✅ Done!${NC}"

