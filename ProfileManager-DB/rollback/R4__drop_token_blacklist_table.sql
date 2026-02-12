-- Rollback: R4__drop_token_blacklist_table.sql
-- Description: Rolls back V4__create_token_blacklist_table.sql
-- WARNING: This will delete all blacklisted tokens!

-- Drop function first
DROP FUNCTION IF EXISTS cleanup_expired_tokens();

-- Drop indexes
DROP INDEX IF EXISTS idx_token_blacklist_expiry;
DROP INDEX IF EXISTS idx_token_blacklist_token_hash;

-- Drop table
DROP TABLE IF EXISTS token_blacklist CASCADE;
