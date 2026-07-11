@echo off
REM stop-server.bat

REM Current script location = repo path
SET RepoPath=%~dp0

REM Two levels up = actual server folder
cd /d "%RepoPath%\..\..\"
for /f "delims=" %%i in ('cd') do set ServerFolderPath=%%i

echo.
echo Stopping server...
echo Repo Path: %RepoPath%
echo Server Folder: %ServerFolderPath%
echo.

REM Lock file inside repo
SET lockFile=%RepoPath%server.lock

REM Check if lock exists
if not exist "%lockFile%" (
    echo No active server lock found.
    exit /b 0
)

echo Current lock info:
type "%lockFile%"
echo.

REM Remove lock file
del /f "%lockFile%"

echo Server lock removed.

REM Optional:
REM Stop actual server process here if needed

REM Commit changes
cd /d "%RepoPath%"
git add .
git commit -m "Server stopped by %USERNAME%"

REM Push changes
git push

echo.
echo Server stopped successfully.
