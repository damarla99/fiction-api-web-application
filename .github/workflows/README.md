# GitHub Actions CI/CD Workflows

This directory contains automated CI/CD pipelines for the Fictions API project.

## 📋 Workflows

### 1. `ci.yml` - CI/CD Pipeline

**Triggers:**
- Push to `main` branch (automatic)
- Manual workflow dispatch (with deploy/destroy options)

**Jobs:**

1. **Validate** - Code quality and validation
   - Python linting (flake8)
   - Code formatting check (black)
   - Terraform format validation
   - Terraform configuration validation

2. **Build** - Docker image creation
   - Build Docker image
   - Tag with timestamp and commit SHA
   - **Trivy security scan** (CRITICAL/HIGH vulnerabilities)
   - Upload scan results to GitHub Security
   - Push to Amazon ECR
   - Tag as `:latest`

3. **Deploy Infrastructure** - Terraform apply
   - Initialize Terraform
   - Plan infrastructure changes
   - Apply changes (create VPC, EKS, ECR, etc.)
   - Save outputs

4. **Deploy Kubernetes** - Application deployment
   - Configure kubectl
   - Update deployment with latest image
   - Apply Kubernetes manifests
   - Wait for rollout completion
   - Get LoadBalancer URL

5. **Manual Approval** - Destroy gate (manual trigger only)
   - Requires manual approval in GitHub UI
   - Environment: `production-destroy`

6. **Destroy Kubernetes** - Remove K8s resources
   - Delete all Kubernetes resources
   - Remove namespace
   - Wait for LoadBalancer deletion

7. **Destroy Infrastructure** - Terraform destroy
   - Destroy EKS cluster
   - Destroy VPC and networking
   - Remove all AWS resources

8. **Cleanup ECR** - Remove container images
   - Delete ECR repository
   - Clean up all Docker images

---

### 2. `pr.yml` - PR Quality Check Pipeline

**Triggers:**
- Pull requests to `main`

**Jobs:**

1. **Test**
   - Run Python tests (pytest)
   - Generate coverage reports
   - Code quality checks

2. **Security**
   - Safety check for vulnerable dependencies
   - Bandit security linting

3. **Docker**
   - Test Docker image builds
   - **Trivy vulnerability scanning** (fails on CRITICAL/HIGH)
   - Upload security scan results
   - Verify image integrity

---

## 🛡️ Security Scanning with Trivy

Both workflows include **Trivy** container image scanning for security vulnerabilities.

### What is Trivy?

Trivy is a comprehensive security scanner that detects:
- **OS vulnerabilities** (Alpine, Debian, Ubuntu, etc.)
- **Language-specific vulnerabilities** (Python packages, Node.js, etc.)
- **Misconfigurations**
- **Secrets in the image**

### Scanning Behavior

**In `ci.yml` (Production):**
- Scans for CRITICAL and HIGH severity vulnerabilities
- **Does NOT fail the build** (exit-code: 0)
- Reports findings but allows deployment
- Uploads results to GitHub Security tab

**In `pr.yml` (Pull Requests):**
- Scans for CRITICAL and HIGH severity vulnerabilities
- **FAILS the build** if found (exit-code: 1)
- Prevents merging vulnerable code
- Uploads results to GitHub Security tab

### Viewing Scan Results

**Option 1: GitHub Security Tab**
1. Go to your repository
2. Click **Security** → **Code scanning**
3. View Trivy findings with details and remediation

**Option 2: Workflow Logs**
1. Go to **Actions** tab
2. Click on the workflow run
3. Expand the "Run Trivy vulnerability scanner" step
4. View table format results

### Example Output

```
fictions-api:test (alpine 3.19)
===================================
Total: 2 (CRITICAL: 1, HIGH: 1)

┌───────────────┬──────────────┬──────────┬───────────────────┬───────────────────┬────────────────────────────────┐
│   Library     │ Vulnerability│ Severity │ Installed Version │ Fixed Version     │ Title                          │
├───────────────┼──────────────┼──────────┼───────────────────┼───────────────────┼────────────────────────────────┤
│ libssl3       │ CVE-2024-1234│ CRITICAL │ 3.1.4-r0          │ 3.1.4-r1          │ openssl: critical vulnerability│
│ libcrypto3    │ CVE-2024-5678│ HIGH     │ 3.1.4-r0          │ 3.1.4-r1          │ openssl: high severity issue   │
└───────────────┴──────────────┴──────────┴───────────────────┴───────────────────┴────────────────────────────────┘
```

### Remediation

When vulnerabilities are found:
1. Check if a newer base image is available
2. Update package versions in `requirements.txt`
3. Rebuild the Docker image
4. Re-run the scan

---

## 🔐 Required Secrets

