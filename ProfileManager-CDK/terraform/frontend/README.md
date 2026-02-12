# Frontend Terraform Deployment

Terraform configuration for deploying a static frontend (React/Vue/Angular) to AWS using S3 and CloudFront CDN.

## Architecture

```
User → CloudFront CDN → S3 Bucket (Static Files)
         ↓
    Route53 (Optional)
```

## Resources Created

1. **S3 Bucket** - Stores static website files (HTML, CSS, JS, images)
2. **CloudFront Distribution** - Global CDN for fast content delivery
3. **Origin Access Identity** - Secure access from CloudFront to S3
4. **Route53 Record** (Optional) - Custom domain DNS
5. **S3 Bucket Policy** - Allows CloudFront to read files

## Features

- ✅ HTTPS by default (CloudFront SSL)
- ✅ Global CDN with edge caching
- ✅ SPA routing support (404 → index.html)
- ✅ Gzip compression
- ✅ Custom domain support (optional)
- ✅ S3 versioning enabled
- ✅ Secure (S3 not publicly accessible)

## Prerequisites

1. **Terraform** installed (v1.0+)
   ```bash
   # Windows (Chocolatey)
   choco install terraform
   
   # Mac (Homebrew)
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **AWS CLI** configured
   ```bash
   aws configure
   ```

3. **Frontend build** ready (dist/ or build/ folder)

## Quick Start

### 1. Configure Variables

```bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

### 5. Upload Frontend Files

```bash
# Get bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Upload your built frontend
aws s3 sync ./dist s3://$BUCKET_NAME/ --delete

# Or for React build folder
aws s3 sync ./build s3://$BUCKET_NAME/ --delete
```

### 6. Invalidate CloudFront Cache

```bash
# Get distribution ID
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)

# Invalidate cache
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"
```

### 7. Access Your Website

```bash
# Get website URL
terraform output website_url
```

## Configuration Options

### Basic Configuration (No Custom Domain)

```hcl
# terraform.tfvars
aws_region   = "us-east-1"
project_name = "my-app"
environment  = "production"
```

**Result:** Website accessible at CloudFront domain (e.g., `https://d111111abcdef8.cloudfront.net`)

### With Custom Domain

```hcl
# terraform.tfvars
aws_region          = "us-east-1"
project_name        = "my-app"
environment         = "production"
domain_name         = "app.example.com"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx"
route53_zone_id     = "Z1234567890ABC"
```

**Prerequisites for custom domain:**
1. Domain registered (Route53 or external)
2. ACM certificate created in **us-east-1** (required for CloudFront)
3. Route53 hosted zone created

**Result:** Website accessible at `https://app.example.com`

## Cost Estimate

| Resource | Configuration | Monthly Cost |
|----------|--------------|--------------|
| S3 Storage | 1GB | $0.023 |
| S3 Requests | 10K requests | $0.004 |
| CloudFront | 10GB data transfer | $0.85 |
| CloudFront Requests | 100K requests | $0.01 |
| Route53 (optional) | 1 hosted zone | $0.50 |
| **Total** | | **~$1-2/month** |

**Note:** First 1TB of CloudFront data transfer is free for 12 months (AWS Free Tier)

## Deployment Workflow

### Initial Deployment

```bash
# 1. Initialize
terraform init

# 2. Deploy infrastructure
terraform apply

# 3. Build frontend
npm run build  # or yarn build

# 4. Upload files
aws s3 sync ./dist s3://$(terraform output -raw s3_bucket_name)/ --delete

# 5. Get URL
terraform output website_url
```

### Update Deployment

```bash
# 1. Build frontend
npm run build

# 2. Upload files
aws s3 sync ./dist s3://$(terraform output -raw s3_bucket_name)/ --delete

# 3. Invalidate cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/deploy-frontend.yml`:

