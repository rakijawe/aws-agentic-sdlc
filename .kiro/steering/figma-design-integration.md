---
inclusion: always
---

# Figma Design Integration

This steering file defines how to use Figma for UI design input and integrate it with the development workflow.

## Overview

Figma serves as the single source of truth for UI/UX design. All frontend implementation should reference Figma designs to ensure pixel-perfect implementation and design consistency.

## Figma Organization Structure

### Project Structure
```
REXX Modernization/
├── 01-Design System/
│   ├── Components Library
│   ├── Color Palette
│   ├── Typography
│   └── Icons & Assets
├── 02-User Flows/
│   ├── Authentication Flow
│   ├── Profile Management Flow
│   └── Navigation Flow
├── 03-Screens/
│   ├── Login Page
│   ├── Profile Page
│   ├── Home Page
│   └── Error States
└── 04-Prototypes/
    ├── Interactive Prototype
    └── User Testing Versions
```

## Design System in Figma

### Components to Create

#### Form Components
- Text Input (with states: default, focus, error, disabled)
- Password Input (with show/hide toggle)
- Dropdown/Select
- Radio Button Group
- Checkbox Group
- Button (primary, secondary, disabled, loading)
- Error Message Component
- Success Message Component

#### Layout Components
- Page Container
- Form Container
- Card Component
- Modal/Dialog
- Navigation Bar
- Footer

#### Design Tokens
- Colors (primary, secondary, error, success, neutral)
- Typography (headings, body, labels, captions)
- Spacing (4px, 8px, 16px, 24px, 32px, 48px)
- Border Radius (4px, 8px, 16px)
- Shadows (elevation levels)

## Referencing Figma in Specs

### In Design.md Files
Always include Figma links in your spec design files:

```markdown
# Design Specification

## Figma Resources

### Design Files
- [Login Page Design](https://figma.com/file/xxx/login-page)
- [Profile Page Design](https://figma.com/file/xxx/profile-page)
- [Component Library](https://figma.com/file/xxx/components)

### Prototypes
- [Interactive Prototype](https://figma.com/proto/xxx/interactive)
- [User Flow](https://figma.com/file/xxx/user-flow)

## Screen Specifications

### Login Page
**Figma Frame**: #[[figma:https://figma.com/file/xxx/login-page?node-id=123]]

#### Layout
- Container: 400px max-width, centered
- Padding: 32px
- Background: White card with shadow

#### Components Used
- Email Input (from design system)
- Password Input (from design system)
- Primary Button (Login)
- Error Message Component

#### Spacing
- Between fields: 24px
- Button margin-top: 32px
- Error message margin-top: 8px
```

### Figma Link Format
Use this format to reference Figma designs:

```markdown
#[[figma:https://figma.com/file/{file-id}/{file-name}?node-id={node-id}]]
```

This allows:
- Direct linking to specific frames/components
- Version tracking
- Easy navigation for developers

## Figma to Code Workflow

### 1. Design Phase
- Designer creates screens in Figma
- Apply design system components
- Create interactive prototype
- Share Figma link with team

### 2. Design Review
- Product Owner reviews against requirements
- Developer reviews for technical feasibility
- QA reviews for testability
- Iterate based on feedback

### 3. Design Handoff
- Designer marks frames as "Ready for Development"
- Add developer notes in Figma comments
- Export assets (icons, images)
- Document component specifications

### 4. Implementation Phase
- Developer references Figma during coding
- Use Figma Inspect for exact measurements
- Extract CSS properties from Figma
- Implement responsive breakpoints

### 5. Design QA
- Compare implementation with Figma
- Verify spacing, colors, typography
- Test interactive states
- Validate responsive behavior

## Figma Plugins for Development

### Recommended Plugins

#### For Developers
- **Figma to Code** - Generate HTML/CSS/React code
- **Inspect** - Get CSS properties and measurements
- **Iconify** - Access icon libraries
- **Content Reel** - Generate realistic content
- **Stark** - Check accessibility compliance

#### For Designers
- **Contrast** - Verify color contrast ratios
- **A11y - Color Contrast Checker** - Accessibility validation
- **Autoflow** - Create user flow diagrams
- **Figma Tokens** - Manage design tokens

## Extracting Design Specifications

