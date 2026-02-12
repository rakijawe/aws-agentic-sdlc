-- Rollback: R2__drop_user_preferences_table.sql
-- Description: Rolls back V2__create_user_preferences_table.sql
-- WARNING: This will delete all user preferences data!

-- Drop indexes first
DROP INDEX IF EXISTS idx_user_preferences_user_id;

-- Drop table
DROP TABLE IF EXISTS user_preferences CASCADE;
