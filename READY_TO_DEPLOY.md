# 🚀 Ready to Deploy - Quick Start Guide

Your infrastructure testing code is ready! Here's how to get started.

## What You Have Now

✅ **Minimal Lambda Code**: Health check handler to test infrastructure
✅ **Unit Tests**: 6 tests to verify functionality
✅ **Build Configuration**: Maven configured for Lambda deployment
✅ **Deployment Scripts**: PowerShell scripts for AWS deployment
✅ **CI/CD Pipeline**: GitHub Actions workflow ready to use
✅ **Documentation**: Complete testing and troubleshooting guides

## Quick Start (3 Steps)

### Step 1: Build and Test Locally (2 minutes)

```powershell
cd ProfileManager-API
.\test-build.ps1
```

**What this does**:
- ✅ Cleans previous builds
- ✅ Compiles Java code
- ✅ Runs 6 unit tests
- ✅ Creates `user-registration-aws.jar`

**Expected output**:
```
✓ Clean successful
✓ Compilation successful
✓ Tests passed
✓ JAR created
Ready for deployment! 🚀
```

### Step 2: Deploy to AWS (10-15 minutes)

```powershell
cd ..\ProfileManager-CDK
.\scripts\complete-lambda-deployment.ps1
```

**What this does**:
1. Builds the JAR (if not already built)
2. Creates S3 bucket for deployments
3. Uploads JAR to S3
4. Deploys CloudFormation stack:
   - VPC with private subnets
   - Lambda function (Java 17)
   - API Gateway HTTP API
   - RDS PostgreSQL 16.11
   - Secrets Manager
   - CloudWatch Logs
5. Updates Lambda with your code
6. Returns API endpoint URL

**You'll be prompted for**:
- Stack name (default: `user-registration-lambda`)
- Environment (default: `production`)
- AWS region (default: `us-east-1`)
- Database username (default: `postgres`)
- Database password (min 8 characters)

### Step 3: Test the Deployment (1 minute)

```bash
# Replace with your actual API endpoint from Step 2
curl https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/production/health
```

**Expected response**:
```json
{
  "status": "UP",
  "service": "ProfileManager-API",
  "version": "1.0.0",
  "timestamp": 1234567890123,
  "environment": "lambda",
  "requestId": "abc-123-def",
  "functionName": "production-user-registration",
  "remainingTimeMs": 29500
}
```

**Success!** ✅ Your infrastructure is working!

## Alternative: Use GitHub Actions (Automated)

If you prefer automated deployment on every push:

### 1. Configure GitHub Secrets
```powershell
# Add these secrets to your GitHub repository:
# Settings → Secrets and variables → Actions → New repository secret
```

Required secrets:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### 2. Push to Main Branch
```bash
git add .
git commit -m "Add health check handler for infrastructure testing"
git push origin main
```

### 3. Monitor Workflow
- Go to GitHub → Actions tab
- Watch the `CI/CD Pipeline (AWS Lambda)` workflow
- Wait for green checkmark (5-10 minutes)

### 4. Get API Endpoint
- Check workflow logs for API endpoint URL
- Or check CloudFormation stack outputs in AWS Console

## Files Created

### Source Code (3 files)
```
ProfileManager-API/src/main/java/com/myorg/usermanagement/handler/
├── StreamLambdaHandler.java      ← Main Lambda entry point
└── HealthCheckHandler.java       ← Health check logic
```

### Tests (1 file)
```
ProfileManager-API/src/test/java/com/myorg/usermanagement/handler/
└── HealthCheckHandlerTest.java   ← 6 unit tests
```

### Configuration (1 file)
```
ProfileManager-API/
└── pom.xml                        ← Updated with shade plugin config
```

### Scripts (1 file)
```
ProfileManager-API/
└── test-build.ps1                 ← Quick build and test script
```

### Documentation (2 files)
```
ProfileManager-API/
└── DEPLOYMENT_TEST.md             ← Complete testing guide

Root/
├── MINIMAL_CODE_SUMMARY.md        ← What was created and why
└── READY_TO_DEPLOY.md             ← This file
```

## What Gets Deployed

### AWS Resources Created
- **VPC**: 10.0.0.0/16 with 2 private subnets
- **Lambda Function**: Java 17, 2048 MB memory, 30s timeout
- **API Gateway**: HTTP API with Lambda proxy integration
- **RDS PostgreSQL**: 16.11, db.t3.micro, 20 GB storage
- **Secrets Manager**: For database credentials and app secrets
- **CloudWatch**: Log groups with 7-day retention
- **Security Groups**: Lambda and RDS security groups

### Endpoints Available
- `GET /health` - Health check
- `GET /actuator/health` - Health check (Spring Boot compatible)
- `ANY /*` - Returns 404 for unknown paths

## Verify Deployment

### Check Lambda Function
```powershell
aws lambda get-function --function-name production-user-registration
```

### Check API Gateway
```powershell
aws apigatewayv2 get-apis
```

### Check CloudWatch Logs
```powershell
cd ProfileManager-CDK
.\scripts\check-lambda-logs.ps1
```

Look for:
- "Health check request received"
- "Health check successful"

### Check RDS Database
```powershell
aws rds describe-db-instances --db-instance-identifier production-lambda-db
```

## Troubleshooting

### Build Issues

**Problem**: Maven not found
```powershell
# Update path in test-build.ps1 or add Maven to PATH
$env:PATH += ";C:\path\to\maven\bin"
```

**Problem**: Java version mismatch
```powershell
# Check Java version
java -version

# Should show: openjdk version "17.x.x"
```

### Deployment Issues