### Using Figma Inspect Panel

#### Colors
```css
/* Extract from Figma Inspect */
--primary-color: #1976D2;
--error-color: #D32F2F;
--success-color: #388E3C;
--text-primary: #212121;
--text-secondary: #757575;
```

#### Typography
```css
/* Heading 1 */
font-family: 'Roboto', sans-serif;
font-size: 32px;
font-weight: 500;
line-height: 40px;
letter-spacing: 0px;

/* Body Text */
font-family: 'Roboto', sans-serif;
font-size: 16px;
font-weight: 400;
line-height: 24px;
```

#### Spacing
```css
/* Extract padding/margin from Figma */
padding: 16px 24px;
margin-bottom: 24px;
gap: 16px;
```

#### Component Dimensions
```css
/* Button */
height: 48px;
min-width: 120px;
border-radius: 4px;

/* Input Field */
height: 56px;
width: 100%;
border-radius: 4px;
```

## Material-UI (MUI) Mapping

### Map Figma Components to Material-UI

#### Form Fields
```tsx
// Figma: Text Input → Material-UI
import { TextField } from '@mui/material';

<TextField
  label="Email"
  type="email"
  variant="outlined"
  error={hasError}
  helperText={hasError ? "Please enter a valid email" : ""}
  fullWidth
/>
```

#### Buttons
```tsx
// Figma: Primary Button → Material-UI
import { Button } from '@mui/material';

<Button variant="contained" color="primary">
  Login
</Button>
```

#### Radio Buttons
```tsx
// Figma: Radio Group → Material-UI
import { RadioGroup, FormControlLabel, Radio } from '@mui/material';

<RadioGroup>
  <FormControlLabel value="male" control={<Radio />} label="Male" />
  <FormControlLabel value="female" control={<Radio />} label="Female" />
  <FormControlLabel value="other" control={<Radio />} label="Other" />
</RadioGroup>
```

### Custom Theming from Figma
```typescript
// Extract colors from Figma and create Material-UI theme
import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976D2',
    },
    secondary: {
      main: '#FF9800',
    },
    error: {
      main: '#D32F2F',
    },
  },
  typography: {
    fontFamily: 'Roboto, sans-serif',
  },
});

export default theme;
```

## Asset Export from Figma

### Export Settings

#### Icons
- Format: SVG
- Scale: 1x
- Naming: `icon-{name}.svg`
- Location: `src/assets/icons/`

#### Images
- Format: PNG or WebP
- Scale: 1x, 2x, 3x (for different densities)
- Naming: `{name}@{scale}x.png`
- Location: `src/assets/images/`

#### Logos
- Format: SVG (vector)
- Include both light and dark versions
- Location: `src/assets/logos/`

### Export Process
1. Select asset in Figma
2. Click "Export" in right panel
3. Choose format and scale
4. Export to local folder
5. Commit to repository under `src/assets/`

## Responsive Design in Figma

### Breakpoints to Design
Match Material-UI breakpoints:

- **Mobile**: 0px - 599px (xs)
- **Tablet**: 600px - 899px (sm)
- **Desktop**: 900px - 1199px (md)
- **Large Desktop**: 1200px+ (lg, xl)

### Figma Frames for Breakpoints
Create separate frames for each breakpoint:
```
Login Page/
├── Mobile (375px)
├── Tablet (768px)
└── Desktop (1440px)
```

### Auto Layout in Figma
- Use Auto Layout for responsive components
- Set constraints (left, right, center, scale)
- Define min/max widths
- Use flex properties (space-between, center, etc.)

## Design Tokens Integration

### Export Design Tokens from Figma
Use Figma Tokens plugin to export:

```json
{
  "colors": {
    "primary": "#1976D2",
    "error": "#D32F2F",
    "success": "#388E3C"
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "16px",
    "lg": "24px",
    "xl": "32px"
  },
  "typography": {
    "h1": {
      "fontSize": "32px",
      "fontWeight": "500",
      "lineHeight": "40px"
    }
  }
}
```

### Import to React
```typescript
// design-tokens.ts
export const DesignTokens = {
  colors: {
    primary: '#1976D2',
    error: '#D32F2F',
    success: '#388E3C'
  },
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    lg: '24px',
    xl: '32px'
  }
};
```

