# Deployment Test Guide

This guide helps you test the infrastructure and deployment setup with minimal code.

## What's Included

### Lambda Handlers
1. **StreamLambdaHandler** - Main entry point for Lambda function
   - Routes requests to appropriate handlers
   - Handles `/health` and `/actuator/health` endpoints
   - Returns 404 for unknown paths

2. **HealthCheckHandler** - Health check endpoint
   - Returns service status, version, and environment info
   - Includes Lambda context information
   - CORS-enabled for frontend testing

### Tests
- **HealthCheckHandlerTest** - Unit tests for health check handler
  - Tests response status code (200)
  - Tests response body structure
  - Tests CORS headers
  - Tests with and without Lambda context

## Build and Test Locally

### 1. Build the Project
```bash
cd ProfileManager-API
mvn clean package
```

This will:
- Compile Java code
- Run unit tests
- Create shaded JAR: `target/user-registration-aws.jar`

### 2. Run Tests
```bash
mvn test
```

Expected output:
```
[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0
```

### 3. Verify JAR Creation
```bash
ls -lh target/*.jar
```

You should see:
- `user-registration-1.0.0.jar` (original)
- `user-registration-aws.jar` (shaded JAR for Lambda)

## Deploy to AWS

### Option 1: Initial Deployment (One-Time)
Use the PowerShell script for complete infrastructure setup:

```powershell
cd ProfileManager-CDK
.\scripts\complete-lambda-deployment.ps1
```

This will:
1. Build the JAR file
2. Create S3 bucket for deployments
3. Upload JAR to S3
4. Deploy CloudFormation stack (VPC, Lambda, API Gateway, RDS, etc.)
5. Update Lambda function with code
6. Display API endpoint URL

**Time**: 10-15 minutes

### Option 2: Code-Only Update (After Initial Setup)
If infrastructure already exists, just update the Lambda code:

```powershell
cd ProfileManager-CDK
.\scripts\deploy-lambda-code.ps1
```

**Time**: 2-3 minutes

### Option 3: Automated CI/CD (Recommended)
Push code to main branch and GitHub Actions will automatically deploy:

```bash
git add .
git commit -m "Add health check handler"
git push origin main
```

GitHub Actions will:
1. Build the project
2. Run tests
3. Upload JAR to S3
4. Update Lambda function

**Time**: 5-10 minutes

## Test the Deployment

### 1. Get API Endpoint
After deployment, you'll see output like:
```
API Endpoint: https://abc123.execute-api.us-east-1.amazonaws.com/production
```

### 2. Test Health Check Endpoint
```bash
# Using curl
curl https://abc123.execute-api.us-east-1.amazonaws.com/production/health

# Using PowerShell
Invoke-RestMethod -Uri "https://abc123.execute-api.us-east-1.amazonaws.com/production/health"
```

Expected response:
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

### 3. Test Actuator Health Endpoint
```bash
curl https://abc123.execute-api.us-east-1.amazonaws.com/production/actuator/health
```

Should return the same response as `/health`.

### 4. Test Unknown Path (404)
```bash
curl https://abc123.execute-api.us-east-1.amazonaws.com/production/unknown
```

Expected response:
```json
{
  "status": "ERROR",
  "message": "Path not found: /unknown",
  "availableEndpoints": ["/health", "/actuator/health"]
}
```

## Check CloudWatch Logs

### Using AWS Console
1. Go to CloudWatch → Log Groups
2. Find `/aws/lambda/production-user-registration`
3. View latest log stream
4. Look for: "Health check request received" and "Health check successful"

### Using PowerShell Script
```powershell
cd ProfileManager-CDK
.\scripts\check-lambda-logs.ps1
```

## Troubleshooting

### Build Fails
**Problem**: Maven build fails
**Solution**: 
- Check Java version: `java -version` (should be 17)
- Check Maven version: `mvn -version`
- Clean and rebuild: `mvn clean install`

### Tests Fail
**Problem**: Unit tests fail
**Solution**:
- Check test output: `mvn test`
- Review error messages
- Ensure all dependencies are downloaded

### JAR Not Found
**Problem**: `user-registration-aws.jar` not created
**Solution**:
- Check pom.xml has maven-shade-plugin configured
- Run: `mvn clean package`
- Look in `target/` directory

### Lambda Function Not Found
**Problem**: Lambda function doesn't exist
**Solution**:
- Run initial deployment: `.\scripts\complete-lambda-deployment.ps1`
- Check CloudFormation stack exists in AWS Console
- Verify stack name matches in script

### API Gateway Returns 502
**Problem**: API Gateway returns "Internal Server Error"
**Solution**:
- Check CloudWatch logs for Lambda errors
- Verify Lambda handler is set correctly: `com.myorg.usermanagement.handler.StreamLambdaHandler::handleRequest`
- Check Lambda function has correct IAM permissions

### Health Check Returns 500
**Problem**: Health check endpoint returns error
**Solution**:
- Check CloudWatch logs for exception details
- Verify Lambda has correct runtime (Java 17)
- Check Lambda memory and timeout settings

## Next Steps

Once health check is working:

1. **Add Database Connection** (Task 3.1)
   - Create database connection utility
   - Test connection to RDS PostgreSQL

2. **Add Authentication** (Task 3.2-3.3)
   - Implement password hashing
   - Implement JWT token generation

3. **Add Registration Handler** (Task 5)
   - Create registration endpoint
   - Test with Postman or curl

4. **Add Login Handler** (Task 8)
   - Create login endpoint
   - Test authentication flow

## Monitoring

### Key Metrics to Watch
- **Invocations**: Number of Lambda invocations
- **Duration**: Average execution time (should be < 1000ms)
- **Errors**: Number of failed invocations (should be 0)
- **Throttles**: Number of throttled requests (should be 0)
- **Cold Starts**: First invocation after idle period (< 3s)

### CloudWatch Dashboard
Create a dashboard to monitor:
- Lambda invocations and errors
- API Gateway 4xx and 5xx errors
- API Gateway latency
- RDS connections and CPU

## Success Criteria

✅ Build completes successfully
✅ All unit tests pass
✅ Shaded JAR created (`user-registration-aws.jar`)
✅ Lambda function deployed
✅ API Gateway endpoint accessible
✅ Health check returns 200 with correct JSON
✅ CloudWatch logs show successful invocations
✅ No errors in CloudWatch logs

## Resources

- **CloudFormation Template**: `ProfileManager-CDK/aws/lambda-infrastructure.yml`
- **Deployment Script**: `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
- **CI/CD Pipeline**: `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml`
- **AWS Console**: https://console.aws.amazon.com/lambda/
- **CloudWatch Logs**: https://console.aws.amazon.com/cloudwatch/

---

**Last Updated**: Current session
**Status**: Ready for deployment testing
