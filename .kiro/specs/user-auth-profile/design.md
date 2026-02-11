# Design Document: User Authentication and Profile Management

## Overview

This design document describes the architecture and implementation approach for a user authentication and profile management system. The system consists of:

1. **Authentication Module**: Handles user login with email/password credentials, validation, and account security
2. **Profile Management Module**: Allows authenticated users to view and update their profile information

The system follows a modern serverless architecture with:
- **Frontend**: Angular 16+ with TypeScript and Angular Material for UI components
- **Backend**: AWS Lambda functions with Java 17 runtime for serverless API logic
- **API Gateway**: AWS API Gateway for REST API endpoints and request routing
- **Database**: Amazon RDS PostgreSQL for data persistence
- **Authentication**: AWS Cognito for JWT token management (optional) or custom JWT implementation

Key design principles:
- Serverless architecture for scalability and cost optimization
- Separation of concerns between presentation, business logic, and data layers
- RESTful API design with proper HTTP status codes via API Gateway
- Client-side and server-side validation for security and user experience
- Secure password handling with bcrypt hashing
- Account protection through rate limiting (API Gateway) and account locking
- Infrastructure as Code using AWS CDK

## Architecture

### System Architecture

```mermaid
graph TB
    subgraph "Frontend - Angular"
        A[Login Component]
        B[Profile Component]
        C[Auth Service]
        D[Profile Service]
        E[Validation Service]
    end
    
    subgraph "AWS Cloud"
        subgraph "API Gateway"
            F[/auth/login]
            G[/auth/logout]
            H[/profile]
            I[/profile/email-policy]
        end
        
        subgraph "Lambda Functions"
            J[AuthLoginHandler]
            K[AuthLogoutHandler]
            L[GetProfileHandler]
            M[UpdateProfileHandler]
            N[GetEmailPolicyHandler]
        end
        
        subgraph "Data Layer"
            O[RDS PostgreSQL]
            P[Secrets Manager]
        end
        
        Q[CloudWatch Logs]
    end
    
    A --> C
    B --> D
    A --> E
    B --> E
    C --> F
    C --> G
    D --> H
    D --> I
    F --> J
    G --> K
    H --> L
    H --> M
    I --> N
    J --> O
    K --> O
    L --> O
    M --> O
    N --> O
    J --> P
    K --> P
    L --> P
    M --> P
    N --> P
    J --> Q
    K --> Q
    L --> Q
    M --> Q
    N --> Q
```

### Component Interaction Flow

**Login Flow:**
1. User enters credentials in Login Component
2. Validation Service validates email format and password complexity (client-side)
3. Auth Service sends credentials to API Gateway `/auth/login` endpoint
4. API Gateway invokes AuthLoginHandler Lambda function
5. Lambda validates credentials, checks account lock status, queries RDS
6. On success: Generate JWT token, return to frontend, redirect to home
7. On failure: Increment failed attempt counter in RDS, return error message
8. All operations logged to CloudWatch

**Profile Management Flow:**
1. Authenticated user navigates to Profile Component
2. Profile Service fetches user data from API Gateway `/profile` endpoint (GET)
3. API Gateway invokes GetProfileHandler Lambda with JWT validation
4. Lambda retrieves profile data from RDS and returns to frontend
5. User modifies profile fields with real-time validation
6. On save: Profile Service sends updated data to API Gateway `/profile` endpoint (PUT)
7. API Gateway invokes UpdateProfileHandler Lambda
8. Lambda validates and persists changes to RDS
9. Return success message to frontend

## Components and Interfaces

### Frontend Components

#### LoginComponent
**Responsibility**: Render login form and handle user authentication

**Template Elements:**
- Email input field (type="email")
- Password input field (type="password")
- Login button (disabled when fields empty)
- Error message display area

**Properties:**
```typescript
email: string
password: string
errorMessage: string
isLoading: boolean
isLoginDisabled: boolean
```

**Methods:**
```typescript
onEmailChange(): void
onPasswordChange(): void
login(): void
validateForm(): boolean
```

#### ProfileComponent
**Responsibility**: Render profile form and handle profile updates

**Template Elements:**
- Title dropdown (Mr, Ms, Mrs, Dr)
- First Name text input (required)
- Last Name text input (required)
- Gender radio buttons (Male, Female, Other) (required)
- Age numeric input (range: 18-120)
- Email text input (required, conditionally read-only)
- Address textarea
- Preferences multi-select checkboxes (required, at least one)
- Save button
- Cancel button

