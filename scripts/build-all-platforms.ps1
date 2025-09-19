# Stack Logistics - Multi-Platform Build Script
# Builds the application for all supported platforms

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Stack Logistics - Multi-Platform Build" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter version
Write-Host "Checking Flutter version..." -ForegroundColor Yellow
flutter --version

# Clean and get dependencies
Write-Host "`nCleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host "`nGetting dependencies..." -ForegroundColor Yellow
flutter pub get

# Run code generation
Write-Host "`nRunning code generation..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

# Run tests
Write-Host "`nRunning tests..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed! Build aborted." -ForegroundColor Red
    exit 1
}

# Analyze code
Write-Host "`nAnalyzing code..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "Code analysis failed! Build aborted." -ForegroundColor Red
    exit 1
}

# Create build directory
$buildDir = "build\outputs"
if (!(Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir
}

Write-Host "`n=========================================" -ForegroundColor Green
Write-Host "   Starting Multi-Platform Builds" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Build for Web
Write-Host "`nBuilding for Web..." -ForegroundColor Magenta
flutter build web --release
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Web build completed successfully" -ForegroundColor Green
    Copy-Item -Path "build\web" -Destination "$buildDir\web" -Recurse -Force
} else {
    Write-Host "✗ Web build failed" -ForegroundColor Red
}

# Build for Windows
Write-Host "`nBuilding for Windows..." -ForegroundColor Magenta
flutter build windows --release
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Windows build completed successfully" -ForegroundColor Green
    Copy-Item -Path "build\windows\x64\runner\Release" -Destination "$buildDir\windows" -Recurse -Force
} else {
    Write-Host "✗ Windows build failed" -ForegroundColor Red
}

# Build APK for Android
Write-Host "`nBuilding Android APK..." -ForegroundColor Magenta
flutter build apk --release
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Android APK build completed successfully" -ForegroundColor Green
    Copy-Item -Path "build\app\outputs\flutter-apk\app-release.apk" -Destination "$buildDir\stacks-logistics-android.apk"
} else {
    Write-Host "✗ Android APK build failed" -ForegroundColor Red
}

# Build Android App Bundle
Write-Host "`nBuilding Android App Bundle..." -ForegroundColor Magenta
flutter build appbundle --release
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Android App Bundle build completed successfully" -ForegroundColor Green
    Copy-Item -Path "build\app\outputs\bundle\release\app-release.aab" -Destination "$buildDir\stacks-logistics-android.aab"
} else {
    Write-Host "✗ Android App Bundle build failed" -ForegroundColor Red
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "   Build Summary" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "`nBuild artifacts are available in: $buildDir" -ForegroundColor White
Write-Host "`nPlatform Support:" -ForegroundColor White
Write-Host "✓ Web (Progressive Web App)" -ForegroundColor Green
Write-Host "✓ Windows Desktop" -ForegroundColor Green
Write-Host "✓ Android (APK & App Bundle)" -ForegroundColor Green
Write-Host "• iOS (requires macOS with Xcode)" -ForegroundColor Yellow
Write-Host "• macOS (requires macOS with Xcode)" -ForegroundColor Yellow
Write-Host "• Linux (requires Linux environment)" -ForegroundColor Yellow

Write-Host "`nDeployment Notes:" -ForegroundColor White
Write-Host "• Web: Deploy the 'web' folder to any web server" -ForegroundColor Cyan
Write-Host "• Windows: Distribute the 'windows' folder as a ZIP" -ForegroundColor Cyan
Write-Host "• Android: Use the APK for sideloading or AAB for Google Play Store" -ForegroundColor Cyan

Write-Host "`n=========================================" -ForegroundColor Green
Write-Host "   Multi-Platform Build Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green