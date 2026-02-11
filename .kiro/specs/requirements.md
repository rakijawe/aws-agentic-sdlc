# Requirements Document

## Introduction

This document specifies the requirements for a user authentication and profile management system as part of the REXX modernization initiative. The system provides secure login functionality with validation and account protection, along with comprehensive profile management capabilities for authenticated users. This system replaces legacy REXX authentication and profile management modules with a modern Java backend and React frontend.

## Figma Design Reference

**Design File**: #[[figma:https://www.figma.com/design/GGoFL7U4ljuiJxfQ1VBBbi/POC?node-id=1-1077&t=jPWNYDTKebx4Ygd4-1]]

### Design Resources
- **Login Page Design**: Figma frame "Login - Desktop/Mobile/Tablet"
- **Profile Page Design**: Figma frame "Profile Management - Desktop/Mobile/Tablet"
- **Component Library**: Design system components for forms, buttons, inputs
- **Interactive Prototype**: User flow demonstrations

### Implementation Notes
- All UI components should match Figma designs pixel-perfect
- Extract colors, typography, and spacing from Figma Inspect panel
- Use Material-UI (MUI) components mapped to Figma design system
- Implement responsive layouts as shown in Figma breakpoints (Mobile: 375px, Tablet: 768px, Desktop: 1440px)

## Requirement Types Classification

This specification includes the following types of requirements:

- **Functional Requirements (FR)**: Core business functionality and user interactions
- **UI/UX Requirements (UI)**: User interface design, layout, and user experience
- **Validation Requirements (VR)**: Input validation and data integrity rules
- **Security Requirements (SR)**: Authentication, authorization, and security controls
- **Data Requirements (DR)**: Data storage, retrieval, and management
- **Business Rules (BR)**: Business logic and policy enforcement
- **Performance Requirements (PR)**: System performance and responsiveness expectations

## Glossary

- **System**: The user authentication and profile management application
- **User**: Any person attempting to access or use the application
- **Authenticated_User**: A user who has successfully logged in
- **Login_Page**: The page where users enter credentials to access the system
- **Profile_Page**: The page where authenticated users view and edit their profile information
- **Email_ID**: The user's email address used for authentication and identification
- **Password**: The secret credential used for authentication
- **Profile**: The collection of user information including personal details and preferences
- **Account_Lock**: A security mechanism that temporarily prevents login attempts after multiple failed authentication attempts
- **Preference**: A user-configurable setting for notifications or system behavior (Email Notifications, SMS Notifications, App Notifications)
- **Home_Page**: The main application page displayed after successful authentication

## Requirements

### Requirement 1: Login Page Access
**Type**: UI/UX Requirement (UI)  
**Figma Reference**: Login Page - Desktop/Mobile/Tablet frames

**User Story:** As a user, I want to access a login page, so that I can authenticate and access the system.

#### Acceptance Criteria

1. THE System SHALL provide a Login_Page to all users

### Requirement 2: Successful Login
**Type**: Functional Requirement (FR)  
**Figma Reference**: Login Page - Success flow, Home Page redirect

**User Story:** As a user, I want to log in with valid credentials, so that I can access my account and be redirected to the home page.

#### Acceptance Criteria

1. WHEN a user enters a valid Email_ID and Password and clicks the Login button, THE System SHALL authenticate the user and redirect the user to the Home_Page

### Requirement 3: Invalid Credentials
**Type**: Functional Requirement (FR)  
**Figma Reference**: Login Page - Error states

**User Story:** As a user, I want to receive clear feedback when I enter invalid credentials, so that I know my login attempt failed.

#### Acceptance Criteria

1. WHEN a user enters an invalid Email_ID or Password and clicks the Login button, THE System SHALL display the message "Invalid username or password"

### Requirement 4: Mandatory Fields Validation
**Type**: Validation Requirement (VR)  
**Figma Reference**: Login Page - Button disabled state

