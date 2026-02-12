# Repository Names

This document describes the repository naming convention for the User Authentication, Registration, and Profile Management System.

## Repository Structure

The project is organized into 4 separate repositories:

### 1. ProfileManager-API
**Purpose**: Java 17 AWS Lambda Backend  
**Technology**: Java 17, AWS Lambda, Maven, PostgreSQL  
**Description**: Contains all Lambda handlers, services, repositories, utilities, validators, and business logic for the backend API.

**Key Components**:
- Lambda handlers (8 handlers)
- Business logic services
- Data access repositories
- Validation utilities
- Security utilities (BCrypt, JWT, OAuth2)
- Exception handling
- Database connection management

**Maven Artifact**:
```xml
<groupId>com.myorg</groupId>
<artifactId>ProfileManager-API</artifactId>
<version>1.0.0</version>
```

### 2. ProfileManager-UI
**Purpose**: React 18+ TypeScript Frontend  
**Technology**: React 18+, TypeScript, Material-UI, React Router  
**Description**: Contains all frontend components, services, routing, and UI logic for the web application.

**Key Components**:
- Authentication components (Registration, Login)
- Profile management component
- API services (Auth, OAuth2, Profile, Validation)
- Route guards and navigation
- Material-UI theme configuration
- TypeScript models and interfaces

**NPM Package**:
```json
{
  "name": "profilemanager-ui",
  "version": "1.0.0"
}
```

### 3. ProfileManager-CDK
**Purpose**: AWS CDK Infrastructure as Code  
**Technology**: AWS CDK (TypeScript), CloudFormation  
**Description**: Contains all infrastructure definitions for deploying the application to AWS.

**Key Components**:
- Database stack (RDS PostgreSQL)
- Lambda stack (Lambda functions)
- API Gateway stack (REST API)
- Secrets Manager stack (credentials, JWT secret, OAuth2 secrets)
- Monitoring stack (CloudWatch logs and alarms)

**NPM Package**:
```json
{
  "name": "profilemanager-cdk",
  "version": "1.0.0"
}
```

### 4. ProfileManager-DB
**Purpose**: PostgreSQL Database Scripts  
**Technology**: PostgreSQL, SQL, Flyway/Liquibase  
**Description**: Contains all database migration and rollback scripts for schema management.

**Key Components**:
- Migration scripts (V1-V4)
  - V1: users table (Customer_Identity)
  - V2: user_preferences table
  - V3: login_attempts table
  - V4: token_blacklist table
- Rollback scripts (R1-R4)

## Repository Naming Convention

The naming follows this pattern:
```
ProfileManager-<Component>
```

Where `<Component>` is:
- **API**: Backend API services
- **UI**: Frontend user interface
- **CDK**: Infrastructure as code
- **DB**: Database scripts

## Benefits of This Structure

1. **Clear Separation**: Each repository has a single, well-defined responsibility
2. **Independent Deployment**: Each component can be deployed independently
3. **Team Organization**: Different teams can work on different repositories
4. **Version Control**: Each component can have its own versioning strategy
5. **CI/CD**: Separate pipelines for each repository
6. **Technology Isolation**: Each repository uses its own technology stack

## Monorepo vs Multi-Repo

This project can be organized as either:

### Option 1: Monorepo (Current Structure)
All 4 components in a single Git repository:
```
aws-agentic-sdlc/
├── ProfileManager-API/
├── ProfileManager-UI/
├── ProfileManager-CDK/
└── ProfileManager-DB/
```

**Advantages**:
- Single clone operation
- Easier to coordinate changes across components
- Shared tooling and configuration
- Simpler for smaller teams

### Option 2: Multi-Repo
Each component in its own Git repository:
```
ProfileManager-API/      (separate repo)
ProfileManager-UI/       (separate repo)
ProfileManager-CDK/      (separate repo)
ProfileManager-DB/       (separate repo)
```

**Advantages**:
- True independence between components
- Separate access control per repository
- Clearer ownership boundaries
- Better for larger teams

## Directory Structure

```
.
├── ProfileManager-API/          # Backend (Java 17 + AWS Lambda)
│   ├── src/main/java/...
│   ├── src/test/java/...
│   ├── pom.xml
│   └── README.md
│
├── ProfileManager-UI/           # Frontend (React 18+ + TypeScript)
│   ├── src/
│   ├── public/
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
│
├── ProfileManager-CDK/          # Infrastructure (AWS CDK)
│   ├── lib/
│   ├── bin/
│   ├── package.json
│   ├── cdk.json
│   └── README.md
│
└── ProfileManager-DB/           # Database (PostgreSQL)
    ├── migrations/
    ├── rollback/
    └── README.md
```

## Quick Commands

### ProfileManager-API
```bash
cd ProfileManager-API
mvn clean install
mvn test
mvn package
```

### ProfileManager-UI
```bash
cd ProfileManager-UI
npm install
npm start
npm test
npm run build
```

### ProfileManager-CDK
```bash
cd ProfileManager-CDK
npm install
cdk bootstrap
cdk deploy --all
cdk destroy --all
```

### ProfileManager-DB
```bash
cd ProfileManager-DB
# Run migrations with Flyway
flyway migrate

# Or manually with psql
psql -h localhost -U postgres -d userauth -f migrations/V1__create_users_table.sql
```

## Integration Points

### API ↔ DB
- ProfileManager-API connects to PostgreSQL database
- Uses JDBC with connection pooling via RDS Proxy
- Credentials stored in AWS Secrets Manager

### UI ↔ API
- ProfileManager-UI calls REST APIs via API Gateway
- Uses JWT tokens for authentication
- API Gateway URL configured in .env file

### CDK → All
- ProfileManager-CDK deploys all infrastructure
- Deploys Lambda functions from ProfileManager-API
- Configures API Gateway endpoints
- Sets up RDS database for ProfileManager-DB
- Deploys frontend to S3 + CloudFront

## Documentation

Each repository has its own README:
- [ProfileManager-API/README.md](ProfileManager-API/README.md)
- [ProfileManager-UI/README.md](ProfileManager-UI/README.md)
- [ProfileManager-CDK/README.md](ProfileManager-CDK/README.md)
- [ProfileManager-DB/README.md](ProfileManager-DB/README.md)

## Next Steps

1. Review the updated structure
2. Initialize Git repositories (if using multi-repo approach)
3. Set up CI/CD pipelines for each repository
4. Configure access control and permissions
5. Start implementing tasks from `.kiro/specs/tasks.md`
