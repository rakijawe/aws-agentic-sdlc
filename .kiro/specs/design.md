# Design Document: User Authentication, Registration, and Profile Management

## Overview

This design document describes the architecture and implementation approach for a user authentication, registration, and profile management system as part of the REXX modernization initiative. The system consists of:

1. **Registration Module**: Handles new user account creation with email/password or social login (Google, Amazon OAuth2)
2. **Authentication Module**: Handles user login with email/password credentials, validation, and account security
3. **Profile Management Module**: Allows authenticated users to view and update their profile information

The system follows a modern serverless architecture with:
- **Frontend**: React 18+ with TypeScript and Material-UI (MUI) for UI components
- **Backend**: AWS Lambda functions with Java 17 runtime for serverless API logic
- **API Gateway**: AWS API Gateway for REST API endpoints and request routing
- **Database**: Amazon RDS PostgreSQL for data persistence
- **Authentication**: JWT token management for session handling
- **Email Service**: AWS SES for email verification

Key design principles:
- Serverless architecture for scalability and cost optimization
- Separation of concerns between presentation, business logic, and data layers
- RESTful API design with proper HTTP status codes via API Gateway
- Client-side and server-side validation for security and user experience
- Secure password handling with bcrypt hashing
- Account protection through rate limiting (API Gateway) and account locking
- OAuth2 integration for social login providers
- Email verification for new accounts
- Infrastructure as Code using AWS CDK
- Pixel-perfect UI implementation based on Figma designs

## Figma Design Reference

**Primary Design File**: #[[figma:https://www.figma.com/design/GGoFL7U4ljuiJxfQ1VBBbi/POC?node-id=1-1077&t=jPWNYDTKebx4Ygd4-1]]

### Design Resources

#### Registration Page
- **Desktop View**: Figma frame "Registration - Desktop" (1440px)
- **Tablet View**: Figma frame "Registration - Tablet" (768px)
- **Mobile View**: Figma frame "Registration - Mobile" (375px)
- **Email Registration Form**: Figma frame "Registration - Email Form"
- **Social Login Buttons**: Figma frame "Registration - Social Login"
- **Password Complexity Requirements**: Figma frame "Registration - Password Requirements"
- **Error States**: Figma frame "Registration - Error States"
- **Duplicate Email Error**: Figma frame "Registration - Duplicate Email"
- **Email Verification Flow**: Figma frame "Registration - Verification Email"

#### Login Page
- **Desktop View**: Figma frame "Login - Desktop" (1440px)
- **Tablet View**: Figma frame "Login - Tablet" (768px)
- **Mobile View**: Figma frame "Login - Mobile" (375px)
- **Error States**: Figma frame "Login - Error States"
- **Loading State**: Figma frame "Login - Loading"
- **Account Locked State**: Figma frame "Login - Account Locked"
- **Unverified Email State**: Figma frame "Login - Unverified Email"

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
- **Social Login Buttons**: Google and Amazon branded buttons
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
2. **Material-UI Mapping**: Map Figma components to Material-UI (MUI) components
3. **Responsive Breakpoints**: Implement layouts for Mobile (375px), Tablet (768px), Desktop (1440px)
4. **Interactive States**: Implement hover, focus, active, disabled, and error states as shown in Figma
5. **Accessibility**: Ensure WCAG AA compliance for color contrast and keyboard navigation

## Requirements Coverage by Design Component

This section maps design components to the requirements they implement:

### Functional Requirements (FR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| RegistrationHandler | Req 2 | Creates new user account with email/password |
| OAuth2Handler | Req 4 | Handles Google and Amazon social login |
| EmailVerificationHandler | Req 6 | Sends and validates email verification |
| AuthLoginHandler | Req 9, 10 | Handles successful login and invalid credentials |
| UpdateProfileHandler | Req 23 | Saves profile changes and returns success message |
| ProfileComponent | Req 24 | Implements cancel functionality to discard changes |

### UI/UX Requirements (UI)
| Component | Requirements | Figma Reference |
|-----------|--------------|-----------------|
| RegistrationComponent | Req 1 | Registration Page - Desktop/Mobile/Tablet |
| SocialLoginComponent | Req 4 | Registration - Social Login Buttons |
| LoginComponent | Req 8 | Login Page - Desktop/Mobile/Tablet |
| ProfileComponent | Req 15, 16 | Profile Management Page - Form Layout |
| Title Dropdown | Req 18 | Profile - Title dropdown component |
| Gender Radio Buttons | Req 19 | Profile - Gender radio button group |
| Preferences Checkboxes | Req 22 | Profile - Preferences checkbox group |
| Email Read-Only Field | Req 25 | Profile - Email field read-only state |

### Validation Requirements (VR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| ValidationService | Req 3, 7, 11, 12, 13, 20, 21 | Client-side validation for all fields |
| RegistrationComponent | Req 3, 7 | Password complexity and email format validation |
| LoginComponent | Req 11 | Disables login button when fields are empty |
| ProfileComponent | Req 17, 19, 22 | Validates mandatory fields and preferences |
| RegistrationHandler | Req 2, 3, 5, 7 | Server-side registration validation |
| UpdateProfileHandler | Req 17, 19, 20, 21, 22 | Server-side validation for profile updates |

### Security Requirements (SR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| Password Hashing Utility | Req 3, 12 | BCrypt password hashing |
| AuthLoginHandler | Req 14 | Account locking after 5 failed attempts |
| LoginAttemptRepository | Req 14 | Tracks failed login attempts |
| JWT Token Utility | Req 2, 9 | Secure token generation and validation |
| OAuth2Handler | Req 4 | OAuth2 integration for social login |
| EmailVerificationHandler | Req 6 | Email verification for new accounts |
| RegistrationHandler | Req 5 | Prevents duplicate account creation |

### Data Requirements (DR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| Database Schema | Req 2, 16, 23 | Stores user account and profile data |
| GetProfileHandler | Req 16 | Retrieves profile data from database |
| UpdateProfileHandler | Req 23 | Persists profile changes to database |
| RegistrationHandler | Req 2 | Creates Customer_Identity record |

### Business Rules (BR)
| Component | Requirements | Description |
|-----------|--------------|-------------|
| RegistrationHandler | Req 5 | Enforces unique email constraint |
| UpdateProfileHandler | Req 17, 20 | Enforces mandatory fields and age range |
| GetEmailPolicyHandler | Req 25 | Returns email modification policy |

## Architecture

### System Architecture

