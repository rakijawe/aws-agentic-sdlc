---
inclusion: always
---

# Authentication & Login Standards

This steering file defines the authentication and login requirements for the application.

## Login Page Requirements

### Access
- Provide a Login page accessible to all users
- Login page must be the entry point for unauthenticated users

### Required Fields
- Email ID (text input)
- Password (password input)
- Login button

### Authentication Flow

#### Successful Login
When user enters valid credentials and clicks Login:
- Authenticate the user
- Redirect to Home page

#### Invalid Credentials
When user enters invalid Email ID or Password:
- Display error message: "Invalid username or password"
- Do not reveal which field is incorrect (security best practice)

### Field Validation

#### Email Format
- Must follow pattern: `name@domain.com`
- Must contain "@" and domain
- Must not contain spaces
- Show error: "Please enter a valid email address" for invalid format

#### Password Policy
Password must contain:
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one numeric digit
- At least one special character

Show error: "Password does not meet complexity requirements" when policy is violated

### Button State Management
- Disable Login button while Email ID or Password field is blank
- Enable Login button only when both fields have values

### Security: Account Locking
- Lock user account after 5 consecutive failed login attempts
- Lock duration: 30 minutes
- Display appropriate message when account is locked

## Implementation Guidelines

- Use secure password hashing (bcrypt, argon2)
- Implement rate limiting on login endpoint
- Log authentication attempts for security monitoring
- Use HTTPS for all authentication requests
- Implement CSRF protection
- Store session tokens securely
