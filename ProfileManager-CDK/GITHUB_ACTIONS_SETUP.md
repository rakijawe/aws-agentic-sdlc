# GitHub Actions CI/CD Setup Guide

This guide explains how to set up GitHub Actions for automated building, testing, and deployment of the ProfileManager Lambda application.

## Overview

The CI/CD pipeline automatically:
1. **Builds** the Java application with Maven
2. **Tests** the code with unit tests
3. **Generates** test coverage reports
4. **Deploys** to AWS Lambda (on push to main branch)
5. **Verifies** the deployment with health checks

## Workflow File

**Location**: `.github/workflows/ci-cd-lambda.yml`

**Triggers**:
- Push to `main` or `master` branch → Build, Test, Deploy
- Pull Request to `main` or `master` → Build, Test only

## Prerequisites

1. GitHub repository with your code
2. AWS account with Lambda infrastructure deployed
3. AWS IAM user with deployment permissions
4. GitHub repository secrets configured

## Setup Steps

### Step 1: Create IAM User for GitHub Actions

#### Option A: Using AWS Console

1. Go to AWS IAM Console: https://console.aws.amazon.com/iam/
2. Click "Users" → "Create user"
3. User name: `github-actions-deployer`
4. Click "Next"
5. Select "Attach policies directly"
6. Click "Create policy" → "JSON"
7. Paste this policy:

```json
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
      "Resource": "arn:aws:lambda:*:*:function:*-user-registration"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:DescribeStacks"
      ],
      "Resource": "*"
    }
  ]
}
```

8. Name the policy: `GitHubActionsDeploymentPolicy`
9. Create the policy
10. Attach it to the user
11. Create access key:
    - Go to user → "Security credentials"
    - Click "Create access key"
    - Choose "Application running outside AWS"
    - Save the Access Key ID and Secret Access Key

#### Option B: Using AWS CLI

```bash
# Create IAM policy
aws iam create-policy \
  --policy-name GitHubActionsDeploymentPolicy \
  --policy-document file://github-actions-iam-policy.json

# Create IAM user
aws iam create-user --user-name github-actions-deployer

# Attach policy to user
aws iam attach-user-policy \
  --user-name github-actions-deployer \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubActionsDeploymentPolicy

# Create access key
aws iam create-access-key --user-name github-actions-deployer
```

### Step 2: Configure GitHub Secrets

#### Option A: Using the Setup Script (Recommended)

```powershell
cd ProfileManager-CDK/scripts
.\setup-github-secrets.ps1 -GitHubRepo "your-username/your-repo" -Region "us-east-1"
```

The script will:
1. Check if GitHub CLI is installed
2. Prompt for AWS credentials
3. Auto-detect AWS account ID
4. Set all required secrets

#### Option B: Using GitHub CLI

```bash
# Set AWS credentials
gh secret set AWS_ACCESS_KEY_ID --body "YOUR_ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "YOUR_SECRET_ACCESS_KEY"

# Set AWS account ID
gh secret set AWS_ACCOUNT_ID --body "123456789012"

# Set stack names
gh secret set TEST_STACK_NAME --body "profilemanager-test-20260212"
gh secret set PROD_STACK_NAME --body "profilemanager-production"
```

#### Option C: Using GitHub Web Interface

1. Go to your repository on GitHub
2. Click "Settings" → "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add these secrets:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_ACCOUNT_ID` | AWS account ID | `123456789012` |
| `TEST_STACK_NAME` | Test stack name | `profilemanager-test-20260212` |
| `PROD_STACK_NAME` | Production stack name | `profilemanager-production` |

### Step 3: Push Code to GitHub

```bash
# Initialize git (if not already done)
git init

# Add remote repository
git remote add origin https://github.com/your-username/your-repo.git

# Add all files
git add .

# Commit
git commit -m "Initial commit with CI/CD pipeline"

# Push to main branch
git push -u origin main
```

### Step 4: Verify Workflow Execution

1. Go to your repository on GitHub
2. Click "Actions" tab
3. You should see the workflow running
4. Click on the workflow run to see details

## Workflow Stages

### Stage 1: Build and Test

**Runs on**: Every push and pull request

**Steps**:
1. Checkout code
2. Set up JDK 17
3. Build with Maven
4. Run unit tests
5. Generate coverage report
6. Upload test results and coverage as artifacts
7. Build Lambda JAR (only on push to main)

**Duration**: ~3-5 minutes

### Stage 2: Deploy to Lambda

**Runs on**: Push to main branch only (after tests pass)

**Steps**:
1. Download JAR artifact from build stage
2. Configure AWS credentials
3. Determine environment (test/production)
4. Get deployment bucket name from CloudFormation
5. Upload JAR to S3
6. Get Lambda function name from CloudFormation
7. Update Lambda function code
8. Wait for update to complete
9. Test deployment with health check
10. Display deployment summary

**Duration**: ~2-3 minutes

## Monitoring Deployments

### View Workflow Runs

```
https://github.com/your-username/your-repo/actions
```

### View Workflow Logs

1. Click on a workflow run
2. Click on a job (e.g., "Build and Test")
3. Expand steps to see detailed logs

### Download Artifacts