**Properties:**
```typescript
profile: UserProfile
originalProfile: UserProfile
errorMessages: Map<string, string>
isLoading: boolean
isSaveDisabled: boolean
isEmailReadOnly: boolean
```

**Methods:**
```typescript
loadProfile(): void
onFieldChange(field: string): void
validateField(field: string): boolean
save(): void
cancel(): void
```

#### AuthService
**Responsibility**: Handle authentication API calls and token management

**Methods:**
```typescript
login(email: string, password: string): Observable<AuthResponse>
logout(): void
getToken(): string | null
isAuthenticated(): boolean
```

#### ProfileService
**Responsibility**: Handle profile-related API calls

**Methods:**
```typescript
getProfile(): Observable<UserProfile>
updateProfile(profile: UserProfile): Observable<UpdateResponse>
checkEmailPolicy(): Observable<EmailPolicyResponse>
```

#### ValidationService
**Responsibility**: Provide client-side validation logic

**Methods:**
```typescript
validateEmail(email: string): ValidationResult
validatePassword(password: string): ValidationResult
validateAge(age: number): ValidationResult
validateMandatoryField(value: string): ValidationResult
validatePreferences(preferences: string[]): ValidationResult
```

### Backend Components

#### API Gateway Configuration

**REST API Endpoints:**

```yaml
/auth/login:
  POST:
    integration: Lambda (AuthLoginHandler)
    auth: None (public endpoint)
    throttling: 10 requests/second per IP
    
/auth/logout:
  POST:
    integration: Lambda (AuthLogoutHandler)
    auth: JWT Authorizer
    throttling: 100 requests/second
    
/profile:
  GET:
    integration: Lambda (GetProfileHandler)
    auth: JWT Authorizer
    throttling: 100 requests/second
  PUT:
    integration: Lambda (UpdateProfileHandler)
    auth: JWT Authorizer
    throttling: 50 requests/second
    
/profile/email-policy:
  GET:
    integration: Lambda (GetEmailPolicyHandler)
    auth: JWT Authorizer
    throttling: 100 requests/second
```

**CORS Configuration:**
```yaml
allowOrigins: ['https://yourdomain.com']
allowMethods: ['GET', 'POST', 'PUT', 'OPTIONS']
allowHeaders: ['Content-Type', 'Authorization']
allowCredentials: true
```

**Request/Response Models:**
- Request validation at API Gateway level
- Standard error response format
- Request/response logging to CloudWatch

#### Lambda Functions

##### AuthLoginHandler
**Responsibility**: Handle user authentication requests

**Handler Method:**
```java
public APIGatewayProxyResponseEvent handleRequest(
    APIGatewayProxyRequestEvent input, 
    Context context
)
```

**Environment Variables:**
- `DB_SECRET_ARN`: ARN of database credentials in Secrets Manager
- `JWT_SECRET_ARN`: ARN of JWT signing key in Secrets Manager
- `ACCOUNT_LOCK_DURATION_MINUTES`: 30
- `MAX_FAILED_ATTEMPTS`: 5

**Logic:**
1. Parse request body to extract email and password
2. Retrieve database credentials from Secrets Manager
3. Connect to RDS and query user by email
4. Check if account is locked
5. Verify password using BCrypt
6. If valid: Generate JWT token, return 200 with token
7. If invalid: Record failed attempt, check if should lock account, return 401
8. Log all operations to CloudWatch

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "token": "eyJhbGc...",
    "expiresIn": 3600,
    "user": {
      "id": 123,
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe"
    }
  }
}
```

##### AuthLogoutHandler
**Responsibility**: Handle user logout (token invalidation)

**Handler Method:**
```java
public APIGatewayProxyResponseEvent handleRequest(
    APIGatewayProxyRequestEvent input, 
    Context context
)
```

**Logic:**
1. Extract JWT token from Authorization header
2. Add token to blacklist in RDS (or use token expiry)
3. Return 200 success response

##### GetProfileHandler
**Responsibility**: Retrieve user profile data

**Handler Method:**
```java
public APIGatewayProxyResponseEvent handleRequest(
    APIGatewayProxyRequestEvent input, 
    Context context
)
```

**Logic:**
1. Extract user ID from JWT token (validated by API Gateway authorizer)
2. Retrieve database credentials from Secrets Manager
3. Query user profile from RDS
4. Return profile data as JSON

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "id": 123,
    "title": "Mr",
    "firstName": "John",
    "lastName": "Doe",
    "gender": "Male",
    "age": 30,
    "email": "user@example.com",
    "address": "123 Main St",
    "preferences": ["Email Notifications", "SMS Notifications"]
  }
}
```

