@echo off
REM ================================
REM PALWORLD SAFE START SCRIPT
REM ================================

setlocal enabledelayedexpansion

REM Get the directory of this script
for %%I in ("%~dp0.") do set "RepoPath=%%~fI"
for %%I in ("%RepoPath%\..") do set "PalServerFolder=%%~fI"
set "ServerExe=%PalServerFolder%\..\PalServer.exe"

cd /d "%RepoPath%"

echo.
echo =====================================
echo  PALWORLD SAFE HOST STARTUP
echo =====================================
echo.

REM --------------------------------
REM Ensure Git Installed
REM --------------------------------

where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Git is not installed.
    pause
    exit /b
)

REM --------------------------------
REM Fetch Latest Remote State
REM --------------------------------

echo Fetching latest GitHub state...
git fetch origin

if %ERRORLEVEL% neq 0 (
    echo Failed to contact GitHub.
    pause
    exit /b
)

REM --------------------------------
REM Check Local Status
REM --------------------------------

git status --porcelain >temp_status.txt
for /f %%A in (temp_status.txt) do set "status=%%A"
del temp_status.txt

if not "!status!"=="" (
    echo.
    echo Uncommitted local changes detected.
    echo Please resolve manually.
    pause
    exit /b
)

REM --------------------------------
REM Check If Behind Remote
REM --------------------------------

for /f %%A in ('git rev-list --count HEAD..origin/main 2^>nul') do set "behind=%%A"

if %behind% gtr 0 (
    echo.
    echo Local repository is outdated.
    echo Pulling latest changes...
    
    git pull origin main

    if %ERRORLEVEL% neq 0 (
        echo Git pull failed.
        pause
        exit /b
    )
)

REM --------------------------------
REM Check Lock File
REM --------------------------------

if exist "%RepoPath%\server.lock" (

    echo.
    echo SERVER ALREADY HOSTED!
    echo.

    type "%RepoPath%\server.lock"

    pause
    exit /b
)

REM --------------------------------
REM Read Current Version
REM --------------------------------

for /f "delims=" %%A in ('type "%RepoPath%\world-version.txt"') do set "version=%%A"

REM --------------------------------
REM Create Lock File
REM --------------------------------

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)

(
    echo HOST=%USERNAME%
    echo TIME=%mydate% %mytime%
    echo VERSION=%version%
) > "%RepoPath%\server.lock"

REM --------------------------------
REM Push Lock
REM --------------------------------

git add server.lock
git commit -m "Acquire server lock"

if %ERRORLEVEL% neq 0 (
    echo Failed to commit lock.
    pause
    exit /b
)

git push origin main

if %ERRORLEVEL% neq 0 (
    echo Failed to push lock.
    pause
    exit /b
)

REM --------------------------------
REM Start Server
REM --------------------------------

echo.
echo Starting Palworld server...
echo.

start "" "%ServerExe%"

echo Server started successfully.
echo.
pause
