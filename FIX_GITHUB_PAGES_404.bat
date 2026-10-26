@echo off
setlocal EnableExtensions
title Fix GitHub Pages 404 - Esayas Portfolio
color 0B
echo.
echo ============================================================
echo   FIX GITHUB PAGES 404 - ESAYAS PORTFOLIO
echo ============================================================
echo.
echo This helper will find your website, push its files to GitHub,
echo then try to enable GitHub Pages if GitHub CLI is installed.
echo It will NOT force-push or overwrite remote history.
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo Git is not installed. Opening Git for Windows download...
  start "" "https://git-scm.com/download/win"
  echo Install Git, then run this file again.
  pause
  exit /b 1
)

set "SITE_DIR="
if exist "%~dp0index.html" set "SITE_DIR=%~dp0"
if not defined SITE_DIR if exist "%~dp0Esayas_Portfolio_Updated\index.html" set "SITE_DIR=%~dp0Esayas_Portfolio_Updated"
if not defined SITE_DIR if exist "%USERPROFILE%\Downloads\Esayas_Portfolio_Updated\index.html" set "SITE_DIR=%USERPROFILE%\Downloads\Esayas_Portfolio_Updated"
if not defined SITE_DIR if exist "%USERPROFILE%\Desktop\Esayas_Portfolio_Updated\index.html" set "SITE_DIR=%USERPROFILE%\Desktop\Esayas_Portfolio_Updated"

if not defined SITE_DIR (
  echo Could not find index.html automatically.
  echo.
  echo Put this BAT file beside your extracted Esayas_Portfolio_Updated
  echo folder, OR put it inside the folder that contains index.html.
  echo Then run it again.
  pause
  exit /b 1
)

cd /d "%SITE_DIR%"
echo Website folder: "%CD%"
echo.

if not exist "index.html" (
  echo ERROR: index.html is not at the website root.
  pause
  exit /b 1
)

if exist ".git\index.lock" (
  tasklist /FI "IMAGENAME eq git.exe" 2>NUL | find /I "git.exe" >NUL
  if not errorlevel 1 (
    echo A Git process is running. Close VS Code/Git operations and retry.
    pause
    exit /b 1
  )
  del /f /q ".git\index.lock"
)

if not exist ".git" (
  git init
  if errorlevel 1 goto failed
)

git add .
if errorlevel 1 goto failed

git diff --cached --quiet
if errorlevel 1 (
  git -c user.name="Esayas Mekonnen" -c user.email="esayas@users.noreply.github.com" commit -m "Publish portfolio website"
  if errorlevel 1 goto failed
) else (
  git rev-parse --verify HEAD >nul 2>nul
  if errorlevel 1 (
    git -c user.name="Esayas Mekonnen" -c user.email="esayas@users.noreply.github.com" commit --allow-empty -m "Initial portfolio commit"
    if errorlevel 1 goto failed
  )
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
echo Pushing website files to GitHub...
git push -u origin main
if errorlevel 1 (
  echo.
  echo PUSH FAILED. Read the message above.
  echo Do not use force push. The remote may contain different commits,
  echo or GitHub may need sign-in/write permission.
  start "" "https://github.com/ESAYASS/isu-edit-"
  goto failed
)

echo.
echo Upload succeeded. Checking whether GitHub CLI is available...
where gh >nul 2>nul
if not errorlevel 1 (
  gh auth status >nul 2>nul
  if not errorlevel 1 (
    echo Trying to enable GitHub Pages...
    gh api -X POST repos/ESAYASS/isu-edit-/pages -f "source[branch]=main" -f "source[path]=/" >nul 2>nul
    if errorlevel 1 (
      echo Pages may already be configured or need setup in the browser.
    ) else (
      echo GitHub Pages enable request sent.
    )
  ) else (
    echo GitHub CLI is installed but not signed in.
  )
) else (
  echo GitHub CLI is not installed, so Pages setup must be completed in browser.
)

echo.
echo Opening GitHub Pages settings. Confirm Source = Deploy from a branch,
echo Branch = main, Folder = /(root), then click Save if needed.
start "" "https://github.com/ESAYASS/isu-edit-/settings/pages"
echo.
echo After Pages shows a successful deployment, your site should be:
echo https://esayass.github.io/isu-edit-/
echo.
pause
exit /b 0

:failed
echo.
echo The automatic fix stopped. No force push was attempted.
echo Open the repository and check the displayed Git error:
echo https://github.com/ESAYASS/isu-edit-
pause
exit /b 1