```mermaid
graph TB
    subgraph "Frontend - React"
        A[Registration Component]
        B[Login Component]
        C[Profile Component]
        D[Auth Service]
        E[Profile Service]
        F[Validation Service]
        G[OAuth2 Service]
    end
    
    subgraph "AWS Cloud"
        subgraph "API Gateway"
            H[/auth/register]
            I[/auth/login]
            J[/auth/logout]
            K[/auth/verify-email]
            L[/auth/oauth2/google]
            M[/auth/oauth2/amazon]
            N[/profile]
            O[/profile/email-policy]
        end
        
        subgraph "Lambda Functions"
            P[RegistrationHandler]
            Q[EmailVerificationHandler]
            R[OAuth2Handler]
            S[AuthLoginHandler]
            T[AuthLogoutHandler]
            U[GetProfileHandler]
            V[UpdateProfileHandler]
            W[GetEmailPolicyHandler]
        end
        
        subgraph "Data Layer"
            X[RDS PostgreSQL]
            Y[Secrets Manager]
        end
        
        Z[CloudWatch Logs]
        AA[SES Email Service]
    end
    
    A --> D
    A --> F
    A --> G
    B --> D
    B --> F
    C --> E
    C --> F
    D --> H
    D --> I
    D --> J
    D --> K
    G --> L
    G --> M
    E --> N
    E --> O
    H --> P
    I --> S
    J --> T
    K --> Q
    L --> R
    M --> R
    N --> U
    N --> V
    O --> W
    P --> X
    P --> Y
    P --> AA
    Q --> X
    Q --> Y
    R --> X
    R --> Y
    S --> X
    S --> Y
    T --> X
    T --> Y
    U --> X
    U --> Y
    V --> X
    V --> Y
    W --> Y
    P --> Z
    Q --> Z
    R --> Z
    S --> Z
    T --> Z
    U --> Z
    V --> Z
    W --> Z
```

### Component Interaction Flow

**Registration Flow (Implements Requirements 1-7):**
1. User accesses Registration Component (Req 1 - UI)
2. User chooses email registration or social login (Req 2, 4 - FR+SR)
3. For email registration:
   - User enters email and password
   - Validation Service validates email format (Req 7 - VR) and password complexity (Req 3 - SR+VR) client-side
   - Auth Service sends registration data to API Gateway `/auth/register` endpoint
   - API Gateway invokes RegistrationHandler Lambda function
   - Lambda checks for duplicate email (Req 5 - BR+SR)
   - Lambda hashes password with BCrypt (Req 3 - SR)
   - Lambda creates Customer_Identity record in RDS (Req 2 - FR+SR)
   - Lambda triggers email verification via SES (Req 6 - FR+SR)
   - Return success response to frontend
4. For social login (Req 4 - FR+SR):
   - User clicks Google or Amazon button
   - OAuth2 Service initiates OAuth2 flow
   - User authenticates with provider
   - API Gateway invokes OAuth2Handler Lambda
   - Lambda creates or links account in RDS
   - Return JWT token to frontend
5. All operations logged to CloudWatch with SLF4J

**Email Verification Flow (Implements Requirement 6):**
1. User receives verification email with unique link
2. User clicks verification link
3. API Gateway invokes EmailVerificationHandler Lambda
4. Lambda marks account as verified in RDS
5. User can now log in

**Login Flow (Implements Requirements 8-14):**
1. User enters credentials in Login Component (Req 8 - UI)
2. Validation Service validates email format (Req 13 - VR) and password complexity (Req 12 - SR+VR) client-side
3. Login button disabled if fields empty (Req 11 - VR)
4. Auth Service sends credentials to API Gateway `/auth/login` endpoint
5. API Gateway invokes AuthLoginHandler Lambda function
6. Lambda checks if email is verified (Req 6 - FR+SR)
7. Lambda validates credentials, checks account lock status (Req 14 - SR), queries RDS
8. On success: Generate JWT token, return to frontend, redirect to home (Req 9 - FR)
9. On failure: Increment failed attempt counter in RDS, return error message (Req 10 - FR)
10. After 5 failed attempts: Lock account for 30 minutes (Req 14 - SR)
11. All operations logged to CloudWatch with SLF4J

**Profile Management Flow (Implements Requirements 15-25):**
1. Authenticated user navigates to Profile Component (Req 15 - UI)
2. Profile Service fetches user data from API Gateway `/profile` endpoint (GET)
3. API Gateway invokes GetProfileHandler Lambda with JWT validation
4. Lambda retrieves profile data from RDS and returns to frontend (Req 16 - UI+DR)
5. User modifies profile fields with real-time validation (Req 17-22 - VR)
6. Check email policy and set read-only if needed (Req 25 - BR+UI)
7. On save: Profile Service sends updated data to API Gateway `/profile` endpoint (PUT)
8. API Gateway invokes UpdateProfileHandler Lambda
9. Lambda validates mandatory fields (Req 17 - VR+BR), age range (Req 20 - VR+BR), preferences (Req 22 - UI+VR)
10. Lambda persists changes to RDS and returns success message (Req 23 - FR+DR)
11. On cancel: Revert to original data (Req 24 - FR)

## Components and Interfaces

### Frontend Components

#### RegistrationComponent
**Responsibility**: Render registration form and handle user registration  
**Requirements**: Req 1 (UI), Req 2 (FR+SR), Req 3 (SR+VR), Req 7 (VR)  
**Figma Reference**: Registration Page - Desktop/Mobile/Tablet frames

**Template Elements:**
- Email input field (type="email") - Material-UI `TextField` with variant="outlined"
- Password input field (type="password") - Material-UI `TextField` with show/hide toggle
- Confirm Password input field - Material-UI `TextField`
- Password complexity requirements display - Custom component showing requirements
- Register button - Material-UI `Button` variant="contained"
- Social login buttons (Google, Amazon) - Custom branded buttons
- Link to login page - Material-UI `Link`
- Error message display area - Custom error component matching Figma error states

**Properties:**
```typescript
email: string
password: string
confirmPassword: string
errorMessage: string
isLoading: boolean
showPasswordRequirements: boolean
passwordRequirementsMet: {
  minLength: boolean
  hasUppercase: boolean
  hasLowercase: boolean
  hasDigit: boolean
  hasSpecialChar: boolean
}
```

**Methods:**
```typescript
onEmailChange(): void  // Validates email format (Req 7)
onPasswordChange(): void  // Validates password complexity (Req 3)
register(): void  // Handles registration (Req 2)
registerWithGoogle(): void  // Handles Google OAuth2 (Req 4)
registerWithAmazon(): void  // Handles Amazon OAuth2 (Req 4)
validateForm(): boolean  // Client-side validation
checkPasswordRequirements(): void  // Real-time password validation
```

**Figma Design Specifications:**
- Container: 450px max-width, centered on page
- Padding: 32px
- Background: White card with elevation shadow (8dp)
- Email field height: 56px
- Password field height: 56px
- Button height: 48px
- Spacing between fields: 24px
- Password requirements: Green checkmarks for met, gray for unmet
- Social login buttons: Full width, 48px height, branded colors
- Error message margin-top: 8px
- Error color: #D32F2F (from Figma design system)
- Success color: #388E3C (for password requirements met)

#### LoginComponent
**Responsibility**: Render login form and handle user authentication  
**Requirements**: Req 8 (UI), Req 9 (FR), Req 10 (FR), Req 11 (VR)  
**Figma Reference**: Login Page - Desktop/Mobile/Tablet frames

