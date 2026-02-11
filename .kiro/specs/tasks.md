# Implementation Plan: User Authentication and Profile Management

## Overview

This implementation plan breaks down the user authentication and profile management system into discrete, actionable tasks as part of the REXX modernization initiative. Each task is mapped to specific requirement types to ensure complete traceability from requirements through implementation.

**Technology Stack:**
- **Backend**: Java 17, AWS Lambda, API Gateway, Maven
- **Frontend**: Angular 16+, TypeScript, Angular Material
- **Database**: PostgreSQL (Amazon RDS)
- **Infrastructure**: AWS CDK (CloudFormation/SAM)
- **DevOps**: GitHub, Jenkins/GitHub Actions, Docker, SonarQube
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

### Phase 2: Core Authentication (Week 2)
Implement login functionality with validation

### Phase 3: Validation Layer (Week 3)
Build comprehensive validation for all inputs

### Phase 4: Profile Management (Week 4)
Implement profile CRUD operations

### Phase 5: Testing & Deployment (Week 5)
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
  
- [ ] 1.4 Set up Secrets Manager for database credentials and JWT secret
  - Create secrets for database credentials
  - Create secret for JWT signing key
  - Configure automatic rotation policies
  
- [ ] 1.5 Create API Gateway REST API with CORS configuration
  - Define REST API resource
  - Configure CORS for allowed origins
  - Set up request/response models
  
- [ ] 1.6 Configure CloudWatch Log Groups for Lambda functions
  - Create log groups for each Lambda function
  - Set retention policies (30 days)
  - Configure log insights queries

---

### Task 2: Create database schema and migration scripts
**Phase**: 1 - Infrastructure & Security  
**Requirement Types**: DR (Data Requirement)  
**Team**: @team:backend @component:backend-data @priority:high  
**Requirements**: Req 7 (SR), Req 9 (UI+DR), Req 11 (UI), Req 12 (UI+VR), Req 15 (UI+VR)

**Description**: Design and implement the PostgreSQL database schema to store user authentication and profile data.

**Sub-tasks**:
- [ ] 2.1 Create users table with all required fields
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 9 (Display Profile Fields), Req 11 (Title Field), Req 12 (Gender Field), Req 15 (Preferences)
  - Define table structure with proper constraints (NOT NULL, CHECK, UNIQUE)
  - Add indexes for email and account_locked fields for query performance
  - Include fields: id, title, first_name, last_name, gender, age, email, password_hash, address, account_locked, locked_until, created_at, updated_at
  
- [ ] 2.2 Create user_preferences table
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 15 (Preferences Selection)
  - Define foreign key relationship to users table with CASCADE delete
  - Add index on user_id for join performance
  - Include fields: user_id, preference
  
- [ ] 2.3 Create login_attempts table
  - **Requirement Type**: SR (Security Requirement) + DR (Data Requirement)
  - **Requirements**: Req 7 (Account Locking)
  - Define table for tracking authentication attempts
  - Add indexes for email and timestamp queries
  - Include fields: id, email, timestamp, successful, ip_address
  
- [ ] 2.4 Create database migration scripts
  - **Requirement Type**: DR (Data Requirement)
  - Write SQL scripts for schema creation
  - Add rollback scripts for each migration
  - Test migrations in dev environment

---

### Task 3: Implement shared Lambda layer utilities
**Phase**: 1 - Infrastructure & Security  
**Requirement Types**: SR (Security Requirement), VR (Validation Requirement), FR (Functional Requirement)  
**Team**: @team:backend @component:backend-service @priority:high  
**Requirements**: Req 2 (FR), Req 5 (SR+VR), Req 6 (VR), Req 10 (VR+BR), Req 13 (VR+BR), Req 14 (VR), Req 15 (UI+VR)

**Description**: Create reusable utility classes for Lambda functions including database access, security, and validation.

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
  - **Requirements**: Req 5 (Password Format Validation)
  - Use BCrypt for password hashing with salt rounds = 10
  - Implement hash generation method
  - Implement hash verification method
  - Never store plain text passwords
  
