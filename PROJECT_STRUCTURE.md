# Project Structure Overview

Complete project structure for User Authentication, Registration, and Profile Management System.

## Directory Tree

```
.
├── README.md                           # Main project documentation
├── PROJECT_STRUCTURE.md                # This file
├── .gitignore                          # Git ignore rules
│
├── ProfileManager-API/                 # Java 17 AWS Lambda Backend
│   ├── README.md                       # Backend documentation
│   ├── pom.xml                         # Maven configuration
│   └── src/
│       ├── main/
│       │   ├── java/com/myorg/usermanagement/
│       │   │   ├── handler/            # Lambda handlers (Tasks 5-11)
│       │   │   │   ├── RegistrationHandler.java
│       │   │   │   ├── EmailVerificationHandler.java
│       │   │   │   ├── OAuth2Handler.java
│       │   │   │   ├── AuthLoginHandler.java
│       │   │   │   ├── AuthLogoutHandler.java
│       │   │   │   ├── GetProfileHandler.java
│       │   │   │   ├── UpdateProfileHandler.java
│       │   │   │   └── GetEmailPolicyHandler.java
│       │   │   │
│       │   │   ├── service/            # Business logic layer
│       │   │   │   ├── AuthService.java
│       │   │   │   ├── RegistrationService.java
│       │   │   │   ├── ProfileService.java
│       │   │   │   └── EmailService.java
│       │   │   │
│       │   │   ├── repository/         # Data access (Task 4)
│       │   │   │   ├── UserRepository.java
│       │   │   │   └── LoginAttemptRepository.java
│       │   │   │
│       │   │   ├── model/              # Entities and DTOs
│       │   │   │   ├── entity/
│       │   │   │   │   ├── UserEntity.java
│       │   │   │   │   ├── UserPreference.java
│       │   │   │   │   └── LoginAttempt.java
│       │   │   │   └── dto/
│       │   │   │       ├── RegistrationRequest.java
│       │   │   │       ├── LoginRequest.java
│       │   │   │       ├── ProfileDTO.java
│       │   │   │       └── AuthResponse.java
│       │   │   │
│       │   │   ├── util/               # Utilities (Task 3)
│       │   │   │   ├── DatabaseConnectionUtil.java
│       │   │   │   ├── PasswordHashUtil.java
│       │   │   │   ├── JwtTokenUtil.java
│       │   │   │   ├── OAuth2ClientUtil.java
│       │   │   │   └── EmailServiceUtil.java
│       │   │   │
│       │   │   ├── validator/          # Validation (Task 3)
│       │   │   │   ├── EmailValidator.java
│       │   │   │   ├── PasswordValidator.java
│       │   │   │   ├── AgeValidator.java
│       │   │   │   ├── MandatoryFieldValidator.java
│       │   │   │   └── PreferencesValidator.java
│       │   │   │
│       │   │   ├── exception/          # Custom exceptions (Task 3)
│       │   │   │   ├── DuplicateEmailException.java
│       │   │   │   ├── EmailNotVerifiedException.java
│       │   │   │   ├── InvalidCredentialsException.java
│       │   │   │   ├── AccountLockedException.java
│       │   │   │   ├── ValidationException.java
│       │   │   │   ├── ProfileNotFoundException.java
│       │   │   │   └── OAuth2Exception.java
│       │   │   │
│       │   │   └── config/             # Configuration
│       │   │       └── LambdaExceptionHandler.java
│       │   │
│       │   └── resources/
│       │       └── logback.xml         # Logging configuration
│       │
│       └── test/
│           └── java/com/myorg/usermanagement/
│               ├── handler/            # Handler tests
│               ├── service/            # Service tests
│               ├── repository/         # Repository tests
│               ├── util/               # Utility tests
│               └── validator/          # Validator tests
│
├── ProfileManager-UI/                  # React 18+ TypeScript Frontend
│   ├── README.md                       # Frontend documentation
│   ├── package.json                    # NPM configuration
│   ├── tsconfig.json                   # TypeScript configuration
│   ├── .env.example                    # Environment variables template
│   ├── public/
│   │   └── index.html                  # HTML template
│   └── src/
│       ├── index.tsx                   # Application entry point
│       ├── App.tsx                     # Root component
│       │
│       ├── components/                 # UI Components (Tasks 15-17)
│       │   ├── auth/
│       │   │   ├── RegistrationComponent.tsx
│       │   │   ├── LoginComponent.tsx
│       │   │   └── PasswordRequirements.tsx
│       │   ├── profile/
│       │   │   └── ProfileComponent.tsx
│       │   └── shared/
│       │       ├── Navigation.tsx
│       │       └── ErrorMessage.tsx
│       │
│       ├── services/                   # API Services (Task 14)
│       │   ├── ValidationService.ts
│       │   ├── AuthService.ts
│       │   ├── OAuth2Service.ts
│       │   └── ProfileService.ts
│       │
│       ├── models/                     # TypeScript interfaces
│       │   ├── User.ts
│       │   ├── Profile.ts
│       │   ├── AuthResponse.ts
│       │   └── ValidationResult.ts
│       │
│       ├── guards/                     # Route guards (Task 18)
│       │   └── AuthGuard.tsx
│       │
│       ├── routes/                     # Routing (Task 18)
│       │   └── AppRoutes.tsx
│       │
│       ├── theme/                      # Material-UI theme
│       │   └── theme.ts
│       │
│       └── utils/                      # Utilities
│           └── constants.ts
│
├── ProfileManager-CDK/                 # AWS CDK Infrastructure (Task 1)
│   ├── README.md                       # Infrastructure documentation
│   ├── package.json                    # NPM configuration
│   ├── tsconfig.json                   # TypeScript configuration
│   ├── cdk.json                        # CDK configuration
│   ├── bin/
│   │   └── app.ts                      # CDK app entry point
│   └── lib/
│       ├── database-stack.ts           # RDS PostgreSQL
│       ├── lambda-stack.ts             # Lambda functions
│       ├── api-gateway-stack.ts        # API Gateway
│       ├── secrets-stack.ts            # Secrets Manager
│       └── monitoring-stack.ts         # CloudWatch
│
├── ProfileManager-DB/                  # PostgreSQL Scripts (Task 2)
│   ├── README.md                       # Database documentation
│   ├── migrations/
│   │   ├── V1__create_users_table.sql
│   │   ├── V2__create_user_preferences_table.sql
│   │   ├── V3__create_login_attempts_table.sql
│   │   └── V4__create_token_blacklist_table.sql
│   └── rollback/
│       ├── R1__drop_users_table.sql
│       ├── R2__drop_user_preferences_table.sql
│       ├── R3__drop_login_attempts_table.sql
│       └── R4__drop_token_blacklist_table.sql
│
└── .kiro/                              # Kiro Specs
    ├── specs/
    │   ├── requirements.md             # Requirements document
    │   ├── design.md                   # Design document
    │   └── tasks.md                    # Implementation tasks
    └── steering/
        ├── product.md                  # Product definition
        ├── tech.md                     # Technology stack
        ├── java-conventions.md         # Java coding standards
        ├── ui-ux-patterns.md           # UI/UX patterns
        ├── validation-rules.md         # Validation rules
        ├── figma-design-integration.md # Figma integration
        └── jira-workflow-automation.md # Jira workflow
```

