# Kubernetes Manifests

**Manual Kubernetes deployment files for Fictions API**

---

## 📋 Overview

This directory contains Kubernetes manifests for deploying the Fictions API to any Kubernetes cluster.

**Use these if you want to:**
- Deploy to an existing Kubernetes cluster (not provisioned by Terraform)
- Have more control over Kubernetes resources
- Use tools like Helm, Kustomize, ArgoCD, etc.

**OR use Terraform:**
- If you want everything automated (AWS + Kubernetes), use `infrastructure/terraform-eks/`
- Terraform provisions AWS infrastructure AND deploys Kubernetes resources

---

## 📁 Files

| File | Description |
|------|-------------|
| `namespace.yaml` | Creates `fictions-app` namespace |
| `secrets.yaml` | Secrets (JWT, MongoDB URI) - **DO NOT COMMIT REAL VALUES** |
| `configmap.yaml` | Environment variables |
| `mongodb.yaml` | MongoDB StatefulSet + Service |
| `deployment.yaml` | Fictions API Deployment |
| `service.yaml` | LoadBalancer Service (NLB on AWS) |
| `hpa.yaml` | Horizontal Pod Autoscaler |

---

## 🚀 Quick Deploy

### Prerequisites

```bash
# 1. Have a Kubernetes cluster running
kubectl cluster-info

# 2. Have Docker image in a registry (ECR, Docker Hub, etc.)
# Build and push image first

# 3. Update image URL in deployment.yaml
# Replace <YOUR_ECR_REPO_URL> with your actual registry URL
```

### Deploy

```bash
# 1. Create namespace
kubectl apply -f kubernetes/namespace.yaml

# 2. Create secrets (update values first!)
kubectl apply -f kubernetes/secrets.yaml

# 3. Create configmap
kubectl apply -f kubernetes/configmap.yaml

# 4. Deploy MongoDB
kubectl apply -f kubernetes/mongodb.yaml

# 5. Deploy API
kubectl apply -f kubernetes/deployment.yaml

# 6. Create service (Load Balancer)
kubectl apply -f kubernetes/service.yaml

# 7. Enable auto-scaling (optional)
kubectl apply -f kubernetes/hpa.yaml
```

### Or Deploy All at Once

```bash
kubectl apply -f kubernetes/
```

---

## 🔧 Configuration

### Update Secrets

**Before deploying, update `secrets.yaml`:**

```yaml
stringData:
  JWT_SECRET: "your-secure-jwt-secret-here"
  MONGODB_URI: "mongodb://mongodb-service:27017/fictions_db"
```

**For production, use:**
```bash
# Create secret from command line
kubectl create secret generic app-secrets \
  --from-literal=JWT_SECRET="$(openssl rand -hex 32)" \
  --from-literal=MONGODB_URI="mongodb://mongodb-service:27017/fictions_db" \
  -n fictions-app
```

### Update Image URL

**In `deployment.yaml`, replace:**
```yaml
image: <YOUR_ECR_REPO_URL>:latest
```

**With your actual image:**
```yaml
image: 123456789.dkr.ecr.us-east-1.amazonaws.com/fictions-api:latest
```

---

## 📊 Verify Deployment

```bash
# Check all resources
kubectl get all -n fictions-app

# Check pods
kubectl get pods -n fictions-app

# Check service (get load balancer URL)
kubectl get svc fictions-api -n fictions-app

# Check logs
kubectl logs -f deployment/fictions-api -n fictions-app
```

---

## 🌐 Access Application

```bash
# Get Load Balancer URL
kubectl get svc fictions-api -n fictions-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Test
curl http://<LOAD_BALANCER_URL>/health
```

---

## 🔄 Update Application

```bash
# Option 1: Update image tag
kubectl set image deployment/fictions-api \
  fictions-api=<YOUR_ECR_REPO_URL>:v2.0 \
  -n fictions-app

# Option 2: Restart with latest image
kubectl rollout restart deployment/fictions-api -n fictions-app

# Watch rollout
kubectl rollout status deployment/fictions-api -n fictions-app
```

---

## 📈 Scaling

### Manual Scaling

```bash
# Scale to 3 replicas
kubectl scale deployment fictions-api -n fictions-app --replicas=3

# Check
kubectl get pods -n fictions-app
```

### Auto-Scaling (HPA)

```bash
# Apply HPA
kubectl apply -f kubernetes/hpa.yaml

# Check HPA status
kubectl get hpa -n fictions-app

# Describe for details
kubectl describe hpa fictions-api-hpa -n fictions-app
```

---

## 🗑️ Cleanup

```bash
# Delete all resources
kubectl delete -f kubernetes/

# Or delete namespace (removes everything)
kubectl delete namespace fictions-app
```

---

## 🔄 Terraform vs Manual Kubernetes

| Aspect | Terraform (infrastructure/) | Manual K8s (kubernetes/) |
|--------|----------------------------|--------------------------|
| **AWS Resources** | ✅ Provisions EKS, VPC, etc. | ❌ Need existing cluster |
| **K8s Resources** | ✅ Creates via Terraform | ✅ Apply with kubectl |
| **Automation** | ✅ Fully automated | Manual apply |
| **Flexibility** | Coupled to AWS | Works with any K8s |
| **Best For** | New AWS deployments | Existing clusters |

### When to Use Each

**Use Terraform (`infrastructure/terraform-eks/`):**
- Starting from scratch on AWS
- Want full automation (AWS + K8s)
- Single command deployment
- Infrastructure as Code for everything

**Use Manual K8s (`kubernetes/`):**
- Already have a Kubernetes cluster
- Want more control over K8s resources
- Using tools like Helm, ArgoCD
- Multi-cloud or on-premise K8s

---

## 📝 Notes

### Storage Class

MongoDB uses `gp3` storage class (AWS EBS). If using a different cloud:

```yaml
# In mongodb.yaml, change:
storageClassName: gp3

# To your storage class:
storageClassName: standard  # GKE
storageClassName: default   # Generic
```

### Load Balancer

Service uses AWS NLB annotation. For other clouds:

```yaml
# Remove or change annotation in service.yaml:
annotations:
  service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
```

### Image Pull Secrets

If using private registry:

```bash
# Create secret
kubectl create secret docker-registry ecr-secret \
  --docker-server=<ECR_URL> \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  -n fictions-app

# Add to deployment.yaml:
spec:
  imagePullSecrets:
  - name: ecr-secret
```

---

## 🔗 Related Documentation

- **Infrastructure (Terraform)**: `../infrastructure/terraform-eks/README.md`
- **Developer Guide**: `../dev-tools/README_DEVELOPERS.md`
- **DevOps Guide**: `../ops-tools/README_DEVOPS.md`
- **API Documentation**: `../API_DOCUMENTATION.md`

---

**For full automation with AWS, use Terraform instead!**  
→ See `infrastructure/terraform-eks/README.md`

