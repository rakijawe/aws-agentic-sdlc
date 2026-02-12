package com.myorg.usermanagement.validator;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for EmailValidator
 * Tests email format validation logic
 */
class EmailValidatorTest {

    private final EmailValidator validator = new EmailValidator();

    @Test
    void testValidEmail() {
        assertTrue(validator.isValid("john.doe@example.com"));
        assertTrue(validator.isValid("user+tag@domain.co.uk"));
        assertTrue(validator.isValid("test_user@test-domain.com"));
    }

    @Test
    void testInvalidEmail_NoAtSymbol() {
        assertFalse(validator.isValid("invalidemail.com"));
    }

    @Test
    void testInvalidEmail_NoDomain() {
        assertFalse(validator.isValid("user@"));
    }

    @Test
    void testInvalidEmail_NoLocalPart() {
        assertFalse(validator.isValid("@domain.com"));
    }

    @Test
    void testInvalidEmail_WithSpaces() {
        assertFalse(validator.isValid("user name@domain.com"));
    }

    @Test
    void testInvalidEmail_MultipleAtSymbols() {
        assertFalse(validator.isValid("user@@domain.com"));
    }

    @Test
    void testNullEmail() {
        assertFalse(validator.isValid(null));
    }

    @Test
    void testEmptyEmail() {
        assertFalse(validator.isValid(""));
    }

    @Test
    void testBlankEmail() {
        assertFalse(validator.isValid("   "));
    }
}
