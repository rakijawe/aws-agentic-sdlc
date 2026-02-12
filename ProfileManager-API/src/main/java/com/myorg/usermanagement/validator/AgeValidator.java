package com.myorg.usermanagement.validator;

/**
 * Validator for age range.
 * Requirement: Req 20 - Age Validation
 */
public class AgeValidator {
    
    private static final int MIN_AGE = 18;
    private static final int MAX_AGE = 120;
    
    /**
     * Validates age is within acceptable range.
     * 
     * @param age the age to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValid(Integer age) {
        if (age == null) {
            return false;
        }
        return age >= MIN_AGE && age <= MAX_AGE;
    }
    
    /**
     * Gets the validation error message.
     * 
     * @return the error message
     */
    public static String getErrorMessage() {
        return "Age must be between 18 and 120";
    }
}
