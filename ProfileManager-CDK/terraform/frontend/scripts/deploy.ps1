# Frontend Deployment Script for Windows
# Deploys frontend to S3 and invalidates CloudFront cache

param(
    [string]$BuildDir = "dist",
    [switch]$SkipBuild = $false
)

Write-Host "Frontend Deployment Script" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

# Check if Terraform is initialized
if (-not (Test-Path ".terraform")) {
    Write-Host "Terraform not initialized. Running terraform init..." -ForegroundColor Yellow
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Terraform init failed!" -ForegroundColor Red
        exit 1
    }
}

# Get Terraform outputs
Write-Host "Getting Terraform outputs..." -ForegroundColor Yellow
$bucketName = terraform output -raw s3_bucket_name 2>$null
$distributionId = terraform output -raw cloudfront_distribution_id 2>$null

if (-not $bucketName -or -not $distributionId) {
    Write-Host "Terraform outputs not found. Have you run 'terraform apply'?" -ForegroundColor Red
    exit 1
}

Write-Host "S3 Bucket: $bucketName" -ForegroundColor Green
Write-Host "CloudFront Distribution: $distributionId" -ForegroundColor Green
Write-Host ""

# Build frontend (if not skipped)
if (-not $SkipBuild) {
    Write-Host "Building frontend..." -ForegroundColor Yellow
    
    # Detect package manager
    if (Test-Path "package-lock.json") {
        npm run build
    } elseif (Test-Path "yarn.lock") {
        yarn build
    } elseif (Test-Path "pnpm-lock.yaml") {
        pnpm build
    } else {
        Write-Host "No package manager lock file found. Using npm..." -ForegroundColor Yellow
        npm run build
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host ""
}

# Check if build directory exists
if (-not (Test-Path $BuildDir)) {
    Write-Host "Build directory '$BuildDir' not found!" -ForegroundColor Red
    Write-Host "Make sure you've built your frontend or specify correct directory with -BuildDir" -ForegroundColor Yellow
    exit 1
}

# Upload to S3
Write-Host "Uploading files to S3..." -ForegroundColor Yellow
aws s3 sync $BuildDir "s3://$bucketName/" --delete

if ($LASTEXITCODE -ne 0) {
    Write-Host "S3 upload failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Upload successful!" -ForegroundColor Green
Write-Host ""

# Invalidate CloudFront cache
Write-Host "Invalidating CloudFront cache..." -ForegroundColor Yellow
$invalidation = aws cloudfront create-invalidation `
    --distribution-id $distributionId `
    --paths "/*" `
    --query 'Invalidation.Id' `
    --output text

if ($LASTEXITCODE -ne 0) {
    Write-Host "CloudFront invalidation failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Invalidation created: $invalidation" -ForegroundColor Green
Write-Host ""

# Get website URL
$websiteUrl = terraform output -raw website_url
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host ""
Write-Host "Website URL: $websiteUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: CloudFront invalidation may take 5-10 minutes to complete." -ForegroundColor Yellow
Write-Host ""
