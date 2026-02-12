# Deployment Checklist

Use this checklist to track your infrastructure testing and deployment progress.

## Pre-Deployment Checks

### Local Environment
- [ ] Java 17 installed and configured
  ```bash
  java -version
  # Should show: openjdk version "17.x.x"
  ```
- [ ] Maven installed and accessible
  ```bash
  mvn -version
  # Should show: Apache Maven 3.x.x
  ```
- [ ] AWS CLI installed and configured
  ```bash
  aws --version
  aws sts get-caller-identity
  ```
- [ ] Git installed (for version control)
  ```bash
  git --version
  ```

### AWS Account Setup
- [ ] AWS account created
- [ ] IAM user created with appropriate permissions
- [ ] AWS credentials configured locally
- [ ] Default region set (e.g., us-east-1)
- [ ] Billing alerts configured (optional but recommended)

## Build and Test Phase

### Local Build
- [ ] Navigate to ProfileManager-API directory
- [ ] Run `.\test-build.ps1`
- [ ] Verify: Clean successful
- [ ] Verify: Compilation successful
- [ ] Verify: All 6 tests passed
- [ ] Verify: JAR files created in `target/` directory
- [ ] Verify: `user-registration-aws.jar` exists (shaded JAR)
- [ ] Check JAR size (should be ~15-20 MB)

### Test Results
- [ ] HealthCheckHandlerTest.testHealthCheckReturns200 ✅
- [ ] HealthCheckHandlerTest.testHealthCheckResponseContainsStatus ✅
- [ ] HealthCheckHandlerTest.testHealthCheckResponseContainsServiceInfo ✅
- [ ] HealthCheckHandlerTest.testHealthCheckResponseContainsContextInfo ✅
- [ ] HealthCheckHandlerTest.testHealthCheckResponseHasCorsHeaders ✅
- [ ] HealthCheckHandlerTest.testHealthCheckWithNullContext ✅

## Initial Deployment Phase

### Pre-Deployment
- [ ] Navigate to ProfileManager-CDK directory
- [ ] Review `aws/lambda-infrastructure.yml` template
- [ ] Prepare database password (min 8 characters)
- [ ] Note: Deployment will take 10-15 minutes

### Run Deployment Script
- [ ] Run `.\scripts\complete-lambda-deployment.ps1`
- [ ] Provide stack name (or use default: user-registration-lambda)
- [ ] Provide environment name (or use default: production)
- [ ] Provide AWS region (or use default: us-east-1)
- [ ] Provide database username (or use default: postgres)
- [ ] Provide database password (secure, min 8 chars)

### Deployment Progress
- [ ] Maven build started
- [ ] JAR file built successfully
- [ ] S3 bucket created (or existing bucket found)
- [ ] JAR uploaded to S3
- [ ] CloudFormation stack creation started
- [ ] Wait for stack creation (10-15 minutes)
- [ ] Stack creation completed successfully
- [ ] Lambda function updated with code
- [ ] API endpoint URL displayed

### Record Deployment Info
```
Stack Name: _______________________________
Environment: _______________________________
Region: _______________________________
API Endpoint: _______________________________
Database Endpoint: _______________________________
Lambda ARN: _______________________________
S3 Bucket: _______________________________
Deployment Date: _______________________________
```

## Post-Deployment Verification

### AWS Console Checks
- [ ] CloudFormation stack shows CREATE_COMPLETE
- [ ] Lambda function exists and shows "Active"
- [ ] API Gateway API exists
- [ ] RDS database instance shows "Available"
- [ ] Secrets Manager secret exists
- [ ] CloudWatch log groups created
- [ ] VPC and subnets created
- [ ] Security groups configured

### API Testing
- [ ] Test health endpoint with curl
  ```bash
  curl https://YOUR-API-ID.execute-api.REGION.amazonaws.com/ENV/health
  ```
