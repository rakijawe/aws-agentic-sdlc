-- Rollback: R1__drop_users_table.sql
-- Description: Rolls back V1__create_users_table.sql
-- WARNING: This will delete all user data!

-- Drop indexes first
DROP INDEX IF EXISTS idx_users_provider;
DROP INDEX IF EXISTS idx_users_verification_token;
DROP INDEX IF EXISTS idx_users_account_locked;
DROP INDEX IF EXISTS idx_users_email;

-- Drop table
DROP TABLE IF EXISTS users CASCADE;
