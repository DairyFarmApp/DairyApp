@echo off
title Push Branches to DairyFarmApp
color 0A
echo ======================================================================
echo  Pushing formal branches to GitHub (DairyFarmApp/DairyApp)
echo  Author: TayyabSaleem1
echo ======================================================================
echo.
cd /d "%~dp0\.."
echo Running: git push -u dairyapp production development main feature/mobile-health-updates
echo.
git push -u dairyapp production development main feature/mobile-health-updates
echo.
if %ERRORLEVEL% EQU 0 (
    echo ======================================================================
    echo  SUCCESS! All branches have been pushed to GitHub.
    echo ======================================================================
) else (
    echo ======================================================================
    echo  Push encountered an issue. Check the message above.
    echo ======================================================================
)
echo.
pause
