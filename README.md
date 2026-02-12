# User Authentication, Registration, and Profile Management System

Enterprise application for user authentication, registration, and profile management using Java 17 with AWS Lambda for the backend and React 18+ for the frontend.

## Project Structure

```
.
├── ProfileManager-API/   # Java 17 AWS Lambda backend
├── ProfileManager-UI/    # React 18+ TypeScript frontend
├── ProfileManager-CDK/   # AWS CDK infrastructure as code
├── ProfileManager-DB/    # PostgreSQL migration scripts
└── .kiro/                # Kiro specs and configuration
```

## Technology Stack

### Backend
- Java 17
- AWS Lambda
- API Gateway
- Maven
- PostgreSQL (Amazon RDS)
- AWS SES (Email)
- OAuth2 (Google, Amazon)

### Frontend
- React 18+
- TypeScript
- Material-UI (MUI)
- React Router
- Axios

### Infrastructure
- AWS CDK (TypeScript)
- CloudFormation
- RDS PostgreSQL
- Secrets Manager
- CloudWatch

### DevOps
- GitHub
- Jenkins/GitHub Actions
- Docker
- SonarQube

## Getting Started

### Prerequisites
- Java 17
- Node.js 18+
- Maven 3.8+
- AWS CLI configured
- PostgreSQL 14+ (for local development)

### Backend Setup
```bash
cd ProfileManager-API
mvn clean install
mvn test
```

### Frontend Setup
```bash
cd ProfileManager-UI
npm install
npm start
```

### Infrastructure Setup
```bash
cd ProfileManager-CDK
npm install
cdk bootstrap
cdk deploy --all
```

### Database Setup
```bash
cd ProfileManager-DB
# Run migrations using Flyway or manually with psql
psql -h localhost -U postgres -d userauth -f migrations/V1__create_users_table.sql
```

## Features

### Authentication
- Email/password registration with email verification
- Social login (Google, Amazon OAuth2)
- JWT token-based authentication
- Account locking after 5 failed login attempts
- Secure password hashing (BCrypt)

### Profile Management
- View and update user profile (8 fields)
- Mandatory field validation
- Age range validation (18-120)
- Email format validation
- Gender selection (Male, Female, Other)
- Multiple preference selection
- Configurable email modification policy

### Security
- Password complexity requirements
- Email verification before login
- Account locking mechanism
- JWT token authentication
- OAuth2 integration
- API Gateway rate limiting
- SQL injection prevention
- XSS prevention

## API Endpoints

### Authentication
- `POST /auth/register` - Email registration
- `GET /auth/verify-email` - Email verification
- `POST /auth/oauth2/google` - Google OAuth2
- `POST /auth/oauth2/amazon` - Amazon OAuth2
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout

### Profile
- `GET /profile` - Get user profile
- `PUT /profile` - Update user profile
- `GET /profile/email-policy` - Get email modification policy

## Testing

### Backend Tests
```bash
cd ProfileManager-API
mvn test
```

### Frontend Tests
```bash
cd ProfileManager-UI
npm test
```

### Property-Based Tests
The project includes 16 property-based tests validating correctness properties with 100+ iterations each.

## Deployment

### Deploy Infrastructure
```bash
cd ProfileManager-CDK
cdk deploy --all --context env=prod
```

### Deploy Backend
```bash
cd ProfileManager-API
mvn clean package
# Lambda functions deployed via CDK
```

### Deploy Frontend
```bash
cd ProfileManager-UI
npm run build
# Deploy to S3 + CloudFront via CDK
```

## Documentation

- [Backend README](ProfileManager-API/README.md)
- [Frontend README](ProfileManager-UI/README.md)
- [Infrastructure README](ProfileManager-CDK/README.md)
- [Database README](ProfileManager-DB/README.md)
- [Spec Files](.kiro/specs/)

## Design Resources

**Figma Design**: [View Design](https://www.figma.com/design/GGoFL7U4ljuiJxfQ1VBBbi/POC?node-id=1-1077&t=jPWNYDTKebx4Ygd4-1)

## Implementation Tasks

See [tasks.md](.kiro/specs/tasks.md) for detailed implementation plan with 21 tasks organized in 7 phases.

## License

Proprietary - All rights reserved
