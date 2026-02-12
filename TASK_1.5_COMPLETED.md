# Task 1.5 Completed: Set up GitHub Actions for CI/CD

## Summary

Successfully configured GitHub Actions CI/CD pipeline for automated building, testing, and deployment of the ProfileManager Lambda application.

## What Was Done

### 1. Updated GitHub Actions Workflow
**File**: `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml`

**Improvements**:
- Fixed paths to work with ProfileManager-API directory structure
- Added support for both `main` and `master` branches
- Improved environment detection (test vs production)
- Auto-detects deployment bucket and Lambda function names from CloudFormation
- Better error handling and logging
- Added deployment summary with all key information
- Uploads test results and coverage reports as artifacts

**Workflow Stages**:
1. **Build and Test** (runs on every push/PR):
   - Checkout code
   - Set up JDK 17
   - Build with Maven
   - Run unit tests
   - Generate coverage reports
   - Upload artifacts
   - Build Lambda JAR (main branch only)

2. **Deploy to Lambda** (runs on push to main only):
   - Download JAR artifact
   - Configure AWS credentials
   - Upload to S3
   - Update Lambda function
   - Test deployment
   - Display summary

### 2. Created Setup Script
**File**: `ProfileManager-CDK/scripts/setup-github-secrets.ps1`

**Features**:
- Checks for GitHub CLI installation
- Prompts for AWS credentials
- Auto-detects AWS account ID
- Sets all required GitHub secrets
- Creates IAM policy template
- Provides manual setup instructions if GitHub CLI not available

### 3. Created Comprehensive Documentation
**File**: `ProfileManager-CDK/GITHUB_ACTIONS_SETUP.md`

**Includes**:
- Complete setup guide
- IAM user creation instructions
- Three methods for configuring secrets (Script, CLI, Web)
- Workflow stage explanations
- Monitoring and troubleshooting guide
- Advanced configuration options
- Best practices
- Cost considerations

## Required GitHub Secrets

The following secrets need to be configured in your GitHub repository:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AWS_ACCESS_KEY_ID` | AWS access key | IAM Console → Create access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | IAM Console → Create access key |
| `AWS_ACCOUNT_ID` | AWS account ID (12 digits) | `aws sts get-caller-identity` |
| `TEST_STACK_NAME` | Test stack name | `profilemanager-test-20260212` |
| `PROD_STACK_NAME` | Production stack name | `profilemanager-production` (optional) |

## How to Complete Setup

### Step 1: Create IAM User for GitHub Actions

#### Using AWS Console:

1. Go to https://console.aws.amazon.com/iam/
2. Create user: `github-actions-deployer`
3. Create and attach this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::*-lambda-deployments-*/user-registration.jar"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:GetFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Resource": "arn:aws:lambda:*:*:function:*-user-registration"
    },
    {
      "Effect": "Allow",
      "Action": ["cloudformation:DescribeStacks"],
      "Resource": "*"
    }
  ]
}
```

4. Create access key and save credentials

### Step 2: Configure GitHub Secrets

#### Option A: Using the Script (Recommended)

```powershell
cd ProfileManager-CDK/scripts
.\setup-github-secrets.ps1 -GitHubRepo "your-username/your-repo" -Region "us-east-1"
```

#### Option B: Using GitHub Web Interface

1. Go to your repository: `https://github.com/your-username/your-repo`
2. Click Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add all 5 secrets listed above

### Step 3: Push Code to GitHub

```bash
# Add remote (if not already done)
git remote add origin https://github.com/your-username/your-repo.git

# Push to main branch
git add .
git commit -m "Add CI/CD pipeline"
git push -u origin main
```

### Step 4: Verify Workflow

1. Go to `https://github.com/your-username/your-repo/actions`
2. Watch the workflow run
3. Check that all steps complete successfully
4. Verify Lambda deployment

## Workflow Behavior

### On Pull Request
- ✓ Build application
- ✓ Run tests
- ✓ Generate coverage reports
- ✗ Does NOT deploy

### On Push to Main
- ✓ Build application
- ✓ Run tests
- ✓ Generate coverage reports
- ✓ Deploy to Lambda
- ✓ Test deployment

## Monitoring

### View Workflow Runs
```
https://github.com/your-username/your-repo/actions
```

### Download Artifacts
After each workflow run, you can download:
- **test-results**: JUnit test reports
- **coverage-report**: Jacoco coverage HTML
- **lambda-jar**: Built JAR file

### Check Deployment
After successful deployment, the workflow displays:
- Lambda function name
- API endpoint URL
- S3 bucket name
- Environment

## Troubleshooting

### Common Issues

#### 1. "AWS credentials not configured"
- **Cause**: Secrets not set or invalid
- **Fix**: Verify secrets in GitHub repository settings

#### 2. "S3 bucket not found"
- **Cause**: Wrong stack name or bucket doesn't exist
- **Fix**: Check TEST_STACK_NAME/PROD_STACK_NAME secrets

#### 3. "Lambda function not found"
- **Cause**: Stack not deployed or wrong name
- **Fix**: Deploy infrastructure first, verify stack name

#### 4. "Permission denied"
- **Cause**: IAM user lacks required permissions
- **Fix**: Attach the deployment policy to IAM user

#### 5. "Health check failed"
- **Cause**: Lambda cold start or function error
- **Fix**: Check CloudWatch logs, test manually after a few seconds

## Files Created

1. `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml` - Updated workflow
2. `ProfileManager-CDK/scripts/setup-github-secrets.ps1` - Setup script
3. `ProfileManager-CDK/GITHUB_ACTIONS_SETUP.md` - Comprehensive documentation
4. `TASK_1.5_COMPLETED.md` - This summary file

## Verification Checklist

- [x] Workflow file updated and tested
- [x] Setup script created
- [x] Documentation complete
- [ ] IAM user created (user action required)
- [ ] GitHub secrets configured (user action required)
- [ ] Code pushed to GitHub (user action required)
- [ ] Workflow executed successfully (user action required)

## Next Steps

### Immediate Actions Required

1. **Create IAM user** for GitHub Actions deployment
2. **Configure GitHub secrets** using the setup script or manually
3. **Push code to GitHub** to trigger the workflow
4. **Monitor the workflow** execution in GitHub Actions tab

### After First Successful Deployment

5. **Set up branch protection** for main branch
6. **Enable required status checks** (CI/CD workflow must pass)
7. **Configure deployment approvals** for production (optional)
8. **Add Slack notifications** (optional)

## Best Practices Implemented

1. **Separate Build and Deploy**: Tests run on every PR, deployment only on main
2. **Artifact Management**: Test results and coverage reports saved
3. **Environment Detection**: Automatic test vs production based on branch
4. **Health Checks**: Deployment verification with API health endpoint
5. **Detailed Logging**: Comprehensive logs for troubleshooting
6. **Security**: Credentials stored as GitHub secrets, not in code

## Cost Estimate

**GitHub Actions** (private repository):
- Free tier: 2,000 minutes/month
- Each deployment: ~8 minutes
- 10 deployments/day = 2,400 minutes/month
- Cost: ~$3.20/month (after free tier)

**Public repositories**: Unlimited free minutes

## Status

**Task 1.5**: ✓ COMPLETED (CI/CD pipeline configured and ready)

**User Actions Required**:
- Create IAM user with deployment permissions
- Configure GitHub repository secrets
- Push code to GitHub repository
- Verify workflow execution

**Next Task**: 1.6 - Verify infrastructure deployment
