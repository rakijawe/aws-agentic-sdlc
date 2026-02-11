# Implementation Plan: User Authentication and Profile Management

## Overview

This implementation plan breaks down the user authentication and profile management system into discrete, actionable tasks. The system uses AWS Lambda functions with Java 17, API Gateway for REST endpoints, RDS PostgreSQL for data persistence, and Angular 16+ for the frontend.

The implementation follows a layered approach:
1. Infrastructure setup (AWS resources)
2. Database schema and utilities
3. Backend Lambda functions (authentication and profile management)
4. Frontend components (login and profile pages)
5. Integration and testing

## Tasks

<!-- @team:devops @component:devops-infra @priority:high -->
- [ ] 1. Set up AWS infrastructure using CDK
  - Create CDK project structure for infrastructure as code
  - Define RDS PostgreSQL instance with appropriate security groups
  - Configure RDS Proxy for connection pooling
  - Set up Secrets Manager for database credentials and JWT secret
  - Create API Gateway REST API with CORS configuration
  - Configure CloudWatch Log Groups for Lambda functions
  - _Requirements: All requirements (infrastructure foundation)_

<!-- @team:backend @component:backend-data @priority:high -->
- [ ] 2. Create database schema and migration scripts
  - [ ] 2.1 Create users table with all required fields
    - Define table structure with proper constraints
    - Add indexes for email and account_locked fields
    - _Requirements: 5.2, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [ ] 2.2 Create user_preferences table
    - Define foreign key relationship to users table
    - Add index on user_id
    - _Requirements: 6.3_
  
  - [ ] 2.3 Create login_attempts table
    - Define table for tracking authentication attempts
    - Add indexes for email and timestamp queries
    - _Requirements: 4.1, 4.2, 4.3_
  
  - [ ] 2.4 Create database migration scripts
    - Write SQL scripts for schema creation
    - Add rollback scripts for each migration
    - _Requirements: All data model requirements_

<!-- @team:backend @component:backend-service @priority:high -->
- [ ] 3. Implement shared Lambda layer utilities
  - [ ] 3.1 Create database connection utility
    - Implement Secrets Manager client for credential retrieval
    - Create JDBC connection factory with RDS Proxy support
    - Add connection pooling and timeout configuration
    - _Requirements: All backend requirements_
  
  - [ ] 3.2 Implement password hashing utility
    - Use BCrypt for password hashing
    - Implement hash generation and verification methods
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 3.3 Create JWT token utility
    - Implement JWT token generation with configurable expiry
    - Add token validation and parsing methods
    - Retrieve JWT secret from Secrets Manager
    - _Requirements: 1.2_
  
  - [ ] 3.4 Implement validation utility classes
    - Create email format validator
    - Create password complexity validator
    - Create age range validator
    - Create mandatory field validator
    - _Requirements: 2.1-2.5, 3.1-3.3, 7.1-7.5, 8.1-8.3, 9.1-9.3_
  
  - [ ] 3.5 Write property test for email validation
    - **Property 4: Email format validation**
    - **Validates: Requirements 3.1, 3.2, 3.3, 9.1, 9.2, 9.3**
  
  - [ ] 3.6 Write property test for password complexity validation
    - **Property 3: Password complexity validation**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**
  
  - [ ] 3.7 Write property test for age range validation
    - **Property 7: Age range validation**
    - **Validates: Requirements 8.1, 8.2, 8.3**
  
  - [ ] 3.8 Create exception classes
    - Define InvalidCredentialsException
    - Define AccountLockedException
    - Define ValidationException
    - Define ProfileNotFoundException
    - _Requirements: 1.3, 4.2, 7.1-7.5_
  
  - [ ] 3.9 Implement Lambda exception handler
    - Create centralized exception handling utility
    - Map exceptions to appropriate HTTP status codes
    - Format error responses consistently
    - _Requirements: All error handling requirements_

<!-- @team:backend @component:backend-data -->
- [ ] 4. Implement repository classes
  - [ ] 4.1 Create UserRepository class
    - Implement findByEmail method with JDBC
    - Implement save method for insert/update operations
    - Implement findById method
    - _Requirements: 1.2, 1.3, 5.1, 10.1_
  
  - [ ] 4.2 Create LoginAttemptRepository class
    - Implement findRecentAttempts method
    - Implement save method for recording attempts
    - Implement deleteOldAttempts cleanup method
    - _Requirements: 4.1, 4.2, 4.3_
  
  - [ ] 4.3 Write unit tests for repository classes
    - Test CRUD operations with H2 in-memory database
    - Test query methods with various inputs
    - Test error handling for database failures
    - _Requirements: 1.2, 1.3, 4.1, 4.2, 4.3, 10.1_

