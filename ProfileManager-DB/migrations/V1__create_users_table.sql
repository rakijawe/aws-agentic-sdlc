-- Migration: V1__create_users_table.sql
-- Description: Creates the users table (Customer_Identity) for storing user account and profile data
-- Requirements: Req 2, 6, 14, 16, 18, 19, 22
-- Task: 2.1 - Create users table with all required fields

CREATE TABLE IF NOT EXISTS users (
    -- Primary key
    id BIGSERIAL PRIMARY KEY,
    
    -- Profile fields (Req 16, 18, 19)
    title VARCHAR(10),  -- Mr, Ms, Mrs, Dr
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    age INTEGER CHECK (age >= 18 AND age <= 120),
    email VARCHAR(255) NOT NULL UNIQUE,
    address TEXT,
    
    -- Authentication fields (Req 2, 6)
    password_hash VARCHAR(255),  -- BCrypt hash, nullable for social login
    email_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    verification_token_expiry TIMESTAMP,
    
    -- Social login fields (Req 4)
    auth_provider VARCHAR(50) DEFAULT 'email',  -- 'email', 'google', 'amazon'
    provider_id VARCHAR(255),  -- Provider-specific user ID
    
    -- Account security fields (Req 14)
    account_locked BOOLEAN DEFAULT FALSE,
    locked_until TIMESTAMP,
    
    -- Audit fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_account_locked ON users(account_locked);
CREATE INDEX idx_users_verification_token ON users(verification_token);
CREATE INDEX idx_users_provider ON users(auth_provider, provider_id);

-- Comments for documentation
COMMENT ON TABLE users IS 'Stores user account and profile information (Customer_Identity)';
COMMENT ON COLUMN users.title IS 'User title: Mr, Ms, Mrs, Dr';
COMMENT ON COLUMN users.gender IS 'User gender: Male, Female, Other';
COMMENT ON COLUMN users.age IS 'User age, must be between 18 and 120';
COMMENT ON COLUMN users.email IS 'User email address, unique identifier';
COMMENT ON COLUMN users.password_hash IS 'BCrypt password hash, null for social login';
COMMENT ON COLUMN users.email_verified IS 'Whether email has been verified';
COMMENT ON COLUMN users.auth_provider IS 'Authentication provider: email, google, amazon';
COMMENT ON COLUMN users.account_locked IS 'Whether account is locked due to failed login attempts';
COMMENT ON COLUMN users.locked_until IS 'Timestamp when account lock expires';