```yaml
name: Deploy Frontend

on:
  push:
    branches: [ main ]

env:
  AWS_REGION: us-east-1

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Build
      run: npm run build
      env:
        REACT_APP_API_URL: ${{ secrets.API_URL }}
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
    
    - name: Deploy to S3
      run: |
        aws s3 sync ./dist s3://${{ secrets.S3_BUCKET_NAME }}/ --delete
    
    - name: Invalidate CloudFront
      run: |
        aws cloudfront create-invalidation \
          --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
          --paths "/*"
```

**Required GitHub Secrets:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `S3_BUCKET_NAME` (from Terraform output)
- `CLOUDFRONT_DISTRIBUTION_ID` (from Terraform output)
- `API_URL` (your backend API endpoint)

## Custom Domain Setup

### Step 1: Request ACM Certificate

```bash
# Must be in us-east-1 for CloudFront
aws acm request-certificate \
  --domain-name app.example.com \
  --validation-method DNS \
  --region us-east-1
```

### Step 2: Validate Certificate

1. Go to AWS Console → Certificate Manager (us-east-1)
2. Click on certificate
3. Create DNS validation records in Route53

### Step 3: Get Certificate ARN

```bash
aws acm list-certificates --region us-east-1
```

### Step 4: Update terraform.tfvars

```hcl
domain_name         = "app.example.com"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx"
route53_zone_id     = "Z1234567890ABC"
```

### Step 5: Apply Terraform

```bash
terraform apply
```

## Environment Variables in Frontend

### React (.env)

```env
REACT_APP_API_URL=https://api.example.com
REACT_APP_ENV=production
```

### Vue (.env.production)

```env
VUE_APP_API_URL=https://api.example.com
VUE_APP_ENV=production
```

### Angular (environment.prod.ts)

```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.example.com'
};
```

## Troubleshooting

### Issue: 403 Forbidden

**Cause:** S3 bucket policy not allowing CloudFront access

**Solution:**
```bash
terraform apply  # Reapply to fix bucket policy
```

### Issue: 404 on SPA Routes

**Cause:** CloudFront not configured for SPA routing

**Solution:** Already configured in `main.tf` - custom error responses redirect 403/404 to index.html

### Issue: Changes Not Visible

**Cause:** CloudFront cache

**Solution:**
```bash
# Invalidate cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

### Issue: SSL Certificate Error

**Cause:** Certificate not in us-east-1 or not validated

**Solution:**
1. Ensure certificate is in us-east-1
2. Validate certificate via DNS
3. Wait for validation to complete

## Cleanup

To destroy all resources:

```bash
# 1. Empty S3 bucket first
aws s3 rm s3://$(terraform output -raw s3_bucket_name)/ --recursive

# 2. Destroy infrastructure
terraform destroy
```

## Security Best Practices

1. ✅ **S3 bucket not publicly accessible** - Only CloudFront can access
2. ✅ **HTTPS enforced** - HTTP redirects to HTTPS
3. ✅ **TLS 1.2+** - Modern encryption
4. ✅ **Origin Access Identity** - Secure CloudFront → S3 access
5. ✅ **Versioning enabled** - Can rollback if needed

## Performance Optimization

1. **Enable Gzip compression** - Already configured
2. **Set cache headers** - Configure in your build process
3. **Use CloudFront edge locations** - Automatic
4. **Optimize images** - Use WebP, compress images
5. **Code splitting** - Use dynamic imports in React/Vue

## Monitoring

### CloudFront Metrics (CloudWatch)

- Requests
- Bytes downloaded
- Error rate
- Cache hit rate

### View Metrics

```bash
# CloudFront metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name Requests \
  --dimensions Name=DistributionId,Value=$(terraform output -raw cloudfront_distribution_id) \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

## Support

For issues or questions:
1. Check Terraform output: `terraform output`
2. Check AWS Console → CloudFront → Distributions
3. Check S3 bucket contents
4. Review CloudFront logs (if enabled)

## Additional Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
