# Configure AWS Secrets Manager for Lambda Application
# This script helps you set up all required secrets for the application

param(
    [string]$Environment = "test",
    [string]$Region = "us-east-1",
    [switch]$Interactive = $true
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configure Application Secrets" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$secretName = "$Environment/lambda/user-registration/secrets"

Write-Host "Secret Name: $secretName" -ForegroundColor Yellow
Write-Host "Region: $Region" -ForegroundColor Yellow
Write-Host ""

# Check if secret exists
Write-Host "Checking if secret exists..." -ForegroundColor Gray
$secretExists = aws secretsmanager describe-secret --secret-id $secretName --region $Region 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Secret does not exist!" -ForegroundColor Red
    Write-Host "Please run the infrastructure deployment first." -ForegroundColor Yellow
    exit 1
}

Write-Host "Secret exists!" -ForegroundColor Green
Write-Host ""

# Get current values
Write-Host "Fetching current secret values..." -ForegroundColor Gray
$currentSecretJson = aws secretsmanager get-secret-value --secret-id $secretName --region $Region --query SecretString --output text
$currentSecret = $currentSecretJson | ConvertFrom-Json

Write-Host "Current values:" -ForegroundColor Yellow
Write-Host "  DATABASE_PASSWORD: ********" -ForegroundColor Gray
Write-Host "  EMAIL_USERNAME: $($currentSecret.EMAIL_USERNAME)" -ForegroundColor Gray
Write-Host "  EMAIL_PASSWORD: ********" -ForegroundColor Gray
Write-Host "  GOOGLE_CLIENT_ID: $($currentSecret.GOOGLE_CLIENT_ID)" -ForegroundColor Gray
Write-Host "  GOOGLE_CLIENT_SECRET: ********" -ForegroundColor Gray
Write-Host "  AMAZON_CLIENT_ID: $($currentSecret.AMAZON_CLIENT_ID)" -ForegroundColor Gray
Write-Host "  AMAZON_CLIENT_SECRET: ********" -ForegroundColor Gray
Write-Host "  ENCRYPTION_KEY: ********" -ForegroundColor Gray
Write-Host ""

