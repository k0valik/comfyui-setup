@echo off
REM ============================================================================
REM  initial_setup.bat - ONE-FILE WINDOWS BOOTSTRAP for the comfyui-setup repo.
REM  Double-click this (or run from cmd). Installs in order:
REM    [1] Git  [2] Python 3.13  [3] .NET SDK  [4] Chocolatey  [5] Node.js 24.21.0
REM    [6] agent CLI (Codex or Google Antigravity) - your choice
REM  Then verifies everything via scripts\Preflight.ps1.
REM
REM  CAVEATS (interactive bits the human handles):
REM   - UAC prompt at start (Chocolatey + Node need admin) - click Yes.
REM   - NVIDIA driver is NOT auto-installed: if nvidia-smi is missing at the end,
REM     install it manually from https://www.nvidia.com/drivers/ and REBOOT.
REM   - If any step fails, re-run this file after reopening the terminal; each
REM     step skips itself if already installed.
REM ============================================================================

REM --- self-elevate: choco + node require admin ---
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Requesting administrator rights... ^(accept the UAC prompt^)
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
cd /d "%~dp0"
setlocal ENABLEDELAYEDEXPANSION

echo.
echo === [1/6] Git ===
where git >nul 2>&1
if not errorlevel 1 (
  echo OK: git present
  for /f "delims=" %%v in ('git --version') do echo     %%v
) else (
  winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements
  if errorlevel 1 goto :winget_fail
  set "PATH=!PATH!;C:\Program Files\Git\cmd"
  echo Installed. ^(If git is not found below, reopen the terminal and re-run this file.^)
)

echo.
echo === [2/6] Python 3.13 ===
python --version >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%v in ('python --version') do echo OK: %%v
) else (
  winget install --id Python.Python.3.13 -e --source winget --accept-source-agreements --accept-package-agreements
  if errorlevel 1 goto :winget_fail
  set "PATH=!PATH!;%LOCALAPPDATA%\Programs\Python\Python313;%LOCALAPPDATA%\Programs\Python\Python313\Scripts;C:\Python313;C:\Python313\Scripts"
  echo Installed. ^(If python is not found below, reopen the terminal and re-run this file.^)
)

echo.
echo === [3/6] .NET SDK ^(SwarmUI build^) ===
dotnet --list-sdks >nul 2>&1
if not errorlevel 1 (
  echo OK: dotnet present
) else (
  winget install --id Microsoft.DotNet.SDK.8 -e --source winget --accept-source-agreements --accept-package-agreements
  if errorlevel 1 goto :winget_fail
  set "PATH=!PATH!;C:\Program Files\dotnet"
  echo Installed.
)

echo.
echo === [4/6] Chocolatey ^(package manager for Node.js^) ===
where choco >nul 2>&1
if not errorlevel 1 (
  echo OK: choco present
) else (
  echo Installing Chocolatey...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://community.chocolatey.org/install.ps1 | iex"
  if errorlevel 1 goto :winget_fail
  set "PATH=!PATH!;C:\ProgramData\chocolatey\bin"
  echo Installed.
)

echo.
echo === [5/6] Node.js 24.21.0 + npm ===
where node >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%v in ('node -v') do echo OK: node %%v present
) else (
  choco install nodejs --version="24.21.0" -y
  if errorlevel 1 goto :winget_fail
  set "PATH=!PATH!;C:\Program Files\nodejs"
  echo Installed. ^(If node is not found below, reopen the terminal and re-run this file.^)
)

echo.
echo === [6/6] Agent CLI ===
echo   [1] Codex (OpenAI)
echo   [2] Antigravity (Google)
echo   [3] Skip - already installed / decide later
choice /c 123 /n /m "Your choice: "
if errorlevel 3 goto :verify
if errorlevel 2 goto :antigravity
echo Installing Codex...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://chatgpt.com/codex/install.ps1 | iex"
echo (if the codex command is missing afterwards, reopen the terminal^)
goto :verify
:antigravity
echo Installing Antigravity...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://antigravity.google/cli/install.ps1 | iex"
echo (if the antigravity command is missing afterwards, reopen the terminal^)

:verify
echo.
echo === Verification ===
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Preflight.ps1"
set PFERR=%errorlevel%
echo.
if "%PFERR%"=="2" (
  echo ^*** Reopen the terminal ^(close ALL PowerShell/cmd windows^) and re-run
  echo ^*** initial_setup.bat - some installs need a fresh PATH.
) else if "%PFERR%"=="1" (
  echo ^*** Preflight found a manual step. Follow the [FAIL] / [WARN] lines above.
) else (
  echo ^*** All prerequisites ready.
)
echo.
echo NEXT STEPS:
echo   1. NVIDIA driver missing? https://www.nvidia.com/drivers/ then REBOOT.
echo   2. Start your agent ^(codex / antigravity^) IN THIS FOLDER.
echo   3. Type:  telepits fel nekem mindent legyszives
echo      ^(the agent takes over: ComfyUI + 86GB models + SwarmUI + workflows^)
echo.
pause
exit /b 0

:winget_fail
echo.
echo ^*** A winget/choco install failed. Common fixes:
echo ^***   - close and reopen the terminal, re-run this file (steps skip if done)
echo ^***   - 'winget not recognized': old Windows - open Microsoft Store,
echo ^***     update "App Installer", then retry
echo ^***   - manual fallback links:
echo ^***     git:     https://git-scm.com/download/win
echo ^***     python:  https://www.python.org/downloads/ ^(tick "Add python.exe to PATH"^)
echo ^***     dotnet:  https://dotnet.microsoft.com/en-us/download/dotnet/8.0
echo ^***     node:    https://nodejs.org/  ^(24.x LTS^)
echo ^*** After manual installs: reopen terminal, re-run this file to continue.
echo.
pause
exit /b 1
