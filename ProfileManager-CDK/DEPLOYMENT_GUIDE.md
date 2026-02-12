# Profile Management Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the profile management backend to AWS.

## Prerequisites

### Required Tools
- AWS CLI configured with appropriate credentials
- AWS CDK CLI (`npm install -g aws-cdk`)
- Java 17 JDK
- Maven 3.8+
- Node.js 18+ and npm
- PostgreSQL client (for database setup)

### AWS Account Requirements
- AWS account with appropriate permissions
- VPC with public and private subnets
- RDS PostgreSQL instance (or will be created)
- Secrets Manager access

## Deployment Steps

### Step 1: Build the Java Application

```bash
cd ProfileManager-API

# Clean and build
mvn clean package

# Verify JAR file created
ls -l target/ProfileManager-API-1.0.0.jar
```

### Step 2: Set Up Database

#### Option A: Create RDS Instance via CDK
```bash
cd ../ProfileManager-CDK

# Deploy database stack (if not exists)
cdk deploy DatabaseStack
```

#### Option B: Use Existing RDS Instance
Ensure you have:
- RDS PostgreSQL 14+ instance running
- Database created: `profilemanager_db`
- Security group allowing Lambda access

#### Run Database Migrations
```bash
cd ../ProfileManager-DB

# Connect to database
psql -h your-rds-endpoint -U postgres -d profilemanager_db

# Run migrations
\i migrations/V1__create_users_table.sql
\i migrations/V2__create_user_preferences_table.sql
\i migrations/V3__create_login_attempts_table.sql
\i migrations/V4__create_token_blacklist_table.sql

# Optional: Insert sample data
\i sample_data.sql

# Verify tables created
\dt
```

### Step 3: Store Database Credentials in Secrets Manager

```bash
# Create secret for database credentials
aws secretsmanager create-secret \
  --name profilemanager/db-credentials \
  --description "Database credentials for Profile Manager" \
  --secret-string '{
    "username": "postgres",
    "password": "your-secure-password",
    "url": "jdbc:postgresql://your-rds-endpoint:5432/profilemanager_db"
  }'
```

### Step 4: Deploy Lambda Functions and API Gateway

```bash
cd ../ProfileManager-CDK

# Install dependencies
npm install

# Bootstrap CDK (first time only)
cdk bootstrap

# Synthesize CloudFormation template
cdk synth

# Deploy the stack
cdk deploy ProfileLambdaStack

# Confirm deployment when prompted
```

### Step 5: Test the Deployment

#### Get API Endpoint
```bash
# Get API Gateway URL from CDK output
API_URL=$(aws cloudformation describe-stacks \
  --stack-name ProfileLambdaStack \
  --query 'Stacks[0].Outputs[?OutputKey==`APIEndpoint`].OutputValue' \
  --output text)

echo "API Endpoint: $API_URL"
```

#### Test GET /profile
```bash
# Test with sample user ID
curl -X GET "$API_URL/profile?userId=1" \
  -H "Content-Type: application/json"
```

Expected response:
```json
{
  "status": "SUCCESS",
  "data": {
    "id": 1,
    "title": "Mr",
    "firstName": "John",
    "lastName": "Doe",
    "gender": "Male",
    "age": 30,
    "email": "john.doe@example.com",
    "address": "123 Main St, New York, NY 10001",
    "preferences": ["Email Notifications", "SMS Notifications"]
  }
}
```

#### Test PUT /profile
```bash
curl -X PUT "$API_URL/profile?userId=1" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Mr",
    "firstName": "John",
    "lastName": "Doe",
    "gender": "Male",
    "age": 31,
    "email": "john.doe@example.com",
    "address": "123 Main St, New York, NY 10001",
    "preferences": ["Email Notifications", "SMS Notifications", "App Notifications"]
  }'
```

Expected response:
```json
{
  "status": "SUCCESS",
  "data": {
    "message": "Profile updated successfully",
    "userId": "1"
  }
}
```

#### Test GET /profile/email-policy
```bash
curl -X GET "$API_URL/profile/email-policy" \
  -H "Content-Type: application/json"
```

Expected response:
```json
{
  "status": "SUCCESS",
  "data": {
    "emailModificationAllowed": true
  }
}
```

### Step 6: Configure JWT Authorizer (Production)

For production, enable JWT authorization:

1. Create Cognito User Pool or custom JWT authorizer Lambda
2. Update `profile-lambda-stack.ts` to uncomment authorizer
3. Redeploy: `cdk deploy ProfileLambdaStack`

