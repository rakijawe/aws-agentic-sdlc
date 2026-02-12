# Database Scripts

PostgreSQL database migration scripts for user authentication system.

## Structure
```
migrations/
├── V1__create_users_table.sql
├── V2__create_user_preferences_table.sql
├── V3__create_login_attempts_table.sql
└── V4__create_token_blacklist_table.sql

rollback/
├── R1__drop_users_table.sql
├── R2__drop_user_preferences_table.sql
├── R3__drop_login_attempts_table.sql
└── R4__drop_token_blacklist_table.sql
```

## Migration Tool
Use Flyway or Liquibase for database migrations.

### Flyway Example
```bash
flyway -url=jdbc:postgresql://localhost:5432/userauth \
       -user=postgres \
       -password=password \
       migrate
```

## Manual Execution
```bash
psql -h localhost -U postgres -d userauth -f migrations/V1__create_users_table.sql
```

## Tables
1. **users** (Customer_Identity) - User accounts
2. **user_preferences** - User preference selections
3. **login_attempts** - Failed login tracking
4. **token_blacklist** - Invalidated JWT tokens



---

## NEW: Profile Management Implementation (Added: 2024-02-12)

### Migration Scripts Implemented

All four migration scripts have been created and are ready for deployment:

#### V1__create_users_table.sql
Creates the main `users` table with:
- Primary key: `user_id` (BIGSERIAL)
- User credentials: `email`, `password_hash`
- Profile fields: `first_name`, `last_name`, `title`, `gender`, `age`, `date_of_birth`
- Account status: `is_verified`, `is_locked`, `failed_login_attempts`
- OAuth fields: `oauth_provider`, `oauth_provider_id`
- Timestamps: `created_at`, `updated_at`, `last_login_at`
- Unique constraint on `email`
- Index on `email` for fast lookups

#### V2__create_user_preferences_table.sql
Creates the `user_preferences` table with:
- Primary key: `preference_id` (BIGSERIAL)
- Foreign key: `user_id` references `users(user_id)` with CASCADE delete
- Preference fields: `preference_name`, `preference_value`
- Timestamps: `created_at`, `updated_at`
- Unique constraint on `(user_id, preference_name)` to prevent duplicates
- Index on `user_id` for fast user preference lookups

#### V3__create_login_attempts_table.sql
Creates the `login_attempts` table with:
- Primary key: `attempt_id` (BIGSERIAL)
- Foreign key: `user_id` references `users(user_id)` with CASCADE delete
- Tracking fields: `attempt_time`, `ip_address`, `user_agent`, `success`
- Index on `(user_id, attempt_time)` for efficient failed attempt queries

#### V4__create_token_blacklist_table.sql
Creates the `token_blacklist` table with:
- Primary key: `blacklist_id` (BIGSERIAL)
- Foreign key: `user_id` references `users(user_id)` with CASCADE delete
- Token fields: `token_hash`, `expiry_time`
- Timestamps: `blacklisted_at`
- Index on `token_hash` for fast token validation
- Index on `expiry_time` for cleanup queries

### Rollback Scripts

All rollback scripts are available in the `rollback/` directory:
- `R1__drop_users_table.sql` - Drops users table
- `R2__drop_user_preferences_table.sql` - Drops user_preferences table
- `R3__drop_login_attempts_table.sql` - Drops login_attempts table
- `R4__drop_token_blacklist_table.sql` - Drops token_blacklist table

**Note**: Execute rollback scripts in reverse order (R4 → R3 → R2 → R1) due to foreign key dependencies.

### Sample Data

The `sample_data.sql` file contains test data for 5 users:

1. **john.doe@example.com** - Verified, active user with preferences
2. **jane.smith@example.com** - Verified, active user with preferences
3. **bob.wilson@example.com** - Verified, active user with preferences
4. **alice.brown@example.com** - Unverified user (for testing verification flow)
5. **charlie.davis@example.com** - Locked account (for testing account locking)

Each user has:
- Hashed password (BCrypt): `Password123!`
- Complete profile information
- Multiple preferences (email notifications, SMS alerts, newsletter)
- Login attempt history

### Deployment Steps

#### Option 1: Using Flyway (Recommended)
```bash
# Install Flyway
# Configure flyway.conf with your database connection

# Run migrations
flyway migrate

# Rollback if needed
flyway undo
```

#### Option 2: Manual Execution
```bash
# Set your database connection details
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=profilemanager_db
export DB_USER=postgres

# Run migrations in order
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f migrations/V1__create_users_table.sql
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f migrations/V2__create_user_preferences_table.sql
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f migrations/V3__create_login_attempts_table.sql
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f migrations/V4__create_token_blacklist_table.sql

# Load sample data (optional, for testing)
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f sample_data.sql
```

#### Option 3: Using Docker PostgreSQL
```bash
# Start PostgreSQL container
docker run --name profilemanager-db \
  -e POSTGRES_DB=profilemanager_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  -d postgres:14

# Wait for PostgreSQL to start
sleep 5

# Run migrations
docker exec -i profilemanager-db psql -U postgres -d profilemanager_db < migrations/V1__create_users_table.sql
docker exec -i profilemanager-db psql -U postgres -d profilemanager_db < migrations/V2__create_user_preferences_table.sql
docker exec -i profilemanager-db psql -U postgres -d profilemanager_db < migrations/V3__create_login_attempts_table.sql
docker exec -i profilemanager-db psql -U postgres -d profilemanager_db < migrations/V4__create_token_blacklist_table.sql

# Load sample data
docker exec -i profilemanager-db psql -U postgres -d profilemanager_db < sample_data.sql
```

### Verification

After running migrations, verify the tables were created:

```sql
-- List all tables
\dt

-- Check users table structure
\d users

-- Check user_preferences table structure
\d user_preferences

-- Check login_attempts table structure
\d login_attempts

-- Check token_blacklist table structure
\d token_blacklist

-- Verify sample data (if loaded)
SELECT user_id, email, first_name, last_name, is_verified, is_locked FROM users;
SELECT COUNT(*) FROM user_preferences;
SELECT COUNT(*) FROM login_attempts;
```

### Database Connection for Lambda

The Lambda functions expect these environment variables:

```bash
DB_HOST=your-rds-endpoint.region.rds.amazonaws.com
DB_PORT=5432
DB_NAME=profilemanager_db
DB_USER=postgres
DB_PASSWORD=your-secure-password
```

For local testing, use:
```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=profilemanager_db
DB_USER=postgres
DB_PASSWORD=password
```

### Next Steps

1. Deploy database migrations to your PostgreSQL instance
2. Load sample data for testing (optional)
3. Configure Lambda environment variables with database connection details
4. Deploy Lambda functions using CDK (see `ProfileManager-CDK/DEPLOYMENT_GUIDE.md`)
5. Test API endpoints with sample user credentials

### Related Documentation

- Backend Implementation: `ProfileManager-API/PROFILE_BACKEND_IMPLEMENTATION.md`
- Deployment Guide: `ProfileManager-CDK/DEPLOYMENT_GUIDE.md`
- Complete Summary: `PROFILE_MANAGEMENT_COMPLETE.md`
