-- Sample Data for Testing
-- This script inserts sample data for testing the profile management functionality

-- Insert sample users
INSERT INTO users (
    title, first_name, last_name, gender, age, email, address,
    password_hash, email_verified, auth_provider, account_locked
) VALUES
    ('Mr', 'John', 'Doe', 'Male', 30, 'john.doe@example.com', '123 Main St, New York, NY 10001',
     '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE, 'email', FALSE),
    
    ('Ms', 'Jane', 'Smith', 'Female', 28, 'jane.smith@example.com', '456 Oak Ave, Los Angeles, CA 90001',
     '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE, 'email', FALSE),
    
    ('Dr', 'Robert', 'Johnson', 'Male', 45, 'robert.johnson@example.com', '789 Pine Rd, Chicago, IL 60601',
     '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890', TRUE, 'email', FALSE),
    
    ('Mrs', 'Emily', 'Williams', 'Female', 35, 'emily.williams@example.com', '321 Elm St, Houston, TX 77001',
     NULL, TRUE, 'google', FALSE),  -- Social login user
    
    (NULL, 'Michael', 'Brown', 'Other', 25, 'michael.brown@example.com', '654 Maple Dr, Phoenix, AZ 85001',
     '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890', FALSE, 'email', FALSE);  -- Unverified user

-- Insert sample preferences
INSERT INTO user_preferences (user_id, preference) VALUES
    (1, 'Email Notifications'),
    (1, 'SMS Notifications'),
    (2, 'Email Notifications'),
    (2, 'App Notifications'),
    (3, 'Email Notifications'),
    (3, 'SMS Notifications'),
    (3, 'App Notifications'),
    (4, 'App Notifications'),
    (5, 'Email Notifications');

-- Insert sample login attempts
INSERT INTO login_attempts (email, timestamp, successful, ip_address) VALUES
    ('john.doe@example.com', CURRENT_TIMESTAMP - INTERVAL '1 hour', TRUE, '192.168.1.100'),
    ('jane.smith@example.com', CURRENT_TIMESTAMP - INTERVAL '2 hours', TRUE, '192.168.1.101'),
    ('invalid@example.com', CURRENT_TIMESTAMP - INTERVAL '30 minutes', FALSE, '192.168.1.102'),
    ('invalid@example.com', CURRENT_TIMESTAMP - INTERVAL '25 minutes', FALSE, '192.168.1.102'),
    ('invalid@example.com', CURRENT_TIMESTAMP - INTERVAL '20 minutes', FALSE, '192.168.1.102');

-- Verify data insertion
SELECT 'Users inserted:' AS info, COUNT(*) AS count FROM users;
SELECT 'Preferences inserted:' AS info, COUNT(*) AS count FROM user_preferences;
SELECT 'Login attempts inserted:' AS info, COUNT(*) AS count FROM login_attempts;

-- Display sample user profiles
SELECT 
    u.id,
    u.title,
    u.first_name,
    u.last_name,
    u.gender,
    u.age,
    u.email,
    u.email_verified,
    u.auth_provider,
    STRING_AGG(up.preference, ', ') AS preferences
FROM users u
LEFT JOIN user_preferences up ON u.id = up.user_id
GROUP BY u.id, u.title, u.first_name, u.last_name, u.gender, u.age, u.email, u.email_verified, u.auth_provider
ORDER BY u.id;