##### UpdateProfileHandler
**Responsibility**: Update user profile data

**Handler Method:**
```java
public APIGatewayProxyResponseEvent handleRequest(
    APIGatewayProxyRequestEvent input, 
    Context context
)
```

**Logic:**
1. Extract user ID from JWT token
2. Parse and validate request body
3. Check email modification policy
4. Validate all mandatory fields
5. Validate field formats (email, age range)
6. Update user record in RDS
7. Return success response

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "message": "Profile updated successfully",
    "profile": { /* updated profile data */ }
  }
}
```

##### GetEmailPolicyHandler
**Responsibility**: Return email modification policy

**Handler Method:**
```java
public APIGatewayProxyResponseEvent handleRequest(
    APIGatewayProxyRequestEvent input, 
    Context context
)
```

**Environment Variables:**
- `EMAIL_MODIFICATION_ALLOWED`: true/false

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "emailModificationAllowed": false
  }
}
```

#### Shared Lambda Layer

**Purpose**: Share common code across Lambda functions

**Contents:**
- Database connection utilities
- JWT token generation and validation
- Password hashing utilities (BCrypt)
- Validation utilities
- Error response builders
- Secrets Manager client
- Logging utilities

**Layer Structure:**
```
java/lib/
  ├── common-utils.jar
  ├── aws-java-sdk-secretsmanager.jar
  ├── postgresql-jdbc.jar
  ├── bcrypt.jar
  └── jwt-library.jar
```

#### Database Access

**Connection Management:**
- Use RDS Proxy for connection pooling
- Retrieve credentials from AWS Secrets Manager
- Connection timeout: 5 seconds
- Query timeout: 30 seconds

**Repository Pattern:**
```java
public class UserRepository {
    private final Connection connection;
    
    public Optional<User> findByEmail(String email) {
        // JDBC query implementation
    }
    
    public User save(User user) {
        // JDBC insert/update implementation
    }
    
    public Optional<User> findById(Long id) {
        // JDBC query implementation
    }
}

public class LoginAttemptRepository {
    private final Connection connection;
    
    public List<LoginAttempt> findRecentAttempts(String email, int minutes) {
        // Query attempts within time window
    }
    
    public LoginAttempt save(LoginAttempt attempt) {
        // Insert login attempt record
    }
    
    public void deleteOldAttempts(String email, int minutes) {
        // Clean up old attempts
    }
}
```

## Data Models

### Frontend Models

#### UserProfile (TypeScript)
```typescript
interface UserProfile {
  id: number;
  title?: string;  // Optional: Mr, Ms, Mrs, Dr
  firstName: string;  // Required
  lastName: string;  // Required
  gender: string;  // Required: Male, Female, Other
  age?: number;  // Optional: 18-120
  email: string;  // Required
  address?: string;  // Optional
  preferences: string[];  // Required: at least one
}
```

#### LoginRequest (TypeScript)
```typescript
interface LoginRequest {
  email: string;
  password: string;
}
```

#### AuthResponse (TypeScript)
```typescript
interface AuthResponse {
  token: string;
  expiresIn: number;
  user: {
    id: number;
    email: string;
    firstName: string;
    lastName: string;
  };
}
```

#### ValidationResult (TypeScript)
```typescript
interface ValidationResult {
  isValid: boolean;
  errorMessage?: string;
}
```

### Backend Models

#### User Entity (Java - for RDS mapping)
```java
public class User {
    private Long id;
    private String title;
    private String firstName;
    private String lastName;
    private String gender;
    private Integer age;
    private String email;
    private String passwordHash;
    private String address;
    private List<String> preferences;
    private Boolean accountLocked;
    private LocalDateTime lockedUntil;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Getters, setters, constructors
}
```

#### LoginAttempt Entity (Java - for RDS mapping)
```java
public class LoginAttempt {
    private Long id;
    private String email;
    private LocalDateTime timestamp;
    private Boolean successful;
    private String ipAddress;
    
    // Getters, setters, constructors
}
```

