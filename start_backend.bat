@echo off
title AgriSync AI Assistant Server
color 0A
cd /d "%~dp0"

echo =====================================================================
echo           AGRISYNC SMART FARMING AI ASSISTANT SERVER
echo =====================================================================
echo.

:: Automatically forward port 8000 to connected Android devices via ADB
where adb >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [*] Checking for connected Android phone via ADB...
    adb reverse tcp:8000 tcp:8000 >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        echo [OK] Android Port Forwarding Active: http://127.0.0.1:8000
    )
)

:: Retrieve and display the current active Wi-Fi IPv4 address
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias '*Wi-Fi*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IPAddress -First 1)"') do set WIFI_IP=%%i

if "%WIFI_IP%"=="" set WIFI_IP=127.0.0.1

echo.
echo ---------------------------------------------------------------------
echo   CONNECTION URLS FOR EVALUATORS & DEVICES:
echo ---------------------------------------------------------------------
echo   - PC Browser Swagger Docs:   http://localhost:8000/docs
echo   - Physical Phone (Wi-Fi):    http://%WIFI_IP%:8000/api
echo   - Physical Phone (USB Cable):http://127.0.0.1:8000/api
echo ---------------------------------------------------------------------
echo.
echo [*] Starting FastAPI Uvicorn ASGI Server on 0.0.0.0:8000 with auto-reload...
echo [*] Press CTRL+C to stop the server at any time.
echo.

python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload

pause
