---
inclusion: always
---

# Java Conventions and Standards

## 1. Purpose

This document defines the mandatory coding standards, architectural conventions, and implementation guidelines to be followed across all Java microservices/REST APIs generated and developed using Kiro.

---

## 2. Technology Stack

| Layer | Standard |
|------|---------|
| Language | Java 17+ |
| Runtime | AWS Lambda |
| Build Tool | Maven/Gradle |
| Database | PostgreSQL (AWS RDS) / Oracle |
| API Style | REST |
| Deployment | AWS Lambda |
| Cloud | AWS |
| Data Access | JDBC, SQL2o, or lightweight ORM |
| API Documentation | OpenAPI / Swagger |
| Logging | SLF4J + Logback |
| Testing | JUnit 5 + Mockito |

---

## 3. Project Structure Standards

### 3.1 Package Naming

All services must follow this package structure:

```
com.<organization>.<domain>.<service>
```

Example:

```
com.myorg.usermanagement.service
```

Standard sub-packages:

| Package | Purpose |
|---------|---------|
| handler | Lambda handlers / API handlers |
| service | Business logic |
| repository | Database access layer |
| model | Entities and DTOs |
| config | Configuration classes |
| util | Utility classes |
| exception | Custom exceptions |
| mapper | DTO-Entity mappers |

---

## 4. Naming Conventions

### 4.1 Class Naming

| Component | Convention | Example |
|-----------|-----------|---------|
| Handler | *Handler | UserHandler |
| Service | *Service | UserService |
| Repository | *Repository | UserRepository |
| Entity | *Entity | UserEntity |
| DTO | *DTO | UserDTO |
| Exception | *Exception | UserNotFoundException |

### 4.2 Code Naming Rules

- Classes: PascalCase
- Methods and Variables: camelCase
- Constants: UPPER_CASE
- Packages: lower.case

---

## 5. Coding Standards

### 5.1 General Rules

- Use Java 17 features where applicable
- No hardcoded values
- Follow SOLID principles
- Maximum method length: 30 lines
- Cyclomatic complexity should be less than 10
- No unused variables or imports
- Avoid duplicate code
- Prefer immutability where possible

---

## 6. AWS Lambda Standards

### 6.1 Lambda Handler Guidelines

- Handlers must be lightweight
- No business logic in handlers
- Only delegate to service layer
- Use proper HTTP status codes in API Gateway responses

Example:

```java
public class UserHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    
    private final UserService userService;
    
    public UserHandler() {
        this.userService = new UserService();
    }
    
    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
        // Delegate to service layer
        return userService.processRequest(input);
    }
}
```

---

### 6.2 Dependency Injection

- Use constructor injection for dependencies
- Initialize dependencies in constructor
- Keep Lambda handlers stateless

Correct Example:

```java
public class UserService {

    private final UserRepository userRepository;

    public UserService() {
        this.userRepository = new UserRepository();
    }
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

---

## 7. REST API Standards

### 7.1 URL Conventions

- Use nouns not verbs
- Use plural resource names

Examples:

```
GET    /users
POST   /users
GET    /users/{id}
PUT    /users/{id}
DELETE /users/{id}
```

---

### 7.2 Response Structure

All APIs must return a standard response format:

```json
{
  "status": "SUCCESS",
  "data": {},
  "error": null
}
```

---

### 7.3 Error Handling

Use standard HTTP status codes:

| Scenario | Code |
|----------|------|
| Success | 200 |
| Created | 201 |
| Bad Request | 400 |
| Unauthorized | 401 |
| Forbidden | 403 |
| Not Found | 404 |
| Server Error | 500 |

Global exception handler must be implemented in Lambda handlers.

---

## 8. Database Standards (PostgreSQL / Oracle)

### 8.1 Data Access Rules

- Use JDBC or lightweight ORM (SQL2o, JDBI)
- Use parameterized queries to prevent SQL injection
- Avoid N+1 queries
- Use proper indexing
- Use pagination for large data sets

---

### 8.2 Entity Standards

- Use snake_case for table names
- Use proper column mappings

Example:

```java
@Table(name = "user_profile")
public class UserEntity {
    @Column(name = "user_id")
    private Long userId;
    