#### ProfileUpdateRequest (Java)
```java
public class ProfileUpdateRequest {
    private String title;
    private String firstName;  // Required
    private String lastName;   // Required
    private String gender;     // Required
    private Integer age;       // Optional, 18-120
    private String email;      // Required
    private String address;    // Optional
    private List<String> preferences;  // Required, at least one
    
    // Validation methods
    public void validate() throws ValidationException {
        if (firstName == null || firstName.trim().isEmpty()) {
            throw new ValidationException("First name is required");
        }
        if (lastName == null || lastName.trim().isEmpty()) {
            throw new ValidationException("Last name is required");
        }
        if (gender == null || gender.trim().isEmpty()) {
            throw new ValidationException("Gender selection is mandatory");
        }
        if (email == null || !isValidEmail(email)) {
            throw new ValidationException("Please enter a valid email address");
        }
        if (age != null && (age < 18 || age > 120)) {
            throw new ValidationException("Age must be between 18 and 120");
        }
        if (preferences == null || preferences.isEmpty()) {
            throw new ValidationException("At least one preference is required");
        }
    }
    
    private boolean isValidEmail(String email) {
        return email.contains("@") && 
               email.indexOf("@") < email.lastIndexOf(".") &&
               !email.contains(" ");
    }
}
```

#### Lambda Response Models

**APIGatewayProxyResponseEvent** (AWS SDK):
```java
public class APIGatewayProxyResponseEvent {
    private int statusCode;
    private Map<String, String> headers;
    private String body;  // JSON string
    
    // Builder pattern for construction
}
```

**AuthResponse:**
```java
public class AuthResponse {
    private String token;
    private long expiresIn;
    private UserInfo user;
    
    public static class UserInfo {
        private Long id;
        private String email;
        private String firstName;
        private String lastName;
    }
}
```

### Database Schema

#### users table
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(10),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    age INTEGER CHECK (age >= 18 AND age <= 120),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    address TEXT,
    account_locked BOOLEAN NOT NULL DEFAULT FALSE,
    locked_until TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_locked ON users(account_locked, locked_until);
```

#### user_preferences table
```sql
CREATE TABLE user_preferences (
    user_id BIGINT NOT NULL,
    preference VARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);
```

#### login_attempts table
```sql
CREATE TABLE login_attempts (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    successful BOOLEAN NOT NULL,
    ip_address VARCHAR(45),
    CONSTRAINT fk_login_attempts_email FOREIGN KEY (email) 
        REFERENCES users(email) ON DELETE CASCADE
);

CREATE INDEX idx_login_attempts_email_timestamp ON login_attempts(email, timestamp);
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: Invalid credentials return error message
*For any* email and password combination that does not match a valid user account, the authentication attempt should return the error message "Invalid username or password"
**Validates: Requirements 1.3**

### Property 2: Login button disabled state
*For any* combination of email and password field values, the login button should be disabled if and only if at least one field is blank
**Validates: Requirements 1.4**

### Property 3: Password complexity validation
*For any* password string, it should fail validation with message "Password does not meet complexity requirements" if it does not contain all of: minimum 8 characters, at least one uppercase letter, at least one lowercase letter, at least one numeric digit, and at least one special character
**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**

### Property 4: Email format validation
*For any* email string, it should fail validation with message "Please enter a valid email address" if it does not contain an "@" symbol, or does not have a domain part after "@", or contains spaces
**Validates: Requirements 3.1, 3.2, 3.3, 9.1, 9.2, 9.3**

### Property 5: Locked account prevents login
*For any* user account that is in a locked state, any login attempt should be prevented and return an appropriate error message
**Validates: Requirements 4.2**

### Property 6: Mandatory profile fields validation
*For any* profile update request, if any mandatory field (firstName, lastName, email, gender, or preferences) is missing or empty, the validation should fail and prevent the save operation
**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

### Property 7: Age range validation
*For any* age value, it should fail validation with message "Age must be between 18 and 120" if it is non-numeric, less than 18, or greater than 120
**Validates: Requirements 8.1, 8.2, 8.3**

### Property 8: Profile save round-trip
*For any* valid profile data, saving the profile and then retrieving it should return data equivalent to what was saved
**Validates: Requirements 10.1**

