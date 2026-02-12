#!/bin/bash
# Frontend Deployment Script for Linux/Mac
# Deploys frontend to S3 and invalidates CloudFront cache

set -e

BUILD_DIR="${1:-dist}"
SKIP_BUILD="${2:-false}"

echo "Frontend Deployment Script"
echo "==========================="
echo ""

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "Terraform not initialized. Running terraform init..."
    terraform init
fi

# Get Terraform outputs
echo "Getting Terraform outputs..."
BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null)
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null)

if [ -z "$BUCKET_NAME" ] || [ -z "$DISTRIBUTION_ID" ]; then
    echo "Error: Terraform outputs not found. Have you run 'terraform apply'?"
    exit 1
fi

echo "S3 Bucket: $BUCKET_NAME"
echo "CloudFront Distribution: $DISTRIBUTION_ID"
echo ""

# Build frontend (if not skipped)
if [ "$SKIP_BUILD" != "true" ]; then
    echo "Building frontend..."
    
    # Detect package manager
    if [ -f "package-lock.json" ]; then
        npm run build
    elif [ -f "yarn.lock" ]; then
        yarn build
    elif [ -f "pnpm-lock.yaml" ]; then
        pnpm build
    else
        echo "No package manager lock file found. Using npm..."
        npm run build
    fi
    
    echo "Build successful!"
    echo ""
fi

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory '$BUILD_DIR' not found!"
    echo "Make sure you've built your frontend or specify correct directory"
    exit 1
fi

# Upload to S3
echo "Uploading files to S3..."
aws s3 sync "$BUILD_DIR" "s3://$BUCKET_NAME/" --delete

echo "Upload successful!"
echo ""

# Invalidate CloudFront cache
echo "Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id "$DISTRIBUTION_ID" \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)

echo "Invalidation created: $INVALIDATION_ID"
echo ""

# Get website URL
WEBSITE_URL=$(terraform output -raw website_url)
echo "Deployment Complete!"
echo "==================="
echo ""
echo "Website URL: $WEBSITE_URL"
echo ""
echo "Note: CloudFront invalidation may take 5-10 minutes to complete."
echo ""
