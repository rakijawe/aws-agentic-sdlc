# User Stories

## 1. Secure Onboarding & Identity

### User Story
"As a new customer, I want to register for an account using my email or social login so that I can securely access personalized services and save my details for future use."

### Requirement ID
REQ-AUTH-01

### EARS Requirement
WHEN a user submits the registration form with a unique email and valid password, THE system shall create a new record in the Customer_Identity table and trigger a verification email.

### Acceptance Criteria
- Password must meet complexity standards (8+ chars, 1 special, 1 number)
- Social login (OAuth2) must support Google and Amazon
- System must prevent duplicate account creation for the same email

---

## 2. Profile & PII Management

### User Story
"As a registered customer, I want to update my personal information (Name, DOB, Gender) so that my profile remains accurate, and the platform can offer relevant age-based or gender-based content."

### Requirement ID
REQ-PII-02

### EARS Requirement
WHILE the user is in the 'Edit Profile' state, THE system shall allow modifications to PII fields, but THE system shall mask the Date of Birth and Tax ID after the initial entry to ensure data privacy.

### Acceptance Criteria
- PII changes must be logged in the Data Lineage Agent for audit
- User must confirm identity via password/biometrics for sensitive field edits

---

## 3. Unified Address Book

### User Story
"As a frequent shopper, I want to manage multiple shipping and billing addresses so that I can easily toggle between home, work, and gift destinations during checkout."

### Requirement ID
REQ-ADDR-03

### EARS Requirement
WHERE a user has multiple addresses saved, THE system shall require one address to be designated as 'Default'.

### Acceptance Criteria
- System must validate zip codes against a master postal database
- User can delete any address except the active billing address for a pending order