<!-- @team:backend @component:backend-api @priority:high -->
- [ ] 5. Implement AuthLoginHandler Lambda function
  - [ ] 5.1 Create Lambda handler class and request parsing
    - Parse APIGatewayProxyRequestEvent
    - Extract email and password from request body
    - Set up CloudWatch logging
    - _Requirements: 1.2, 1.3_
  
  - [ ] 5.2 Implement authentication logic
    - Query user by email from database
    - Check if account is locked
    - Verify password using BCrypt
    - Generate JWT token on success
    - _Requirements: 1.2, 4.2_
  
  - [ ] 5.3 Implement failed attempt tracking
    - Record failed login attempts
    - Count recent failed attempts (last 30 minutes)
    - Lock account after 5 consecutive failures
    - _Requirements: 4.1, 4.2_
  
  - [ ] 5.4 Format response with proper status codes
    - Return 200 with token on success
    - Return 401 for invalid credentials
    - Return 403 for locked accounts
    - _Requirements: 1.2, 1.3, 4.2_
  
  - [ ] 5.5 Write unit test for successful login
    - Test valid credentials return JWT token
    - Verify response format and status code
    - _Requirements: 1.2_
  
  - [ ] 5.6 Write property test for invalid credentials
    - **Property 1: Invalid credentials return error message**
    - **Validates: Requirements 1.3**
  
  - [ ] 5.7 Write unit test for account locking
    - Test account locks after 5 failed attempts
    - Verify locked account prevents login
    - _Requirements: 4.1, 4.2_

<!-- @team:backend @component:backend-api -->
- [ ] 6. Implement GetProfileHandler Lambda function
  - [ ] 6.1 Create Lambda handler class
    - Parse APIGatewayProxyRequestEvent
    - Extract user ID from JWT token (validated by API Gateway)
    - Set up CloudWatch logging
    - _Requirements: 5.1, 5.2_
  
  - [ ] 6.2 Implement profile retrieval logic
    - Query user profile from database by user ID
    - Handle profile not found scenario
    - Format profile data as JSON response
    - _Requirements: 5.1, 5.2_
  
  - [ ] 6.3 Write unit tests for profile retrieval
    - Test successful profile fetch
    - Test profile not found error
    - _Requirements: 5.1, 5.2_

<!-- @team:backend @component:backend-api @priority:high -->
- [ ] 7. Implement UpdateProfileHandler Lambda function
  - [ ] 7.1 Create Lambda handler class and request parsing
    - Parse APIGatewayProxyRequestEvent
    - Extract user ID from JWT token
    - Parse ProfileUpdateRequest from body
    - _Requirements: 10.1, 10.2_
  
  - [ ] 7.2 Implement profile validation logic
    - Validate all mandatory fields (firstName, lastName, email, gender, preferences)
    - Validate email format
    - Validate age range (18-120)
    - Check email modification policy
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 9.1, 9.2, 9.3, 11.1, 11.2_
  
  - [ ] 7.3 Implement profile update logic
    - Update user record in database
    - Update preferences in user_preferences table
    - Return success response with updated profile
    - _Requirements: 10.1, 10.2_
  
  - [ ] 7.4 Write property test for mandatory fields validation
    - **Property 6: Mandatory profile fields validation**
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**
  
  - [ ] 7.5 Write property test for profile save round-trip
    - **Property 8: Profile save round-trip**
    - **Validates: Requirements 10.1**
  
  - [ ] 7.6 Write unit tests for profile update
    - Test successful profile update
    - Test validation errors for invalid data
    - Test email policy enforcement
    - _Requirements: 7.1-7.5, 8.1-8.3, 9.1-9.3, 10.1, 10.2, 11.1, 11.2_

<!-- @team:backend @component:backend-api -->
- [ ] 8. Implement supporting Lambda functions
  - [ ] 8.1 Create AuthLogoutHandler Lambda function
    - Parse request and extract JWT token
    - Implement token blacklist logic (optional)
    - Return success response
    - _Requirements: 1.2_
  
  - [ ] 8.2 Create GetEmailPolicyHandler Lambda function
    - Read EMAIL_MODIFICATION_ALLOWED environment variable
    - Return policy configuration as JSON
    - _Requirements: 11.1, 11.2_
  
  - [ ] 8.3 Write unit tests for supporting functions
    - Test logout handler
    - Test email policy handler
    - _Requirements: 1.2, 11.1, 11.2_