**User Story:** As a user, I want the login button to be disabled when required fields are empty, so that I don't submit incomplete forms.

#### Acceptance Criteria

1. WHILE the Email_ID field or Password field is blank, THE System SHALL disable the Login button

### Requirement 5: Password Format Validation
**Type**: Security Requirement (SR) + Validation Requirement (VR)  
**Figma Reference**: Login Page - Password field with validation error state

**User Story:** As a user, I want to receive feedback when my password doesn't meet security requirements, so that I can create a secure password.

#### Acceptance Criteria

1. WHEN a user enters a password that does not meet the password policy, THE System SHALL display the message "Password does not meet complexity requirements"

**Business Rules for Password:**
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one numeric digit
- At least one special character

### Requirement 6: Email Format Validation
**Type**: Validation Requirement (VR)  
**Figma Reference**: Login Page - Email field with validation error state

**User Story:** As a user, I want to receive feedback when my email format is invalid, so that I can correct it.

#### Acceptance Criteria

1. WHEN a user enters an Email_ID in an invalid format, THE System SHALL display the message "Please enter a valid email address"

**Business Rule:**
- Format: `name@domain.com`
- Must contain "@" and domain
- Must not contain spaces

### Requirement 7: Account Locking
**Type**: Security Requirement (SR)  
**Figma Reference**: Login Page - Account locked error state

**User Story:** As a system administrator, I want accounts to be locked after multiple failed login attempts, so that the system is protected from brute force attacks.

#### Acceptance Criteria

1. WHEN a user enters incorrect credentials more than 5 times consecutively, THE System SHALL lock the user account for 30 minutes

### Requirement 8: View Profile Page
**Type**: UI/UX Requirement (UI)  
**Figma Reference**: Profile Management Page - Desktop/Mobile/Tablet frames

**User Story:** As an authenticated user, I want to access my profile page, so that I can view and manage my personal information.

#### Acceptance Criteria

1. THE System SHALL provide a Profile_Page to all Authenticated_Users

### Requirement 9: Display Profile Fields
**Type**: UI/UX Requirement (UI) + Data Requirement (DR)  
**Figma Reference**: Profile Management Page - Form layout with all fields

**User Story:** As an authenticated user, I want to see all my profile fields, so that I can review and update my information.

#### Acceptance Criteria

1. THE System SHALL display the following fields on the Profile_Page: Title, First Name, Last Name, Gender, Age, Email_ID, Address, and Preferences

### Requirement 10: Mandatory Profile Fields
**Type**: Validation Requirement (VR) + Business Rule (BR)  
**Figma Reference**: Profile Management Page - Required field indicators (asterisks)

**User Story:** As a system administrator, I want to enforce mandatory profile fields, so that we maintain complete user records.

#### Acceptance Criteria

1. WHILE a user is saving the profile, THE System SHALL ensure that the following fields are mandatory: First Name, Last Name, Email_ID, and Gender

### Requirement 11: Title Field Behavior
**Type**: UI/UX Requirement (UI)  
**Figma Reference**: Profile Management Page - Title dropdown component

**User Story:** As an authenticated user, I want to select my title from predefined options, so that I can specify my preferred form of address.

#### Acceptance Criteria

1. THE System SHALL display Title as a dropdown with the following options: Mr, Ms, Mrs, Dr

### Requirement 12: Gender Field Validation
**Type**: UI/UX Requirement (UI) + Validation Requirement (VR)  
**Figma Reference**: Profile Management Page - Gender radio button group

**User Story:** As an authenticated user, I want to select my gender from predefined options, so that I can specify my gender identity.

#### Acceptance Criteria

1. THE System SHALL display Gender as radio button options with the values: Male, Female, Other
2. WHEN a user selects an invalid or blank Gender option, THE System SHALL display the message "Gender selection is mandatory"