## Task to Structure Mapping

### Phase 1: Infrastructure & Security (Week 1)

**Task 1: AWS Infrastructure (CDK)**
- `ProfileManager-CDK/` - All CDK stacks
- `ProfileManager-CDK/lib/database-stack.ts` - RDS PostgreSQL
- `ProfileManager-CDK/lib/lambda-stack.ts` - Lambda functions
- `ProfileManager-CDK/lib/api-gateway-stack.ts` - API Gateway
- `ProfileManager-CDK/lib/secrets-stack.ts` - Secrets Manager
- `ProfileManager-CDK/lib/monitoring-stack.ts` - CloudWatch

**Task 2: Database Schema**
- `ProfileManager-DB/migrations/` - SQL migration scripts
- `ProfileManager-DB/rollback/` - Rollback scripts

**Task 3: Lambda Utilities**
- `ProfileManager-API/src/main/java/com/myorg/usermanagement/util/` - All utilities
- `ProfileManager-API/src/main/java/com/myorg/usermanagement/validator/` - Validators
- `ProfileManager-API/src/main/java/com/myorg/usermanagement/exception/` - Exceptions
- `ProfileManager-API/src/main/java/com/myorg/usermanagement/config/` - Configuration

**Task 4: Repository Classes**
- `ProfileManager-API/src/main/java/com/myorg/usermanagement/repository/` - Data access