- [ ] Verify response status code is 200
- [ ] Verify response contains "status": "UP"
- [ ] Verify response contains service info
- [ ] Verify response contains Lambda context

- [ ] Test actuator health endpoint
  ```bash
  curl https://YOUR-API-ID.execute-api.REGION.amazonaws.com/ENV/actuator/health
  ```
- [ ] Verify same response as /health

- [ ] Test unknown path (should return 404)
  ```bash
  curl https://YOUR-API-ID.execute-api.REGION.amazonaws.com/ENV/unknown
  ```
- [ ] Verify response status code is 404
- [ ] Verify response contains error message

### CloudWatch Logs
- [ ] Navigate to CloudWatch → Log Groups
- [ ] Find log group: `/aws/lambda/ENV-user-registration`
- [ ] View latest log stream
- [ ] Verify log entry: "Health check request received"
- [ ] Verify log entry: "Health check successful"
- [ ] No ERROR level logs present

### Performance Checks
- [ ] Lambda cold start time < 3 seconds
- [ ] Lambda warm invocation time < 1 second
- [ ] API Gateway response time < 500ms
- [ ] No throttling errors
- [ ] No timeout errors

## Configuration Phase

### Secrets Manager
- [ ] Navigate to Secrets Manager in AWS Console
- [ ] Find secret: `ENV/lambda/user-registration/secrets`
- [ ] Update EMAIL_USERNAME (your verified SES email)
- [ ] Update EMAIL_PASSWORD (SES SMTP password)
- [ ] Update GOOGLE_CLIENT_ID (from Google Cloud Console)
- [ ] Update GOOGLE_CLIENT_SECRET (from Google Cloud Console)
- [ ] Update AMAZON_CLIENT_ID (from Amazon Developer Console)
- [ ] Update AMAZON_CLIENT_SECRET (from Amazon Developer Console)
- [ ] Update ENCRYPTION_KEY (generate 32-byte base64 key)

### AWS SES Configuration
- [ ] Navigate to SES in AWS Console
- [ ] Verify sender email address
- [ ] Check verification status (should be "Verified")
- [ ] Request production access (if in sandbox)
- [ ] Test email sending (optional)

### Database Access (Optional)
- [ ] Get RDS endpoint from CloudFormation outputs
- [ ] Connect using psql or database client
  ```bash
  psql -h DB-ENDPOINT -U postgres -d userregistration
  ```
- [ ] Verify connection successful
- [ ] List tables (should be empty initially)

## CI/CD Setup (Optional)

### GitHub Repository
- [ ] Code pushed to GitHub repository
- [ ] Repository is private (recommended for production)
- [ ] Branch protection rules configured (optional)

### GitHub Secrets
- [ ] Navigate to Settings → Secrets and variables → Actions
- [ ] Add secret: AWS_ACCESS_KEY_ID
- [ ] Add secret: AWS_SECRET_ACCESS_KEY
- [ ] Verify secrets are accessible

### GitHub Actions
- [ ] Workflow file exists: `.github/workflows/ci-cd-lambda.yml`
- [ ] Push code to main branch
- [ ] Navigate to Actions tab
- [ ] Verify workflow triggered
- [ ] Wait for workflow completion (5-10 minutes)
- [ ] Verify workflow status: Success ✅
- [ ] Check workflow logs for API endpoint

### Test Automated Deployment
- [ ] Make a small code change (e.g., update version number)
- [ ] Commit and push to main branch
- [ ] Verify GitHub Actions workflow triggers
- [ ] Verify Lambda function updated
- [ ] Test API endpoint still works

## Monitoring Setup

### CloudWatch Alarms
- [ ] Create alarm: Lambda errors > 5 in 5 minutes
- [ ] Create alarm: API Gateway 5xx errors > 10 in 5 minutes
- [ ] Create alarm: RDS CPU > 80%
- [ ] Create alarm: RDS connections > 80% of max
- [ ] Configure SNS topic for alarm notifications
- [ ] Subscribe email to SNS topic
- [ ] Test alarm (optional)

