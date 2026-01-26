@echo off
REM PowerShell Script Runner - Batch Wrapper
REM This batch file launches the PowerShell GUI application

setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Run the PowerShell script with bypassed execution policy
powershell.exe -ExecutionPolicy Bypass -File "!SCRIPT_DIR!PowerShell-Script-Runner.ps1"

endlocal