- [ ] 3.3 Create JWT token utility
  - **Requirement Type**: SR (Security Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 2 (Successful Login)
  - Implement JWT token generation with configurable expiry (default 1 hour)
  - Add token validation and parsing methods
  - Retrieve JWT secret from Secrets Manager
  - Include user ID and email in token claims
  
- [ ] 3.4 Implement validation utility classes
  - **Requirement Type**: VR (Validation Requirement)
  - **Requirements**: Req 5 (Password), Req 6 (Email), Req 10 (Mandatory Fields), Req 12 (Gender), Req 13 (Age), Req 14 (Email in Profile), Req 15 (Preferences)
  - Create EmailValidator class with regex pattern
  - Create PasswordValidator class with complexity rules
  - Create AgeValidator class with range check (18-120)
  - Create MandatoryFieldValidator class
  - Create PreferencesValidator class
  
- [ ] 3.5 Write property test for email validation
  - **Requirement Type**: VR (Validation Requirement)
  - **Property 5**: Email format validation
  - **Validates**: Req 6 (Email Format Validation), Req 14 (Email Validation in Profile)
  - Test with randomly generated invalid emails (no @, no domain, with spaces)
  - Minimum 100 iterations
  
- [ ] 3.6 Write property test for password complexity validation
  - **Requirement Type**: SR (Security Requirement) + VR (Validation Requirement)
  - **Property 4**: Password complexity validation
  - **Validates**: Req 5 (Password Format Validation)
  - Test with randomly generated passwords missing complexity requirements
  - Minimum 100 iterations
  
- [ ] 3.7 Write property test for age range validation
  - **Requirement Type**: VR (Validation Requirement) + BR (Business Rule)
  - **Property 8**: Age range validation
  - **Validates**: Req 13 (Age Validation)
  - Test with randomly generated ages outside range (< 18, > 120, non-numeric)
  - Minimum 100 iterations
  
- [ ] 3.8 Create exception classes
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 3 (Invalid Credentials), Req 7 (Account Locking), Req 10 (Mandatory Fields), Req 12 (Gender Validation)
  - Define InvalidCredentialsException for authentication failures
  - Define AccountLockedException for locked accounts
  - Define ValidationException for field validation failures
  - Define ProfileNotFoundException for missing profiles
  - All exceptions extend RuntimeException
  
- [ ] 3.9 Implement Lambda exception handler
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
**Requirements**: Req 2 (FR), Req 3 (FR), Req 7 (SR), Req 8 (UI), Req 16 (FR+DR)

**Description**: Implement repository pattern classes for database access using JDBC.

**Sub-tasks**:
- [ ] 4.1 Create UserRepository class
  - **Requirement Type**: DR (Data Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 2 (Successful Login), Req 3 (Invalid Credentials), Req 8 (View Profile Page), Req 16 (Save Profile)
  - Implement findByEmail(String email) method with JDBC PreparedStatement
  - Implement save(User user) method for insert/update operations
  - Implement findById(Long id) method
  - Use SLF4J for logging all database operations
  - Handle SQLException with proper error messages
  
- [ ] 4.2 Create LoginAttemptRepository class
  - **Requirement Type**: SR (Security Requirement) + DR (Data Requirement)
  - **Requirements**: Req 7 (Account Locking)
  - Implement findRecentAttempts(String email, int minutes) method
  - Implement save(LoginAttempt attempt) method for recording attempts
  - Implement deleteOldAttempts(String email, int minutes) cleanup method
  - Use SLF4J for logging security events
  
- [ ]* 4.3 Write unit tests for repository classes
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 2, Req 3, Req 7, Req 16
  - Test CRUD operations with H2 in-memory database
  - Test query methods with various inputs (valid, invalid, edge cases)
  - Test error handling for database failures
  - Target 70% minimum coverage (per Java conventions)
  - Use JUnit 5 and Mockito

---

### Task 5: Implement AuthLoginHandler Lambda function
**Phase**: 2 - Core Authentication  
**Requirement Types**: FR (Functional Requirement), SR (Security Requirement)  
**Team**: @team:backend @component:backend-api @priority:high  
**Requirements**: Req 2 (FR), Req 3 (FR), Req 5 (SR+VR), Req 7 (SR)  
**Figma Reference**: Login Page - Error states, Account locked state

**Description**: Implement the Lambda function that handles user authentication requests.

**Sub-tasks**:
- [ ] 5.1 Create Lambda handler class and request parsing
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 2 (Successful Login), Req 3 (Invalid Credentials)
  - Create AuthLoginHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent to extract email and password
  - Set up CloudWatch logging with SLF4J
  - Validate request body format
  
- [ ] 5.2 Implement authentication logic
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Successful Login), Req 7 (Account Locking)
  - Query user by email from database using UserRepository
  - Check if account is locked (account_locked = true and locked_until > now)
  - Verify password using BCrypt hash comparison
  - Generate JWT token on successful authentication
  - Return user info (id, email, firstName, lastName) with token
  
- [ ] 5.3 Implement failed attempt tracking
  - **Requirement Type**: SR (Security Requirement)
  - **Requirements**: Req 7 (Account Locking)
  - Record failed login attempts in login_attempts table
  - Count recent failed attempts (last 30 minutes) using LoginAttemptRepository
  - Lock account after 5 consecutive failures (set account_locked = true, locked_until = now + 30 minutes)
  - Log account locking events to CloudWatch
  
- [ ] 5.4 Format response with proper HTTP status codes
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 2 (Successful Login), Req 3 (Invalid Credentials), Req 7 (Account Locking)
  - Return 200 with JWT token and user info on success
  - Return 401 with "Invalid username or password" message on failure
  - Return 403 with "Account is locked" message for locked accounts
  - Follow REST standards with proper headers (Content-Type, CORS)
  
- [ ]* 5.5 Write unit test for successful login
  - **Requirement Type**: FR (Functional Requirement)
  - **Property 1**: Valid credentials authenticate successfully
  - **Validates**: Req 2 (Successful Login)
  - Test valid credentials return JWT token
  - Verify response format and status code 200
  - Verify token contains correct user claims
  
- [ ]* 5.6 Write property test for invalid credentials
  - **Requirement Type**: FR (Functional Requirement)
  - **Property 2**: Invalid credentials return error message
  - **Validates**: Req 3 (Invalid Credentials)
  - Test with randomly generated invalid email/password combinations
  - Verify error message "Invalid username or password"
  - Minimum 100 iterations
  
- [ ]* 5.7 Write property test for account locking
  - **Requirement Type**: SR (Security Requirement)
  - **Property 6**: Account locking after failed attempts
  - **Validates**: Req 7 (Account Locking)
  - Test account locks after 5 consecutive failures
  - Verify locked account prevents login for 30 minutes
  - Verify account unlocks after 30 minutes

---

### Task 6: Implement GetProfileHandler Lambda function
**Phase**: 4 - Profile Management  
**Requirement Types**: UI (UI/UX Requirement), DR (Data Requirement)  
**Team**: @team:backend @component:backend-api  
**Requirements**: Req 8 (UI), Req 9 (UI+DR)  
**Figma Reference**: Profile Management Page - Form layout

**Description**: Implement the Lambda function that retrieves user profile data.

**Sub-tasks**:
- [ ] 6.1 Create Lambda handler class
  - **Requirement Type**: UI (UI/UX Requirement) + DR (Data Requirement)
  - **Requirements**: Req 8 (View Profile Page), Req 9 (Display Profile Fields)
  - Create GetProfileHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent
  - Extract user ID from JWT token (validated by API Gateway authorizer)
  - Set up CloudWatch logging with SLF4J
  
- [ ] 6.2 Implement profile retrieval logic
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 8 (View Profile Page), Req 9 (Display Profile Fields)
  - Query user profile from database by user ID using UserRepository
  - Join with user_preferences table to get preferences list
  - Handle profile not found scenario (return 404)
  - Format profile data as JSON response with all 8 fields
  - Return 200 with profile data
  
- [ ]* 6.3 Write unit tests for profile retrieval
  - **Requirement Type**: DR (Data Requirement)
  - **Requirements**: Req 8, Req 9
  - Test successful profile fetch with all fields
  - Test profile not found error (404)
  - Test JWT token extraction
  - Mock database with H2 in-memory database

---

### Task 7: Implement UpdateProfileHandler Lambda function
**Phase**: 4 - Profile Management  
**Requirement Types**: VR (Validation Requirement), BR (Business Rule), FR (Functional Requirement), DR (Data Requirement)  
**Team**: @team:backend @component:backend-api @priority:high  
**Requirements**: Req 10 (VR+BR), Req 12 (UI+VR), Req 13 (VR+BR), Req 14 (VR), Req 15 (UI+VR), Req 16 (FR+DR), Req 18 (BR+UI)  
**Figma Reference**: Profile Management Page - Validation states, Success message

**Description**: Implement the Lambda function that updates user profile data with comprehensive validation.

**Sub-tasks**:
- [ ] 7.1 Create Lambda handler class and request parsing
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 16 (Save Profile)
  - Create UpdateProfileHandler class extending RequestHandler
  - Parse APIGatewayProxyRequestEvent
  - Extract user ID from JWT token
  - Parse ProfileUpdateRequest from request body
  - Set up CloudWatch logging with SLF4J
  
- [ ] 7.2 Implement profile validation logic
  - **Requirement Type**: VR (Validation Requirement) + BR (Business Rule)
  - **Requirements**: Req 10 (Mandatory Fields), Req 12 (Gender), Req 13 (Age), Req 14 (Email), Req 15 (Preferences), Req 18 (Email Policy)
  - Validate all mandatory fields: firstName, lastName, email, gender (non-empty)
  - Validate gender selection (must be Male, Female, or Other)
  - Validate email format using EmailValidator
  - Validate age range 18-120 using AgeValidator
  - Validate at least one preference selected using PreferencesValidator
  - Check email modification policy from GetEmailPolicyHandler
  - Return 400 with field-specific error messages on validation failure
  
- [ ] 7.3 Implement profile update logic
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Requirements**: Req 16 (Save Profile)
  - Update user record in users table using UserRepository
  - Delete existing preferences and insert new ones in user_preferences table
  - Set updated_at timestamp
  - Return success response with message "Profile updated successfully"
  - Return 200 with updated profile data
  - Log profile update event to CloudWatch
  
- [ ]* 7.4 Write property test for mandatory fields validation
  - **Requirement Type**: VR (Validation Requirement) + BR (Business Rule)
  - **Property 7**: Mandatory profile fields validation
  - **Validates**: Req 10 (Mandatory Profile Fields), Req 12 (Gender Field Validation)
  - Test with randomly generated profiles missing mandatory fields
  - Verify appropriate error messages for each missing field
  - Minimum 100 iterations
  
- [ ]* 7.5 Write property test for preferences validation
  - **Requirement Type**: VR (Validation Requirement)
  - **Property 9**: Preferences selection validation
  - **Validates**: Req 15 (Preferences Selection)
  - Test with profiles having no preferences selected
  - Verify error message "At least one preference is required"
  - Minimum 100 iterations
  
- [ ]* 7.6 Write property test for profile save round-trip
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Property 10**: Profile save round-trip with success message
  - **Validates**: Req 16 (Save Profile)
  - Test saving profile and retrieving it returns equivalent data
  - Verify success message "Profile updated successfully"
  - Test with randomly generated valid profiles
  - Minimum 100 iterations
  
- [ ]* 7.7 Write unit tests for profile update
  - **Requirement Type**: VR (Validation Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 10, Req 12, Req 13, Req 14, Req 15, Req 16, Req 18
  - Test successful profile update with all valid data
  - Test validation errors for invalid data (each field)
  - Test email policy enforcement (read-only email)
  - Target 70% minimum coverage (per Java conventions)
  - Use JUnit 5 and Mockito

---

### Task 8: Implement supporting Lambda functions
**Phase**: 4 - Profile Management  
**Requirement Types**: FR (Functional Requirement), BR (Business Rule), UI (UI/UX Requirement)  
**Team**: @team:backend @component:backend-api  
**Requirements**: Req 2 (FR), Req 18 (BR+UI)

**Description**: Implement additional Lambda functions for logout and email policy.

**Sub-tasks**:
- [ ] 8.1 Create AuthLogoutHandler Lambda function
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 2 (Successful Login - logout flow)
  - Create AuthLogoutHandler class extending RequestHandler
  - Parse request and extract JWT token from Authorization header
  - Implement token blacklist logic (optional - add to database table)
  - Return 200 success response
  - Use SLF4J for logging logout events
  
- [ ] 8.2 Create GetEmailPolicyHandler Lambda function
  - **Requirement Type**: BR (Business Rule) + UI (UI/UX Requirement)
  - **Requirements**: Req 18 (Read Only Email Rule)
  - Create GetEmailPolicyHandler class extending RequestHandler
  - Read EMAIL_MODIFICATION_ALLOWED environment variable
  - Return policy configuration as JSON: {"emailModificationAllowed": true/false}
  - Return 200 with policy data
  - Cache policy response in frontend
  
- [ ]* 8.3 Write unit tests for supporting functions
  - **Requirement Type**: FR (Functional Requirement) + BR (Business Rule)
  - **Requirements**: Req 2, Req 18
  - Test logout handler with valid token
  - Test email policy handler returns correct policy
  - Test environment variable configuration
  - Use JUnit 5 and Mockito

---

### Task 9: Configure API Gateway endpoints and integrations
**Phase**: 2 - Core Authentication  
**Requirement Types**: FR (Functional Requirement), SR (Security Requirement), PR (Performance Requirement)  
**Team**: @team:devops @component:devops-infra  
**Requirements**: All API requirements

**Description**: Configure API Gateway REST API with endpoints, Lambda integrations, and security.

**Sub-tasks**:
- [ ] 9.1 Create API Gateway REST API resource
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All API requirements
  - Define API name: "UserAuthProfileAPI"
  - Configure CORS settings (allow origins, methods, headers)
  - Set up request/response models
  - Enable CloudWatch logging
  
- [ ] 9.2 Create /auth/login endpoint
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Successful Login), Req 3 (Invalid Credentials)
  - Configure POST method
  - Integrate with AuthLoginHandler Lambda function
  - Set throttling to 10 requests/second per IP (rate limiting per authentication standards)
  - No authorization required (public endpoint)
  - Configure request validation
  
- [ ] 9.3 Create /auth/logout endpoint
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 2 (Successful Login - logout flow)
  - Configure POST method
  - Integrate with AuthLogoutHandler Lambda function
  - Add JWT authorizer (validate token before invoking Lambda)
  - Set throttling to 100 requests/second
  
- [ ] 9.4 Create /profile endpoints
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Requirements**: Req 8 (View Profile), Req 9 (Display Fields), Req 16 (Save Profile)
  - Configure GET method for profile retrieval (integrate with GetProfileHandler)
  - Configure PUT method for profile update (integrate with UpdateProfileHandler)
  - Add JWT authorizer to both methods
  - Set throttling to 100 requests/second for GET, 50 requests/second for PUT
  
- [ ] 9.5 Create /profile/email-policy endpoint
  - **Requirement Type**: BR (Business Rule)
  - **Requirements**: Req 18 (Read Only Email Rule)
  - Configure GET method
  - Integrate with GetEmailPolicyHandler Lambda function
  - Add JWT authorizer
  - Set throttling to 100 requests/second
  
- [ ] 9.6 Create JWT authorizer for API Gateway
  - **Requirement Type**: SR (Security Requirement)
  - **Requirements**: All authenticated endpoints
  - Configure custom authorizer Lambda (or use Cognito User Pool)
  - Validate JWT tokens (signature, expiry, claims)
  - Extract user ID from token claims and pass to Lambda functions
  - Cache authorization decisions (TTL: 300 seconds)
  - Return 401 for invalid/expired tokens

---

### Task 10: Checkpoint - Backend validation
**Phase**: 2 - Core Authentication  
**Requirement Types**: All  
**Team**: @team:backend @team:devops  
**Requirements**: All backend requirements

**Description**: Validate that all backend Lambda functions and API Gateway are working correctly before proceeding to frontend.

**Validation Steps**:
- [ ] Test each Lambda function independently with sample events
- [ ] Test API Gateway endpoints with Postman or curl
- [ ] Verify database connections and queries work correctly
- [ ] Check CloudWatch logs for errors and warnings
- [ ] Verify JWT token generation and validation
- [ ] Test account locking after 5 failed attempts
- [ ] Ensure all unit tests and property tests pass
- [ ] Ask the user if questions arise before proceeding

---

### Task 11: Create Angular project structure and shared services
**Phase**: 3 - Validation Layer  
**Requirement Types**: VR (Validation Requirement), FR (Functional Requirement), UI (UI/UX Requirement)  
**Team**: @team:frontend @component:frontend-ui @priority:high  
**Requirements**: All frontend requirements  
**Figma Reference**: Component Library, Design System

**Description**: Set up Angular project with Material Design and implement shared services for validation, authentication, and profile management.

**Sub-tasks**:
- [ ] 11.1 Set up Angular project with Angular Material
  - **Requirement Type**: UI (UI/UX Requirement)
  - **Requirements**: All frontend requirements
  - Initialize Angular 16+ project with TypeScript
  - Install Angular Material and configure custom theme based on Figma colors
  - Set up routing module with lazy loading
  - Configure environment files for API Gateway URLs
  - Extract design tokens from Figma (colors, typography, spacing)
  
- [ ] 11.2 Create ValidationService
  - **Requirement Type**: VR (Validation Requirement)
  - **Requirements**: Req 5 (Password), Req 6 (Email), Req 10 (Mandatory Fields), Req 12 (Gender), Req 13 (Age), Req 14 (Email in Profile)
  - Implement validateEmail(email: string): ValidationResult method
  - Implement validatePassword(password: string): ValidationResult method
  - Implement validateAge(age: number): ValidationResult method
  - Implement validateMandatoryField(value: string): ValidationResult method
  - Return {isValid: boolean, errorMessage?: string} for each validator
  - Match server-side validation logic exactly
  
- [ ] 11.3 Create AuthService
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Successful Login), Req 3 (Invalid Credentials)
  - Implement login(email: string, password: string): Observable<AuthResponse> method
  - Implement logout(): void method
  - Implement token storage in localStorage with secure practices
  - Implement isAuthenticated(): boolean method
  - Implement getToken(): string | null method
  - Handle HTTP errors and map to user-friendly messages
  
