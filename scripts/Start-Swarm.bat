@echo off
REM Double-click starter for SwarmUI. First time? Run scripts\Install-Swarm.ps1 once.
cd /d "%~dp0..\tmp\SwarmUI"
if not exist "src\bin\live_release\SwarmUI.exe" (
  echo SwarmUI is not built yet. Ask the agent to run scripts\Install-Swarm.ps1 first.
  pause
  exit /b 1
)
echo Starting SwarmUI: http://localhost:7801
src\bin\live_release\SwarmUI.exe %*
pause
