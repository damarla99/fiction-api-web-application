#!/bin/bash

################################################################################
# Create Kubernetes Secrets for Fictions API
# This script helps generate secure secrets without committing them to git
################################################################################

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Kubernetes Secrets Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if openssl is available
if ! command -v openssl &> /dev/null; then
    echo "❌ openssl not found. Using fallback random generation."
    JWT_SECRET=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
else
    # Generate a secure random JWT secret (64 characters)
    JWT_SECRET=$(openssl rand -hex 32)
fi

echo "✅ Generated secure JWT_SECRET"
echo ""

# Prompt for MongoDB URI
read -p "📝 MongoDB URI (default: mongodb://mongodb-service:27017/fictions_db): " MONGODB_URI
MONGODB_URI=${MONGODB_URI:-"mongodb://mongodb-service:27017/fictions_db"}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Creating Kubernetes secret..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create namespace if it doesn't exist
kubectl create namespace fictions-app --dry-run=client -o yaml | kubectl apply -f -

# Create the secret
kubectl create secret generic app-secrets \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --from-literal=MONGODB_URI="$MONGODB_URI" \
  --namespace=fictions-app \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Secret 'app-secrets' created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 IMPORTANT:"
echo "  - Secrets are stored in Kubernetes cluster only"
echo "  - NOT committed to git (secure!)"
echo "  - To view: kubectl get secret app-secrets -n fictions-app -o yaml"
echo ""
echo "💡 TIP: For production, use:"
echo "  - AWS Secrets Manager + External Secrets Operator"
echo "  - HashiCorp Vault"
echo "  - Sealed Secrets"
echo ""