- [ ] 11.4 Create ProfileService
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Requirements**: Req 8 (View Profile), Req 9 (Display Fields), Req 16 (Save Profile), Req 18 (Email Policy)
  - Implement getProfile(): Observable<UserProfile> method
  - Implement updateProfile(profile: UserProfile): Observable<UpdateResponse> method
  - Implement checkEmailPolicy(): Observable<EmailPolicyResponse> method
  - Include JWT token in Authorization header for all requests
  - Handle HTTP errors (401, 403, 404, 500)
  
- [ ]* 11.5 Write unit tests for services
  - **Requirement Type**: VR (Validation Requirement) + FR (Functional Requirement)
  - **Requirements**: All validation and service requirements
  - Test ValidationService methods with valid and invalid inputs
  - Test AuthService with mocked HttpClient
  - Test ProfileService with mocked HttpClient
  - Test error handling and edge cases
  - Use Jasmine and Karma

---

### Task 12: Implement LoginComponent
**Phase**: 2 - Core Authentication  
**Requirement Types**: UI (UI/UX Requirement), FR (Functional Requirement), VR (Validation Requirement), SR (Security Requirement)  
**Team**: @team:frontend @component:frontend-ui @priority:high  
**Requirements**: Req 1 (UI), Req 2 (FR), Req 3 (FR), Req 4 (VR), Req 5 (SR+VR), Req 6 (VR), Req 7 (SR)  
**Figma Reference**: Login Page - Desktop/Mobile/Tablet, Error states, Loading state, Account locked state