### Phase 2-4: Backend Lambda Handlers (Weeks 2-4)

**Tasks 5-11: Lambda Handlers**
- `ProfileManager-API/src/main/java/com/myorg/usermanagement/handler/` - All handlers
  - Task 5: RegistrationHandler
  - Task 6: EmailVerificationHandler
  - Task 7: OAuth2Handler
  - Task 8: AuthLoginHandler
  - Task 9: GetProfileHandler
  - Task 10: UpdateProfileHandler
  - Task 11: AuthLogoutHandler, GetEmailPolicyHandler

**Task 12: API Gateway**
- `ProfileManager-CDK/lib/api-gateway-stack.ts` - API Gateway configuration

### Phase 5-6: Frontend (Weeks 5-6)

**Task 14: React Project & Services**
- `ProfileManager-UI/src/` - React application structure
- `ProfileManager-UI/src/services/` - API services
- `ProfileManager-UI/src/theme/` - Material-UI theme

**Task 15: Registration Component**
- `ProfileManager-UI/src/components/auth/RegistrationComponent.tsx`
- `ProfileManager-UI/src/components/auth/PasswordRequirements.tsx`

**Task 16: Login Component**
- `ProfileManager-UI/src/components/auth/LoginComponent.tsx`

**Task 17: Profile Component**
- `ProfileManager-UI/src/components/profile/ProfileComponent.tsx`

**Task 18: Routing**
- `ProfileManager-UI/src/routes/AppRoutes.tsx`
- `ProfileManager-UI/src/guards/AuthGuard.tsx`
- `ProfileManager-UI/src/components/shared/Navigation.tsx`

### Phase 7: Testing & Deployment (Week 7)

**Task 19: Deployment Pipeline**
- CI/CD configuration (GitHub Actions/Jenkins)
- Deployment scripts

**Task 20-21: Testing**
- `ProfileManager-API/src/test/` - Backend tests
- `ProfileManager-UI/src/**/*.test.tsx` - Frontend tests

## Next Steps

1. **Backend Setup**:
   ```bash
   cd ProfileManager-API
   mvn clean install
   ```

2. **Frontend Setup**:
   ```bash
   cd ProfileManager-UI
   npm install
   ```

3. **Infrastructure Setup**:
   ```bash
   cd ProfileManager-CDK
   npm install
   ```

4. **Start Implementation**:
   - Open `.kiro/specs/tasks.md`
   - Execute tasks sequentially starting with Task 1
   - Follow the 7-phase implementation plan

## Key Files Created

✅ Backend Maven project structure with pom.xml
✅ Frontend React TypeScript project with package.json
✅ Infrastructure AWS CDK project with cdk.json
✅ Database migration structure
✅ All package directories with proper Java conventions
✅ Configuration files (logback.xml, tsconfig.json, etc.)
✅ README files for each module
✅ .gitignore for all environments

## Ready for Implementation

The project structure is now complete and ready for task execution. All directories follow the conventions specified in the steering files and align with the tasks in tasks.md.
