# Implementation Plan: User Authentication, Registration, and Profile Management

## Overview

This implementation plan breaks down the user authentication, registration, and profile management system into discrete, actionable tasks as part of the REXX modernization initiative. Each task is mapped to specific requirement types to ensure complete traceability from requirements through implementation.

**Technology Stack:**
- **Backend**: Java 17, AWS Lambda, API Gateway, Maven
- **Frontend**: React 18+, TypeScript, Material-UI (MUI)
- **Database**: PostgreSQL (Amazon RDS)
- **Infrastructure**: AWS CDK (CloudFormation/SAM)
- **DevOps**: GitHub, Jenkins/GitHub Actions, Docker, SonarQube
- **Email Service**: AWS SES for email verification
- **OAuth2**: Google and Amazon OAuth2 integration
- **Design**: Figma for UI/UX specifications

**Figma Design Reference**: #[[figma:https://www.figma.com/design/GGoFL7U4ljuiJxfQ1VBBbi/POC?node-id=1-1077&t=jPWNYDTKebx4Ygd4-1]]

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

### Task 1: Set up AWS infrastructure using CDK
**Phase**: 1 - Infrastructure & Security  
**Requirement Types**: PR (Performance Requirement)  
**Team**: @team:devops @component:devops-infra @priority:high  
**Requirements**: All requirements (infrastructure foundation)

**Description**: Create the foundational AWS infrastructure for the application using Infrastructure as Code (AWS CDK).

**Sub-tasks**:
- [ ] 1.1 Create CDK project structure for infrastructure as code
  - Initialize CDK project with TypeScript
  - Define stack structure for dev, staging, prod environments
  
- [ ] 1.2 Define RDS PostgreSQL instance with appropriate security groups
  - Configure PostgreSQL 14+ instance
  - Set up VPC and security groups
  - Enable encryption at rest and in transit
  
- [ ] 1.3 Configure RDS Proxy for connection pooling
  - Set up RDS Proxy for Lambda connection pooling
  - Configure connection limits and timeouts
  
- [ ] 1.4 Set up Secrets Manager for database credentials, JWT secret, and OAuth2 secrets
  - Create secrets for database credentials
  - Create secret for JWT signing key
  - Create secrets for Google OAuth2 client ID and secret
  - Create secrets for Amazon OAuth2 client ID and secret
  - Configure automatic rotation policies
  
- [ ] 1.5 Create API Gateway REST API with CORS configuration
  - Define REST API resource
  - Configure CORS for allowed origins
  - Set up request/response models
  
- [ ] 1.6 Configure CloudWatch Log Groups for Lambda functions
  - Create log groups for each Lambda function (including registration, verification, OAuth2)
  - Set retention policies (30 days)
  - Configure log insights queries
  
- [ ] 1.7 Set up AWS SES for email sending
  - Configure SES in appropriate region
  - Verify sender email address
  - Move out of SES sandbox for production
  - Configure email templates for verification emails

---

### Task 2: Create database schema and migration scripts
**Phase**: 1 - Infrastructure & Security  
**Requirement Types**: DR (Data Requirement)  
**Team**: @team:backend @component:backend-data @priority:high  
**Requirements**: Req 2 (FR+SR), Req 6 (FR+SR), Req 14 (SR), Req 16 (UI+DR), Req 18 (UI), Req 19 (UI+VR), Req 22 (UI+VR)

**Description**: Design and implement the PostgreSQL database schema to store user authentication, registration, and profile data.

**Sub-tasks**:
- [ ] 2.1 Create users table (Customer_Identity) with all required fields
  - **Requirement Type**: DR (Data Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Email Registration), Req 6 (Email Verification), Req 16 (Display Profile Fields), Req 18 (Title Field), Req 19 (Gender Field), Req 22 (Preferences)
  - Define table structure with proper constraints (NOT NULL, CHECK, UNIQUE)
  - Add indexes for email, account_locked, verification_token, and provider fields
  - Include fields: id, title, first_name, last_name, gender, age, email, password_hash, address, account_locked, locked_until, email_verified, verification_token, verification_token_expiry, auth_provider, provider_id, created_at, updated_at
  - Add UNIQUE constraint on email column
  - Add CHECK constraint on age (18-120)
  
- [ ] 2.2 Create user_preferences table
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 22 (Preferences Selection)
  - Define foreign key relationship to users table with CASCADE delete
  - Add index on user_id for join performance
  - Include fields: user_id, preference
  
- [ ] 2.3 Create login_attempts table
  - **Requirement Type**: SR (Security Requirement) + DR (Data Requirement)
  - **Requirements**: Req 14 (Account Locking)
  - Define table for tracking authentication attempts
  - Add indexes for email and timestamp queries
  - Include fields: id, email, timestamp, successful, ip_address
  
- [ ] 2.4 Create token_blacklist table for logout
  - **Requirement Type**: SR (Security Requirement) + DR (Data Requirement)
  - **Requirements**: Req 9 (Successful Login - logout flow)
  - Define table for storing invalidated JWT tokens
  - Add index on token_hash and expiry
  - Include fields: id, token_hash, expiry, created_at
  
- [ ] 2.5 Create database migration scripts
  - **Requirement Type**: DR (Data Requirement)
  - Write SQL scripts for schema creation
  - Add rollback scripts for each migration
  - Test migrations in dev environment

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
