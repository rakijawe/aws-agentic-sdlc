# User Authentication Frontend

React 18+ TypeScript frontend for user authentication, registration, and profile management.

## Technology Stack
- React 18+
- TypeScript
- Material-UI (MUI)
- React Router
- Axios

## Project Structure
```
src/
├── components/       # UI Components
│   ├── auth/        # Authentication components
│   ├── profile/     # Profile components
│   └── shared/      # Shared components
├── services/        # API Services
├── models/          # TypeScript interfaces
├── guards/          # Route guards
├── routes/          # Routing configuration
├── theme/           # Material-UI theme
└── utils/           # Utilities
```

## Setup
```bash
npm install
```

## Development
```bash
npm start
```

## Build
```bash
npm run build
```

## Test
```bash
npm test
```

## Environment Variables
Create `.env` file:
```
REACT_APP_API_URL=https://your-api-gateway-url
REACT_APP_GOOGLE_CLIENT_ID=your-google-client-id
REACT_APP_AMAZON_CLIENT_ID=your-amazon-client-id
```