### CloudWatch Dashboard
- [ ] Create dashboard: "ProfileManager-Production"
- [ ] Add widget: Lambda invocations
- [ ] Add widget: Lambda errors
- [ ] Add widget: Lambda duration
- [ ] Add widget: API Gateway requests
- [ ] Add widget: API Gateway latency
- [ ] Add widget: RDS CPU utilization
- [ ] Add widget: RDS connections
- [ ] Save dashboard

### Cost Monitoring
- [ ] Enable Cost Explorer (if not already enabled)
- [ ] Create budget alert for monthly costs
- [ ] Set budget threshold (e.g., $50/month)
- [ ] Configure email notification

## Documentation

### Update Documentation
- [ ] Document API endpoint URL
- [ ] Document database endpoint
- [ ] Document secrets location
- [ ] Document deployment process
- [ ] Document rollback procedure
- [ ] Document monitoring setup

### Team Communication
- [ ] Share API endpoint with team
- [ ] Share deployment guide
- [ ] Share CloudWatch dashboard link
- [ ] Share troubleshooting guide

## Success Criteria

### All Green Checks
- [ ] All pre-deployment checks passed
- [ ] Build and test phase completed
- [ ] Initial deployment successful
- [ ] Post-deployment verification passed
- [ ] Configuration completed
- [ ] CI/CD setup working (if configured)
- [ ] Monitoring configured
- [ ] Documentation updated

### Ready for Next Phase
- [ ] Infrastructure is stable
- [ ] API endpoint is accessible
- [ ] CloudWatch logs are clean
- [ ] No errors or warnings
- [ ] Team is informed
- [ ] Ready to implement Task 2 (Database Schema)

## Next Steps

Once all checks are complete:

1. **Task 2**: Create database schema and migration scripts
   - Create V1__create_customer_identity_table.sql
   - Create V2__create_user_preferences_table.sql
   - Create V3__create_login_attempts_table.sql
   - Create V4__create_token_blacklist_table.sql

2. **Task 3**: Implement Lambda utilities
   - Database connection utility
   - Password hashing utility
   - JWT token utility
   - Validation utilities

3. **Task 4**: Implement repository classes
   - UserRepository
   - LoginAttemptRepository

4. **Task 5**: Implement registration handler
   - Email registration
   - Password validation
   - Email verification

## Rollback Plan

If deployment fails or issues arise:

### Rollback Steps
- [ ] Identify the issue (check CloudWatch logs)
- [ ] Decide: Fix forward or rollback
- [ ] If rollback: Delete CloudFormation stack
  ```bash
  aws cloudformation delete-stack --stack-name user-registration-lambda
  ```
- [ ] Wait for deletion to complete
- [ ] Fix the issue locally
- [ ] Redeploy using deployment script

### Backup Strategy
- [ ] Database backups enabled (7-day retention)
- [ ] S3 bucket versioning enabled (optional)
- [ ] CloudFormation template in version control
- [ ] Lambda code in version control

## Troubleshooting Reference

### Common Issues
- [ ] Build fails → Check Java version, Maven configuration
- [ ] Tests fail → Check test output, fix code issues
- [ ] Deployment fails → Check AWS credentials, CloudFormation logs
- [ ] API returns 502 → Check Lambda logs, handler configuration
- [ ] API returns 404 → Check API Gateway routes
- [ ] Health check fails → Check Lambda code, CloudWatch logs

### Support Resources
- [ ] AWS Support (if subscribed)
- [ ] AWS Documentation
- [ ] Stack Overflow
- [ ] GitHub Issues (for dependencies)
- [ ] Team Slack/Discord (if applicable)

---

**Checklist Version**: 1.0
**Last Updated**: Current session
**Status**: Ready for use

**Progress**: _____ / _____ items completed (___%)

**Notes**:
_____________________________________________
_____________________________________________
_____________________________________________
