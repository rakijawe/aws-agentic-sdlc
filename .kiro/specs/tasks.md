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

**Infrastructure Setup (One-Time)**:
- Use `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1` for initial infrastructure deployment
- CloudFormation template: `ProfileManager-CDK/aws/lambda-infrastructure.yml`
- Creates: VPC, Lambda, API Gateway, RDS PostgreSQL, Secrets Manager, CloudWatch

**Continuous Deployment (Automated)**:
- GitHub Actions workflow: `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml`
- Triggers: Push to main branch or PR merge
- Pipeline: Build → Test → Upload to S3 → Update Lambda function
- No infrastructure changes on each deployment, only Lambda code updates

**Key Files**:
- Infrastructure: `ProfileManager-CDK/aws/lambda-infrastructure.yml`
- Deployment Script: `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
- CI/CD Pipeline: `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml`
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

**Description**: Deploy the foundational AWS Lambda infrastructure using the existing CloudFormation template and PowerShell deployment script.

**Infrastructure Files**:
- CloudFormation Template: `ProfileManager-CDK/aws/lambda-infrastructure.yml`
- Deployment Script: `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
- GitHub Actions: `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml`

**Sub-tasks**:
- [x] 1.1 Review existing infrastructure template
  - CloudFormation template includes: VPC, Lambda, API Gateway, RDS PostgreSQL 16.11, Secrets Manager, CloudWatch
  - Deployment script handles: Maven build, S3 upload, stack creation, Lambda update
  
- [x] 1.2 Initial infrastructure deployment (one-time setup)
  - Run `ProfileManager-CDK/scripts/complete-lambda-deployment.ps1`
  - Provide parameters: stack name, environment, region, DB credentials
  - Script will: build JAR, create S3 bucket, upload code, deploy CloudFormation stack
  - Verify stack creation in AWS Console
  - Note: This takes 10-15 minutes
  
- [x] 1.3 Configure Secrets Manager values
  - Update secrets in AWS Secrets Manager: `{environment}/lambda/user-registration/secrets`
  - Set EMAIL_USERNAME and EMAIL_PASSWORD (for SES)
  - Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET
  - Set AMAZON_CLIENT_ID and AMAZON_CLIENT_SECRET
  - Set ENCRYPTION_KEY (base64 encoded 32-byte key)
  - Use AWS Console or `ProfileManager-CDK/scripts/update-secrets.ps1`
  
- [x] 1.4 Configure AWS SES for email sending
  - Verify sender email address in SES console
  - Request production access (move out of sandbox)
  - Test email sending with verification template
  - Configure SES region in Lambda environment variables
  
- [x] 1.5 Set up GitHub Actions for CI/CD (automated deployments)
  - Configure GitHub secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
  - Workflow file: `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml`
  - Triggers: Push to main branch automatically deploys to Lambda
  - Pipeline: Build → Test → Upload to S3 → Update Lambda function
  
- [x] 1.6 Verify infrastructure deployment
  - Test API endpoint: `curl {ApiEndpoint}/actuator/health`
  - Check CloudWatch logs: `/aws/lambda/{FunctionName}`
  - Verify RDS database connectivity
  - Test Lambda function invocation
  - Review CloudFormation stack outputs (API endpoint, DB endpoint, Lambda ARN)

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
  - Create RegistrationHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent to extract email and password
  - Set up CloudWatch logging with SLF4J
  - Validate request body format
  
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

### Task 12: Configure API Gateway endpoints and integrations
**Phase**: 2 - Registration & Email Verification  
**Requirement Types**: FR (Functional Requirement), SR (Security Requirement), PR (Performance Requirement)  
**Team**: @team:devops @component:devops-infra  
**Requirements**: All API requirements

**Description**: Configure API Gateway REST API with endpoints, Lambda integrations, and security.

**Sub-tasks**:
- [ ] 12.1 Create API Gateway REST API resource
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All API requirements
  - Define API name: "UserAuthRegistrationProfileAPI"
  - Configure CORS settings (allow origins, methods, headers)
  - Set up request/response models
  - Enable CloudWatch logging
  
- [ ] 12.2 Create /auth/register endpoint
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Email Registration)
  - Configure POST method
  - Integrate with RegistrationHandler Lambda function
  - Set throttling to 5 requests/second per IP (prevent abuse)
  - No authorization required (public endpoint)
  - Configure request validation
  
