# Business Requirements Document

## 1. User Login – EARS Requirements

### 1.1 Login Page Access

**Ubiquitous Requirement (U1)**

The system shall provide a Login page to all users.

---

### 1.2 Successful Login

**Event Driven Requirement (E1)**

When the user enters a valid Email ID and Password and clicks the Login button, the system shall authenticate the user and redirect the user to the Home page.

---

### 1.3 Invalid Credentials

**Event Driven Requirement (E2)**

When the user enters an invalid Email ID or Password and clicks the Login button, the system shall display the message:

> "Invalid username or password"

---

### 1.4 Mandatory Fields Validation

**State Driven Requirement (S1)**

While the Email ID or Password field is blank, the system shall disable the Login button.

---

### 1.5 Password Format Validation

**Event Driven Requirement (E3)**

When the user enters a password that does not meet the password policy, the system shall display the message:

> "Password does not meet complexity requirements"

**Business Rules for Password:**

Password must contain:
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one numeric digit
- At least one special character

---

### 1.6 Email Format Validation

**Event Driven Requirement (E4)**

When the user enters an Email ID in an invalid format, the system shall display the message:

> "Please enter a valid email address"

**Business Rule:**

Email must follow standard pattern:
- Format: `name@domain.com`
- Must contain "@" and domain
- Must not contain spaces

---

### 1.7 Account Locking

**State Driven Requirement (S2)**

While the user enters incorrect credentials more than 5 times consecutively, the system shall lock the user account for 30 minutes.

---

## 2. Profile Management – EARS Requirements

### 2.1 View Profile Page

**Ubiquitous Requirement (U2)**

The system shall provide a Profile Management page to all authenticated users.

---

### 2.2 Display Profile Fields

**Ubiquitous Requirement (U3)**

The system shall display the following fields on the Profile Management page:
- Title
- First Name
- Last Name
- Gender
- Age
- Email
- Address
- Preferences (three preference options)

---

### 2.3 Mandatory Fields

**State Driven Requirement (S3)**

While the user is saving the profile, the system shall ensure that the following fields are mandatory:
- First Name
- Last Name
- Email
- Gender

---

### 2.4 Title Field Behavior

**Ubiquitous Requirement (U4)**

The system shall display Title as a dropdown with the following options:
- Mr
- Ms
- Mrs
- Dr

---

### 2.5 Gender Field Validation

**Ubiquitous Requirement (U5)**

The system shall display Gender as radio button options with the values:
- Male
- Female
- Other

**Event Driven Requirement (E5)**

When the user selects an invalid or blank Gender option, the system shall display the message:

> "Gender selection is mandatory"

---

### 2.6 Age Validation

**Event Driven Requirement (E6)**

When the user enters Age less than 18 or greater than 120, the system shall display the message:

> "Age must be between 18 and 120"

**Business Rule:**
- Age must be numeric
- Allowed range: 18 – 120

---

### 2.7 Email Validation in Profile

**Event Driven Requirement (E7)**

When the user updates the Email field with an invalid email format, the system shall display the message:

> "Please enter a valid email address"

---

### 2.8 Preferences Selection

**Ubiquitous Requirement (U6)**

The system shall display Preferences as a dropdown or radio button list with three options.

**Example preference options:**
- Email Notifications
- SMS Notifications
- App Notifications

**State Driven Requirement (S4)**

While saving the profile, the system shall ensure that at least one preference option is selected.

---

### 2.9 Save Profile

**Event Driven Requirement (E8)**

When the user clicks the Save button after entering valid profile details, the system shall save the updated profile information and display the message:

> "Profile updated successfully"

---

### 2.10 Cancel Changes

**Event Driven Requirement (E9)**

When the user clicks the Cancel button, the system shall discard all unsaved changes and reload the last saved profile data.

---

### 2.11 Read Only Email Rule

**Ubiquitous Requirement (U7)**

The system shall display Email ID as read-only if the organization policy restricts email modification.