**Description**: Implement the login page component with form validation and authentication logic, matching Figma designs pixel-perfect.

**Sub-tasks**:
- [ ] 12.1 Create component structure and template
  - **Requirement Type**: UI (UI/UX Requirement)
  - **Requirements**: Req 1 (Login Page Access), Req 2 (Successful Login), Req 3 (Invalid Credentials), Req 4 (Mandatory Fields)
  - Create LoginComponent with TypeScript class and HTML template
  - Create login form with email and password fields using Angular Material
  - Add login button with disabled state
  - Add error message display area matching Figma error component
  - Apply Angular Material styling matching Figma design system
  - Implement responsive layout for Mobile (375px), Tablet (768px), Desktop (1440px)
  - Extract exact colors, spacing, typography from Figma Inspect
  
- [ ] 12.2 Implement form validation logic
  - **Requirement Type**: VR (Validation Requirement) + SR (Security Requirement)
  - **Requirements**: Req 4 (Mandatory Fields), Req 5 (Password Format), Req 6 (Email Format)
  - Add reactive form with FormBuilder
  - Implement real-time email format validation using ValidationService
  - Implement real-time password complexity validation using ValidationService
  - Disable login button when email or password field is empty (Req 4)
  - Display inline error messages below fields matching Figma error states
  - Clear error messages when user corrects input
  
