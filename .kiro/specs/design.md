# Design Document: User Authentication and Profile Management

## Overview

This design document describes the architecture and implementation approach for a user authentication and profile management system as part of the REXX modernization initiative. The system consists of:

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
- Pixel-perfect UI implementation based on Figma designs

## Figma Design Reference

**Primary Design File**: #[[figma:https://www.figma.com/design/GGoFL7U4ljuiJxfQ1VBBbi/POC?node-id=1-1077&t=jPWNYDTKebx4Ygd4-1]]

### Design Resources

#### Login Page
- **Desktop View**: Figma frame "Login - Desktop" (1440px)
- **Tablet View**: Figma frame "Login - Tablet" (768px)
- **Mobile View**: Figma frame "Login - Mobile" (375px)
- **Error States**: Figma frame "Login - Error States"
- **Loading State**: Figma frame "Login - Loading"
- **Account Locked State**: Figma frame "Login - Account Locked"

#### Profile Management Page
- **Desktop View**: Figma frame "Profile Management - Desktop" (1440px)
- **Tablet View**: Figma frame "Profile Management - Tablet" (768px)
- **Mobile View**: Figma frame "Profile Management - Mobile" (375px)
- **Form Layout**: Figma frame "Profile - Form Fields"
- **Validation States**: Figma frame "Profile - Validation Errors"
- **Success State**: Figma frame "Profile - Save Success"

#### Component Library
- **Form Components**: Text inputs, dropdowns, radio buttons, checkboxes
- **Buttons**: Primary, secondary, disabled, loading states
- **Error Messages**: Inline error component with icon
- **Success Messages**: Toast notification component
- **Navigation**: Header, navigation bar, logout button

#### Design System
- **Colors**: Primary, secondary, error, success, neutral palette
- **Typography**: Roboto font family with defined sizes and weights
- **Spacing**: 4px, 8px, 16px, 24px, 32px, 48px grid system
- **Border Radius**: 4px for inputs, 8px for cards
- **Shadows**: Elevation levels for cards and modals

### Implementation Guidelines from Figma

1. **Extract Design Tokens**: Use Figma Inspect panel to get exact colors, typography, and spacing
2. **Angular Material Mapping**: Map Figma components to Angular Material components
3. **Responsive Breakpoints**: Implement layouts for Mobile (375px), Tablet (768px), Desktop (1440px)
4. **Interactive States**: Implement hover, focus, active, disabled, and error states as shown in Figma
5. **Accessibility**: Ensure WCAG AA compliance for color contrast and keyboard navigation

## Requirements Coverage by Design Component

This section maps design components to the requirements they implement:

### Functional Requirements (FR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| AuthLoginHandler | Req 2, 3 | Handles successful login and invalid credentials |
| UpdateProfileHandler | Req 16 | Saves profile changes and returns success message |
| ProfileComponent | Req 17 | Implements cancel functionality to discard changes |

### UI/UX Requirements (UI)
| Component | Requirements | Figma Reference |
|-----------|--------------|-----------------|
| LoginComponent | Req 1 | Login Page - Desktop/Mobile/Tablet |
| ProfileComponent | Req 8, 9 | Profile Management Page - Form Layout |
| Title Dropdown | Req 11 | Profile - Title dropdown component |
| Gender Radio Buttons | Req 12 | Profile - Gender radio button group |
| Preferences Checkboxes | Req 15 | Profile - Preferences checkbox group |
| Email Read-Only Field | Req 18 | Profile - Email field read-only state |

### Validation Requirements (VR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| ValidationService | Req 4, 5, 6, 13, 14 | Client-side validation for all fields |
| LoginComponent | Req 4 | Disables login button when fields are empty |
| ProfileComponent | Req 10, 12, 15 | Validates mandatory fields and preferences |
| UpdateProfileHandler | Req 10, 12, 13, 14, 15 | Server-side validation for profile updates |

### Security Requirements (SR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| Password Hashing Utility | Req 5 | BCrypt password hashing |
| AuthLoginHandler | Req 7 | Account locking after 5 failed attempts |
| LoginAttemptRepository | Req 7 | Tracks failed login attempts |
| JWT Token Utility | Req 2 | Secure token generation and validation |

### Data Requirements (DR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| Database Schema | Req 9, 16 | Stores user profile data |
| GetProfileHandler | Req 9 | Retrieves profile data from database |
| UpdateProfileHandler | Req 16 | Persists profile changes to database |

### Business Rules (BR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| UpdateProfileHandler | Req 10, 13 | Enforces mandatory fields and age range |
| GetEmailPolicyHandler | Req 18 | Returns email modification policy |

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