- [ ] 12.3 Create /auth/verify-email endpoint
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 6 (Email Verification)
  - Configure GET method
  - Integrate with EmailVerificationHandler Lambda function
  - Set throttling to 10 requests/second
  - No authorization required (public endpoint)
  
- [ ] 12.4 Create /auth/oauth2/google and /auth/oauth2/amazon endpoints
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4 (Social Login Registration)
  - Configure POST methods for both endpoints
  - Integrate with OAuth2Handler Lambda function
  - Set throttling to 10 requests/second
  - No authorization required (public endpoints)
  
- [ ] 12.5 Create /auth/login endpoint
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 9 (Successful Login), Req 10 (Invalid Credentials)
  - Configure POST method
  - Integrate with AuthLoginHandler Lambda function
  - Set throttling to 10 requests/second per IP (rate limiting per authentication standards)
  - No authorization required (public endpoint)
  - Configure request validation
  
- [ ] 12.6 Create /auth/logout endpoint
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 9 (Successful Login - logout flow)
  - Configure POST method
  - Integrate with AuthLogoutHandler Lambda function
  - Add JWT authorizer (validate token before invoking Lambda)
  - Set throttling to 100 requests/second
  
- [ ] 12.7 Create /profile endpoints
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Requirements**: Req 15 (View Profile), Req 16 (Display Fields), Req 23 (Save Profile)
  - Configure GET method for profile retrieval (integrate with GetProfileHandler)
  - Configure PUT method for profile update (integrate with UpdateProfileHandler)
  - Add JWT authorizer to both methods
  - Set throttling to 100 requests/second for GET, 50 requests/second for PUT
  
- [ ] 12.8 Create /profile/email-policy endpoint
  - **Requirement Type**: BR (Business Rule)
  - **Requirements**: Req 25 (Read Only Email Rule)
  - Configure GET method
  - Integrate with GetEmailPolicyHandler Lambda function
  - Add JWT authorizer
  - Set throttling to 100 requests/second
  
- [ ] 12.9 Create JWT authorizer for API Gateway
  - **Requirement Type**: SR (Security Requirement)
  - **Requirements**: All authenticated endpoints
  - Configure custom authorizer Lambda (or use Cognito User Pool)
  - Validate JWT tokens (signature, expiry, claims)
  - Extract user ID from token claims and pass to Lambda functions
  - Cache authorization decisions (TTL: 300 seconds)
  - Return 401 for invalid/expired tokens

---

### Task 13: Checkpoint - Backend validation
**Phase**: 4 - Core Authentication  
**Requirement Types**: All  
**Team**: @team:backend @team:devops  
**Requirements**: All backend requirements

**Description**: Validate that all backend Lambda functions and API Gateway are working correctly before proceeding to frontend.

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

### Task 14: Create React project structure and shared services
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

### Task 15: Implement RegistrationComponent
**Phase**: 2 - Registration & Email Verification  
**Requirement Types**: UI (UI/UX Requirement), FR (Functional Requirement), VR (Validation Requirement), SR (Security Requirement)  
**Team**: @team:frontend @component:frontend-ui @priority:high  
**Requirements**: Req 1 (UI), Req 2 (FR+SR), Req 3 (SR+VR), Req 4 (FR+SR), Req 7 (VR)  
**Figma Reference**: Registration Page - Desktop/Mobile/Tablet, Email registration form, Social login buttons, Password requirements, Error states

**Description**: Implement the registration page component with email registration, social login, and password complexity validation, matching Figma designs pixel-perfect.

**Sub-tasks**:
- [ ] 15.1 Create component structure and template
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
  
- [ ] 15.2 Implement password requirements display
  - **Requirement Type**: SR (Security Requirement) + VR (Validation Requirement)
  - **Requirements**: Req 3 (Registration Password Complexity)
  - Display password complexity requirements in real-time
  - Show checkmarks for met requirements (green)
  - Show X marks for unmet requirements (gray)
  - Requirements: min 8 chars, uppercase, lowercase, digit, special char
  - Update display as user types
  
- [ ] 15.3 Implement form validation logic
  - **Requirement Type**: VR (Validation Requirement) + SR (Security Requirement)
  - **Requirements**: Req 3 (Password Complexity), Req 7 (Email Format)
  - Add reactive form with useState
  - Implement real-time email format validation using ValidationService
  - Implement real-time password complexity validation using ValidationService
  - Validate password and confirm password match
  - Display inline error messages below fields matching Figma error states
  - Clear error messages when user corrects input
  