- [ ] 12.3 Implement login submission logic
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement)
  - **Requirements**: Req 2 (Successful Login), Req 3 (Invalid Credentials), Req 7 (Account Locking)
  - Call AuthService.login on form submit
  - Handle successful login: store JWT token securely, redirect to home page
  - Handle authentication errors: display "Invalid username or password" message
  - Handle account locked errors: display "Account is locked. Please try again after 30 minutes." message
  - Show loading indicator during API call (spinner in button)
  - Disable form during submission to prevent double-submit
  
- [ ]* 12.4 Write property test for login button disabled state
  - **Requirement Type**: VR (Validation Requirement)
  - **Property 3**: Login button disabled state
  - **Validates**: Req 4 (Mandatory Fields Validation)
  - Test with randomly generated combinations of empty/non-empty email and password
  - Verify button is disabled if and only if at least one field is blank
  - Minimum 100 iterations
  
- [ ]* 12.5 Write unit tests for LoginComponent
  - **Requirement Type**: UI (UI/UX Requirement) + FR (Functional Requirement) + VR (Validation Requirement)
  - **Requirements**: Req 1, Req 2, Req 3, Req 4, Req 5, Req 6
  - Test form validation (email format, password complexity)
  - Test button disabled state when fields are empty
  - Test successful login flow (token storage, navigation)
  - Test error handling (invalid credentials, account locked)
  - Test loading state during API call
  - Use Jasmine and Karma with TestBed

---

### Task 13: Implement ProfileComponent
**Phase**: 4 - Profile Management  
**Requirement Types**: UI (UI/UX Requirement), VR (Validation Requirement), FR (Functional Requirement), BR (Business Rule), DR (Data Requirement)  
**Team**: @team:frontend @component:frontend-ui @priority:high  
**Requirements**: Req 8-18 (all profile requirements)  
**Figma Reference**: Profile Management Page - Desktop/Mobile/Tablet, Form layout, Validation states, Success message

**Description**: Implement the profile management page component with all fields, validation, and save/cancel functionality, matching Figma designs pixel-perfect.

**Sub-tasks**:
- [ ] 13.1 Create component structure and template
  - **Requirement Type**: UI (UI/UX Requirement)
  - **Requirements**: Req 8 (View Profile), Req 9 (Display Fields), Req 11 (Title), Req 12 (Gender), Req 15 (Preferences)
  - Create ProfileComponent with TypeScript class and HTML template
  - Create profile form with all 8 fields using Angular Material:
    - Title dropdown (Mr, Ms, Mrs, Dr) - `<mat-select>`
    - First Name text input (required) - `<mat-form-field>`
    - Last Name text input (required) - `<mat-form-field>`
    - Gender radio buttons (Male, Female, Other) (required) - `<mat-radio-group>`
    - Age numeric input (range: 18-120) - `<mat-form-field type="number">`
    - Email text input (required, conditionally read-only) - `<mat-form-field>`
    - Address textarea - `<textarea matInput>`
    - Preferences checkboxes (required, at least one) - `<mat-checkbox>`
  - Add Save and Cancel buttons matching Figma action buttons
  - Add error message display areas for each field
  - Apply Angular Material styling matching Figma design system
  - Implement responsive layout: 2-column grid on desktop, single column on mobile/tablet
  - Extract exact colors, spacing, typography from Figma Inspect
  
- [ ] 13.2 Implement profile loading logic
  - **Requirement Type**: UI (UI/UX Requirement) + DR (Data Requirement) + BR (Business Rule)
  - **Requirements**: Req 8 (View Profile), Req 9 (Display Fields), Req 18 (Read Only Email)
  - Call ProfileService.getProfile on component init (ngOnInit)
  - Populate form with retrieved profile data
  - Store original profile data in originalProfile property for cancel functionality
  - Call ProfileService.checkEmailPolicy to determine if email is read-only
  - Set email field read-only if policy restricts modification (add lock icon)
  - Show loading indicator while fetching data
  
- [ ] 13.3 Implement form validation logic
  - **Requirement Type**: VR (Validation Requirement) + BR (Business Rule)
  - **Requirements**: Req 10 (Mandatory Fields), Req 12 (Gender), Req 13 (Age), Req 14 (Email), Req 15 (Preferences)
  - Add reactive form with FormBuilder and validators
  - Validate mandatory fields: firstName, lastName, email, gender (Validators.required)
  - Validate gender selection: display "Gender selection is mandatory" if blank
  - Validate email format using ValidationService
  - Validate age range 18-120 using ValidationService
  - Validate at least one preference selected using custom validator
  - Display inline error messages below each field matching Figma error states
  - Clear error messages when user corrects input
  - Disable save button when form is invalid
  
- [ ] 13.4 Implement save functionality
  - **Requirement Type**: FR (Functional Requirement) + DR (Data Requirement)
  - **Requirements**: Req 16 (Save Profile)
  - Call ProfileService.updateProfile on save button click
  - Handle successful save: display "Profile updated successfully" toast notification (green, top-right)
  - Handle validation errors: display field-specific error messages
  - Show loading indicator during API call (spinner in button)
  - Disable form during submission to prevent double-submit
  - Update originalProfile with saved data after successful save
  
- [ ] 13.5 Implement cancel functionality
  - **Requirement Type**: FR (Functional Requirement)
  - **Requirements**: Req 17 (Cancel Changes)
  - Revert form to originalProfile data on cancel button click
  - Clear any error messages
  - Reset form validation state
  - No API call needed (client-side only)
  
- [ ]* 13.6 Write property test for cancel discards changes
  - **Requirement Type**: FR (Functional Requirement)
  - **Property 11**: Cancel discards changes
  - **Validates**: Req 17 (Cancel Changes)
  - Test with randomly generated profile modifications
  - Verify cancel button reverts all fields to original values
  - Minimum 100 iterations
  
