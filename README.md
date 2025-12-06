# Fictions API - Production-Ready Containerized Web Application

A full-stack containerized web application demonstrating modern DevOps practices, cloud deployment, and scalable architecture. Built with Python/FastAPI, deployed on AWS EKS with complete infrastructure as code.

> **Portfolio Project** - Showcasing end-to-end development and deployment capabilities

[![Python](https://img.shields.io/badge/Python-3.11-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104-green.svg)](https://fastapi.tiangolo.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-blue.svg)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EKS-orange.svg)](https://aws.amazon.com/eks/)

---

## 🎯 Quick Summary

**What is this?** A production-ready RESTful API for managing fictional stories with user authentication.

**How to run it locally?**
1. Install Docker Desktop
2. Run `./dev-tools/start-local.sh`
3. Open http://localhost:3000/api/docs

**How to test it?**
- Use Swagger UI (click & test in browser)
- Or run `./dev-tools/test-api.sh`

That's it! See [Quick Start](#-quick-start---local-development) below for details.

---

## 📋 Table of Contents

- [Quick Summary](#-quick-summary)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Prerequisites](#-prerequisites)
- [Quick Start - Local Development](#-quick-start---local-development)
- [Cloud Deployment (AWS EKS)](#-cloud-deployment-aws-eks)
- [Testing Locally](#-testing-locally)
- [API Documentation](#-api-documentation)
- [Project Structure](#-project-structure)
- [Monitoring & Operations](#-monitoring--operations)
- [Security Features](#-security-features)
- [Cost Estimation](#-cost-estimation-aws)
- [Key Highlights](#-key-highlights-for-hiring-team)

---

## 🚀 Features

### Application Features
- ✅ **RESTful API** with CRUD operations for fictions management
- ✅ **JWT Authentication** with secure password hashing (bcrypt)
- ✅ **Rate Limiting** (SlowAPI) to prevent abuse
- ✅ **MongoDB** integration with async driver (Motor)
- ✅ **Input Validation** with Pydantic models
- ✅ **Auto-generated API Documentation** (Swagger UI)
- ✅ **Health Check** endpoints for monitoring
- ✅ **CORS** support for cross-origin requests

### DevOps Features
- ✅ **Docker** containerization with multi-stage builds
- ✅ **Kubernetes** deployment with Kustomize
- ✅ **AWS EKS** (Elastic Kubernetes Service) deployment
- ✅ **Infrastructure as Code** with Terraform
- ✅ **Auto-scaling** (Horizontal Pod Autoscaler + Cluster Autoscaler)
- ✅ **Load Balancing** (AWS Load Balancer Controller)
- ✅ **Secrets Management** (Kubernetes Secrets)
- ✅ **Remote State** management (S3 with native locking - Terraform 1.10+)
- ✅ **CI/CD Ready** structure
- ✅ **Production-grade** security and best practices

---

## 🛠️ Tech Stack

### Backend
- **Language:** Python 3.11+
- **Framework:** FastAPI (async web framework)
- **Database:** MongoDB 7.0
- **ORM/ODM:** Motor (async MongoDB driver)
- **Authentication:** JWT (python-jose) + bcrypt
- **Validation:** Pydantic
- **Rate Limiting:** SlowAPI

### DevOps & Infrastructure
- **Containerization:** Docker, Docker Compose
- **Orchestration:** Kubernetes (Kustomize)
- **Cloud Platform:** AWS
  - EKS (Elastic Kubernetes Service)
  - ECR (Elastic Container Registry)
  - VPC (Virtual Private Cloud)
  - ALB/NLB (Application/Network Load Balancer)
- **Infrastructure as Code:** Terraform
- **Configuration Management:** Kubernetes ConfigMaps & Secrets
- **Monitoring:** Metrics Server, CloudWatch

---

## 🏗️ Architecture

### AWS Infrastructure Diagram

```mermaid
graph TB
    subgraph Internet
        Users[End Users/API Clients]
    end
    
    subgraph AWS["AWS Cloud (us-east-1)"]
        IGW[Internet Gateway]
        
        subgraph VPC["VPC (10.0.0.0/16)"]
            subgraph PublicSubnets["Public Subnets (10.0.1-2.0/24)<br/>2 AZs"]
                NAT[NAT Gateway<br/>Elastic IP<br/>Outbound Only]
                NLB[Network Load Balancer<br/>Public Endpoint]
            end
            
            subgraph PrivateSubnets["Private Subnets (10.0.11-12.0/24)<br/>2 AZs"]
                subgraph EKS["EKS Cluster (v1.31)"]
                    subgraph WorkerNodes["Worker Nodes (EC2)<br/>1-2 t3.small<br/>No Public IPs"]
                        subgraph Pods["Application Pods"]
                            API[Fictions API<br/>FastAPI<br/>Auto-scaling 1-4 replicas]
                            DB[MongoDB<br/>StatefulSet<br/>Persistent Volume]
                        end
                    end
                end
            end
        end
        
        ECR[ECR<br/>Container Registry]
        CloudWatch[CloudWatch<br/>Logs & Metrics]
        IAM[IAM Roles<br/>Permissions]
        EBS[EBS Volumes<br/>Persistent Storage]
    end
    
    Users -->|HTTPS| IGW
    IGW --> NLB
    NLB -->|Port 3000| API
    API --> DB
    WorkerNodes -.->|OS Updates<br/>Docker Pulls| NAT
    NAT --> IGW
    WorkerNodes --> ECR
    WorkerNodes --> CloudWatch
    API -.->|Uses| IAM
    DB -.->|Uses| EBS
    
    style Users fill:#e1f5ff
    style IGW fill:#ff9900
    style NAT fill:#ff9900
    style NLB fill:#ff9900
    style EKS fill:#326ce5
    style API fill:#009688
    style DB fill:#4caf50
    style ECR fill:#ff9900
    style CloudWatch fill:#ff9900
    style IAM fill:#ff9900
    style EBS fill:#ff9900
```

### Network Architecture Details

- **VPC:** 10.0.0.0/16 across 2 Availability Zones (High Availability)
- **Public Subnets:** 10.0.1.0/24, 10.0.2.0/24
  - NAT Gateway (Elastic IP for outbound traffic)
  - Network Load Balancer (Public endpoint for users)
- **Private Subnets:** 10.0.11.0/24, 10.0.12.0/24
  - EKS worker nodes (no public IPs - secure)
  - All application pods
- **Internet Gateway:** Bi-directional internet access for public subnets
- **NAT Gateway:** Outbound-only internet for private subnets (OS updates, Docker pulls)

### Traffic Flow

**Inbound (User → API):**
```
End User → Internet Gateway → Network Load Balancer (Public Subnet) 
→ EKS Worker Nodes (Private Subnet) → FastAPI Pods
```

**Outbound (Nodes → Internet):**
```
EKS Worker Nodes (Private Subnet) → NAT Gateway (Public Subnet) 
→ Internet Gateway → Internet
```

### Security Architecture

**1. Network Isolation:**
- ✅ Private subnets for all worker nodes (no public IPs)
- ✅ Security Groups for fine-grained access control
- ✅ Network ACLs at subnet level

**2. Security Groups:**
- **EKS Control Plane SG:** Protects Kubernetes API server
- **Worker Node SG:** Controls access to EC2 instances
  - Port 443: HTTPS from control plane
  - Port 10250: Kubelet API from control plane
  - Port 53: DNS within VPC
  - Port 3000: FastAPI from NLB
  - Pod-to-pod: All traffic within same SG
- **NLB:** No SG (Layer 4 pass-through, security at worker node level)

**3. IAM Roles (Least Privilege):**
- EKS Cluster Role
- Worker Node Role (EC2, ECR, CloudWatch)
- Load Balancer Controller Role
- Cluster Autoscaler Role

**4. Application Security:**
- ✅ JWT Authentication
- ✅ Rate Limiting (SlowAPI)
- ✅ Password Hashing (bcrypt)
- ✅ Input Validation (Pydantic)
- ✅ Kubernetes Secrets for credentials

---

## 🔄 CI/CD Pipeline

Automated deployment pipeline using GitHub Actions.

### 🚀 Features

- ✅ **Automatic Deployment** - Push to `main` triggers full deployment
- ✅ **Code Validation** - Automated linting and formatting checks
- ✅ **Docker Build** - Automatic image build and push to ECR
- ✅ **Infrastructure Deploy** - Terraform provisions AWS resources
- ✅ **Kubernetes Deploy** - Automated kubectl deployment
- ✅ **Manual Approval** - Required approval for destroy operations
- ✅ **Complete Cleanup** - Destroys all resources to avoid costs

### 📊 Deployment Flow

```mermaid
graph LR
    A[Push to main] --> B[Validate Code]
    B --> C[Build Docker]
    C --> D[Deploy Infrastructure]
    D --> E[Deploy Kubernetes]
    E --> F[Get API URL]
    F --> G[🎉 Live!]
    
    H[Manual Trigger] --> I[Approval Required]
    I --> J[Destroy K8s]
    J --> K[Destroy Infra]
    K --> L[Cleanup ECR]
    L --> M[✅ Deleted]
```

### 🔐 Setup GitHub Secrets

Add these in **Settings → Secrets and variables → Actions**:

| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |

### 🎯 Usage

**Deploy:**
```bash
git add .
git commit -m "Deploy feature"
git push origin main
# Automatic deployment starts!
```

**Destroy (Save costs):**
1. Go to GitHub Actions tab
2. Run "Deploy to AWS EKS" workflow
3. Select action: `destroy`
4. Approve the destruction
5. All resources deleted ✅

**View Details:** See [.github/workflows/README.md](.github/workflows/README.md)

---

## 📦 Prerequisites

<details>
<summary><b>Click to see prerequisites</b></summary>

### For Local Development

| Tool | Version | Installation |
|------|---------|--------------|
| **Docker Desktop** | Latest | [Download](https://www.docker.com/products/docker-desktop/) |
| **Git** | Latest | [Download](https://git-scm.com/downloads) |

### For AWS EKS Deployment

| Tool | Version | Installation |
|------|---------|--------------|
| **AWS CLI** | v2 | [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **kubectl** | 1.31+ | [Install Guide](https://kubernetes.io/docs/tasks/tools/) |
| **Terraform** | 1.10+ | [Download](https://www.terraform.io/downloads) |

**AWS Account Setup:**
```bash
# Configure credentials
aws configure

# Verify access
aws sts get-caller-identity
```

</details>

---

## 🚀 Quick Start - Local Development

> ⏱️ **5 minutes** | 💰 **Free** | 🎯 **Perfect for testing and development**

### Three Simple Steps

#### **1️⃣ Clone and Navigate**

```bash
git clone <your-repo-url>
cd webapp-devops
```

#### **2️⃣ Start Everything**

```bash
./dev-tools/start-local.sh
```

This single command will:
- ✅ Check Docker is running
- ✅ Start MongoDB database
- ✅ Start FastAPI application
- ✅ Run health checks
- ✅ Show you what's running

#### **3️⃣ Open Swagger UI (Interactive Testing)**

Open in your browser: **http://localhost:3000/api/docs**

You'll see an interactive interface where you can test all API endpoints with a single click!

### ✅ That's It!

Your API is now running locally. Jump to [Testing](#-testing-locally) to try it out.

### 🛑 When Done

```bash
./dev-tools/stop-local.sh
```

---

## 🌐 Cloud Deployment (AWS EKS)

> ⏱️ **~25 minutes** | 💰 **~$120-150/month** | 🎯 **For production demos**

<details>
<summary><b>Click to expand AWS deployment steps</b></summary>

---

### AWS EKS Deployment Steps

#### **Step 1: Setup Terraform Backend** ⏱️ 2 minutes (Optional but Recommended)

This stores your Terraform state in AWS (enables team collaboration and state locking).

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket fictions-api-terraform-state-development \
  --region us-east-1

# Enable versioning (keeps history)
aws s3api put-bucket-versioning \
  --bucket fictions-api-terraform-state-development \
  --versioning-configuration Status=Enabled

# Enable encryption (security)
aws s3api put-bucket-encryption \
  --bucket fictions-api-terraform-state-development \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Note: Terraform 1.10+ uses native S3 state locking (use_lockfile = true)
# No DynamoDB table needed!

```

#### **Step 2: Deploy Infrastructure with Terraform** ⏱️ 15-20 minutes

This creates all AWS resources (VPC, EKS cluster, load balancer, etc.).

```bash
cd infrastructure/terraform-eks

# Initialize Terraform (downloads providers)
terraform init

# Preview what will be created (optional but recommended)
terraform plan

# Deploy infrastructure (this takes ~15-20 minutes)
terraform apply
# Type 'yes' when prompted

# Save outputs for later use
terraform output > outputs.txt
```

**☕ Take a coffee break!** This step takes 15-20 minutes while AWS provisions:
- ✅ VPC with public/private subnets (2 Availability Zones)
- ✅ Internet Gateway & NAT Gateway
- ✅ EKS Cluster v1.31 (Kubernetes control plane)
- ✅ EKS Node Groups (1-2 t3.small instances)
- ✅ ECR Repository (for Docker images)
- ✅ IAM Roles & Security Groups
- ✅ Load Balancer Controller, Metrics Server, Autoscaler

#### **Step 3: Configure kubectl** ⏱️ 1 minute

Connect your local kubectl to the EKS cluster.

```bash
# Configure kubectl to access EKS cluster
aws eks update-kubeconfig \
  --region us-east-1 \
  --name fictions-api-development

# Verify connection
kubectl get nodes
# Expected: 1-2 nodes with STATUS "Ready"

# Check system pods
kubectl get pods -n kube-system
# Expected: All pods showing "Running" status
```

✅ **Success indicator:** You should see nodes in "Ready" state.

#### **Step 4: Build and Push Docker Image** ⏱️ 3-5 minutes

Build your application image and push it to AWS ECR.

**Option A: Automated Script (Recommended)**
```bash
cd ../../ops-tools
./build-and-push.sh
```

**Option B: Manual Steps**
```bash
cd ../../ops-tools

# 1. Get ECR URL from Terraform
ECR_URL=$(cd ../infrastructure/terraform-eks && terraform output -raw ecr_repository_url)
echo "ECR URL: $ECR_URL"

# 2. Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $ECR_URL

# 3. Build Docker image
cd ..
docker build -t fictions-api:latest .

# 4. Tag image for ECR
docker tag fictions-api:latest $ECR_URL:latest

# 5. Push to ECR
docker push $ECR_URL:latest
```

✅ **Success indicator:** You should see "Pushed" confirmation for each layer.

#### **Step 5: Update Kubernetes Deployment** ⏱️ 30 seconds

Update the deployment file with your ECR image URL.

```bash
cd ops-tools

# Automatically updates kubernetes/deployment.yaml with ECR URL
./update-k8s-image.sh
```

✅ **Success indicator:** Script confirms "Updated deployment.yaml"

#### **Step 6: Deploy Application to Kubernetes** ⏱️ 2-3 minutes

Deploy MongoDB and the FastAPI application to EKS.

**Option A: Automated Script (Recommended)**
```bash
./deploy-kubectl.sh
```

**Option B: Manual Deployment**
```bash
# Deploy all Kubernetes manifests
kubectl apply -f ../kubernetes/

# Watch pods start up (Ctrl+C to exit)
kubectl get pods -n fictions-app -w
```

✅ **Success indicator:** All pods show STATUS "Running" (may take 2-3 minutes)

#### **Step 7: Get API URL and Verify** ⏱️ 2-3 minutes

Get your public API URL from the load balancer.

```bash
# Get LoadBalancer URL (may take 2-3 minutes to provision)
kubectl get svc fictions-api -n fictions-app

# Export the URL for easy access
export API_URL=$(kubectl get svc fictions-api -n fictions-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "🎉 API URL: http://$API_URL"
echo "📖 API Docs: http://$API_URL/api/docs"

# Test health endpoint
curl http://$API_URL/health
# Expected: {"status":"ok","app":"Fictions API",...}
```

**🎉 Deployment Complete!** Your API is now live on AWS EKS.

**📖 Next Steps:**
- See [Testing](#-testing) section for how to test all endpoints
- Visit `http://<LOAD_BALANCER_URL>/api/docs` for interactive Swagger UI
- Check [Monitoring](#-monitoring--operations) for logs and status

**💰 Important:** Remember to run `terraform destroy` when done to avoid AWS charges!

#### **Cleanup (To avoid AWS charges)**

```bash
# Delete Kubernetes resources
kubectl delete -f kubernetes/

# Destroy infrastructure
cd infrastructure/terraform-eks
terraform destroy
# Type 'yes' when prompted

# Delete S3 bucket (if created)
aws s3 rb s3://fictions-api-terraform-state-development --force
```

</details>

---

## 📖 API Documentation

### Endpoints Overview

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/health` | GET | Health check | No |
| `/api/docs` | GET | Swagger UI documentation | No |
| `/api/auth/register` | POST | Register new user | No |
| `/api/auth/login` | POST | Login and get JWT token | No |
| `/api/fictions/` | GET | List all fictions | Yes |
| `/api/fictions/` | POST | Create new fiction | Yes |
| `/api/fictions/{id}` | GET | Get fiction by ID | Yes |
| `/api/fictions/{id}` | PUT | Update fiction | Yes |
| `/api/fictions/{id}` | DELETE | Delete fiction | Yes |

### Interactive Documentation

When the API is running, visit:
- **Swagger UI:** `http://localhost:3000/api/docs` (local) or `http://<LOAD_BALANCER_URL>/api/docs` (AWS)
  - Interactive API documentation with "Try it out" functionality
  - Test all endpoints directly from your browser

### API Field Reference

> **⚠️ Important:** Pay close attention to field names - common mistakes include using `name` instead of `username`, `access_token` instead of `token`, or `summary` instead of `description`.

#### User Registration (`POST /api/auth/register`)

**Required Fields:**
```json
{
  "username": "string",    // 3-30 characters, alphanumeric + underscore/hyphen
  "email": "string",       // Valid email format (e.g., user@example.com)
  "password": "string"     // Minimum 6 characters
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",  // JWT token for authentication
  "token_type": "bearer",
  "user": {
    "_id": "...",
    "username": "...",
    "email": "...",
    "created_at": "..."
  }
}
```

#### User Login (`POST /api/auth/login`)

**Required Fields:**
```json
{
  "email": "string",      // Registered email address
  "password": "string"    // User's password
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",  // Use this token in Authorization header
  "token_type": "bearer",
  "user": { ... }
}
```

#### Create Fiction (`POST /api/fictions/`)

**Required Fields:**
```json
{
  "title": "string",        // 1-200 characters
  "author": "string",       // 1-100 characters
  "genre": "string",        // Must be lowercase: fantasy, sci-fi, mystery, romance, 
                            // thriller, horror, adventure, drama, comedy, other
  "description": "string",  // ⚠️ NOT "summary"! Max 500 characters
  "content": "string"       // Minimum 1 character
}
```

**Valid Genres:**
- `fantasy`, `sci-fi`, `mystery`, `romance`, `thriller`, `horror`, `adventure`, `drama`, `comedy`, `other`

**Authorization Required:**
- Add header: `Authorization: Bearer <your-token-here>`

#### Update Fiction (`PUT /api/fictions/{id}`)

Same fields as Create Fiction (all fields required).

#### Common Mistakes to Avoid

| ❌ Wrong Field | ✅ Correct Field | Endpoint |
|----------------|------------------|----------|
| `"name"` | `"username"` | `/api/auth/register` |
| `"access_token"` | `"token"` | Response from login/register |
| `"summary"` | `"description"` | `/api/fictions/` |
| `"Fantasy"` | `"fantasy"` | `/api/fictions/` (genre must be lowercase) |
| `"Sci-Fi"` | `"sci-fi"` | `/api/fictions/` (genre must be lowercase) |

### Example Usage

For detailed examples and interactive testing, use the **Swagger UI** at `/api/docs` endpoint.

---

## 📁 Project Structure

```
webapp-devops/
├── src/                          # Python application source code
│   ├── main.py                   # FastAPI application entry point
│   ├── config/                   # Configuration (settings, database)
│   ├── models/                   # Pydantic models (User, Fiction)
│   ├── routers/                  # API route handlers
│   ├── middleware/               # Auth, rate limiting
│   └── utils/                    # Utility functions (password hashing)
│
├── infrastructure/               # Infrastructure as Code
│   └── terraform-eks/           # Terraform for AWS EKS
│       ├── backend.tf           # Terraform backend configuration
│       ├── provider.tf          # AWS, Kubernetes, Helm providers
│       ├── main.tf              # Data sources
│       ├── vpc.tf               # VPC, subnets, gateways
│       ├── eks.tf               # EKS cluster
│       ├── ecr.tf               # Container registry
│       ├── addons.tf            # EKS add-ons (Load Balancer, Metrics, Autoscaler)
│       ├── secrets.tf           # Secrets management
│       ├── variables.tf         # Input variables
│       └── outputs.tf           # Output values
│
├── kubernetes/                   # Kubernetes manifests
│   ├── namespace.yaml           # Namespace definition
│   ├── configmap.yaml           # Application configuration
│   ├── secrets.yaml             # Sensitive data (JWT, MongoDB URI)
│   ├── mongodb.yaml             # MongoDB StatefulSet + Service
│   ├── deployment.yaml          # API Deployment
│   ├── service.yaml             # LoadBalancer Service
│   ├── hpa.yaml                 # Horizontal Pod Autoscaler
│   └── kustomization.yaml       # Kustomize configuration
│
├── ops-tools/                    # DevOps automation scripts
│   ├── build-and-push.sh        # Build & push Docker image to ECR
│   ├── update-k8s-image.sh      # Update deployment with ECR URL
│   └── deploy-kubectl.sh        # Deploy application to Kubernetes
│
├── dev-tools/                    # Development tools
│   ├── start-local.sh           # Start local Docker environment
│   ├── stop-local.sh            # Stop local environment
│   └── test-api.sh              # Test API endpoints
│
├── Dockerfile                    # Multi-stage Docker build
├── docker-compose.yml            # Local development setup
├── requirements.txt              # Python dependencies
└── README.md                     # This file - Complete documentation
```

---

## 🧪 Testing Locally

After starting the application (`./dev-tools/start-local.sh`), choose your preferred testing method:

### 🎯 Option 1: Automated Test Script (Easiest)

```bash
./dev-tools/test-api.sh
```

This script automatically tests:
- ✅ Health check
- ✅ User registration
- ✅ User login
- ✅ Fiction creation
- ✅ Fiction retrieval

### 🌐 Option 2: Swagger UI (Most Interactive)

1. Open in browser: **http://localhost:3000/api/docs**
2. Click any endpoint (e.g., `POST /api/auth/register`)
3. Click **"Try it out"**
4. Fill in the example values
5. Click **"Execute"**
6. See the response below!

> 💡 **Tip:** Swagger UI is the easiest way to explore and test all endpoints interactively.

### ⌨️ Option 3: Manual Testing with curl

<details>
<summary><b>Click to see curl examples</b></summary>

```bash
# 1. Check if API is running
curl http://localhost:3000/health

# 2. Register a new user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "test123"
  }'

# 3. Login and get token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'
# Copy the "token" value from the response

# 4. Use token to create a fiction
export TOKEN="paste-your-token-here"

curl -X POST http://localhost:3000/api/fictions/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "My Test Story",
    "author": "Test Author",
    "genre": "fantasy",
    "description": "A test story",
    "content": "Once upon a time..."
  }'

# 5. Get all fictions
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/fictions/
```

</details>

---

## 🌐 Testing on AWS

<details>
<summary><b>Click to see AWS testing instructions</b></summary>

**Get your API URL first:**
```bash
export API_URL=$(kubectl get svc fictions-api -n fictions-app \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "API URL: http://$API_URL"
```

**Option 1: Interactive Swagger UI (Recommended)**
```bash
# Open in browser
echo "http://$API_URL/api/docs"
# Visit the URL and test interactively
```

**Option 2: Manual curl Commands**
```bash
# 1. Health check
curl http://$API_URL/health

# 2. Register a user
curl -X POST http://$API_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "demouser",
    "email": "demo@example.com",
    "password": "demo123"
  }'

# 3. Login to get token
curl -X POST http://$API_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "demo123"
  }'

# 4. Copy the "token" from response
export TOKEN="<paste-your-token-here>"

# 5. Create a fiction
curl -X POST http://$API_URL/api/fictions/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Cloud Fiction",
    "author": "AWS Author",
    "genre": "sci-fi",
    "description": "A story in the cloud",
    "content": "In the AWS cloud..."
  }'

# 6. Get all fictions
curl -H "Authorization: Bearer $TOKEN" \
  http://$API_URL/api/fictions/
```

**Common Test Scenarios:**
- ✅ Health Check: Verify API is running
- ✅ Register: Create a new user account
- ✅ Login: Get JWT token for authentication
- ✅ Create Fiction: Test authenticated POST request
- ✅ List Fictions: Test authenticated GET request
- ✅ Update Fiction: Test PUT request
- ✅ Delete Fiction: Test DELETE request

</details>

---

## 📊 Monitoring & Operations

### View Logs

```bash
# Local
docker-compose logs -f api

# AWS EKS
kubectl logs -n fictions-app deployment/fictions-api -f
kubectl logs -n fictions-app statefulset/mongodb -f
```

### Check Status

```bash
# Local
docker-compose ps

# AWS EKS
kubectl get all -n fictions-app
kubectl get pods -n fictions-app
kubectl get svc -n fictions-app
kubectl get hpa -n fictions-app
```

### Scaling

```bash
# Manual scaling
kubectl scale deployment fictions-api -n fictions-app --replicas=3

# Auto-scaling (HPA already configured)
kubectl get hpa -n fictions-app
# Automatically scales between 1-4 replicas based on CPU/memory
```

### Update Deployment

```bash
# After code changes
cd ops-tools
./build-and-push.sh              # Build new image
kubectl rollout restart deployment/fictions-api -n fictions-app
kubectl rollout status deployment/fictions-api -n fictions-app
```

---


## 🔐 Security Features

### Application Security
- ✅ **JWT-based authentication** with secure token handling
- ✅ **Password hashing** with bcrypt (salt rounds)
- ✅ **Rate limiting** (100 requests per 15 minutes via SlowAPI)
- ✅ **Input validation** with Pydantic models
- ✅ **CORS** configuration for cross-origin requests
- ✅ **MongoDB authentication** ready (credentials in Kubernetes Secrets)

### Infrastructure Security
- ✅ **Private Subnets** - All EKS worker nodes have no public IPs
- ✅ **NAT Gateway** - Outbound-only internet access for updates (no Security Group needed - AWS managed)
- ✅ **Security Groups** - Fine-grained network access control:
  
  **1. EKS Control Plane Security Group:**
  - Inbound: HTTPS (443) from worker nodes
  - Outbound: All traffic to worker nodes
  - Purpose: Protects Kubernetes API server
  
  **2. Worker Node Security Group:**
  - Inbound: 
    - Port 443 (HTTPS) from control plane
    - Port 10250 (Kubelet API) from control plane
    - Port 53 (DNS) within VPC
    - Port 3000 (FastAPI) from VPC CIDR (for NLB)
    - All traffic from same security group (pod-to-pod communication)
  - Outbound: All traffic (via NAT Gateway)
  - Purpose: Protects EC2 instances running Kubernetes pods
  
  **3. NLB (Network Load Balancer):**
  - **No Security Group** (Layer 4 pass-through)
  - Traffic passes directly to Worker Node SG
  - Security enforced at worker node level
  - Why: NLB operates at TCP layer, not application layer

- ✅ **Network ACLs** - Subnet-level firewall (default: allow all, can be restricted)
- ✅ **Secrets Management** - Kubernetes Secrets for JWT_SECRET, MongoDB URI
- ✅ **IAM Roles** - Least privilege access for:
  - EKS cluster operations
  - Worker nodes (EC2, ECR, CloudWatch access)
  - Load Balancer Controller (create/manage load balancers)
  - Cluster Autoscaler (modify Auto Scaling Groups)
- ✅ **Encryption** - EBS volumes encrypted at rest (AES-256)
- ✅ **HTTPS ready** - NLB supports SSL/TLS termination with ACM certificates
- ✅ **VPC Isolation** - Complete network segregation from other workloads
- ✅ **CloudWatch Logs** - Audit trail and monitoring (control plane + application logs)

---

## 💰 Cost Estimation (AWS)

**Deploy-on-Demand (Recommended for Portfolio):**
- **Cost per demo:** ~$3-5 (2-3 hours of runtime)
- **Monthly cost (4 demos):** ~$12-20
- **Savings vs always-on:** 85-90%

**Always-On Development (~$120-150/month):**
- EKS Cluster: $73/month (control plane)
- EC2 Instances: 1-2 t3.small (~$30-60/month)
- NAT Gateway: ~$32/month
- Load Balancer: ~$16/month
- ECR Storage: <$1/month
- Data Transfer: Variable

**💡 Recommended Strategy:**
1. Keep infrastructure **destroyed** by default
2. Deploy via GitHub Actions before interviews/demos (~25 minutes)
3. Show your working application
4. Destroy after demo (~10 minutes)

This approach saves **$100+/month** while keeping full production capabilities!

---

## 🎯 Key Highlights for Hiring Team

### What This Project Demonstrates

1. **Full-Stack Development**
   - Modern async Python/FastAPI backend
   - RESTful API design
   - Database integration (MongoDB)
   - Authentication & authorization

2. **DevOps Excellence**
   - Infrastructure as Code (Terraform)
   - Container orchestration (Kubernetes)
   - Cloud deployment (AWS EKS)
   - CI/CD ready architecture

3. **Best Practices**
   - Clean code architecture
   - Comprehensive documentation
   - Security considerations
   - Scalability patterns
   - Monitoring and observability

4. **Production-Ready**
   - Auto-scaling capabilities
   - High availability setup
   - Load balancing
   - Health checks and graceful degradation
   - Secrets management

### Technologies Used

**Backend:** Python, FastAPI, MongoDB, Pydantic, JWT, bcrypt  
**DevOps:** Docker, Kubernetes, Terraform, AWS (EKS, ECR, VPC)  
**Tools:** kubectl, Helm, Kustomize, AWS CLI

---

---

**Ready to deploy?** Start with [Quick Start - Local Development](#-quick-start---local-development) above! 🚀
