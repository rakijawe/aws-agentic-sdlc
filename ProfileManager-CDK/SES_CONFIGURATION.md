# AWS SES Configuration Guide

This guide explains how to configure AWS Simple Email Service (SES) for sending verification emails and notifications from the ProfileManager application.

## Overview

AWS SES is used for:
- Email verification during user registration
- Password reset emails
- Account notifications
- System alerts

## Prerequisites

- AWS account with SES access
- AWS CLI configured
- Sender email address (that you own/control)

## SES Account Modes

### Sandbox Mode (Default)
- **Limitations**:
  - Can only send to verified email addresses
  - Limited to 200 emails per 24 hours
  - Max 1 email per second
- **Use for**: Development and testing

### Production Mode
- **Benefits**:
  - Can send to any email address
  - Higher sending limits (50,000+ emails per 24 hours)
  - Higher send rate (14+ emails per second)
- **Use for**: Production deployment

## Configuration Steps

### Method 1: Automated Script (Recommended)

Run the SES configuration script:

```powershell
cd ProfileManager-CDK/scripts
.\configure-ses.ps1 -Region "us-east-1" -SenderEmail "noreply@yourdomain.com"
```

The script will:
1. Check SES account status
2. Verify email address
3. Test email sending
4. Guide you through production access request

### Method 2: AWS Console

#### Step 1: Verify Email Address

1. Go to AWS SES Console: https://console.aws.amazon.com/ses/
2. Click "Verified identities" in the left menu
3. Click "Create identity"
4. Select "Email address"
5. Enter your sender email (e.g., `noreply@yourdomain.com`)
6. Click "Create identity"
7. Check your email inbox
8. Click the verification link in the email from AWS

#### Step 2: Check Verification Status

1. Go back to "Verified identities"
2. Find your email address
3. Status should show "Verified" (green checkmark)

#### Step 3: Test Email Sending

1. Select your verified email identity
2. Click "Send test email"
3. Choose "Formatted" message type
4. Enter recipient email (must be verified in sandbox mode)
5. Enter subject and body
6. Click "Send test email"
7. Check recipient inbox

#### Step 4: Request Production Access

1. Click "Account dashboard" in the left menu
2. Click "Request production access" button
3. Fill out the form:
   - **Mail type**: Transactional
   - **Website URL**: Your application URL
   - **Use case description**: 
     ```
     We are building a user authentication and profile management system.
     We need to send:
     - Email verification links during registration
     - Password reset emails
     - Account notification emails
     
     Expected volume: [X] emails per day
     We have implemented proper unsubscribe mechanisms and bounce handling.
     ```
   - **Additional contacts**: Your email
4. Click "Submit request"
5. Wait for AWS approval (usually 24-48 hours)

### Method 3: AWS CLI

#### Verify Email Address

```bash
# Send verification email
aws sesv2 create-email-identity \
  --email-identity noreply@yourdomain.com \
  --region us-east-1

# Check verification status
aws sesv2 get-email-identity \
  --email-identity noreply@yourdomain.com \
  --region us-east-1
```

#### Send Test Email

```bash
aws sesv2 send-email \
  --from-email-address noreply@yourdomain.com \
  --destination ToAddresses=recipient@example.com \
  --content "Subject={Data='Test Email'},Body={Text={Data='This is a test email'}}" \
  --region us-east-1
```

#### Check Account Status

```bash
aws sesv2 get-account --region us-east-1
```

## Update Application Configuration

After verifying your email, update the Secrets Manager:

```powershell
cd ProfileManager-CDK/scripts
.\configure-secrets.ps1 -Environment "test" -Region "us-east-1"
```

When prompted for EMAIL_USERNAME, enter your verified sender email.

## Email Templates

### Verification Email Template

The application will send emails like this:

```
Subject: Verify Your Email Address

Hello,

Thank you for registering with ProfileManager!

Please verify your email address by clicking the link below:

https://your-api-endpoint.com/auth/verify-email?token=VERIFICATION_TOKEN

This link will expire in 24 hours.

If you didn't create an account, please ignore this email.

Best regards,
ProfileManager Team
```

### Password Reset Email Template

```
Subject: Reset Your Password

Hello,

We received a request to reset your password.

Click the link below to reset your password:

https://your-api-endpoint.com/auth/reset-password?token=RESET_TOKEN

This link will expire in 1 hour.

If you didn't request a password reset, please ignore this email.

Best regards,
ProfileManager Team
```

