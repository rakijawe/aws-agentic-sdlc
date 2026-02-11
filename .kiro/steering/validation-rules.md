---
inclusion: always
---

# Validation Rules

This steering file defines all validation rules and error messages for the application.

## Email Validation

### Format Rules
- Pattern: `name@domain.com`
- Must contain "@" symbol
- Must have domain part after "@"
- Must not contain spaces
- Case-insensitive

### Error Message
"Please enter a valid email address"

### Implementation
```regex
^[^\s@]+@[^\s@]+\.[^\s@]+$
```

## Password Validation

### Complexity Requirements
- Minimum length: 8 characters
- At least 1 uppercase letter (A-Z)
- At least 1 lowercase letter (a-z)
- At least 1 numeric digit (0-9)
- At least 1 special character (!@#$%^&*()_+-=[]{}|;:,.<>?)

### Error Message
"Password does not meet complexity requirements"

### Implementation Guidelines
- Validate on client-side for immediate feedback
- Re-validate on server-side for security
- Show password strength indicator
- Provide clear requirements before user starts typing

## Age Validation

### Range Rules
- Minimum: 18
- Maximum: 120
- Must be numeric integer

### Error Message
"Age must be between 18 and 120"

### Implementation
- Use numeric input type
- Set min/max attributes
- Validate on blur and submit

## Mandatory Field Validation

### Login Page
- Email ID: Required
- Password: Required
- Disable submit button when either field is empty

### Profile Page
- First Name: Required
- Last Name: Required
- Email: Required
- Gender: Required
- At least one Preference: Required

### Error Messages
- Generic: "This field is required"
- Specific: "Gender selection is mandatory"

## General Validation Principles

### Client-Side Validation
- Provide immediate feedback
- Validate on blur (field exit)
- Validate on submit
- Show inline error messages
- Use appropriate input types and attributes

### Server-Side Validation
- Always validate on server (never trust client)
- Return clear error messages
- Use HTTP 400 for validation errors
- Return field-specific error details

### Error Message Display
- Show errors inline near the field
- Use red color for error text
- Add error icon for visual clarity
- Ensure errors are accessible (ARIA)
- Clear errors when user corrects input

### Validation Timing
- On blur: Validate individual fields
- On submit: Validate entire form
- Real-time: For password strength, character count
- Debounced: For async validations (email uniqueness)

## Implementation Best Practices

- Use validation library (Yup, Joi, Zod, etc.)
- Define validation schemas centrally
- Reuse validation logic between client and server
- Provide helpful error messages
- Support internationalization for error messages
- Log validation failures for monitoring
