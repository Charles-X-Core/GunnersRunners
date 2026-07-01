@echo off
title GunnersRunners Music Converter
cd /d "%~dp0"
echo ========================================
echo  GunnersRunners Auto Converter
echo  Leave this running while you play!
echo  Press Ctrl+C to stop.
echo ========================================
echo.
python watch_songs.py
pause