### Requirement 13: Age Validation
**Type**: Validation Requirement (VR) + Business Rule (BR)  
**Figma Reference**: Profile Management Page - Age numeric input with validation

**User Story:** As a system administrator, I want to validate that users are within an acceptable age range, so that we comply with age restrictions.

#### Acceptance Criteria

1. WHEN a user enters Age less than 18 or greater than 120, THE System SHALL display the message "Age must be between 18 and 120"

**Business Rule:**
- Age must be numeric
- Allowed range: 18 – 120

### Requirement 14: Email Validation in Profile
**Type**: Validation Requirement (VR)  
**Figma Reference**: Profile Management Page - Email field with validation error state

**User Story:** As an authenticated user, I want to receive validation feedback when updating my email, so that I ensure it's in the correct format.

#### Acceptance Criteria

1. WHEN a user updates the Email_ID field with an invalid email format, THE System SHALL display the message "Please enter a valid email address"

### Requirement 15: Preferences Selection
**Type**: UI/UX Requirement (UI) + Validation Requirement (VR)  
**Figma Reference**: Profile Management Page - Preferences checkbox group

**User Story:** As an authenticated user, I want to select my notification preferences, so that I can control how the system communicates with me.

#### Acceptance Criteria

1. THE System SHALL display Preferences as a dropdown or checkbox list with three options
2. WHILE saving the profile, THE System SHALL ensure that at least one preference option is selected

**Example preference options:**
- Email Notifications
- SMS Notifications
- App Notifications

### Requirement 16: Save Profile
**Type**: Functional Requirement (FR) + Data Requirement (DR)  
**Figma Reference**: Profile Management Page - Save button and success message

**User Story:** As an authenticated user, I want to save my profile changes, so that my updated information is persisted.

#### Acceptance Criteria

1. WHEN a user clicks the Save button after entering valid profile details, THE System SHALL save the updated profile information and display the message "Profile updated successfully"

### Requirement 17: Cancel Changes
**Type**: Functional Requirement (FR)  
**Figma Reference**: Profile Management Page - Cancel button behavior

**User Story:** As an authenticated user, I want to cancel my profile changes, so that I can discard unwanted modifications.

#### Acceptance Criteria

1. WHEN a user clicks the Cancel button, THE System SHALL discard all unsaved changes and reload the last saved profile data

### Requirement 18: Read Only Email Rule
**Type**: Business Rule (BR) + UI/UX Requirement (UI)  
**Figma Reference**: Profile Management Page - Email field read-only state

**User Story:** As a system administrator, I want to control whether users can modify their email addresses, so that we can enforce organizational policies.

#### Acceptance Criteria

1. THE System SHALL display Email_ID as read-only if the organization policy restricts email modification

---

## Requirement Type Mapping

This section provides a comprehensive mapping of requirements to their types and the tasks that implement them.

### Functional Requirements (FR)
Requirements that define core business functionality and user interactions:

| Requirement ID | Requirement Name | Related Tasks |
|----------------|------------------|---------------|
| Requirement 2 | Successful Login | Task 5 (AuthLoginHandler), Task 12 (LoginComponent) |
| Requirement 3 | Invalid Credentials | Task 5 (AuthLoginHandler), Task 12 (LoginComponent) |
| Requirement 16 | Save Profile | Task 7 (UpdateProfileHandler), Task 13 (ProfileComponent) |
| Requirement 17 | Cancel Changes | Task 13 (ProfileComponent) |

### UI/UX Requirements (UI)
Requirements that define user interface design, layout, and user experience:

| Requirement ID | Requirement Name | Related Tasks |
|----------------|------------------|---------------|
| Requirement 1 | Login Page Access | Task 12 (LoginComponent) |
| Requirement 8 | View Profile Page | Task 13 (ProfileComponent) |
| Requirement 9 | Display Profile Fields | Task 13 (ProfileComponent) |
| Requirement 11 | Title Field Behavior | Task 13 (ProfileComponent) |
| Requirement 12 | Gender Field Validation | Task 13 (ProfileComponent) |
| Requirement 15 | Preferences Selection | Task 13 (ProfileComponent) |
| Requirement 18 | Read Only Email Rule | Task 8 (GetEmailPolicyHandler), Task 13 (ProfileComponent) |

