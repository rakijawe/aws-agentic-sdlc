---
inclusion: always
---

# UI/UX Patterns

This steering file defines the user interface and user experience patterns for the application.

## Form Controls

### Text Input Fields
- Use appropriate input types (email, password, text, number)
- Show placeholder text for guidance
- Provide clear labels above or beside inputs
- Support autofill/autocomplete where appropriate
- Show character count for limited fields

### Dropdown/Select Fields
- Title: Dropdown with predefined options
- Show default "Select..." option if no default value
- Use native select or custom dropdown component
- Ensure keyboard navigation support

### Radio Buttons
- Gender: Radio button group
- Show all options visibly
- Only one selection allowed
- Provide clear labels for each option
- Use proper grouping (fieldset/legend)

### Checkboxes
- Preferences: Multiple selection allowed
- Show all options visibly
- Allow multiple selections
- Provide "Select All" / "Clear All" if many options

### Buttons
- Primary action: Prominent styling (Save, Login)
- Secondary action: Less prominent (Cancel)
- Disabled state: Visual indication when inactive
- Loading state: Show spinner during async operations
- Clear, action-oriented labels

## Button State Management

### Disabled State
- Login button: Disabled when Email or Password is empty
- Save button: Disabled when mandatory fields are empty
- Visual indication: Reduced opacity, cursor not-allowed
- Tooltip: Explain why button is disabled (optional)

### Loading State
- Show spinner or loading indicator during API calls
- Disable button to prevent double-submission
- Maintain button width to prevent layout shift

### Success State
- Brief visual feedback on successful action
- Consider checkmark animation or color change

## Error Handling

### Inline Errors
- Display errors below or beside the field
- Use red color and error icon
- Clear, specific error messages
- Remove error when user corrects input

### Form-Level Errors
- Display at top of form for general errors
- Use alert/banner component
- Include dismiss option
- Auto-dismiss after timeout (optional)

### Error Messages
- "Invalid username or password" (login failure)
- "Password does not meet complexity requirements"
- "Please enter a valid email address"
- "Gender selection is mandatory"
- "Age must be between 18 and 120"
- "Profile updated successfully" (success message)

## Success Feedback

### Success Messages
- Display after successful actions
- Use green color and success icon
- Auto-dismiss after 3-5 seconds
- Position: Top of page or near action button

### Examples
- "Profile updated successfully"
- "Login successful"

## Page Layout

### Login Page
- Centered layout
- Simple, focused design
- Email field
- Password field
- Login button
- Optional: "Forgot Password" link
- Optional: "Sign Up" link

### Profile Management Page
- Form layout with clear sections
- Group related fields
- Consistent spacing
- Save and Cancel buttons at bottom
- Breadcrumb or back navigation

## Accessibility Requirements

### Keyboard Navigation
- All interactive elements accessible via Tab
- Logical tab order
- Enter key submits forms
- Escape key cancels/closes modals

### Screen Reader Support
- Proper ARIA labels
- Error announcements
- Form field associations (label + input)
- Button purpose clearly stated

### Visual Accessibility
- Sufficient color contrast (WCAG AA minimum)
- Don't rely on color alone for information
- Clear focus indicators
- Scalable text (support zoom)

## Responsive Design

### Mobile Considerations
- Touch-friendly button sizes (min 44x44px)
- Appropriate input types for mobile keyboards
- Stack form fields vertically
- Full-width inputs on small screens

### Desktop Considerations
- Multi-column layouts where appropriate
- Reasonable max-width for forms (600-800px)
- Hover states for interactive elements

## Loading & Performance

### Initial Load
- Show skeleton screens or loading indicators
- Lazy load non-critical components
- Optimize images and assets

### Form Submission
- Immediate visual feedback
- Disable form during submission
- Handle slow networks gracefully
- Timeout handling with retry option

## Implementation Guidelines

- Use consistent spacing (8px grid system)
- Follow design system/component library
- Maintain consistent typography
- Use animation sparingly and purposefully
- Test with real users
- Support both light and dark modes (if applicable)
- Ensure cross-browser compatibility
