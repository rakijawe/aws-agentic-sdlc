# Implementation Plan: User Authentication, Registration, and Profile Management

## Overview

This implementation plan breaks down the user authentication, registration, and profile management system into discrete, actionable tasks. Each task is mapped to specific requirement types to ensure complete traceability from requirements through implementation.

**Technology Stack:**
- **Backend**: Java 17, AWS Lambda, API Gateway, Maven
- **Frontend**: React 18+, TypeScript, Material-UI (MUI)
- **Database**: PostgreSQL 16.11 (Amazon RDS)
- **Infrastructure**: AWS CloudFormation (Lambda deployment)
- **DevOps**: GitHub Actions, Docker, SonarQube
- **Email Service**: AWS SES for email verification
- **OAuth2**: Google and Amazon OAuth2 integration
- **Design**: Figma for UI/UX specifications

**Figma Design Reference**: #[[figma:https://www.figma.com/design/GGoFL7U4ljuiJxfQ1VBBbi/POC?node-id=1-1077&t=jPWNYDTKebx4Ygd4-1]]

## Deployment Strategy

**IMPORTANT - Task Execution Order**:
This project follows an infrastructure-first approach with placeholder code:
1. **Phase 1 (Task 1)**: Set up infrastructure with placeholder Lambda handler
2. **Phase 2 (Tasks 2-4)**: Build database schema and utility classes
3. **Phase 3 (Tasks 5-11)**: Implement real Lambda handlers (replaces placeholder)
4. **Continuous**: GitHub Actions automatically deploys code changes to Lambda

**Why this order?**
- Infrastructure can be tested independently before writing complex code
- GitHub Actions works from day 1 with placeholder code
- Real handlers are deployed incrementally via CI/CD pipeline
- Reduces risk by separating infrastructure issues from code issues

**Infrastructure Setup (One-Time)**:
- Create and run deployment script: `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
- Uses CloudFormation template: `ProfileManager-CDK/aws/lambda-infrastructure.yml`
- Creates: VPC, Lambda, API Gateway, RDS PostgreSQL, Secrets Manager, CloudWatch
- **Deploys with**: Placeholder Lambda handler (Task 1.0.7) that returns success message

**Continuous Deployment (Automated)**:
- GitHub Actions workflow: `.github/workflows/ci-cd-lambda.yml`
- Triggers: Push to main branch or PR merge
- Pipeline: Build → Test → Upload to S3 → Update Lambda function
- No infrastructure changes on each deployment, only Lambda code updates
- **Initially deploys**: Placeholder handler
- **Later deploys**: Real handlers from Tasks 5-11

**Key Files to Create**:
- Infrastructure: `ProfileManager-CDK/aws/lambda-infrastructure.yml`
- Deployment Script: `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
- CI/CD Pipeline: `.github/workflows/ci-cd-lambda.yml`
- Database Migrations: `ProfileManager-CDK/resources/db/migration/`
- Application Config: `ProfileManager-CDK/resources/application-lambda.properties`

## Requirement Type Legend

- **FR**: Functional Requirement - Core business functionality and user interactions
- **UI**: UI/UX Requirement - User interface design, layout, and user experience
- **VR**: Validation Requirement - Input validation and data integrity rules
- **SR**: Security Requirement - Authentication, authorization, and security controls
- **DR**: Data Requirement - Data storage, retrieval, and management
- **BR**: Business Rule - Business logic and policy enforcement
- **PR**: Performance Requirement - System performance and responsiveness

## Implementation Phases

### Phase 1: Infrastructure & Security (Week 1)
Focus on foundational infrastructure and security components

### Phase 2: Registration & Email Verification (Week 2)
Implement user registration with email and social login

### Phase 3: Social Login Integration (Week 3)
Integrate OAuth2 for Google and Amazon

### Phase 4: Core Authentication (Week 4)
Implement login functionality with validation

### Phase 5: Validation Layer (Week 5)
Build comprehensive validation for all inputs

### Phase 6: Profile Management (Week 6)
Implement profile CRUD operations

### Phase 7: Testing & Deployment (Week 7)
Complete testing and deploy to production

## Tasks

### Task 1: Set up AWS Lambda infrastructure using CloudFormation
**Phase**: 1 - Infrastructure & Security  
**Requirement Types**: PR (Performance Requirement)  
**Team**: @team:devops @component:devops-infra @priority:high  
**Requirements**: All requirements (infrastructure foundation)

**Description**: Deploy the foundational AWS Lambda infrastructure. This task will guide you through creating all necessary infrastructure files from scratch and deploying them to AWS.

**Infrastructure Files to Create**:
- CloudFormation Template: `ProfileManager-CDK/aws/lambda-infrastructure.yml`
- Deployment Script: `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
- GitHub Actions Workflow: `.github/workflows/ci-cd-lambda.yml`
- Application Properties: `ProfileManager-CDK/resources/application-lambda.properties`

**Sub-tasks**:
- [ ] 1.0 Create infrastructure files (complete infrastructure as code setup)
  
  **IMPORTANT**: This task assumes NO infrastructure files exist. You will create everything from scratch following the detailed specifications below.
  
  **1.0.1 Create CloudFormation template**: `ProfileManager-CDK/aws/lambda-infrastructure.yml`
  - Create directory: `ProfileManager-CDK/aws/`
  - **Template structure** (600+ lines of YAML):
    - **Parameters section**: 
      - EnvironmentName (String, default: production)
      - DatabaseUsername (String, default: postgres, NoEcho: true)
      - DatabasePassword (String, MinLength: 8, NoEcho: true)
      - DeploymentBucketName (String, for S3 bucket)
    - **VPC Resources**: 
      - VPC with CIDR 10.0.0.0/16
      - 2 private subnets (10.0.1.0/24, 10.0.2.0/24) in different AZs
      - Route tables and associations
      - Security group for Lambda (allow outbound to RDS)
      - Security group for RDS (allow inbound from Lambda on port 5432)
    - **RDS PostgreSQL**: 
      - Engine: postgres, Version: 16.11
      - Instance class: db.t3.micro
      - Allocated storage: 20 GB
      - DB subnet group with both private subnets
      - Master username/password from parameters
      - Backup retention: 7 days
    - **Lambda Function**: 
      - Runtime: java17
      - Handler: `com.myorg.usermanagement.handler.StreamLambdaHandler::handleRequest`
      - Memory: 2048 MB
      - Timeout: 30 seconds
      - VPC configuration: Use private subnets and Lambda security group
      - Code: S3 bucket and key (user-registration.jar)
      - Environment variables: SPRING_DATASOURCE_URL, SPRING_DATASOURCE_USERNAME, SPRING_PROFILES_ACTIVE
    - **HTTP API Gateway**: 
      - Protocol: HTTP
      - Route: `ANY /{proxy+}` (proxy integration to Lambda)
      - Route: `ANY /` (root route)
      - Stage: `${EnvironmentName}` (auto-deploy)
      - Integration: Lambda proxy with PayloadFormatVersion 2.0
      - Lambda permission for API Gateway invoke
    - **Secrets Manager**: 
      - Secret name: `${EnvironmentName}/lambda/user-registration/secrets`
      - Secret string with keys: SPRING_DATASOURCE_PASSWORD, EMAIL_USERNAME, EMAIL_PASSWORD, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, AMAZON_CLIENT_ID, AMAZON_CLIENT_SECRET, ENCRYPTION_KEY
    - **CloudWatch Log Groups**: 
      - API Gateway log group: `/aws/apigateway/${EnvironmentName}/user-registration`
      - Lambda log group: `/aws/lambda/${LambdaFunction}`
      - Retention: 7 days
    - **IAM Roles**: 
      - Lambda execution role with managed policies: AWSLambdaVPCAccessExecutionRole, AWSLambdaBasicExecutionRole
      - Custom policy for Secrets Manager access (secretsmanager:GetSecretValue)
    - **Outputs**: 
      - ApiEndpoint, LambdaFunctionArn, DeploymentBucketName, DatabaseEndpoint
  
  **1.0.2 Create deployment script**: `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
  - Create directory: `ProfileManager-CDK/scripts/`
  - **Script structure** (PowerShell, 300+ lines):
    - **Parameters**: 
      ```powershell
      param(
          [string]$StackName = "user-registration-lambda",
          [string]$Environment = "production",
          [string]$Region = "us-east-1"
      )
      ```
    - **Step 1 - Prerequisites check**: 
      - Check AWS CLI installed: `Get-Command aws`
      - Check AWS credentials: `aws sts get-caller-identity`
      - Get AWS account ID for bucket naming
    - **Step 2 - Configuration prompts**: 
      - Prompt for stack name (with default)
      - Prompt for environment name
      - Prompt for AWS region
      - Prompt for database username (default: postgres)
      - Prompt for database password (secure string, min 8 chars)
    - **Step 3 - Build application**: 
      - Set Maven path (adjust for your system): `$mvnPath = "C:\Users\CAESAR\Downloads\apache-maven-3.9.12-bin\apache-maven-3.9.12\bin\mvn.cmd"`
      - Calculate ProfileManager-API directory: `$apiDir = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "ProfileManager-API"`
      - Navigate to API directory: `Push-Location $apiDir`
      - Run Maven build: `& $mvnPath clean package -DskipTests`
      - Find shaded JAR: `Get-ChildItem -Path "$apiDir\target" -Filter "*-aws.jar"`
      - Verify build success and JAR exists
    - **Step 4 - S3 bucket management**: 
      - Generate bucket name: `$bucketName = "$Environment-lambda-deployments-$accountId"`
      - Check if bucket exists: `aws s3 ls s3://$bucketName`
      - Create if not exists: `aws s3 mb s3://$bucketName --region $Region`
    - **Step 5 - Upload JAR to S3**: 
      - Upload command: `aws s3 cp $jarFile s3://$bucketName/user-registration.jar`
      - Verify upload success
    - **Step 6 - Deploy CloudFormation stack**: 
      - Get template path: `$templatePath = Join-Path (Split-Path $PSScriptRoot -Parent) "aws\lambda-infrastructure.yml"`
      - Verify template exists
      - Deploy command: `aws cloudformation create-stack --stack-name $StackName --template-body file://$templatePath --parameters ParameterKey=EnvironmentName,ParameterValue=$Environment ... --capabilities CAPABILITY_IAM --region $Region`
      - Wait for completion: `aws cloudformation wait stack-create-complete --stack-name $StackName --region $Region`
    - **Step 7 - Update Lambda code**: 
      - Get Lambda function ARN from stack outputs
      - Extract function name from ARN
      - Update function code: `aws lambda update-function-code --function-name $functionName --s3-bucket $bucketName --s3-key user-registration.jar`
      - Wait for update: `aws lambda wait function-updated --function-name $functionName`
    - **Step 8 - Verification and outputs**: 
      - Get stack outputs: API endpoint, Lambda ARN, DB endpoint
      - Display summary with all endpoints and resources
      - Provide next steps (update secrets, test API)
    - **Error handling**: Check `$LASTEXITCODE` after each command, exit with error message if non-zero
  
  **1.0.3 Create application properties**: `ProfileManager-CDK/resources/application-lambda.properties`
  - Create directory: `ProfileManager-CDK/resources/`
  - **Properties content**:
    ```properties
    # Database Configuration (from Lambda environment variables)
    spring.datasource.url=${SPRING_DATASOURCE_URL}
    spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
    spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}
    spring.datasource.driver-class-name=org.postgresql.Driver
    
    # Connection Pool
    spring.datasource.hikari.maximum-pool-size=10
    spring.datasource.hikari.connection-timeout=5000
    
    # Logging
    logging.level.root=INFO
    logging.level.com.myorg=DEBUG
    ```
  
  **1.0.4 Create GitHub Actions workflow**: `.github/workflows/ci-cd-lambda.yml`
  - Create directory: `.github/workflows/` (in repository root)
  - **Workflow structure** (YAML, 150+ lines):
    - **Name and triggers**:
      ```yaml
      name: CI/CD Pipeline (AWS Lambda)
      on:
        push:
          branches: [main, master]
        pull_request:
          branches: [main, master]
      ```
    - **Environment variables**:
      ```yaml
      env:
        JAVA_VERSION: '17'
        MAVEN_OPTS: -Xmx1024m
        AWS_REGION: us-east-1
        MAVEN_PATH: ProfileManager-API
      ```
    - **Job 1 - build-and-test** (runs on all pushes and PRs):
      - Checkout code: `actions/checkout@v4`
      - Setup JDK 17: `actions/setup-java@v4` with distribution: 'temurin', cache: maven
      - Build: `mvn clean compile -DskipTests` in ProfileManager-API directory
      - Run tests: `mvn test`
      - Generate coverage: `mvn jacoco:report` (requires Jacoco plugin in pom.xml)
      - Upload test results: `actions/upload-artifact@v4` with name: test-results
      - Upload coverage report: `actions/upload-artifact@v4` with name: coverage-report
      - Build Lambda JAR (only on main/master branch): `mvn clean package -DskipTests`
      - Upload JAR artifact (only on main/master branch): `actions/upload-artifact@v4` with name: lambda-jar
    - **Job 2 - deploy-lambda** (only on push to main/master, depends on build-and-test):
      - Download JAR artifact: `actions/download-artifact@v4`
      - Configure AWS credentials: `aws-actions/configure-aws-credentials@v4` using secrets
      - Determine environment: main → production, master → test (or use TEST_STACK_NAME for main)
      - Get deployment bucket from CloudFormation outputs
      - Upload to S3: `aws s3 cp target/*-aws.jar s3://$BUCKET_NAME/user-registration.jar`
      - Get Lambda function name from CloudFormation outputs
      - Update Lambda: `aws lambda update-function-code --function-name $FUNCTION_NAME --s3-bucket $BUCKET_NAME --s3-key user-registration.jar`
      - Wait for update: `aws lambda wait function-updated --function-name $FUNCTION_NAME`
      - Test deployment: Health check with curl
      - Display summary: Function name, API endpoint, bucket name, environment
    - **Required GitHub secrets**: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ACCOUNT_ID, TEST_STACK_NAME (or PROD_STACK_NAME)
  
  **1.0.5 Create additional configuration files**:
  - `ProfileManager-CDK/resources/application-test.properties` - Override properties for test environment
  - `ProfileManager-CDK/resources/application.properties` - Default properties (fallback)
  
  **1.0.6 Add Jacoco plugin to pom.xml**:
  - Open `ProfileManager-API/pom.xml`
  - Add Jacoco Maven plugin in `<build><plugins>` section:
    ```xml
    <plugin>
        <groupId>org.jacoco</groupId>
        <artifactId>jacoco-maven-plugin</artifactId>
        <version>0.8.11</version>
        <executions>
            <execution>
                <goals>
                    <goal>prepare-agent</goal>
                </goals>
            </execution>
            <execution>
                <id>report</id>
                <phase>test</phase>
                <goals>
                    <goal>report</goal>
                </goals>
            </execution>
        </executions>
    </plugin>
    ```
  
  **Note**: These instructions provide complete details for creating all infrastructure files from scratch following AWS CloudFormation and PowerShell best practices.