### Property 9: Success message on valid save
*For any* valid profile data, successfully saving the profile should display the message "Profile updated successfully"
**Validates: Requirements 10.2**

### Property 10: Cancel discards changes
*For any* profile modifications, clicking the cancel button should revert all fields to their original values from the last saved state
**Validates: Requirements 10.3, 10.4**

## Error Handling

### Client-Side Error Handling

**Validation Errors:**
- Display inline error messages below or beside the relevant field
- Use red color (#D32F2F) and error icon for visual indication
- Clear error messages when user corrects the input
- Prevent form submission when validation errors exist

**Network Errors:**
- Display toast notification for connection failures
- Provide retry mechanism for failed requests
- Show loading indicators during API calls
- Handle timeout scenarios gracefully (30-second timeout)

**Authentication Errors:**
- Display error message for invalid credentials
- Do not reveal which field (email or password) is incorrect
- Show account locked message with unlock time
- Clear error messages on new input

### Server-Side Error Handling (Lambda)

**Validation Errors (HTTP 400):**
```json
{
  "statusCode": 400,
  "body": {
    "error": "Bad Request",
    "message": "Validation failed",
    "fieldErrors": {
      "email": "Please enter a valid email address",
      "age": "Age must be between 18 and 120"
    },
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**Authentication Errors (HTTP 401):**
```json
{
  "statusCode": 401,
  "body": {
    "error": "Unauthorized",
    "message": "Invalid username or password",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**Account Locked Error (HTTP 403):**
```json
{
  "statusCode": 403,
  "body": {
    "error": "Forbidden",
    "message": "Account is locked. Please try again after 30 minutes.",
    "lockedUntil": "2024-01-15T11:00:00Z",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**Server Errors (HTTP 500):**
```json
{
  "statusCode": 500,
  "body": {
    "error": "Internal Server Error",
    "message": "An unexpected error occurred. Please try again later.",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Error Logging

**Lambda Logging (CloudWatch):**
- Use LambdaLogger or SLF4J with CloudWatch appender
- Log all authentication attempts (success and failure)
- Log account locking events
- Log validation failures with sanitized data (no passwords)
- Log unexpected exceptions with stack traces
- Use appropriate log levels (ERROR, WARN, INFO, DEBUG)
- Include request ID for tracing

**Example Logging:**
```java
LambdaLogger logger = context.getLogger();
logger.log("Login attempt for email: " + email + ", RequestId: " + context.getRequestId());
logger.log("Account locked for email: " + email + " until " + lockedUntil);
logger.log("Failed to update profile for user: " + userId + ", Error: " + exception.getMessage());
```

**CloudWatch Log Groups:**
- `/aws/lambda/auth-login-handler`
- `/aws/lambda/auth-logout-handler`
- `/aws/lambda/get-profile-handler`
- `/aws/lambda/update-profile-handler`
- `/aws/lambda/get-email-policy-handler`

### Exception Handling Strategy

**Custom Exceptions:**
- `InvalidCredentialsException` - Invalid email/password
- `AccountLockedException` - Account is locked
- `ValidationException` - Field validation failure
- `EmailPolicyException` - Email modification not allowed
- `ProfileNotFoundException` - User profile not found
- `DatabaseException` - Database connection or query errors

**Lambda Exception Handler Pattern:**
```java
public class LambdaExceptionHandler {
    
    public static APIGatewayProxyResponseEvent handleException(
        Exception ex, 
        Context context
    ) {
        context.getLogger().log("Exception: " + ex.getMessage());
        
        if (ex instanceof InvalidCredentialsException) {
            return buildErrorResponse(401, "Invalid username or password");
        } else if (ex instanceof AccountLockedException) {
            AccountLockedException lockEx = (AccountLockedException) ex;
            return buildErrorResponse(403, 
                "Account is locked. Please try again after 30 minutes.",
                Map.of("lockedUntil", lockEx.getLockedUntil().toString()));
        } else if (ex instanceof ValidationException) {
            ValidationException valEx = (ValidationException) ex;
            return buildErrorResponse(400, "Validation failed", 
                Map.of("fieldErrors", valEx.getFieldErrors()));
        } else if (ex instanceof ProfileNotFoundException) {
            return buildErrorResponse(404, "Profile not found");
        } else {
            context.getLogger().log("Unexpected error: " + ex);
            return buildErrorResponse(500, 
                "An unexpected error occurred. Please try again later.");
        }
    }
    
    private static APIGatewayProxyResponseEvent buildErrorResponse(
        int statusCode, 
        String message
    ) {
        return buildErrorResponse(statusCode, message, null);
    }
    
    private static APIGatewayProxyResponseEvent buildErrorResponse(
        int statusCode, 
        String message, 
        Map<String, Object> additionalData
    ) {
        Map<String, Object> body = new HashMap<>();
        body.put("error", getErrorName(statusCode));
        body.put("message", message);
        body.put("timestamp", Instant.now().toString());
        if (additionalData != null) {
            body.putAll(additionalData);
        }
        
        APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent();
        response.setStatusCode(statusCode);
        response.setBody(new Gson().toJson(body));
        response.setHeaders(Map.of(
            "Content-Type", "application/json",
            "Access-Control-Allow-Origin", "*"
        ));
        return response;
    }
}
```

## Testing Strategy

### Dual Testing Approach

This system requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests** focus on:
- Specific examples of valid and invalid inputs
- Edge cases (empty strings, boundary values, special characters)
- Integration between components (controller → service → repository)
- Error conditions and exception handling
- UI component rendering and user interactions

**Property-Based Tests** focus on:
- Universal validation rules across all possible inputs
- Password complexity requirements for randomly generated passwords
- Email format validation for randomly generated email strings
- Age range validation for randomly generated numeric values
- Profile data integrity for randomly generated profile objects

### Property-Based Testing Configuration

**Framework**: Use **jqwik** for Java backend property-based testing

**Configuration**:
- Minimum 100 iterations per property test
- Each test must reference its design document property
- Tag format: `@Tag("Feature: user-auth-profile, Property {number}: {property_text}")`

**Example Property Test Structure:**
```java
@Property
@Tag("Feature: user-auth-profile, Property 3: Password complexity validation")
void passwordComplexityValidation(@ForAll("invalidPasswords") String password) {
    ValidationResult result = validationService.validatePassword(password);
    
    assertThat(result.isValid()).isFalse();
    assertThat(result.getErrorMessage())
        .isEqualTo("Password does not meet complexity requirements");
}

@Provide
Arbitrary<String> invalidPasswords() {
    // Generate passwords missing at least one complexity requirement
    return Arbitraries.oneOf(
        passwordsWithoutUppercase(),
        passwordsWithoutLowercase(),
        passwordsWithoutDigit(),
        passwordsWithoutSpecialChar(),
        passwordsTooShort()
    );
}
```

### Frontend Testing

**Unit Tests (Jasmine/Karma)**:
- Component rendering and initialization
- Form validation logic
- User interaction handling (button clicks, input changes)
- Service method calls and responses
- Error message display

**Example Frontend Unit Test:**
```typescript
describe('LoginComponent', () => {
  it('should disable login button when email is empty', () => {
    component.email = '';
    component.password = 'ValidPass123!';
    component.onEmailChange();
    
    expect(component.isLoginDisabled).toBe(true);
  });
  
  it('should display error for invalid email format', () => {
    component.email = 'invalid-email';
    const result = validationService.validateEmail(component.email);
    
    expect(result.isValid).toBe(false);
    expect(result.errorMessage).toBe('Please enter a valid email address');
  });
});
```

### Backend Testing

**Unit Tests (JUnit 5)**:
- Lambda handler request/response processing
- Business logic validation
- Database access operations (with mocked connections)
- Validation logic for specific cases
- Exception handling

**Property-Based Tests (jqwik)**:
- Password validation across all invalid password patterns
- Email validation across all invalid email patterns
- Age validation across all invalid age values
- Profile validation across all combinations of missing mandatory fields

**Example Lambda Unit Test:**
```java
@Test
void shouldLockAccountAfter5FailedAttempts() {
    // Given
    String email = "user@example.com";
    AuthLoginHandler handler = new AuthLoginHandler();
    Context mockContext = mock(Context.class);
    when(mockContext.getLogger()).thenReturn(mock(LambdaLogger.class));
    
    // When - simulate 5 failed login attempts
    for (int i = 0; i < 5; i++) {
        APIGatewayProxyRequestEvent request = createLoginRequest(email, "wrongpassword");
        handler.handleRequest(request, mockContext);
    }
    
    // Then - 6th attempt should return account locked error
    APIGatewayProxyRequestEvent request = createLoginRequest(email, "correctpassword");
    APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
    
    assertEquals(403, response.getStatusCode());
    assertTrue(response.getBody().contains("Account is locked"));
}

@Test
void shouldReturnJWTTokenOnSuccessfulLogin() {
    // Given
    String email = "user@example.com";
    String password = "ValidPass123!";
    AuthLoginHandler handler = new AuthLoginHandler();
    Context mockContext = mock(Context.class);
    
    // When
    APIGatewayProxyRequestEvent request = createLoginRequest(email, password);
    APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
    
    // Then
    assertEquals(200, response.getStatusCode());
    JsonObject body = JsonParser.parseString(response.getBody()).getAsJsonObject();
    assertTrue(body.has("token"));
    assertTrue(body.has("expiresIn"));
    assertTrue(body.has("user"));
}
```

**Example Backend Property Test:**
```java
@Property
@Tag("Feature: user-auth-profile, Property 4: Email format validation")
void emailFormatValidation(@ForAll("invalidEmails") String email) {
    // Given
    ProfileUpdateRequest request = createValidProfile();
    request.setEmail(email);
    
    // When & Then
    assertThrows(ValidationException.class, () -> {
        request.validate();
    });
}

@Provide
Arbitrary<String> invalidEmails() {
    return Arbitraries.oneOf(
        Arbitraries.strings().filter(s -> !s.contains("@")),  // No @ symbol
        Arbitraries.strings().map(s -> s + "@"),  // No domain
        Arbitraries.strings().map(s -> "user @domain.com")  // Contains space
    );
}
```

### Integration Testing

**Lambda Integration Tests**:
- Use LocalStack or AWS SAM Local for local testing
- Test Lambda functions with realistic API Gateway events
- Verify database interactions with test RDS instance or H2
- Test JWT token generation and validation
- Test error handling and response formatting

**Example Integration Test:**
```java
@Test
void testAuthLoginIntegration() {
    // Given - LocalStack or SAM Local running
    AuthLoginHandler handler = new AuthLoginHandler();
    Context context = new TestContext();
    
    // Create test user in database
    createTestUser("test@example.com", "ValidPass123!");
    
    // When
    APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent()
        .withBody("{\"email\":\"test@example.com\",\"password\":\"ValidPass123!\"}")
        .withHeaders(Map.of("Content-Type", "application/json"));
    
    APIGatewayProxyResponseEvent response = handler.handleRequest(request, context);
    
    // Then
    assertEquals(200, response.getStatusCode());
    JsonObject body = JsonParser.parseString(response.getBody()).getAsJsonObject();
    assertNotNull(body.get("token").getAsString());
}
```

**API Gateway Integration Tests**:
- Test API Gateway routing to correct Lambda functions
- Verify CORS configuration
- Test rate limiting and throttling
- Verify JWT authorizer functionality
- Test request/response transformations

**Test Coverage Goals**:
- Minimum 70% code coverage (per Java conventions)
- 100% coverage of validation logic
- 100% coverage of security-critical paths (authentication, authorization)
- All error handling paths tested

### Test Data Management

**Test Database**:
- Use H2 in-memory database for unit tests
- Use RDS with separate test database for integration tests
- Use AWS SAM Local with LocalStack for local Lambda testing
- Reset database state between tests

**Test Fixtures**:
- Create reusable test data builders
- Use factory pattern for creating test users and profiles
- Maintain separate test data for valid and invalid scenarios

**Environment Variables for Testing**:
```properties
DB_SECRET_ARN=test-secret-arn
JWT_SECRET_ARN=test-jwt-secret
ACCOUNT_LOCK_DURATION_MINUTES=30
MAX_FAILED_ATTEMPTS=5
EMAIL_MODIFICATION_ALLOWED=true
```

### Performance Testing

**Lambda Cold Start Testing**:
- Measure cold start times for each Lambda function
- Target: < 3 seconds for cold starts
- Optimize by minimizing dependencies and using Lambda layers

**Load Testing**:
- Use Artillery or Gatling for API Gateway load testing
- Test concurrent login requests
- Test profile update throughput
- Verify API Gateway throttling limits

**Database Connection Testing**:
- Test RDS Proxy connection pooling
- Verify connection timeout handling
- Test query performance under load
