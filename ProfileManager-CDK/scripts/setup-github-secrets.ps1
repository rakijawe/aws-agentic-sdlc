# Setup GitHub Secrets for CI/CD
# This script helps you configure GitHub repository secrets

param(
    [string]$GitHubRepo = "",
    [string]$Region = "us-east-1"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup GitHub Secrets for CI/CD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if GitHub CLI is installed
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue

if (-not $ghInstalled) {
    Write-Host "[WARNING] GitHub CLI (gh) is not installed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can install it from: https://cli.github.com/" -ForegroundColor Yellow
    Write-Host "Or configure secrets manually in GitHub web interface." -ForegroundColor Yellow
    Write-Host ""
    $manualSetup = $true
} else {
    Write-Host "[SUCCESS] GitHub CLI found" -ForegroundColor Green
    $manualSetup = $false
}

# Get GitHub repository
if (-not $GitHubRepo -and -not $manualSetup) {
    $GitHubRepo = Read-Host "Enter GitHub repository (format: owner/repo)"
}

Write-Host ""
Write-Host "Required GitHub Secrets:" -ForegroundColor Yellow
Write-Host "------------------------" -ForegroundColor Yellow
Write-Host ""

# 1. AWS Credentials
Write-Host "1. AWS_ACCESS_KEY_ID" -ForegroundColor Cyan
Write-Host "   Description: AWS access key for deployment" -ForegroundColor Gray
Write-Host "   How to get: AWS IAM Console → Users → Security credentials" -ForegroundColor Gray

if (-not $manualSetup) {
    $awsAccessKey = Read-Host "   Enter AWS_ACCESS_KEY_ID"
    if ($awsAccessKey) {
        gh secret set AWS_ACCESS_KEY_ID --body $awsAccessKey --repo $GitHubRepo
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [SUCCESS] AWS_ACCESS_KEY_ID set" -ForegroundColor Green
        }
    }
}
Write-Host ""

Write-Host "2. AWS_SECRET_ACCESS_KEY" -ForegroundColor Cyan
Write-Host "   Description: AWS secret access key for deployment" -ForegroundColor Gray

if (-not $manualSetup) {
    $awsSecretKeySecure = Read-Host "   Enter AWS_SECRET_ACCESS_KEY" -AsSecureString
    $awsSecretKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($awsSecretKeySecure)
    )
    if ($awsSecretKey) {
        gh secret set AWS_SECRET_ACCESS_KEY --body $awsSecretKey --repo $GitHubRepo
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [SUCCESS] AWS_SECRET_ACCESS_KEY set" -ForegroundColor Green
        }
    }
}
Write-Host ""

# 2. AWS Account ID
Write-Host "3. AWS_ACCOUNT_ID" -ForegroundColor Cyan
Write-Host "   Description: Your AWS account ID (12 digits)" -ForegroundColor Gray

$accountId = aws sts get-caller-identity --query Account --output text 2>$null
if ($accountId) {
    Write-Host "   Detected: $accountId" -ForegroundColor Green
    
    if (-not $manualSetup) {
        gh secret set AWS_ACCOUNT_ID --body $accountId --repo $GitHubRepo
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [SUCCESS] AWS_ACCOUNT_ID set" -ForegroundColor Green
        }
    }
} else {
    Write-Host "   Could not detect AWS account ID" -ForegroundColor Yellow
    if (-not $manualSetup) {
        $accountId = Read-Host "   Enter AWS_ACCOUNT_ID"
        if ($accountId) {
            gh secret set AWS_ACCOUNT_ID --body $accountId --repo $GitHubRepo
        }
    }
}
Write-Host ""

# 3. Stack Names
Write-Host "4. TEST_STACK_NAME" -ForegroundColor Cyan
Write-Host "   Description: CloudFormation stack name for test environment" -ForegroundColor Gray
Write-Host "   Example: profilemanager-test-20260212" -ForegroundColor Gray

if (-not $manualSetup) {
    $testStackName = Read-Host "   Enter TEST_STACK_NAME"
    if ($testStackName) {
        gh secret set TEST_STACK_NAME --body $testStackName --repo $GitHubRepo
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [SUCCESS] TEST_STACK_NAME set" -ForegroundColor Green
        }
    }
}
Write-Host ""

Write-Host "5. PROD_STACK_NAME" -ForegroundColor Cyan
Write-Host "   Description: CloudFormation stack name for production environment" -ForegroundColor Gray
Write-Host "   Example: profilemanager-production" -ForegroundColor Gray

if (-not $manualSetup) {
    $prodStackName = Read-Host "   Enter PROD_STACK_NAME (or press Enter to skip)"
    if ($prodStackName) {
        gh secret set PROD_STACK_NAME --body $prodStackName --repo $GitHubRepo
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [SUCCESS] PROD_STACK_NAME set" -ForegroundColor Green
        }
    }
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($manualSetup) {
    Write-Host "Manual Setup Required:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Go to your GitHub repository:" -ForegroundColor White
    Write-Host "https://github.com/$GitHubRepo/settings/secrets/actions" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Add these secrets:" -ForegroundColor White
    Write-Host "1. AWS_ACCESS_KEY_ID - Your AWS access key" -ForegroundColor Gray
    Write-Host "2. AWS_SECRET_ACCESS_KEY - Your AWS secret key" -ForegroundColor Gray
    Write-Host "3. AWS_ACCOUNT_ID - Your AWS account ID ($accountId)" -ForegroundColor Gray
    Write-Host "4. TEST_STACK_NAME - Test stack name" -ForegroundColor Gray
    Write-Host "5. PROD_STACK_NAME - Production stack name (optional)" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "[SUCCESS] GitHub secrets configured!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Verify secrets at:" -ForegroundColor Yellow
    Write-Host "https://github.com/$GitHubRepo/settings/secrets/actions" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Push code to GitHub repository" -ForegroundColor White
Write-Host "2. GitHub Actions will automatically:" -ForegroundColor White
Write-Host "   - Build the application" -ForegroundColor Gray
Write-Host "   - Run tests" -ForegroundColor Gray
Write-Host "   - Deploy to Lambda (on push to main branch)" -ForegroundColor Gray
Write-Host "3. Monitor workflow at:" -ForegroundColor White
Write-Host "   https://github.com/$GitHubRepo/actions" -ForegroundColor Cyan
Write-Host ""

# IAM Policy recommendation
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Required IAM Permissions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The AWS user/role needs these permissions:" -ForegroundColor Yellow
Write-Host ""
Write-Host "- s3:PutObject (for uploading JAR to S3)" -ForegroundColor Gray
Write-Host "- lambda:UpdateFunctionCode (for updating Lambda)" -ForegroundColor Gray
Write-Host "- lambda:GetFunction (for checking Lambda status)" -ForegroundColor Gray
Write-Host "- cloudformation:DescribeStacks (for getting outputs)" -ForegroundColor Gray
Write-Host ""
Write-Host "Sample IAM policy saved to: github-actions-iam-policy.json" -ForegroundColor Yellow
Write-Host ""

# Create sample IAM policy
$iamPolicy = @"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::*-lambda-deployments-*/user-registration.jar"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:GetFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Resource": "arn:aws:lambda:${Region}:${accountId}:function:*-user-registration"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:DescribeStacks"
      ],
      "Resource": "arn:aws:cloudformation:${Region}:${accountId}:stack/*/*"
    }
  ]
}
"@

$iamPolicy | Out-File -FilePath "github-actions-iam-policy.json" -Encoding UTF8
Write-Host "IAM policy template created: github-actions-iam-policy.json" -ForegroundColor Green
Write-Host ""