**Template Elements:**
- Email input field (type="email") - Material-UI `TextField` with variant="outlined"
- Password input field (type="password") - Material-UI `TextField` with show/hide toggle
- Login button (disabled when fields empty) - Material-UI `Button` variant="contained"
- Link to registration page - Material-UI `Link`
- "Forgot Password" link - Material-UI `Link`
- Error message display area - Custom error component matching Figma error states

**Properties:**
```typescript
email: string
password: string
errorMessage: string
isLoading: boolean
isLoginDisabled: boolean  // Implements Req 11
```

**Methods:**
```typescript
onEmailChange(): void  // Validates email format (Req 13)
onPasswordChange(): void  // Validates password complexity (Req 12)
login(): void  // Handles authentication (Req 9, 10)
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
**Requirements**: Req 15-25 (UI, VR, FR, BR)  
**Figma Reference**: Profile Management Page - Desktop/Mobile/Tablet frames

**Template Elements:**
- Title dropdown (Mr, Ms, Mrs, Dr) - Material-UI `Select` (Req 18)
- First Name text input (required) - Material-UI `TextField` (Req 17)
- Last Name text input (required) - Material-UI `TextField` (Req 17)
- Gender radio buttons (Male, Female, Other) (required) - Material-UI `RadioGroup` (Req 19)
- Age numeric input (range: 18-120) - Material-UI `TextField` type="number" with validation (Req 20)
- Email text input (required, conditionally read-only) - Material-UI `TextField` (Req 21, 25)
- Address textarea - Material-UI `TextField` multiline (Req 16)
- Preferences multi-select checkboxes (required, at least one) - Material-UI `Checkbox` (Req 22)
- Save button - Material-UI `Button` variant="contained" color="primary" (Req 23)
- Cancel button - Material-UI `Button` variant="outlined" (Req 24)

**Properties:**
```typescript
profile: UserProfile
originalProfile: UserProfile  // For cancel functionality (Req 24)
errorMessages: Map<string, string>
isLoading: boolean
isSaveDisabled: boolean
isEmailReadOnly: boolean  // Implements Req 25
```

**Methods:**
```typescript
loadProfile(): void  // Implements Req 16
onFieldChange(field: string): void  // Real-time validation
validateField(field: string): boolean  // Implements Req 17-22
save(): void  // Implements Req 23
cancel(): void  // Implements Req 24
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
**Responsibility**: Handle authentication and registration API calls and token management  
**Requirements**: Req 2 (FR), Req 4 (FR+SR), Req 9 (FR), Req 10 (FR)

**Methods:**
```typescript
register(email: string, password: string): Promise<RegistrationResponse>  // Implements Req 2
registerWithOAuth2(provider: 'google' | 'amazon'): Promise<AuthResponse>  // Implements Req 4
login(email: string, password: string): Promise<AuthResponse>  // Implements Req 9, 10
logout(): void
getToken(): string | null
isAuthenticated(): boolean
```

**Security Implementation:**
- Store JWT token in localStorage or sessionStorage with secure practices
- Include token in Authorization header for all authenticated requests
- Clear token on logout
- Validate token expiry before API calls

#### ProfileService
**Responsibility**: Handle profile-related API calls  
**Requirements**: Req 16 (UI+DR), Req 23 (FR+DR), Req 25 (BR+UI)

**Methods:**
```typescript
getProfile(): Promise<UserProfile>  // Implements Req 16
updateProfile(profile: UserProfile): Promise<UpdateResponse>  // Implements Req 23
checkEmailPolicy(): Promise<EmailPolicyResponse>  // Implements Req 25
```

#### ValidationService
**Responsibility**: Provide client-side validation logic  
**Requirements**: Req 3 (SR+VR), Req 7 (VR), Req 11-13 (VR), Req 17 (VR+BR), Req 20-22 (VR)

**Methods:**
```typescript
validateEmail(email: string): ValidationResult  // Implements Req 7, 13, 21
validatePassword(password: string): ValidationResult  // Implements Req 3, 12
validateAge(age: number): ValidationResult  // Implements Req 20
validateMandatoryField(value: string): ValidationResult  // Implements Req 17
validatePreferences(preferences: string[]): ValidationResult  // Implements Req 22
checkPasswordRequirements(password: string): PasswordRequirements  // Implements Req 3
```

**Validation Rules:**
- Email: Must contain "@", domain part, no spaces (Req 7, 13, 21)
- Password: Min 8 chars, uppercase, lowercase, digit, special char (Req 3, 12)
- Age: Numeric, range 18-120 (Req 20)
- Mandatory fields: Non-empty string (Req 17)
- Preferences: At least one selected (Req 22)

#### OAuth2Service
**Responsibility**: Handle OAuth2 authentication flows  
**Requirements**: Req 4 (FR+SR)

**Methods:**
```typescript
initiateGoogleLogin(): void  // Opens Google OAuth2 consent screen
initiateAmazonLogin(): void  // Opens Amazon OAuth2 consent screen
handleOAuth2Callback(code: string, provider: string): Promise<AuthResponse>
```

**OAuth2 Configuration:**
- Google Client ID and Secret stored in environment variables
- Amazon Client ID and Secret stored in environment variables
- Redirect URI configured in API Gateway
- Scopes: email, profile

### Backend Components

#### API Gateway Configuration

**REST API Endpoints:**