    @Column(name = "first_name")
    private String firstName;
}
```

---

### 8.3 Transactions

- Transactions only at service layer
- Use database transaction management
- No transactions in handlers

---

## 9. Microservices Standards

- Each microservice must have single responsibility
- Independent database per service
- No cross-service database joins
- Communication via REST APIs only
- Services must be stateless

---

## 10. AWS Lambda Best Practices

### 10.1 Lambda Design

- Keep functions lightweight
- Optimize cold start (minimize dependencies)
- Use minimal dependencies
- Externalize all configurations
- Reuse connections (database, HTTP clients)

---

### 10.2 Configuration Rules

- Use environment variables
- Secrets must be stored in AWS Secrets Manager
- No credentials in code
- Use AWS Systems Manager Parameter Store for configuration

---

### 10.3 Logging

- Use structured JSON logs
- Log to AWS CloudWatch
- No System.out.println statements
- Include correlation IDs for tracing

---

## 11. Logging Standards

- Use SLF4J Logger
- Do not use System.out
- Proper log levels must be used

| Scenario | Log Level |
|----------|-----------|
| Application flow | INFO |
| Debugging | DEBUG |
| Errors | ERROR |
| Detailed tracing | TRACE |

Example:

```java
private static final Logger log = LoggerFactory.getLogger(UserService.class);

log.info("Processing user request for userId: {}", userId);
log.error("Error processing user: {}", userId, exception);
```

---

## 12. Security Standards

- Use OAuth/JWT for authentication
- Validate all user inputs
- Prevent SQL Injection (use parameterized queries)
- Encrypt sensitive data
- No sensitive data in logs
- Use AWS IAM roles for Lambda permissions
- Implement rate limiting at API Gateway level

---

## 13. Testing Standards

### 13.1 Unit Testing

- Use JUnit 5
- Minimum 70% code coverage
- Use Mockito for mocking
- No database dependency in unit tests

Example:

```java
@Test
void testGetUser() {
    UserRepository mockRepo = mock(UserRepository.class);
    when(mockRepo.findById(1L)).thenReturn(Optional.of(new UserEntity()));
    
    UserService service = new UserService(mockRepo);
    UserDTO result = service.getUser(1L);
    
    assertNotNull(result);
}
```

---

### 13.2 Integration Testing

- Use test containers where needed
- Mock external services
- API contract tests recommended
- Test Lambda handlers with sample events

---

## 14. Performance Guidelines

- Pagination mandatory for list APIs
- Proper DB indexing
- Avoid N+1 queries
- Use caching where applicable (ElastiCache)
- Connection pooling for database
- Async processing for long-running tasks

---

## 15. Documentation Standards

- Swagger/OpenAPI mandatory
- JavaDoc for all public methods
- Proper README for each service
- Document environment variables
- Document API Gateway endpoints

---

## 16. CI/CD Standards

- Maven/Gradle based build
- Sonar quality gates
- Automated unit tests
- AWS SAM or CloudFormation for deployment
- AWS Lambda deployment pipeline
- Automated security scanning

---

## 17. Code Quality Rules

- No critical Sonar issues
- No security vulnerabilities
- Zero build warnings
- Consistent formatting
- Follow Google Java Style Guide or similar

---

## 18. API Gateway Integration

- Use API Gateway for all Lambda functions
- Implement request validation at API Gateway
- Use API Gateway stages (dev, test, prod)
- Enable CloudWatch logging for API Gateway
- Implement throttling and rate limiting

---

## 19. Error Response Format

Standard error response:

```json
{
  "status": "ERROR",
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with id 123 not found",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

---

## 20. Kiro Specific Guidelines

- All generated code must adhere to this document
- Custom code must not modify generated core files
- Business logic must reside only in service layer
- Generated artifacts should not be manually edited
- Follow serverless best practices

---

### Compliance

All developers and generated code must strictly adhere to these standards. Any deviation requires prior approval from the architecture team.