**Problem**: AWS credentials not configured
```powershell
# Configure AWS CLI
aws configure

# Or set environment variables
$env:AWS_ACCESS_KEY_ID = "your-key"
$env:AWS_SECRET_ACCESS_KEY = "your-secret"
```

**Problem**: Stack already exists
```powershell
# Delete existing stack first
aws cloudformation delete-stack --stack-name user-registration-lambda

# Wait for deletion
aws cloudformation wait stack-delete-complete --stack-name user-registration-lambda

# Then redeploy
.\scripts\complete-lambda-deployment.ps1
```

### Testing Issues

**Problem**: API returns 502 Bad Gateway
- Check CloudWatch logs for Lambda errors
- Verify Lambda handler is correct: `com.myorg.usermanagement.handler.StreamLambdaHandler::handleRequest`
- Check Lambda has correct runtime: Java 17

**Problem**: API returns 404
- Verify API Gateway routes are configured
- Check API Gateway stage is deployed
- Verify Lambda permission for API Gateway

**Problem**: Health check returns 500
- Check CloudWatch logs for exception details
- Verify JAR was uploaded correctly
- Check Lambda environment variables

## Next Steps After Successful Deployment

### 1. Configure Secrets (Task 1.3)
```powershell
cd ProfileManager-CDK
.\scripts\update-secrets.ps1
```

Update these secrets in AWS Secrets Manager:
- `EMAIL_USERNAME` - Your SES verified email
- `EMAIL_PASSWORD` - Your SES SMTP password
- `GOOGLE_CLIENT_ID` - Google OAuth2 client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth2 client secret
- `AMAZON_CLIENT_ID` - Amazon OAuth2 client ID
- `AMAZON_CLIENT_SECRET` - Amazon OAuth2 client secret
- `ENCRYPTION_KEY` - Base64 encoded 32-byte key

### 2. Configure AWS SES (Task 1.4)
- Verify sender email address in SES console
- Request production access (move out of sandbox)
- Test email sending

### 3. Set Up GitHub Actions (Task 1.5)
- Add AWS credentials to GitHub secrets
- Push code to trigger workflow
- Monitor deployment

### 4. Create Database Schema (Task 2)
- Create migration files in `ProfileManager-CDK/resources/db/migration/`
- Run migrations against RDS database

### 5. Implement Lambda Utilities (Task 3)
- Database connection utility
- Password hashing utility
- JWT token utility
- Validation utilities
- OAuth2 client utility
- Email service utility

## Monitoring

### CloudWatch Dashboard
Create a dashboard to monitor:
- Lambda invocations and errors
- API Gateway requests and latency
- RDS connections and CPU
- SES email delivery

### CloudWatch Alarms
Set up alarms for:
- Lambda errors > 5 in 5 minutes
- API Gateway 5xx errors > 10 in 5 minutes
- RDS CPU > 80%
- RDS connections > 80% of max

### Cost Monitoring
Estimated monthly costs (us-east-1):
- Lambda: ~$0.20 per 1M requests
- API Gateway: ~$1.00 per 1M requests
- RDS db.t3.micro: ~$15/month
- Data transfer: Variable

## Success Checklist

Before proceeding to next tasks:

- [ ] `test-build.ps1` runs successfully
- [ ] All 6 unit tests pass
- [ ] `user-registration-aws.jar` created
- [ ] CloudFormation stack deployed
- [ ] Lambda function exists
- [ ] API Gateway endpoint accessible
- [ ] Health check returns 200 with JSON
- [ ] CloudWatch logs show successful invocations
- [ ] No errors in CloudWatch logs
- [ ] GitHub Actions workflow configured (optional)

## Resources

### Documentation
- **Testing Guide**: `ProfileManager-API/DEPLOYMENT_TEST.md`
- **Code Summary**: `MINIMAL_CODE_SUMMARY.md`
- **Tasks File**: `.kiro/specs/tasks.md`
- **Tasks Update**: `TASKS_UPDATE_SUMMARY.md`

### Scripts
- **Build & Test**: `ProfileManager-API/test-build.ps1`
- **Deploy Infrastructure**: `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
- **Deploy Code Only**: `ProfileManager-CDK/scripts/deploy-lambda-code.ps1`
- **Check Logs**: `ProfileManager-CDK/scripts/check-lambda-logs.ps1`
- **Update Secrets**: `ProfileManager-CDK/scripts/update-secrets.ps1`

### AWS Console Links
- **Lambda**: https://console.aws.amazon.com/lambda/
- **API Gateway**: https://console.aws.amazon.com/apigateway/
- **CloudFormation**: https://console.aws.amazon.com/cloudformation/
- **CloudWatch**: https://console.aws.amazon.com/cloudwatch/
- **RDS**: https://console.aws.amazon.com/rds/
- **Secrets Manager**: https://console.aws.amazon.com/secretsmanager/

### GitHub
- **Actions**: https://github.com/YOUR-REPO/actions
- **Workflow File**: `.github/workflows/ci-cd-lambda.yml`

## Support

If you encounter issues:

1. **Check CloudWatch Logs**: Most issues show up in logs
2. **Review Deployment Guide**: `ProfileManager-API/DEPLOYMENT_TEST.md`
3. **Check AWS Console**: Verify resources were created
4. **Run Diagnostics**: Use provided PowerShell scripts

---

**Status**: ✅ Ready to deploy
**Next Action**: Run `ProfileManager-API\test-build.ps1`
**Then**: Run `ProfileManager-CDK\scripts\complete-lambda-deployment.ps1`
**Finally**: Test with `curl {endpoint}/health`

🚀 **Happy Deploying!**
