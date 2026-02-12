package com.myorg.usermanagement.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.myorg.usermanagement.exception.ProfileNotFoundException;
import com.myorg.usermanagement.model.dto.ApiResponse;
import com.myorg.usermanagement.model.dto.UserProfileDTO;
import com.myorg.usermanagement.model.entity.UserEntity;
import com.myorg.usermanagement.repository.UserRepository;
import com.myorg.usermanagement.util.DatabaseUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Lambda handler for retrieving user profile.
 * Requirements: Req 15 (View Profile Page), Req 16 (Display Profile Fields)
 * Phase: 6 - Profile Management
 * Task: 9 - Implement GetProfileHandler Lambda function
 */
public class GetProfileHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    
    private static final Logger log = LoggerFactory.getLogger(GetProfileHandler.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
        log.info("GetProfileHandler invoked");
        
        Connection conn = null;
        
        try {
            // Extract user ID from JWT token (passed by API Gateway authorizer)
            Long userId = extractUserIdFromToken(input);
            log.info("Processing profile request for user ID: {}", userId);
            
            // Get database connection
            conn = DatabaseUtil.getConnection();
            UserRepository userRepository = new UserRepository(conn);
            
            // Retrieve user profile
            Optional<UserEntity> userOpt = userRepository.findByIdWithPreferences(userId);
            
            if (userOpt.isEmpty()) {
                log.warn("Profile not found for user ID: {}", userId);
                throw new ProfileNotFoundException("Profile not found for user ID: " + userId);
            }
            
            UserEntity user = userOpt.get();
            
            // Get user preferences
            List<String> preferences = userRepository.getUserPreferences(userId);
            
            // Map to DTO
            UserProfileDTO profileDTO = mapToDTO(user, preferences);
            
            // Return success response
            ApiResponse<UserProfileDTO> response = ApiResponse.success(profileDTO);
            
            log.info("Successfully retrieved profile for user ID: {}", userId);
            
            return createResponse(200, response);
            
        } catch (ProfileNotFoundException e) {
            log.error("Profile not found", e);
            return createErrorResponse(404, "PROFILE_NOT_FOUND", e.getMessage());
            
        } catch (Exception e) {
            log.error("Error retrieving profile", e);
            return createErrorResponse(500, "INTERNAL_ERROR", "An error occurred while retrieving the profile");
            
        } finally {
            DatabaseUtil.closeConnection(conn);
        }
    }
    
    /**
     * Extracts user ID from JWT token claims.
     * In production, this would be passed by API Gateway authorizer in request context.
     * 
     * @param input the API Gateway request
     * @return user ID
     */
    private Long extractUserIdFromToken(APIGatewayProxyRequestEvent input) {
        // In production, extract from: input.getRequestContext().getAuthorizer().getClaims().get("sub")
        // For now, extract from path parameters or headers for testing
        Map<String, String> pathParams = input.getPathParameters();
        if (pathParams != null && pathParams.containsKey("userId")) {
            return Long.parseLong(pathParams.get("userId"));
        }
        
        // Fallback: extract from query parameters for testing
        Map<String, String> queryParams = input.getQueryStringParameters();
        if (queryParams != null && queryParams.containsKey("userId")) {
            return Long.parseLong(queryParams.get("userId"));
        }
        
        throw new IllegalArgumentException("User ID not found in request");
    }
    
    /**
     * Maps UserEntity to UserProfileDTO.
     * 
     * @param user the user entity
     * @param preferences the user preferences
     * @return user profile DTO
     */
    private UserProfileDTO mapToDTO(UserEntity user, List<String> preferences) {
        UserProfileDTO dto = new UserProfileDTO();
        dto.setId(user.getId());
        dto.setTitle(user.getTitle());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setGender(user.getGender());
        dto.setAge(user.getAge());
        dto.setEmail(user.getEmail());
        dto.setAddress(user.getAddress());
        dto.setPreferences(preferences);
        return dto;
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
}