- [ ] 15.4 Implement email registration submission logic
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Email Registration), Req 5 (Duplicate Account Prevention)
  - Call AuthService.register on form submit
  - Handle successful registration: display success message, redirect to login
  - Handle duplicate email error: display "An account with this email already exists"
  - Handle validation errors: display appropriate error messages
  - Show loading indicator during API call (spinner in button)
  - Disable form during submission to prevent double-submit
  
- [ ] 15.5 Implement social login functionality
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4 (Social Login Registration)
  - Call OAuth2Service.initiateGoogleLogin on Google button click
  - Call OAuth2Service.initiateAmazonLogin on Amazon button click
  - Handle OAuth2 callback and token storage
  - Redirect to home page after successful social login
  - Handle OAuth2 errors
  
- [ ]* 15.6 Write unit tests for RegistrationComponent
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

### Task 16: Implement LoginComponent
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

### Task 17: Implement ProfileComponent
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

### Task 18: Configure routing and navigation
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

### Task 19: Configure deployment pipeline
**Phase**: 7 - Testing & Deployment  
**Requirement Types**: PR (Performance Requirement)  
**Team**: @team:devops @component:devops-cicd  
**Requirements**: All requirements (deployment and monitoring)

**Description**: Configure and validate the CI/CD pipeline for automated build, test, and deployment using existing GitHub Actions workflows.

**Pipeline Files**:
- Lambda Pipeline: `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml`
- Setup Workflow: `ProfileManager-CDK/.github/workflows/setup-infrastructure.yml`

**Sub-tasks**:
- [ ] 19.1 Configure GitHub Actions secrets
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All requirements (deployment)
  - Add AWS_ACCESS_KEY_ID to GitHub repository secrets
  - Add AWS_SECRET_ACCESS_KEY to GitHub repository secrets
  - Verify secrets are accessible in workflow runs
  - Use `ProfileManager-CDK/scripts/setup-github-secrets.ps1` for guidance
  
- [ ] 19.2 Configure Lambda deployment pipeline
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All backend requirements
  - Pipeline file: `ProfileManager-CDK/.github/workflows/ci-cd-lambda.yml`
  - Triggers: Push to main branch, Pull requests to main
  - Build steps: Maven clean package, Run unit tests, Run integration tests, Generate coverage report
  - Deploy steps: Upload JAR to S3, Update Lambda function code
  - Verify pipeline runs successfully on push to main
  - Monitor CloudWatch logs after deployment
  
- [ ] 19.3 Configure frontend deployment (if separate from Lambda)
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All frontend requirements
  - Build React application for production (npm run build)
  - Deploy to S3 bucket with static website hosting
  - Configure CloudFront distribution for CDN (optional)
  - Configure environment-specific API Gateway URLs in .env files
  - Invalidate CloudFront cache after deployment (if using CloudFront)
  
- [ ] 19.4 Set up monitoring and alerts
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All requirements (monitoring)
  - Configure CloudWatch alarms for Lambda errors (threshold: > 5 errors in 5 minutes)
  - Set up API Gateway monitoring (4xx, 5xx errors, latency)
  - Configure RDS performance monitoring (CPU, connections, slow queries)
  - Monitor SES email delivery metrics
  - Create CloudWatch dashboard for system health
  - Set up SNS notifications for critical alerts
  - Configure log retention policies (30 days) - already set in CloudFormation template
  - Use `ProfileManager-CDK/scripts/check-lambda-logs.ps1` for log monitoring

---

### Task 20: Integration testing and validation
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

### Task 21: Final checkpoint - Production readiness validation
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
| Req 2 | Email Registration | Task 3.3 (JWT utility), Task 4.1 (UserRepository), Task 5 (RegistrationHandler), Task 12.2 (API Gateway), Task 14.3 (AuthService), Task 15 (RegistrationComponent), Task 18.1 (Routing) |
| Req 4 | Social Login Registration | Task 3.5 (OAuth2 utility), Task 4.1 (UserRepository), Task 7 (OAuth2Handler), Task 12.4 (API Gateway), Task 14.4 (OAuth2Service), Task 15.5 (RegistrationComponent) |
| Req 6 | Email Verification | Task 3.6 (Email service), Task 4.1 (UserRepository), Task 5.5 (Send email), Task 6 (EmailVerificationHandler), Task 12.3 (API Gateway) |
| Req 9 | Successful Login | Task 3.3 (JWT utility), Task 4.1 (UserRepository), Task 8 (AuthLoginHandler), Task 11.1 (AuthLogoutHandler), Task 12.5-12.6 (API Gateway), Task 14.3 (AuthService), Task 16 (LoginComponent), Task 18 (Routing) |
| Req 10 | Invalid Credentials | Task 3.10 (Exceptions), Task 4.1 (UserRepository), Task 8 (AuthLoginHandler), Task 12.5 (API Gateway), Task 14.3 (AuthService), Task 16 (LoginComponent) |
| Req 23 | Save Profile | Task 4.1 (UserRepository), Task 10 (UpdateProfileHandler), Task 12.7 (API Gateway), Task 14.5 (ProfileService), Task 17 (ProfileComponent) |
| Req 24 | Cancel Changes | Task 17.5 (ProfileComponent cancel functionality) |

