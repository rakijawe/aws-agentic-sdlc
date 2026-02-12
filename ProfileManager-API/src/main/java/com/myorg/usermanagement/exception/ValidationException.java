package com.myorg.usermanagement.exception;

import java.util.HashMap;
import java.util.Map;

/**
 * Exception thrown when validation fails.
 */
public class ValidationException extends RuntimeException {
    
    private Map<String, String> fieldErrors;
    
    public ValidationException(String message) {
        super(message);
        this.fieldErrors = new HashMap<>();
    }
    
    public ValidationException(String message, Map<String, String> fieldErrors) {
        super(message);
        this.fieldErrors = fieldErrors;
    }
    
    public Map<String, String> getFieldErrors() {
        return fieldErrors;
    }
    
    public void addFieldError(String field, String error) {
        this.fieldErrors.put(field, error);
    }
}
