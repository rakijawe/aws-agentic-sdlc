package com.myorg.usermanagement.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

/**
 * Stream-based Lambda handler that routes requests to appropriate handlers.
 * This is the main entry point for the Lambda function.
 */
public class StreamLambdaHandler implements RequestStreamHandler {
    
    private static final Logger log = LoggerFactory.getLogger(StreamLambdaHandler.class);
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HealthCheckHandler healthCheckHandler = new HealthCheckHandler();
    
    @Override
    public void handleRequest(InputStream input, OutputStream output, Context context) throws IOException {
        log.info("Lambda function invoked");
        
        try {
            // Parse the input stream
            JsonNode event = objectMapper.readTree(input);
            
            // Extract path and HTTP method
            String path = event.has("path") ? event.get("path").asText() : "/";
            String httpMethod = event.has("httpMethod") ? event.get("httpMethod").asText() : "GET";
            
            log.info("Request: {} {}", httpMethod, path);
            
            // Route to appropriate handler
            String responseJson;
            if (path.equals("/health") || path.equals("/actuator/health")) {
                // Health check endpoint
                responseJson = handleHealthCheck(event, context);
            } else {
                // Default response for unknown paths
                responseJson = handleNotFound(path);
            }
            
            // Write response to output stream
            output.write(responseJson.getBytes());
            
        } catch (Exception e) {
            log.error("Error processing request", e);
            String errorResponse = createErrorResponse(500, "Internal server error: " + e.getMessage());
            output.write(errorResponse.getBytes());
        }
    }
    
    private String handleHealthCheck(JsonNode event, Context context) throws IOException {
        Map<String, Object> healthData = new HashMap<>();
        healthData.put("status", "UP");
        healthData.put("service", "ProfileManager-API");
        healthData.put("version", "1.0.0");
        healthData.put("timestamp", System.currentTimeMillis());
        healthData.put("environment", System.getenv("SPRING_PROFILES_ACTIVE"));
        
        if (context != null) {
            healthData.put("requestId", context.getAwsRequestId());
            healthData.put("functionName", context.getFunctionName());
            healthData.put("remainingTimeMs", context.getRemainingTimeInMillis());
        }
        
        return createSuccessResponse(200, healthData);
    }
    
    private String handleNotFound(String path) throws IOException {
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("status", "ERROR");
        errorData.put("message", "Path not found: " + path);
        errorData.put("availableEndpoints", new String[]{"/health", "/actuator/health"});
        
        return createSuccessResponse(404, errorData);
    }
    
    private String createSuccessResponse(int statusCode, Object data) throws IOException {
        Map<String, Object> response = new HashMap<>();
        response.put("statusCode", statusCode);
        response.put("body", objectMapper.writeValueAsString(data));
        
        Map<String, String> headers = new HashMap<>();
        headers.put("Content-Type", "application/json");
        headers.put("Access-Control-Allow-Origin", "*");
        headers.put("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        headers.put("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.put("headers", headers);
        
        return objectMapper.writeValueAsString(response);
    }
    
    private String createErrorResponse(int statusCode, String message) {
        try {
            Map<String, Object> errorData = new HashMap<>();
            errorData.put("status", "ERROR");
            errorData.put("message", message);
            errorData.put("timestamp", System.currentTimeMillis());
            
            return createSuccessResponse(statusCode, errorData);
        } catch (Exception e) {
            log.error("Failed to create error response", e);
            return "{\"statusCode\":500,\"body\":\"{\\\"status\\\":\\\"ERROR\\\",\\\"message\\\":\\\"Internal server error\\\"}\"}";
        }
    }
}
