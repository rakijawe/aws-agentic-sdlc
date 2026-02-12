package com.myorg.usermanagement.validator;

import com.myorg.usermanagement.exception.ValidationException;
import com.myorg.usermanagement.model.dto.ProfileUpdateRequest;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Validator for profile update requests.
 * Requirements: Req 17, 19, 20, 21, 22 - Profile validation
 */
public class ProfileValidator {
    
    private static final List<String> VALID_GENDERS = List.of("Male", "Female", "Other");
    private static final List<String> VALID_TITLES = List.of("Mr", "Ms", "Mrs", "Dr");
    
    /**
     * Validates a profile update request.
     * 
     * @param request the profile update request
     * @throws ValidationException if validation fails
     */
    public static void validate(ProfileUpdateRequest request) {
        Map<String, String> errors = new HashMap<>();
        
        // Req 17: Mandatory fields validation
        if (request.getFirstName() == null || request.getFirstName().trim().isEmpty()) {
            errors.put("firstName", "First Name is required");
        }
        
        if (request.getLastName() == null || request.getLastName().trim().isEmpty()) {
            errors.put("lastName", "Last Name is required");
        }
        
        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            errors.put("email", "Email is required");
        } else if (!EmailValidator.isValid(request.getEmail())) {
            // Req 21: Email format validation
            errors.put("email", EmailValidator.getErrorMessage());
        }
        
        if (request.getGender() == null || request.getGender().trim().isEmpty()) {
            // Req 19: Gender validation
            errors.put("gender", "Gender selection is mandatory");
        } else if (!VALID_GENDERS.contains(request.getGender())) {
            errors.put("gender", "Gender must be one of: Male, Female, Other");
        }
        
        // Req 20: Age validation
        if (request.getAge() != null && !AgeValidator.isValid(request.getAge())) {
            errors.put("age", AgeValidator.getErrorMessage());
        }
        
        // Req 22: Preferences validation
        if (request.getPreferences() == null || request.getPreferences().isEmpty()) {
            errors.put("preferences", "At least one preference is required");
        }
        
        // Req 18: Title validation (optional field)
        if (request.getTitle() != null && !request.getTitle().trim().isEmpty() 
                && !VALID_TITLES.contains(request.getTitle())) {
            errors.put("title", "Title must be one of: Mr, Ms, Mrs, Dr");
        }
        
        if (!errors.isEmpty()) {
            throw new ValidationException("Validation failed", errors);
        }
    }
}
