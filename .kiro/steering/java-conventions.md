{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # Java Conventions and Standards\
\
## 1. Purpose\
\
This document defines the mandatory coding standards, architectural conventions, and implementation guidelines to be followed across all Java micro services/Rest APIs generated and developed using Kiro.\
\
---\
\
## 2. Technology Stack\
\
| Layer | Standard |\
|------|---------|\
| Language | Java 17+ |\
| Framework | Spring Boot 3.x |\
| Build Tool | Maven |\
| Database | PostgreSQL (AWS RDS) |\
| API Style | REST |\
| Deployment | AWS Lambda |\
| Cloud | AWS |\
| ORM | Spring Data JPA |\
| API Documentation | OpenAPI / Swagger |\
| Logging | SLF4J + Logback |\
| Testing | JUnit 5 + Mockito |\
\
---\
\
## 3. Project Structure Standards\
\
### 3.1 Package Naming\
\
All services must follow this package structure:\
\
```\
com.<organization>.<domain>.<service>\
```\
\
Example:\
\
```\
com.myorg.usermanagement.service\
```\
\
Standard sub-packages:\
\
| Package | Purpose |\
|-------|--------|\
| controller | REST controllers |\
| service | Business logic |\
| repository | Database access layer |\
| model | Entities and DTOs |\
| config | Configuration classes |\
| util | Utility classes |\
| exception | Custom exceptions |\
| mapper | DTO-Entity mappers |\
\
---\
\
## 4. Naming Conventions\
\
### 4.1 Class Naming\
\
| Component | Convention | Example |\
|--------|-----------|---------|\
| Controller | *Controller | UserController |\
| Service | *Service | UserService |\
| Repository | *Repository | UserRepository |\
| Entity | *Entity | UserEntity |\
| DTO | *DTO | UserDTO |\
| Exception | *Exception | UserNotFoundException |\
\
### 4.2 Code Naming Rules\
\
- Classes: PascalCase  \
- Methods and Variables: camelCase  \
- Constants: UPPER_CASE  \
- Packages: lower.case  \
\
---\
\
## 5. Coding Standards\
\
### 5.1 General Rules\
\
- Use Java 17 features where applicable  \
- No hardcoded values  \
- Follow SOLID principles  \
- Maximum method length: 30 lines  \
- Cyclomatic complexity should be less than 10  \
- No unused variables or imports  \
- Avoid duplicate code  \
- Prefer immutability where possible  \
\
---\
\
## 6. Spring Boot Standards\
\
### 6.1 Controller Guidelines\
\
- Controllers must be lightweight  \
- No business logic in controllers  \
- Only delegate to service layer  \
- All controllers must be REST based  \
- Use proper HTTP status codes  \
\
Example:\
\
```\
@RestController\
@RequestMapping("/users")\
public class UserController\
```\
\
---\
\
### 6.2 Dependency Injection\
\
- Always use constructor injection  \
- Field injection is not allowed  \
\
Correct Example:\
\
```\
@Service\
public class UserService \{\
\
    private final UserRepository userRepository;\
\
    public UserService(UserRepository userRepository) \{\
        this.userRepository = userRepository;\
    \}\
\}\
```\
\
---\
\
## 7. REST API Standards\
\
### 7.1 URL Conventions\
\
- Use nouns not verbs  \
- Use plural resource names  \
\
Examples:\
\
```\
GET    /users\
POST   /users\
GET    /users/\{id\}\
PUT    /users/\{id\}\
DELETE /users/\{id\}\
```\
\
---\
\
### 7.2 Response Structure\
\
All APIs must return a standard response format:\
\
```\
\{\
  "status": "SUCCESS",\
  "data": \{\},\
  "error": null\
\}\
```\
\
---\
\
### 7.3 Error Handling\
\
Use standard HTTP status codes:\
\
| Scenario | Code |\
|--------|-----|\
| Success | 200 |\
| Created | 201 |\
| Bad Request | 400 |\
| Unauthorized | 401 |\
| Forbidden | 403 |\
| Not Found | 404 |\
| Server Error | 500 |\
\
Global exception handler must be implemented using:\
\
```\
@ControllerAdvice\
```\
\
---\
\
## 8. Database Standards (PostgreSQL / RDS)\
\
### 8.1 JPA Rules\
\
- Use Spring Data JPA  \
- Avoid native queries  \
- Use proper indexing  \
- Use pagination for large data sets  \
\
---\
\
### 8.2 Entity Standards\
\
- Use snake_case for table names  \
- Use proper column mappings  \
\
Example:\
\
```\
@Entity\
@Table(name = "user_profile")\
```\
\
---\
\
### 8.3 Transactions\
\
- Transactions only at service layer  \
- Use @Transactional annotation  \
- No transactions in controllers  \
\
---\
\
## 9. Microservices Standards\
\
- Each microservice must have single responsibility  \
- Independent database per service  \
- No cross-service database joins  \
- Communication via REST APIs only  \
- Services must be stateless  \
\
---\
\
## 10. AWS Lambda Standards\
\
### 10.1 Lambda Design\
\
- Keep functions lightweight  \
- Optimize cold start  \
- Use minimal dependencies  \
- Externalize all configurations  \
\
---\
\
### 10.2 Configuration Rules\
\
- Use environment variables  \
- Secrets must be stored in AWS Secrets Manager  \
- No credentials in code  \
\
---\
\
### 10.3 Logging\
\
- Use structured JSON logs  \
- Log to AWS CloudWatch  \
- No System.out.println statements  \
\
---\
\
## 11. Logging Standards\
\
- Use SLF4J Logger  \
- Do not use System.out  \
- Proper log levels must be used  \
\
| Scenario | Log Level |\
|--------|---------|\
| Application flow | INFO |\
| Debugging | DEBUG |\
| Errors | ERROR |\
| Detailed tracing | TRACE |\
\
Example:\
\
```\
private static final Logger log = LoggerFactory.getLogger(UserService.class);\
```\
\
---\
\
## 12. Security Standards\
\
- Use OAuth/JWT for authentication  \
- Validate all user inputs  \
- Prevent SQL Injection  \
- Encrypt sensitive data  \
- No sensitive data in logs  \
\
---\
\
## 13. Testing Standards\
\
### 13.1 Unit Testing\
\
- Use JUnit 5  \
- Minimum 80% code coverage  \
- Use Mockito for mocking  \
- No database dependency in unit tests  \
\
---\
\
### 13.2 Integration Testing\
\
- Use test containers where needed  \
- Mock external services  \
- API contract tests recommended  \
\
---\
\
## 14. Performance Guidelines\
\
- Pagination mandatory for list APIs  \
- Proper DB indexing  \
- Avoid N+1 queries  \
- Use caching where applicable  \
\
---\
\
## 15. Documentation Standards\
\
- Swagger/OpenAPI mandatory  \
- JavaDoc for all public methods  \
- Proper README for each service  \
\
---\
\
## 16. CI/CD Standards\
\
- Maven based build  \
- Sonar quality gates  \
- Automated unit tests  \
- Docker packaging  \
- AWS Lambda deployment pipeline  \
\
---\
\
## 17. Code Quality Rules\
\
- No critical Sonar issues  \
- No security vulnerabilities  \
- Zero build warnings  \
- Consistent formatting  \
\
---\
\
## 18. Kiro Specific Guidelines\
\
- All generated code must adhere to this document  \
- Custom code must not modify generated core files  \
- Business logic must reside only in service layer  \
- Generated artifacts should not be manually edited  \
\
---\
\
### Compliance\
\
All developers and generated code must strictly adhere to these standards. Any deviation requires prior approval from the architecture team.\
}