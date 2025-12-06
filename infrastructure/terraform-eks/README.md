# EKS Deployment with Terraform

Deploy the Fictions API on Amazon EKS (Elastic Kubernetes Service) using Terraform.

## 🎯 What Gets Deployed

This Terraform configuration creates a complete, production-ready EKS cluster with:

### Infrastructure
- **EKS Cluster** (Kubernetes 1.28)
- **VPC** with public and private subnets across 3 AZs
- **NAT Gateways** for private subnet internet access
- **EKS Managed Node Group** (2-4 t3.medium instances)
- **ECR Repository** for container images

### Kubernetes Addons
- **AWS Load Balancer Controller** - Manages ALB/NLB
- **Cluster Autoscaler** - Auto-scales worker nodes
- **Metrics Server** - Enables HPA (Horizontal Pod Autoscaler)
- **CoreDNS, kube-proxy, VPC-CNI** - Essential cluster components
- **EBS CSI Driver** - For persistent volumes

### Application Components
- **Fictions API Deployment** (3 replicas with HPA 2-10)
- **MongoDB StatefulSet** with persistent storage (10GB)
- **Network Load Balancer** (internet-facing)
- **Kubernetes Secrets** for sensitive data
- **ConfigMaps** for configuration

---

## 📋 Prerequisites

1. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```

2. **Terraform** >= 1.0
   ```bash
   terraform --version
   ```

3. **kubectl** installed
   ```bash
   kubectl version --client
   ```

4. **Docker** installed
   ```bash
   docker --version
   ```

---

## 🚀 Quick Start

### Step 1: Initialize Terraform

```bash
cd infrastructure/terraform-eks
terraform init
```

### Step 2: Configure Variables

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Or use environment variables (recommended for secrets)
export TF_VAR_jwt_secret="$(openssl rand -hex 32)"
export TF_VAR_mongodb_uri="mongodb://mongodb-service:27017/fictions_db"
```

### Step 3: Deploy EKS Cluster

```bash
# Review the plan
terraform plan

# Apply (takes 15-20 minutes)
terraform apply
```

**Note:** EKS cluster creation takes ~15-20 minutes. ☕

### Step 4: Configure kubectl

```bash
# Get the configure command from output
terraform output -raw configure_kubectl

# Or manually:
aws eks update-kubeconfig --region us-east-1 --name fictions-api
```

### Step 5: Verify Cluster

```bash
# Check nodes
kubectl get nodes

# Check all resources
kubectl get all -n fictions-app

# Check pods
kubectl get pods -n fictions-app
```

### Step 6: Build and Push Docker Image

```bash
# Navigate to project root
cd ../../

# Get ECR URL
ECR_URL=$(cd infrastructure/terraform-eks && terraform output -raw ecr_repository_url)

# Build image
docker build -t fictions-api .

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin $ECR_URL

# Tag and push
docker tag fictions-api:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

### Step 7: Update Deployment

```bash
# Restart deployment to pull new image
kubectl rollout restart deployment/fictions-api -n fictions-app

# Watch rollout status
kubectl rollout status deployment/fictions-api -n fictions-app
```

### Step 8: Get Application URL

```bash
# Get Load Balancer URL
kubectl get svc fictions-api -n fictions-app

# Or use this command
kubectl get svc fictions-api -n fictions-app \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Note:** Load balancer provisioning takes 2-3 minutes.

### Step 9: Test the Application

```bash
# Get LB hostname
LB_HOST=$(kubectl get svc fictions-api -n fictions-app \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test health endpoint
curl http://$LB_HOST/health
```

---

## 📊 What's Running

After deployment, you'll have:

```
EKS Cluster: fictions-api
├── Node Group (2-4 t3.medium instances)
│   ├── Cluster Autoscaler (scales nodes)
│   ├── AWS Load Balancer Controller (manages LB)
│   └── Metrics Server (for HPA)
│
└── Namespace: fictions-app
    ├── MongoDB StatefulSet (1 replica)
    │   └── PersistentVolume (10GB EBS gp3)
    ├── Fictions API Deployment (3 replicas)
    │   └── HorizontalPodAutoscaler (2-10 pods)
    ├── Services
    │   ├── mongodb-service (ClusterIP)
    │   └── fictions-api (LoadBalancer)
    ├── ConfigMaps
    │   └── fictions-api-config
    └── Secrets
        └── fictions-api-secrets
```

---

## 🔧 Common Operations

### Scale Application

```bash
# Manual scaling
kubectl scale deployment fictions-api -n fictions-app --replicas=5

# Check HPA status
kubectl get hpa -n fictions-app

# Describe HPA
kubectl describe hpa fictions-api-hpa -n fictions-app
```

### View Logs

```bash
# Application logs
kubectl logs -f deployment/fictions-api -n fictions-app

# MongoDB logs
kubectl logs -f statefulset/mongodb -n fictions-app

# Specific pod logs
kubectl logs -f pod/fictions-api-xxx -n fictions-app
```

### Update Application

```bash
# After pushing new image to ECR
kubectl rollout restart deployment/fictions-api -n fictions-app

# Watch rollout
kubectl rollout status deployment/fictions-api -n fictions-app

# Rollback if needed
kubectl rollout undo deployment/fictions-api -n fictions-app
```

