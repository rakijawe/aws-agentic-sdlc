# Secrets Configuration Guide

This guide explains how to configure AWS Secrets Manager for the ProfileManager Lambda application.

## Overview

The application uses AWS Secrets Manager to store sensitive configuration values:
- Database credentials
- Email service credentials (AWS SES)
- OAuth2 credentials (Google and Amazon)
- Encryption keys

## Secret Location

**Secret Name**: `{environment}/lambda/user-registration/secrets`

Examples:
- Test environment: `test/lambda/user-registration/secrets`
- Production environment: `production/lambda/user-registration/secrets`

## Required Secret Values

### 1. Database Password
- **Key**: `SPRING_DATASOURCE_PASSWORD`
- **Description**: PostgreSQL database password
- **Set during**: Infrastructure deployment
- **Update**: Only if you need to change the database password

### 2. Email Configuration (AWS SES)
- **EMAIL_USERNAME**: Email address verified in AWS SES
- **EMAIL_PASSWORD**: Not used for SES (can be placeholder)
- **Setup Steps**:
  1. Go to AWS SES Console: https://console.aws.amazon.com/ses/
  2. Verify your sender email address
  3. Request production access (to move out of sandbox)
  4. Use the verified email as EMAIL_USERNAME

### 3. Google OAuth2 Credentials
- **GOOGLE_CLIENT_ID**: OAuth 2.0 Client ID from Google Cloud Console
- **GOOGLE_CLIENT_SECRET**: OAuth 2.0 Client Secret
- **Setup Steps**:
  1. Go to Google Cloud Console: https://console.cloud.google.com/apis/credentials
  2. Create a new OAuth 2.0 Client ID (Web application)
  3. Add authorized redirect URIs:
     - `https://your-api-endpoint.amazonaws.com/auth/oauth2/google/callback`
  4. Copy the Client ID and Client Secret

### 4. Amazon OAuth2 Credentials
- **AMAZON_CLIENT_ID**: Login with Amazon Client ID
- **AMAZON_CLIENT_SECRET**: Login with Amazon Client Secret
- **Setup Steps**:
  1. Go to Amazon Developer Console: https://developer.amazon.com/loginwithamazon/console/site/lwa/overview.html
  2. Create a new Security Profile
  3. Add allowed return URLs:
     - `https://your-api-endpoint.amazonaws.com/auth/oauth2/amazon/callback`
  4. Copy the Client ID and Client Secret

### 5. Encryption Key
- **ENCRYPTION_KEY**: Base64-encoded 32-byte encryption key
- **Description**: Used for encrypting sensitive data
- **Generation**: Script can auto-generate a secure key

## Configuration Methods

### Method 1: Interactive Script (Recommended)

Run the configuration script:

```powershell
cd ProfileManager-CDK/scripts
.\configure-secrets.ps1 -Environment "test" -Region "us-east-1"
```

The script will:
1. Show current values
2. Prompt for new values (press Enter to keep current)
3. Update the secret in AWS Secrets Manager

### Method 2: AWS Console

1. Go to AWS Secrets Manager Console
2. Search for your secret: `test/lambda/user-registration/secrets`
3. Click "Retrieve secret value"
4. Click "Edit"
5. Update the JSON values
6. Click "Save"

### Method 3: AWS CLI

```bash
# Get current secret
aws secretsmanager get-secret-value \
  --secret-id "test/lambda/user-registration/secrets" \
  --region us-east-1

# Update secret
aws secretsmanager update-secret \
  --secret-id "test/lambda/user-registration/secrets" \
  --secret-string '{"SPRING_DATASOURCE_PASSWORD":"your_password","EMAIL_USERNAME":"your_email@example.com",...}' \
  --region us-east-1
```

## Verification

After updating secrets:

1. **Check secret was updated**:
   ```powershell
   aws secretsmanager get-secret-value --secret-id "test/lambda/user-registration/secrets" --region us-east-1
   ```

2. **Restart Lambda function** (if needed):
   ```powershell
   aws lambda update-function-configuration \
     --function-name your-function-name \
     --region us-east-1
   ```

3. **Test the application**:
   - Try email registration
   - Try Google OAuth login
   - Try Amazon OAuth login

## Security Best Practices

1. **Never commit secrets to Git**
   - Secrets are stored in AWS Secrets Manager only
   - Never put secrets in code or configuration files

2. **Use IAM permissions**
   - Lambda function has IAM role with permission to read secrets
   - Limit access to Secrets Manager to authorized users only

3. **Rotate secrets regularly**
   - Change OAuth2 credentials periodically
   - Rotate encryption keys with proper migration

4. **Use different secrets per environment**
   - Test environment: `test/lambda/user-registration/secrets`
   - Production environment: `production/lambda/user-registration/secrets`

## Troubleshooting

### Secret not found
- Ensure infrastructure was deployed successfully
- Check the secret name matches your environment
- Verify you're using the correct AWS region

### Lambda can't read secret
- Check Lambda IAM role has `secretsmanager:GetSecretValue` permission
- Verify the secret ARN in Lambda environment variables
- Check CloudWatch logs for permission errors

### OAuth2 not working
- Verify redirect URIs match exactly (including https://)
- Check Client ID and Secret are correct
- Ensure OAuth2 consent screen is configured
- Test credentials with OAuth2 playground first

## Next Steps

After configuring secrets:
1. ✓ Configure AWS SES (Task 1.4)
2. ✓ Set up GitHub Actions (Task 1.5)
3. ✓ Verify infrastructure deployment (Task 1.6)
