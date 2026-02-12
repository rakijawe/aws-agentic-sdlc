package com.myorg.usermanagement.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.myorg.usermanagement.model.dto.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * Lambda handler for retrieving email modification policy.
 * Requirements: Req 25 (Read Only Email Rule)
 * Phase: 6 - Profile Management
 * Task: 11 - Implement GetEmailPolicyHandler Lambda function
 */
public class GetEmailPolicyHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    
    private static final Logger log = LoggerFactory.getLogger(GetEmailPolicyHandler.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();
    
    // Environment variable to control email modification policy
    private static final String EMAIL_MODIFICATION_ALLOWED = System.getenv().getOrDefault("EMAIL_MODIFICATION_ALLOWED", "true");
    
    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
        log.info("GetEmailPolicyHandler invoked");
        
        try {
            // Parse policy from environment variable
            boolean emailModificationAllowed = Boolean.parseBoolean(EMAIL_MODIFICATION_ALLOWED);
            
            log.info("Email modification policy: {}", emailModificationAllowed);
            
            // Create response data
            Map<String, Boolean> policyData = new HashMap<>();
            policyData.put("emailModificationAllowed", emailModificationAllowed);
            
            ApiResponse<Map<String, Boolean>> response = ApiResponse.success(policyData);
            
            return createResponse(200, response);
            
        } catch (Exception e) {
            log.error("Error retrieving email policy", e);
            return createErrorResponse(500, "INTERNAL_ERROR", "An error occurred while retrieving email policy");
        }
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
            headers.put("Cache-Control", "public, max-age=3600"); // Cache for 1 hour
            
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
        Map<String, Object> errorBody = new HashMap<>();
        errorBody.put("status", "ERROR");
        errorBody.put("error", Map.of(
                "code", errorCode,
                "message", message
        ));
        
        return createResponse(statusCode, errorBody);
    }
}
