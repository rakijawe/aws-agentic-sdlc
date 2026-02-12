# Quick Build and Test Script
# This script builds the project and runs tests to verify everything works before deployment

Write-Host "ProfileManager-API - Build and Test" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Maven is available
Write-Host "Checking Maven installation..." -ForegroundColor Yellow
$mvnPath = "C:\Users\CAESAR\Downloads\apache-maven-3.9.12-bin\apache-maven-3.9.12\bin\mvn.cmd"

if (-not (Test-Path $mvnPath)) {
    Write-Host "Maven not found at: $mvnPath" -ForegroundColor Red
    Write-Host "Please update the path in this script or ensure Maven is in PATH" -ForegroundColor Yellow
    exit 1
}

Write-Host "Maven found: $mvnPath" -ForegroundColor Green
Write-Host ""

# Check Java version
Write-Host "Checking Java version..." -ForegroundColor Yellow
$javaVersion = java -version 2>&1 | Select-String "version"
Write-Host $javaVersion -ForegroundColor Gray

if ($javaVersion -notmatch "17") {
    Write-Host "Warning: Java 17 is required. Current version may not be compatible." -ForegroundColor Yellow
}
Write-Host ""

# Clean previous builds
Write-Host "Step 1: Cleaning previous builds..." -ForegroundColor Yellow
& $mvnPath clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Clean failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Clean successful!" -ForegroundColor Green
Write-Host ""

# Compile
Write-Host "Step 2: Compiling source code..." -ForegroundColor Yellow
& $mvnPath compile
if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Compilation successful!" -ForegroundColor Green
Write-Host ""

# Run tests
Write-Host "Step 3: Running unit tests..." -ForegroundColor Yellow
& $mvnPath test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed!" -ForegroundColor Red
    Write-Host "Check the output above for details" -ForegroundColor Yellow
    exit 1
}
Write-Host "All tests passed!" -ForegroundColor Green
Write-Host ""

# Package
Write-Host "Step 4: Creating JAR file..." -ForegroundColor Yellow
& $mvnPath package -DskipTests
if ($LASTEXITCODE -ne 0) {
    Write-Host "Packaging failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Packaging successful!" -ForegroundColor Green
Write-Host ""

# Verify JAR files
Write-Host "Step 5: Verifying JAR files..." -ForegroundColor Yellow
$jarFiles = Get-ChildItem -Path "target" -Filter "*.jar"

if ($jarFiles.Count -eq 0) {
    Write-Host "No JAR files found in target directory!" -ForegroundColor Red
    exit 1
}

Write-Host "Found JAR files:" -ForegroundColor Green
foreach ($jar in $jarFiles) {
    $sizeKB = [math]::Round($jar.Length / 1KB, 2)
    $sizeMB = [math]::Round($jar.Length / 1MB, 2)
    Write-Host "  - $($jar.Name) ($sizeMB MB)" -ForegroundColor Cyan
}
Write-Host ""

# Check for shaded JAR
$shadedJar = Get-ChildItem -Path "target" -Filter "*-aws.jar" | Select-Object -First 1

if ($shadedJar) {
    Write-Host "Lambda-ready JAR found: $($shadedJar.Name)" -ForegroundColor Green
    Write-Host "Size: $([math]::Round($shadedJar.Length / 1MB, 2)) MB" -ForegroundColor Gray
} else {
    Write-Host "Warning: Shaded JAR (*-aws.jar) not found!" -ForegroundColor Yellow
    Write-Host "Check pom.xml maven-shade-plugin configuration" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "Build Summary" -ForegroundColor Cyan
Write-Host "=============" -ForegroundColor Cyan
Write-Host "✓ Clean successful" -ForegroundColor Green
Write-Host "✓ Compilation successful" -ForegroundColor Green
Write-Host "✓ Tests passed" -ForegroundColor Green
Write-Host "✓ JAR created" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review test results above" -ForegroundColor White
Write-Host "2. Deploy to AWS using: ..\ProfileManager-CDK\scripts\complete-lambda-deployment.ps1" -ForegroundColor White
Write-Host "3. Or push to main branch for automated deployment via GitHub Actions" -ForegroundColor White
Write-Host ""

Write-Host "Ready for deployment! 🚀" -ForegroundColor Green
