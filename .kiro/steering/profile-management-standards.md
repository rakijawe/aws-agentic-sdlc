---
inclusion: always
---

# Profile Management Standards

This steering file defines the profile management requirements and UI patterns.

## Profile Page Access
- Available to all authenticated users
- Accessible from main navigation

## Profile Fields

### Required Fields (Mandatory)
- First Name (text input)
- Last Name (text input)
- Email (text input)
- Gender (radio buttons)

### Optional Fields
- Title (dropdown)
- Age (numeric input)
- Address (text area)
- Preferences (multi-select or checkboxes)

## Field Specifications

### Title Field
- Type: Dropdown
- Options:
  - Mr
  - Ms
  - Mrs
  - Dr
- Default: None selected

### First Name & Last Name
- Type: Text input
- Mandatory for profile save
- Validation: Non-empty string

### Gender Field
- Type: Radio buttons
- Options:
  - Male
  - Female
  - Other
- Mandatory selection required
- Error message: "Gender selection is mandatory" if blank

### Age Field
- Type: Numeric input
- Validation range: 18 – 120
- Error message: "Age must be between 18 and 120" for out-of-range values
- Must be numeric only

### Email Field
- Type: Text input
- Mandatory field
- Format validation: `name@domain.com`
- Error message: "Please enter a valid email address" for invalid format
- May be read-only based on organization policy

### Address Field
- Type: Text area
- Optional field
- Multi-line input support

### Preferences Field
- Type: Dropdown or checkbox list
- Options (example):
  - Email Notifications
  - SMS Notifications
  - App Notifications
- At least one preference must be selected when saving

## Profile Actions

### Save Profile
When user clicks Save button with valid data:
- Validate all mandatory fields
- Validate all field formats
- Save updated profile information
- Display success message: "Profile updated successfully"
- Remain on profile page or redirect as per UX design

### Cancel Changes
When user clicks Cancel button:
- Discard all unsaved changes
- Reload last saved profile data
- No confirmation dialog needed (or add if preferred by UX)

## Business Rules

### Email Modification Policy
- If organization policy restricts email modification:
  - Display Email field as read-only
  - Show appropriate indicator (disabled state, lock icon)
  - Provide alternative method for email change if needed

### Data Persistence
- Save profile data to database on successful validation
- Maintain audit trail of profile changes
- Store timestamps for created/updated records

## Implementation Guidelines

- Use form validation library for consistent validation
- Implement client-side and server-side validation
- Provide clear, inline error messages
- Use appropriate input types (email, number, etc.)
- Implement proper accessibility (ARIA labels, keyboard navigation)
- Show loading state during save operation
- Handle network errors gracefully
