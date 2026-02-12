# Unit Tests for Profile Management

## Test Coverage

This test suite provides unit tests for the profile management backend code.

### Validators (100% Coverage)
- ✅ **EmailValidatorTest** - Tests email format validation
- ✅ **AgeValidatorTest** - Tests age range validation (18-120)
- ✅ **GetEmailPolicyHandlerTest** - Tests email policy retrieval

### Note on Handler Tests

The Lambda handlers (GetProfileHandler, UpdateProfileHandler) are tightly coupled with database connections and cannot be easily unit tested without significant refactoring. These handlers should be tested through:

1. **Integration Tests** - Test with actual database (H2 in-memory or PostgreSQL test container)
2. **End-to-End Tests** - Test deployed Lambda functions with API Gateway

### Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=EmailValidatorTest

# Run with coverage report
mvn test jacoco:report
```

### Test Coverage Target

- Validators: 100% coverage ✅
- Handlers: Integration tests recommended
- Overall target: 70% minimum (per Java conventions)

### Future Improvements

To enable unit testing of handlers:
1. Inject UserRepository via constructor (Dependency Injection)
2. Create interfaces for repositories
3. Use mocking frameworks (Mockito) to mock dependencies