### UI/UX Requirements (UI) - User interface and experience

| Requirement | Description | Implementing Tasks | Figma Reference |
|-------------|-------------|-------------------|-----------------|
| Req 1 | Registration Page Access | Task 15.1 (RegistrationComponent structure), Task 18.1 (Routing) | Registration Page - Desktop/Mobile/Tablet |
| Req 8 | Login Page Access | Task 16.1 (LoginComponent structure), Task 18.1 (Routing) | Login Page - Desktop/Mobile/Tablet |
| Req 15 | View Profile Page | Task 9 (GetProfileHandler), Task 17.1-17.2 (ProfileComponent), Task 18.1 (Routing) | Profile Management Page |
| Req 16 | Display Profile Fields | Task 2.1-2.2 (Database schema), Task 9 (GetProfileHandler), Task 17.1 (ProfileComponent) | Profile - Form Fields |
| Req 18 | Title Field Behavior | Task 2.1 (Database), Task 17.1 (ProfileComponent) | Profile - Title dropdown |
| Req 19 | Gender Field Validation | Task 2.1 (Database), Task 10.2 (Validation), Task 17.1-17.3 (ProfileComponent) | Profile - Gender radio buttons |
| Req 22 | Preferences Selection | Task 2.2 (Database), Task 10.2 (Validation), Task 17.1-17.3 (ProfileComponent) | Profile - Preferences checkboxes |
| Req 25 | Read Only Email Rule | Task 11.2 (GetEmailPolicyHandler), Task 12.8 (API Gateway), Task 14.5 (ProfileService), Task 17.2 (ProfileComponent) | Profile - Email read-only state |

### Validation Requirements (VR) - Input validation and data integrity

| Requirement | Description | Implementing Tasks | Property Tests |
|-------------|-------------|-------------------|----------------|
| Req 3 | Registration Password Complexity | Task 3.2 (BCrypt), Task 3.4 (Validators), Task 5.2 (RegistrationHandler), Task 14.2 (ValidationService), Task 15.2-15.3 (RegistrationComponent) | Task 3.8 (Property 2) |
| Req 7 | Registration Email Format Validation | Task 3.4 (Validators), Task 5.2 (RegistrationHandler), Task 14.2 (ValidationService), Task 15.3 (RegistrationComponent) | Task 3.7 (Property 4) |
| Req 11 | Mandatory Fields Validation | Task 3.4 (Validators), Task 14.2 (ValidationService), Task 16.2 (LoginComponent) | Task 16.4 (Property 7) |
| Req 12 | Password Format Validation | Task 3.2 (BCrypt), Task 3.4 (Validators), Task 14.2 (ValidationService), Task 16.2 (LoginComponent) | Task 3.8 (Property 2) |
| Req 13 | Email Format Validation | Task 3.4 (Validators), Task 14.2 (ValidationService), Task 16.2 (LoginComponent) | Task 3.7 (Property 4) |
| Req 17 | Mandatory Profile Fields | Task 3.4 (Validators), Task 10.2 (UpdateProfileHandler), Task 17.3 (ProfileComponent) | Task 10.4 (Property 11) |
| Req 19 | Gender Field Validation | Task 10.2 (UpdateProfileHandler), Task 17.3 (ProfileComponent) | Task 10.4 (Property 11) |
| Req 20 | Age Validation | Task 3.4 (Validators), Task 10.2 (UpdateProfileHandler), Task 17.3 (ProfileComponent) | Task 3.9 (Property 12) |
| Req 21 | Email Validation in Profile | Task 3.4 (Validators), Task 10.2 (UpdateProfileHandler), Task 17.3 (ProfileComponent) | Task 3.7 (Property 4) |
| Req 22 | Preferences Selection | Task 3.4 (Validators), Task 10.2 (UpdateProfileHandler), Task 17.3 (ProfileComponent) | Task 10.5 (Property 14) |

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
- JWT token authentication (Task 3.3, 12.9)
- API Gateway rate limiting (Task 12.2: 5 req/s for registration, Task 12.5: 10 req/s for login)
- HTTPS enforcement (Task 12.1)
- SQL injection prevention with parameterized queries (Task 4.1, 4.2)
- XSS prevention with React sanitization (Task 14.1)
- CSRF protection (Task 12.1)
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
| Infrastructure | Scalability and performance | Task 1 (AWS infrastructure), Task 12 (API Gateway), Task 19 (Deployment) | Lambda cold start < 3s, API response < 500ms p95, Page load < 2s, Email delivery < 5s |

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
| Property 7 | Login button disabled state | Req 11 (Mandatory Fields) | Task 16.4 |
| Property 8 | Password complexity validation during login | Req 12 (Password Format) | Task 3.8 |
| Property 9 | Email format validation during login | Req 13 (Email Format) | Task 3.7 |
| Property 10 | Account locking after failed attempts | Req 14 (Account Locking) | Task 8.7 |
| Property 11 | Mandatory profile fields validation | Req 17, 19 (Mandatory Fields, Gender) | Task 10.4 |
| Property 12 | Age range validation | Req 20 (Age Validation) | Task 3.9 |
| Property 13 | Email format validation in profile | Req 21 (Email in Profile) | Task 3.7 |
| Property 14 | Preferences selection validation | Req 22 (Preferences) | Task 10.5 |
| Property 15 | Profile save round-trip with success message | Req 23 (Save Profile) | Task 10.6 |
| Property 16 | Cancel discards changes | Req 24 (Cancel Changes) | Task 17.6 |

