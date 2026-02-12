package com.myorg.usermanagement.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.myorg.usermanagement.exception.ProfileNotFoundException;
import com.myorg.usermanagement.exception.ValidationException;
import com.myorg.usermanagement.model.dto.ApiResponse;
import com.myorg.usermanagement.model.dto.ProfileUpdateRequest;
import com.myorg.usermanagement.model.dto.UserProfileDTO;
import com.myorg.usermanagement.model.entity.UserEntity;
import com.myorg.usermanagement.repository.UserRepository;
import com.myorg.usermanagement.util.DatabaseUtil;
import com.myorg.usermanagement.validator.ProfileValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Lambda handler for updating user profile.
 * Requirements: Req 17-23, 25 (Profile validation and update)
 * Phase: 6 - Profile Management
 * Task: 10 - Implement UpdateProfileHandler Lambda function
 */
public class UpdateProfileHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    
    private static final Logger log = LoggerFactory.getLogger(UpdateProfileHandler.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
        log.info("UpdateProfileHandler invoked");
        
        Connection conn = null;
        
        try {
            // Extract user ID from JWT token
            Long userId = extractUserIdFromToken(input);
            log.info("Processing profile update for user ID: {}", userId);
            
            // Parse request body
            ProfileUpdateRequest updateRequest = objectMapper.readValue(
                    input.getBody(),
                    ProfileUpdateRequest.class
            );
            
            // Validate request
            ProfileValidator.validate(updateRequest);
            log.info("Profile validation passed for user ID: {}", userId);
            
            // Get database connection
            conn = DatabaseUtil.getConnection();
            UserRepository userRepository = new UserRepository(conn);
            
            // Check if user exists
            Optional<UserEntity> userOpt = userRepository.findByIdWithPreferences(userId);
            if (userOpt.isEmpty()) {
                log.warn("Profile not found for user ID: {}", userId);
                throw new ProfileNotFoundException("Profile not found for user ID: " + userId);
            }
            
            UserEntity user = userOpt.get();
            
            // Update user entity with new values
            user.setTitle(updateRequest.getTitle());
            user.setFirstName(updateRequest.getFirstName());
            user.setLastName(updateRequest.getLastName());
            user.setGender(updateRequest.getGender());
            user.setAge(updateRequest.getAge());
            user.setEmail(updateRequest.getEmail());
            user.setAddress(updateRequest.getAddress());
            
            // Update profile in database
            boolean profileUpdated = userRepository.updateProfile(user);
            if (!profileUpdated) {
                throw new RuntimeException("Failed to update profile");
            }
            
            // Update preferences
            boolean preferencesUpdated = userRepository.updatePreferences(userId, updateRequest.getPreferences());
            if (!preferencesUpdated) {
                throw new RuntimeException("Failed to update preferences");
            }
            
            // Commit transaction
            DatabaseUtil.commit(conn);
            
            log.info("Successfully updated profile for user ID: {}", userId);
            
            // Return success response
            Map<String, String> responseData = new HashMap<>();
            responseData.put("message", "Profile updated successfully");
            responseData.put("userId", userId.toString());
            
            ApiResponse<Map<String, String>> response = ApiResponse.success(responseData);
            
            return createResponse(200, response);
            
        } catch (ValidationException e) {
            log.error("Validation failed", e);
            DatabaseUtil.rollback(conn);
            return createValidationErrorResponse(e);
            
        } catch (ProfileNotFoundException e) {
            log.error("Profile not found", e);
            DatabaseUtil.rollback(conn);
            return createErrorResponse(404, "PROFILE_NOT_FOUND", e.getMessage());
            
        } catch (Exception e) {
            log.error("Error updating profile", e);
            DatabaseUtil.rollback(conn);
            return createErrorResponse(500, "INTERNAL_ERROR", "An error occurred while updating the profile");
            
        } finally {
            DatabaseUtil.closeConnection(conn);
        }
    }
    
    /**
     * Extracts user ID from JWT token claims.
     * 
     * @param input the API Gateway request
     * @return user ID
     */
    private Long extractUserIdFromToken(APIGatewayProxyRequestEvent input) {
        // In production, extract from: input.getRequestContext().getAuthorizer().getClaims().get("sub")
        Map<String, String> pathParams = input.getPathParameters();
        if (pathParams != null && pathParams.containsKey("userId")) {
            return Long.parseLong(pathParams.get("userId"));
        }
        
        Map<String, String> queryParams = input.getQueryStringParameters();
        if (queryParams != null && queryParams.containsKey("userId")) {
            return Long.parseLong(queryParams.get("userId"));
        }
        
        throw new IllegalArgumentException("User ID not found in request");
    }
    
    /**
     * Creates a success response.
     * 
     * @param statusCode the HTTP status code
     * @param body the response body
     * @return API Gateway response
     */
    private APIGatewayProxyResponseEvent createResponse(int statusCode, Object body) {
        try {
            Map<String, String> headers = new HashMap<>();
            headers.put("Content-Type", "application/json");
            headers.put("Access-Control-Allow-Origin", "*");
            
            return new APIGatewayProxyResponseEvent()
                    .withStatusCode(statusCode)
                    .withHeaders(headers)
                    .withBody(objectMapper.writeValueAsString(body));
        } catch (Exception e) {
            log.error("Error creating response", e);
            return new APIGatewayProxyResponseEvent()
                    .withStatusCode(500)
                    .withBody("{\"error\":\"Internal server error\"}");
        }
    }
    
    /**
     * Creates an error response.
     * 
     * @param statusCode the HTTP status code
     * @param errorCode the error code
     * @param message the error message
     * @return API Gateway response
     */
    private APIGatewayProxyResponseEvent createErrorResponse(int statusCode, String errorCode, String message) {
        ApiResponse.ErrorDetails error = new ApiResponse.ErrorDetails(
                errorCode,
                message,
                Instant.now().toString()
        );
        ApiResponse<Object> response = ApiResponse.error(error);
        return createResponse(statusCode, response);
    }
    
    /**
     * Creates a validation error response with field-specific errors.
     * 
     * @param e the validation exception
     * @return API Gateway response
     */
    private APIGatewayProxyResponseEvent createValidationErrorResponse(ValidationException e) {
        Map<String, Object> errorBody = new HashMap<>();
        errorBody.put("status", "ERROR");
        errorBody.put("error", Map.of(
                "code", "VALIDATION_ERROR",
                "message", e.getMessage(),
                "fieldErrors", e.getFieldErrors(),
                "timestamp", Instant.now().toString()
        ));
        
        return createResponse(400, errorBody);
    }
}