- [ ] 1.0.7 Create minimal placeholder Lambda handler (CRITICAL - DO THIS BEFORE DEPLOYMENT)
  - **Purpose**: Provide a working Lambda function for initial infrastructure deployment
  - **Why**: Infrastructure deployment (Task 1.2) requires a JAR file to deploy. Real Lambda handlers are created in Tasks 5-11, so we need a placeholder first.
  - **Location**: `ProfileManager-API/src/main/java/com/myorg/usermanagement/handler/StreamLambdaHandler.java`
  - **Implementation**:
    ```java
    package com.myorg.usermanagement.handler;
    
    import com.amazonaws.services.lambda.runtime.Context;
    import com.amazonaws.services.lambda.runtime.RequestHandler;
    import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
    import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
    import java.util.HashMap;
    import java.util.Map;
    
    public class StreamLambdaHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
        @Override
        public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
            context.getLogger().log("Placeholder handler invoked - Path: " + input.getPath());
            
            APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent();
            response.setStatusCode(200);
            
            Map<String, String> headers = new HashMap<>();
            headers.put("Content-Type", "application/json");
            response.setHeaders(headers);
            
            String body = String.format(
                "{\"message\": \"Infrastructure deployed successfully\", " +
                "\"status\": \"placeholder\", " +
                "\"path\": \"%s\", " +
                "\"note\": \"Real handlers will be deployed in subsequent tasks\"}",
                input.getPath()
            );
            response.setBody(body);
            
            return response;
        }
    }
    ```
  - **Verify build**: Run `mvn clean package` in ProfileManager-API directory to ensure JAR is created successfully
  - **Test locally**: Verify the handler compiles without errors
  - **Note**: This placeholder will be replaced/extended when implementing real handlers in Tasks 5-11
  - **Important**: Without this placeholder, Task 1.2 (infrastructure deployment) will fail because there's no code to build and deploy
  
- [x] 1.1 Review and validate infrastructure files
  - **Validate CloudFormation template**:
    - Run: `aws cloudformation validate-template --template-body file://ProfileManager-CDK/aws/lambda-infrastructure.yml`
    - Check for syntax errors
    - Verify all required parameters are defined
    - Verify outputs section includes: LambdaFunctionArn, ApiEndpoint, DatabaseEndpoint
  - **Validate deployment script**:
    - Check Maven path is correct for your system
    - Verify script can find ProfileManager-API directory
    - Test AWS CLI commands work
    - Verify S3 bucket naming convention
  - **Validate application properties**:
    - Check all required properties are defined
    - Verify environment variable placeholders (${VAR_NAME})
    - Ensure no hardcoded credentials
  - **Validate GitHub Actions workflow**:
    - Check YAML syntax: Use online YAML validator
    - Verify job dependencies are correct
    - Check artifact names match between jobs
    - Verify AWS CLI commands are correct
  - **Review infrastructure components**:
    - VPC: 10.0.0.0/16 with 2 private subnets
    - RDS: PostgreSQL 16.11, db.t3.micro
    - Lambda: Java 17, 2048 MB memory, 30s timeout
    - API Gateway: HTTP API with proxy integration
    - Secrets Manager: Secret for credentials
    - CloudWatch: Log groups with 30-day retention
  
