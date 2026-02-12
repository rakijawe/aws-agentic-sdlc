-- Migration: V3__create_login_attempts_table.sql
-- Description: Creates the login_attempts table for tracking authentication attempts
-- Requirements: Req 14 - Account Locking
-- Task: 2.3 - Create login_attempts table

CREATE TABLE IF NOT EXISTS login_attempts (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    successful BOOLEAN NOT NULL,
    ip_address VARCHAR(45)  -- Supports both IPv4 and IPv6
);

-- Indexes for query performance
CREATE INDEX idx_login_attempts_email ON login_attempts(email);
CREATE INDEX idx_login_attempts_timestamp ON login_attempts(timestamp);
CREATE INDEX idx_login_attempts_email_timestamp ON login_attempts(email, timestamp);

-- Comments for documentation
COMMENT ON TABLE login_attempts IS 'Tracks login attempts for account security';
COMMENT ON COLUMN login_attempts.email IS 'Email address of login attempt';
COMMENT ON COLUMN login_attempts.timestamp IS 'When the login attempt occurred';
COMMENT ON COLUMN login_attempts.successful IS 'Whether the login attempt was successful';
COMMENT ON COLUMN login_attempts.ip_address IS 'IP address of the login attempt';