Add these secrets in GitHub repository settings (Settings → Secrets and variables → Actions):

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key for deployment | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |

### How to Create AWS IAM User for CI/CD:

```bash
# 1. Create IAM user
aws iam create-user --user-name github-actions-deploy

# 2. Create access key
aws iam create-access-key --user-name github-actions-deploy

# 3. Attach policies (adjust as needed)
aws iam attach-user-policy \
  --user-name github-actions-deploy \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# For production, use least-privilege policies instead
```

---

## 🚀 Usage

### Deploy to AWS EKS

**Automatic Deployment (Push to main):**
```bash
git add .
git commit -m "Deploy new feature"
git push origin main
```

**Manual Deployment:**
1. Go to GitHub Actions tab
2. Select "CI/CD Pipeline" workflow
3. Click "Run workflow"
4. Select branch: `main`
5. Action: `deploy`
6. Click "Run workflow"

### Destroy Infrastructure

**⚠️ Warning: This will delete ALL resources and data!**

1. Go to GitHub Actions tab
2. Select "CI/CD Pipeline" workflow
3. Click "Run workflow"
4. Select branch: `main`
5. Action: `destroy`
6. Click "Run workflow"
7. **Approve the destruction** in the workflow run page

---

## 📊 Workflow Visualization

```
┌─────────────┐
│   Push to   │
│    main     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Validate   │ ◄── Lint, Format, Terraform validate
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Build    │ ◄── Docker build
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Trivy    │ ◄── 🛡️ Security scan (CRITICAL/HIGH)
│    Scan     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Push to ECR  │ ◄── Push Docker image
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Deploy Infra │ ◄── Terraform apply (EKS, VPC, etc.)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Deploy K8s │ ◄── kubectl apply (MongoDB, API, LB)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   SUCCESS   │ 🎉
└─────────────┘


DESTROY PATH (Manual):
┌─────────────┐
│   Manual    │
│   Trigger   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Approval  │ ◄── ⚠️ Manual approval required!
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Destroy K8s │ ◄── Delete Kubernetes resources
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Destroy Infra│ ◄── Terraform destroy
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Cleanup ECR │ ◄── Remove container images
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   DELETED   │ ✅
└─────────────┘
```

---

## 🔧 Environment Setup

### GitHub Environment for Destroy Protection

1. Go to repository Settings → Environments
2. Create environment: `production-destroy`
3. Add protection rules:
   - ✅ Required reviewers (add yourself)
   - ✅ Wait timer: 0 minutes
4. Save protection rules

This ensures manual approval before destroying infrastructure.

---

## 📝 Customization

### Modify Terraform Variables

Edit `infrastructure/terraform-eks/variables.tf` or pass via workflow:

```yaml
- name: Terraform Apply
  run: |
    terraform apply \
      -var="aws_region=us-west-2" \
      -var="instance_type=t3.large" \
      -auto-approve tfplan
```

### Change Deployment Region

Update in `.github/workflows/ci.yml`:

```yaml
env:
  AWS_REGION: us-west-2  # Change this
```

### Add Notifications

Add to the end of `deploy-k8s` job:

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🐛 Troubleshooting

### Issue: Terraform State Lock

**Error:** `Error acquiring the state lock`

**Solution:**
```bash
# Force unlock (get lock ID from error message)
cd infrastructure/terraform-eks
terraform force-unlock <LOCK_ID>
```

### Issue: ECR Repository Not Found

**Error:** `RepositoryNotFoundException`

**Solution:**
- Ensure Terraform has created ECR repository
- Check repository name matches: `fictions-api-development`
- Verify AWS region is correct

### Issue: Kubectl Connection Failed

**Error:** `error: You must be logged in to the server`

**Solution:**
- EKS cluster may still be provisioning (wait 5-10 minutes)
- Check AWS credentials are valid
- Verify cluster name matches Terraform output

### Issue: LoadBalancer Pending

**Error:** LoadBalancer URL is empty or pending

**Solution:**
- Wait longer (can take 3-5 minutes)
- Check AWS Load Balancer Controller is installed
- Verify security groups allow traffic

---

## 📊 Cost Awareness

**Deployment Duration:** ~20-25 minutes  
**Destruction Duration:** ~15-20 minutes  
**Cost per Hour:** ~$0.26/hour (~$186/month if left running)

**💡 Tip:** Run destroy workflow when not actively using to save costs!

---

## ✅ Best Practices

1. **Always test locally** before pushing to `main`
2. **Use pull requests** for code review
3. **Run destroy** when demos are complete
4. **Monitor AWS costs** in AWS Cost Explorer
5. **Review workflow logs** for any warnings
6. **Keep secrets secure** - never commit them

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes CI/CD](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/)

---

**Questions?** Check workflow logs in the Actions tab or review Terraform/kubectl output.