**Login Flow (Implements Requirements 1-7):**
1. User enters credentials in Login Component (Req 1 - UI)
2. Validation Service validates email format (Req 6 - VR) and password complexity (Req 5 - SR+VR) client-side
3. Login button disabled if fields empty (Req 4 - VR)
4. Auth Service sends credentials to API Gateway `/auth/login` endpoint
5. API Gateway invokes AuthLoginHandler Lambda function
6. Lambda validates credentials, checks account lock status (Req 7 - SR), queries RDS
7. On success: Generate JWT token, return to frontend, redirect to home (Req 2 - FR)
8. On failure: Increment failed attempt counter in RDS, return error message (Req 3 - FR)
9. All operations logged to CloudWatch with SLF4J

**Profile Management Flow (Implements Requirements 8-18):**
1. Authenticated user navigates to Profile Component (Req 8 - UI)
2. Profile Service fetches user data from API Gateway `/profile` endpoint (GET)
3. API Gateway invokes GetProfileHandler Lambda with JWT validation
4. Lambda retrieves profile data from RDS and returns to frontend (Req 9 - UI+DR)
5. User modifies profile fields with real-time validation (Req 10-15 - VR)
6. Check email policy and set read-only if needed (Req 18 - BR+UI)
7. On save: Profile Service sends updated data to API Gateway `/profile` endpoint (PUT)
8. API Gateway invokes UpdateProfileHandler Lambda
9. Lambda validates mandatory fields (Req 10 - VR+BR), age range (Req 13 - VR+BR), preferences (Req 15 - UI+VR)
10. Lambda persists changes to RDS and returns success message (Req 16 - FR+DR)
11. On cancel: Revert to original data (Req 17 - FR)

## Components and Interfaces

### Frontend Components

#### LoginComponent
**Responsibility**: Render login form and handle user authentication  
**Requirements**: Req 1 (UI), Req 2 (FR), Req 3 (FR), Req 4 (VR)  
**Figma Reference**: Login Page - Desktop/Mobile/Tablet frames

**Template Elements:**
- Email input field (type="email") - Angular Material `<mat-form-field>` with `<input matInput>`
- Password input field (type="password") - Angular Material with show/hide toggle
- Login button (disabled when fields empty) - Angular Material `<button mat-raised-button>`
- Error message display area - Custom error component matching Figma error states

**Properties:**
```typescript
email: string
password: string
errorMessage: string
isLoading: boolean
isLoginDisabled: boolean  // Implements Req 4
```

**Methods:**
```typescript
onEmailChange(): void  // Validates email format (Req 6)
onPasswordChange(): void  // Validates password complexity (Req 5)
login(): void  // Handles authentication (Req 2, 3)
validateForm(): boolean  // Client-side validation
```

**Figma Design Specifications:**
- Container: 400px max-width, centered on page
- Padding: 32px
- Background: White card with elevation shadow (8dp)
- Email field height: 56px
- Password field height: 56px
- Button height: 48px
- Spacing between fields: 24px
- Error message margin-top: 8px
- Error color: #D32F2F (from Figma design system)

#### ProfileComponent
**Responsibility**: Render profile form and handle profile updates  
**Requirements**: Req 8-18 (UI, VR, FR, BR)  
**Figma Reference**: Profile Management Page - Desktop/Mobile/Tablet frames

**Template Elements:**
- Title dropdown (Mr, Ms, Mrs, Dr) - Angular Material `<mat-select>` (Req 11)
- First Name text input (required) - Angular Material `<mat-form-field>` (Req 10)
- Last Name text input (required) - Angular Material `<mat-form-field>` (Req 10)
- Gender radio buttons (Male, Female, Other) (required) - Angular Material `<mat-radio-group>` (Req 12)
- Age numeric input (range: 18-120) - Angular Material with validation (Req 13)
- Email text input (required, conditionally read-only) - Angular Material (Req 14, 18)
- Address textarea - Angular Material `<textarea matInput>`
- Preferences multi-select checkboxes (required, at least one) - Angular Material `<mat-checkbox>` (Req 15)
- Save button - Angular Material `<button mat-raised-button color="primary">` (Req 16)
- Cancel button - Angular Material `<button mat-button>` (Req 17)

**Properties:**
```typescript
profile: UserProfile
originalProfile: UserProfile  // For cancel functionality (Req 17)
errorMessages: Map<string, string>
isLoading: boolean
isSaveDisabled: boolean
isEmailReadOnly: boolean  // Implements Req 18
```

**Methods:**
```typescript
loadProfile(): void  // Implements Req 9
onFieldChange(field: string): void  // Real-time validation
validateField(field: string): boolean  // Implements Req 10-15
save(): void  // Implements Req 16
cancel(): void  // Implements Req 17
```

