# Frontend Deployment Workflow

Complete guide for deploying frontend with manual setup first, then automated deployments.

## Overview

This follows the same pattern as your backend deployment:

1. **Manual Setup (One-Time)** - Create infrastructure using Terraform
2. **Automated Deployments** - Every push to `main` auto-deploys

## Deployment Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    ONE-TIME SETUP                            │
│  (Manual - Run locally or via GitHub Actions)                │
├─────────────────────────────────────────────────────────────┤
│  1. Terraform Infrastructure                                 │
│     - S3 Bucket                                              │
│     - CloudFront Distribution                                │
│     - Route53 DNS (optional)                                 │
│                                                               │
│  2. GitHub Secrets Configuration                             │
│     - AWS_ACCESS_KEY_ID                                      │
│     - AWS_SECRET_ACCESS_KEY                                  │
│     - S3_BUCKET_NAME                                         │
│     - CLOUDFRONT_DISTRIBUTION_ID                             │
│     - API_URL                                                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 AUTOMATED DEPLOYMENTS                        │
│  (Automatic - GitHub Actions)                                │
├─────────────────────────────────────────────────────────────┤
│  On every push to main:                                      │
│  1. Install dependencies (npm ci)                            │
│  2. Run tests                                                │
│  3. Build application (npm run build)                        │
│  4. Upload to S3                                             │
│  5. Invalidate CloudFront cache                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Option A: Manual Setup (Recommended for First Time)

### Prerequisites

1. **Terraform** installed
2. **AWS CLI** configured
3. **Node.js** installed

### Step 1: Configure Terraform

```bash
cd terraform/frontend

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**terraform.tfvars:**
```hcl
aws_region   = "us-east-1"
project_name = "user-registration"
environment  = "production"

# Optional: Custom domain
# domain_name         = "app.example.com"
# acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx"
# route53_zone_id     = "Z1234567890ABC"
```

### Step 2: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply (create resources)
terraform apply
```

**Expected output:**
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

cloudfront_distribution_id = "E1234567890ABC"
cloudfront_domain_name = "d111111abcdef8.cloudfront.net"
s3_bucket_name = "user-registration-production-frontend"
website_url = "https://d111111abcdef8.cloudfront.net"
```

**Save these values!** You'll need them for GitHub secrets.

### Step 3: Test Infrastructure

```bash
# Get outputs
terraform output

# Test CloudFront (should return 403 - no files yet)
curl https://$(terraform output -raw cloudfront_domain_name)
```

### Step 4: Configure GitHub Secrets

Go to your GitHub repository:
1. Navigate to: **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Add these secrets:

| Secret Name | Value | Where to Get It |
|-------------|-------|-----------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | AWS IAM |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | AWS IAM |
| `S3_BUCKET_NAME` | S3 bucket name | `terraform output s3_bucket_name` |
| `CLOUDFRONT_DISTRIBUTION_ID` | CloudFront ID | `terraform output cloudfront_distribution_id` |
| `WEBSITE_URL` | Website URL | `terraform output website_url` |
| `API_URL` | Backend API URL | Your backend endpoint |

### Step 5: Initial Deployment

```bash
# Build frontend
npm run build

# Deploy to S3
aws s3 sync dist/ s3://$(terraform output -raw s3_bucket_name)/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"

# Get website URL
terraform output website_url
```

### Step 6: Verify Deployment

```bash
# Test website
curl https://$(terraform output -raw cloudfront_domain_name)

# Or open in browser
open https://$(terraform output -raw cloudfront_domain_name)
```

---

## Option B: Automated Setup via GitHub Actions

### Step 1: Push Code to GitHub

```bash
git add .
git commit -m "Add frontend deployment configuration"
git push origin main
```

### Step 2: Configure GitHub Secrets

Add AWS credentials:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Step 3: Run Setup Workflow

1. Go to your repository on GitHub
2. Click **"Actions"** tab
3. Find **"Setup Frontend Infrastructure (One-Time)"**
4. Click **"Run workflow"**
5. Fill in parameters:
   - Project name: `user-registration`
   - Environment: `production`
   - AWS region: `us-east-1`
   - Domain name: (leave empty for CloudFront domain)
6. Click **"Run workflow"**

### Step 4: Get Infrastructure Outputs

After workflow completes:
1. Click on the workflow run
2. Download **"infrastructure-outputs"** artifact
3. Open `infrastructure-outputs.txt`
4. Add values as GitHub secrets

### Step 5: Add Remaining Secrets

Add these secrets from the outputs file:
- `S3_BUCKET_NAME`
- `CLOUDFRONT_DISTRIBUTION_ID`
- `WEBSITE_URL`
- `API_URL` (your backend API)

---

## Automated Deployments (After Setup)

Once infrastructure is set up, every push to `main` automatically:

1. ✅ Installs dependencies
2. ✅ Runs tests
3. ✅ Builds application
4. ✅ Uploads to S3
5. ✅ Invalidates CloudFront cache

### Trigger Deployment

```bash
# Make changes
git add .
git commit -m "feat: Add new feature"
git push origin main

# GitHub Actions will automatically deploy!
```

### Monitor Deployment

1. Go to: `https://github.com/your-org/your-repo/actions`
2. Click on latest workflow run
3. View logs for each step

---

## Environment Variables

### React (.env.production)

