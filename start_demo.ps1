# HydroSmart presentation launcher: emulator + warm ML service + app, in one go.
$ErrorActionPreference = "SilentlyContinue"
$adb = "C:\Android\sdk\platform-tools\adb.exe"
$emu = "C:\Android\sdk\emulator\emulator.exe"
$pkg = "com.example.hydro_smart"

Write-Host "1/5  Starting the Android emulator..." -ForegroundColor Green
& $adb start-server | Out-Null
$running = (& $adb devices) -match "emulator-\d+\s+device"
if (-not $running) {
    Start-Process -FilePath $emu -ArgumentList "-avd", "Pixel_6_API_34", "-no-boot-anim" -WindowStyle Normal
}

Write-Host "2/5  Waiting for Android to finish booting..." -ForegroundColor Green
& $adb wait-for-device
do { Start-Sleep -Seconds 3; $b = (& $adb shell getprop sys.boot_completed).Trim() } until ($b -eq "1")
Start-Sleep -Seconds 5

Write-Host "3/5  Setting the emulator location to SMIT, Majitar..." -ForegroundColor Green
& $adb shell cmd location set-location-enabled true | Out-Null
& $adb emu geo fix 88.4977 27.1867 | Out-Null

Write-Host "4/5  Waking up the crop-prediction server (can take up to a minute)..." -ForegroundColor Green
try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 90 "https://hydro-smart-backend.onrender.com/" | Out-Null; Write-Host "     ML server is awake." }
catch { Write-Host "     ML server did not answer yet; the app will retry when you ask for a recommendation." -ForegroundColor Yellow }

Write-Host "5/5  Opening HydroSmart..." -ForegroundColor Green
& $adb shell am force-stop $pkg
& $adb shell monkey -p $pkg -c android.intent.category.LAUNCHER 1 2>&1 | Out-Null
& $adb emu geo fix 88.4977 27.1867 | Out-Null

Write-Host ""
Write-Host "Ready. Switch on the ESP32 (USB power) and the S25 hotspot; the Live pH card goes green within ~15 s." -ForegroundColor Cyan
