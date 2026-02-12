# Profile Management Backend Implementation

## Overview
This document describes the backend implementation for profile management functionality.

## Implemented Components

### 1. Model Classes

#### Entity
- **UserEntity.java** - Database entity representing users table
  - Maps to `users` (Customer_Identity) table
  - Contains all profile fields: id, title, firstName, lastName, gender, age, email, address, etc.

#### DTOs
- **UserProfileDTO.java** - Data transfer object for profile responses
  - Contains profile fields and preferences list
  - Used for GET /profile responses

- **ProfileUpdateRequest.java** - Request DTO for profile updates
  - Contains all updatable profile fields
  - Used for PUT /profile requests

- **ApiResponse.java** - Standard API response wrapper
  - Provides consistent response format
  - Includes success and error response builders

### 2. Exception Classes

- **ProfileNotFoundException.java** - Thrown when profile not found (404)
- **ValidationException.java** - Thrown when validation fails (400)
  - Includes field-specific error messages

### 3. Validators

- **EmailValidator.java** - Validates email format
  - Regex pattern: `^[^\s@]+@[^\s@]+\.[^\s@]+$`
  - Requirements: Req 7, 13, 21

- **AgeValidator.java** - Validates age range (18-120)
  - Requirements: Req 20

- **ProfileValidator.java** - Validates complete profile update requests
  - Validates mandatory fields (firstName, lastName, email, gender)
  - Validates email format
  - Validates gender selection (Male, Female, Other)
  - Validates age range
  - Validates preferences (at least one required)
  - Validates title (optional: Mr, Ms, Mrs, Dr)
  - Requirements: Req 17, 19, 20, 21, 22

### 4. Utilities

- **DatabaseUtil.java** - Database connection management
  - Creates connections with RDS Proxy support
  - Handles transactions (commit, rollback)
  - Manages connection lifecycle

### 5. Repository

- **UserRepository.java** - Data access layer for user profiles
  - `findByIdWithPreferences(Long userId)` - Retrieves user profile
  - `getUserPreferences(Long userId)` - Gets user preferences list
  - `updateProfile(UserEntity user)` - Updates user profile
  - `updatePreferences(Long userId, List<String> preferences)` - Updates preferences
  - Uses JDBC with PreparedStatements for SQL injection prevention

### 6. Lambda Handlers

#### GetProfileHandler.java
- **Endpoint**: GET /profile
- **Requirements**: Req 15 (View Profile), Req 16 (Display Fields)
- **Functionality**:
  - Extracts user ID from JWT token (via API Gateway authorizer)
  - Retrieves user profile from database
  - Retrieves user preferences
  - Returns profile data as JSON
- **Response Codes**:
  - 200: Success with profile data
  - 404: Profile not found
  - 500: Internal server error

#### UpdateProfileHandler.java
- **Endpoint**: PUT /profile
- **Requirements**: Req 17-23 (Profile validation and update)
- **Functionality**:
  - Extracts user ID from JWT token
  - Parses profile update request from body
  - Validates all fields using ProfileValidator
  - Updates user profile in database
  - Updates user preferences
  - Commits transaction
- **Response Codes**:
  - 200: Success with "Profile updated successfully" message
  - 400: Validation error with field-specific errors
  - 404: Profile not found
  - 500: Internal server error

#### GetEmailPolicyHandler.java
- **Endpoint**: GET /profile/email-policy
- **Requirements**: Req 25 (Read Only Email Rule)
- **Functionality**:
  - Reads EMAIL_MODIFICATION_ALLOWED environment variable
  - Returns policy configuration
  - Caches response for 1 hour
- **Response Codes**:
  - 200: Success with policy data
  - 500: Internal server error

## Environment Variables Required

### Database Configuration
- `DB_URL` - Database connection URL (e.g., jdbc:postgresql://host:5432/dbname)
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password

### Email Policy Configuration
- `EMAIL_MODIFICATION_ALLOWED` - Whether users can modify email (default: true)

## API Endpoints

### GET /profile
Retrieves user profile data.

**Request**:
- Headers: `Authorization: Bearer <JWT_TOKEN>`
- Path/Query: `userId` (for testing, in production extracted from JWT)

**Response** (200 OK):
```json
{
  "status": "SUCCESS",
  "data": {
    "id": 123,
    "title": "Mr",
    "firstName": "John",
    "lastName": "Doe",
    "gender": "Male",
    "age": 30,
    "email": "john.doe@example.com",
    "address": "123 Main St",
    "preferences": ["Email Notifications", "SMS Notifications"]
  }
}
```

### PUT /profile
Updates user profile data.

**Request**:
- Headers: `Authorization: Bearer <JWT_TOKEN>`
- Path/Query: `userId` (for testing)
- Body:
```json
{
  "title": "Mr",
  "firstName": "John",
  "lastName": "Doe",
  "gender": "Male",
  "age": 30,
  "email": "john.doe@example.com",
  "address": "123 Main St",
  "preferences": ["Email Notifications", "SMS Notifications"]
}
```

**Response** (200 OK):
```json
{
  "status": "SUCCESS",
  "data": {
    "message": "Profile updated successfully",
    "userId": "123"
  }
}
```

**Response** (400 Bad Request - Validation Error):
```json
{
  "status": "ERROR",
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "fieldErrors": {
      "firstName": "First Name is required",
      "age": "Age must be between 18 and 120"
    },
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### GET /profile/email-policy
Retrieves email modification policy.

**Request**:
- Headers: `Authorization: Bearer <JWT_TOKEN>`

**Response** (200 OK):
```json
{
  "status": "SUCCESS",
  "data": {
    "emailModificationAllowed": true
  }
}
```

## Validation Rules

### Mandatory Fields
- First Name (required, non-empty)
- Last Name (required, non-empty)
- Email (required, valid format)
- Gender (required, one of: Male, Female, Other)

### Optional Fields
- Title (if provided, must be one of: Mr, Ms, Mrs, Dr)
- Age (if provided, must be 18-120)
- Address (optional)

### Preferences
- At least one preference must be selected
- Valid preferences: Email Notifications, SMS Notifications, App Notifications

### Email Format
- Pattern: `name@domain.com`
- Must contain "@" and domain
- Must not contain spaces

## Error Handling

All handlers implement consistent error handling:
- Validation errors return 400 with field-specific errors
- Not found errors return 404
- Internal errors return 500
- All errors include error code, message, and timestamp
- Database transactions are rolled back on errors

## Logging

All components use SLF4J for logging:
- INFO: Normal operations (profile retrieved, updated)
- WARN: Business logic warnings (profile not found)
- ERROR: Exceptions and errors

## Security

- JWT token validation handled by API Gateway authorizer
- SQL injection prevention via PreparedStatements
- Input validation on all fields
- Transaction management for data consistency
- CORS headers configured for cross-origin requests

## Next Steps

1. **Database Setup**: Create database schema (see database migration scripts)
2. **AWS Infrastructure**: Deploy Lambda functions and API Gateway
3. **Testing**: Unit tests and integration tests
4. **Monitoring**: CloudWatch logs and metrics
