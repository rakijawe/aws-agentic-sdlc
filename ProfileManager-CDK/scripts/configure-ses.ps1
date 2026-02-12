# Configure AWS SES for Email Sending
# This script helps you set up AWS SES for the application

param(
    [string]$Region = "us-east-1",
    [string]$SenderEmail = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configure AWS SES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check AWS CLI
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] AWS CLI not found!" -ForegroundColor Red
    exit 1
}

# Get sender email if not provided
if (-not $SenderEmail) {
    $SenderEmail = Read-Host "Enter sender email address"
}

Write-Host "Region: $Region" -ForegroundColor Yellow
Write-Host "Sender Email: $SenderEmail" -ForegroundColor Yellow
Write-Host ""

# Step 1: Check current SES status
Write-Host "Step 1: Checking SES Account Status" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor Cyan

$accountDetails = aws sesv2 get-account --region $Region 2>&1 | ConvertFrom-Json

if ($LASTEXITCODE -eq 0) {
    $sendingEnabled = $accountDetails.SendingEnabled
    $productionAccess = $accountDetails.ProductionAccessEnabled
    
    Write-Host "Sending Enabled: $sendingEnabled" -ForegroundColor $(if ($sendingEnabled) { "Green" } else { "Red" })
    Write-Host "Production Access: $productionAccess" -ForegroundColor $(if ($productionAccess) { "Green" } else { "Yellow" })
    
    if (-not $productionAccess) {
        Write-Host ""
        Write-Host "NOTE: Your account is in SANDBOX mode" -ForegroundColor Yellow
        Write-Host "In sandbox mode, you can only send to verified email addresses." -ForegroundColor Yellow
        Write-Host "To send to any email address, request production access." -ForegroundColor Yellow
    }
} else {
    Write-Host "[WARNING] Could not get SES account details" -ForegroundColor Yellow
}

Write-Host ""

# Step 2: Check if email is already verified
Write-Host "Step 2: Checking Email Verification Status" -ForegroundColor Cyan
Write-Host "-------------------------------------------" -ForegroundColor Cyan

$identities = aws sesv2 list-email-identities --region $Region 2>&1 | ConvertFrom-Json

$emailVerified = $false
if ($LASTEXITCODE -eq 0 -and $identities.EmailIdentities) {
    foreach ($identity in $identities.EmailIdentities) {
        if ($identity.IdentityName -eq $SenderEmail) {
            Write-Host "Email: $SenderEmail" -ForegroundColor Gray
            Write-Host "Status: $($identity.VerificationStatus)" -ForegroundColor $(if ($identity.VerificationStatus -eq "SUCCESS") { "Green" } else { "Yellow" })
            
            if ($identity.VerificationStatus -eq "SUCCESS") {
                $emailVerified = $true
            }
            break
        }
    }
}