<!-- @team:devops @component:devops-infra -->
- [ ] 9. Configure API Gateway endpoints and integrations
  - [ ] 9.1 Create API Gateway REST API resource
    - Define API name and description
    - Configure CORS settings
    - _Requirements: All API requirements_
  
  - [ ] 9.2 Create /auth/login endpoint
    - Configure POST method
    - Integrate with AuthLoginHandler Lambda
    - Set throttling to 10 requests/second per IP
    - No authorization required (public endpoint)
    - _Requirements: 1.2, 1.3_
  
  - [ ] 9.3 Create /auth/logout endpoint
    - Configure POST method
    - Integrate with AuthLogoutHandler Lambda
    - Add JWT authorizer
    - _Requirements: 1.2_
  
  - [ ] 9.4 Create /profile endpoints
    - Configure GET method for profile retrieval
    - Configure PUT method for profile update
    - Integrate with respective Lambda functions
    - Add JWT authorizer to both methods
    - _Requirements: 5.1, 5.2, 10.1, 10.2_
  
  - [ ] 9.5 Create /profile/email-policy endpoint
    - Configure GET method
    - Integrate with GetEmailPolicyHandler Lambda
    - Add JWT authorizer
    - _Requirements: 11.1, 11.2_
  
  - [ ] 9.6 Create JWT authorizer for API Gateway
    - Configure custom authorizer Lambda (or use Cognito)
    - Validate JWT tokens
    - Extract user ID from token claims
    - _Requirements: All authenticated endpoints_

- [ ] 10. Checkpoint - Ensure backend Lambda functions and API Gateway are working
  - Test each Lambda function independently
  - Test API Gateway endpoints with Postman or curl
  - Verify database connections and queries
  - Check CloudWatch logs for errors
  - Ensure all tests pass, ask the user if questions arise.

<!-- @team:frontend @component:frontend-ui @priority:high -->
- [ ] 11. Create Angular project structure and shared services
  - [ ] 11.1 Set up Angular project with Angular Material
    - Initialize Angular 16+ project
    - Install Angular Material and configure theme
    - Set up routing module
    - _Requirements: All frontend requirements_
  
  - [ ] 11.2 Create ValidationService
    - Implement validateEmail method
    - Implement validatePassword method
    - Implement validateAge method
    - Implement validateMandatoryField method
    - _Requirements: 2.1-2.5, 3.1-3.3, 7.1-7.5, 8.1-8.3_
  
  - [ ] 11.3 Create AuthService
    - Implement login method with HTTP client
    - Implement logout method
    - Implement token storage (localStorage)
    - Implement isAuthenticated method
    - _Requirements: 1.2, 1.3_
  
  - [ ] 11.4 Create ProfileService
    - Implement getProfile method
    - Implement updateProfile method
    - Implement checkEmailPolicy method
    - _Requirements: 5.1, 5.2, 10.1, 10.2, 11.1, 11.2_
  
  - [ ] 11.5 Write unit tests for services
    - Test ValidationService methods
    - Test AuthService with mocked HTTP client
    - Test ProfileService with mocked HTTP client
    - _Requirements: All validation and service requirements_

<!-- @team:frontend @component:frontend-ui @priority:high -->
- [ ] 12. Implement LoginComponent
  - [ ] 12.1 Create component structure and template
    - Create login form with email and password fields
    - Add login button
    - Add error message display area
    - Apply Angular Material styling
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  
  - [ ] 12.2 Implement form validation logic
    - Add reactive form with validators
    - Implement real-time email format validation
    - Implement real-time password complexity validation
    - Disable login button when fields are empty
    - _Requirements: 1.4, 2.1-2.5, 3.1-3.3_
  
  - [ ] 12.3 Implement login submission logic
    - Call AuthService.login on form submit
    - Handle successful login (store token, redirect to home)
    - Handle authentication errors (display error message)
    - Handle account locked errors (display locked message)
    - Show loading indicator during API call
    - _Requirements: 1.2, 1.3, 4.2_
  
  - [ ] 12.4 Write property test for login button disabled state
    - **Property 2: Login button disabled state**
    - **Validates: Requirements 1.4**
  
  - [ ] 12.5 Write unit tests for LoginComponent
    - Test form validation
    - Test button disabled state
    - Test successful login flow
    - Test error handling
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1-2.5, 3.1-3.3_

