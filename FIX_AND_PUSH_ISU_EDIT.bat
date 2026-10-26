@echo off
setlocal EnableExtensions
title Fix and Push isu-edit- Portfolio
color 0B
echo.
echo ========================================================
echo       FIX AND PUSH YOUR ESAYAS PORTFOLIO TO GITHUB
echo ========================================================
echo.
echo This helper will locate your extracted portfolio folder,
echo safely check for a stale Git lock, commit the website files,
echo and push to your GitHub repository.
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo ERROR: Git for Windows is not installed or is not in PATH.
  echo Install it from https://git-scm.com/download/win
  start "" "https://git-scm.com/download/win"
  echo After installing, close this window and run this file again.
  pause
  exit /b 1
)

set "SITE_DIR="
if exist "%~dp0Esayas_Portfolio_Updated\index.html" set "SITE_DIR=%~dp0Esayas_Portfolio_Updated"
if not defined SITE_DIR if exist "%~dp0index.html" set "SITE_DIR=%~dp0"
if not defined SITE_DIR if exist "%USERPROFILE%\Downloads\Esayas_Portfolio_Updated\index.html" set "SITE_DIR=%USERPROFILE%\Downloads\Esayas_Portfolio_Updated"
if not defined SITE_DIR if exist "%USERPROFILE%\Desktop\Esayas_Portfolio_Updated\index.html" set "SITE_DIR=%USERPROFILE%\Desktop\Esayas_Portfolio_Updated"

if not defined SITE_DIR (
  echo Could not automatically find the extracted website folder.
  echo.
  echo Move this BAT file next to the Esayas_Portfolio_Updated folder,
  echo or put it inside the folder containing index.html, then run again.
  echo.
  pause
  exit /b 1
)

cd /d "%SITE_DIR%"
echo Website folder:
echo "%CD%"
echo.

if not exist "index.html" (
  echo ERROR: index.html is missing from this folder.
  pause
  exit /b 1
)

if exist ".git\index.lock" (
  echo A Git lock file was found.
  echo This script will only remove it if no git.exe process is running.
  tasklist /FI "IMAGENAME eq git.exe" 2>NUL | find /I "git.exe" >NUL
  if not errorlevel 1 (
    echo.
    echo A Git process is running. Close VS Code terminals/Git tools,
    echo wait for any Git operation to finish, then run this file again.
    pause
    exit /b 1
  )
  del /f /q ".git\index.lock"
  if exist ".git\index.lock" (
    echo ERROR: Could not remove .git\index.lock.
    pause
    exit /b 1
  )
)

if not exist ".git" (
  echo Initializing Git repository...
  git init
  if errorlevel 1 goto failed
)

git add .
if errorlevel 1 goto failed

git diff --cached --quiet
if not errorlevel 1 (
  echo No staged changes detected.
  git rev-parse --verify HEAD >nul 2>nul
  if errorlevel 1 (
    echo No first commit exists yet. Creating initial commit...
    git -c user.name="Esayas Mekonnen" -c user.email="esayas@users.noreply.github.com" commit --allow-empty -m "Initial portfolio commit"
    if errorlevel 1 goto failed
  ) else (
    echo Existing commit found; no new commit needed.
  )
) else (
  git rev-parse --verify HEAD >nul 2>nul
  if errorlevel 1 (
    git -c user.name="Esayas Mekonnen" -c user.email="esayas@users.noreply.github.com" commit -m "Publish Esayas Mekonnen portfolio"
  ) else (
    git -c user.name="Esayas Mekonnen" -c user.email="esayas@users.noreply.github.com" commit -m "Update Esayas Mekonnen portfolio"
  )
  if errorlevel 1 goto failed
)

git branch -M main
if errorlevel 1 goto failed

git remote get-url origin >nul 2>nul
if errorlevel 1 (
  git remote add origin https://github.com/ESAYASS/isu-edit-.git
) else (
  git remote set-url origin https://github.com/ESAYASS/isu-edit-.git
)
if errorlevel 1 goto failed

echo.
echo Pushing to https://github.com/ESAYASS/isu-edit- ...
echo If GitHub authentication appears, complete sign-in in your browser.
git push -u origin main
if errorlevel 1 (
  echo.
  echo Push failed. Possible causes:
  echo - GitHub sign-in or write permission is missing.
  echo - The GitHub repository already has a separate commit/history.
  echo.
  echo If it says non-fast-forward, do NOT force-push. Ask for help
  echo with the exact error so existing remote files are not overwritten.
  start "" "https://github.com/ESAYASS/isu-edit-"
  goto failed
)

echo.
echo SUCCESS: Your website files have been pushed to GitHub.
echo Repository: https://github.com/ESAYASS/isu-edit-
echo.
echo To publish a live website, open Settings ^> Pages in the repository,
echo choose Deploy from a branch, branch main, folder /(root), then Save.
start "" "https://github.com/ESAYASS/isu-edit-"
pause
exit /b 0

:failed
echo.
echo The script could not finish. Read the error above.
echo Send a screenshot of this window if you need help.
pause
exit /b 1
