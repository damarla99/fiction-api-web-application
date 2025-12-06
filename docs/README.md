# Documentation Assets

This folder contains screenshots and images used in the main README.

## Required Screenshots

### 1. `ci-deploy-workflow.png` - Deploy Pipeline

**How to capture this screenshot:**

1. Go to your GitHub repository
2. Click on the **"Actions"** tab
3. Click on a successful **"deploy"** workflow run
4. You'll see the workflow graph showing deployment jobs:
   - ✅ validate
   - ✅ build-backend
   - ✅ build-frontend
   - ✅ deploy-infrastructure
   - ✅ deploy-k8s
5. Take a screenshot of this workflow graph
6. Save it as `ci-deploy-workflow.png` in this `docs/` folder

**What to capture:**
- All job boxes with green checkmarks (✓)
- Job names clearly visible
- Workflow execution flow from left to right
- Deployment success message/summary at the bottom (optional)

---

### 2. `ci-destroy-workflow.png` - Destroy Pipeline

**How to capture this screenshot:**

1. Go to your GitHub repository
2. Click on the **"Actions"** tab
3. Click on a successful **"destroy"** workflow run
4. You'll see the workflow graph showing cleanup jobs:
   - ✅ approval-destroy (manual approval step)
   - ✅ destroy-k8s
   - ✅ destroy-infra
   - ✅ cleanup-ecr (optional)
5. Take a screenshot of this workflow graph
6. Save it as `ci-destroy-workflow.png` in this `docs/` folder

**What to capture:**
- Manual approval step (shows you control infrastructure deletion)
- All cleanup jobs with green checkmarks (✓)
- Complete cleanup flow

---

## Tips for Great Screenshots

**General:**
- ✅ Use light theme (easier to read)
- ✅ Capture entire workflow from left to right
- ✅ Include all job names clearly
- ✅ Show green checkmarks (✓) for success
- ✅ Recommended width: ~1200px for good quality
- ✅ Crop out unnecessary browser chrome

**Pro Tip:** Take screenshots after successful runs to show working pipelines!

---

## Why Both Screenshots Matter

Hiring managers often **don't have access** to your private GitHub Actions. 

**Deploy Pipeline Screenshot proves:**
- ✅ You built a working deployment automation
- ✅ Full CI/CD from code → infrastructure → application
- ✅ Multi-stage workflow (validate, build, deploy)
- ✅ Production deployment capability

**Destroy Pipeline Screenshot proves:**
- ✅ You understand infrastructure lifecycle management
- ✅ Cost-conscious (can tear down demos)
- ✅ Safe deletion with manual approval gates
- ✅ Complete cleanup automation

**Together, these show full DevOps maturity!** 🚀

---

## File Checklist

- [ ] `ci-deploy-workflow.png` - Deploy pipeline screenshot
- [ ] `ci-destroy-workflow.png` - Destroy pipeline screenshot

Both are referenced in the main README.md under "Approach 3: CI/CD Deployment"