- [ ] 1.2 Initial infrastructure deployment with placeholder code (one-time setup)
  - **Prerequisites**: Task 1.0.7 MUST be completed first (placeholder handler must exist)
  - Run `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
  - Provide parameters: stack name, environment, region, DB credentials
  - Script will: build placeholder JAR, create S3 bucket, upload code, deploy CloudFormation stack
  - Verify stack creation in AWS Console
  - Note: This takes 10-15 minutes
  - **Important**: Ensure Maven path is correct in script (default: `C:\Users\CAESAR\Downloads\apache-maven-3.9.12-bin\apache-maven-3.9.12\bin\mvn.cmd`)
  - **Important**: CloudFormation template path must be relative to script location
  - **Deployed Resources**: VPC, Lambda (with placeholder handler), HTTP API Gateway (with proxy integration), RDS PostgreSQL 16.11, Secrets Manager, CloudWatch, S3 bucket
  - **Verify deployment**: Test API endpoint with `curl {ApiEndpoint}` - should return placeholder message
  - **Note**: This deploys infrastructure with a placeholder Lambda handler. Real handlers will be deployed in Tasks 5-11 via GitHub Actions
  
- [x] 1.3 Configure Secrets Manager values
  - **Create configuration script**: `ProfileManager-CDK/scripts/configure-secrets.ps1`
  - **Create documentation**: `ProfileManager-CDK/SECRETS_CONFIGURATION.md`
  - Update secrets in AWS Secrets Manager: `{environment}/lambda/user-registration/secrets`
  - Set EMAIL_USERNAME and EMAIL_PASSWORD (for SES)
  - Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET
  - Set AMAZON_CLIENT_ID and AMAZON_CLIENT_SECRET
  - Set ENCRYPTION_KEY (base64 encoded 32-byte key)
  - Script supports both interactive and non-interactive modes
  
- [x] 1.4 Configure AWS SES for email sending
  - **Create configuration script**: `ProfileManager-CDK/scripts/configure-ses.ps1`
  - **Create documentation**: `ProfileManager-CDK/SES_CONFIGURATION.md`
  - Verify sender email address in SES console
  - Request production access (move out of sandbox)
  - Test email sending with verification template
  - Configure SES region in Lambda environment variables
  - Script can verify emails, send test emails, and guide production access request
  
- [x] 1.5 Set up GitHub Actions for CI/CD (automated deployments)
  - **Update existing workflow file**: `.github/workflows/ci-cd-lambda.yml`
    - Fix paths to work with ProfileManager-API directory structure
    - Add support for both `main` and `master` branches
    - Improve environment detection (test vs production)
    - Auto-detect deployment bucket and Lambda function names from CloudFormation
    - Add better error handling and logging
    - Add deployment summary with key information
    - Upload test results and coverage reports as artifacts
  - **Create setup script**: `ProfileManager-CDK/scripts/setup-github-secrets.ps1`
  - **Create documentation**: `ProfileManager-CDK/GITHUB_ACTIONS_SETUP.md`
  - **Add Jacoco plugin** to `ProfileManager-API/pom.xml` for coverage reports
  - **Move .github folder** from ProfileManager-CDK/ to repository root
  - Configure GitHub secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ACCOUNT_ID, TEST_STACK_NAME
  - Triggers: Push to main branch automatically deploys to Lambda
  - Pipeline: Build → Test (with Jacoco coverage) → Upload to S3 → Update Lambda function
  - **Important**: Workflow uses TEST_STACK_NAME for main branch (not PROD_STACK_NAME)
  - **Important**: GitHub CLI is optional - script provides manual setup instructions if not installed
  - **Note**: Initial GitHub Actions runs will deploy the placeholder handler from Task 1.0.7
  - **Note**: Once real handlers are implemented (Tasks 5-11), GitHub Actions will automatically deploy them on push to main
  - **Test the workflow**: Make a small change to the placeholder handler and push to main to verify CI/CD works
  
- [x] 1.6 Verify infrastructure deployment
  - Test API endpoint: `curl {ApiEndpoint}` should return placeholder message with status 200
  - Expected response: `{"message": "Infrastructure deployed successfully", "status": "placeholder", ...}`
  - Check CloudWatch logs: `/aws/lambda/{FunctionName}` - should show placeholder handler invocations
  - Verify RDS database connectivity (can connect from Lambda VPC)
  - Test Lambda function invocation directly via AWS Console
  - Review CloudFormation stack outputs (API endpoint, DB endpoint, Lambda ARN)
  - **Note**: At this point, infrastructure is fully deployed and working with placeholder code
  - **Next steps**: Proceed with Tasks 2-4 (database and utilities), then Tasks 5-11 (real Lambda handlers)

---

### Task 2: Create database schema and migration scripts
**Phase**: 1 - Infrastructure & Security  
**Requirement Types**: DR (Data Requirement)  
**Team**: @team:backend @component:backend-data @priority:high  
**Requirements**: Req 2 (FR+SR), Req 6 (FR+SR), Req 14 (SR), Req 16 (UI+DR), Req 18 (UI), Req 19 (UI+VR), Req 22 (UI+VR)

**Description**: Design and implement the PostgreSQL database schema to store user authentication, registration, and profile data.

**Migration Directory**: `ProfileManager-CDK/resources/db/migration/`

**Sub-tasks**:
- [ ] 2.1 Create users table (Customer_Identity) with all required fields
  - **Requirement Type**: DR (Data Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Email Registration), Req 6 (Email Verification), Req 16 (Display Profile Fields), Req 18 (Title Field), Req 19 (Gender Field), Req 22 (Preferences)
  - Create migration file: `V1__create_customer_identity_table.sql`
  - Define table structure with proper constraints (NOT NULL, CHECK, UNIQUE)
  - Add indexes for email, account_locked, verification_token, and provider fields
  - Include fields: id, title, first_name, last_name, gender, age, email, password_hash, address, account_locked, locked_until, email_verified, verification_token, verification_token_expiry, auth_provider, provider_id, created_at, updated_at
  - Add UNIQUE constraint on email column
  - Add CHECK constraint on age (18-120)
  - Note: V1 migration already exists, review and update if needed
  
- [ ] 2.2 Create user_preferences table
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 22 (Preferences Selection)
  - Create migration file: `V2__create_user_preferences_table.sql`
  - Define foreign key relationship to users table with CASCADE delete
  - Add index on user_id for join performance
  - Include fields: user_id, preference
  
- [ ] 2.3 Create login_attempts table
  - **Requirement Type**: SR (Security Requirement) + DR (Data Requirement)
  - **Requirements**: Req 14 (Account Locking)
  - Create migration file: `V3__create_login_attempts_table.sql`
  - Define table for tracking authentication attempts
  - Add indexes for email and timestamp queries
  - Include fields: id, email, timestamp, successful, ip_address
  
- [ ] 2.4 Create token_blacklist table for logout
  - **Requirement Type**: SR (Security Requirement) + DR (Data Requirement)
  - **Requirements**: Req 9 (Successful Login - logout flow)
  - Create migration file: `V4__create_token_blacklist_table.sql`
  - Define table for storing invalidated JWT tokens
  - Add index on token_hash and expiry
  - Include fields: id, token_hash, expiry, created_at
  
- [x] 2.5 Set up database migration structure
  - Migration directory created: `ProfileManager-CDK/resources/db/migration/`
  - Rollback directory created: `ProfileManager-CDK/resources/db/rollback/` (if needed)
  - Use Flyway or Liquibase for migration execution

---

### Task 3: Implement shared Lambda layer utilities
**Phase**: 1 - Infrastructure & Security  
**Requirement Types**: SR (Security Requirement), VR (Validation Requirement), FR (Functional Requirement)  
**Team**: @team:backend @component:backend-service @priority:high  
**Requirements**: Req 2 (FR+SR), Req 3 (SR+VR), Req 7 (VR), Req 9 (FR), Req 12 (SR+VR), Req 13 (VR), Req 17 (VR+BR), Req 20 (VR+BR), Req 21 (VR), Req 22 (UI+VR)

**Description**: Create reusable utility classes for Lambda functions including database access, security, validation, OAuth2, and email services.

**Sub-tasks**:
- [ ] 3.1 Create database connection utility
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: All backend requirements
  - Implement Secrets Manager client for credential retrieval
  - Create JDBC connection factory with RDS Proxy support
  - Add connection pooling and timeout configuration (5s connection, 30s query)
  - Use SLF4J for logging (per Java conventions)
  
- [ ] 3.2 Implement password hashing utility
  - **Requirement Type**: SR (Security Requirement)
  - **Requirements**: Req 3 (Registration Password Complexity), Req 12 (Password Format Validation)
  - Use BCrypt for password hashing with salt rounds = 10
  - Implement hash generation method
  - Implement hash verification method
  - Never store plain text passwords
  
- [ ] 3.3 Create JWT token utility
  - **Requirement Type**: SR (Security Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 2 (Email Registration), Req 9 (Successful Login)
  - Implement JWT token generation with configurable expiry (default 1 hour)
  - Add token validation and parsing methods
  - Retrieve JWT secret from Secrets Manager
  - Include user ID, email, and auth provider in token claims
  
- [ ] 3.4 Implement validation utility classes
  - **Requirement Type**: VR (Validation Requirement)
  - **Requirements**: Req 3 (Password), Req 7 (Email), Req 13 (Email), Req 17 (Mandatory Fields), Req 19 (Gender), Req 20 (Age), Req 21 (Email in Profile), Req 22 (Preferences)
  - Create EmailValidator class with regex pattern
  - Create PasswordValidator class with complexity rules
  - Create AgeValidator class with range check (18-120)
  - Create MandatoryFieldValidator class
  - Create PreferencesValidator class
  
- [ ] 3.5 Implement OAuth2 client utility
  - **Requirement Type**: SR (Security Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 4 (Social Login Registration)
  - Create OAuth2Client class for Google and Amazon
  - Implement authorization code exchange for access token
  - Implement user profile retrieval from provider
  - Handle OAuth2 errors and token expiry
  
- [ ] 3.6 Implement email service utility
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 6 (Email Verification)
  - Create EmailService class using AWS SES
  - Implement sendVerificationEmail method
  - Generate unique verification tokens
  - Create email templates for verification
  
- [ ] 3.7 Write property test for email validation
  - **Requirement Type**: VR (Validation Requirement)
  - **Property 4**: Email format validation during registration
  - **Validates**: Req 7 (Registration Email Format Validation), Req 13 (Email Format Validation), Req 21 (Email Validation in Profile)
  - Test with randomly generated invalid emails (no @, no domain, with spaces)
  - Minimum 100 iterations
  
- [ ] 3.8 Write property test for password complexity validation
  - **Requirement Type**: SR (Security Requirement) + VR (Validation Requirement)
  - **Property 2**: Password complexity validation during registration
  - **Validates**: Req 3 (Registration Password Complexity), Req 12 (Password Format Validation)
  - Test with randomly generated passwords missing complexity requirements
  - Minimum 100 iterations
  
- [ ] 3.9 Write property test for age range validation
  - **Requirement Type**: VR (Validation Requirement) + BR (Business Rule)
  - **Property 12**: Age range validation
  - **Validates**: Req 20 (Age Validation)
  - Test with randomly generated ages outside range (< 18, > 120, non-numeric)
  - Minimum 100 iterations
  
- [ ] 3.10 Create exception classes
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 2 (Duplicate Email), Req 6 (Email Verification), Req 10 (Invalid Credentials), Req 14 (Account Locking), Req 17 (Mandatory Fields), Req 19 (Gender Validation)
  - Define DuplicateEmailException for registration failures
  - Define EmailNotVerifiedException for unverified accounts
  - Define InvalidCredentialsException for authentication failures
  - Define AccountLockedException for locked accounts
  - Define ValidationException for field validation failures
  - Define ProfileNotFoundException for missing profiles
  - Define OAuth2Exception for OAuth2 failures
  - All exceptions extend RuntimeException
  
- [ ] 3.11 Implement Lambda exception handler
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: All error handling requirements
  - Create centralized LambdaExceptionHandler class
  - Map exceptions to appropriate HTTP status codes (400, 401, 403, 404, 500)
  - Format error responses consistently with JSON structure
  - Include timestamp and error details

---

### Task 4: Implement repository classes
**Phase**: 1 - Infrastructure & Security  
**Requirement Types**: DR (Data Requirement), FR (Functional Requirement), SR (Security Requirement)  
**Team**: @team:backend @component:backend-data  
**Requirements**: Req 2 (FR+SR), Req 5 (BR+SR), Req 6 (FR+SR), Req 9 (FR), Req 10 (FR), Req 14 (SR), Req 15 (UI), Req 23 (FR+DR)

**Description**: Implement repository pattern classes for database access using JDBC.

**Sub-tasks**:
- [ ] 4.1 Create UserRepository class
  - **Requirement Type**: DR (Data Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 2 (Email Registration), Req 5 (Duplicate Account Prevention), Req 9 (Successful Login), Req 10 (Invalid Credentials), Req 15 (View Profile Page), Req 23 (Save Profile)
  - Implement findByEmail(String email) method with JDBC PreparedStatement
  - Implement existsByEmail(String email) method for duplicate check
  - Implement save(User user) method for insert/update operations
  - Implement findById(Long id) method
  - Implement markEmailVerified(String email) method
  - Use SLF4J for logging all database operations
  - Handle SQLException with proper error messages
  
- [ ] 4.2 Create LoginAttemptRepository class
  - **Requirement Type**: SR (Security Requirement) + DR (Data Requirement)
  - **Requirements**: Req 14 (Account Locking)
  - Implement findRecentAttempts(String email, int minutes) method
  - Implement save(LoginAttempt attempt) method for recording attempts
  - Implement deleteOldAttempts(String email, int minutes) cleanup method
  - Use SLF4J for logging security events
  
- [ ]* 4.3 Write unit tests for repository classes
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 2, Req 5, Req 6, Req 9, Req 10, Req 14, Req 23
  - Test CRUD operations with H2 in-memory database
  - Test query methods with various inputs (valid, invalid, edge cases)
  - Test duplicate email detection
  - Test email verification marking
  - Test error handling for database failures
  - Target 70% minimum coverage (per Java conventions)
  - Use JUnit 5 and Mockito

---

### Task 5: Implement RegistrationHandler Lambda function
**Phase**: 2 - Registration & Email Verification  
**Requirement Types**: FR (Functional Requirement), SR (Security Requirement), VR (Validation Requirement), BR (Business Rule)  
**Team**: @team:backend @component:backend-api @priority:high  
**Requirements**: Req 2 (FR+SR), Req 3 (SR+VR), Req 5 (BR+SR), Req 7 (VR)  
**Figma Reference**: Registration Page - Email registration form, Error states, Duplicate email error

**Description**: Implement the Lambda function that handles user registration requests with email and password.

**Sub-tasks**:
- [ ] 5.1 Create Lambda handler class and request parsing
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 2 (Email Registration)
  - **Note**: This task extends/replaces the placeholder handler created in Task 1.0.7
  - **Implementation approach**: Update StreamLambdaHandler to route requests to RegistrationHandler based on path
  - Create RegistrationHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent to extract email and password
  - Set up CloudWatch logging with SLF4J
  - Validate request body format
  - **Routing logic**: StreamLambdaHandler should check request path and delegate to appropriate handler
  - **Example routing**: 
    - `/register` → RegistrationHandler
    - `/login` → AuthLoginHandler (Task 8)
    - `/verify` → EmailVerificationHandler (Task 6)
    - etc.
  
- [ ] 5.2 Implement registration validation logic
  - **Requirement Type**: VR (Validation Requirement) + SR (Security Requirement)
  - **Requirements**: Req 3 (Registration Password Complexity), Req 7 (Registration Email Format Validation)
  - Validate email format using EmailValidator
  - Validate password complexity using PasswordValidator
  - Return 400 with appropriate error messages on validation failure
  
- [ ] 5.3 Implement duplicate email check
  - **Requirement Type**: BR (Business Rule) + SR (Security Requirement)
  - **Requirements**: Req 5 (Duplicate Account Prevention)
  - Check if email already exists using UserRepository.existsByEmail()
  - Return 400 with message "An account with this email already exists" if duplicate
  - Log duplicate registration attempts to CloudWatch
  
- [ ] 5.4 Implement user account creation
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Email Registration)
  - Hash password using BCrypt
  - Generate email verification token (UUID)
  - Set verification token expiry (24 hours)
  - Create user record in Customer_Identity table with email_verified = false
  - Set auth_provider = 'email'
  - Log registration event to CloudWatch
  
- [ ] 5.5 Implement email verification sending
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Email Registration), Req 6 (Email Verification)
  - Send verification email via SES using EmailService
  - Include verification link with token
  - Return 201 with success message
  - Handle SES errors gracefully
  
- [ ]* 5.6 Write property test for unique email registration
  - **Requirement Type**: BR (Business Rule) + SR (Security Requirement)
  - **Property 1**: Unique email registration
  - **Validates**: Req 2.3 (Duplicate Email), Req 5.2 (Duplicate Account Prevention)
  - Test with randomly generated emails
  - Verify duplicate email returns error message
  - Minimum 100 iterations
  
- [ ]* 5.7 Write unit tests for registration
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2, Req 3, Req 5, Req 7
  - Test successful registration with valid data
  - Test duplicate email detection
  - Test password complexity validation
  - Test email format validation
  - Test verification email sending
  - Use JUnit 5 and Mockito

---

### Task 6: Implement EmailVerificationHandler Lambda function
**Phase**: 2 - Registration & Email Verification  
**Requirement Types**: FR (Functional Requirement), SR (Security Requirement)  
**Team**: @team:backend @component:backend-api @priority:high  
**Requirements**: Req 6 (FR+SR)  
**Figma Reference**: Email verification flow, Verification success page

**Description**: Implement the Lambda function that handles email verification requests.

**Sub-tasks**:
- [ ] 6.1 Create Lambda handler class
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 6 (Email Verification)
  - Create EmailVerificationHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent
  - Extract verification token from query parameters
  - Set up CloudWatch logging with SLF4J
  
- [ ] 6.2 Implement verification logic
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 6 (Email Verification)
  - Query user by verification token
  - Check if token is expired (> 24 hours)
  - Mark account as verified using UserRepository.markEmailVerified()
  - Clear verification token and expiry
  - Return 200 with success message
  - Return 400 for invalid/expired tokens
  - Log verification events to CloudWatch
  
- [ ]* 6.3 Write property test for email verification requirement
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Property 3**: Email verification requirement
  - **Validates**: Req 6.3 (Unverified Email Login Prevention)
  - Test that unverified users cannot log in
  - Verify error message "Please verify your email address before logging in"
  - Minimum 100 iterations
  
- [ ]* 6.4 Write unit tests for email verification
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 6
  - Test successful verification with valid token
  - Test expired token error
  - Test invalid token error
  - Test already verified account
  - Use JUnit 5 and Mockito

---

### Task 7: Implement OAuth2Handler Lambda function
**Phase**: 3 - Social Login Integration  
**Requirement Types**: FR (Functional Requirement), SR (Security Requirement)  
**Team**: @team:backend @component:backend-api @priority:high  
**Requirements**: Req 4 (FR+SR)  
**Figma Reference**: Registration Page - Social login buttons (Google, Amazon)

**Description**: Implement the Lambda function that handles OAuth2 authentication for Google and Amazon.

**Sub-tasks**:
- [ ] 7.1 Create Lambda handler class and request parsing
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4 (Social Login Registration)
  - Create OAuth2Handler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent
  - Extract authorization code and provider from request
  - Set up CloudWatch logging with SLF4J
  
- [ ] 7.2 Implement OAuth2 token exchange
  - **Requirement Type**: SR (Security Requirement)
  - **Requirements**: Req 4 (Social Login Registration)
  - Exchange authorization code for access token with provider
  - Retrieve OAuth2 client credentials from Secrets Manager
  - Handle Google and Amazon OAuth2 flows
  - Handle OAuth2 errors (invalid code, expired code)
  
- [ ] 7.3 Implement user profile retrieval from provider
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4 (Social Login Registration)
  - Retrieve user profile from provider (email, name)
  - Extract provider user ID
  - Validate email from provider
  
- [ ] 7.4 Implement account creation or linking
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4.2 (Create Account), Req 4.3 (Link Account)
  - Check if user exists by email
  - If not exists: Create new user record with auth_provider and provider_id
  - If exists: Link social login to existing account (update auth_provider and provider_id)
  - Set email_verified = true (provider verified)
  - Generate JWT token
  - Return token and user info
  - Log OAuth2 authentication events to CloudWatch
  
- [ ]* 7.5 Write unit tests for OAuth2 handler
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4
  - Test successful OAuth2 authentication with Google
  - Test successful OAuth2 authentication with Amazon
  - Test account creation for new user
  - Test account linking for existing user
  - Test OAuth2 errors (invalid code, provider errors)
  - Mock OAuth2 provider responses
  - Use JUnit 5 and Mockito

---

### Task 8: Implement AuthLoginHandler Lambda function
**Phase**: 4 - Core Authentication  
**Requirement Types**: FR (Functional Requirement), SR (Security Requirement)  
**Team**: @team:backend @component:backend-api @priority:high  
**Requirements**: Req 6.3 (FR+SR), Req 9 (FR), Req 10 (FR), Req 12 (SR+VR), Req 14 (SR)  
**Figma Reference**: Login Page - Error states, Account locked state, Unverified email state

**Description**: Implement the Lambda function that handles user authentication requests.

**Sub-tasks**:
- [ ] 8.1 Create Lambda handler class and request parsing
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 9 (Successful Login), Req 10 (Invalid Credentials)
  - Create AuthLoginHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent to extract email and password
  - Set up CloudWatch logging with SLF4J
  - Validate request body format
  
- [ ] 8.2 Implement authentication logic
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 6.3 (Email Verification Requirement), Req 9 (Successful Login), Req 14 (Account Locking)
  - Query user by email from database using UserRepository
  - Check if email is verified (email_verified = true)
  - If not verified: Return 403 with message "Please verify your email address before logging in"
  - Check if account is locked (account_locked = true and locked_until > now)
  - Verify password using BCrypt hash comparison
  - Generate JWT token on successful authentication
  - Return user info (id, email, firstName, lastName, provider) with token
  
- [ ] 8.3 Implement failed attempt tracking
  - **Requirement Type**: SR (Security Requirement)
  - **Requirements**: Req 14 (Account Locking)
  - Record failed login attempts in login_attempts table
  - Count recent failed attempts (last 30 minutes) using LoginAttemptRepository
  - Lock account after 5 consecutive failures (set account_locked = true, locked_until = now + 30 minutes)
  - Log account locking events to CloudWatch
  
- [ ] 8.4 Format response with proper HTTP status codes
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 9 (Successful Login), Req 10 (Invalid Credentials), Req 14 (Account Locking), Req 6.3 (Unverified Email)
  - Return 200 with JWT token and user info on success
  - Return 401 with "Invalid username or password" message on failure
  - Return 403 with "Account is locked" message for locked accounts
  - Return 403 with "Please verify your email address before logging in" for unverified accounts
  - Follow REST standards with proper headers (Content-Type, CORS)
  
- [ ]* 8.5 Write property test for successful login
  - **Requirement Type**: FR (Functional Requirement)
  - **Property 5**: Valid credentials authenticate successfully
  - **Validates**: Req 9 (Successful Login)
  - Test valid credentials return JWT token
  - Verify response format and status code 200
  - Verify token contains correct user claims
  - Minimum 100 iterations
  
- [ ]* 8.6 Write property test for invalid credentials
  - **Requirement Type**: FR (Functional Requirement)
  - **Property 6**: Invalid credentials return error message
  - **Validates**: Req 10 (Invalid Credentials)
  - Test with randomly generated invalid email/password combinations
  - Verify error message "Invalid username or password"
  - Minimum 100 iterations
  
- [ ]* 8.7 Write property test for account locking
  - **Requirement Type**: SR (Security Requirement)
  - **Property 10**: Account locking after failed attempts
  - **Validates**: Req 14 (Account Locking)
  - Test account locks after 5 consecutive failures
  - Verify locked account prevents login for 30 minutes
  - Verify account unlocks after 30 minutes
  - Minimum 100 iterations

---

### Task 9: Implement GetProfileHandler Lambda function
**Phase**: 6 - Profile Management  
**Requirement Types**: UI (UI/UX Requirement), DR (Data Requirement)  
**Team**: @team:backend @component:backend-api  
**Requirements**: Req 15 (UI), Req 16 (UI+DR)  
**Figma Reference**: Profile Management Page - Form layout

**Description**: Implement the Lambda function that retrieves user profile data.

**Sub-tasks**:
- [ ] 9.1 Create Lambda handler class
  - **Requirement Type**: UI (UI/UX Requirement) + DR (Data Requirement)
  - **Requirements**: Req 15 (View Profile Page), Req 16 (Display Profile Fields)
  - Create GetProfileHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent
  - Extract user ID from JWT token (validated by API Gateway authorizer)
  - Set up CloudWatch logging with SLF4J
  
- [ ] 9.2 Implement profile retrieval logic
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 15 (View Profile Page), Req 16 (Display Profile Fields)
  - Query user profile from database by user ID using UserRepository
  - Join with user_preferences table to get preferences list
  - Handle profile not found scenario (return 404)
  - Format profile data as JSON response with all 8 fields
  - Return 200 with profile data
  
- [ ]* 9.3 Write unit tests for profile retrieval
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 15, Req 16
  - Test successful profile fetch with all fields
  - Test profile not found error (404)
  - Test JWT token extraction
  - Mock database with H2 in-memory database

---

### Task 10: Implement UpdateProfileHandler Lambda function
**Phase**: 6 - Profile Management  
**Requirement Types**: VR (Validation Requirement), BR (Business Rule), FR (Functional Requirement), DR (Data Requirement)  
**Team**: @team:backend @component:backend-api @priority:high  
**Requirements**: Req 17 (VR+BR), Req 19 (UI+VR), Req 20 (VR+BR), Req 21 (VR), Req 22 (UI+VR), Req 23 (FR+DR), Req 25 (BR+UI)  
**Figma Reference**: Profile Management Page - Validation states, Success message

**Description**: Implement the Lambda function that updates user profile data with comprehensive validation.

**Sub-tasks**:
- [ ] 10.1 Create Lambda handler class and request parsing
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 23 (Save Profile)
  - Create UpdateProfileHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent
  - Extract user ID from JWT token
  - Parse ProfileUpdateRequest from request body
  - Set up CloudWatch logging with SLF4J
  
- [ ] 10.2 Implement profile validation logic
  - **Requirement Type**: VR (Validation Requirement) + BR (Business Rule)
  - **Requirements**: Req 17 (Mandatory Fields), Req 19 (Gender), Req 20 (Age), Req 21 (Email), Req 22 (Preferences), Req 25 (Email Policy)
  - Validate all mandatory fields: firstName, lastName, email, gender (non-empty)
  - Validate gender selection (must be Male, Female, or Other)
  - Validate email format using EmailValidator
  - Validate age range 18-120 using AgeValidator
  - Validate at least one preference selected using PreferencesValidator
  - Check email modification policy from GetEmailPolicyHandler
  - Return 400 with field-specific error messages on validation failure
  
- [ ] 10.3 Implement profile update logic
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Requirements**: Req 23 (Save Profile)
  - Update user record in users table using UserRepository
  - Delete existing preferences and insert new ones in user_preferences table
  - Set updated_at timestamp
  - Return success response with message "Profile updated successfully"
  - Return 200 with updated profile data
  - Log profile update event to CloudWatch
  
- [ ]* 10.4 Write property test for mandatory fields validation
  - **Requirement Type**: VR (Validation Requirement) + BR (Business Rule)
  - **Property 11**: Mandatory profile fields validation
  - **Validates**: Req 17 (Mandatory Profile Fields), Req 19 (Gender Field Validation)
  - Test with randomly generated profiles missing mandatory fields
  - Verify appropriate error messages for each missing field
  - Minimum 100 iterations
  
- [ ]* 10.5 Write property test for preferences validation
  - **Requirement Type**: VR (Validation Requirement)
  - **Property 14**: Preferences selection validation
  - **Validates**: Req 22 (Preferences Selection)
  - Test with profiles having no preferences selected
  - Verify error message "At least one preference is required"
  - Minimum 100 iterations
  
- [ ]* 10.6 Write property test for profile save round-trip
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Property 15**: Profile save round-trip with success message
  - **Validates**: Req 23 (Save Profile)
  - Test saving profile and retrieving it returns equivalent data
  - Verify success message "Profile updated successfully"
  - Test with randomly generated valid profiles
  - Minimum 100 iterations
  
- [ ]* 10.7 Write unit tests for profile update
  - **Requirement Type**: VR (Validation Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 17, Req 19, Req 20, Req 21, Req 22, Req 23, Req 25
  - Test successful profile update with all valid data
  - Test validation errors for invalid data (each field)
  - Test email policy enforcement (read-only email)
  - Target 70% minimum coverage (per Java conventions)
  - Use JUnit 5 and Mockito

---

### Task 11: Implement supporting Lambda functions
**Phase**: 6 - Profile Management  
**Requirement Types**: FR (Functional Requirement), BR (Business Rule), UI (UI/UX Requirement)  
**Team**: @team:backend @component:backend-api  
**Requirements**: Req 9 (FR), Req 25 (BR+UI)

**Description**: Implement additional Lambda functions for logout and email policy.

**Sub-tasks**:
- [ ] 11.1 Create AuthLogoutHandler Lambda function
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 9 (Successful Login - logout flow)
  - Create AuthLogoutHandler class extending RequestHandler
  - Parse request and extract JWT token from Authorization header
  - Implement token blacklist logic (add to token_blacklist table)
  - Return 200 success response
  - Use SLF4J for logging logout events
  
- [ ] 11.2 Create GetEmailPolicyHandler Lambda function
  - **Requirement Type**: BR (Business Rule) + UI (UI/UX Requirement)
  - **Requirements**: Req 25 (Read Only Email Rule)
  - Create GetEmailPolicyHandler class extending RequestHandler
  - Read EMAIL_MODIFICATION_ALLOWED environment variable
  - Return policy configuration as JSON: {"emailModificationAllowed": true/false}
  - Return 200 with policy data
  - Cache policy response in frontend
  
- [ ]* 11.3 Write unit tests for supporting functions
  - **Requirement Type**: FR (Functional Requirement) + BR (Business Rule)
  - **Requirements**: Req 9, Req 25
  - Test logout handler with valid token
  - Test email policy handler returns correct policy
  - Test environment variable configuration
  - Use JUnit 5 and Mockito

---

### Task 12: Checkpoint - Backend validation
**Phase**: 4 - Core Authentication  
**Requirement Types**: All  
**Team**: @team:backend @team:devops  
**Requirements**: All backend requirements

**Description**: Validate that all backend Lambda functions are working correctly before proceeding to frontend. API Gateway was already deployed via CloudFormation in Task 1.2.

**Validation Steps**:
- [ ] Test each Lambda function independently with sample events
- [ ] Test API Gateway endpoints with Postman or curl
- [ ] Test registration flow (email and social login)
- [ ] Test email verification flow
- [ ] Test login flow with verified and unverified accounts
- [ ] Verify database connections and queries work correctly
- [ ] Check CloudWatch logs for errors and warnings
- [ ] Verify JWT token generation and validation
- [ ] Test account locking after 5 failed attempts
- [ ] Test OAuth2 integration with Google and Amazon
- [ ] Ensure all unit tests and property tests pass
- [ ] Ask the user if questions arise before proceeding

---

### Task 13: Create React project structure and shared services
**Phase**: 5 - Validation Layer  
**Requirement Types**: VR (Validation Requirement), FR (Functional Requirement), UI (UI/UX Requirement)  
**Team**: @team:frontend @component:frontend-ui @priority:high  
**Requirements**: All frontend requirements  
**Figma Reference**: Component Library, Design System

**Description**: Set up React project with Material Design and implement shared services for validation, authentication, registration, and profile management.

**Sub-tasks**:
- [ ] 14.1 Set up React project with Material-UI (MUI)
  - **Requirement Type**: UI (UI/UX Requirement)
  - **Requirements**: All frontend requirements
  - Initialize React 18+ project with TypeScript
  - Install Material-UI (MUI) and configure custom theme based on Figma colors
  - Set up routing module with lazy loading
  - Configure environment files for API Gateway URLs
  - Extract design tokens from Figma (colors, typography, spacing)
  
- [ ] 14.2 Create ValidationService
  - **Requirement Type**: VR (Validation Requirement)
  - **Requirements**: Req 3 (Password), Req 7 (Email), Req 12 (Password), Req 13 (Email), Req 17 (Mandatory Fields), Req 19 (Gender), Req 20 (Age), Req 21 (Email in Profile)
  - Implement validateEmail(email: string): ValidationResult method
  - Implement validatePassword(password: string): ValidationResult method
  - Implement checkPasswordRequirements(password: string): PasswordRequirements method
  - Implement validateAge(age: number): ValidationResult method
  - Implement validateMandatoryField(value: string): ValidationResult method
  - Return {isValid: boolean, errorMessage?: string} for each validator
  - Match server-side validation logic exactly
  
- [ ] 14.3 Create AuthService
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Email Registration), Req 4 (Social Login), Req 9 (Successful Login), Req 10 (Invalid Credentials)
  - Implement register(email: string, password: string): Promise<RegistrationResponse> method
  - Implement login(email: string, password: string): Promise<AuthResponse> method
  - Implement logout(): void method
  - Implement token storage in localStorage with secure practices
  - Implement isAuthenticated(): boolean method
  - Implement getToken(): string | null method
  - Handle HTTP errors and map to user-friendly messages
  
- [ ] 14.4 Create OAuth2Service
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4 (Social Login Registration)
  - Implement initiateGoogleLogin(): void method
  - Implement initiateAmazonLogin(): void method
  - Implement handleOAuth2Callback(code: string, provider: string): Promise<AuthResponse> method
  - Handle OAuth2 errors
  
- [ ] 14.5 Create ProfileService
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Requirements**: Req 15 (View Profile), Req 16 (Display Fields), Req 23 (Save Profile), Req 25 (Email Policy)
  - Implement getProfile(): Promise<UserProfile> method
  - Implement updateProfile(profile: UserProfile): Promise<UpdateResponse> method
  - Implement checkEmailPolicy(): Promise<EmailPolicyResponse> method
  - Include JWT token in Authorization header for all requests
  - Handle HTTP errors (401, 403, 404, 500)
  
- [ ]* 14.6 Write unit tests for services
  - **Requirement Type**: VR (Validation Requirement) + FR (Functional Requirement)
  - **Requirements**: All validation and service requirements
  - Test ValidationService methods with valid and invalid inputs
  - Test AuthService with mocked fetch/axios
  - Test OAuth2Service with mocked fetch/axios
  - Test ProfileService with mocked fetch/axios
  - Test error handling and edge cases
  - Use Jest and React Testing Library

---

### Task 14: Implement RegistrationComponent
**Phase**: 2 - Registration & Email Verification  
**Requirement Types**: UI (UI/UX Requirement), FR (Functional Requirement), VR (Validation Requirement), SR (Security Requirement)  
**Team**: @team:frontend @component:frontend-ui @priority:high  
**Requirements**: Req 1 (UI), Req 2 (FR+SR), Req 3 (SR+VR), Req 4 (FR+SR), Req 7 (VR)  
**Figma Reference**: Registration Page - Desktop/Mobile/Tablet, Email registration form, Social login buttons, Password requirements, Error states

**Description**: Implement the registration page component with email registration, social login, and password complexity validation, matching Figma designs pixel-perfect.

**Sub-tasks**:
- [ ] 14.1 Create component structure and template
  - **Requirement Type**: UI (UI/UX Requirement)
  - **Requirements**: Req 1 (Registration Page Access), Req 2 (Email Registration), Req 4 (Social Login)
  - Create RegistrationComponent with TypeScript class and HTML template
  - Create registration form with email, password, and confirm password fields using Material-UI (MUI)
  - Add register button
  - Add social login buttons for Google and Amazon with branded styling
  - Add link to login page
  - Add error message display area matching Figma error component
  - Apply Material-UI (MUI) styling matching Figma design system
  - Implement responsive layout for Mobile (375px), Tablet (768px), Desktop (1440px)
  - Extract exact colors, spacing, typography from Figma Inspect
  
- [ ] 14.2 Implement password requirements display
  - **Requirement Type**: SR (Security Requirement) + VR (Validation Requirement)
  - **Requirements**: Req 3 (Registration Password Complexity)
  - Display password complexity requirements in real-time
  - Show checkmarks for met requirements (green)
  - Show X marks for unmet requirements (gray)
  - Requirements: min 8 chars, uppercase, lowercase, digit, special char
  - Update display as user types
  
- [ ] 14.3 Implement form validation logic
  - **Requirement Type**: VR (Validation Requirement) + SR (Security Requirement)
  - **Requirements**: Req 3 (Password Complexity), Req 7 (Email Format)
  - Add reactive form with useState
  - Implement real-time email format validation using ValidationService
  - Implement real-time password complexity validation using ValidationService
  - Validate password and confirm password match
  - Display inline error messages below fields matching Figma error states
  - Clear error messages when user corrects input
  
- [ ] 14.4 Implement email registration submission logic
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Email Registration), Req 5 (Duplicate Account Prevention)
  - Call AuthService.register on form submit
  - Handle successful registration: display success message, redirect to login
  - Handle duplicate email error: display "An account with this email already exists"
  - Handle validation errors: display appropriate error messages
  - Show loading indicator during API call (spinner in button)
  - Disable form during submission to prevent double-submit
  
- [ ] 14.5 Implement social login functionality
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4 (Social Login Registration)
  - Call OAuth2Service.initiateGoogleLogin on Google button click
  - Call OAuth2Service.initiateAmazonLogin on Amazon button click
  - Handle OAuth2 callback and token storage
  - Redirect to home page after successful social login
  - Handle OAuth2 errors
  
- [ ]* 14.6 Write unit tests for RegistrationComponent
  - **Requirement Type**: UI (UI/UX Requirement) + FR (Functional Requirement) + VR (Validation Requirement)
  - **Requirements**: Req 1, Req 2, Req 3, Req 4, Req 7
  - Test form validation (email format, password complexity, password match)
  - Test password requirements display updates in real-time
  - Test successful registration flow
  - Test duplicate email error handling
  - Test social login button clicks
  - Test loading state during API call
  - Use Jest and React Testing Library with render from React Testing Library

---

### Task 15: Implement LoginComponent
**Phase**: 4 - Core Authentication  
**Requirement Types**: UI (UI/UX Requirement), FR (Functional Requirement), VR (Validation Requirement), SR (Security Requirement)  
**Team**: @team:frontend @component:frontend-ui @priority:high  
**Requirements**: Req 8 (UI), Req 9 (FR), Req 10 (FR), Req 11 (VR), Req 12 (SR+VR), Req 13 (VR), Req 14 (SR), Req 6.3 (FR+SR)  
**Figma Reference**: Login Page - Desktop/Mobile/Tablet, Error states, Loading state, Account locked state, Unverified email state

**Description**: Implement the login page component with form validation and authentication logic, matching Figma designs pixel-perfect.

**Sub-tasks**:
- [ ] 16.1 Create component structure and template
  - **Requirement Type**: UI (UI/UX Requirement)
  - **Requirements**: Req 8 (Login Page Access), Req 9 (Successful Login), Req 10 (Invalid Credentials), Req 11 (Mandatory Fields)
  - Create LoginComponent with TypeScript class and HTML template
  - Create login form with email and password fields using Material-UI (MUI)
  - Add login button with disabled state
  - Add link to registration page
  - Add "Forgot Password" link (optional)
  - Add error message display area matching Figma error component
  - Apply Material-UI (MUI) styling matching Figma design system
  - Implement responsive layout for Mobile (375px), Tablet (768px), Desktop (1440px)
  - Extract exact colors, spacing, typography from Figma Inspect
  
- [ ] 16.2 Implement form validation logic
  - **Requirement Type**: VR (Validation Requirement) + SR (Security Requirement)
  - **Requirements**: Req 11 (Mandatory Fields), Req 12 (Password Format), Req 13 (Email Format)
  - Add reactive form with useState
  - Implement real-time email format validation using ValidationService
  - Implement real-time password complexity validation using ValidationService
  - Disable login button when email or password field is empty (Req 11)
  - Display inline error messages below fields matching Figma error states
  - Clear error messages when user corrects input
  
- [ ] 16.3 Implement login submission logic
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 9 (Successful Login), Req 10 (Invalid Credentials), Req 14 (Account Locking), Req 6.3 (Unverified Email)
  - Call AuthService.login on form submit
  - Handle successful login: store JWT token securely, redirect to home page
  - Handle authentication errors: display "Invalid username or password" message
  - Handle account locked errors: display "Account is locked. Please try again after 30 minutes." message
  - Handle unverified email errors: display "Please verify your email address before logging in" message
  - Show loading indicator during API call (spinner in button)
  - Disable form during submission to prevent double-submit
  
- [ ]* 16.4 Write property test for login button disabled state
  - **Requirement Type**: VR (Validation Requirement)
  - **Property 7**: Login button disabled state
  - **Validates**: Req 11 (Mandatory Fields Validation)
  - Test with randomly generated combinations of empty/non-empty email and password
  - Verify button is disabled if and only if at least one field is blank
  - Minimum 100 iterations
  
- [ ]* 16.5 Write unit tests for LoginComponent
  - **Requirement Type**: UI (UI/UX Requirement) + FR (Functional Requirement) + VR (Validation Requirement)
  - **Requirements**: Req 8, Req 9, Req 10, Req 11, Req 12, Req 13, Req 14, Req 6.3
  - Test form validation (email format, password complexity)
  - Test button disabled state when fields are empty
  - Test successful login flow (token storage, navigation)
  - Test error handling (invalid credentials, account locked, unverified email)
  - Test loading state during API call
  - Use Jest and React Testing Library with render from React Testing Library

---

### Task 16: Implement ProfileComponent
**Phase**: 6 - Profile Management  
**Requirement Types**: UI (UI/UX Requirement), VR (Validation Requirement), FR (Functional Requirement), BR (Business Rule), DR (Data Requirement)  
**Team**: @team:frontend @component:frontend-ui @priority:high  
**Requirements**: Req 15-25 (all profile requirements)  
**Figma Reference**: Profile Management Page - Desktop/Mobile/Tablet, Form layout, Validation states, Success message

**Description**: Implement the profile management page component with all fields, validation, and save/cancel functionality, matching Figma designs pixel-perfect.

**Sub-tasks**:
- [ ] 17.1 Create component structure and template
  - **Requirement Type**: UI (UI/UX Requirement)
  - **Requirements**: Req 15 (View Profile), Req 16 (Display Fields), Req 18 (Title), Req 19 (Gender), Req 22 (Preferences)
  - Create ProfileComponent with TypeScript class and HTML template
  - Create profile form with all 8 fields using Material-UI (MUI):
    - Title dropdown (Mr, Ms, Mrs, Dr) - `<Material-UI select>`
    - First Name text input (required) - `<Material-UI form-field>`
    - Last Name text input (required) - `<Material-UI form-field>`
    - Gender radio buttons (Male, Female, Other) (required) - `<Material-UI radio-group>`
    - Age numeric input (range: 18-120) - `<Material-UI form-field type="number">`
    - Email text input (required, conditionally read-only) - `<Material-UI form-field>`
    - Address textarea - `TextField multiline`
    - Preferences checkboxes (required, at least one) - `<Material-UI checkbox>`
  - Add Save and Cancel buttons matching Figma action buttons
  - Add error message display areas for each field
  - Apply Material-UI (MUI) styling matching Figma design system
  - Implement responsive layout: 2-column grid on desktop, single column on mobile/tablet
  - Extract exact colors, spacing, typography from Figma Inspect
  
- [ ] 17.2 Implement profile loading logic
  - **Requirement Type**: UI (UI/UX Requirement) + DR (Data Requirement) + BR (Business Rule)
  - **Requirements**: Req 15 (View Profile), Req 16 (Display Fields), Req 25 (Read Only Email)
  - Call ProfileService.getProfile on component init (useEffect hook)
  - Populate form with retrieved profile data
  - Store original profile data in originalProfile property for cancel functionality
  - Call ProfileService.checkEmailPolicy to determine if email is read-only
  - Set email field read-only if policy restricts modification (add lock icon)
  - Show loading indicator while fetching data
  
- [ ] 17.3 Implement form validation logic
  - **Requirement Type**: VR (Validation Requirement) + BR (Business Rule)
  - **Requirements**: Req 17 (Mandatory Fields), Req 19 (Gender), Req 20 (Age), Req 21 (Email), Req 22 (Preferences)
  - Add reactive form with useState and validators
  - Validate mandatory fields: firstName, lastName, email, gender (Validators.required)
  - Validate gender selection: display "Gender selection is mandatory" if blank
  - Validate email format using ValidationService
  - Validate age range 18-120 using ValidationService
  - Validate at least one preference selected using custom validator
  - Display inline error messages below each field matching Figma error states
  - Clear error messages when user corrects input
  - Disable save button when form is invalid
  
- [ ] 17.4 Implement save functionality
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Requirements**: Req 23 (Save Profile)
  - Call ProfileService.updateProfile on save button click
  - Handle successful save: display "Profile updated successfully" toast notification (green, top-right)
  - Handle validation errors: display field-specific error messages
  - Show loading indicator during API call (spinner in button)
  - Disable form during submission to prevent double-submit
  - Update originalProfile with saved data after successful save
  
- [ ] 17.5 Implement cancel functionality
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 24 (Cancel Changes)
  - Revert form to originalProfile data on cancel button click
  - Clear any error messages
  - Reset form validation state
  - No API call needed (client-side only)
  
- [ ]* 17.6 Write property test for cancel discards changes
  - **Requirement Type**: FR (Functional Requirement)
  - **Property 16**: Cancel discards changes
  - **Validates**: Req 24 (Cancel Changes)
  - Test with randomly generated profile modifications
  - Verify cancel button reverts all fields to original values
  - Minimum 100 iterations
  
- [ ]* 17.7 Write unit tests for ProfileComponent
  - **Requirement Type**: UI (UI/UX Requirement) + VR (Validation Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 15-25 (all profile requirements)
  - Test profile loading and form population
  - Test form validation for all fields
  - Test save functionality (success and error cases)
  - Test cancel functionality (revert to original data)
  - Test email read-only based on policy
  - Test mandatory field validation
  - Test age range validation
  - Test preferences validation (at least one selected)
  - Use Jest and React Testing Library with render from React Testing Library

---

### Task 17: Configure routing and navigation
**Phase**: 4 - Core Authentication  
**Requirement Types**: UI (UI/UX Requirement), FR (Functional Requirement), SR (Security Requirement)  
**Team**: @team:frontend @component:frontend-routing  
**Requirements**: Req 1 (UI), Req 8 (UI), Req 9 (FR), Req 15 (UI)

**Description**: Set up React Router with authentication guards and navigation components.

**Sub-tasks**:
- [ ] 18.1 Set up React Router
  - **Requirement Type**: UI (UI/UX Requirement) + SR (Security Requirement)
  - **Requirements**: Req 1 (Registration Page Access), Req 8 (Login Page Access), Req 9 (Successful Login), Req 15 (View Profile Page)
  - Define routes for registration page (/register), login page (/login), and profile page (/profile)
  - Implement AuthGuard route guard for authenticated routes
  - Configure redirect to /login for unauthenticated users
  - Configure redirect to /profile after successful login/registration
  - Set up lazy loading for feature modules
  
- [ ] 18.2 Create navigation component
  - **Requirement Type**: UI (UI/UX Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 9 (Successful Login - logout flow)
  - Add navigation bar with Material-UI (MUI) toolbar
  - Show navigation only for authenticated users (use conditional rendering with AuthService.isAuthenticated())
  - Add logout button that calls AuthService.logout()
  - Redirect to /login after logout
  - Match Figma navigation design
  
- [ ]* 18.3 Write unit tests for routing and guards
  - **Requirement Type**: UI (UI/UX Requirement) + SR (Security Requirement)
  - **Requirements**: Req 1, Req 8, Req 9, Req 15
  - Test AuthGuard redirects unauthenticated users to /login
  - Test AuthGuard allows authenticated users to access /profile
  - Test navigation component shows/hides based on authentication state
  - Test logout functionality
  - Use Jest and React Testing Library with MemoryRouter from react-router-dom

---

### Task 18: Configure deployment pipeline
**Phase**: 7 - Testing & Deployment  
**Requirement Types**: PR (Performance Requirement)  
**Team**: @team:devops @component:devops-cicd  
**Requirements**: All requirements (deployment and monitoring)

**Description**: Complete frontend deployment configuration and monitoring setup. Backend Lambda deployment pipeline is already configured and working (completed in Task 1.5).

**Note**: GitHub Actions secrets and Lambda deployment pipeline were configured in Task 1.5 and verified in Task 1.6.

**Sub-tasks**:
- [ ] 18.1 Configure frontend deployment
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All frontend requirements
  - Build React application for production (npm run build)
  - Deploy to S3 bucket with static website hosting
  - Configure CloudFront distribution for CDN (optional)
  - Configure environment-specific API Gateway URLs in .env files
  - Invalidate CloudFront cache after deployment (if using CloudFront)
  - Create GitHub Actions workflow for frontend deployment
  
- [ ] 18.2 Set up monitoring and alerts
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All requirements (monitoring)
  - Configure CloudWatch alarms for Lambda errors (threshold: > 5 errors in 5 minutes)
  - Set up API Gateway monitoring (4xx, 5xx errors, latency)
  - Configure RDS performance monitoring (CPU, connections, slow queries)
  - Monitor SES email delivery metrics
  - Create CloudWatch dashboard for system health
  - Set up SNS notifications for critical alerts
  - Note: Log retention policies (30 days) already configured in CloudFormation template
  - Use `ProfileManager-CDK/scripts/check-lambda-logs.ps1` for log monitoring

---

### Task 19: Integration testing and validation
**Phase**: 7 - Testing & Deployment  
**Requirement Types**: All requirement types  
**Team**: @team:qa @component:qa-testing  
**Requirements**: All requirements

**Description**: Perform comprehensive integration and end-to-end testing to validate the entire system.

**Sub-tasks**:
- [ ]* 20.1 Write end-to-end tests for registration flow
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement) + VR (Validation Requirement)
  - **Requirements**: Req 1 (Registration Page), Req 2 (Email Registration), Req 3 (Password Complexity), Req 4 (Social Login), Req 5 (Duplicate Prevention), Req 6 (Email Verification), Req 7 (Email Format)
  - Test complete registration flow from UI to database
  - Test successful registration with valid data
  - Test duplicate email detection
  - Test password complexity validation
  - Test email format validation
  - Test email verification flow
  - Test social login with Google and Amazon
  - Use Cypress or Protractor for E2E tests
  
- [ ]* 20.2 Write end-to-end tests for authentication flow
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement) + VR (Validation Requirement)
  - **Requirements**: Req 8 (Login Page), Req 9 (Successful Login), Req 10 (Invalid Credentials), Req 11 (Mandatory Fields), Req 14 (Account Locking), Req 6.3 (Unverified Email)
  - Test complete login flow from UI to database
  - Test successful login with valid credentials (redirect to home)
  - Test invalid credentials display error message
  - Test login button disabled when fields are empty
  - Test account locking after 5 failed attempts
  - Test account unlocks after 30 minutes
  - Test unverified email prevention
  - Test logout functionality
  - Use Cypress or Protractor for E2E tests
  
- [ ]* 20.3 Write end-to-end tests for profile management
  - **Requirement Type**: UI (UI/UX Requirement) + VR (Validation Requirement) + FR (Functional Requirement) + BR (Business Rule)
  - **Requirements**: Req 15-25 (all profile requirements)
  - Test profile retrieval and display of all 8 fields
  - Test profile update with valid data (success message displayed)
  - Test validation errors for invalid data (each field)
  - Test mandatory field validation (firstName, lastName, email, gender)
  - Test age range validation (18-120)
  - Test email format validation
  - Test preferences validation (at least one selected)
  - Test cancel functionality (revert to original data)
  - Test email policy enforcement (read-only email field)
  - Use Cypress or Protractor for E2E tests
  
- [ ]* 20.4 Perform security testing
  - **Requirement Type**: SR (Security Requirement)
  - **Requirements**: All security requirements
  - Test JWT token validation (expired token, invalid signature, missing token)
  - Test SQL injection prevention (parameterized queries)
  - Test XSS prevention (React sanitization)
  - Test CSRF protection (CSRF tokens)
  - Verify HTTPS enforcement for all API calls
  - Verify secure token storage (localStorage with HttpOnly cookies recommended)
  - Test password hashing (BCrypt, never plain text)
  - Test account locking mechanism (5 failures, 30 minutes)
  - Test API Gateway rate limiting (5-10 req/s for public endpoints)
  - Test OAuth2 security (token exchange, state parameter)
  - Use OWASP ZAP or Burp Suite for security scanning
  
- [ ]* 20.5 Perform performance testing
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All requirements (performance)
  - Test Lambda cold start times (target: < 3 seconds)
  - Test API Gateway throughput (concurrent requests)
  - Test database query performance (target: < 100ms p95)
  - Test concurrent user load (100+ concurrent users)
  - Test API response times (target: < 500ms p95)
  - Test frontend page load times (target: < 2 seconds)
  - Test email delivery times (target: < 5 seconds)
  - Use Artillery or Gatling for load testing
  - Monitor CloudWatch metrics during tests

---

### Task 20: Final checkpoint - Production readiness validation
**Phase**: 7 - Testing & Deployment  
**Requirement Types**: All requirement types  
**Team**: @team:backend @team:frontend @team:devops @team:qa  
**Requirements**: All requirements

**Description**: Final validation that the system is ready for production deployment.

**Validation Checklist**:
- [ ] Run all unit tests and property tests (100% pass rate required)
- [ ] Run all integration tests and E2E tests (100% pass rate required)
- [ ] Verify code coverage meets 70% minimum (per Java conventions)
- [ ] Review CloudWatch logs for any errors or warnings
- [ ] Perform manual testing of critical flows (registration, email verification, social login, login, profile management)
- [ ] Verify all 25 requirements are implemented and tested
- [ ] Verify all 16 correctness properties are validated
- [ ] Verify Figma designs match implementation (pixel-perfect)
- [ ] Verify responsive layouts work on Mobile, Tablet, Desktop
- [ ] Verify WCAG AA accessibility compliance
- [ ] Verify security best practices are followed
- [ ] Verify performance targets are met (Lambda < 3s, API < 500ms, page load < 2s, email < 5s)
- [ ] Verify monitoring and alerts are configured
- [ ] Verify deployment pipeline works end-to-end
- [ ] Verify SES email delivery is working
- [ ] Verify OAuth2 integration with Google and Amazon is working
- [ ] Ensure all tests pass, ask the user if questions arise before production deployment

---

## Requirement Type to Task Mapping

This section provides a comprehensive mapping of requirement types to the tasks that implement them.

### Functional Requirements (FR) - Core business functionality

| Requirement | Description | Implementing Tasks |
|-------------|-------------|-------------------|
| Req 2 | Email Registration | Task 3.3 (JWT utility), Task 4.1 (UserRepository), Task 5 (RegistrationHandler), Task 13.3 (AuthService), Task 14 (RegistrationComponent), Task 17.1 (Routing) |
| Req 4 | Social Login Registration | Task 3.5 (OAuth2 utility), Task 4.1 (UserRepository), Task 7 (OAuth2Handler), Task 13.4 (OAuth2Service), Task 14.5 (RegistrationComponent) |
| Req 6 | Email Verification | Task 3.6 (Email service), Task 4.1 (UserRepository), Task 5.5 (Send email), Task 6 (EmailVerificationHandler) |
| Req 9 | Successful Login | Task 3.3 (JWT utility), Task 4.1 (UserRepository), Task 8 (AuthLoginHandler), Task 11.1 (AuthLogoutHandler), Task 13.3 (AuthService), Task 15 (LoginComponent), Task 17 (Routing) |
| Req 10 | Invalid Credentials | Task 3.10 (Exceptions), Task 4.1 (UserRepository), Task 8 (AuthLoginHandler), Task 13.3 (AuthService), Task 15 (LoginComponent) |
| Req 23 | Save Profile | Task 4.1 (UserRepository), Task 10 (UpdateProfileHandler), Task 13.5 (ProfileService), Task 16 (ProfileComponent) |
| Req 24 | Cancel Changes | Task 16.5 (ProfileComponent cancel functionality) |

### UI/UX Requirements (UI) - User interface and experience

| Requirement | Description | Implementing Tasks | Figma Reference |
|-------------|-------------|-------------------|-----------------|
| Req 1 | Registration Page Access | Task 14.1 (RegistrationComponent structure), Task 17.1 (Routing) | Registration Page - Desktop/Mobile/Tablet |
| Req 8 | Login Page Access | Task 15.1 (LoginComponent structure), Task 17.1 (Routing) | Login Page - Desktop/Mobile/Tablet |
| Req 15 | View Profile Page | Task 9 (GetProfileHandler), Task 16.1-16.2 (ProfileComponent), Task 17.1 (Routing) | Profile Management Page |
| Req 16 | Display Profile Fields | Task 2.1-2.2 (Database schema), Task 9 (GetProfileHandler), Task 16.1 (ProfileComponent) | Profile - Form Fields |
| Req 18 | Title Field Behavior | Task 2.1 (Database), Task 16.1 (ProfileComponent) | Profile - Title dropdown |
| Req 19 | Gender Field Validation | Task 2.1 (Database), Task 10.2 (Validation), Task 16.1-16.3 (ProfileComponent) | Profile - Gender radio buttons |
| Req 22 | Preferences Selection | Task 2.2 (Database), Task 10.2 (Validation), Task 16.1-16.3 (ProfileComponent) | Profile - Preferences checkboxes |
| Req 25 | Read Only Email Rule | Task 11.2 (GetEmailPolicyHandler), Task 13.5 (ProfileService), Task 16.2 (ProfileComponent) | Profile - Email read-only state |

### Validation Requirements (VR) - Input validation and data integrity

| Requirement | Description | Implementing Tasks | Property Tests |
|-------------|-------------|-------------------|----------------|
| Req 3 | Registration Password Complexity | Task 3.2 (BCrypt), Task 3.4 (Validators), Task 5.2 (RegistrationHandler), Task 13.2 (ValidationService), Task 14.2-14.3 (RegistrationComponent) | Task 3.8 (Property 2) |
| Req 7 | Registration Email Format Validation | Task 3.4 (Validators), Task 5.2 (RegistrationHandler), Task 13.2 (ValidationService), Task 14.3 (RegistrationComponent) | Task 3.7 (Property 4) |
| Req 11 | Mandatory Fields Validation | Task 3.4 (Validators), Task 13.2 (ValidationService), Task 15.2 (LoginComponent) | Task 15.4 (Property 7) |
| Req 12 | Password Format Validation | Task 3.2 (BCrypt), Task 3.4 (Validators), Task 13.2 (ValidationService), Task 15.2 (LoginComponent) | Task 3.8 (Property 2) |
| Req 13 | Email Format Validation | Task 3.4 (Validators), Task 13.2 (ValidationService), Task 15.2 (LoginComponent) | Task 3.7 (Property 4) |
| Req 17 | Mandatory Profile Fields | Task 3.4 (Validators), Task 10.2 (UpdateProfileHandler), Task 16.3 (ProfileComponent) | Task 10.4 (Property 11) |
| Req 19 | Gender Field Validation | Task 10.2 (UpdateProfileHandler), Task 16.3 (ProfileComponent) | Task 10.4 (Property 11) |
| Req 20 | Age Validation | Task 3.4 (Validators), Task 10.2 (UpdateProfileHandler), Task 16.3 (ProfileComponent) | Task 3.9 (Property 12) |
| Req 21 | Email Validation in Profile | Task 3.4 (Validators), Task 10.2 (UpdateProfileHandler), Task 16.3 (ProfileComponent) | Task 3.7 (Property 4) |
| Req 22 | Preferences Selection | Task 3.4 (Validators), Task 10.2 (UpdateProfileHandler), Task 16.3 (ProfileComponent) | Task 10.5 (Property 14) |

### Security Requirements (SR) - Authentication and security controls

| Requirement | Description | Implementing Tasks | Security Measures |
|-------------|-------------|-------------------|-------------------|
| Req 2 | Email Registration | Task 3.2 (BCrypt hashing), Task 5.4 (RegistrationHandler) | BCrypt with salt rounds = 10, never store plain text |
| Req 3 | Registration Password Complexity | Task 3.2 (BCrypt hashing), Task 5.2 (RegistrationHandler) | Password complexity validation |
| Req 4 | Social Login Registration | Task 3.5 (OAuth2 utility), Task 7 (OAuth2Handler) | OAuth2 authentication with Google and Amazon |
| Req 5 | Duplicate Account Prevention | Task 4.1 (UserRepository), Task 5.3 (RegistrationHandler) | Database unique constraint + application check |
| Req 6 | Email Verification | Task 3.6 (Email service), Task 6 (EmailVerificationHandler) | Email verification token with 24-hour expiry |
| Req 12 | Password Format Validation | Task 3.2 (BCrypt hashing), Task 8.2 (AuthLoginHandler) | BCrypt password verification |
| Req 14 | Account Locking | Task 2.3 (login_attempts table), Task 4.2 (LoginAttemptRepository), Task 8.3 (AuthLoginHandler) | Lock after 5 failures for 30 minutes |

**Additional Security Measures**:
- JWT token authentication (Task 3.3)
- API Gateway rate limiting (configured in CloudFormation template)
- HTTPS enforcement (configured in CloudFormation template)
- SQL injection prevention with parameterized queries (Task 4.1, 4.2)
- XSS prevention with React sanitization (Task 13.1)
- CSRF protection (configured in CloudFormation template)
- Secrets Manager for credentials (Task 1.4, 3.1)
- CloudWatch logging for security events (Task 1.6, 5.4, 6.2, 7.4, 8.3)

### Data Requirements (DR) - Data storage and management

| Requirement | Description | Implementing Tasks | Database Tables |
|-------------|-------------|-------------------|-----------------|
| Req 2 | Email Registration | Task 2.1 (Database schema), Task 5.4 (RegistrationHandler) | users (Customer_Identity) |
| Req 16 | Display Profile Fields | Task 2.1-2.2 (Database schema), Task 9 (GetProfileHandler) | users, user_preferences |
| Req 23 | Save Profile | Task 2.1-2.2 (Database schema), Task 10.3 (UpdateProfileHandler) | users, user_preferences |

**Database Schema**:
- users table: id, title, first_name, last_name, gender, age, email, password_hash, address, account_locked, locked_until, email_verified, verification_token, verification_token_expiry, auth_provider, provider_id, created_at, updated_at
- user_preferences table: user_id, preference
- login_attempts table: id, email, timestamp, successful, ip_address
- token_blacklist table: id, token_hash, expiry, created_at

### Business Rules (BR) - Business logic and policies

| Requirement | Description | Implementing Tasks | Configuration |
|-------------|-------------|-------------------|---------------|
| Req 5 | Duplicate Account Prevention | Task 5.3 (RegistrationHandler) | Database unique constraint + application-level check |
| Req 17 | Mandatory Profile Fields | Task 10.2 (UpdateProfileHandler validation) | Hard-coded validation rules |
| Req 20 | Age Validation | Task 10.2 (UpdateProfileHandler validation) | Age range: 18-120 |
| Req 25 | Read Only Email Rule | Task 11.2 (GetEmailPolicyHandler) | Environment variable: EMAIL_MODIFICATION_ALLOWED |

### Performance Requirements (PR) - System performance

| Requirement | Description | Implementing Tasks | Performance Targets |
|-------------|-------------|-------------------|---------------------|
| Infrastructure | Scalability and performance | Task 1 (AWS infrastructure), Task 18 (Deployment) | Lambda cold start < 3s, API response < 500ms p95, Page load < 2s, Email delivery < 5s |

---

## Property-Based Tests Mapping

All property-based tests validate universal correctness properties across randomly generated inputs (minimum 100 iterations each).

| Property | Description | Validates Requirements | Implementing Task |
|----------|-------------|----------------------|-------------------|
| Property 1 | Unique email registration | Req 2.3, 5.2 (Duplicate Email Prevention) | Task 5.6 |
| Property 2 | Password complexity validation during registration | Req 3 (Registration Password Complexity) | Task 3.8 |
| Property 3 | Email verification requirement | Req 6.3 (Unverified Email Login Prevention) | Task 6.3 |
| Property 4 | Email format validation during registration | Req 7 (Registration Email Format) | Task 3.7 |
| Property 5 | Valid credentials authenticate successfully | Req 9 (Successful Login) | Task 8.5 |
| Property 6 | Invalid credentials return error message | Req 10 (Invalid Credentials) | Task 8.6 |
| Property 7 | Login button disabled state | Req 11 (Mandatory Fields) | Task 15.4 |
| Property 8 | Password complexity validation during login | Req 12 (Password Format) | Task 3.8 |
| Property 9 | Email format validation during login | Req 13 (Email Format) | Task 3.7 |
| Property 10 | Account locking after failed attempts | Req 14 (Account Locking) | Task 8.7 |
| Property 11 | Mandatory profile fields validation | Req 17, 19 (Mandatory Fields, Gender) | Task 10.4 |
| Property 12 | Age range validation | Req 20 (Age Validation) | Task 3.9 |
| Property 13 | Email format validation in profile | Req 21 (Email in Profile) | Task 3.7 |
| Property 14 | Preferences selection validation | Req 22 (Preferences) | Task 10.5 |
| Property 15 | Profile save round-trip with success message | Req 23 (Save Profile) | Task 10.6 |
| Property 16 | Cancel discards changes | Req 24 (Cancel Changes) | Task 16.6 |

---

## Task Dependencies and Execution Order

### Phase 1: Infrastructure & Security (Week 1)
**Critical Path**: Task 1 → Task 2 → Task 3 → Task 4

1. Task 1: AWS infrastructure (no dependencies)
2. Task 2: Database schema (depends on Task 1)
3. Task 3: Lambda utilities (depends on Task 1, 2)
4. Task 4: Repository classes (depends on Task 2, 3)

### Phase 2: Registration & Email Verification (Week 2)
**Critical Path**: Task 5 → Task 6 → Task 12 (Backend checkpoint)

5. Task 5: RegistrationHandler (depends on Task 3, 4)
6. Task 6: EmailVerificationHandler (depends on Task 3, 4)
7. Task 12: Backend checkpoint (depends on Task 5, 6)

### Phase 3: Social Login Integration (Week 3)
**Critical Path**: Task 7 → Task 12 (Backend checkpoint)

8. Task 7: OAuth2Handler (depends on Task 3, 4)
9. Task 12: Backend checkpoint (depends on Task 7)

### Phase 4: Core Authentication (Week 4)
**Critical Path**: Task 8 → Task 12 → Task 13 → Task 15 → Task 17

10. Task 8: AuthLoginHandler (depends on Task 3, 4)
11. Task 12: Backend checkpoint (depends on Task 8)
12. Task 13: React services (depends on Task 12)
13. Task 15: LoginComponent (depends on Task 13)
14. Task 17: Routing (depends on Task 14, 15)

### Phase 5: Validation Layer (Week 5)
**Parallel Execution**: Task 3.4-3.9 (validation utilities and property tests)

- Can be executed in parallel with Phase 2-4 tasks
- Property tests validate validation logic

### Phase 6: Profile Management (Week 6)
**Critical Path**: Task 9 → Task 10 → Task 11 → Task 16

17. Task 9: GetProfileHandler (depends on Task 4)
18. Task 10: UpdateProfileHandler (depends on Task 3, 4)
19. Task 11: Supporting functions (depends on Task 3)
20. Task 16: ProfileComponent (depends on Task 9, 10, 11, 13)

### Phase 7: Testing & Deployment (Week 7)
**Critical Path**: Task 18 → Task 19 → Task 20

21. Task 18: Deployment pipeline (depends on all implementation tasks)
22. Task 19: Integration testing (depends on Task 18)
23. Task 20: Final checkpoint (depends on Task 19)

---

## Notes

- **Optional Tasks**: Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- **Test Coverage**: Target 70% minimum code coverage (per Java conventions)
- **Property Tests**: Minimum 100 iterations per property test
- **Figma Compliance**: All UI components must match Figma designs pixel-perfect
- **Security**: Follow OWASP security best practices
- **Logging**: Use SLF4J for all backend logging (per Java conventions)
- **REST Standards**: Follow proper HTTP status codes and versioning
- **Email Service**: AWS SES for email verification
- **OAuth2**: Google and Amazon OAuth2 integration

---

## Success Criteria

### Functional Completeness
- [ ] All 25 requirements implemented and tested
- [ ] All 16 correctness properties validated with property-based tests
- [ ] All functional flows work end-to-end (registration, email verification, social login, login, profile management)
- [ ] Email verification flow working with SES
- [ ] OAuth2 integration working with Google and Amazon

### Quality Metrics
- [ ] Code coverage >= 70% (per Java conventions)
- [ ] All property tests pass with 100+ iterations
- [ ] All unit tests pass (100% pass rate)
- [ ] No critical or high severity bugs
- [ ] SonarQube quality gate passed

### UI/UX Compliance
- [ ] Pixel-perfect match with Figma designs
- [ ] All responsive breakpoints implemented (Mobile 375px, Tablet 768px, Desktop 1440px)
- [ ] All interactive states implemented (hover, focus, active, disabled, error)
- [ ] Password requirements displayed in real-time during registration
- [ ] Social login buttons match brand guidelines
- [ ] WCAG AA accessibility compliance verified

### Security Compliance
- [ ] Password hashing with BCrypt implemented
- [ ] Account locking after 5 failed attempts working
- [ ] Email verification required before login
- [ ] Duplicate email prevention working
- [ ] JWT token authentication working
- [ ] OAuth2 integration secure and working
- [ ] API Gateway rate limiting configured (5-10 req/s for public endpoints)
- [ ] All security events logged to CloudWatch
- [ ] HTTPS enforcement verified
- [ ] SQL injection prevention verified
- [ ] XSS prevention verified
- [ ] CSRF protection verified

### Performance Targets
- [ ] Lambda cold start < 3 seconds
- [ ] API response time < 500ms (p95)
- [ ] Database query time < 100ms (p95)
- [ ] Frontend page load < 2 seconds
- [ ] Email delivery < 5 seconds
- [ ] System handles 100+ concurrent users

### Deployment Readiness
- [ ] Infrastructure as Code (AWS CDK) complete
- [ ] CI/CD pipeline configured and working
- [ ] Environment variables configured
- [ ] SES configured and verified
- [ ] OAuth2 credentials configured
- [ ] Monitoring and alerts set up (CloudWatch)
- [ ] Documentation complete (README, API docs, deployment guide)
- [ ] Production deployment successful

### Registration & Verification Specific
- [ ] Registration form validates all fields correctly
- [ ] Password complexity requirements displayed and validated
- [ ] Duplicate email detection working
- [ ] Verification email sent successfully
- [ ] Email verification link working
- [ ] Unverified users cannot log in
- [ ] Social login creates or links accounts correctly