1. Go to workflow run
2. Scroll to "Artifacts" section
3. Download:
   - `test-results` - JUnit test reports
   - `coverage-report` - Jacoco coverage HTML report
   - `lambda-jar` - Built JAR file

## Troubleshooting

### Workflow Fails at "Build with Maven"

**Possible causes**:
- Compilation errors in code
- Missing dependencies in pom.xml

**Solutions**:
- Check workflow logs for error details
- Run `mvn clean compile` locally to reproduce
- Fix compilation errors and push again

### Workflow Fails at "Run unit tests"

**Possible causes**:
- Test failures
- Missing test dependencies

**Solutions**:
- Check test logs in workflow
- Run `mvn test` locally
- Fix failing tests

### Workflow Fails at "Configure AWS credentials"

**Possible causes**:
- Invalid AWS credentials
- Secrets not set correctly

**Solutions**:
- Verify secrets in GitHub repository settings
- Check AWS access key is valid
- Ensure IAM user has required permissions

### Workflow Fails at "Upload JAR to S3"

**Possible causes**:
- S3 bucket doesn't exist
- IAM user lacks S3 permissions
- Wrong bucket name

**Solutions**:
- Verify S3 bucket exists: `aws s3 ls`
- Check IAM policy includes S3 permissions
- Verify stack name in secrets is correct

### Workflow Fails at "Update Lambda function"

**Possible causes**:
- Lambda function doesn't exist
- IAM user lacks Lambda permissions
- Wrong function name

**Solutions**:
- Verify Lambda exists: `aws lambda list-functions`
- Check IAM policy includes Lambda permissions
- Verify stack name outputs correct function name

### Deployment Succeeds but Health Check Fails

**Possible causes**:
- Lambda cold start (needs warm-up)
- API Gateway not configured
- Lambda function error

**Solutions**:
- Wait a few seconds and test manually
- Check Lambda logs in CloudWatch
- Verify API Gateway endpoint

## Advanced Configuration

### Deploy to Multiple Environments

The workflow supports deploying to different environments based on branch:

- `main` branch → Production environment
- `develop` branch → Test environment

To enable:

1. Add branch to workflow triggers:
```yaml
on:
  push:
    branches: [ main, develop ]
```

2. Update environment logic:
```yaml
- name: Determine environment
  run: |
    if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
      echo "environment=production" >> $GITHUB_OUTPUT
    elif [[ "${{ github.ref }}" == "refs/heads/develop" ]]; then
      echo "environment=test" >> $GITHUB_OUTPUT
    fi
```

### Add Slack Notifications

Add this step at the end of deploy job:

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Deployment to Lambda: ${{ job.status }}'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Add SonarQube Analysis

Add this step after tests:

```yaml
- name: SonarQube Scan
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  run: |
    mvn sonar:sonar \
      -Dsonar.projectKey=profilemanager \
      -Dsonar.host.url=${{ secrets.SONAR_HOST_URL }}
```

### Add Deployment Approval

For production deployments, add manual approval:

```yaml
deploy-lambda:
  name: Deploy to AWS Lambda
  needs: build-and-test
  runs-on: ubuntu-latest
  environment:
    name: production
    url: ${{ steps.get-url.outputs.api_url }}
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

Then configure environment protection rules in GitHub:
1. Go to Settings → Environments
2. Click "production"
3. Enable "Required reviewers"
4. Add reviewers

## Best Practices

### 1. Branch Protection

Enable branch protection for `main`:
1. Go to Settings → Branches
2. Add rule for `main`
3. Enable:
   - Require pull request reviews
   - Require status checks to pass (select CI/CD workflow)
   - Require branches to be up to date

### 2. Semantic Versioning

Tag releases with semantic versions:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 3. Changelog

Maintain a CHANGELOG.md file:

```markdown
# Changelog

## [1.0.0] - 2024-02-12
### Added
- Initial release
- User authentication
- Profile management
```

### 4. Test Coverage

Aim for 70%+ code coverage:
- View coverage reports in workflow artifacts
- Add coverage badge to README
- Fail build if coverage drops below threshold

### 5. Security Scanning

Add security scanning:

```yaml
- name: Run Snyk Security Scan
  uses: snyk/actions/maven@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## Cost Considerations

GitHub Actions pricing:
- **Public repositories**: Free unlimited minutes
- **Private repositories**: 
  - Free tier: 2,000 minutes/month
  - After free tier: $0.008/minute

Typical workflow usage:
- Build + Test: ~5 minutes
- Deploy: ~3 minutes
- Total per deployment: ~8 minutes

Monthly cost estimate (private repo):
- 10 deployments/day = 80 minutes/day
- 30 days = 2,400 minutes/month
- Cost: (2,400 - 2,000) × $0.008 = $3.20/month

## Support Resources

- GitHub Actions Documentation: https://docs.github.com/en/actions
- AWS Lambda Documentation: https://docs.aws.amazon.com/lambda/
- Maven Documentation: https://maven.apache.org/guides/
- GitHub CLI: https://cli.github.com/

## Next Steps

After setting up CI/CD:

1. ✓ Make a code change
2. ✓ Create a pull request
3. ✓ Watch tests run automatically
4. ✓ Merge to main
5. ✓ Watch automatic deployment
6. ✓ Verify deployment with health check
