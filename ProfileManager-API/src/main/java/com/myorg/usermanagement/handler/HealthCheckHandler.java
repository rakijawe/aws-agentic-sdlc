package com.myorg.usermanagement.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * Simple health check handler to test Lambda deployment and infrastructure.
 * This handler responds to health check requests from API Gateway.
 */
public class HealthCheckHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    
    private static final Logger log = LoggerFactory.getLogger(HealthCheckHandler.class);
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent input, Context context) {
        log.info("Health check request received");
        
        try {
            // Create health check response
            Map<String, Object> healthData = new HashMap<>();
            healthData.put("status", "UP");
            healthData.put("service", "ProfileManager-API");
            healthData.put("version", "1.0.0");
            healthData.put("timestamp", System.currentTimeMillis());
            healthData.put("environment", System.getenv("SPRING_PROFILES_ACTIVE"));
            
            // Add Lambda context information
            if (context != null) {
                healthData.put("requestId", context.getAwsRequestId());
                healthData.put("functionName", context.getFunctionName());
                healthData.put("remainingTimeMs", context.getRemainingTimeInMillis());
            }
            
            String responseBody = objectMapper.writeValueAsString(healthData);
            
            log.info("Health check successful");
            
            return createResponse(200, responseBody);
            
        } catch (Exception e) {
            log.error("Health check failed", e);
            return createErrorResponse(500, "Health check failed: " + e.getMessage());
        }
    }
    
    private APIGatewayProxyResponseEvent createResponse(int statusCode, String body) {
        APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent();
        response.setStatusCode(statusCode);
        response.setBody(body);
        
        Map<String, String> headers = new HashMap<>();
        headers.put("Content-Type", "application/json");
        headers.put("Access-Control-Allow-Origin", "*");
        headers.put("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        headers.put("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeaders(headers);
        
        return response;
    }
    
    private APIGatewayProxyResponseEvent createErrorResponse(int statusCode, String message) {
        try {
            Map<String, Object> errorBody = new HashMap<>();
            errorBody.put("status", "ERROR");
            errorBody.put("message", message);
            errorBody.put("timestamp", System.currentTimeMillis());
            
            String body = objectMapper.writeValueAsString(errorBody);
            return createResponse(statusCode, body);
        } catch (Exception e) {
            log.error("Failed to create error response", e);
            APIGatewayProxyResponseEvent response = new APIGatewayProxyResponseEvent();
            response.setStatusCode(statusCode);
            response.setBody("{\"status\":\"ERROR\",\"message\":\"Internal server error\"}");
            return response;
        }
    }
}
