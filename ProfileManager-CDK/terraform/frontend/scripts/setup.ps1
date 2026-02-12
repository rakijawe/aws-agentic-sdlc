# Initial Setup Script for Frontend Infrastructure
# Creates all AWS resources using Terraform

Write-Host "Frontend Infrastructure Setup" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Terraform
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "Terraform not found!" -ForegroundColor Red
    Write-Host "Install from: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Terraform found" -ForegroundColor Green

# Check AWS CLI
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "AWS CLI not found!" -ForegroundColor Red
    Write-Host "Install from: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ AWS CLI found" -ForegroundColor Green

# Check AWS credentials
$identity = aws sts get-caller-identity 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "AWS credentials not configured!" -ForegroundColor Red
    Write-Host "Run: aws configure" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ AWS credentials configured" -ForegroundColor Green
Write-Host ""

# Check if terraform.tfvars exists
if (-not (Test-Path "terraform.tfvars")) {
    Write-Host "Creating terraform.tfvars from example..." -ForegroundColor Yellow
    Copy-Item "terraform.tfvars.example" "terraform.tfvars"
    Write-Host "✓ Created terraform.tfvars" -ForegroundColor Green
    Write-Host ""
    Write-Host "Please edit terraform.tfvars with your configuration:" -ForegroundColor Yellow
    Write-Host "  - project_name" -ForegroundColor White
    Write-Host "  - environment" -ForegroundColor White
    Write-Host "  - domain_name (optional)" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue with setup? (y/n)"
    if ($continue -ne "y") {
        Write-Host "Setup cancelled. Edit terraform.tfvars and run this script again." -ForegroundColor Yellow
        exit 0
    }
}

# Initialize Terraform
Write-Host "Initializing Terraform..." -ForegroundColor Yellow
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "Terraform init failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Terraform initialized" -ForegroundColor Green
Write-Host ""

# Plan
Write-Host "Planning infrastructure..." -ForegroundColor Yellow
terraform plan -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host "Terraform plan failed!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Confirm
Write-Host "Review the plan above." -ForegroundColor Yellow
$apply = Read-Host "Apply this plan? (yes/no)"

if ($apply -ne "yes") {
    Write-Host "Setup cancelled." -ForegroundColor Yellow
    exit 0
}

# Apply
Write-Host ""
Write-Host "Creating infrastructure..." -ForegroundColor Yellow
Write-Host "This will take 5-10 minutes..." -ForegroundColor Gray
terraform apply tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Host "Terraform apply failed!" -ForegroundColor Red
    exit 1
}

# Clean up plan file
Remove-Item tfplan -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "===============" -ForegroundColor Green
Write-Host ""

# Display outputs
Write-Host "Infrastructure Details:" -ForegroundColor Cyan
Write-Host ""
terraform output

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Build your frontend: npm run build" -ForegroundColor White
Write-Host "2. Deploy: .\scripts\deploy.ps1" -ForegroundColor White
Write-Host ""