## Testing Email Sending

### Test in Sandbox Mode

1. Verify both sender and recipient emails
2. Send test email using the script or console
3. Check recipient inbox (including spam folder)

### Test in Production Mode

1. Ensure production access is approved
2. Send test email to any email address
3. Monitor bounce and complaint rates

## Monitoring and Troubleshooting

### Check Sending Statistics

```bash
# Get sending statistics
aws sesv2 get-account --region us-east-1

# List suppressed destinations (bounces/complaints)
aws sesv2 list-suppressed-destinations --region us-east-1
```

### Common Issues

#### Email Not Received

**Possible causes**:
- Email in spam folder
- Recipient email not verified (sandbox mode)
- Email address typo
- Sending limits exceeded

**Solutions**:
- Check spam/junk folder
- Verify recipient email in SES console
- Check CloudWatch logs for errors
- Request production access

#### Verification Email Not Received

**Possible causes**:
- Email in spam folder
- Incorrect email address
- Email provider blocking AWS emails

**Solutions**:
- Check spam folder
- Try different email address
- Use email from your own domain

#### Production Access Denied

**Possible causes**:
- Incomplete use case description
- Suspicious activity detected
- Previous SES violations

**Solutions**:
- Provide detailed use case
- Explain email volume and purpose
- Contact AWS Support

### CloudWatch Logs

Monitor email sending in CloudWatch:

```bash
# View Lambda logs
aws logs tail /aws/lambda/your-function-name --follow --region us-east-1
```

Look for:
- Email sending attempts
- SES API errors
- Bounce notifications
- Complaint notifications

## Best Practices

### 1. Use Verified Domain (Recommended)

Instead of verifying individual emails, verify your entire domain:

1. Go to SES Console → Verified identities
2. Click "Create identity"
3. Select "Domain"
4. Enter your domain (e.g., `yourdomain.com`)
5. Add DNS records (DKIM, SPF, DMARC)
6. Wait for verification

Benefits:
- Send from any email @yourdomain.com
- Better deliverability
- Professional appearance

### 2. Handle Bounces and Complaints

Configure SNS topics for bounce and complaint notifications:

```bash
# Set up bounce notifications
aws sesv2 put-email-identity-feedback-attributes \
  --email-identity noreply@yourdomain.com \
  --email-forwarding-enabled \
  --region us-east-1
```

### 3. Monitor Reputation

- Keep bounce rate < 5%
- Keep complaint rate < 0.1%
- Remove invalid email addresses
- Implement double opt-in

### 4. Implement Rate Limiting

Respect SES sending limits:
- Sandbox: 1 email/second, 200/day
- Production: Check your account limits

### 5. Use Configuration Sets

Track email metrics with configuration sets:

```bash
# Create configuration set
aws sesv2 create-configuration-set \
  --configuration-set-name profilemanager-emails \
  --region us-east-1
```

## Security Considerations

### 1. Protect Sender Credentials

- Never commit EMAIL_PASSWORD to Git
- Store in AWS Secrets Manager only
- Rotate credentials regularly

### 2. Prevent Email Spoofing

- Implement SPF records
- Enable DKIM signing
- Add DMARC policy

### 3. Validate Email Addresses

- Validate format before sending
- Check for disposable email domains
- Implement email verification flow

### 4. Rate Limiting

- Limit verification emails per IP
- Prevent email bombing attacks
- Implement CAPTCHA for registration

## Cost Estimation

AWS SES Pricing (as of 2024):
- First 62,000 emails/month: FREE (if sent from EC2/Lambda)
- Additional emails: $0.10 per 1,000 emails
- Attachments: $0.12 per GB

Example costs:
- 10,000 emails/month: FREE
- 100,000 emails/month: ~$3.80
- 1,000,000 emails/month: ~$93.80

## Next Steps

After configuring SES:

1. ✓ Update EMAIL_USERNAME in Secrets Manager
2. ✓ Test email sending from Lambda function
3. ✓ Request production access (if needed)
4. ✓ Configure bounce/complaint handling
5. ✓ Set up monitoring and alerts

## Support Resources

- AWS SES Documentation: https://docs.aws.amazon.com/ses/
- SES Console: https://console.aws.amazon.com/ses/
- AWS Support: https://console.aws.amazon.com/support/
- SES Forum: https://forums.aws.amazon.com/forum.jspa?forumID=90