if (-not $emailVerified) {
    Write-Host "Email $SenderEmail is NOT verified" -ForegroundColor Yellow
    Write-Host ""
    
    # Step 3: Verify email
    Write-Host "Step 3: Verifying Email Address" -ForegroundColor Cyan
    Write-Host "--------------------------------" -ForegroundColor Cyan
    
    $verify = Read-Host "Do you want to verify $SenderEmail now? (Y/n)"
    
    if ($verify -ne "n" -and $verify -ne "N") {
        Write-Host "Sending verification email to $SenderEmail..." -ForegroundColor Gray
        
        aws sesv2 create-email-identity `
            --email-identity $SenderEmail `
            --region $Region | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[SUCCESS] Verification email sent!" -ForegroundColor Green
            Write-Host ""
            Write-Host "IMPORTANT: Check your inbox at $SenderEmail" -ForegroundColor Yellow
            Write-Host "Click the verification link in the email from AWS." -ForegroundColor Yellow
            Write-Host ""
            
            # Wait for verification
            $waitForVerification = Read-Host "Press Enter after clicking the verification link (or 'skip' to continue)"
            
            if ($waitForVerification -ne "skip") {
                Write-Host "Checking verification status..." -ForegroundColor Gray
                Start-Sleep -Seconds 2
                
                $verifyStatus = aws sesv2 get-email-identity `
                    --email-identity $SenderEmail `
                    --region $Region 2>&1 | ConvertFrom-Json
                
                if ($verifyStatus.VerificationStatus -eq "SUCCESS") {
                    Write-Host "[SUCCESS] Email verified!" -ForegroundColor Green
                    $emailVerified = $true
                } else {
                    Write-Host "[WARNING] Email not yet verified. Status: $($verifyStatus.VerificationStatus)" -ForegroundColor Yellow
                    Write-Host "You can verify it later and re-run this script." -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "[ERROR] Failed to send verification email" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[SUCCESS] Email is already verified!" -ForegroundColor Green
}

Write-Host ""

# Step 4: Configure sending limits
Write-Host "Step 4: Checking Sending Limits" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan

if ($accountDetails) {
    $maxSendRate = $accountDetails.SendQuota.MaxSendRate
    $max24HourSend = $accountDetails.SendQuota.Max24HourSend
    
    Write-Host "Max send rate: $maxSendRate emails/second" -ForegroundColor Gray
    Write-Host "Max 24-hour send: $max24HourSend emails" -ForegroundColor Gray
    
    if ($max24HourSend -lt 200) {
        Write-Host ""
        Write-Host "NOTE: Low sending limits detected (sandbox mode)" -ForegroundColor Yellow
        Write-Host "Request production access to increase limits." -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 5: Test email sending
Write-Host "Step 5: Test Email Sending" -ForegroundColor Cyan
Write-Host "---------------------------" -ForegroundColor Cyan

if ($emailVerified) {
    $testEmail = Read-Host "Do you want to send a test email? (Y/n)"
    
    if ($testEmail -ne "n" -and $testEmail -ne "N") {
        $recipientEmail = Read-Host "Enter recipient email address (must be verified in sandbox mode)"
        
        if ($recipientEmail) {
            Write-Host "Sending test email..." -ForegroundColor Gray
            
            $emailContent = @"
{
    "Content": {
        "Simple": {
            "Subject": {
                "Data": "Test Email from ProfileManager API"
            },
            "Body": {
                "Text": {
                    "Data": "This is a test email from your ProfileManager API application.\n\nIf you received this email, AWS SES is configured correctly!\n\nTimestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                }
            }
        }
    },
    "FromEmailAddress": "$SenderEmail",
    "Destination": {
        "ToAddresses": ["$recipientEmail"]
    }
}
"@
            
            $tempFile = [System.IO.Path]::GetTempFileName()
            $emailContent | Out-File -FilePath $tempFile -Encoding UTF8
            
            aws sesv2 send-email `
                --cli-input-json file://$tempFile `
                --region $Region | Out-Null
            
            Remove-Item $tempFile
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[SUCCESS] Test email sent!" -ForegroundColor Green
                Write-Host "Check inbox at $recipientEmail" -ForegroundColor Yellow
            } else {
                Write-Host "[ERROR] Failed to send test email" -ForegroundColor Red
                Write-Host "Make sure the recipient email is verified (if in sandbox mode)" -ForegroundColor Yellow
            }
        }
    }
} else {
    Write-Host "[SKIPPED] Email not verified yet" -ForegroundColor Yellow
}

Write-Host ""

# Step 6: Request production access
Write-Host "Step 6: Production Access" -ForegroundColor Cyan
Write-Host "-------------------------" -ForegroundColor Cyan

if (-not $productionAccess) {
    Write-Host "Your SES account is in SANDBOX mode" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To request production access:" -ForegroundColor White
    Write-Host "1. Go to AWS SES Console: https://console.aws.amazon.com/ses/" -ForegroundColor White
    Write-Host "2. Click 'Account dashboard' in the left menu" -ForegroundColor White
    Write-Host "3. Click 'Request production access' button" -ForegroundColor White
    Write-Host "4. Fill out the form with your use case" -ForegroundColor White
    Write-Host "5. Wait for AWS approval (usually 24-48 hours)" -ForegroundColor White
    Write-Host ""
    
    $openConsole = Read-Host "Open SES Console in browser? (Y/n)"
    if ($openConsole -ne "n" -and $openConsole -ne "N") {
        Start-Process "https://console.aws.amazon.com/ses/home?region=$Region#/account"
    }
} else {
    Write-Host "[SUCCESS] Production access is enabled!" -ForegroundColor Green
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuration Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Sender Email: $SenderEmail" -ForegroundColor $(if ($emailVerified) { "Green" } else { "Yellow" })
Write-Host "Verification Status: $(if ($emailVerified) { 'VERIFIED' } else { 'PENDING' })" -ForegroundColor $(if ($emailVerified) { "Green" } else { "Yellow" })
Write-Host "Production Access: $(if ($productionAccess) { 'ENABLED' } else { 'SANDBOX MODE' })" -ForegroundColor $(if ($productionAccess) { "Green" } else { "Yellow" })
Write-Host ""

if ($emailVerified) {
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Update EMAIL_USERNAME in Secrets Manager: $SenderEmail" -ForegroundColor White
    Write-Host "2. If in sandbox mode, request production access" -ForegroundColor White
    Write-Host "3. Test email sending from your application" -ForegroundColor White
} else {
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Check your email and click the verification link" -ForegroundColor White
    Write-Host "2. Re-run this script to verify status" -ForegroundColor White
    Write-Host "3. Update EMAIL_USERNAME in Secrets Manager" -ForegroundColor White
}

Write-Host ""