```yaml
/auth/register:
  POST:
    integration: Lambda (RegistrationHandler)
    auth: None (public endpoint)
    throttling: 5 requests/second per IP
    
/auth/verify-email:
  GET:
    integration: Lambda (EmailVerificationHandler)
    auth: None (public endpoint)
    throttling: 10 requests/second
    
/auth/oauth2/google:
  POST:
    integration: Lambda (OAuth2Handler)
    auth: None (public endpoint)
    throttling: 10 requests/second
    
/auth/oauth2/amazon:
  POST:
    integration: Lambda (OAuth2Handler)
    auth: None (public endpoint)
    throttling: 10 requests/second
    
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

##### RegistrationHandler
**Responsibility**: Handle user registration requests  
**Requirements**: Req 2 (FR+SR), Req 3 (SR+VR), Req 5 (BR+SR), Req 7 (VR)  
**Type**: Functional Requirement + Security Requirement + Business Rule

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
- `SES_FROM_EMAIL`: Email address for sending verification emails
- `VERIFICATION_BASE_URL`: Base URL for email verification links

**Logic:**
1. Parse request body to extract email and password
2. Validate email format (Req 7 - VR)
3. Validate password complexity (Req 3 - SR+VR)
4. Retrieve database credentials from Secrets Manager
5. Connect to RDS and check for duplicate email (Req 5 - BR+SR)
6. If duplicate: Return 400 with message "An account with this email already exists"
7. Hash password using BCrypt (Req 3 - SR)
8. Create new user record in Customer_Identity table (Req 2 - FR+SR)
9. Generate email verification token
10. Send verification email via SES (Req 2 - FR+SR)
11. Return 201 with success message
12. Log all operations to CloudWatch with SLF4J

**Response:**
```json
{
  "statusCode": 201,
  "body": {
    "message": "Registration successful. Please check your email to verify your account.",
    "email": "user@example.com"
  }
}
```

##### EmailVerificationHandler
**Responsibility**: Handle email verification requests  
**Requirements**: Req 6 (FR+SR)  
**Type**: Functional Requirement + Security Requirement

**Handler Method:**
```java
public APIGatewayProxyResponseEvent handleRequest(
    APIGatewayProxyRequestEvent input, 
    Context context
)
```

**Logic:**
1. Extract verification token from query parameters
2. Validate token format and expiry
3. Retrieve database credentials from Secrets Manager
4. Query user by verification token
5. If valid: Mark account as verified in RDS (Req 6 - FR+SR)
6. If invalid/expired: Return 400 with error message
7. Return success response
8. Log verification event to CloudWatch with SLF4J

**Response:**
```json
{
  "statusCode": 200,
  "body": {
    "message": "Email verified successfully. You can now log in.",
    "verified": true
  }
}
```

##### OAuth2Handler
**Responsibility**: Handle OAuth2 authentication for Google and Amazon  
**Requirements**: Req 4 (FR+SR)  
**Type**: Functional Requirement + Security Requirement

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
- `GOOGLE_CLIENT_ID`: Google OAuth2 client ID
- `GOOGLE_CLIENT_SECRET`: Google OAuth2 client secret (from Secrets Manager)
- `AMAZON_CLIENT_ID`: Amazon OAuth2 client ID
- `AMAZON_CLIENT_SECRET`: Amazon OAuth2 client secret (from Secrets Manager)

**Logic:**
1. Parse request body to extract authorization code and provider
2. Exchange authorization code for access token with provider
3. Retrieve user profile from provider (email, name)
4. Retrieve database credentials from Secrets Manager
5. Check if user exists by email
6. If exists: Link social login to existing account (Req 4.3 - FR+SR)
7. If not exists: Create new user record (Req 4.2 - FR+SR)
8. Generate JWT token
9. Return token and user info
10. Log OAuth2 authentication to CloudWatch with SLF4J

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
      "lastName": "Doe",
      "provider": "google"
    }
  }
}
```

##### AuthLoginHandler
**Responsibility**: Handle user authentication requests  
**Requirements**: Req 9 (FR), Req 10 (FR), Req 12 (SR+VR), Req 14 (SR), Req 6.3 (FR+SR)  
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
- `ACCOUNT_LOCK_DURATION_MINUTES`: 30 (Req 14)
- `MAX_FAILED_ATTEMPTS`: 5 (Req 14)

**Logic:**
1. Parse request body to extract email and password
2. Retrieve database credentials from Secrets Manager
3. Connect to RDS and query user by email
4. Check if account is verified (Req 6.3 - FR+SR)
5. If not verified: Return 403 with message "Please verify your email address before logging in"
6. Check if account is locked (Req 14 - SR)
7. If locked: Return 403 with account locked message
8. Verify password using BCrypt (Req 12 - SR)
9. If valid: Generate JWT token, clear failed attempts, return 200 with token (Req 9 - FR)
10. If invalid: Record failed attempt, check if should lock account, return 401 (Req 10 - FR, Req 14 - SR)
11. Log all operations to CloudWatch with SLF4J

**Response (Success):**
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

**Response (Invalid Credentials):**
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