---

## Task Dependencies and Execution Order

### Phase 1: Infrastructure & Security (Week 1)
**Critical Path**: Task 1 → Task 2 → Task 3 → Task 4

1. Task 1: AWS infrastructure (no dependencies)
2. Task 2: Database schema (depends on Task 1)
3. Task 3: Lambda utilities (depends on Task 1, 2)
4. Task 4: Repository classes (depends on Task 2, 3)

### Phase 2: Registration & Email Verification (Week 2)
**Critical Path**: Task 5 → Task 6 → Task 12 → Task 13

5. Task 5: RegistrationHandler (depends on Task 3, 4)
6. Task 6: EmailVerificationHandler (depends on Task 3, 4)
7. Task 12: API Gateway (depends on Task 5, 6, 7, 8, 11)
8. Task 13: Backend checkpoint (depends on Task 5, 6, 12)

### Phase 3: Social Login Integration (Week 3)
**Critical Path**: Task 7 → Task 12

9. Task 7: OAuth2Handler (depends on Task 3, 4)
10. Task 12: API Gateway OAuth2 endpoints (depends on Task 7)

### Phase 4: Core Authentication (Week 4)
**Critical Path**: Task 8 → Task 12 → Task 13 → Task 14 → Task 16 → Task 18

11. Task 8: AuthLoginHandler (depends on Task 3, 4)
12. Task 12: API Gateway login endpoints (depends on Task 8)
13. Task 13: Backend checkpoint (depends on Task 8, 12)
14. Task 14: React services (depends on Task 13)
15. Task 16: LoginComponent (depends on Task 14)
16. Task 18: Routing (depends on Task 15, 16)

### Phase 5: Validation Layer (Week 5)
**Parallel Execution**: Task 3.4-3.9 (validation utilities and property tests)

- Can be executed in parallel with Phase 2-4 tasks
- Property tests validate validation logic

### Phase 6: Profile Management (Week 6)
**Critical Path**: Task 9 → Task 10 → Task 11 → Task 17

17. Task 9: GetProfileHandler (depends on Task 4)
18. Task 10: UpdateProfileHandler (depends on Task 3, 4)
19. Task 11: Supporting functions (depends on Task 3)
20. Task 17: ProfileComponent (depends on Task 9, 10, 11, 14)

### Phase 7: Testing & Deployment (Week 7)
**Critical Path**: Task 19 → Task 20 → Task 21

21. Task 19: Deployment pipeline (depends on all implementation tasks)
22. Task 20: Integration testing (depends on Task 19)
23. Task 21: Final checkpoint (depends on Task 20)

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
