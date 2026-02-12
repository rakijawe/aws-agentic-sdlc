-- Rollback: R3__drop_login_attempts_table.sql
-- Description: Rolls back V3__create_login_attempts_table.sql
-- WARNING: This will delete all login attempt history!

-- Drop indexes first
DROP INDEX IF EXISTS idx_login_attempts_email_timestamp;
DROP INDEX IF EXISTS idx_login_attempts_timestamp;
DROP INDEX IF EXISTS idx_login_attempts_email;

-- Drop table
DROP TABLE IF EXISTS login_attempts CASCADE;
