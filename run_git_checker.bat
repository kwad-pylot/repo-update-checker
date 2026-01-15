@echo off
:: Wrapper to run the PowerShell git update checker (for Task Scheduler)
:: Phase 1: Silently check for updates
:: Phase 2: If updates found, popup interactive window

:: Phase 1: Check only (silent, returns exit code 1 if updates found)
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0git_update_checker.ps1" -CheckOnly

:: Phase 2: If updates found (errorlevel 1), run interactive mode
if %errorlevel% equ 1 (
    powershell -ExecutionPolicy Bypass -File "%~dp0git_update_checker.ps1"
)
