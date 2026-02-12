# User Authentication Backend

Java 17 AWS Lambda backend for user authentication, registration, and profile management.

## Technology Stack
- Java 17
- AWS Lambda
- API Gateway
- PostgreSQL (Amazon RDS)
- Maven
- AWS SES (Email)
- OAuth2 (Google, Amazon)

## Project Structure
```
src/main/java/com/myorg/usermanagement/
├── handler/          # Lambda handlers
├── service/          # Business logic
├── repository/       # Data access layer
├── model/            # Entities and DTOs
├── util/             # Utilities
├── validator/        # Validation classes
├── exception/        # Custom exceptions
└── config/           # Configuration
```

## Build
```bash
mvn clean package
```

## Test
```bash
mvn test
```

## Deploy
```bash
# Deploy using AWS CDK (see infrastructure/)
cd ../infrastructure
cdk deploy
```
