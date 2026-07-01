@echo off
cd /d "%~dp0"
start "" /min "start_converter_silent.vbs"
timeout /t 1 /nobreak >nul
start "" GunnersRunners.exe