if ($Interactive) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Enter New Values" -ForegroundColor Cyan
    Write-Host "  (Press Enter to keep current value)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Database Password
    Write-Host "1. Database Password" -ForegroundColor Yellow
    Write-Host "   Current: ********" -ForegroundColor Gray
    $dbPasswordInput = Read-Host "   New value (or press Enter to keep current)"
    $dbPassword = if ($dbPasswordInput) { $dbPasswordInput } else { $currentSecret.SPRING_DATASOURCE_PASSWORD }
    Write-Host ""

    # Email Configuration
    Write-Host "2. Email Configuration (for AWS SES)" -ForegroundColor Yellow
    Write-Host "   Current username: $($currentSecret.EMAIL_USERNAME)" -ForegroundColor Gray
    $emailUsername = Read-Host "   Email username (or press Enter to keep current)"
    if (-not $emailUsername) { $emailUsername = $currentSecret.EMAIL_USERNAME }
    
    Write-Host "   Current password: ********" -ForegroundColor Gray
    $emailPasswordSecure = Read-Host "   Email password (or press Enter to keep current)" -AsSecureString
    $emailPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($emailPasswordSecure)
    )
    if (-not $emailPassword) { $emailPassword = $currentSecret.EMAIL_PASSWORD }
    Write-Host ""

    # Google OAuth
    Write-Host "3. Google OAuth Configuration" -ForegroundColor Yellow
    Write-Host "   Get credentials from: https://console.cloud.google.com/apis/credentials" -ForegroundColor Gray
    Write-Host "   Current Client ID: $($currentSecret.GOOGLE_CLIENT_ID)" -ForegroundColor Gray
    $googleClientId = Read-Host "   Google Client ID (or press Enter to keep current)"
    if (-not $googleClientId) { $googleClientId = $currentSecret.GOOGLE_CLIENT_ID }
    
    Write-Host "   Current Client Secret: ********" -ForegroundColor Gray
    $googleClientSecretSecure = Read-Host "   Google Client Secret (or press Enter to keep current)" -AsSecureString
    $googleClientSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($googleClientSecretSecure)
    )
    if (-not $googleClientSecret) { $googleClientSecret = $currentSecret.GOOGLE_CLIENT_SECRET }
    Write-Host ""

    # Amazon OAuth
    Write-Host "4. Amazon OAuth Configuration" -ForegroundColor Yellow
    Write-Host "   Get credentials from: https://developer.amazon.com/loginwithamazon/console/site/lwa/overview.html" -ForegroundColor Gray
    Write-Host "   Current Client ID: $($currentSecret.AMAZON_CLIENT_ID)" -ForegroundColor Gray
    $amazonClientId = Read-Host "   Amazon Client ID (or press Enter to keep current)"
    if (-not $amazonClientId) { $amazonClientId = $currentSecret.AMAZON_CLIENT_ID }
    
    Write-Host "   Current Client Secret: ********" -ForegroundColor Gray
    $amazonClientSecretSecure = Read-Host "   Amazon Client Secret (or press Enter to keep current)" -AsSecureString
    $amazonClientSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($amazonClientSecretSecure)
    )
    if (-not $amazonClientSecret) { $amazonClientSecret = $currentSecret.AMAZON_CLIENT_SECRET }
    Write-Host ""

    # Encryption Key
    Write-Host "5. Encryption Key" -ForegroundColor Yellow
    Write-Host "   Current: ********" -ForegroundColor Gray
    $generateNew = Read-Host "   Generate new encryption key? (y/N)"
    if ($generateNew -eq "y" -or $generateNew -eq "Y") {
        Write-Host "   Generating new 32-byte encryption key..." -ForegroundColor Gray
        $bytes = New-Object byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
        $encryptionKey = [Convert]::ToBase64String($bytes)
        Write-Host "   New key generated!" -ForegroundColor Green
    } else {
        $encryptionKey = $currentSecret.ENCRYPTION_KEY
    }
    Write-Host ""

} else {
    # Non-interactive mode - keep all current values
    $dbPassword = $currentSecret.SPRING_DATASOURCE_PASSWORD
    $emailUsername = $currentSecret.EMAIL_USERNAME
    $emailPassword = $currentSecret.EMAIL_PASSWORD
    $googleClientId = $currentSecret.GOOGLE_CLIENT_ID
    $googleClientSecret = $currentSecret.GOOGLE_CLIENT_SECRET
    $amazonClientId = $currentSecret.AMAZON_CLIENT_ID
    $amazonClientSecret = $currentSecret.AMAZON_CLIENT_SECRET
    $encryptionKey = $currentSecret.ENCRYPTION_KEY
}

# Build the secret JSON
$newSecretJson = @{
    SPRING_DATASOURCE_PASSWORD = $dbPassword
    EMAIL_USERNAME = $emailUsername
    EMAIL_PASSWORD = $emailPassword
    GOOGLE_CLIENT_ID = $googleClientId
    GOOGLE_CLIENT_SECRET = $googleClientSecret
    AMAZON_CLIENT_ID = $amazonClientId
    AMAZON_CLIENT_SECRET = $amazonClientSecret
    ENCRYPTION_KEY = $encryptionKey
} | ConvertTo-Json -Compress

# Update the secret
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Updating Secret in AWS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Updating secret: $secretName" -ForegroundColor Yellow
aws secretsmanager update-secret `
    --secret-id $secretName `
    --secret-string $newSecretJson `
    --region $Region | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Secrets updated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Verify AWS SES email address (if using SES)" -ForegroundColor White
    Write-Host "2. Test OAuth2 credentials with your application" -ForegroundColor White
    Write-Host "3. Restart Lambda function to pick up new secrets" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[ERROR] Failed to update secrets!" -ForegroundColor Red
    exit 1
}
