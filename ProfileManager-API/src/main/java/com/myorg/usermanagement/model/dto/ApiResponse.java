package com.myorg.usermanagement.model.dto;

/**
 * Standard API response wrapper.
 */
public class ApiResponse<T> {
    
    private String status;
    private T data;
    private ErrorDetails error;
    
    // Constructors
    public ApiResponse() {
    }
    
    public ApiResponse(String status, T data) {
        this.status = status;
        this.data = data;
    }
    
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>("SUCCESS", data);
    }
    
    public static <T> ApiResponse<T> error(ErrorDetails error) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setStatus("ERROR");
        response.setError(error);
        return response;
    }
    
    // Getters and Setters
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public T getData() {
        return data;
    }
    
    public void setData(T data) {
        this.data = data;
    }
    
    public ErrorDetails getError() {
        return error;
    }
    
    public void setError(ErrorDetails error) {
        this.error = error;
    }
    
    /**
     * Error details for API responses.
     */
    public static class ErrorDetails {
        private String code;
        private String message;
        private String timestamp;
        
        public ErrorDetails() {
        }
        
        public ErrorDetails(String code, String message, String timestamp) {
            this.code = code;
            this.message = message;
            this.timestamp = timestamp;
        }
        
        public String getCode() {
            return code;
        }
        
        public void setCode(String code) {
            this.code = code;
        }
        
        public String getMessage() {
            return message;
        }
        
        public void setMessage(String message) {
            this.message = message;
        }
        
        public String getTimestamp() {
            return timestamp;
        }
        
        public void setTimestamp(String timestamp) {
            this.timestamp = timestamp;
        }
    }
}
