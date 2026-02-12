# Quick Start Guide

This guide will help you get started with the User Authentication, Registration, and Profile Management System.

## ✅ Project Structure Created

The complete project structure has been created with:
- ✅ Backend (Java 17 + AWS Lambda)
- ✅ Frontend (React 18+ + TypeScript)
- ✅ Infrastructure (AWS CDK)
- ✅ Database (PostgreSQL migration scripts)

## 📋 Prerequisites

Before you begin, ensure you have:
- ☐ Java 17 installed
- ☐ Maven 3.8+ installed
- ☐ Node.js 18+ installed
- ☐ AWS CLI configured
- ☐ PostgreSQL 14+ (for local development)
- ☐ Git installed

## 🚀 Getting Started

### Step 1: Verify Project Structure

```bash
# Check the project structure
ls -la

# You should see:
# - ProfileManager-API/
# - ProfileManager-UI/
# - ProfileManager-CDK/
# - ProfileManager-DB/
# - .kiro/
```

### Step 2: Backend Setup

```bash
cd ProfileManager-API

# Install dependencies and build
mvn clean install

# Run tests (optional)
mvn test

# Go back to root
cd ..
```

### Step 3: Frontend Setup

```bash
cd ProfileManager-UI

# Install dependencies
npm install

# Create .env file from template
cp .env.example .env

# Edit .env with your configuration
# REACT_APP_API_URL=https://your-api-gateway-url
# REACT_APP_GOOGLE_CLIENT_ID=your-google-client-id
# REACT_APP_AMAZON_CLIENT_ID=your-amazon-client-id

# Start development server (optional)
npm start

# Go back to root
cd ..
```

### Step 4: Infrastructure Setup

```bash
cd ProfileManager-CDK

# Install dependencies
npm install

# Bootstrap CDK (first time only)
cdk bootstrap

# Go back to root
cd ..
```

## 📝 Implementation Tasks

Now you're ready to start implementing! Open the tasks file:

```bash
# View the implementation tasks
cat .kiro/specs/tasks.md
```

### Task Execution Order

Follow the 7-phase implementation plan in `tasks.md`:

**Phase 1: Infrastructure & Security (Week 1)**
- Task 1: Set up AWS infrastructure using CDK
- Task 2: Create database schema and migration scripts
- Task 3: Implement shared Lambda layer utilities
- Task 4: Implement repository classes

**Phase 2: Registration & Email Verification (Week 2)**
- Task 5: Implement RegistrationHandler Lambda function
- Task 6: Implement EmailVerificationHandler Lambda function
- Task 12: Configure API Gateway endpoints (partial)
- Task 13: Backend validation checkpoint

**Phase 3: Social Login Integration (Week 3)**
- Task 7: Implement OAuth2Handler Lambda function

**Phase 4: Core Authentication (Week 4)**
- Task 8: Implement AuthLoginHandler Lambda function
- Task 14: Create React project structure and shared services
- Task 16: Implement LoginComponent
- Task 18: Configure routing and navigation

**Phase 5: Validation Layer (Week 5)**
- Property-based tests (Tasks 3.7-3.9, 5.6, 6.3, 8.5-8.7, etc.)

**Phase 6: Profile Management (Week 6)**
- Task 9: Implement GetProfileHandler Lambda function
- Task 10: Implement UpdateProfileHandler Lambda function
- Task 11: Implement supporting Lambda functions
- Task 15: Implement RegistrationComponent
- Task 17: Implement ProfileComponent

**Phase 7: Testing & Deployment (Week 7)**
- Task 19: Create deployment pipeline
- Task 20: Integration testing and validation
- Task 21: Final checkpoint - Production readiness validation

## 🎯 Next Steps

### Option 1: Start with Infrastructure (Recommended)

```bash
# Execute Task 1: Set up AWS infrastructure
cd ProfileManager-CDK

# Review the CDK stacks to be created
# Then implement according to Task 1 sub-tasks in tasks.md
```

### Option 2: Start with Backend Utilities

```bash
# Execute Task 3: Implement shared Lambda layer utilities
cd ProfileManager-API/src/main/java/com/myorg/usermanagement

# Create utility classes according to Task 3 sub-tasks
```

### Option 3: Start with Database Schema

```bash
# Execute Task 2: Create database schema
cd ProfileManager-DB/migrations

# Create SQL migration scripts according to Task 2 sub-tasks
```

## 📚 Documentation

- **Main README**: `README.md` - Project overview
- **Project Structure**: `PROJECT_STRUCTURE.md` - Complete directory structure
- **Backend README**: `ProfileManager-API/README.md` - Backend documentation
- **Frontend README**: `ProfileManager-UI/README.md` - Frontend documentation
- **Infrastructure README**: `ProfileManager-CDK/README.md` - Infrastructure documentation
- **Database README**: `ProfileManager-DB/README.md` - Database documentation
- **Tasks**: `.kiro/specs/tasks.md` - Implementation tasks (21 tasks)
- **Requirements**: `.kiro/specs/requirements.md` - Requirements document
- **Design**: `.kiro/specs/design.md` - Design document

## 🔧 Development Commands

### Backend
```bash
cd ProfileManager-API
mvn clean install          # Build
mvn test                   # Run tests
mvn package                # Package for deployment
```

### Frontend
```bash
cd ProfileManager-UI
npm install                # Install dependencies
npm start                  # Start dev server
npm test                   # Run tests
npm run build              # Build for production
```

### Infrastructure
```bash
cd ProfileManager-CDK
npm install                # Install dependencies
cdk synth                  # Synthesize CloudFormation
cdk diff                   # Compare with deployed
cdk deploy --all           # Deploy all stacks
cdk destroy --all          # Destroy all stacks
```

## 🎨 Design Resources

**Figma Design**: [View Design](https://www.figma.com/design/GGoFL7U4ljuiJxfQ1VBBbi/POC?node-id=1-1077&t=jPWNYDTKebx4Ygd4-1)

Reference the Figma design when implementing frontend components (Tasks 15-17).

## ✨ Key Features to Implement

- ✅ Email/password registration with verification
- ✅ Social login (Google, Amazon OAuth2)
- ✅ JWT token authentication
- ✅ Account locking after 5 failed attempts
- ✅ Profile management (8 fields)
- ✅ Comprehensive validation
- ✅ Password complexity requirements
- ✅ Age range validation (18-120)
- ✅ Email format validation
- ✅ Mandatory field validation

## 🧪 Testing

The project includes:
- Unit tests (70% minimum coverage)
- Property-based tests (16 properties, 100+ iterations each)
- Integration tests
- End-to-end tests

## 🚢 Deployment

When ready to deploy:

1. Deploy infrastructure:
   ```bash
   cd ProfileManager-CDK
   cdk deploy --all --context env=prod
   ```

2. Backend is deployed automatically via CDK

3. Deploy frontend:
   ```bash
   cd ProfileManager-UI
   npm run build
   # Deploy to S3 + CloudFront (configured in CDK)
   ```

## 📞 Support

For questions or issues:
1. Review the spec files in `.kiro/specs/`
2. Check the steering files in `.kiro/steering/`
3. Refer to task details in `tasks.md`

## 🎉 You're Ready!

The project structure is complete. Start implementing by opening `.kiro/specs/tasks.md` and executing tasks sequentially.

Good luck! 🚀
