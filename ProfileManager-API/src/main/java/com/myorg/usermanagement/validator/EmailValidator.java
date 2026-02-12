package com.myorg.usermanagement.validator;

import java.util.regex.Pattern;

/**
 * Validator for email format.
 * Requirement: Req 7, 13, 21 - Email Format Validation
 */
public class EmailValidator {
    
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    
    /**
     * Validates email format.
     * 
     * @param email the email to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValid(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email).matches();
    }
    
    /**
     * Gets the validation error message.
     * 
     * @return the error message
     */
    public static String getErrorMessage() {
        return "Please enter a valid email address";
    }
}