### Access MongoDB

```bash
# Port forward to local machine
kubectl port-forward -n fictions-app statefulset/mongodb 27017:27017

# In another terminal, connect
mongosh mongodb://localhost:27017/fictions_db
```

### Debug Pods

```bash
# Describe pod
kubectl describe pod/fictions-api-xxx -n fictions-app

# Get pod events
kubectl get events -n fictions-app --sort-by='.lastTimestamp'

# Execute command in pod
kubectl exec -it deployment/fictions-api -n fictions-app -- /bin/sh

# Check resource usage
kubectl top pods -n fictions-app
kubectl top nodes
```

---

## 🔄 Update Infrastructure

### Modify Cluster Configuration

```bash
# Edit variables.tf or terraform.tfvars
nano terraform.tfvars

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Upgrade EKS Version

```bash
# Update cluster_version in variables.tf
variable "cluster_version" {
  default = "1.29"  # Update this
}

# Plan and apply
terraform plan
terraform apply
```

---

## 💰 Cost Optimization

### Estimated Monthly Costs (us-east-1)

| Resource | Configuration | Monthly Cost |
|----------|--------------|--------------|
| EKS Cluster | Control plane | $73 |
| EC2 Instances | 2x t3.medium | ~$60 |
| NAT Gateways | 2 gateways | ~$65 |
| EBS Volumes | 10GB gp3 | ~$1 |
| Load Balancer | NLB | ~$20 |
| ECR Storage | <5GB | ~$0.50 |
| Data Transfer | 100GB | ~$9 |
| **Total** | | **~$228/month** |

### Cost Reduction Strategies

1. **Use Single NAT Gateway** (saves ~$32/month)
   ```hcl
   # In vpc.tf
   single_nat_gateway = true
   ```

2. **Use Spot Instances** (saves ~60% on EC2)
   ```hcl
   # In eks.tf
   capacity_type = "SPOT"
   ```

3. **Reduce Node Count** for dev environments
   ```hcl
   node_desired_size = 1
   node_min_size     = 1
   ```

4. **Use Spot Instances** for development/staging (60% cost reduction)

---

## 🔍 Monitoring

### CloudWatch Container Insights

```bash
# Enable Container Insights (already enabled in Terraform)
# View in AWS Console: CloudWatch → Container Insights

# Or use AWS CLI
aws cloudwatch get-metric-statistics \
    --namespace ContainerInsights \
    --metric-name pod_cpu_utilization \
    --dimensions Name=ClusterName,Value=fictions-api \
    --statistics Average \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300
```

### Kubernetes Dashboard (Optional)

```bash
# Install Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create admin user
# (Follow official Kubernetes dashboard docs)

# Access dashboard
kubectl proxy
```

---

## 🧹 Cleanup

### Destroy Everything

**⚠️ Warning: This deletes all resources!**

```bash
# Destroy Kubernetes resources first
terraform destroy -target=module.helm_release.cluster_autoscaler
terraform destroy -target=module.helm_release.aws_load_balancer_controller

# Then destroy everything else
terraform destroy
```

**Confirm by typing** `yes`

This removes:
- EKS cluster and node group
- All Kubernetes resources
- VPC and networking
- Load balancers
- ECR repository
- Persistent volumes

---

## 🔒 Security Best Practices

1. **Use Private Subnets** for nodes (already configured)
2. **Enable Pod Security Standards**
   ```bash
   kubectl label namespace fictions-app \
       pod-security.kubernetes.io/enforce=restricted
   ```

3. **Use IAM Roles for Service Accounts (IRSA)**
   - Already configured for LB Controller and Cluster Autoscaler

4. **Rotate Secrets Regularly**
   ```bash
   # Update secrets
   kubectl create secret generic fictions-api-secrets \
       --from-literal=JWT_SECRET=new-secret \
       --dry-run=client -o yaml | kubectl apply -f -
   ```

5. **Enable Audit Logging**
   ```bash
   # In AWS Console: EKS → Cluster → Logging
   ```

---

## 📚 Additional Resources

- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)

---

## 🆘 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n fictions-app

# Describe pod for events
kubectl describe pod/POD_NAME -n fictions-app

# Check logs
kubectl logs POD_NAME -n fictions-app
```

### Load Balancer Not Created

```bash
# Check AWS LB Controller logs
kubectl logs -n kube-system \
    deployment/aws-load-balancer-controller

# Check service
kubectl describe svc fictions-api -n fictions-app
```

### Nodes Not Scaling

```bash
# Check Cluster Autoscaler logs
kubectl logs -n kube-system \
    deployment/cluster-autoscaler

# Check HPA
kubectl describe hpa fictions-api-hpa -n fictions-app
```

### Image Pull Errors

```bash
# Verify ECR permissions
aws ecr describe-repositories

# Check if image exists
aws ecr list-images \
    --repository-name fictions-api

# Re-authenticate to ECR
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin $ECR_URL
```

---

**Your EKS cluster is ready for production! 🚀**

For more details, see the main deployment guide: `../../IMPLEMENTATION_GUIDE.md`

