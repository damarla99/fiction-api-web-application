# Documentation Assets

This folder contains screenshots and images used in the main README.

## Required Screenshot

### `ci-workflow.png` - GitHub Actions CI/CD Workflow

**How to capture this screenshot:**

1. Go to your GitHub repository
2. Click on the **"Actions"** tab
3. Click on your latest successful workflow run (CI/CD Pipeline)
4. You'll see the workflow graph showing all jobs:
   - validate
   - build-backend
   - build-frontend
   - deploy-infrastructure
   - deploy-k8s
   - destroy-infrastructure
5. Take a screenshot of this workflow graph
6. Save it as `ci-workflow.png` in this `docs/` folder

**Tips for a good screenshot:**
- Make sure all job names are visible
- Include the green checkmarks (✓) showing successful runs
- Capture the entire workflow from left to right
- Use a clean, light-themed view if possible
- Recommended size: ~1200px wide for good quality

**Alternative:** If you prefer, you can also screenshot the "Workflow runs" list view showing multiple successful deployments with timestamps.

## Why this matters

Hiring managers often don't have access to your private GitHub Actions. This screenshot proves:
- ✅ You actually implemented a working CI/CD pipeline
- ✅ The pipeline has run successfully
- ✅ You understand the deployment flow
- ✅ The project is production-ready

This visual evidence significantly strengthens your portfolio!