## Collaboration Best Practices

### For Designers
- Keep design system components up to date
- Document component usage in Figma
- Add developer notes for complex interactions
- Mark frames with status (Draft, Review, Ready, Done)
- Version designs before major changes
- Share prototypes early for feedback

### For Developers
- Reference Figma during implementation
- Ask questions via Figma comments
- Mark implemented frames with checkmark
- Report design inconsistencies
- Suggest improvements based on technical constraints
- Update Figma links in code comments

### For Product Owners
- Review designs against requirements
- Validate user flows in prototypes
- Approve designs before development
- Track design changes in Jira
- Ensure accessibility compliance

## Figma in Spec Files

### Example: Login Page Spec

```markdown
# Login Page Implementation

## Design Reference
**Figma**: #[[figma:https://figma.com/file/abc123/login-page?node-id=45:678]]

## Implementation Tasks

### Frontend Tasks
<!-- @team:frontend @component:frontend-ui @figma:abc123 -->

- [ ] Create LoginComponent
  - Reference: Figma frame "Login - Desktop"
  - Use Material-UI form fields
  - Extract colors from Figma Inspect
  
- [ ] Implement form validation
  - Reference: Figma frame "Login - Error States"
  - Match error message styling
  - Use error color from design system
  
- [ ] Add responsive layout
  - Reference: Figma frames "Login - Mobile/Tablet/Desktop"
  - Use Material-UI Grid/Box components
  - Test on all breakpoints

- [ ] Export and integrate assets
  - Logo from Figma (SVG)
  - Background pattern (if any)
  - Icons for show/hide password
```

## Quality Checklist

### Design-to-Code Validation
- [ ] Colors match Figma exactly
- [ ] Typography (font, size, weight) matches
- [ ] Spacing matches (padding, margin, gaps)
- [ ] Border radius matches
- [ ] Shadows match elevation
- [ ] Interactive states implemented (hover, focus, active, disabled)
- [ ] Responsive behavior matches all breakpoints
- [ ] Animations match Figma prototype
- [ ] Assets exported and optimized
- [ ] Accessibility requirements met

## Tools Integration

### Figma API for Automation
Use Figma API to:
- Fetch design metadata
- Export assets programmatically
- Sync design tokens
- Generate component documentation

### Example: Fetch Figma File Info
```typescript
// figma-sync.service.ts
export async function getFigmaFile(fileId: string) {
  const response = await fetch(
    `https://api.figma.com/v1/files/${fileId}`,
    {
      headers: {
        'X-Figma-Token': process.env.REACT_APP_FIGMA_TOKEN
      }
    }
  );
  return response.json();
}
```

## Documentation

### Maintain Design Documentation
- Link Figma files in project README
- Document component library location
- Keep design system changelog
- Archive old design versions
- Document design decisions

### Example README Section
```markdown
## Design Resources

- [Figma Design System](https://figma.com/file/xxx/design-system)
- [Component Library](https://figma.com/file/xxx/components)
- [User Flows](https://figma.com/file/xxx/flows)
- [Interactive Prototype](https://figma.com/proto/xxx/prototype)

### For Developers
1. Request Figma access from design team
2. Install Figma desktop app or use web version
3. Use Inspect panel for measurements and CSS
4. Export assets as needed
5. Reference designs during implementation
```

## Troubleshooting

### Common Issues

**Issue**: Figma link not accessible
- Solution: Request access from file owner
- Check if link is set to "Anyone with link can view"

**Issue**: Colors don't match exactly
- Solution: Use Figma Inspect to copy exact hex values
- Check for opacity/transparency settings

**Issue**: Fonts not available
- Solution: Install Google Fonts or custom fonts
- Use font-family fallbacks

**Issue**: Exported assets too large
- Solution: Optimize SVGs, compress PNGs
- Use WebP format for images
- Implement lazy loading

## Implementation Checklist

- [ ] Set up Figma project structure
- [ ] Create design system components
- [ ] Define design tokens
- [ ] Install recommended Figma plugins
- [ ] Train team on Figma workflow
- [ ] Document Figma links in specs
- [ ] Set up asset export process
- [ ] Create design-to-code checklist
- [ ] Establish design review process
- [ ] Integrate Figma with Jira (if possible)