### Validation Requirements (VR)
Requirements that define input validation and data integrity rules:

| Requirement ID | Requirement Name | Related Tasks |
|----------------|------------------|---------------|
| Requirement 4 | Mandatory Fields Validation | Task 11 (ValidationService), Task 12 (LoginComponent) |
| Requirement 5 | Password Format Validation | Task 3 (Validation utilities), Task 11 (ValidationService), Task 12 (LoginComponent) |
| Requirement 6 | Email Format Validation | Task 3 (Validation utilities), Task 11 (ValidationService), Task 12 (LoginComponent) |
| Requirement 10 | Mandatory Profile Fields | Task 7 (UpdateProfileHandler), Task 13 (ProfileComponent) |
| Requirement 12 | Gender Field Validation | Task 7 (UpdateProfileHandler), Task 13 (ProfileComponent) |
| Requirement 13 | Age Validation | Task 3 (Validation utilities), Task 7 (UpdateProfileHandler), Task 13 (ProfileComponent) |
| Requirement 14 | Email Validation in Profile | Task 7 (UpdateProfileHandler), Task 13 (ProfileComponent) |
| Requirement 15 | Preferences Selection | Task 7 (UpdateProfileHandler), Task 13 (ProfileComponent) |

### Security Requirements (SR)
Requirements that define authentication, authorization, and security controls:

| Requirement ID | Requirement Name | Related Tasks |
|----------------|------------------|---------------|
| Requirement 5 | Password Format Validation | Task 3 (Password hashing utility), Task 5 (AuthLoginHandler) |
| Requirement 7 | Account Locking | Task 4 (LoginAttemptRepository), Task 5 (AuthLoginHandler) |

### Data Requirements (DR)
Requirements that define data storage, retrieval, and management:

| Requirement ID | Requirement Name | Related Tasks |
|----------------|------------------|---------------|
| Requirement 9 | Display Profile Fields | Task 2 (Database schema), Task 6 (GetProfileHandler) |
| Requirement 16 | Save Profile | Task 2 (Database schema), Task 7 (UpdateProfileHandler) |

### Business Rules (BR)
Requirements that define business logic and policy enforcement:

| Requirement ID | Requirement Name | Related Tasks |
|----------------|------------------|---------------|
| Requirement 10 | Mandatory Profile Fields | Task 7 (UpdateProfileHandler) |
| Requirement 13 | Age Validation | Task 7 (UpdateProfileHandler) |
| Requirement 18 | Read Only Email Rule | Task 8 (GetEmailPolicyHandler) |

### Performance Requirements (PR)
Requirements that define system performance and responsiveness expectations:

| Requirement ID | Requirement Name | Related Tasks |
|----------------|------------------|---------------|
| N/A | Response Time | Task 1 (Infrastructure setup), Task 9 (API Gateway configuration) |
| N/A | Scalability | Task 1 (AWS Lambda, RDS Proxy), Task 15 (Deployment pipeline) |

---

## Requirements Traceability Matrix

This matrix shows the relationship between requirements, design components, and implementation tasks:

