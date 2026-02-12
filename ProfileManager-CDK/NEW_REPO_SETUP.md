# Complete Setup Guide for New Repository

This guide walks you through setting up a new Spring Boot application with AWS Lambda deployment and automated CI/CD from scratch.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [AWS Configuration](#aws-configuration)
4. [GitHub Configuration](#github-configuration)
5. [Deployment](#deployment)
6. [Verification](#verification)
7. [Ongoing Development](#ongoing-development)

---

## Prerequisites

### Required Accounts
- ✅ **GitHub Account** - For code repository and CI/CD
- ✅ **AWS Account** - For infrastructure deployment
- ✅ **Email Account** - For sending verification emails (Gmail recommended)
- ✅ **Google Cloud Console** - For OAuth2 (optional)
- ✅ **Amazon Developer Console** - For OAuth2 (optional)

### Required Software (Optional - only if using manual deployment)
- Java 17
- Maven 3.9+
- AWS CLI v2
- Git

---

## Project Setup

### Step 1: Create New Repository

1. **Create GitHub repository:**
   ```bash
   # On GitHub.com
   # Click "New repository"
   # Name: your-app-name
   # Visibility: Public or Private
   # Initialize: Do NOT add README, .gitignore, or license yet
   ```

2. **Clone this template repository:**
   ```bash
   git clone https://github.com/bahni07/KIROPOC.git your-app-name
   cd your-app-name
   ```

3. **Update remote to your new repository:**
   ```bash
   git remote set-url origin https://github.com/your-username/your-app-name.git
   ```

### Step 2: Customize Application

#### Update `pom.xml`

```xml
<groupId>com.yourcompany</groupId>
<artifactId>your-app-name</artifactId>
<version>1.0.0</version>
<name>Your App Name</name>
<description>Your app description</description>
```

#### Update Package Names (Optional)

If you want to change from `com.example.userregistration` to your own package:

1. Rename package directories in `src/main/java/`
2. Update imports in all Java files
3. Update `application.properties` if needed

#### Update Application Properties

Edit `src/main/resources/application.properties`:

```properties
# Application name
spring.application.name=your-app-name

# Database configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/your_db_name
spring.datasource.username=postgres
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}

# Email configuration
spring.mail.username=${EMAIL_USERNAME}
spring.mail.password=${EMAIL_PASSWORD}
app.email.from=${EMAIL_USERNAME}

# OAuth2 - Google
spring.security.oauth2.client.registration.google.client-id=${GOOGLE_CLIENT_ID}
spring.security.oauth2.client.registration.google.client-secret=${GOOGLE_CLIENT_SECRET}
spring.security.oauth2.client.registration.google.redirect-uri=https://your-domain.com/api/v1/register/oauth/callback/google

# OAuth2 - Amazon
spring.security.oauth2.client.registration.amazon.client-id=${AMAZON_CLIENT_ID}
spring.security.oauth2.client.registration.amazon.client-secret=${AMAZON_CLIENT_SECRET}
spring.security.oauth2.client.registration.amazon.redirect-uri=https://your-domain.com/api/v1/register/oauth/callback/amazon
```

#### Create `.env` File (for local development)

```env
SPRING_DATASOURCE_PASSWORD=your_local_db_password
EMAIL_USERNAME=your_email@gmail.com
EMAIL_PASSWORD=your_gmail_app_password
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
AMAZON_CLIENT_ID=your_amazon_client_id
AMAZON_CLIENT_SECRET=your_amazon_client_secret
ENCRYPTION_KEY=dGhpc2lzYTMyYnl0ZWVuY3J5cHRpb25rZXlmb3J0ZXN0aW5n
```

**Generate Encryption Key:**
```bash
# Linux/Mac
openssl rand -base64 32

# Windows PowerShell
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

### Step 3: Update Infrastructure Files

#### Update `aws/lambda-infrastructure.yml`

Change resource names to match your application:

```yaml
# Line 8: Update description
Description: 'Your App Name - AWS Lambda Deployment'

# Lines with function names - update if needed
FunctionName: !Sub ${EnvironmentName}-your-app-name

# Lines with API names - update if needed
Name: !Sub ${EnvironmentName}-your-app-name-api
```

#### Update `.github/workflows/ci-cd-lambda.yml`

Update stack and function names:

```yaml
# Line 52: Update stack name
--stack-name your-app-lambda \

# Line 59: Update JAR name if you changed artifactId in pom.xml
aws s3 cp target/your-app-name-1.0.0.jar \

# Line 64: Update function name
--function-name production-your-app-name \
```

#### Update `.github/workflows/setup-infrastructure.yml`

Update default values:

```yaml
# Line 10: Update default stack name
default: 'your-app-lambda'
```

### Step 4: Update Documentation

#### Update `README.md`

1. Change project title and description
2. Update repository URLs
3. Update API endpoint examples
4. Add your specific features

#### Update `DEPLOYMENT_GUIDE.md`

1. Update application name references
2. Update stack names
3. Update function names

---

## AWS Configuration

### Step 1: Create IAM User

1. **Go to AWS Console → IAM → Users**
2. **Click "Create user"**
3. **User details:**
   - User name: `your-app-deployment-user`
   - Access type: Programmatic access
4. **Attach policies:**
   - `AWSCloudFormationFullAccess`
   - `AWSLambdaFullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonS3FullAccess`
   - `IAMFullAccess`
   - `AmazonAPIGatewayAdministrator`
   - `SecretsManagerReadWrite`
   - `AmazonVPCFullAccess`
5. **Save credentials:**
   - Access Key ID
   - Secret Access Key

### Step 2: Configure AWS CLI (Optional - for manual deployment)

```bash
aws configure
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region name: us-east-1
# Default output format: json
```

### Step 3: Verify AWS Access

```bash
aws sts get-caller-identity
```

---

## GitHub Configuration

### Step 1: Push Code to GitHub

```bash
# Add all files
git add .

# Commit
git commit -m "Initial commit: Spring Boot Lambda application"

# Push to GitHub
git push -u origin main
```

### Step 2: Configure GitHub Secrets

1. **Go to your repository on GitHub**
2. **Navigate to: Settings → Secrets and variables → Actions**
3. **Click "New repository secret"**
4. **Add the following secrets:**

   | Secret Name | Value | Description |
   |-------------|-------|-------------|
   | `AWS_ACCESS_KEY_ID` | Your AWS access key | From IAM user creation |
   | `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | From IAM user creation |

---

## Deployment

### Option A: Automated Deployment via GitHub Actions (Recommended)

#### Step 1: Run Infrastructure Setup Workflow

1. **Go to your repository on GitHub**
2. **Click "Actions" tab**
3. **Find "Setup AWS Infrastructure (One-Time)" workflow**
4. **Click "Run workflow" button**
5. **Fill in parameters:**

   | Parameter | Value | Example |
   |-----------|-------|---------|
   | Stack name | `your-app-lambda` | `user-registration-lambda` |
   | Environment | `production` | `production` |
   | Database username | `postgres` | `postgres` |
   | Database password | Strong password (min 8 chars) | `MySecurePass123!` |
   | AWS region | `us-east-1` | `us-east-1` |

6. **Click "Run workflow"**
7. **Wait 10-15 minutes** for deployment to complete

#### Step 2: View Deployment Results

After workflow completes, check the logs for:

```
==========================================
✅ Infrastructure Deployment Complete!
==========================================

📋 Stack Details:
  Stack Name: your-app-lambda
  Environment: production
  Region: us-east-1

🌐 Endpoints:
  API: https://[id].execute-api.us-east-1.amazonaws.com/production
  Database: [name]-db.[id].us-east-1.rds.amazonaws.com

📦 Resources:
  Lambda: arn:aws:lambda:us-east-1:[account]:function:production-your-app
  S3 Bucket: production-lambda-deployments-[account-id]
==========================================
```

**Save these values!** You'll need them for testing and configuration.

### Option B: Manual Deployment via PowerShell Script

```powershell
# Run the deployment script
.\scripts\complete-lambda-deployment.ps1

# Follow the prompts:
# - Stack name: your-app-lambda
# - Environment: production
# - Region: us-east-1
# - Database username: postgres
# - Database password: [your-password]
```

---

## Post-Deployment Configuration

### Step 1: Update AWS Secrets Manager

Your application needs real credentials to work. Update the secrets:

1. **Go to AWS Console → Secrets Manager**
2. **Find secret:** `production/lambda/your-app/secrets`
3. **Click "Retrieve secret value" → "Edit"**
4. **Update the JSON:**

```json
{
  "SPRING_DATASOURCE_PASSWORD": "your_actual_db_password",
  "EMAIL_USERNAME": "your_email@gmail.com",
  "EMAIL_PASSWORD": "your_gmail_app_password",
  "GOOGLE_CLIENT_ID": "your_google_client_id",
  "GOOGLE_CLIENT_SECRET": "your_google_client_secret",
  "AMAZON_CLIENT_ID": "your_amazon_client_id",
  "AMAZON_CLIENT_SECRET": "your_amazon_client_secret",
  "ENCRYPTION_KEY": "your_base64_encryption_key"
}
```

5. **Click "Save"**

### Step 2: Get OAuth2 Credentials

#### Google OAuth2

1. **Go to [Google Cloud Console](https://console.cloud.google.com/)**
2. **Create new project** or select existing
3. **Enable Google+ API**
4. **Create OAuth 2.0 credentials:**
   - Application type: Web application
   - Authorized redirect URIs: `https://[your-api-endpoint]/api/v1/register/oauth/callback/google`
5. **Copy Client ID and Client Secret**

#### Amazon OAuth2

1. **Go to [Amazon Developer Console](https://developer.amazon.com/)**
2. **Create new Security Profile**
3. **Add redirect URI:** `https://[your-api-endpoint]/api/v1/register/oauth/callback/amazon`
4. **Copy Client ID and Client Secret**

### Step 3: Configure Email (Gmail)

1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password:**
   - Go to: Google Account → Security → 2-Step Verification → App passwords
   - Select app: Mail
   - Select device: Other (Custom name)
   - Generate password
3. **Use this password** in `EMAIL_PASSWORD` secret

---

## Verification

### Step 1: Test API Health

```bash
# Replace with your actual API endpoint
curl https://[your-api-id].execute-api.us-east-1.amazonaws.com/production/actuator/health

# Expected response:
{"status":"UP"}
```

### Step 2: Test User Registration

```bash
# Register a new user
curl -X POST https://[your-api-endpoint]/api/v1/register/email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "firstName": "Test",
    "lastName": "User"
  }'

# Expected response:
{
  "message": "Registration successful. Please check your email to verify your account.",
  "userId": "...",
  "email": "test@example.com"
}
```

### Step 3: Check Lambda Logs

```bash
# View recent logs
aws logs tail /aws/lambda/production-your-app --since 5m --region us-east-1

# Follow logs in real-time
aws logs tail /aws/lambda/production-your-app --follow --region us-east-1
```

### Step 4: Check Database

```bash
# Connect to RDS database
psql -h [db-endpoint] -U postgres -d userregistration

# List tables
\dt

# Check users
SELECT * FROM customer_identity;
```

---

## Ongoing Development

### Automated Deployments

After initial setup, every push to `main` branch automatically:

1. ✅ Builds the application
2. ✅ Runs tests
3. ✅ Generates coverage reports
4. ✅ Uploads new JAR to S3
5. ✅ Updates Lambda function
6. ✅ Tests deployment

**No manual intervention required!**

### Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes
# ... edit code ...

# 3. Test locally
mvn clean test

# 4. Commit and push
git add .
git commit -m "feat: Add new feature"
git push origin feature/new-feature

# 5. Create Pull Request on GitHub
# Tests will run automatically

# 6. After approval, merge to main
# Deployment happens automatically
```

### Local Development

```bash
# Run with H2 in-memory database
mvn spring-boot:run -Dspring-boot.run.profiles=test

# Run with PostgreSQL
mvn spring-boot:run

# Run tests
mvn test

# Run with coverage
mvn clean verify jacoco:report
```

---

## File Checklist

Files you need to copy from this repository:

### Required Files
- ✅ `pom.xml` - Maven configuration with all dependencies
- ✅ `src/` - All source code
- ✅ `.github/workflows/ci-cd-lambda.yml` - Automated deployment
- ✅ `.github/workflows/setup-infrastructure.yml` - One-time setup
- ✅ `aws/lambda-infrastructure.yml` - CloudFormation template
- ✅ `scripts/complete-lambda-deployment.ps1` - Manual deployment script
- ✅ `scripts/deploy-lambda-code.ps1` - Code-only deployment
- ✅ `scripts/cleanup-and-retry.ps1` - Cleanup script
- ✅ `Dockerfile` - Docker configuration
- ✅ `.dockerignore` - Docker ignore rules
- ✅ `.gitignore` - Git ignore rules

### Documentation Files
- ✅ `README.md` - Project overview
- ✅ `DEPLOYMENT_GUIDE.md` - Detailed deployment guide
- ✅ `AUTOMATED_SETUP.md` - Quick automated setup guide
- ✅ `NEW_REPO_SETUP.md` - This file

### Optional Files
- ⚪ `aws/infrastructure.yml` - ECS Fargate alternative
- ⚪ `.github/workflows/ci-cd-aws.yml` - ECS deployment workflow
- ⚪ `scripts/setup-aws.ps1` - ECS setup script
- ⚪ `BRANCHING_STRATEGY.md` - Git workflow guide
- ⚪ `DEPLOYMENT.md` - Alternative deployment options

---

## Troubleshooting

### Issue: CloudFormation Stack Creation Failed

**Check:**
```bash
# View stack events
aws cloudformation describe-stack-events \
  --stack-name your-app-lambda \
  --region us-east-1 \
  --max-items 20

# Check PostgreSQL versions available
aws rds describe-db-engine-versions \
  --engine postgres \
  --query 'DBEngineVersions[].EngineVersion' \
  --region us-east-1
```

**Solution:** Update `EngineVersion` in `aws/lambda-infrastructure.yml`

### Issue: Lambda Returns Internal Server Error

**Check logs:**
```bash
aws logs tail /aws/lambda/production-your-app --since 10m --region us-east-1
```

**Common causes:**
- Database connection timeout (check security groups)
- Missing environment variables
- Spring Boot initialization errors
- OAuth2 configuration errors

### Issue: GitHub Actions Workflow Fails

**Check:**
1. GitHub secrets are configured correctly
2. AWS credentials have required permissions
3. Stack name matches in all files
4. JAR file name matches in workflow

### Issue: Email Verification Not Working

**Check:**
1. Gmail App Password is correct
2. `EMAIL_USERNAME` and `EMAIL_PASSWORD` in Secrets Manager
3. Lambda has internet access (NAT Gateway or VPC endpoints)
4. Check Lambda logs for email sending errors

---

## Cost Management

### Monthly Costs (Approximate)

| Resource | Configuration | Cost |
|----------|--------------|------|
| Lambda | 2GB RAM, 1M requests | $5-10 |
| RDS | db.t3.micro, 20GB | $15 |
| API Gateway | 1M requests | $3.50 |
| S3 | 1GB storage | $0.50 |
| Data Transfer | Minimal | $1-5 |
| **Total** | | **$25-35/month** |

### Cost Optimization

1. **Use RDS Reserved Instances** - Save up to 60%
2. **Enable Lambda SnapStart** - Reduce cold starts
3. **Set up CloudWatch alarms** - Monitor usage
4. **Use S3 lifecycle policies** - Delete old JARs
5. **Consider Aurora Serverless** - Pay per use

### Cleanup (Delete Everything)

```bash
# Delete CloudFormation stack
aws cloudformation delete-stack \
  --stack-name your-app-lambda \
  --region us-east-1

# Wait for deletion
aws cloudformation wait stack-delete-complete \
  --stack-name your-app-lambda \
  --region us-east-1

# Delete S3 bucket
aws s3 rb s3://production-lambda-deployments-[account-id] \
  --force \
  --region us-east-1
```

---

## Support

### Documentation
- [AWS Lambda Java](https://docs.aws.amazon.com/lambda/latest/dg/lambda-java.html)
- [Spring Boot](https://spring.io/projects/spring-boot)
- [GitHub Actions](https://docs.github.com/en/actions)

### Quick Links
- **AUTOMATED_SETUP.md** - Quick automated setup guide
- **DEPLOYMENT_GUIDE.md** - Detailed deployment guide
- **README.md** - Project overview and API documentation

### Getting Help

1. Check the troubleshooting section above
2. Review CloudWatch logs
3. Check GitHub Actions workflow logs
4. Review AWS CloudFormation events

---

## Summary

You now have a complete, production-ready Spring Boot application with:

✅ AWS Lambda serverless deployment  
✅ Automated CI/CD via GitHub Actions  
✅ PostgreSQL database (RDS)  
✅ API Gateway with HTTPS  
✅ Secrets management  
✅ Monitoring and logging  
✅ Email verification  
✅ OAuth2 integration  
✅ Security best practices  

**Next Steps:**
1. Customize the application for your needs
2. Add your business logic
3. Write tests
4. Deploy and iterate!

Happy coding! 🚀
