@echo off
:: Interactive Git Update Checker
:: Double-click this to check for updates and pull with confirmation

powershell -ExecutionPolicy Bypass -File "%~dp0git_update_checker.ps1"
pause
