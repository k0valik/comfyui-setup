#Requires -Version 5.1
<#
  Start SwarmUI (graphical front-end; it manages its own ComfyUI backend).
  Usage: powershell -ExecutionPolicy Bypass -File scripts/Start-Swarm.ps1
  First run: it auto-builds if needed, then opens http://localhost:7801
  Backend is pre-wired in tmp/SwarmUI/Data/Backends.fds to
  tmp/ComfyUI/main.py (our venv + models + Manager).
  NOTE: run scripts/Install-Swarm.ps1 once before this.
#>
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location "$RepoRoot\tmp\SwarmUI"

if (-not (Test-Path "src\bin\live_release\SwarmUI.exe")) {
  Write-Host "SwarmUI not built yet - run scripts/Install-Swarm.ps1 first." -ForegroundColor Yellow
  & "$RepoRoot\scripts\Install-Swarm.ps1"
  if (-not (Test-Path "src\bin\live_release\SwarmUI.exe")) { Write-Error "Build failed." }
}
Write-Host "Starting SwarmUI on http://localhost:7801 ..." -ForegroundColor Cyan
& ".\src\bin\live_release\SwarmUI.exe" @args
if ($LASTEXITCODE -eq 42) {  # Swarm restart convention
  & ".\src\bin\live_release\SwarmUI.exe" @args
}
