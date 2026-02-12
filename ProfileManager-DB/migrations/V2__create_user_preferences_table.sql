-- Migration: V2__create_user_preferences_table.sql
-- Description: Creates the user_preferences table for storing user notification preferences
-- Requirements: Req 22 - Preferences Selection
-- Task: 2.2 - Create user_preferences table

CREATE TABLE IF NOT EXISTS user_preferences (
    user_id BIGINT NOT NULL,
    preference VARCHAR(100) NOT NULL,
    
    -- Foreign key to users table
    CONSTRAINT fk_user_preferences_user_id 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE,
    
    -- Composite primary key (user can have multiple preferences)
    PRIMARY KEY (user_id, preference)
);

-- Index for join performance
CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);

-- Comments for documentation
COMMENT ON TABLE user_preferences IS 'Stores user notification preferences';
COMMENT ON COLUMN user_preferences.user_id IS 'Reference to users table';
COMMENT ON COLUMN user_preferences.preference IS 'Preference type: Email Notifications, SMS Notifications, App Notifications';

-- Insert sample valid preferences (optional, for reference)
-- Valid preferences: 'Email Notifications', 'SMS Notifications', 'App Notifications'