- [ ]* 13.7 Write unit tests for ProfileComponent
  - **Requirement Type**: UI (UI/UX Requirement) + VR (Validation Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 8-18 (all profile requirements)
  - Test profile loading and form population
  - Test form validation for all fields
  - Test save functionality (success and error cases)
  - Test cancel functionality (revert to original data)
  - Test email read-only based on policy
  - Test mandatory field validation
  - Test age range validation
  - Test preferences validation (at least one selected)
  - Use Jasmine and Karma with TestBed

---

### Task 14: Configure routing and navigation
**Phase**: 2 - Core Authentication  
**Requirement Types**: UI (UI/UX Requirement), FR (Functional Requirement), SR (Security Requirement)  
**Team**: @team:frontend @component:frontend-routing  
**Requirements**: Req 1 (UI), Req 2 (FR), Req 8 (UI)

**Description**: Set up Angular routing with authentication guards and navigation components.

**Sub-tasks**:
- [ ] 14.1 Set up Angular routing
  - **Requirement Type**: UI (UI/UX Requirement) + SR (Security Requirement)
  - **Requirements**: Req 1 (Login Page Access), Req 2 (Successful Login), Req 8 (View Profile Page)
  - Define routes for login page (/login) and profile page (/profile)
  - Implement AuthGuard route guard for authenticated routes
  - Configure redirect to /login for unauthenticated users
  - Configure redirect to /profile after successful login
  - Set up lazy loading for feature modules
  
- [ ] 14.2 Create navigation component
  - **Requirement Type**: UI (UI/UX Requirement) + FR (Functional Requirement)
  - **Requirements**: Req 2 (Successful Login - logout flow)
  - Add navigation bar with Angular Material toolbar
  - Show navigation only for authenticated users (use *ngIf with AuthService.isAuthenticated())
  - Add logout button that calls AuthService.logout()
  - Redirect to /login after logout
  - Match Figma navigation design
  
- [ ]* 14.3 Write unit tests for routing and guards
  - **Requirement Type**: UI (UI/UX Requirement) + SR (Security Requirement)
  - **Requirements**: Req 1, Req 2, Req 8
  - Test AuthGuard redirects unauthenticated users to /login
  - Test AuthGuard allows authenticated users to access /profile
  - Test navigation component shows/hides based on authentication state
  - Test logout functionality
  - Use Jasmine and Karma with RouterTestingModule

---

### Task 15: Create deployment pipeline
**Phase**: 5 - Testing & Deployment  
**Requirement Types**: PR (Performance Requirement)  
**Team**: @team:devops @component:devops-cicd  
**Requirements**: All requirements (deployment and monitoring)

**Description**: Set up CI/CD pipeline for automated build, test, and deployment.

**Sub-tasks**:
- [ ] 15.1 Configure build pipeline
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All requirements (deployment)
  - Set up GitHub Actions or Jenkins pipeline
  - Configure Java build with Maven (per Java conventions)
  - Configure Angular build with npm
  - Run unit tests and property tests
  - Generate code coverage reports (target 70% minimum)
  - Run SonarQube analysis for code quality
  - Fail build if coverage < 70% or quality gate fails
  
- [ ] 15.2 Configure Lambda deployment
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All backend requirements
  - Package Lambda functions with dependencies using Maven
  - Deploy Lambda functions to AWS using AWS CDK
  - Update Lambda environment variables (DB_SECRET_ARN, JWT_SECRET_ARN, etc.)
  - Deploy Lambda layer with shared utilities
  - Run smoke tests after deployment
  
- [ ] 15.3 Configure frontend deployment
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All frontend requirements
  - Build Angular application for production (ng build --prod)
  - Deploy to S3 bucket with static website hosting
  - Configure CloudFront distribution for CDN
  - Configure environment-specific API Gateway URLs
  - Invalidate CloudFront cache after deployment
  
- [ ] 15.4 Set up monitoring and alerts
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All requirements (monitoring)
  - Configure CloudWatch alarms for Lambda errors (threshold: > 5 errors in 5 minutes)
  - Set up API Gateway monitoring (4xx, 5xx errors, latency)
  - Configure RDS performance monitoring (CPU, connections, slow queries)
  - Create CloudWatch dashboard for system health
  - Set up SNS notifications for critical alerts
  - Configure log retention policies (30 days)

---

### Task 16: Integration testing and validation
**Phase**: 5 - Testing & Deployment  
**Requirement Types**: All requirement types  
**Team**: @team:qa @component:qa-testing  
**Requirements**: All requirements

**Description**: Perform comprehensive integration and end-to-end testing to validate the entire system.

**Sub-tasks**:
- [ ]* 16.1 Write end-to-end tests for authentication flow
  - **Requirement Type**: FR (Functional Requirement) + SR (Security Requirement) + VR (Validation Requirement)
  - **Requirements**: Req 1 (Login Page), Req 2 (Successful Login), Req 3 (Invalid Credentials), Req 4 (Mandatory Fields), Req 7 (Account Locking)
  - Test complete login flow from UI to database
  - Test successful login with valid credentials (redirect to home)
  - Test invalid credentials display error message
  - Test login button disabled when fields are empty
  - Test account locking after 5 failed attempts
  - Test account unlocks after 30 minutes
  - Test logout functionality
  - Use Cypress or Protractor for E2E tests
  
- [ ]* 16.2 Write end-to-end tests for profile management
  - **Requirement Type**: UI (UI/UX Requirement) + VR (Validation Requirement) + FR (Functional Requirement) + BR (Business Rule)
  - **Requirements**: Req 8-18 (all profile requirements)
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
  
- [ ]* 16.3 Perform security testing
  - **Requirement Type**: SR (Security Requirement)
  - **Requirements**: All security requirements
  - Test JWT token validation (expired token, invalid signature, missing token)
  - Test SQL injection prevention (parameterized queries)
  - Test XSS prevention (Angular sanitization)
  - Test CSRF protection (CSRF tokens)
  - Verify HTTPS enforcement for all API calls
  - Verify secure token storage (localStorage with HttpOnly cookies recommended)
  - Test password hashing (BCrypt, never plain text)
  - Test account locking mechanism (5 failures, 30 minutes)
  - Test API Gateway rate limiting (10 req/s for login)
  - Use OWASP ZAP or Burp Suite for security scanning
  
- [ ]* 16.4 Perform performance testing
  - **Requirement Type**: PR (Performance Requirement)
  - **Requirements**: All requirements (performance)
  - Test Lambda cold start times (target: < 3 seconds)
  - Test API Gateway throughput (concurrent requests)
  - Test database query performance (target: < 100ms p95)
  - Test concurrent user load (100+ concurrent users)
  - Test API response times (target: < 500ms p95)
  - Test frontend page load times (target: < 2 seconds)
  - Use Artillery or Gatling for load testing
  - Monitor CloudWatch metrics during tests

---

### Task 17: Final checkpoint - Production readiness validation
**Phase**: 5 - Testing & Deployment  
**Requirement Types**: All requirement types  
**Team**: @team:backend @team:frontend @team:devops @team:qa  
**Requirements**: All requirements

**Description**: Final validation that the system is ready for production deployment.

**Validation Checklist**:
- [ ] Run all unit tests and property tests (100% pass rate required)
- [ ] Run all integration tests and E2E tests (100% pass rate required)
- [ ] Verify code coverage meets 70% minimum (per Java conventions)
- [ ] Review CloudWatch logs for any errors or warnings
- [ ] Perform manual testing of critical flows (login, profile management)
- [ ] Verify all 18 requirements are implemented and tested
- [ ] Verify all 11 correctness properties are validated
- [ ] Verify Figma designs match implementation (pixel-perfect)
- [ ] Verify responsive layouts work on Mobile, Tablet, Desktop
- [ ] Verify WCAG AA accessibility compliance
- [ ] Verify security best practices are followed
- [ ] Verify performance targets are met (Lambda < 3s, API < 500ms, page load < 2s)
- [ ] Verify monitoring and alerts are configured
- [ ] Verify deployment pipeline works end-to-end
- [ ] Ensure all tests pass, ask the user if questions arise before production deployment

---

## Requirement Type to Task Mapping

This section provides a comprehensive mapping of requirement types to the tasks that implement them.

### Functional Requirements (FR) - Core business functionality

| Requirement | Description | Implementing Tasks |
|-------------|-------------|-------------------|
| Req 2 | Successful Login | Task 3.3 (JWT utility), Task 4.1 (UserRepository), Task 5 (AuthLoginHandler), Task 8.1 (AuthLogoutHandler), Task 9.2-9.3 (API Gateway), Task 11.3 (AuthService), Task 12 (LoginComponent), Task 14 (Routing) |
| Req 3 | Invalid Credentials | Task 3.8 (Exceptions), Task 4.1 (UserRepository), Task 5 (AuthLoginHandler), Task 9.2 (API Gateway), Task 11.3 (AuthService), Task 12 (LoginComponent) |
| Req 16 | Save Profile | Task 4.1 (UserRepository), Task 7 (UpdateProfileHandler), Task 9.4 (API Gateway), Task 11.4 (ProfileService), Task 13 (ProfileComponent) |
| Req 17 | Cancel Changes | Task 13.5 (ProfileComponent cancel functionality) |

### UI/UX Requirements (UI) - User interface and experience

| Requirement | Description | Implementing Tasks | Figma Reference |
|-------------|-------------|-------------------|-----------------|
| Req 1 | Login Page Access | Task 12.1 (LoginComponent structure), Task 14.1 (Routing) | Login Page - Desktop/Mobile/Tablet |
| Req 8 | View Profile Page | Task 6 (GetProfileHandler), Task 13.1-13.2 (ProfileComponent), Task 14.1 (Routing) | Profile Management Page |
| Req 9 | Display Profile Fields | Task 2.1-2.2 (Database schema), Task 6 (GetProfileHandler), Task 13.1 (ProfileComponent) | Profile - Form Fields |
| Req 11 | Title Field Behavior | Task 2.1 (Database), Task 13.1 (ProfileComponent) | Profile - Title dropdown |
| Req 12 | Gender Field Validation | Task 2.1 (Database), Task 7.2 (Validation), Task 13.1-13.3 (ProfileComponent) | Profile - Gender radio buttons |
| Req 15 | Preferences Selection | Task 2.2 (Database), Task 7.2 (Validation), Task 13.1-13.3 (ProfileComponent) | Profile - Preferences checkboxes |
| Req 18 | Read Only Email Rule | Task 8.2 (GetEmailPolicyHandler), Task 9.5 (API Gateway), Task 11.4 (ProfileService), Task 13.2 (ProfileComponent) | Profile - Email read-only state |

### Validation Requirements (VR) - Input validation and data integrity

| Requirement | Description | Implementing Tasks | Property Tests |
|-------------|-------------|-------------------|----------------|
| Req 4 | Mandatory Fields Validation | Task 3.4 (Validators), Task 11.2 (ValidationService), Task 12.2 (LoginComponent) | Task 12.4 (Property 3) |
| Req 5 | Password Format Validation | Task 3.2 (BCrypt), Task 3.4 (Validators), Task 11.2 (ValidationService), Task 12.2 (LoginComponent) | Task 3.6 (Property 4) |
| Req 6 | Email Format Validation | Task 3.4 (Validators), Task 11.2 (ValidationService), Task 12.2 (LoginComponent) | Task 3.5 (Property 5) |
| Req 10 | Mandatory Profile Fields | Task 3.4 (Validators), Task 7.2 (UpdateProfileHandler), Task 13.3 (ProfileComponent) | Task 7.4 (Property 7) |
| Req 12 | Gender Field Validation | Task 7.2 (UpdateProfileHandler), Task 13.3 (ProfileComponent) | Task 7.4 (Property 7) |
| Req 13 | Age Validation | Task 3.4 (Validators), Task 7.2 (UpdateProfileHandler), Task 13.3 (ProfileComponent) | Task 3.7 (Property 8) |
| Req 14 | Email Validation in Profile | Task 3.4 (Validators), Task 7.2 (UpdateProfileHandler), Task 13.3 (ProfileComponent) | Task 3.5 (Property 5) |
| Req 15 | Preferences Selection | Task 3.4 (Validators), Task 7.2 (UpdateProfileHandler), Task 13.3 (ProfileComponent) | Task 7.5 (Property 9) |

### Security Requirements (SR) - Authentication and security controls

| Requirement | Description | Implementing Tasks | Security Measures |
|-------------|-------------|-------------------|-------------------|
| Req 5 | Password Format Validation | Task 3.2 (BCrypt hashing), Task 5.2 (AuthLoginHandler) | BCrypt with salt rounds = 10, never store plain text |
| Req 7 | Account Locking | Task 2.3 (login_attempts table), Task 4.2 (LoginAttemptRepository), Task 5.3 (AuthLoginHandler) | Lock after 5 failures for 30 minutes |

**Additional Security Measures**:
- JWT token authentication (Task 3.3, 9.6)
- API Gateway rate limiting (Task 9.2: 10 req/s for login)
- HTTPS enforcement (Task 9.1)
- SQL injection prevention with parameterized queries (Task 4.1, 4.2)
- XSS prevention with Angular sanitization (Task 11.1)
- CSRF protection (Task 9.1)
- Secrets Manager for credentials (Task 1.4, 3.1)
- CloudWatch logging for security events (Task 1.6, 5.3)

### Data Requirements (DR) - Data storage and management

| Requirement | Description | Implementing Tasks | Database Tables |
|-------------|-------------|-------------------|-----------------|
| Req 9 | Display Profile Fields | Task 2.1-2.2 (Database schema), Task 6 (GetProfileHandler) | users, user_preferences |
| Req 16 | Save Profile | Task 2.1-2.2 (Database schema), Task 7.3 (UpdateProfileHandler) | users, user_preferences |

**Database Schema**:
- users table: id, title, first_name, last_name, gender, age, email, password_hash, address, account_locked, locked_until, created_at, updated_at
- user_preferences table: user_id, preference
- login_attempts table: id, email, timestamp, successful, ip_address

### Business Rules (BR) - Business logic and policies

| Requirement | Description | Implementing Tasks | Configuration |
|-------------|-------------|-------------------|---------------|
| Req 10 | Mandatory Profile Fields | Task 7.2 (UpdateProfileHandler validation) | Hard-coded validation rules |
| Req 13 | Age Validation | Task 7.2 (UpdateProfileHandler validation) | Age range: 18-120 |
| Req 18 | Read Only Email Rule | Task 8.2 (GetEmailPolicyHandler) | Environment variable: EMAIL_MODIFICATION_ALLOWED |

### Performance Requirements (PR) - System performance

| Requirement | Description | Implementing Tasks | Performance Targets |
|-------------|-------------|-------------------|---------------------|
| Infrastructure | Scalability and performance | Task 1 (AWS infrastructure), Task 9 (API Gateway), Task 15 (Deployment) | Lambda cold start < 3s, API response < 500ms p95, Page load < 2s |

---

## Property-Based Tests Mapping

All property-based tests validate universal correctness properties across randomly generated inputs (minimum 100 iterations each).

| Property | Description | Validates Requirements | Implementing Task |
|----------|-------------|----------------------|-------------------|
| Property 1 | Valid credentials authenticate successfully | Req 2 (Successful Login) | Task 5.5 |
| Property 2 | Invalid credentials return error message | Req 3 (Invalid Credentials) | Task 5.6 |
| Property 3 | Login button disabled state | Req 4 (Mandatory Fields) | Task 12.4 |
| Property 4 | Password complexity validation | Req 5 (Password Format) | Task 3.6 |
| Property 5 | Email format validation | Req 6, 14 (Email Format) | Task 3.5 |
| Property 6 | Account locking after failed attempts | Req 7 (Account Locking) | Task 5.7 |
| Property 7 | Mandatory profile fields validation | Req 10, 12 (Mandatory Fields, Gender) | Task 7.4 |
| Property 8 | Age range validation | Req 13 (Age Validation) | Task 3.7 |
| Property 9 | Preferences selection validation | Req 15 (Preferences) | Task 7.5 |
| Property 10 | Profile save round-trip with success message | Req 16 (Save Profile) | Task 7.6 |
| Property 11 | Cancel discards changes | Req 17 (Cancel Changes) | Task 13.6 |

---

## Task Dependencies and Execution Order

### Phase 1: Infrastructure & Security (Week 1)
**Critical Path**: Task 1 → Task 2 → Task 3 → Task 4

1. Task 1: AWS infrastructure (no dependencies)
2. Task 2: Database schema (depends on Task 1)
3. Task 3: Lambda utilities (depends on Task 1, 2)
4. Task 4: Repository classes (depends on Task 2, 3)

### Phase 2: Core Authentication (Week 2)
**Critical Path**: Task 5 → Task 9 → Task 10 → Task 11 → Task 12 → Task 14

5. Task 5: AuthLoginHandler (depends on Task 3, 4)
6. Task 9: API Gateway (depends on Task 5, 8)
7. Task 10: Backend checkpoint (depends on Task 5, 9)
8. Task 11: Angular services (depends on Task 10)
9. Task 12: LoginComponent (depends on Task 11)
10. Task 14: Routing (depends on Task 12)

### Phase 3: Validation Layer (Week 3)
**Parallel Execution**: Task 3.4-3.7 (validation utilities and property tests)

- Can be executed in parallel with Phase 2 tasks
- Property tests validate validation logic

### Phase 4: Profile Management (Week 4)
**Critical Path**: Task 6 → Task 7 → Task 8 → Task 13

11. Task 6: GetProfileHandler (depends on Task 4)
12. Task 7: UpdateProfileHandler (depends on Task 3, 4)
13. Task 8: Supporting functions (depends on Task 3)
14. Task 13: ProfileComponent (depends on Task 6, 7, 8, 11)

### Phase 5: Testing & Deployment (Week 5)
**Critical Path**: Task 15 → Task 16 → Task 17

15. Task 15: Deployment pipeline (depends on all implementation tasks)
16. Task 16: Integration testing (depends on Task 15)
17. Task 17: Final checkpoint (depends on Task 16)

---

## Notes

- **Optional Tasks**: Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- **Test Coverage**: Target 70% minimum code coverage (per Java conventions)
- **Property Tests**: Minimum 100 iterations per property test
- **Figma Compliance**: All UI components must match Figma designs pixel-perfect
- **Security**: Follow OWASP security best practices
- **Logging**: Use SLF4J for all backend logging (per Java conventions)
- **REST Standards**: Follow proper HTTP status codes and versioning
- **REXX Modernization**: Part of REXX to Java & Angular modernization initiative

---

## Success Criteria

### Functional Completeness
- [ ] All 18 requirements implemented and tested
- [ ] All 11 correctness properties validated with property-based tests
- [ ] All functional flows work end-to-end (login, profile management)

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
- [ ] WCAG AA accessibility compliance verified

### Security Compliance
- [ ] Password hashing with BCrypt implemented
- [ ] Account locking after 5 failed attempts working
- [ ] JWT token authentication working
- [ ] API Gateway rate limiting configured (10 req/s for login)
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
- [ ] System handles 100+ concurrent users

### Deployment Readiness
- [ ] Infrastructure as Code (AWS CDK) complete
- [ ] CI/CD pipeline configured and working
- [ ] Environment variables configured
- [ ] Monitoring and alerts set up (CloudWatch)
- [ ] Documentation complete (README, API docs, deployment guide)
- [ ] Production deployment successful
