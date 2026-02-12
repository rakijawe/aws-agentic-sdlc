# Profile Management API Documentation

**Version**: 1.0.0  
**Base URL**: `https://your-api-gateway-url.amazonaws.com/prod`  
**Authentication**: JWT Bearer Token (passed in Authorization header)

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
4. [Request/Response Formats](#requestresponse-formats)
5. [Error Handling](#error-handling)
6. [Examples](#examples)

---

## Overview

This API provides profile management functionality including:
- Retrieving user profile data
- Updating user profile with validation
- Checking email modification policy

All endpoints return JSON responses with a standard format.

---

## Authentication

All endpoints (except email policy) require JWT authentication.

**Header Format:**
```
Authorization: Bearer <your-jwt-token>
```

**User ID Extraction:**
- User ID is extracted from the JWT token by API Gateway
- Passed to Lambda functions via path parameters or request context

---

## API Endpoints

### 1. Get User Profile

Retrieves the complete user profile including all fields and preferences.

**Endpoint:** `GET /profile`  
**Authentication:** Required  
**Requirements:** Req 15 (View Profile), Req 16 (Display Fields)

#### Request

```http
GET /profile?userId=1 HTTP/1.1
Host: your-api-gateway-url.amazonaws.com
Authorization: Bearer <jwt-token>
Content-Type: application/json
```

**Query Parameters:**
- `userId` (required): The user ID (extracted from JWT in production)

#### Response (200 OK)

```json
{
  "status": "SUCCESS",
  "data": {
    "id": 1,
    "title": "Mr",
    "firstName": "John",
    "lastName": "Doe",
    "gender": "Male",
    "age": 30,
    "email": "john.doe@example.com",
    "address": "123 Main St, City, State 12345",
    "preferences": [
      "Email Notifications",
      "SMS Alerts",
      "Newsletter"
    ]
  },
  "error": null
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| id | Long | User ID |
| title | String | Title (Mr, Ms, Mrs, Dr) - Optional |
| firstName | String | First name - Required |
| lastName | String | Last name - Required |
| gender | String | Gender (Male, Female, Other) - Required |
| age | Integer | Age (18-120) - Optional |
| email | String | Email address - Required |
| address | String | Full address - Optional |
| preferences | Array<String> | List of user preferences - Required (at least one) |

#### Error Responses

**404 Not Found** - Profile not found
```json
{
  "status": "ERROR",
  "data": null,
  "error": {
    "code": "PROFILE_NOT_FOUND",
    "message": "Profile not found for user ID: 999",
    "timestamp": "2024-02-12T10:30:00Z"
  }
}
```

**400 Bad Request** - Invalid user ID
```json
{
  "status": "ERROR",
  "data": null,
  "error": {
    "code": "INVALID_REQUEST",
    "message": "User ID not found in request",
    "timestamp": "2024-02-12T10:30:00Z"
  }
}
```

---

### 2. Update User Profile

Updates the user profile with validation.

**Endpoint:** `PUT /profile`  
**Authentication:** Required  
**Requirements:** Req 17-23 (Profile validation and update)

#### Request

```http
PUT /profile?userId=1 HTTP/1.1
Host: your-api-gateway-url.amazonaws.com
Authorization: Bearer <jwt-token>
Content-Type: application/json

{
  "title": "Mr",
  "firstName": "John",
  "lastName": "Doe",
  "gender": "Male",
  "age": 30,
  "email": "john.doe@example.com",
  "address": "123 Main St, City, State 12345",
  "preferences": [
    "Email Notifications",
    "SMS Alerts"
  ]
}
```

#### Request Body

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| title | String | No | One of: Mr, Ms, Mrs, Dr |
| firstName | String | Yes | Non-empty |
| lastName | String | Yes | Non-empty |
| gender | String | Yes | One of: Male, Female, Other |
| age | Integer | No | Range: 18-120 |
| email | String | Yes | Valid email format |
| address | String | No | Any string |
| preferences | Array<String> | Yes | At least one preference required |

#### Validation Rules

1. **Mandatory Fields**: firstName, lastName, email, gender
2. **Email Format**: Must match pattern `^[^\s@]+@[^\s@]+\.[^\s@]+$`
3. **Age Range**: If provided, must be between 18 and 120
4. **Gender**: Must be exactly "Male", "Female", or "Other"
5. **Preferences**: At least one preference must be selected
6. **Email Policy**: Email modification may be restricted (check email policy endpoint)

#### Response (200 OK)

```json
{
  "status": "SUCCESS",
  "data": {
    "message": "Profile updated successfully",
    "profile": {
      "id": 1,
      "title": "Mr",
      "firstName": "John",
      "lastName": "Doe",
      "gender": "Male",
      "age": 30,
      "email": "john.doe@example.com",
      "address": "123 Main St, City, State 12345",
      "preferences": [
        "Email Notifications",
        "SMS Alerts"
      ]
    }
  },
  "error": null
}
```

#### Error Responses

**400 Bad Request** - Validation errors
```json
{
  "status": "ERROR",
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "First name is required",
    "timestamp": "2024-02-12T10:30:00Z"
  }
}
```

**Validation Error Messages:**
- `"First name is required"`
- `"Last name is required"`
- `"Email is required"`
- `"Please enter a valid email address"`
- `"Gender selection is mandatory"`
- `"Age must be between 18 and 120"`
- `"At least one preference is required"`

**404 Not Found** - User not found
```json
{
  "status": "ERROR",
  "data": null,
  "error": {
    "code": "PROFILE_NOT_FOUND",
    "message": "Profile not found for user ID: 999",
    "timestamp": "2024-02-12T10:30:00Z"
  }
}
```

---

### 3. Get Email Modification Policy

Checks if email modification is allowed for the user.

**Endpoint:** `GET /profile/email-policy`  
**Authentication:** Required  
**Requirements:** Req 25 (Read Only Email Rule)

#### Request

```http
GET /profile/email-policy HTTP/1.1
Host: your-api-gateway-url.amazonaws.com
Authorization: Bearer <jwt-token>
Content-Type: application/json
```

#### Response (200 OK)

```json
{
  "status": "SUCCESS",
  "data": {
    "emailModificationAllowed": true
  },
  "error": null
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| emailModificationAllowed | Boolean | `true` if email can be modified, `false` if read-only |

#### Usage

Frontend should call this endpoint before rendering the profile form to determine if the email field should be:
- **Editable** (`emailModificationAllowed: true`)
- **Read-only** (`emailModificationAllowed: false`) - Display with lock icon

---

## Request/Response Formats

### Standard Response Format

All API responses follow this structure:

```json
{
  "status": "SUCCESS" | "ERROR",
  "data": <response-data> | null,
  "error": <error-details> | null
}
```

### Success Response

```json
{
  "status": "SUCCESS",
  "data": { ... },
  "error": null
}
```

### Error Response

```json
{
  "status": "ERROR",
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "timestamp": "2024-02-12T10:30:00Z"
  }
}
```

### Common HTTP Status Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 200 | OK | Successful request |
| 400 | Bad Request | Validation error or invalid request |
| 401 | Unauthorized | Missing or invalid JWT token |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Profile not found |
| 500 | Internal Server Error | Server-side error |

---

## Error Handling

### Error Codes

| Code | Description |
|------|-------------|
| `PROFILE_NOT_FOUND` | User profile does not exist |
| `VALIDATION_ERROR` | Request validation failed |
| `INVALID_REQUEST` | Malformed request |
| `INTERNAL_ERROR` | Server-side error |

### Frontend Error Handling

```typescript
try {
  const response = await fetch(`${API_BASE_URL}/profile?userId=${userId}`, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
  
  const data = await response.json();
  
  if (data.status === 'ERROR') {
    // Handle error
    console.error(data.error.message);
    showErrorToast(data.error.message);
  } else {
    // Handle success
    setProfile(data.data);
  }
} catch (error) {
  console.error('Network error:', error);
  showErrorToast('Failed to connect to server');
}
```

---

## Examples

### Example 1: Fetch User Profile

**Request:**
```bash
curl -X GET "https://api.example.com/prod/profile?userId=1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "status": "SUCCESS",
  "data": {
    "id": 1,
    "title": "Mr",
    "firstName": "John",
    "lastName": "Doe",
    "gender": "Male",
    "age": 30,
    "email": "john.doe@example.com",
    "address": "123 Main St",
    "preferences": ["Email Notifications", "SMS Alerts"]
  },
  "error": null
}
```

---

### Example 2: Update User Profile

**Request:**
```bash
curl -X PUT "https://api.example.com/prod/profile?userId=1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Dr",
    "firstName": "John",
    "lastName": "Doe",
    "gender": "Male",
    "age": 31,
    "email": "john.doe@example.com",
    "address": "456 Oak Ave",
    "preferences": ["Email Notifications", "Newsletter"]
  }'
```

**Response:**
```json
{
  "status": "SUCCESS",
  "data": {
    "message": "Profile updated successfully",
    "profile": {
      "id": 1,
      "title": "Dr",
      "firstName": "John",
      "lastName": "Doe",
      "gender": "Male",
      "age": 31,
      "email": "john.doe@example.com",
      "address": "456 Oak Ave",
      "preferences": ["Email Notifications", "Newsletter"]
    }
  },
  "error": null
}
```

---

### Example 3: Check Email Policy

**Request:**
```bash
curl -X GET "https://api.example.com/prod/profile/email-policy" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "status": "SUCCESS",
  "data": {
    "emailModificationAllowed": false
  },
  "error": null
}
```

---

### Example 4: Validation Error

**Request:**
```bash
curl -X PUT "https://api.example.com/prod/profile?userId=1" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "",
    "lastName": "Doe",
    "gender": "Male",
    "email": "invalid-email",
    "preferences": []
  }'
```

**Response:**
```json
{
  "status": "ERROR",
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "First name is required",
    "timestamp": "2024-02-12T10:30:00Z"
  }
}
```

---

## Frontend Integration

### React/TypeScript Example

```typescript
// api/profileService.ts
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL;

export interface UserProfile {
  id: number;
  title?: string;
  firstName: string;
  lastName: string;
  gender: string;
  age?: number;
  email: string;
  address?: string;
  preferences: string[];
}

export interface ApiResponse<T> {
  status: 'SUCCESS' | 'ERROR';
  data: T | null;
  error: {
    code: string;
    message: string;
    timestamp: string;
  } | null;
}

export const ProfileService = {
  async getProfile(userId: number, token: string): Promise<UserProfile> {
    const response = await axios.get<ApiResponse<UserProfile>>(
      `${API_BASE_URL}/profile?userId=${userId}`,
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    if (response.data.status === 'ERROR') {
      throw new Error(response.data.error?.message || 'Failed to fetch profile');
    }
    
    return response.data.data!;
  },

  async updateProfile(userId: number, profile: Partial<UserProfile>, token: string): Promise<UserProfile> {
    const response = await axios.put<ApiResponse<{ message: string; profile: UserProfile }>>(
      `${API_BASE_URL}/profile?userId=${userId}`,
      profile,
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    if (response.data.status === 'ERROR') {
      throw new Error(response.data.error?.message || 'Failed to update profile');
    }
    
    return response.data.data!.profile;
  },

  async getEmailPolicy(token: string): Promise<boolean> {
    const response = await axios.get<ApiResponse<{ emailModificationAllowed: boolean }>>(
      `${API_BASE_URL}/profile/email-policy`,
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    if (response.data.status === 'ERROR') {
      throw new Error(response.data.error?.message || 'Failed to fetch email policy');
    }
    
    return response.data.data!.emailModificationAllowed;
  }
};
```

---

## CORS Configuration

The API is configured with CORS to allow cross-origin requests:

**Allowed Origins:** `*` (all origins)  
**Allowed Methods:** `GET, POST, PUT, DELETE, OPTIONS`  
**Allowed Headers:** `Content-Type, Authorization`

---

## Rate Limiting

| Endpoint | Rate Limit |
|----------|------------|
| GET /profile | 100 requests/second |
| PUT /profile | 50 requests/second |
| GET /profile/email-policy | 100 requests/second |

---

## Support

For API issues or questions:
- **Backend Team**: backend-team@example.com
- **Documentation**: See `ProfileManager-API/PROFILE_BACKEND_IMPLEMENTATION.md`
- **Deployment**: See `ProfileManager-CDK/DEPLOYMENT_GUIDE.md`

---

**Last Updated**: 2024-02-12  
**API Version**: 1.0.0