**Figma Design Specifications:**
- Container: 800px max-width, centered
- Padding: 48px
- Form layout: 2-column grid on desktop, single column on mobile
- Field height: 56px for inputs, 120px for textarea
- Label font: Roboto 14px, weight 500
- Input font: Roboto 16px, weight 400
- Spacing between fields: 24px
- Button height: 48px
- Button min-width: 120px
- Success message: Green toast (#388E3C) at top-right
- Error messages: Red text (#D32F2F) below each field

#### AuthService
**Responsibility**: Handle authentication API calls and token management  
**Requirements**: Req 2 (FR), Req 3 (FR)

**Methods:**
```typescript
login(email: string, password: string): Observable<AuthResponse>  // Implements Req 2, 3
logout(): void
getToken(): string | null
isAuthenticated(): boolean
```

**Security Implementation:**
- Store JWT token in localStorage with secure practices
- Include token in Authorization header for all authenticated requests
- Clear token on logout
- Validate token expiry before API calls

#### ProfileService
**Responsibility**: Handle profile-related API calls  
**Requirements**: Req 9 (UI+DR), Req 16 (FR+DR), Req 18 (BR+UI)

**Methods:**
```typescript
getProfile(): Observable<UserProfile>  // Implements Req 9
updateProfile(profile: UserProfile): Observable<UpdateResponse>  // Implements Req 16
checkEmailPolicy(): Observable<EmailPolicyResponse>  // Implements Req 18
```

#### ValidationService
**Responsibility**: Provide client-side validation logic  
**Requirements**: Req 4-6 (VR), Req 10 (VR+BR), Req 13-15 (VR)

**Methods:**
```typescript
validateEmail(email: string): ValidationResult  // Implements Req 6, 14
validatePassword(password: string): ValidationResult  // Implements Req 5
validateAge(age: number): ValidationResult  // Implements Req 13
validateMandatoryField(value: string): ValidationResult  // Implements Req 10
validatePreferences(preferences: string[]): ValidationResult  // Implements Req 15
```

**Validation Rules:**
- Email: Must contain "@", domain part, no spaces (Req 6, 14)
- Password: Min 8 chars, uppercase, lowercase, digit, special char (Req 5)
- Age: Numeric, range 18-120 (Req 13)
- Mandatory fields: Non-empty string (Req 10)
- Preferences: At least one selected (Req 15)

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
**Requirements**: Req 2 (FR), Req 3 (FR), Req 5 (SR+VR), Req 7 (SR)  
**Type**: Security Requirement + Functional Requirement

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
- `ACCOUNT_LOCK_DURATION_MINUTES`: 30 (Req 7)
- `MAX_FAILED_ATTEMPTS`: 5 (Req 7)

**Logic:**
1. Parse request body to extract email and password
2. Retrieve database credentials from Secrets Manager
3. Connect to RDS and query user by email
4. Check if account is locked (Req 7 - SR)
5. Verify password using BCrypt (Req 5 - SR)
6. If valid: Generate JWT token, return 200 with token (Req 2 - FR)
7. If invalid: Record failed attempt, check if should lock account, return 401 (Req 3 - FR, Req 7 - SR)
8. Log all operations to CloudWatch with SLF4J (per Java conventions)

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
**Requirements**: Req 2 (FR)  
**Type**: Functional Requirement

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
4. Log logout event to CloudWatch with SLF4J

##### GetProfileHandler
**Responsibility**: Retrieve user profile data  
**Requirements**: Req 9 (UI+DR)  
**Type**: UI/UX Requirement + Data Requirement

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
3. Query user profile from RDS (Req 9 - DR)
4. Return profile data as JSON
5. Log profile retrieval to CloudWatch with SLF4J

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
**Requirements**: Req 10 (VR+BR), Req 12 (UI+VR), Req 13 (VR+BR), Req 14 (VR), Req 15 (UI+VR), Req 16 (FR+DR), Req 18 (BR+UI)  
**Type**: Validation Requirement + Business Rule + Functional Requirement + Data Requirement

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
3. Check email modification policy (Req 18 - BR)
4. Validate all mandatory fields: firstName, lastName, email, gender (Req 10 - VR+BR)
5. Validate gender selection (Req 12 - VR)
6. Validate email format (Req 14 - VR)
7. Validate age range 18-120 (Req 13 - VR+BR)
8. Validate at least one preference selected (Req 15 - VR)
9. Update user record in RDS (Req 16 - DR)
10. Return success response with message "Profile updated successfully" (Req 16 - FR)
11. Log profile update to CloudWatch with SLF4J

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
**Requirements**: Req 18 (BR+UI)  
**Type**: Business Rule + UI/UX Requirement

**Handler Method:**
```java
public APIGatewayProxyResponseEvent handleRequest(
    APIGatewayProxyRequestEvent input, 
    Context context
)
```

**Environment Variables:**
- `EMAIL_MODIFICATION_ALLOWED`: true/false (Req 18 - BR)

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

### Property 1: Valid credentials authenticate successfully
*For any* valid user account with correct email and password, the authentication attempt should succeed and redirect the user to the Home page
**Validates: Requirements 2.1**

### Property 2: Invalid credentials return error message
*For any* email and password combination that does not match a valid user account, the authentication attempt should return the error message "Invalid username or password"
**Validates: Requirements 3.1**

### Property 3: Login button disabled state
*For any* combination of email and password field values, the login button should be disabled if and only if at least one field is blank
**Validates: Requirements 4.1**

### Property 4: Password complexity validation
*For any* password string, it should fail validation with message "Password does not meet complexity requirements" if it does not contain all of: minimum 8 characters, at least one uppercase letter, at least one lowercase letter, at least one numeric digit, and at least one special character
**Validates: Requirements 5.1**

### Property 5: Email format validation
*For any* email string, it should fail validation with message "Please enter a valid email address" if it does not contain an "@" symbol, or does not have a domain part after "@", or contains spaces
**Validates: Requirements 6.1, 14.1**

### Property 6: Account locking after failed attempts
*For any* user account, when incorrect credentials are entered more than 5 times consecutively, the account should be locked for 30 minutes and prevent further login attempts
**Validates: Requirements 7.1**

### Property 7: Mandatory profile fields validation
*For any* profile update request, if any mandatory field (First Name, Last Name, Email, or Gender) is missing or empty, the validation should fail with an appropriate error message and prevent the save operation
**Validates: Requirements 10.1, 12.2**

### Property 8: Age range validation
*For any* age value, it should fail validation with message "Age must be between 18 and 120" if it is non-numeric, less than 18, or greater than 120
**Validates: Requirements 13.1**

### Property 9: Preferences selection validation
*For any* profile update request, if no preference options are selected, the validation should fail and prevent the save operation
**Validates: Requirements 15.2**

### Property 10: Profile save round-trip with success message
*For any* valid profile data, saving the profile should persist the data correctly, display the message "Profile updated successfully", and retrieving the profile should return data equivalent to what was saved
**Validates: Requirements 16.1**

### Property 11: Cancel discards changes
*For any* profile modifications, clicking the cancel button should revert all fields to their original values from the last saved state
**Validates: Requirements 17.1**

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

---

## Design-to-Requirements Mapping

This section provides comprehensive mapping between design components and requirements, organized by requirement type.

### Functional Requirements (FR) Implementation

| Requirement | Design Components | Implementation Details |
|-------------|-------------------|------------------------|
| **Req 2: Successful Login** | AuthLoginHandler, LoginComponent, AuthService, JWT Token Utility | Lambda validates credentials, generates JWT token, frontend stores token and redirects to home page |
| **Req 3: Invalid Credentials** | AuthLoginHandler, LoginComponent | Lambda returns 401 with error message, frontend displays "Invalid username or password" |
| **Req 16: Save Profile** | UpdateProfileHandler, ProfileComponent, ProfileService | Lambda validates and persists profile data, returns success message, frontend displays toast notification |
| **Req 17: Cancel Changes** | ProfileComponent | Frontend reverts form to originalProfile state, clears error messages |

### UI/UX Requirements (UI) Implementation

| Requirement | Design Components | Figma Reference | Implementation Details |
|-------------|-------------------|-----------------|------------------------|
| **Req 1: Login Page Access** | LoginComponent | Login Page - Desktop/Mobile/Tablet | Angular component with responsive layout, 400px max-width container, centered |
| **Req 8: View Profile Page** | ProfileComponent | Profile Management Page | Angular component with 800px max-width, 2-column grid on desktop |
| **Req 9: Display Profile Fields** | ProfileComponent, GetProfileHandler | Profile - Form Fields | All 8 fields displayed with proper labels and input types |
| **Req 11: Title Field Behavior** | ProfileComponent | Profile - Title dropdown | Angular Material `<mat-select>` with 4 options (Mr, Ms, Mrs, Dr) |
| **Req 12: Gender Field Validation** | ProfileComponent | Profile - Gender radio buttons | Angular Material `<mat-radio-group>` with 3 options (Male, Female, Other) |
| **Req 15: Preferences Selection** | ProfileComponent | Profile - Preferences checkboxes | Angular Material `<mat-checkbox>` group with 3 options, at least one required |
| **Req 18: Read Only Email Rule** | ProfileComponent, GetEmailPolicyHandler | Profile - Email read-only state | Conditionally set `readonly` attribute based on policy response |

### Validation Requirements (VR) Implementation

| Requirement | Design Components | Validation Logic | Error Message |
|-------------|-------------------|------------------|---------------|
| **Req 4: Mandatory Fields Validation** | ValidationService, LoginComponent | Check if email or password is empty | Login button disabled (no message) |
| **Req 5: Password Format Validation** | ValidationService, Password Hashing Utility | Regex: min 8 chars, uppercase, lowercase, digit, special char | "Password does not meet complexity requirements" |
| **Req 6: Email Format Validation** | ValidationService | Regex: contains "@", domain part, no spaces | "Please enter a valid email address" |
| **Req 10: Mandatory Profile Fields** | ValidationService, UpdateProfileHandler | Check firstName, lastName, email, gender are non-empty | Field-specific error messages |
| **Req 12: Gender Field Validation** | ProfileComponent, UpdateProfileHandler | Check gender is selected | "Gender selection is mandatory" |
| **Req 13: Age Validation** | ValidationService, UpdateProfileHandler | Check age is numeric and 18 <= age <= 120 | "Age must be between 18 and 120" |
| **Req 14: Email Validation in Profile** | ValidationService, UpdateProfileHandler | Same as Req 6 | "Please enter a valid email address" |
| **Req 15: Preferences Selection** | ValidationService, UpdateProfileHandler | Check at least one preference is selected | "At least one preference is required" |

### Security Requirements (SR) Implementation

| Requirement | Design Components | Security Mechanism | Implementation Details |
|-------------|-------------------|-------------------|------------------------|
| **Req 5: Password Format Validation** | Password Hashing Utility, AuthLoginHandler | BCrypt password hashing | Use BCrypt with salt rounds = 10, never store plain text passwords |
| **Req 7: Account Locking** | LoginAttemptRepository, AuthLoginHandler | Failed attempt tracking and account locking | Track attempts in database, lock account for 30 minutes after 5 consecutive failures |

**Additional Security Measures:**
- JWT token authentication with secure storage (localStorage with HttpOnly cookies recommended)
- API Gateway rate limiting: 10 requests/second for login endpoint
- HTTPS enforcement for all API calls
- CSRF protection with tokens
- SQL injection prevention with parameterized queries
- XSS prevention with Angular's built-in sanitization
- Secrets Manager for database credentials and JWT secret
- CloudWatch logging for all security events (login attempts, account locks)

### Data Requirements (DR) Implementation

| Requirement | Design Components | Database Tables | Implementation Details |
|-------------|-------------------|-----------------|------------------------|
| **Req 9: Display Profile Fields** | GetProfileHandler, UserRepository | users, user_preferences | Query user by ID, join with preferences table |
| **Req 16: Save Profile** | UpdateProfileHandler, UserRepository | users, user_preferences | Update user record, delete and insert preferences |

**Database Schema:**
- `users` table: Stores user profile data with constraints (NOT NULL, CHECK, UNIQUE)
- `user_preferences` table: Stores user preferences with foreign key to users
- `login_attempts` table: Tracks authentication attempts for account locking
- Indexes: email, account_locked, locked_until, user_id for performance

### Business Rules (BR) Implementation

| Requirement | Design Components | Business Logic | Configuration |
|-------------|-------------------|----------------|---------------|
| **Req 10: Mandatory Profile Fields** | UpdateProfileHandler | Validate firstName, lastName, email, gender are non-empty | Hard-coded validation in ProfileUpdateRequest.validate() |
| **Req 13: Age Validation** | UpdateProfileHandler | Validate age range 18-120 | Hard-coded validation in ProfileUpdateRequest.validate() |
| **Req 18: Read Only Email Rule** | GetEmailPolicyHandler | Return email modification policy | Environment variable EMAIL_MODIFICATION_ALLOWED |

---

## Figma-to-Code Implementation Guide

### Step 1: Extract Design Tokens from Figma

Use Figma Inspect panel to extract exact values:

**Colors (from Figma design system):**
```scss
// src/styles/_variables.scss
$primary-color: #1976D2;
$primary-dark: #1565C0;
$primary-light: #42A5F5;
$accent-color: #FF9800;
$error-color: #D32F2F;
$success-color: #388E3C;
$warning-color: #F57C00;
$text-primary: #212121;
$text-secondary: #757575;
$text-disabled: #BDBDBD;
$background: #FAFAFA;
$surface: #FFFFFF;
$divider: #E0E0E0;
```

**Typography (from Figma design system):**
```scss
// src/styles/_typography.scss
$font-family: 'Roboto', sans-serif;

// Headings
$h1-size: 32px;
$h1-weight: 500;
$h1-line-height: 40px;

$h2-size: 24px;
$h2-weight: 500;
$h2-line-height: 32px;

// Body
$body-size: 16px;
$body-weight: 400;
$body-line-height: 24px;

// Labels
$label-size: 14px;
$label-weight: 500;
$label-line-height: 20px;

// Captions
$caption-size: 12px;
$caption-weight: 400;
$caption-line-height: 16px;
```

**Spacing (from Figma design system):**
```scss
// src/styles/_spacing.scss
$spacing-xs: 4px;
$spacing-sm: 8px;
$spacing-md: 16px;
$spacing-lg: 24px;
$spacing-xl: 32px;
$spacing-xxl: 48px;
```

**Border Radius:**
```scss
$border-radius-sm: 4px;  // Inputs, buttons
$border-radius-md: 8px;  // Cards
$border-radius-lg: 16px; // Modals
```

### Step 2: Configure Angular Material Theme

Map Figma colors to Angular Material theme:

```scss
// src/styles/theme.scss
@use '@angular/material' as mat;
@include mat.core();

// Define custom palettes based on Figma colors
$custom-primary: mat.define-palette(mat.$blue-palette, 700, 600, 800);
$custom-accent: mat.define-palette(mat.$orange-palette, 500, 400, 600);
$custom-warn: mat.define-palette(mat.$red-palette, 700, 600, 800);

// Create theme
$custom-theme: mat.define-light-theme((
  color: (
    primary: $custom-primary,
    accent: $custom-accent,
    warn: $custom-warn,
  ),
  typography: mat.define-typography-config(
    $font-family: 'Roboto, sans-serif',
    $headline-1: mat.define-typography-level(32px, 40px, 500),
    $headline-2: mat.define-typography-level(24px, 32px, 500),
    $body-1: mat.define-typography-level(16px, 24px, 400),
    $body-2: mat.define-typography-level(14px, 20px, 400),
    $caption: mat.define-typography-level(12px, 16px, 400),
  ),
));

@include mat.all-component-themes($custom-theme);
```

### Step 3: Implement Responsive Breakpoints

Match Figma breakpoints in Angular:

```scss
// src/styles/_breakpoints.scss
$breakpoint-mobile: 375px;
$breakpoint-tablet: 768px;
$breakpoint-desktop: 1440px;

@mixin mobile {
  @media (max-width: #{$breakpoint-tablet - 1px}) {
    @content;
  }
}

@mixin tablet {
  @media (min-width: $breakpoint-tablet) and (max-width: #{$breakpoint-desktop - 1px}) {
    @content;
  }
}

@mixin desktop {
  @media (min-width: $breakpoint-desktop) {
    @content;
  }
}
```

### Step 4: Map Figma Components to Angular Material

**Login Form Example:**
```html
<!-- login.component.html -->
<div class="login-container">
  <mat-card class="login-card">
    <mat-card-header>
      <mat-card-title>Login</mat-card-title>
    </mat-card-header>
    
    <mat-card-content>
      <form [formGroup]="loginForm" (ngSubmit)="login()">
        <!-- Email Field (from Figma: Login - Email Input) -->
        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Email</mat-label>
          <input matInput type="email" formControlName="email" 
                 placeholder="name@domain.com">
          <mat-error *ngIf="loginForm.get('email')?.hasError('required')">
            Email is required
          </mat-error>
          <mat-error *ngIf="loginForm.get('email')?.hasError('email')">
            Please enter a valid email address
          </mat-error>
        </mat-form-field>

        <!-- Password Field (from Figma: Login - Password Input) -->
        <mat-form-field appearance="outline" class="full-width">
          <mat-label>Password</mat-label>
          <input matInput [type]="hidePassword ? 'password' : 'text'" 
                 formControlName="password">
          <button mat-icon-button matSuffix 
                  (click)="hidePassword = !hidePassword" 
                  type="button">
            <mat-icon>{{hidePassword ? 'visibility_off' : 'visibility'}}</mat-icon>
          </button>
          <mat-error *ngIf="loginForm.get('password')?.hasError('required')">
            Password is required
          </mat-error>
          <mat-error *ngIf="loginForm.get('password')?.hasError('pattern')">
            Password does not meet complexity requirements
          </mat-error>
        </mat-form-field>

        <!-- Error Message (from Figma: Login - Error State) -->
        <div class="error-message" *ngIf="errorMessage">
          <mat-icon>error</mat-icon>
          <span>{{ errorMessage }}</span>
        </div>

        <!-- Login Button (from Figma: Login - Primary Button) -->
        <button mat-raised-button color="primary" type="submit" 
                class="login-button" [disabled]="!loginForm.valid || isLoading">
          <span *ngIf="!isLoading">Login</span>
          <mat-spinner *ngIf="isLoading" diameter="20"></mat-spinner>
        </button>
      </form>
    </mat-card-content>
  </mat-card>
</div>
```

**Login Component Styles (matching Figma):**
```scss
// login.component.scss
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: $background;
  padding: $spacing-lg;
}

.login-card {
  max-width: 400px;
  width: 100%;
  padding: $spacing-xl;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.full-width {
  width: 100%;
  margin-bottom: $spacing-lg;
}

.error-message {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
  color: $error-color;
  font-size: $body-size;
  margin-bottom: $spacing-lg;
  
  mat-icon {
    font-size: 20px;
    width: 20px;
    height: 20px;
  }
}

.login-button {
  width: 100%;
  height: 48px;
  font-size: $body-size;
  font-weight: 500;
  margin-top: $spacing-xl;
}

// Responsive adjustments
@include mobile {
  .login-card {
    padding: $spacing-lg;
  }
}
```

### Step 5: Implement Profile Form (matching Figma)

```html
<!-- profile.component.html -->
<div class="profile-container">
  <mat-card class="profile-card">
    <mat-card-header>
      <mat-card-title>Profile Management</mat-card-title>
    </mat-card-header>
    
    <mat-card-content>
      <form [formGroup]="profileForm" (ngSubmit)="save()">
        <div class="form-grid">
          <!-- Title Dropdown (from Figma: Profile - Title Dropdown) -->
          <mat-form-field appearance="outline">
            <mat-label>Title</mat-label>
            <mat-select formControlName="title">
              <mat-option value="Mr">Mr</mat-option>
              <mat-option value="Ms">Ms</mat-option>
              <mat-option value="Mrs">Mrs</mat-option>
              <mat-option value="Dr">Dr</mat-option>
            </mat-select>
          </mat-form-field>

          <!-- First Name (from Figma: Profile - First Name Input) -->
          <mat-form-field appearance="outline">
            <mat-label>First Name *</mat-label>
            <input matInput formControlName="firstName">
            <mat-error>First name is required</mat-error>
          </mat-form-field>

          <!-- Last Name (from Figma: Profile - Last Name Input) -->
          <mat-form-field appearance="outline">
            <mat-label>Last Name *</mat-label>
            <input matInput formControlName="lastName">
            <mat-error>Last name is required</mat-error>
          </mat-form-field>

          <!-- Gender Radio Buttons (from Figma: Profile - Gender Radio Group) -->
          <div class="form-field">
            <label class="field-label">Gender *</label>
            <mat-radio-group formControlName="gender">
              <mat-radio-button value="Male">Male</mat-radio-button>
              <mat-radio-button value="Female">Female</mat-radio-button>
              <mat-radio-button value="Other">Other</mat-radio-button>
            </mat-radio-group>
            <mat-error *ngIf="profileForm.get('gender')?.hasError('required')">
              Gender selection is mandatory
            </mat-error>
          </div>

          <!-- Age (from Figma: Profile - Age Input) -->
          <mat-form-field appearance="outline">
            <mat-label>Age</mat-label>
            <input matInput type="number" formControlName="age" 
                   min="18" max="120">
            <mat-error>Age must be between 18 and 120</mat-error>
          </mat-form-field>

          <!-- Email (from Figma: Profile - Email Input) -->
          <mat-form-field appearance="outline">
            <mat-label>Email *</mat-label>
            <input matInput type="email" formControlName="email" 
                   [readonly]="isEmailReadOnly">
            <mat-icon matSuffix *ngIf="isEmailReadOnly">lock</mat-icon>
            <mat-error>Please enter a valid email address</mat-error>
          </mat-form-field>

          <!-- Address (from Figma: Profile - Address Textarea) -->
          <mat-form-field appearance="outline" class="full-width">
            <mat-label>Address</mat-label>
            <textarea matInput formControlName="address" rows="3"></textarea>
          </mat-form-field>

          <!-- Preferences (from Figma: Profile - Preferences Checkboxes) -->
          <div class="form-field full-width">
            <label class="field-label">Preferences *</label>
            <div class="checkbox-group">
              <mat-checkbox formControlName="emailNotifications">
                Email Notifications
              </mat-checkbox>
              <mat-checkbox formControlName="smsNotifications">
                SMS Notifications
              </mat-checkbox>
              <mat-checkbox formControlName="appNotifications">
                App Notifications
              </mat-checkbox>
            </div>
            <mat-error *ngIf="!hasPreferenceSelected()">
              At least one preference is required
            </mat-error>
          </div>
        </div>

        <!-- Action Buttons (from Figma: Profile - Action Buttons) -->
        <div class="action-buttons">
          <button mat-button type="button" (click)="cancel()">
            Cancel
          </button>
          <button mat-raised-button color="primary" type="submit" 
                  [disabled]="!profileForm.valid || isLoading">
            <span *ngIf="!isLoading">Save</span>
            <mat-spinner *ngIf="isLoading" diameter="20"></mat-spinner>
          </button>
        </div>
      </form>
    </mat-card-content>
  </mat-card>
</div>
```

**Profile Component Styles (matching Figma):**
```scss
// profile.component.scss
.profile-container {
  display: flex;
  justify-content: center;
  padding: $spacing-xxl $spacing-lg;
  background-color: $background;
  min-height: 100vh;
}

.profile-card {
  max-width: 800px;
  width: 100%;
  padding: $spacing-xxl;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: $spacing-lg;
  margin-bottom: $spacing-xl;
}

.full-width {
  grid-column: 1 / -1;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: $spacing-sm;
}

.field-label {
  font-size: $label-size;
  font-weight: $label-weight;
  color: $text-primary;
}

.checkbox-group {
  display: flex;
  flex-direction: column;
  gap: $spacing-md;
}

.action-buttons {
  display: flex;
  justify-content: flex-end;
  gap: $spacing-md;
  
  button {
    min-width: 120px;
    height: 48px;
  }
}

// Responsive adjustments
@include mobile {
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .profile-card {
    padding: $spacing-lg;
  }
}

@include tablet {
  .form-grid {
    grid-template-columns: 1fr;
  }
}
```

### Step 6: Quality Checklist for Figma-to-Code

Before marking implementation complete, verify:

- [ ] Colors match Figma exactly (use Figma Inspect to copy hex values)
- [ ] Typography (font-family, size, weight, line-height) matches Figma
- [ ] Spacing (padding, margin, gaps) matches Figma measurements
- [ ] Border radius matches Figma
- [ ] Shadows match Figma elevation levels
- [ ] Interactive states implemented (hover, focus, active, disabled, error)
- [ ] Responsive behavior matches all Figma breakpoints (Mobile, Tablet, Desktop)
- [ ] Animations match Figma prototype (if any)
- [ ] Icons match Figma (use Material Icons or export from Figma)
- [ ] Error states match Figma error frames
- [ ] Loading states match Figma loading frames
- [ ] Success states match Figma success frames
- [ ] Accessibility requirements met (WCAG AA color contrast, keyboard navigation)

---

## Implementation Priority by Requirement Type

### Phase 1: Infrastructure & Security (Week 1)
**Priority**: Critical  
**Requirements**: Req 5 (SR), Req 7 (SR)

- Set up AWS infrastructure (Task 1)
- Create database schema (Task 2)
- Implement password hashing utility (Task 3.2)
- Implement JWT token utility (Task 3.3)
- Implement account locking logic (Task 4.2, 5.3)

### Phase 2: Core Authentication (Week 2)
**Priority**: High  
**Requirements**: Req 1 (UI), Req 2 (FR), Req 3 (FR), Req 4 (VR), Req 6 (VR)

- Implement AuthLoginHandler (Task 5)
- Implement LoginComponent (Task 12)
- Implement ValidationService for email (Task 11.2)
- Configure API Gateway login endpoint (Task 9.2)

### Phase 3: Validation Layer (Week 3)
**Priority**: High  
**Requirements**: Req 5 (VR), Req 10 (VR+BR), Req 13 (VR+BR), Req 14 (VR), Req 15 (VR)

- Implement all validation utilities (Task 3.4)
- Write property tests for validation (Task 3.5, 3.6, 3.7)
- Implement client-side validation in components (Task 12.2, 13.3)

### Phase 4: Profile Management (Week 4)
**Priority**: High  
**Requirements**: Req 8-18 (UI, VR, FR, DR, BR)

- Implement GetProfileHandler (Task 6)
- Implement UpdateProfileHandler (Task 7)
- Implement ProfileComponent (Task 13)
- Implement GetEmailPolicyHandler (Task 8.2)
- Configure API Gateway profile endpoints (Task 9.4, 9.5)

### Phase 5: Testing & Deployment (Week 5)
**Priority**: Medium  
**Requirements**: All requirements

- Write unit tests (Task 4.3, 5.5, 6.3, 7.7, 11.5, 12.5, 13.7)
- Write property tests (Task 5.6, 5.7, 7.4, 7.5, 7.6, 12.4, 13.6)
- Integration testing (Task 16)
- Deployment pipeline (Task 15)

---

## Success Criteria

### Functional Completeness
- [ ] All 18 requirements implemented and tested
- [ ] All 11 correctness properties validated with property-based tests
- [ ] All functional flows work end-to-end (login, profile management)

### Quality Metrics
- [ ] Code coverage >= 70% (per Java conventions)
- [ ] All property tests pass with 100+ iterations
- [ ] All unit tests pass
- [ ] No critical or high severity bugs
- [ ] SonarQube quality gate passed

### UI/UX Compliance
- [ ] Pixel-perfect match with Figma designs
- [ ] All responsive breakpoints implemented (Mobile, Tablet, Desktop)
- [ ] All interactive states implemented (hover, focus, active, disabled, error)
- [ ] WCAG AA accessibility compliance verified

### Security Compliance
- [ ] Password hashing with BCrypt implemented
- [ ] Account locking after 5 failed attempts working
- [ ] JWT token authentication working
- [ ] API Gateway rate limiting configured
- [ ] All security events logged to CloudWatch

### Performance Targets
- [ ] Lambda cold start < 3 seconds
- [ ] API response time < 500ms (p95)
- [ ] Database query time < 100ms (p95)
- [ ] Frontend page load < 2 seconds

### Deployment Readiness
- [ ] Infrastructure as Code (AWS CDK) complete
- [ ] CI/CD pipeline configured and working
- [ ] Environment variables configured
- [ ] Monitoring and alerts set up
- [ ] Documentation complete
