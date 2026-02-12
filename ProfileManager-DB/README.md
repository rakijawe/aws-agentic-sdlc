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
