package com.myorg.usermanagement.validator;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for AgeValidator
 * Tests age range validation (18-120)
 */
class AgeValidatorTest {

    private final AgeValidator validator = new AgeValidator();

    @Test
    void testValidAge_MinimumBoundary() {
        assertTrue(validator.isValid(18));
    }

    @Test
    void testValidAge_MaximumBoundary() {
        assertTrue(validator.isValid(120));
    }

    @Test
    void testValidAge_MiddleRange() {
        assertTrue(validator.isValid(25));
        assertTrue(validator.isValid(50));
        assertTrue(validator.isValid(75));
    }

    @Test
    void testInvalidAge_BelowMinimum() {
        assertFalse(validator.isValid(17));
        assertFalse(validator.isValid(0));
        assertFalse(validator.isValid(-5));
    }

    @Test
    void testInvalidAge_AboveMaximum() {
        assertFalse(validator.isValid(121));
        assertFalse(validator.isValid(150));
    }

    @Test
    void testNullAge() {
        assertFalse(validator.isValid(null));
    }
}
