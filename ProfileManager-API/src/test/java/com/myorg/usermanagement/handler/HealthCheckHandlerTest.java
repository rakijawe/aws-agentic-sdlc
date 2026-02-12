package com.myorg.usermanagement.handler;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

/**
 * Unit tests for HealthCheckHandler.
 */
class HealthCheckHandlerTest {
    
    private HealthCheckHandler handler;
    private ObjectMapper objectMapper;
    
    @Mock
    private Context mockContext;
    
    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        handler = new HealthCheckHandler();
        objectMapper = new ObjectMapper();
        
        // Mock context
        when(mockContext.getAwsRequestId()).thenReturn("test-request-id");
        when(mockContext.getFunctionName()).thenReturn("test-function");
        when(mockContext.getRemainingTimeInMillis()).thenReturn(30000);
    }
    
    @Test
    void testHealthCheckReturns200() {
        // Arrange
        APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
        request.setPath("/health");
        request.setHttpMethod("GET");
        
        // Act
        APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
        
        // Assert
        assertNotNull(response);
        assertEquals(200, response.getStatusCode());
        assertNotNull(response.getBody());
    }
    
    @Test
    void testHealthCheckResponseContainsStatus() throws Exception {
        // Arrange
        APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
        request.setPath("/health");
        
        // Act
        APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
        
        // Assert
        JsonNode responseBody = objectMapper.readTree(response.getBody());
        assertTrue(responseBody.has("status"));
        assertEquals("UP", responseBody.get("status").asText());
    }
    
    @Test
    void testHealthCheckResponseContainsServiceInfo() throws Exception {
        // Arrange
        APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
        
        // Act
        APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
        
        // Assert
        JsonNode responseBody = objectMapper.readTree(response.getBody());
        assertTrue(responseBody.has("service"));
        assertTrue(responseBody.has("version"));
        assertTrue(responseBody.has("timestamp"));
        assertEquals("ProfileManager-API", responseBody.get("service").asText());
        assertEquals("1.0.0", responseBody.get("version").asText());
    }
    
    @Test
    void testHealthCheckResponseContainsContextInfo() throws Exception {
        // Arrange
        APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
        
        // Act
        APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
        
        // Assert
        JsonNode responseBody = objectMapper.readTree(response.getBody());
        assertTrue(responseBody.has("requestId"));
        assertTrue(responseBody.has("functionName"));
        assertTrue(responseBody.has("remainingTimeMs"));
        assertEquals("test-request-id", responseBody.get("requestId").asText());
        assertEquals("test-function", responseBody.get("functionName").asText());
    }
    
    @Test
    void testHealthCheckResponseHasCorsHeaders() {
        // Arrange
        APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
        
        // Act
        APIGatewayProxyResponseEvent response = handler.handleRequest(request, mockContext);
        
        // Assert
        assertNotNull(response.getHeaders());
        assertTrue(response.getHeaders().containsKey("Content-Type"));
        assertTrue(response.getHeaders().containsKey("Access-Control-Allow-Origin"));
        assertEquals("application/json", response.getHeaders().get("Content-Type"));
        assertEquals("*", response.getHeaders().get("Access-Control-Allow-Origin"));
    }
    
    @Test
    void testHealthCheckWithNullContext() {
        // Arrange
        APIGatewayProxyRequestEvent request = new APIGatewayProxyRequestEvent();
        
        // Act
        APIGatewayProxyResponseEvent response = handler.handleRequest(request, null);
        
        // Assert
        assertNotNull(response);
        assertEquals(200, response.getStatusCode());
    }
}