```env
REACT_APP_API_URL=https://api.example.com
REACT_APP_ENV=production
```

### Vue (.env.production)

```env
VUE_APP_API_URL=https://api.example.com
VUE_APP_ENV=production
```

### Vite (.env.production)

```env
VITE_API_URL=https://api.example.com
VITE_ENV=production
```

**Note:** Add `API_URL` as a GitHub secret and reference it in the workflow.

---

## Deployment Comparison

| Aspect | Manual Setup | Automated Setup |
|--------|-------------|-----------------|
| **Initial Setup** | Run Terraform locally | Run GitHub Actions workflow |
| **Prerequisites** | Terraform, AWS CLI, Node.js | Just AWS credentials |
| **Control** | Full control, see each step | Automated, less visibility |
| **Troubleshooting** | Easier to debug | Check workflow logs |
| **Best For** | First-time setup, validation | New team members, new repos |
| **Time** | ~15 minutes | ~10 minutes |

| Aspect | Both Options |
|--------|-------------|
| **Ongoing Deployments** | Fully automated via GitHub Actions |
| **Cost** | ~$1-2/month |
| **Infrastructure** | Same (S3 + CloudFront) |

---

## Workflow Files

### `.github/workflows/deploy-frontend.yml`
- Triggers on push to `main`
- Builds and deploys frontend
- Runs on every code change

### `.github/workflows/setup-infrastructure.yml`
- Manually triggered
- Creates AWS infrastructure
- Run once per environment

---

## Common Tasks

### Update Frontend Code

```bash
# Make changes
git add .
git commit -m "Update homepage"
git push origin main

# Automatic deployment via GitHub Actions
```

### Manual Deployment (Skip CI/CD)

```bash
# Build
npm run build

# Deploy
cd terraform/frontend
.\scripts\deploy.ps1
```

### View Deployment Status

```bash
# Check S3 bucket
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/

# Check CloudFront invalidations
aws cloudfront list-invalidations \
  --distribution-id $(terraform output -raw cloudfront_distribution_id)
```

### Rollback Deployment

```bash
# S3 versioning is enabled, so you can restore previous version
aws s3api list-object-versions \
  --bucket $(terraform output -raw s3_bucket_name) \
  --prefix index.html

# Restore specific version
aws s3api copy-object \
  --bucket $(terraform output -raw s3_bucket_name) \
  --copy-source $(terraform output -raw s3_bucket_name)/index.html?versionId=VERSION_ID \
  --key index.html
```

---

## Troubleshooting

### Issue: Deployment Fails with "Bucket not found"

**Cause:** Infrastructure not set up or wrong bucket name

**Solution:**
```bash
# Check if infrastructure exists
cd terraform/frontend
terraform output

# If no output, run setup first
terraform apply
```

### Issue: Changes Not Visible on Website

**Cause:** CloudFront cache

**Solution:**
```bash
# Invalidate cache manually
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"

# Wait 5-10 minutes for invalidation to complete
```

### Issue: GitHub Actions Fails with "Access Denied"

**Cause:** AWS credentials not configured or insufficient permissions

**Solution:**
1. Check GitHub secrets are set correctly
2. Verify IAM user has required permissions:
   - S3: `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket`
   - CloudFront: `cloudfront:CreateInvalidation`

### Issue: Build Fails in GitHub Actions

**Cause:** Missing environment variables or dependencies

**Solution:**
1. Check `API_URL` secret is set
2. Verify `package.json` scripts are correct
3. Check Node.js version matches local development

---

## Cost Breakdown

| Resource | Monthly Cost |
|----------|-------------|
| S3 Storage (1GB) | $0.023 |
| S3 Requests (10K) | $0.004 |
| CloudFront Data Transfer (10GB) | $0.85 |
| CloudFront Requests (100K) | $0.01 |
| Route53 (optional) | $0.50 |
| **Total** | **~$1-2/month** |

**Note:** First 1TB CloudFront data transfer is free for 12 months (AWS Free Tier)

---

## Security Best Practices

1. ✅ **S3 bucket not publicly accessible** - Only CloudFront can access
2. ✅ **HTTPS enforced** - HTTP redirects to HTTPS
3. ✅ **TLS 1.2+** - Modern encryption
4. ✅ **Origin Access Identity** - Secure CloudFront → S3 access
5. ✅ **Versioning enabled** - Can rollback if needed
6. ✅ **Secrets in GitHub Secrets** - Never commit credentials

---

## Next Steps

After successful deployment:

1. ✅ Test website functionality
2. ✅ Configure custom domain (optional)
3. ✅ Set up monitoring (CloudWatch)
4. ✅ Add CloudFront alarms
5. ✅ Document API endpoints
6. ✅ Set up staging environment

---

## Support

For issues or questions:
1. Check Terraform output: `terraform output`
2. Check GitHub Actions logs
3. Check AWS Console → CloudFront → Distributions
4. Check S3 bucket contents
5. Review CloudWatch logs

---

## Summary

✅ **Manual setup first** - Validate and troubleshoot  
✅ **Automated deployments** - Every push to main  
✅ **Infrastructure as code** - Terraform  
✅ **Cost-effective** - ~$1-2/month  
✅ **Scalable** - Global CDN  
✅ **Secure** - HTTPS, private S3  

Same proven approach as your backend deployment!
