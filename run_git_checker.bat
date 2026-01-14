@echo off
:: Wrapper to run the PowerShell git update checker
:: Use this for Windows Task Scheduler

powershell -ExecutionPolicy Bypass -File "%~dp0git_update_checker.ps1"