<!-- @team:frontend @component:frontend-ui @priority:high -->
- [ ] 13. Implement ProfileComponent
  - [ ] 13.1 Create component structure and template
    - Create profile form with all fields (Title, First Name, Last Name, Gender, Age, Email, Address, Preferences)
    - Add Save and Cancel buttons
    - Add error message display areas
    - Apply Angular Material styling
    - _Requirements: 5.1, 5.2, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [ ] 13.2 Implement profile loading logic
    - Call ProfileService.getProfile on component init
    - Populate form with retrieved profile data
    - Store original profile data for cancel functionality
    - Check email policy and set email field read-only if needed
    - _Requirements: 5.1, 5.2, 11.1, 11.2_
  
  - [ ] 13.3 Implement form validation logic
    - Add reactive form with validators for all fields
    - Validate mandatory fields (firstName, lastName, email, gender, preferences)
    - Validate email format
    - Validate age range (18-120)
    - Display inline error messages
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 9.1, 9.2, 9.3_
  
  - [ ] 13.4 Implement save functionality
    - Call ProfileService.updateProfile on save button click
    - Handle successful save (display success message)
    - Handle validation errors (display field-specific errors)
    - Show loading indicator during API call
    - _Requirements: 10.1, 10.2_
  
  - [ ] 13.5 Implement cancel functionality
    - Revert form to original profile data on cancel button click
    - Clear any error messages
    - _Requirements: 10.3, 10.4_
  
  - [ ] 13.6 Write property test for cancel discards changes
    - **Property 10: Cancel discards changes**
    - **Validates: Requirements 10.3, 10.4**
  
  - [ ] 13.7 Write unit tests for ProfileComponent
    - Test profile loading
    - Test form validation
    - Test save functionality
    - Test cancel functionality
    - Test email read-only based on policy
    - _Requirements: 5.1, 5.2, 6.1-6.6, 7.1-7.5, 8.1-8.3, 9.1-9.3, 10.1-10.4, 11.1, 11.2_

<!-- @team:frontend @component:frontend-routing -->
- [ ] 14. Configure routing and navigation
  - [ ] 14.1 Set up Angular routing
    - Define routes for login and profile pages
    - Implement route guards for authenticated routes
    - Configure redirect to login for unauthenticated users
    - _Requirements: 1.1, 1.2, 5.1_
  
  - [ ] 14.2 Create navigation component
    - Add navigation bar with logout button
    - Show navigation only for authenticated users
    - Implement logout functionality
    - _Requirements: 1.2_
  
  - [ ] 14.3 Write unit tests for routing and guards
    - Test route guard redirects unauthenticated users
    - Test navigation component
    - _Requirements: 1.1, 1.2, 5.1_

<!-- @team:devops @component:devops-cicd -->
- [ ] 15. Create deployment pipeline
  - [ ] 15.1 Configure build pipeline
    - Set up GitHub Actions or Jenkins pipeline
    - Configure Java build with Maven/Gradle
    - Configure Angular build
    - Run unit tests and property tests
    - Generate code coverage reports
    - _Requirements: All requirements (deployment)_
  
  - [ ] 15.2 Configure Lambda deployment
    - Package Lambda functions with dependencies
    - Deploy Lambda functions to AWS
    - Update Lambda environment variables
    - Deploy Lambda layer with shared utilities
    - _Requirements: All backend requirements_
  
  - [ ] 15.3 Configure frontend deployment
    - Build Angular application for production
    - Deploy to S3 or CloudFront
    - Configure environment-specific API Gateway URLs
    - _Requirements: All frontend requirements_
  
  - [ ] 15.4 Set up monitoring and alerts
    - Configure CloudWatch alarms for Lambda errors
    - Set up API Gateway monitoring
    - Configure RDS performance monitoring
    - Create dashboard for system health
    - _Requirements: All requirements (monitoring)_

<!-- @team:qa @component:qa-testing -->
- [ ] 16. Integration testing and validation
  - [ ] 16.1 Write end-to-end tests for authentication flow
    - Test complete login flow from UI to database
    - Test account locking after failed attempts
    - Test logout functionality
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 4.1, 4.2, 4.3_
  
  - [ ] 16.2 Write end-to-end tests for profile management
    - Test profile retrieval and display
    - Test profile update with valid data
    - Test validation errors for invalid data
    - Test cancel functionality
    - Test email policy enforcement
    - _Requirements: 5.1, 5.2, 6.1-6.6, 7.1-7.5, 8.1-8.3, 9.1-9.3, 10.1-10.4, 11.1, 11.2_
  
  - [ ] 16.3 Perform security testing
    - Test JWT token validation
    - Test SQL injection prevention
    - Test XSS prevention
    - Test CSRF protection
    - _Requirements: All security requirements_
  
  - [ ] 16.4 Perform performance testing
    - Test Lambda cold start times
    - Test API Gateway throughput
    - Test database query performance
    - Test concurrent user load
    - _Requirements: All requirements (performance)_

- [ ] 17. Final checkpoint - Ensure all tests pass and system is ready for deployment
  - Run all unit tests and property tests
  - Run all integration tests
  - Verify code coverage meets 70% minimum
  - Review CloudWatch logs for any errors
  - Perform manual testing of critical flows
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- All tasks are required for comprehensive implementation
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties across all inputs
- Unit tests validate specific examples, edge cases, and integration points
- Backend uses Java 17 with AWS Lambda runtime
- Frontend uses Angular 16+ with TypeScript and Angular Material
- Infrastructure uses AWS CDK for Infrastructure as Code
- All Lambda functions log to CloudWatch for monitoring and debugging
