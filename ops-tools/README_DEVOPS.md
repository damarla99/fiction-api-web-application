# DevOps / Operations Guide

**For: DevOps Engineers, SREs, Infrastructure Team**  
**Handles: AWS deployment, Kubernetes, infrastructure, monitoring**

---

## 🎯 Your Responsibilities

As DevOps/Ops, you handle:
- ✅ AWS infrastructure (EKS, VPC, networking)
- ✅ Kubernetes cluster management
- ✅ CI/CD pipelines
- ✅ Deployment automation
- ✅ Monitoring and logging
- ✅ Secrets management
- ✅ Cost optimization
- ❌ **Not responsible for**: Application code (that's developers)

Developers write code, you deploy it.

---

## 📁 What You Work With

```
webapp-devops/
├── infrastructure/                  # YOUR INFRASTRUCTURE CODE
│   ├── terraform-eks/          # EKS Terraform configs
│   │   ├── backend.tf          # Terraform backend config
│   │   ├── provider.tf         # AWS, K8s, Helm providers
│   │   ├── main.tf             # Data sources
│   │   ├── variables.tf
│   │   ├── vpc.tf              # VPC, subnets
│   │   ├── eks.tf              # EKS cluster
│   │   ├── ecr.tf              # Container registry
│   │   ├── addons.tf           # EKS add-ons
│   │   ├── kubernetes.tf.disabled  # (Using kubectl instead)
│   │   └── ...
│   └── kubernetes/             # K8s manifests (kubectl)
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ...
├── ops-tools/                  # YOUR DEVOPS TOOLS
│   ├── build-and-push.sh      # Build & push Docker image
│   ├── update-k8s-image.sh    # Update deployment YAML
│   ├── deploy-kubectl.sh      # Deploy with kubectl
│   ├── test-api.sh            # Test deployed API
│   └── README_DEVOPS.md       # This file
├── .github/workflows/         # CI/CD pipelines
└── Dockerfile                 # Container build instructions
```

**Developers handle:**
- `src/` - Application code
- `dev-tools/` - Local development tools

---

## 🚀 Quick Start (Ops Tasks)

### Deploy to AWS EKS (kubectl Approach)

**Recommended Deployment: Terraform (Infrastructure) + kubectl (Application)**

```bash
# 1. Deploy infrastructure (VPC, EKS, ECR)
cd infrastructure/terraform-eks
terraform init && terraform apply

# 2. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name fictions-api-development

# 3. Build and push Docker image
cd ../../ops-tools
./build-and-push.sh

# 4. Update deployment with ECR URL
./update-k8s-image.sh

# 5. Deploy application to Kubernetes
./deploy-kubectl.sh
```

**See `KUBECTL_DEPLOYMENT.md` for complete guide.**

### Manual Deployment (Step by Step)

```bash
# 1. Deploy infrastructure
cd infrastructure/terraform-eks
terraform init
terraform apply

# 2. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name fictions-api-development

# 3. Build and push image
ECR_URL=$(terraform output -raw ecr_repository_url)
cd ../..
docker build -t fictions-api .
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
docker tag fictions-api:latest $ECR_URL:latest
docker push $ECR_URL:latest

# 4. Restart deployment
kubectl rollout restart infrastructure/fictions-api -n fictions-app
```

---

## 📊 Infrastructure Overview

### AWS Resources Managed

```
VPC (10.0.0.0/16)
├── 2 Public Subnets (us-east-1a, us-east-1b)
├── 2 Private Subnets (us-east-1a, us-east-1b)
├── 1 NAT Gateway (cost optimized for dev)
├── Internet Gateway
└── Route Tables

EKS Cluster
├── Control Plane (managed by AWS)
├── Worker Nodes: 1x t3.small
├── Node Group (auto-scaling: 1-2 nodes)
└── Add-ons:
    ├── AWS Load Balancer Controller
    ├── EBS CSI Driver
    ├── CoreDNS
    ├── kube-proxy
    └── VPC-CNI

ECR Repository
└── fictions-api (Docker images)

Network Load Balancer
└── External endpoint for API

CloudWatch
├── Container Insights
└── Log Groups
```

### Kubernetes Resources

```
Namespace: fictions-app
├── MongoDB StatefulSet
│   ├── 1 replica
│   ├── 5GB PersistentVolume (EBS)
│   └── ClusterIP Service
├── Fictions API Deployment
│   ├── 1 replica (dev mode)
│   ├── HPA: 1-3 pods
│   └── LoadBalancer Service (NLB)
├── ConfigMap (env vars)
└── Secrets (JWT, MongoDB URI)
```

---

## 🛠️ Common Operations Tasks

### 1. Deploy New Application Version

```bash
# Developers push code to Git
# You deploy it:

# Get ECR URL
cd infrastructure/terraform-eks
ECR_URL=$(terraform output -raw ecr_repository_url)

# Build new image
cd ../..
docker build -t fictions-api:v1.2.3 .

# Push to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
docker tag fictions-api:v1.2.3 $ECR_URL:v1.2.3
docker tag fictions-api:v1.2.3 $ECR_URL:latest
docker push $ECR_URL:v1.2.3
docker push $ECR_URL:latest

# Deploy to K8s
kubectl set image infrastructure/fictions-api \
    fictions-api=$ECR_URL:v1.2.3 \
    -n fictions-app

# Watch rollout
kubectl rollout status infrastructure/fictions-api -n fictions-app
```

### 2. Scale Application

```bash
# Manual scaling
kubectl scale deployment fictions-api -n fictions-app --replicas=3

# Update HPA limits
kubectl edit hpa fictions-api-hpa -n fictions-app

# Scale nodes (via Terraform)
cd infrastructure/terraform-eks
# Edit terraform.tfvars: node_desired_size = 2
terraform apply
```

### 3. Monitor Resources

```bash
# Pod status
kubectl get pods -n fictions-app

# Pod resource usage
kubectl top pods -n fictions-app

# Node resource usage
kubectl top nodes

# Application logs
kubectl logs -f infrastructure/fictions-api -n fictions-app

# MongoDB logs
kubectl logs -f statefulset/mongodb -n fictions-app

# HPA status
kubectl get hpa -n fictions-app
kubectl describe hpa fictions-api-hpa -n fictions-app
```

### 4. Update Infrastructure

```bash
cd infrastructure/terraform-eks

# Edit .tf files
vim variables.tf

# Plan changes
terraform plan

# Apply changes
terraform apply

# View current state
terraform show

# View outputs
terraform output
```

### 5. Backup MongoDB

```bash
# Port-forward to MongoDB
kubectl port-forward -n fictions-app statefulset/mongodb 27017:27017 &

# Backup
mongodump --uri="mongodb://localhost:27017/fictions_db" --out=backup-$(date +%Y%m%d)

# Upload to S3
aws s3 cp backup-$(date +%Y%m%d) s3://your-backup-bucket/ --recursive

# Kill port-forward
killall kubectl
```

### 6. Restore MongoDB

```bash
# Port-forward
kubectl port-forward -n fictions-app statefulset/mongodb 27017:27017 &

# Download from S3
aws s3 cp s3://your-backup-bucket/backup-20240101 ./restore --recursive

# Restore
mongorestore --uri="mongodb://localhost:27017/fictions_db" --drop ./restore/fictions_db

# Kill port-forward
killall kubectl
```

### 7. Update Secrets

```bash
# Create new secret
kubectl create secret generic app-secrets-new \
    --from-literal=JWT_SECRET="new-secret" \
    --from-literal=MONGODB_URI="mongodb://..." \
    -n fictions-app

# Update deployment to use new secret
kubectl edit deployment fictions-api -n fictions-app
# Change secretName to app-secrets-new

# Delete old secret
kubectl delete secret app-secrets -n fictions-app
```

### 8. Troubleshoot Issues

```bash
# Check all resources
kubectl get all -n fictions-app

# Describe pod
kubectl describe pod/<pod-name> -n fictions-app

# Get events
kubectl get events -n fictions-app --sort-by='.lastTimestamp'

# Check logs
kubectl logs <pod-name> -n fictions-app --previous

# Exec into pod
kubectl exec -it <pod-name> -n fictions-app -- /bin/sh

# Check service endpoints
kubectl get endpoints -n fictions-app

# Check load balancer
kubectl describe svc fictions-api-service -n fictions-app
```

---

## 💰 Cost Management

### Current Monthly Costs (Dev Mode)

| Resource | Cost |
|----------|------|
| EKS Control Plane | $73 |
| EC2 (1x t3.small) | ~$15 |
| NAT Gateway (1) | ~$32 |
| Load Balancer | ~$20 |
| EBS Storage | ~$1 |
| **Total** | **~$141/month** |

### Cost Optimization

```bash
# 1. Destroy when not in use
cd infrastructure/terraform-eks
terraform destroy

# 2. Use Spot instances (in terraform.tfvars)
capacity_type = "SPOT"  # 60% cost reduction

# 3. Schedule start/stop (Lambda + EventBridge)
# Stop cluster at night, weekends

# 4. Right-size resources
# Monitor with: kubectl top nodes
# Adjust in variables.tf

# 5. Clean up old images
aws ecr list-images --repository-name fictions-api
aws ecr batch-delete-image --repository-name fictions-api --image-ids imageTag=old-tag
```

---

## 🔐 Security Best Practices

### 1. Secrets Management

```bash
# Never commit secrets to Git
# Use AWS Secrets Manager or K8s secrets

# Rotate secrets regularly
kubectl create secret generic app-secrets \
    --from-literal=JWT_SECRET="$(openssl rand -hex 32)" \
    --dry-run=client -o yaml | kubectl apply -f -

# Restart pods to use new secrets
kubectl rollout restart infrastructure/fictions-api -n fictions-app
```

### 2. Network Security

```bash
# Review security groups
aws ec2 describe-security-groups --region us-east-1

# Check network policies
kubectl get networkpolicies -n fictions-app

# Ensure private subnets for nodes
# Public subnets only for load balancers
```

### 3. RBAC

```bash
# Create service account for CI/CD
kubectl create serviceaccount github-actions -n fictions-app

# Bind role
kubectl create rolebinding github-actions-deploy \
    --clusterrole=edit \
    --serviceaccount=fictions-app:github-actions \
    --namespace=fictions-app
```

### 4. Image Security

```bash
# Enable ECR image scanning
aws ecr put-image-scanning-configuration \
    --repository-name fictions-api \
    --image-scanning-configuration scanOnPush=true

# Scan images
aws ecr start-image-scan --repository-name fictions-api --image-id imageTag=latest

# Get scan results
aws ecr describe-image-scan-findings --repository-name fictions-api --image-id imageTag=latest
```

---

## 📈 Monitoring & Alerting

### CloudWatch Container Insights

```bash
# Enable Container Insights (already enabled in Terraform)
# View in AWS Console:
# CloudWatch → Container Insights → EKS Clusters → fictions-api

# View metrics
aws cloudwatch get-metric-statistics \
    --namespace ContainerInsights \
    --metric-name pod_cpu_utilization \
    --dimensions Name=ClusterName,Value=fictions-api \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average
```

### Kubernetes Metrics

```bash
# Install metrics-server (already in Terraform)
kubectl top nodes
kubectl top pods -n fictions-app

# View HPA metrics
kubectl get hpa -n fictions-app
```

### Set Up Alerts

```bash
# Create SNS topic
aws sns create-topic --name eks-alerts

# Subscribe email
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:ACCOUNT:eks-alerts \
    --protocol email \
    --notification-endpoint ops@example.com

# Create CloudWatch alarm
aws cloudwatch put-metric-alarm \
    --alarm-name high-cpu-usage \
    --alarm-description "Alert when CPU > 80%" \
    --metric-name pod_cpu_utilization \
    --namespace ContainerInsights \
    --statistic Average \
    --period 300 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --alarm-actions arn:aws:sns:us-east-1:ACCOUNT:eks-alerts
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

Location: `.github/workflows/ci-cd.yml`

**Triggers:**
- Push to `main` branch
- Pull requests

**Jobs:**
1. **Build** - Build Docker image
2. **Test** - Run tests
3. **Deploy** - Push to ECR, deploy to EKS

**Secrets needed in GitHub:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

---

## 🧹 Cleanup

### Temporary Shutdown (Save Costs)

```bash
# Scale app to 0
kubectl scale deployment fictions-api -n fictions-app --replicas=0

# Or destroy cluster
cd infrastructure/terraform-eks
terraform destroy
```

### Permanent Cleanup

```bash
# 1. Delete EKS cluster
cd infrastructure/terraform-eks
terraform destroy

# 2. Delete ECR images
aws ecr batch-delete-image \
    --repository-name fictions-api \
    --image-ids "$(aws ecr list-images --repository-name fictions-api --query 'imageIds[*]' --output json)"

# 3. Delete ECR repository
aws ecr delete-repository --repository-name fictions-api --force

# 4. Clean up local Docker
docker system prune -a
```

---

## 📚 Additional Resources

- **Terraform Docs**: `infrastructure/terraform-eks/README.md`
- **EKS Deployment Guide**: `EKS_DEPLOYMENT.md`
- **Full Deployment Guide**: `DEPLOYMENT_GUIDE.md`
- **Quick Reference**: `QUICK_REFERENCE.md`

---

## 🆘 Common Issues & Solutions

### Issue: Pods in CrashLoopBackOff

```bash
# Check logs
kubectl logs <pod-name> -n fictions-app

# Check events
kubectl describe pod <pod-name> -n fictions-app

# Common causes:
# - Wrong image tag
# - Missing secrets
# - MongoDB not ready
```

### Issue: Load Balancer Not Working

```bash
# Check service
kubectl describe svc fictions-api-service -n fictions-app

# Check AWS LB Controller
kubectl logs -n kube-system infrastructure/aws-load-balancer-controller

# Verify security groups
aws ec2 describe-security-groups --region us-east-1
```

### Issue: High Costs

```bash
# Check NAT Gateway usage (biggest cost)
# Consider single NAT gateway for dev

# Check node sizes
kubectl get nodes -o wide

# Right-size in variables.tf
```

---

## ✅ Deployment Checklist

Before deploying to production:

- [ ] Terraform plan reviewed
- [ ] Secrets rotated
- [ ] Backups configured
- [ ] Monitoring and alerts set up
- [ ] Cost estimates reviewed
- [ ] Security groups configured
- [ ] RBAC policies in place
- [ ] Image scanned for vulnerabilities
- [ ] Load testing completed
- [ ] Rollback plan documented

---

**Happy Operating! 🚀**

Your job: Keep the infrastructure running smoothly.  
Developer job: Write the code.