| Requirement | Type | Design Component | Implementation Tasks | Test Tasks |
|-------------|------|------------------|---------------------|------------|
| Req 1 | UI | LoginComponent | Task 12.1 | Task 12.5 |
| Req 2 | FR | AuthLoginHandler, LoginComponent | Task 5.1-5.4, Task 12.3 | Task 5.5, Task 12.5 |
| Req 3 | FR | AuthLoginHandler, LoginComponent | Task 5.4, Task 12.3 | Task 5.6, Task 12.5 |
| Req 4 | VR | ValidationService, LoginComponent | Task 11.2, Task 12.2 | Task 12.4, Task 12.5 |
| Req 5 | SR+VR | ValidationService, AuthLoginHandler | Task 3.2, Task 3.4, Task 11.2 | Task 3.6, Task 11.5 |
| Req 6 | VR | ValidationService, LoginComponent | Task 3.4, Task 11.2, Task 12.2 | Task 3.5, Task 11.5 |
| Req 7 | SR | LoginAttemptRepository, AuthLoginHandler | Task 4.2, Task 5.3 | Task 5.7 |
| Req 8 | UI | ProfileComponent | Task 13.1 | Task 13.7 |
| Req 9 | UI+DR | ProfileComponent, GetProfileHandler | Task 6.2, Task 13.1 | Task 6.3, Task 13.7 |
| Req 10 | VR+BR | UpdateProfileHandler, ProfileComponent | Task 7.2, Task 13.3 | Task 7.4, Task 13.7 |
| Req 11 | UI | ProfileComponent | Task 13.1 | Task 13.7 |
| Req 12 | UI+VR | ProfileComponent, UpdateProfileHandler | Task 7.2, Task 13.3 | Task 7.4, Task 13.7 |
| Req 13 | VR+BR | ValidationService, UpdateProfileHandler | Task 3.4, Task 7.2 | Task 3.7, Task 7.7 |
| Req 14 | VR | ValidationService, UpdateProfileHandler | Task 3.4, Task 7.2 | Task 3.5, Task 7.7 |
| Req 15 | UI+VR | ProfileComponent, UpdateProfileHandler | Task 7.2, Task 13.3 | Task 7.5, Task 13.7 |
| Req 16 | FR+DR | UpdateProfileHandler, ProfileComponent | Task 7.3, Task 13.4 | Task 7.6, Task 13.7 |
| Req 17 | FR | ProfileComponent | Task 13.5 | Task 13.6, Task 13.7 |
| Req 18 | BR+UI | GetEmailPolicyHandler, ProfileComponent | Task 8.2, Task 13.2 | Task 8.3, Task 13.7 |

---

## Implementation Guidelines by Requirement Type

### For Functional Requirements (FR)
- Implement business logic in Lambda handlers (backend) and services (frontend)
- Follow REST API standards with proper HTTP status codes
- Ensure proper error handling and logging
- Write unit tests for all business logic paths

### For UI/UX Requirements (UI)
- Reference Figma designs for pixel-perfect implementation
- Use Material-UI (MUI) components mapped to Figma design system
- Extract colors, typography, and spacing from Figma Inspect
- Implement responsive layouts for all breakpoints (Mobile, Tablet, Desktop)
- Test UI on all supported browsers and devices

### For Validation Requirements (VR)
- Implement validation on both client-side (React) and server-side (Lambda)
- Use consistent error messages across client and server
- Write property-based tests for validation logic
- Display inline error messages as shown in Figma error states

### For Security Requirements (SR)
- Use BCrypt for password hashing (never store plain text passwords)
- Implement rate limiting at API Gateway level
- Use JWT tokens for authentication with secure storage
- Log all security events (login attempts, account locks) to CloudWatch
- Follow OWASP security best practices

### For Data Requirements (DR)
- Design database schema with proper constraints and indexes
- Use parameterized queries to prevent SQL injection
- Implement proper connection pooling with RDS Proxy
- Handle database errors gracefully with retry logic

### For Business Rules (BR)
- Centralize business rules in validation utilities and Lambda handlers
- Document business rules clearly in code comments
- Make business rules configurable via environment variables where appropriate
- Write unit tests specifically for business rule validation

### For Performance Requirements (PR)
- Use AWS Lambda for auto-scaling
- Implement connection pooling with RDS Proxy
- Set appropriate API Gateway throttling limits
- Monitor performance with CloudWatch metrics
- Optimize database queries with proper indexing