### Step 7: Monitor and Logs

#### View Lambda Logs
```bash
# GetProfileHandler logs
aws logs tail /aws/lambda/ProfileLambdaStack-GetProfileHandler --follow

# UpdateProfileHandler logs
aws logs tail /aws/lambda/ProfileLambdaStack-UpdateProfileHandler --follow
```

#### View API Gateway Logs
```bash
aws logs tail /aws/apigateway/Profile-Management-API --follow
```

#### CloudWatch Metrics
- Lambda invocations, errors, duration
- API Gateway requests, 4xx/5xx errors, latency

## Environment Configuration

### Lambda Environment Variables

Set these in `profile-lambda-stack.ts` or via AWS Console:

- `DB_URL` - Database JDBC URL (from Secrets Manager)
- `DB_USER` - Database username (from Secrets Manager)
- `DB_PASSWORD` - Database password (from Secrets Manager)
- `EMAIL_MODIFICATION_ALLOWED` - Whether email can be modified (true/false)

### API Gateway Configuration

- **Throttling**: 100 requests/second (configurable)
- **CORS**: Enabled for all origins (restrict in production)
- **Logging**: INFO level with data trace enabled
- **Metrics**: Enabled for CloudWatch

## Rollback

### Rollback Lambda Deployment
```bash
cd ProfileManager-CDK

# Destroy the stack
cdk destroy ProfileLambdaStack
```

### Rollback Database Changes
```bash
cd ProfileManager-DB

psql -h your-rds-endpoint -U postgres -d profilemanager_db

\i rollback/R4__drop_token_blacklist_table.sql
\i rollback/R3__drop_login_attempts_table.sql
\i rollback/R2__drop_user_preferences_table.sql
\i rollback/R1__drop_users_table.sql
```

## Troubleshooting

### Lambda Function Errors

**Issue**: Lambda timeout
- **Solution**: Increase timeout in `profile-lambda-stack.ts` (default: 30s)

**Issue**: Database connection fails
- **Solution**: Check VPC configuration, security groups, and RDS endpoint

**Issue**: Out of memory
- **Solution**: Increase memory size in `profile-lambda-stack.ts` (default: 512MB)

### API Gateway Errors

**Issue**: 403 Forbidden
- **Solution**: Check authorizer configuration or disable for testing

**Issue**: 502 Bad Gateway
- **Solution**: Check Lambda function logs for errors

**Issue**: CORS errors
- **Solution**: Verify CORS configuration in API Gateway

### Database Errors

**Issue**: Connection refused
- **Solution**: Check security group allows Lambda access to RDS

**Issue**: Authentication failed
- **Solution**: Verify credentials in Secrets Manager

**Issue**: Table not found
- **Solution**: Run database migrations

## Security Best Practices

1. **Secrets Management**
   - Store all credentials in Secrets Manager
   - Enable automatic rotation
   - Never commit credentials to Git

2. **Network Security**
   - Deploy Lambda in private subnets
   - Use VPC endpoints for AWS services
   - Restrict RDS security group to Lambda only

3. **API Security**
   - Enable JWT authorizer in production
   - Implement rate limiting
   - Use API keys for additional protection
   - Restrict CORS to specific origins

4. **Monitoring**
   - Set up CloudWatch alarms for errors
   - Enable AWS X-Ray for tracing
   - Monitor Lambda concurrency limits
   - Track API Gateway metrics

## Cost Optimization

1. **Lambda**
   - Right-size memory allocation
   - Use provisioned concurrency only if needed
   - Set appropriate timeout values

2. **API Gateway**
   - Use caching for GET requests
   - Implement request throttling
   - Consider REST API vs HTTP API

3. **RDS**
   - Use RDS Proxy for connection pooling
   - Right-size instance type
   - Enable automated backups with retention policy

## Next Steps

1. **Add Authentication**
   - Implement JWT authorizer
   - Integrate with Cognito or custom auth

2. **Add Monitoring**
   - Set up CloudWatch dashboards
   - Configure alarms for errors and latency
   - Enable AWS X-Ray tracing

3. **Add CI/CD**
   - Set up GitHub Actions or Jenkins pipeline
   - Automate testing and deployment
   - Implement blue-green deployments

4. **Add Testing**
   - Write unit tests for Lambda handlers
   - Implement integration tests
   - Set up load testing

5. **Production Hardening**
   - Enable WAF for API Gateway
   - Implement DDoS protection
   - Set up disaster recovery
   - Configure multi-region deployment
