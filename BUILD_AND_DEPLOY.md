# Build and Deployment Guide

**Project**: User Authentication, Registration, and Profile Management System  
**Last Updated**: 2024-02-12  
**Version**: 1.0.0

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Database Setup](#database-setup)
4. [Backend API Build](#backend-api-build)
5. [CDK Infrastructure Deployment](#cdk-infrastructure-deployment)
6. [Lambda Deployment](#lambda-deployment)
7. [Frontend Build and Deployment](#frontend-build-and-deployment)
8. [Environment Configuration](#environment-configuration)
9. [Testing](#testing)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

| Tool | Version | Purpose |
|------|---------|---------|
| Java | 17+ | Backend development |
| Maven | 3.8+ | Java build tool |
| Node.js | 18+ | Frontend and CDK |
| npm | 9+ | Package manager |
| AWS CLI | 2.x | AWS deployment |
| AWS CDK | 2.x | Infrastructure as code |
| PostgreSQL | 14+ | Database (local dev) |
| Git | 2.x | Version control |

### AWS Account Setup

1. **Create AWS Account** (if not exists)
2. **Configure AWS CLI**:
   ```cmd
   aws configure
   ```
   - Enter AWS Access Key ID
   - Enter AWS Secret Access Key
   - Default region: `us-east-1` (or your preferred region)
   - Default output format: `json`

3. **Verify AWS CLI**:
   ```cmd
   aws sts get-caller-identity
   ```

### Install AWS CDK

```cmd
npm install -g aws-cdk
cdk --version
```

---

## Local Development Setup

### 1. Clone Repository

```cmd
git clone <repository-url>
cd <repository-name>
```

### 2. Verify Project Structure

```
project-root/
├── ProfileManager-API/      (Java Lambda functions)
├── ProfileManager-CDK/      (Infrastructure as code)
├── ProfileManager-DB/       (Database migrations)
└── ProfileManager-UI/       (React frontend - future)
```

---

## Database Setup

### Option 1: Local PostgreSQL (Development)

#### Install PostgreSQL

**Windows**:
1. Download from https://www.postgresql.org/download/windows/
2. Run installer
3. Set password for `postgres` user
4. Note the port (default: 5432)

**Verify Installation**:
```cmd
psql --version
```

#### Create Database

```cmd
psql -U postgres
```

```sql
-- Create database
CREATE DATABASE user_management;

-- Create user
CREATE USER app_user WITH PASSWORD 'your_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE user_management TO app_user;

-- Exit
\q
```

#### Run Migrations

```cmd
cd ProfileManager-DB

# Connect to database
psql -U app_user -d user_management

# Run migration scripts in order
\i migrations/V1__create_users_table.sql
\i migrations/V2__create_user_preferences_table.sql
\i migrations/V3__create_login_attempts_table.sql
\i migrations/V4__create_token_blacklist_table.sql

# Verify tables
\dt

# Exit
\q
```

#### Load Sample Data (Optional)

```cmd
psql -U app_user -d user_management -f sample_data.sql
```

### Option 2: AWS RDS (Production)

#### Create RDS Instance via CDK

The CDK stack will create the RDS instance automatically (see CDK deployment section).

#### Manual RDS Setup (Alternative)

1. **Go to AWS Console** → RDS
2. **Create Database**:
   - Engine: PostgreSQL 14+
   - Template: Production or Dev/Test
   - DB Instance Identifier: `user-management-db`
   - Master username: `postgres`
   - Master password: (set secure password)
   - Instance class: `db.t3.micro` (dev) or `db.t3.medium` (prod)
   - Storage: 20 GB
   - VPC: Default or custom
   - Public access: No (for production)
   - Security group: Allow port 5432 from Lambda security group

3. **Note Connection Details**:
   - Endpoint: `user-management-db.xxxxx.us-east-1.rds.amazonaws.com`
   - Port: `5432`
   - Database name: `user_management`

#### Store Credentials in Secrets Manager

```cmd
aws secretsmanager create-secret ^
  --name user-management-db-credentials ^
  --description "Database credentials for user management system" ^
  --secret-string "{\"username\":\"postgres\",\"password\":\"your_password\",\"host\":\"your-rds-endpoint\",\"port\":5432,\"dbname\":\"user_management\"}"
```

#### Run Migrations on RDS

```cmd
# Connect to RDS
psql -h your-rds-endpoint -U postgres -d user_management

# Run migrations (same as local)
\i migrations/V1__create_users_table.sql
\i migrations/V2__create_user_preferences_table.sql
\i migrations/V3__create_login_attempts_table.sql
\i migrations/V4__create_token_blacklist_table.sql

# Verify
\dt
\q
```

---

## Backend API Build

### 1. Navigate to API Directory

```cmd
cd ProfileManager-API
```

### 2. Build with Maven

```cmd
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Package (creates JAR)
mvn package

# Skip tests (faster build)
mvn package -DskipTests
```

### 3. Verify Build Output

```cmd
dir target
```

Expected output:
- `ProfileManager-API-1.0-SNAPSHOT.jar` - Main JAR
- `test-classes/` - Compiled test classes

### 4. Run Tests with Coverage

```cmd
mvn clean test jacoco:report
```

View coverage report:
```cmd
start target\site\jacoco\index.html
```

### 5. Build for Lambda Deployment

```cmd
# Create deployment package
mvn clean package shade:shade

# This creates a fat JAR with all dependencies
# Output: target/ProfileManager-API-1.0-SNAPSHOT-shaded.jar
```

---

## CDK Infrastructure Deployment

### 1. Navigate to CDK Directory

```cmd
cd ProfileManager-CDK
```

### 2. Install Dependencies

```cmd
npm install
```

### 3. Bootstrap CDK (First Time Only)

```cmd
cdk bootstrap aws://ACCOUNT-ID/REGION
```

Example:
```cmd
cdk bootstrap aws://123456789012/us-east-1
```

### 4. Synthesize CloudFormation Template

```cmd
cdk synth
```

This generates CloudFormation template in `cdk.out/` directory.

### 5. Review Changes

```cmd
cdk diff
```

Shows what will be created/updated/deleted.

### 6. Deploy Infrastructure

```cmd
# Deploy all stacks
cdk deploy --all

# Deploy specific stack
cdk deploy ProfileLambdaStack

# Deploy with approval
cdk deploy --require-approval never
```

### 7. Verify Deployment

```cmd
# List stacks
aws cloudformation list-stacks

# Describe stack
aws cloudformation describe-stacks --stack-name ProfileLambdaStack
```

### 8. Get Stack Outputs

```cmd
aws cloudformation describe-stacks ^
  --stack-name ProfileLambdaStack ^
  --query "Stacks[0].Outputs"
```

Note the outputs:
- API Gateway URL
- Lambda function ARNs
- RDS endpoint
- Secrets ARNs

---

## Lambda Deployment

### Option 1: Deploy via CDK (Recommended)

The CDK stack automatically deploys Lambda functions. Just run:

```cmd
cd ProfileManager-CDK
cdk deploy
```

### Option 2: Manual Lambda Deployment

#### Package Lambda Function

```cmd
cd ProfileManager-API

# Build deployment package
mvn clean package

# Create deployment ZIP
cd target
jar -cvf lambda-deployment.zip -C classes .
```

#### Upload to Lambda

```cmd
# Update function code
aws lambda update-function-code ^
  --function-name GetProfileHandler ^
  --zip-file fileb://lambda-deployment.zip

aws lambda update-function-code ^
  --function-name UpdateProfileHandler ^
  --zip-file fileb://lambda-deployment.zip

aws lambda update-function-code ^
  --function-name GetEmailPolicyHandler ^
  --zip-file fileb://lambda-deployment.zip
```

#### Update Environment Variables

```cmd
aws lambda update-function-configuration ^
  --function-name GetProfileHandler ^
  --environment "Variables={DB_SECRET_ARN=arn:aws:secretsmanager:...,EMAIL_MODIFICATION_ALLOWED=true}"
```

### Option 3: Deploy via SAM

#### Create SAM Template

```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  GetProfileFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: com.myorg.usermanagement.handler.GetProfileHandler::handleRequest
      Runtime: java17
      CodeUri: ProfileManager-API/target/ProfileManager-API-1.0-SNAPSHOT.jar
      MemorySize: 512
      Timeout: 30
      Environment:
        Variables:
          DB_SECRET_ARN: !Ref DatabaseSecret
```

#### Deploy with SAM

```cmd
sam build
sam deploy --guided
```

---

## Frontend Build and Deployment

### 1. Navigate to UI Directory

```cmd
cd ProfileManager-UI
```

### 2. Install Dependencies

```cmd
npm install
```

### 3. Configure Environment

Create `.env.production`:

```env
REACT_APP_API_BASE_URL=https://your-api-gateway-url.amazonaws.com/prod
REACT_APP_GOOGLE_CLIENT_ID=your-google-client-id
REACT_APP_AMAZON_CLIENT_ID=your-amazon-client-id
```

### 4. Build for Production

```cmd
npm run build
```

Output: `build/` directory with optimized production files.

### 5. Deploy to S3

#### Create S3 Bucket

```cmd
aws s3 mb s3://user-management-frontend
```

#### Configure Static Website Hosting

```cmd
aws s3 website s3://user-management-frontend ^
  --index-document index.html ^
  --error-document index.html
```

#### Upload Build Files

```cmd
aws s3 sync build/ s3://user-management-frontend --delete
```

#### Set Bucket Policy (Public Read)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::user-management-frontend/*"
    }
  ]
}
```

```cmd
aws s3api put-bucket-policy ^
  --bucket user-management-frontend ^
  --policy file://bucket-policy.json
```

### 6. Configure CloudFront (Optional)

```cmd
aws cloudfront create-distribution ^
  --origin-domain-name user-management-frontend.s3.amazonaws.com ^
  --default-root-object index.html
```

---

## Environment Configuration

### Development Environment

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=user_management
DB_USER=app_user
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your-dev-jwt-secret
JWT_EXPIRY=3600

# Email
EMAIL_MODIFICATION_ALLOWED=true

# AWS (for local testing)
AWS_REGION=us-east-1
AWS_PROFILE=default
```

### Production Environment

Store in AWS Secrets Manager and reference in Lambda:

```cmd
# Database credentials
aws secretsmanager create-secret ^
  --name prod/user-management/db ^
  --secret-string "{\"username\":\"postgres\",\"password\":\"xxx\",\"host\":\"xxx.rds.amazonaws.com\",\"port\":5432,\"dbname\":\"user_management\"}"

# JWT secret
aws secretsmanager create-secret ^
  --name prod/user-management/jwt ^
  --secret-string "{\"secret\":\"your-prod-jwt-secret\"}"

# OAuth2 credentials
aws secretsmanager create-secret ^
  --name prod/user-management/oauth2 ^
  --secret-string "{\"google_client_id\":\"xxx\",\"google_client_secret\":\"xxx\",\"amazon_client_id\":\"xxx\",\"amazon_client_secret\":\"xxx\"}"
```

---

## Testing

### Unit Tests

```cmd
# Backend
cd ProfileManager-API
mvn test

# Frontend
cd ProfileManager-UI
npm test
```

### Integration Tests

```cmd
# Test API endpoints
curl -X GET https://your-api-gateway-url/prod/profile?userId=1 ^
  -H "Authorization: Bearer your-jwt-token"

curl -X PUT https://your-api-gateway-url/prod/profile?userId=1 ^
  -H "Authorization: Bearer your-jwt-token" ^
  -H "Content-Type: application/json" ^
  -d "{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john@example.com\",\"gender\":\"Male\",\"preferences\":[\"Email Notifications\"]}"
```

### Load Testing (Optional)

```cmd
# Install Apache Bench
# Test API performance
ab -n 1000 -c 10 https://your-api-gateway-url/prod/profile?userId=1
```

---

## Troubleshooting

### Common Issues

#### 1. Maven Build Fails

**Error**: `Could not resolve dependencies`

**Solution**:
```cmd
mvn clean install -U
```

#### 2. CDK Deploy Fails

**Error**: `CDK not bootstrapped`

**Solution**:
```cmd
cdk bootstrap aws://ACCOUNT-ID/REGION
```

#### 3. Lambda Function Timeout

**Error**: `Task timed out after 3.00 seconds`

**Solution**: Increase timeout in CDK:
```typescript
timeout: Duration.seconds(30)
```

#### 4. Database Connection Fails

**Error**: `Connection refused`

**Solution**:
- Check security group allows port 5432
- Verify RDS endpoint is correct
- Check Secrets Manager credentials

#### 5. CORS Errors in Frontend

**Error**: `Access-Control-Allow-Origin header is missing`

**Solution**: Configure CORS in API Gateway:
```typescript
defaultCorsPreflightOptions: {
  allowOrigins: ['*'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization']
}
```

### Logs and Monitoring

#### View Lambda Logs

```cmd
aws logs tail /aws/lambda/GetProfileHandler --follow
```

#### View API Gateway Logs

```cmd
aws logs tail /aws/apigateway/ProfileAPI --follow
```

#### CloudWatch Insights Query

```
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 20
```

---

## Deployment Checklist

### Pre-Deployment

- [ ] All unit tests passing
- [ ] Code coverage ≥ 70%
- [ ] SonarQube quality gate passed
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] Secrets stored in Secrets Manager
- [ ] IAM roles and policies configured

### Deployment

- [ ] Database migrations applied
- [ ] CDK infrastructure deployed
- [ ] Lambda functions deployed
- [ ] API Gateway configured
- [ ] Frontend built and deployed
- [ ] CloudFront distribution created (if applicable)

### Post-Deployment

- [ ] Smoke tests passed
- [ ] API endpoints responding
- [ ] Database connections working
- [ ] CloudWatch logs configured
- [ ] Monitoring and alerts set up
- [ ] Documentation updated

---

## Rollback Procedures

### Rollback Lambda Function

```cmd
# List versions
aws lambda list-versions-by-function --function-name GetProfileHandler

# Rollback to previous version
aws lambda update-alias ^
  --function-name GetProfileHandler ^
  --name PROD ^
  --function-version 2
```

### Rollback CDK Stack

```cmd
# Delete stack
cdk destroy ProfileLambdaStack

# Redeploy previous version
git checkout <previous-commit>
cdk deploy
```

### Rollback Database

```cmd
# Run rollback scripts
psql -U app_user -d user_management -f rollback/R4__drop_token_blacklist_table.sql
psql -U app_user -d user_management -f rollback/R3__drop_login_attempts_table.sql
```

---

## CI/CD Pipeline (Future)

### GitHub Actions Example

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Java
        uses: actions/setup-java@v2
        with:
          java-version: '17'
      
      - name: Build with Maven
        run: mvn clean package
        working-directory: ProfileManager-API
      
      - name: Run tests
        run: mvn test
        working-directory: ProfileManager-API
      
      - name: Deploy CDK
        run: |
          npm install
          cdk deploy --require-approval never
        working-directory: ProfileManager-CDK
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

## Support

For deployment issues:
- **Backend**: backend-team@example.com
- **Infrastructure**: devops-team@example.com
- **Documentation**: See individual README files in each directory

---

**Last Updated**: 2024-02-12  
**Version**: 1.0.0
