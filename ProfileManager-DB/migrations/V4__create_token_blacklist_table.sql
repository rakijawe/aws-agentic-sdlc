-- Migration: V4__create_token_blacklist_table.sql
-- Description: Creates the token_blacklist table for storing invalidated JWT tokens
-- Requirements: Req 9 - Successful Login (logout flow)
-- Task: 2.4 - Create token_blacklist table for logout

CREATE TABLE IF NOT EXISTS token_blacklist (
    id BIGSERIAL PRIMARY KEY,
    token_hash VARCHAR(255) NOT NULL UNIQUE,  -- SHA-256 hash of JWT token
    expiry TIMESTAMP NOT NULL,  -- When the token expires
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for query performance
CREATE INDEX idx_token_blacklist_token_hash ON token_blacklist(token_hash);
CREATE INDEX idx_token_blacklist_expiry ON token_blacklist(expiry);

-- Comments for documentation
COMMENT ON TABLE token_blacklist IS 'Stores invalidated JWT tokens for logout functionality';
COMMENT ON COLUMN token_blacklist.token_hash IS 'SHA-256 hash of the JWT token';
COMMENT ON COLUMN token_blacklist.expiry IS 'When the token expires (for cleanup)';
COMMENT ON COLUMN token_blacklist.created_at IS 'When the token was blacklisted';

-- Optional: Create a function to clean up expired tokens
CREATE OR REPLACE FUNCTION cleanup_expired_tokens()
RETURNS void AS $$
BEGIN
    DELETE FROM token_blacklist WHERE expiry < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Optional: Schedule cleanup (requires pg_cron extension or external scheduler)
-- SELECT cron.schedule('cleanup-tokens', '0 * * * *', 'SELECT cleanup_expired_tokens()');