**Response (Unverified Email):**
```json
{
  "statusCode": 403,
  "body": {
    "error": "Forbidden",
    "message": "Please verify your email address before logging in",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

##### AuthLogoutHandler
**Responsibility**: Handle user logout (token invalidation)  
**Requirements**: Req 9 (FR)  
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
**Requirements**: Req 16 (UI+DR)  
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
3. Query user profile from RDS (Req 16 - DR)
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
**Requirements**: Req 17 (VR+BR), Req 19 (UI+VR), Req 20 (VR+BR), Req 21 (VR), Req 22 (UI+VR), Req 23 (FR+DR), Req 25 (BR+UI)  
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
3. Check email modification policy (Req 25 - BR)
4. Validate all mandatory fields: firstName, lastName, email, gender (Req 17 - VR+BR)
5. Validate gender selection (Req 19 - VR)
6. Validate email format (Req 21 - VR)
7. Validate age range 18-120 (Req 20 - VR+BR)
8. Validate at least one preference selected (Req 22 - VR)
9. Update user record in RDS (Req 23 - DR)
10. Return success response with message "Profile updated successfully" (Req 23 - FR)
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
**Requirements**: Req 25 (BR+UI)  
**Type**: Business Rule + UI/UX Requirement

**Handler Method:**
```java
public APIGatewayProxyResponseEvent handleRequest(
    APIGatewayProxyRequestEvent input, 
    Context context
)
```

**Environment Variables:**
- `EMAIL_MODIFICATION_ALLOWED`: true/false (Req 25 - BR)

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
- OAuth2 client utilities
- Email service utilities (SES)

**Layer Structure:**
```
java/lib/
  ├── common-utils.jar
  ├── aws-java-sdk-secretsmanager.jar
  ├── aws-java-sdk-ses.jar
  ├── postgresql-jdbc.jar
  ├── bcrypt.jar
  ├── jwt-library.jar
  └── oauth2-client.jar
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
    
    public boolean existsByEmail(String email) {
        // Check for duplicate email (Req 5)
    }
    
    public void markEmailVerified(String email) {
        // Mark account as verified (Req 6)
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

#### RegistrationRequest (TypeScript)
```typescript
interface RegistrationRequest {
  email: string;
  password: string;
  confirmPassword: string;
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
    provider?: string;  // 'email', 'google', 'amazon'
  };
}
```

#### RegistrationResponse (TypeScript)
```typescript
interface RegistrationResponse {
  message: string;
  email: string;
}
```

#### ValidationResult (TypeScript)
```typescript
interface ValidationResult {
  isValid: boolean;
  errorMessage?: string;
}
```

#### PasswordRequirements (TypeScript)
```typescript
interface PasswordRequirements {
  minLength: boolean;
  hasUppercase: boolean;
  hasLowercase: boolean;
  hasDigit: boolean;
  hasSpecialChar: boolean;
  allMet: boolean;
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
    private Boolean emailVerified;
    private String verificationToken;
    private LocalDateTime verificationTokenExpiry;
    private String authProvider;  // 'email', 'google', 'amazon'
    private String providerId;  // OAuth2 provider user ID
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

#### RegistrationRequest (Java)
```java
public class RegistrationRequest {
    private String email;
    private String password;
    
    public void validate() throws ValidationException {
        if (email == null || !isValidEmail(email)) {
            throw new ValidationException("Please enter a valid email address");
        }
        if (password == null || !isValidPassword(password)) {
            throw new ValidationException("Password does not meet complexity requirements");
        }
    }
    
    private boolean isValidEmail(String email) {
        return email.contains("@") && 
               email.indexOf("@") < email.lastIndexOf(".") &&
               !email.contains(" ");
    }
    
    private boolean isValidPassword(String password) {
        return password.length() >= 8 &&
               password.matches(".*[A-Z].*") &&
               password.matches(".*[a-z].*") &&
               password.matches(".*\\d.*") &&
               password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{}|;:,.<>?].*");
    }
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

#### OAuth2Request (Java)
```java
public class OAuth2Request {
    private String code;  // Authorization code from provider
    private String provider;  // 'google' or 'amazon'
    private String redirectUri;
    
    // Getters, setters, constructors
}
```

#### OAuth2UserInfo (Java)
```java
public class OAuth2UserInfo {
    private String providerId;
    private String email;
    private String firstName;
    private String lastName;
    private String provider;
    
    // Getters, setters, constructors
}
```

### Database Schema

#### users table (Customer_Identity)
```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(10),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    age INTEGER CHECK (age >= 18 AND age <= 120),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),  -- NULL for OAuth2 users
    address TEXT,
    account_locked BOOLEAN NOT NULL DEFAULT FALSE,
    locked_until TIMESTAMP,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    verification_token VARCHAR(255),
    verification_token_expiry TIMESTAMP,
    auth_provider VARCHAR(20) NOT NULL DEFAULT 'email',  -- 'email', 'google', 'amazon'
    provider_id VARCHAR(255),  -- OAuth2 provider user ID
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_locked ON users(account_locked, locked_until);
CREATE INDEX idx_users_verification_token ON users(verification_token);
CREATE INDEX idx_users_provider ON users(auth_provider, provider_id);
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

#### token_blacklist table (for logout)
```sql
CREATE TABLE token_blacklist (
    id BIGSERIAL PRIMARY KEY,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expiry TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_token_blacklist_expiry ON token_blacklist(expiry);
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Unique email registration
*For any* email address, the system should prevent creation of multiple accounts with the same email and return the error message "An account with this email already exists"
**Validates: Requirements 2.3, 5.2**

### Property 2: Password complexity validation during registration
*For any* password string during registration, it should fail validation with message "Password does not meet complexity requirements" if it does not contain all of: minimum 8 characters, at least one uppercase letter, at least one lowercase letter, at least one numeric digit, and at least one special character
**Validates: Requirements 3.1**

### Property 3: Email verification requirement
*For any* user account that has not verified their email, login attempts should return the error message "Please verify your email address before logging in"
**Validates: Requirements 6.3**

### Property 4: Email format validation during registration
*For any* email string during registration, it should fail validation with message "Please enter a valid email address" if it does not contain an "@" symbol, or does not have a domain part after "@", or contains spaces
**Validates: Requirements 7.1**

### Property 5: Valid credentials authenticate successfully
*For any* valid user account with correct email and password and verified email, the authentication attempt should succeed and redirect the user to the Home page
**Validates: Requirements 9.1**

### Property 6: Invalid credentials return error message
*For any* email and password combination that does not match a valid user account, the authentication attempt should return the error message "Invalid username or password"
**Validates: Requirements 10.1**

### Property 7: Login button disabled state
*For any* combination of email and password field values, the login button should be disabled if and only if at least one field is blank
**Validates: Requirements 11.1**

### Property 8: Password complexity validation during login
*For any* password string during login, it should fail validation with message "Password does not meet complexity requirements" if it does not contain all of: minimum 8 characters, at least one uppercase letter, at least one lowercase letter, at least one numeric digit, and at least one special character
**Validates: Requirements 12.1**

### Property 9: Email format validation during login
*For any* email string during login, it should fail validation with message "Please enter a valid email address" if it does not contain an "@" symbol, or does not have a domain part after "@", or contains spaces
**Validates: Requirements 13.1**

### Property 10: Account locking after failed attempts
*For any* user account, when incorrect credentials are entered more than 5 times consecutively, the account should be locked for 30 minutes and prevent further login attempts
**Validates: Requirements 14.1**

### Property 11: Mandatory profile fields validation
*For any* profile update request, if any mandatory field (First Name, Last Name, Email, or Gender) is missing or empty, the validation should fail with an appropriate error message and prevent the save operation
**Validates: Requirements 17.1, 19.2**

### Property 12: Age range validation
*For any* age value, it should fail validation with message "Age must be between 18 and 120" if it is non-numeric, less than 18, or greater than 120
**Validates: Requirements 20.1**

### Property 13: Email format validation in profile
*For any* email string in profile update, it should fail validation with message "Please enter a valid email address" if it does not contain an "@" symbol, or does not have a domain part after "@", or contains spaces
**Validates: Requirements 21.1**

### Property 14: Preferences selection validation
*For any* profile update request, if no preference options are selected, the validation should fail and prevent the save operation
**Validates: Requirements 22.2**

### Property 15: Profile save round-trip integrity
*For any* valid profile data, saving the profile should persist the data correctly, display the message "Profile updated successfully", and retrieving the profile should return data equivalent to what was saved
**Validates: Requirements 23.1**

### Property 16: Cancel discards changes
*For any* profile modifications, clicking the cancel button should revert all fields to their original values from the last saved state
**Validates: Requirements 24.1**

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
- Show unverified email message with resend verification link
- Clear error messages on new input

**Registration Errors:**
- Display duplicate email error message
- Show password complexity requirements in real-time
- Highlight unmet password requirements
- Display email format validation errors

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

**Duplicate Email Error (HTTP 400):**
```json
{
  "statusCode": 400,
  "body": {
    "error": "Bad Request",
    "message": "An account with this email already exists",
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

**Unverified Email Error (HTTP 403):**
```json
{
  "statusCode": 403,
  "body": {
    "error": "Forbidden",
    "message": "Please verify your email address before logging in",
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
- Use SLF4J with CloudWatch appender (per Java conventions)
- Log all registration attempts (success and failure)
- Log all authentication attempts (success and failure)
- Log email verification events
- Log OAuth2 authentication events
- Log account locking events
- Log validation failures with sanitized data (no passwords)
- Log unexpected exceptions with stack traces
- Use appropriate log levels (ERROR, WARN, INFO, DEBUG)
- Include request ID for tracing

**CloudWatch Log Groups:**
- `/aws/lambda/registration-handler`
- `/aws/lambda/email-verification-handler`
- `/aws/lambda/oauth2-handler`
- `/aws/lambda/auth-login-handler`
- `/aws/lambda/auth-logout-handler`
- `/aws/lambda/get-profile-handler`
- `/aws/lambda/update-profile-handler`
- `/aws/lambda/get-email-policy-handler`

### Exception Handling Strategy

**Custom Exceptions:**
- `DuplicateEmailException` - Email already exists
- `InvalidCredentialsException` - Invalid email/password
- `AccountLockedException` - Account is locked
- `EmailNotVerifiedException` - Email not verified
- `ValidationException` - Field validation failure
- `EmailPolicyException` - Email modification not allowed
- `ProfileNotFoundException` - User profile not found
- `DatabaseException` - Database connection or query errors
- `OAuth2Exception` - OAuth2 authentication failure

## Testing Strategy

### Dual Testing Approach

This system requires both unit tests and property-based tests for comprehensive coverage:

**Unit Tests** focus on:
- Specific examples of valid and invalid inputs
- Edge cases (empty strings, boundary values, special characters)
- Integration between components (controller → service → repository)
- Error conditions and exception handling
- UI component rendering and user interactions
- OAuth2 flow integration
- Email verification flow

**Property-Based Tests** focus on:
- Universal validation rules across all possible inputs
- Password complexity requirements for randomly generated passwords
- Email format validation for randomly generated email strings
- Age range validation for randomly generated numeric values
- Profile data integrity for randomly generated profile objects
- Duplicate email prevention across random email inputs

### Property-Based Testing Configuration

**Framework**: Use **jqwik** for Java backend property-based testing

**Configuration**:
- Minimum 100 iterations per property test
- Each test must reference its design document property
- Tag format: `@Tag("Feature: user-auth-registration-profile, Property {number}: {property_text}")`

**Example Property Test Structure:**
```java
@Property
@Tag("Feature: user-auth-registration-profile, Property 2: Password complexity validation")
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

**Unit Tests (Jest/React Testing Library)**:
- Component rendering and initialization
- Form validation logic
- User interaction handling (button clicks, input changes)
- Service method calls and responses
- Error message display
- OAuth2 button clicks
- Password requirements display

**Example Frontend Unit Test:**
```typescript
describe('RegistrationComponent', () => {
  it('should display password requirements in real-time', () => {
    const { getByLabelText, getByText } = render(<RegistrationComponent />);
    const passwordInput = getByLabelText(/password/i);
    
    fireEvent.change(passwordInput, { target: { value: 'weak' } });
    
    expect(getByText(/minimum 8 characters/i)).toHaveClass('unmet');
    expect(getByText(/uppercase letter/i)).toHaveClass('unmet');
  });
  
  it('should prevent registration with duplicate email', async () => {
    const { getByRole, getByText } = render(<RegistrationComponent />);
    const emailInput = getByRole('textbox', { name: /email/i });
    const registerButton = getByRole('button', { name: /register/i });
    
    fireEvent.change(emailInput, { target: { value: 'existing@example.com' } });
    fireEvent.click(registerButton);
    
    await waitFor(() => {
      expect(getByText('An account with this email already exists')).toBeInTheDocument();
    });
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
- OAuth2 token exchange
- Email verification token generation

**Property-Based Tests (jqwik)**:
- Password validation across all invalid password patterns
- Email validation across all invalid email patterns
- Age validation across all invalid age values
- Profile validation across all combinations of missing mandatory fields
- Duplicate email prevention across random email inputs

**Example Lambda Unit Test:**
```java
@Test
void shouldPreventDuplicateEmailRegistration() {
    // Given
    String email = "existing@example.com";
    RegistrationHandler handler = new RegistrationHandler();
    Context mockContext = mock(Context.class);
    when(mockContext.getLogger()).thenReturn(mock(LambdaLogger.class));
    
    // Create existing user
    createTestUser(email, "ValidPass123!");
    
    // When - attempt to register with same email
    APIGatewayProxyRequestEvent request = createRegistrationRequest(email, "NewPass456!");
    APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
    
    // Then
    assertEquals(400, response.getStatusCode());
    assertTrue(response.getBody().contains("An account with this email already exists"));
}

@Test
void shouldSendVerificationEmailAfterRegistration() {
    // Given
    String email = "newuser@example.com";
    RegistrationHandler handler = new RegistrationHandler();
    Context mockContext = mock(Context.class);
    
    // When
    APIGatewayProxyRequestEvent request = createRegistrationRequest(email, "ValidPass123!");
    APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
    
    // Then
    assertEquals(201, response.getStatusCode());
    verify(sesClient).sendEmail(argThat(req -> 
        req.getDestination().getToAddresses().contains(email)
    ));
}
```

**Example Backend Property Test:**
```java
@Property
@Tag("Feature: user-auth-registration-profile, Property 4: Email format validation")
void emailFormatValidation(@ForAll("invalidEmails") String email) {
    // Given
    RegistrationRequest request = new RegistrationRequest();
    request.setEmail(email);
    request.setPassword("ValidPass123!");
    
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
- Test OAuth2 integration with mock providers
- Test email sending with SES sandbox

**Test Coverage Goals**:
- Minimum 70% code coverage (per Java conventions)
- 100% coverage of validation logic
- 100% coverage of security-critical paths (authentication, authorization, registration)
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
SES_FROM_EMAIL=test@example.com
VERIFICATION_BASE_URL=http://localhost:3000/verify
GOOGLE_CLIENT_ID=test-google-client-id
AMAZON_CLIENT_ID=test-amazon-client-id
```

## Design-to-Requirements Mapping

This section provides comprehensive mapping between design components and requirements, organized by requirement type.

### Functional Requirements (FR) Implementation

| Requirement | Design Components | Implementation Details |
|-------------|-------------------|------------------------|
| **Req 2: Email Registration** | RegistrationHandler, RegistrationComponent, AuthService, Customer_Identity table | Lambda validates and creates user record, sends verification email via SES, frontend displays success message |
| **Req 4: Social Login Registration** | OAuth2Handler, SocialLoginComponent, OAuth2Service | Lambda exchanges OAuth2 code for token, retrieves user profile, creates or links account |
| **Req 6: Email Verification** | EmailVerificationHandler, RegistrationHandler, SES | Lambda generates verification token, sends email via SES, marks account as verified on click |
| **Req 9: Successful Login** | AuthLoginHandler, LoginComponent, AuthService, JWT Token Utility | Lambda validates credentials, generates JWT token, frontend stores token and redirects to home page |
| **Req 10: Invalid Credentials** | AuthLoginHandler, LoginComponent | Lambda returns 401 with error message, frontend displays "Invalid username or password" |
| **Req 23: Save Profile** | UpdateProfileHandler, ProfileComponent, ProfileService | Lambda validates and persists profile data, returns success message, frontend displays toast notification |
| **Req 24: Cancel Changes** | ProfileComponent | Frontend reverts form to originalProfile state, clears error messages |

### UI/UX Requirements (UI) Implementation

| Requirement | Design Components | Figma Reference | Implementation Details |
|-------------|-------------------|-----------------|------------------------|
| **Req 1: Registration Page Access** | RegistrationComponent | Registration Page - Desktop/Mobile/Tablet | React component with responsive layout, 450px max-width container, centered |
| **Req 8: Login Page Access** | LoginComponent | Login Page - Desktop/Mobile/Tablet | React component with responsive layout, 400px max-width container, centered |
| **Req 15: View Profile Page** | ProfileComponent | Profile Management Page | React component with 800px max-width, 2-column grid on desktop |
| **Req 16: Display Profile Fields** | ProfileComponent, GetProfileHandler | Profile - Form Fields | All 8 fields displayed with proper labels and input types |
| **Req 18: Title Field Behavior** | ProfileComponent | Profile - Title dropdown | Material-UI `Select` with 4 options (Mr, Ms, Mrs, Dr) |
| **Req 19: Gender Field Validation** | ProfileComponent | Profile - Gender radio buttons | Material-UI `RadioGroup` with 3 options (Male, Female, Other) |
| **Req 22: Preferences Selection** | ProfileComponent | Profile - Preferences checkboxes | Material-UI `Checkbox` group with 3 options, at least one required |
| **Req 25: Read Only Email Rule** | ProfileComponent, GetEmailPolicyHandler | Profile - Email read-only state | Conditionally set `disabled` or `readOnly` attribute based on policy response |

### Validation Requirements (VR) Implementation

| Requirement | Design Components | Validation Logic | Error Message |
|-------------|-------------------|------------------|---------------|
| **Req 3: Registration Password Complexity** | ValidationService, RegistrationHandler, RegistrationComponent | Regex: min 8 chars, uppercase, lowercase, digit, special char | "Password does not meet complexity requirements" |
| **Req 7: Registration Email Format Validation** | ValidationService, RegistrationHandler, RegistrationComponent | Regex: contains "@", domain part, no spaces | "Please enter a valid email address" |
| **Req 11: Mandatory Fields Validation** | ValidationService, LoginComponent | Check if email or password is empty | Login button disabled (no message) |
| **Req 12: Password Format Validation** | ValidationService, AuthLoginHandler, LoginComponent | Same as Req 3 | "Password does not meet complexity requirements" |
| **Req 13: Email Format Validation** | ValidationService, AuthLoginHandler, LoginComponent | Same as Req 7 | "Please enter a valid email address" |
| **Req 17: Mandatory Profile Fields** | ValidationService, UpdateProfileHandler, ProfileComponent | Check firstName, lastName, email, gender are non-empty | Field-specific error messages |
| **Req 19: Gender Field Validation** | ProfileComponent, UpdateProfileHandler | Check gender is selected | "Gender selection is mandatory" |
| **Req 20: Age Validation** | ValidationService, UpdateProfileHandler, ProfileComponent | Check age is numeric and 18 <= age <= 120 | "Age must be between 18 and 120" |
| **Req 21: Email Validation in Profile** | ValidationService, UpdateProfileHandler, ProfileComponent | Same as Req 7 | "Please enter a valid email address" |
| **Req 22: Preferences Selection** | ValidationService, UpdateProfileHandler, ProfileComponent | Check at least one preference is selected | "At least one preference is required" |

### Security Requirements (SR) Implementation

| Requirement | Design Components | Security Mechanism | Implementation Details |
|-------------|-------------------|-------------------|------------------------|
| **Req 2: Email Registration** | RegistrationHandler, Customer_Identity table | Unique email constraint, password hashing | Use BCrypt with salt rounds = 10, database unique constraint on email |
| **Req 3: Registration Password Complexity** | Password Hashing Utility, RegistrationHandler | BCrypt password hashing | Hash password before storing, never store plain text passwords |
| **Req 4: Social Login Registration** | OAuth2Handler, OAuth2 integration | OAuth2 authentication | Exchange authorization code for access token, retrieve user profile from provider |
| **Req 5: Duplicate Account Prevention** | RegistrationHandler, Customer_Identity unique constraint | Database unique constraint | Check for existing email before insert, return error if exists |
| **Req 6: Email Verification** | EmailVerificationHandler, Email service | Email verification token | Generate unique token, send via SES, mark account as verified on click |
| **Req 12: Password Format Validation** | Password Hashing Utility, AuthLoginHandler | BCrypt password verification | Verify password using BCrypt compare function |
| **Req 14: Account Locking** | LoginAttemptRepository, AuthLoginHandler | Failed attempt tracking and account locking | Track attempts in database, lock account for 30 minutes after 5 consecutive failures |

**Additional Security Measures:**
- JWT token authentication with secure storage (localStorage or sessionStorage)
- API Gateway rate limiting: 5-10 requests/second for public endpoints
- HTTPS enforcement for all API calls
- CSRF protection with tokens
- SQL injection prevention with parameterized queries
- XSS prevention with React's built-in sanitization
- Secrets Manager for database credentials, JWT secret, OAuth2 secrets
- CloudWatch logging for all security events (registration, login attempts, account locks, email verification)

### Data Requirements (DR) Implementation

| Requirement | Design Components | Database Tables | Implementation Details |
|-------------|-------------------|-----------------|------------------------|
| **Req 2: Email Registration** | RegistrationHandler, UserRepository | users (Customer_Identity) | Insert new user record with hashed password, email verification fields |
| **Req 16: Display Profile Fields** | GetProfileHandler, UserRepository | users, user_preferences | Query user by ID, join with preferences table |
| **Req 23: Save Profile** | UpdateProfileHandler, UserRepository | users, user_preferences | Update user record, delete and insert preferences |

**Database Schema:**
- `users` table: Stores user account and profile data with constraints (NOT NULL, CHECK, UNIQUE)
- `user_preferences` table: Stores user preferences with foreign key to users
- `login_attempts` table: Tracks authentication attempts for account locking
- `token_blacklist` table: Stores invalidated JWT tokens for logout
- Indexes: email, account_locked, locked_until, user_id, verification_token for performance

### Business Rules (BR) Implementation

| Requirement | Design Components | Business Logic | Configuration |
|-------------|-------------------|----------------|---------------|
| **Req 5: Duplicate Account Prevention** | RegistrationHandler | Check for existing email before creating account | Database unique constraint + application-level check |
| **Req 17: Mandatory Profile Fields** | UpdateProfileHandler | Validate firstName, lastName, email, gender are non-empty | Hard-coded validation in ProfileUpdateRequest.validate() |
| **Req 20: Age Validation** | UpdateProfileHandler | Validate age range 18-120 | Hard-coded validation in ProfileUpdateRequest.validate() |
| **Req 25: Read Only Email Rule** | GetEmailPolicyHandler | Return email modification policy | Environment variable EMAIL_MODIFICATION_ALLOWED |

## Implementation Priority by Requirement Type

### Phase 1: Infrastructure & Security (Week 1)
**Priority**: Critical  
**Requirements**: Req 3 (SR), Req 5 (BR+SR), Req 14 (SR)

- Set up AWS infrastructure (Task 1)
- Create database schema with Customer_Identity table (Task 2)
- Implement password hashing utility (Task 3.2)
- Implement JWT token utility (Task 3.3)
- Implement account locking logic (Task 4.2, 5.3)
- Set up SES for email sending (Task 1)

### Phase 2: Registration & Email Verification (Week 2)
**Priority**: High  
**Requirements**: Req 1 (UI), Req 2 (FR+SR), Req 3 (SR+VR), Req 6 (FR+SR), Req 7 (VR)

- Implement RegistrationHandler (Task TBD)
- Implement EmailVerificationHandler (Task TBD)
- Implement RegistrationComponent (Task TBD)
- Implement ValidationService for registration (Task TBD)
- Configure API Gateway registration endpoints (Task TBD)

### Phase 3: Social Login Integration (Week 3)
**Priority**: High  
**Requirements**: Req 4 (FR+SR)

- Implement OAuth2Handler (Task TBD)
- Implement OAuth2Service (Task TBD)
- Implement SocialLoginComponent (Task TBD)
- Configure Google and Amazon OAuth2 (Task TBD)
- Configure API Gateway OAuth2 endpoints (Task TBD)

### Phase 4: Core Authentication (Week 4)
**Priority**: High  
**Requirements**: Req 8 (UI), Req 9 (FR), Req 10 (FR), Req 11 (VR), Req 13 (VR)

- Implement AuthLoginHandler (Task 5)
- Implement LoginComponent (Task 12)
- Implement ValidationService for login (Task 11.2)
- Configure API Gateway login endpoint (Task 9.2)

### Phase 5: Validation Layer (Week 5)
**Priority**: High  
**Requirements**: Req 12 (VR), Req 17 (VR+BR), Req 20 (VR+BR), Req 21 (VR), Req 22 (VR)

- Implement all validation utilities (Task 3.4)
- Write property tests for validation (Task 3.5, 3.6, 3.7)
- Implement client-side validation in components (Task 12.2, 13.3)

### Phase 6: Profile Management (Week 6)
**Priority**: High  
**Requirements**: Req 15-25 (UI, VR, FR, DR, BR)

- Implement GetProfileHandler (Task 6)
- Implement UpdateProfileHandler (Task 7)
- Implement ProfileComponent (Task 13)
- Implement GetEmailPolicyHandler (Task 8.2)
- Configure API Gateway profile endpoints (Task 9.4, 9.5)

### Phase 7: Testing & Deployment (Week 7)
**Priority**: Medium  
**Requirements**: All requirements

- Write unit tests (Task 4.3, 5.5, 6.3, 7.7, 11.5, 12.5, 13.7)
- Write property tests (Task 5.6, 5.7, 7.4, 7.5, 7.6, 12.4, 13.6)
- Integration testing (Task 16)
- Deployment pipeline (Task 15)

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
- [ ] All unit tests pass
- [ ] No critical or high severity bugs
- [ ] SonarQube quality gate passed

### UI/UX Compliance
- [ ] Pixel-perfect match with Figma designs
- [ ] All responsive breakpoints implemented (Mobile, Tablet, Desktop)
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
- [ ] API Gateway rate limiting configured
- [ ] All security events logged to CloudWatch

### Performance Targets
- [ ] Lambda cold start < 3 seconds
- [ ] API response time < 500ms (p95)
- [ ] Database query time < 100ms (p95)
- [ ] Frontend page load < 2 seconds
- [ ] Email delivery < 5 seconds

### Deployment Readiness
- [ ] Infrastructure as Code (AWS CDK) complete
- [ ] CI/CD pipeline configured and working
- [ ] Environment variables configured
- [ ] SES configured and verified
- [ ] OAuth2 credentials configured
- [ ] Monitoring and alerts set up
- [ ] Documentation complete

### Registration & Verification Specific
- [ ] Registration form validates all fields correctly
- [ ] Password complexity requirements displayed and validated
- [ ] Duplicate email detection working
- [ ] Verification email sent successfully
- [ ] Email verification link working
- [ ] Unverified users cannot log in
- [ ] Social login creates or links accounts correctly

---

## Figma-to-Code Implementation Guide

### Step 1: Extract Design Tokens from Figma

Use Figma Inspect panel to extract exact values:

**Colors (from Figma design system):**
```typescript
// src/styles/designTokens.ts
export const colors = {
  primary: '#1976D2',
  primaryDark: '#1565C0',
  primaryLight: '#42A5F5',
  accent: '#FF9800',
  error: '#D32F2F',
  success: '#388E3C',
  warning: '#F57C00',
  textPrimary: '#212121',
  textSecondary: '#757575',
  textDisabled: '#BDBDBD',
  background: '#FAFAFA',
  surface: '#FFFFFF',
  divider: '#E0E0E0',
  googleBlue: '#4285F4',
  amazonOrange: '#FF9900',
};
```

**Typography (from Figma design system):**
```typescript
// src/styles/designTokens.ts
export const typography = {
  fontFamily: 'Roboto, sans-serif',
  
  // Headings
  h1: {
    size: '32px',
    weight: 500,
    lineHeight: '40px',
  },
  h2: {
    size: '24px',
    weight: 500,
    lineHeight: '32px',
  },
  
  // Body
  body: {
    size: '16px',
    weight: 400,
    lineHeight: '24px',
  },
  
  // Labels
  label: {
    size: '14px',
    weight: 500,
    lineHeight: '20px',
  },
  
  // Captions
  caption: {
    size: '12px',
    weight: 400,
    lineHeight: '16px',
  },
};
```

**Spacing (from Figma design system):**
```typescript
// src/styles/designTokens.ts
export const spacing = {
  xs: 4,   // 4px
  sm: 8,   // 8px
  md: 16,  // 16px
  lg: 24,  // 24px
  xl: 32,  // 32px
  xxl: 48, // 48px
};
```

### Step 2: Configure Material-UI Theme

Map Figma colors to Material-UI theme:

```typescript
// src/theme.ts
import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976D2',
      dark: '#1565C0',
      light: '#42A5F5',
    },
    secondary: {
      main: '#FF9800',
    },
    error: {
      main: '#D32F2F',
    },
    success: {
      main: '#388E3C',
    },
    warning: {
      main: '#F57C00',
    },
    text: {
      primary: '#212121',
      secondary: '#757575',
      disabled: '#BDBDBD',
    },
    background: {
      default: '#FAFAFA',
      paper: '#FFFFFF',
    },
    divider: '#E0E0E0',
  },
  typography: {
    fontFamily: 'Roboto, sans-serif',
    h1: {
      fontSize: '32px',
      fontWeight: 500,
      lineHeight: '40px',
    },
    h2: {
      fontSize: '24px',
      fontWeight: 500,
      lineHeight: '32px',
    },
    body1: {
      fontSize: '16px',
      fontWeight: 400,
      lineHeight: '24px',
    },
    body2: {
      fontSize: '14px',
      fontWeight: 500,
      lineHeight: '20px',
    },
    caption: {
      fontSize: '12px',
      fontWeight: 400,
      lineHeight: '16px',
    },
  },
  spacing: 4, // Base spacing unit (4px)
  shape: {
    borderRadius: 4,
  },
});

export default theme;
```

### Step 3: Quality Checklist for Figma-to-Code

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
- [ ] Social login buttons match brand guidelines
- [ ] Password requirements display matches Figma
- [ ] Accessibility requirements met (WCAG AA color contrast, keyboard navigation)
