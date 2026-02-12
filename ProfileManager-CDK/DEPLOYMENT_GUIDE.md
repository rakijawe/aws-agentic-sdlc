# AWS Lambda Deployment Guide

Complete guide for deploying Spring Boot applications to AWS Lambda with automated CI/CD.

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [One-Time Setup](#one-time-setup)
5. [Automated Deployments](#automated-deployments)
6. [Scripts Reference](#scripts-reference)
7. [Troubleshooting](#troubleshooting)
8. [Deploying to a New Repository](#deploying-to-a-new-repository)

---

## Overview

This deployment approach separates infrastructure provisioning from code deployment:

- **Infrastructure**: Deployed once manually using scripts
- **Code**: Automatically deployed via GitHub Actions on every push to main

### Deployment Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    ONE-TIME SETUP                            │
│  (Manual - Run scripts locally)                              │
├─────────────────────────────────────────────────────────────┤
│  1. AWS Infrastructure (CloudFormation)                      │
│     - VPC, Subnets, Security Groups                          │
│     - RDS PostgreSQL Database                                │
│     - Lambda Function (placeholder)                          │
│     - API Gateway                                            │
│     - S3 Bucket for deployments                              │
│                                                               │
│  2. GitHub Secrets Configuration                             │
│     - AWS_ACCESS_KEY_ID                                      │
│     - AWS_SECRET_ACCESS_KEY                                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 AUTOMATED DEPLOYMENTS                        │
│  (Automatic - GitHub Actions)                                │
├─────────────────────────────────────────────────────────────┤
│  On every push to main:                                      │
│  1. Build application (Maven)                                │
│  2. Run tests                                                │
│  3. Generate coverage reports                                │
│  4. Build Lambda JAR                                         │
│  5. Upload JAR to S3                                         │
│  6. Update Lambda function code                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Architecture

### AWS Resources Created

```
┌──────────────────────────────────────────────────────────────┐
│                         AWS Cloud                             │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  API Gateway (HTTP API)                              │    │
│  │  https://[id].execute-api.us-east-1.amazonaws.com   │    │
│  └────────────────────┬─────────────────────────────────┘    │
│                       │                                       │
│  ┌────────────────────▼─────────────────────────────────┐    │
│  │  Lambda Function                                      │    │
│  │  - Runtime: Java 17                                   │    │
│  │  - Memory: 2048 MB                                    │    │
│  │  - Timeout: 30 seconds                                │    │
│  │  - Spring Boot Application                            │    │
│  └────────────────────┬─────────────────────────────────┘    │
│                       │                                       │
│  ┌────────────────────▼─────────────────────────────────┐    │
│  │  RDS PostgreSQL                                       │    │
│  │  - Engine: PostgreSQL 16.11                           │    │
│  │  - Instance: db.t3.micro                              │    │
│  │  - Storage: 20 GB                                     │    │
│  └───────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐    │
│  │  S3 Bucket                                             │    │
│  │  - Stores Lambda deployment JARs                       │    │
│  │  - Versioning enabled                                  │    │
│  └───────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐    │
│  │  Secrets Manager                                       │    │
│  │  - Database password                                   │    │
│  │  - Email credentials                                   │    │
│  │  - OAuth2 credentials                                  │    │
│  │  - Encryption keys                                     │    │
│  └───────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### Required Software

1. **AWS CLI** (v2.x)
   ```powershell
   # Install via MSI installer
   # Download from: https://aws.amazon.com/cli/
   
   # Verify installation
   aws --version
   ```

2. **Maven** (3.9.x)
   ```powershell
   # Download from: https://maven.apache.org/download.cgi
   # Extract and add to PATH
   
   # Verify installation
   mvn --version
   ```

3. **Git**
   ```powershell
   # Download from: https://git-scm.com/
   
   # Verify installation
   git --version
   ```

4. **Java 17**
   ```powershell
   # Download from: https://adoptium.net/
   
   # Verify installation
   java -version
   ```

### AWS Account Setup

1. **Create IAM User**
   - Go to AWS Console → IAM → Users
   - Create user with programmatic access
   - Attach policies:
     - `AWSCloudFormationFullAccess`
     - `AWSLambdaFullAccess`
     - `AmazonRDSFullAccess`
     - `AmazonS3FullAccess`
     - `IAMFullAccess`
     - `AmazonAPIGatewayAdministrator`
     - `SecretsManagerReadWrite`

2. **Configure AWS CLI**
   ```powershell
   aws configure
   # AWS Access Key ID: [your-access-key]
   # AWS Secret Access Key: [your-secret-key]
   # Default region name: us-east-1
   # Default output format: json
   ```

3. **Verify Configuration**
   ```powershell
   aws sts get-caller-identity
   ```

---

## One-Time Setup

### Step 1: Clone Repository

```powershell
git clone https://github.com/your-org/your-repo.git
cd your-repo
```

### Step 2: Configure Application

1. **Update `src/main/resources/application.properties`**
   ```properties
   # Database configuration (will be overridden by Lambda environment)
   spring.datasource.url=jdbc:postgresql://localhost:5432/userregistration
   spring.datasource.username=postgres
   spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}
   
   # Email configuration
   app.email.username=${EMAIL_USERNAME}
   app.email.password=${EMAIL_PASSWORD}
   
   # OAuth2 configuration
   spring.security.oauth2.client.registration.google.client-id=${GOOGLE_CLIENT_ID}
   spring.security.oauth2.client.registration.google.client-secret=${GOOGLE_CLIENT_SECRET}
   ```

2. **Create `.env` file** (for local development)
   ```env
   SPRING_DATASOURCE_PASSWORD=your_db_password
   EMAIL_USERNAME=your_email@gmail.com
   EMAIL_PASSWORD=your_app_password
   GOOGLE_CLIENT_ID=your_google_client_id
   GOOGLE_CLIENT_SECRET=your_google_client_secret
   AMAZON_CLIENT_ID=your_amazon_client_id
   AMAZON_CLIENT_SECRET=your_amazon_client_secret
   ENCRYPTION_KEY=your_base64_encryption_key
   ```

### Step 3: Deploy AWS Infrastructure

You have two options for deploying infrastructure:

#### Option A: Automated Setup via GitHub Actions (Recommended)

1. **Push code to GitHub**
   ```powershell
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. **Configure GitHub Secrets** (see Step 4 below)

3. **Run the setup workflow**
   - Go to your repository on GitHub
   - Navigate to: Actions → Setup AWS Infrastructure (One-Time)
   - Click "Run workflow"
   - Fill in the parameters:
     - Stack name: `user-registration-lambda`
     - Environment: `production`
     - Database username: `postgres`
     - Database password: (minimum 8 characters)
     - AWS region: `us-east-1`
   - Click "Run workflow"

4. **Monitor progress**
   - Watch the workflow execution (takes 10-15 minutes)
   - View deployment summary in the workflow logs

**Advantages:**
- ✅ Fully automated - no local setup required
- ✅ Reproducible - can be run on any machine
- ✅ Auditable - all actions logged in GitHub
- ✅ No need to install AWS CLI or Maven locally

#### Option B: Manual Setup via PowerShell Script

Run the complete deployment script locally:

```powershell
.\scripts\complete-lambda-deployment.ps1
```

**What this script does:**
1. Builds your Spring Boot application
2. Creates S3 bucket for deployments
3. Uploads JAR to S3
4. Deploys CloudFormation stack (VPC, RDS, Lambda, API Gateway)
5. Updates Lambda function with application code
6. Displays API endpoint and database connection details

**Script prompts:**
- CloudFormation stack name (default: `user-registration-lambda`)
- Environment name (default: `production`)
- AWS region (default: `us-east-1`)
- Database username (default: `postgres`)
- Database password (minimum 8 characters)

**Expected output:**
```
Deployment Complete!
===================

API Endpoint: https://[id].execute-api.us-east-1.amazonaws.com/production
Database Endpoint: [stack-name]-db.[id].us-east-1.rds.amazonaws.com
Deployment Bucket: production-lambda-deployments-[account-id]
```

**Time required:** 10-15 minutes (mostly waiting for RDS database creation)

### Step 4: Configure GitHub Secrets

Add AWS credentials to GitHub repository:

**Option A: Using GitHub Web Interface**

1. Go to your repository on GitHub
2. Navigate to: Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add two secrets:
   - Name: `AWS_ACCESS_KEY_ID`, Value: [your AWS access key]
   - Name: `AWS_SECRET_ACCESS_KEY`, Value: [your AWS secret key]

**Option B: Using Script** (requires GitHub CLI)

```powershell
# Install GitHub CLI first
winget install --id GitHub.cli

# Run setup script
.\scripts\setup-github-secrets.ps1
```

### Step 5: Test the Deployment

```powershell
# Test API endpoint
curl https://[your-api-endpoint]/actuator/health

# Expected response:
# {"status":"UP"}
```

---

## Automated Deployments

### How It Works

Once setup is complete, every push to the `main` branch triggers:

1. **Build & Test** (GitHub Actions)
   - Checkout code
   - Set up Java 17
   - Build with Maven
   - Run unit tests
   - Run integration tests
   - Generate code coverage reports

2. **Deploy** (GitHub Actions)
   - Build Lambda JAR
   - Upload to S3
   - Update Lambda function
   - Test deployment

### Workflow File

Location: `.github/workflows/ci-cd-lambda.yml`

```yaml
name: CI/CD Pipeline (AWS Lambda)

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    # Builds and tests application
    
  deploy-lambda:
    # Deploys to AWS Lambda
    # Only runs on push to main
```

### Triggering a Deployment

```powershell
# Make changes to your code
git add .
git commit -m "feat: Add new feature"
git push origin main

# GitHub Actions will automatically:
# 1. Build and test
# 2. Deploy to Lambda
# 3. Update API Gateway
```

### Monitoring Deployments

1. Go to: `https://github.com/your-org/your-repo/actions`
2. Click on the latest workflow run
3. View logs for each step
4. Download artifacts (test results, coverage reports)

---

## Scripts Reference

### Infrastructure Scripts

#### `scripts/complete-lambda-deployment.ps1`
**Purpose:** Complete one-time infrastructure and application deployment

**Usage:**
```powershell
.\scripts\complete-lambda-deployment.ps1
```

**What it does:**
- Builds Spring Boot application
- Creates/uses S3 bucket
- Uploads JAR to S3
- Deploys CloudFormation stack
- Updates Lambda function
- Displays deployment information

**When to use:** Initial deployment or complete redeployment

---

#### `scripts/deploy-lambda-code.ps1`
**Purpose:** Update Lambda function code only (infrastructure already exists)

**Usage:**
```powershell
.\scripts\deploy-lambda-code.ps1
```

**What it does:**
- Builds Spring Boot application
- Uploads JAR to existing S3 bucket
- Updates existing Lambda function

**When to use:** Quick code updates without infrastructure changes

---

#### `scripts/cleanup-and-retry.ps1`
**Purpose:** Delete failed CloudFormation stack

**Usage:**
```powershell
.\scripts\cleanup-and-retry.ps1
```

**What it does:**
- Deletes CloudFormation stack
- Waits for deletion to complete

**When to use:** After a failed deployment to clean up before retrying

---

### GitHub Integration Scripts

#### `scripts/setup-github-secrets.ps1`
**Purpose:** Configure GitHub repository secrets for CI/CD

**Usage:**
```powershell
.\scripts\setup-github-secrets.ps1
```

**What it does:**
- Checks for GitHub CLI
- Prompts for AWS credentials
- Sets GitHub repository secrets

**When to use:** One-time setup for GitHub Actions

---

#### `scripts/test-github-pipeline.ps1`
**Purpose:** Test GitHub Actions pipeline

**Usage:**
```powershell
.\scripts\test-github-pipeline.ps1
```

**What it does:**
- Verifies GitHub secrets are configured
- Commits and pushes changes
- Triggers GitHub Actions workflow

**When to use:** Testing CI/CD pipeline after setup

---

### Utility Scripts

#### `scripts/update-secrets.ps1`
**Purpose:** Update AWS Secrets Manager values

**Usage:**
```powershell
.\scripts\update-secrets.ps1
```

**What it does:**
- Prompts for application secrets
- Updates AWS Secrets Manager

**When to use:** Updating credentials or configuration

---

#### `scripts/check-postgres-versions.ps1`
**Purpose:** Check available PostgreSQL versions in AWS RDS

**Usage:**
```powershell
.\scripts\check-postgres-versions.ps1
```

**What it does:**
- Lists available PostgreSQL versions in your AWS region

**When to use:** Before deployment to verify database version availability

---

## Troubleshooting

### Common Issues

#### 1. CloudFormation Stack Creation Failed

**Error:** `Cannot find version X.X for postgres`

**Solution:**
```powershell
# Check available versions
.\scripts\check-postgres-versions.ps1

# Update aws/lambda-infrastructure.yml
# Change EngineVersion to an available version
```

---

#### 2. Lambda Function Returns Internal Server Error

**Error:** `{"message":"Internal Server Error"}`

**Diagnosis:**
```powershell
# Check Lambda logs
aws logs tail /aws/lambda/production-user-registration --since 5m --region us-east-1
```

**Common causes:**
- Spring Boot initialization failure
- Database connection issues
- Missing environment variables
- OAuth2 configuration errors

---

#### 3. GitHub Actions Deployment Fails

**Error:** `No plugin found for prefix 'jacoco'`

**Solution:** JaCoCo plugin is now added to `pom.xml`. Pull latest changes.

---

#### 4. S3 Bucket Already Exists

**Error:** `Bucket already exists`

**Solution:**
```powershell
# Use existing bucket or delete and recreate
aws s3 rb s3://production-lambda-deployments-[account-id] --force --region us-east-1
```

---

## Deploying to a New Repository

### Complete Checklist

#### Phase 1: Repository Setup

- [ ] Create new GitHub repository
- [ ] Clone repository locally
- [ ] Copy application code
- [ ] Copy deployment files:
  - [ ] `.github/workflows/ci-cd-lambda.yml`
  - [ ] `aws/lambda-infrastructure.yml`
  - [ ] `scripts/` directory (all scripts)
  - [ ] `Dockerfile` (if using containers)
  - [ ] `.dockerignore`

#### Phase 2: Configuration

- [ ] Update `pom.xml`:
  - [ ] Change `artifactId`, `groupId`, `name`
  - [ ] Verify Java version (17)
  - [ ] Verify Spring Boot version (3.2.0)
  - [ ] Ensure JaCoCo plugin is present
  - [ ] Ensure Maven Shade plugin is configured

- [ ] Update `application.properties`:
  - [ ] Database configuration
  - [ ] Email settings
  - [ ] OAuth2 settings
  - [ ] Application-specific properties

- [ ] Update `application-lambda.properties`:
  - [ ] Lambda-specific configuration
  - [ ] Connection pool settings

- [ ] Create `.env` file with local development credentials

#### Phase 3: AWS Setup

- [ ] Configure AWS CLI
  ```powershell
  aws configure
  ```

- [ ] Verify AWS credentials
  ```powershell
  aws sts get-caller-identity
  ```

- [ ] Update `aws/lambda-infrastructure.yml`:
  - [ ] Change stack name references
  - [ ] Update resource names
  - [ ] Verify PostgreSQL version
  - [ ] Update Lambda function name
  - [ ] Update API Gateway name

#### Phase 4: Infrastructure Deployment

- [ ] Run complete deployment script
  ```powershell
  .\scripts\complete-lambda-deployment.ps1
  ```

- [ ] Note down outputs:
  - [ ] API Endpoint URL
  - [ ] Database Endpoint
  - [ ] S3 Bucket Name
  - [ ] Lambda Function Name

- [ ] Test API endpoint
  ```powershell
  curl https://[api-endpoint]/actuator/health
  ```

#### Phase 5: GitHub Configuration

- [ ] Push code to GitHub
  ```powershell
  git add .
  git commit -m "Initial commit"
  git push origin main
  ```

- [ ] Configure GitHub secrets:
  - [ ] `AWS_ACCESS_KEY_ID`
  - [ ] `AWS_SECRET_ACCESS_KEY`

- [ ] Update workflow file if needed:
  - [ ] Stack name
  - [ ] Function name
  - [ ] Region

#### Phase 6: Testing

- [ ] Trigger GitHub Actions:
  ```powershell
  git commit --allow-empty -m "Test CI/CD pipeline"
  git push origin main
  ```

- [ ] Monitor workflow: `https://github.com/[org]/[repo]/actions`

- [ ] Verify deployment:
  ```powershell
  curl https://[api-endpoint]/actuator/health
  ```

- [ ] Check Lambda logs:
  ```powershell
  aws logs tail /aws/lambda/[function-name] --since 5m --region us-east-1
  ```

#### Phase 7: Documentation

- [ ] Update `README.md` with:
  - [ ] Project-specific information
  - [ ] API endpoints
  - [ ] Environment variables
  - [ ] Setup instructions

- [ ] Document any custom configuration

- [ ] Add API documentation

---

## File Structure

```
your-repo/
├── .github/
│   └── workflows/
│       └── ci-cd-lambda.yml          # GitHub Actions workflow
├── aws/
│   ├── lambda-infrastructure.yml     # CloudFormation template
│   ├── LAMBDA_DEPLOYMENT.md          # Lambda deployment guide
│   └── README.md                     # AWS deployment overview
├── scripts/
│   ├── complete-lambda-deployment.ps1  # Full deployment
│   ├── deploy-lambda-code.ps1          # Code-only deployment
│   ├── cleanup-and-retry.ps1           # Cleanup failed stacks
│   ├── setup-github-secrets.ps1        # Configure GitHub secrets
│   ├── test-github-pipeline.ps1        # Test CI/CD
│   ├── update-secrets.ps1              # Update AWS secrets
│   └── check-postgres-versions.ps1     # Check RDS versions
├── src/
│   ├── main/
│   │   ├── java/                     # Application code
│   │   └── resources/
│   │       ├── application.properties
│   │       └── application-lambda.properties
│   └── test/                         # Test code
├── pom.xml                           # Maven configuration
├── Dockerfile                        # Docker configuration
├── .dockerignore
├── .env                              # Local environment variables
├── DEPLOYMENT_GUIDE.md               # This file
└── README.md                         # Project README
```

---

## Cost Estimates

### Monthly AWS Costs (Approximate)

| Resource | Configuration | Estimated Cost |
|----------|--------------|----------------|
| Lambda | 2GB RAM, 1M requests/month | $5-10 |
| RDS PostgreSQL | db.t3.micro, 20GB storage | $15 |
| API Gateway | 1M requests/month | $3.50 |
| S3 | 1GB storage, minimal requests | $0.50 |
| Data Transfer | Minimal | $1-5 |
| **Total** | | **~$25-35/month** |

### Cost Optimization Tips

1. **Use RDS Reserved Instances** - Save up to 60% on database costs
2. **Enable Lambda SnapStart** - Reduce cold start costs
3. **Set up CloudWatch alarms** - Monitor unexpected usage
4. **Use S3 lifecycle policies** - Auto-delete old deployment artifacts
5. **Consider Aurora Serverless** - Pay only for database usage

---

## Security Best Practices

### Credentials Management

1. **Never commit credentials to Git**
   - Use `.env` for local development
   - Add `.env` to `.gitignore`
   - Use AWS Secrets Manager for production

2. **Rotate AWS credentials regularly**
   ```powershell
   # Create new access key
   aws iam create-access-key --user-name your-user
   
   # Update GitHub secrets
   # Delete old access key
   aws iam delete-access-key --access-key-id OLD_KEY --user-name your-user
   ```

3. **Use IAM roles with least privilege**
   - Grant only necessary permissions
   - Use separate IAM users for different environments

### Network Security

1. **Database in private subnet** - Not publicly accessible
2. **Security groups** - Restrict access to Lambda only
3. **VPC endpoints** - Keep traffic within AWS network

### Application Security

1. **Enable HTTPS only** - API Gateway enforces HTTPS
2. **Input validation** - Validate all user inputs
3. **SQL injection prevention** - Use parameterized queries
4. **Password hashing** - BCrypt with cost factor 12
5. **OAuth2 security** - Validate tokens and state parameters

---

## Support and Resources

### Documentation
- [AWS Lambda Java](https://docs.aws.amazon.com/lambda/latest/dg/lambda-java.html)
- [Spring Boot on Lambda](https://github.com/awslabs/aws-serverless-java-container)
- [CloudFormation Reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/)
- [GitHub Actions](https://docs.github.com/en/actions)

### Useful Commands

```powershell
# View CloudFormation stack status
aws cloudformation describe-stacks --stack-name user-registration-lambda

# View Lambda function configuration
aws lambda get-function-configuration --function-name production-user-registration

# View recent Lambda logs
aws logs tail /aws/lambda/production-user-registration --follow

# List S3 bucket contents
aws s3 ls s3://production-lambda-deployments-[account-id]/

# Test Lambda function directly
aws lambda invoke --function-name production-user-registration response.json

# View API Gateway details
aws apigatewayv2 get-apis
```

---

## Conclusion

This deployment approach provides:

✅ **Separation of Concerns** - Infrastructure vs. Code deployment  
✅ **Automated CI/CD** - Push to main = automatic deployment  
✅ **Infrastructure as Code** - CloudFormation templates  
✅ **Reproducible** - Easy to deploy to new environments  
✅ **Cost-Effective** - Pay only for what you use  
✅ **Scalable** - Lambda auto-scales with demand  

For questions or issues, refer to the troubleshooting section or check the AWS CloudWatch logs.
