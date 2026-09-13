#Requires -Version 5.1
<#
  One-time SwarmUI install (graphical front-end on top of our ComfyUI backend).
  Run from repo root:  powershell -ExecutionPolicy Bypass -File scripts/Install-Swarm.ps1
  Requires: git (runbook sec.0.1) + .NET SDK 8/10 (auto-installs if missing, user-level).
  Does NOT touch the ComfyUI install or models - Swarm grafts onto them.
  After install, start with scripts/Start-Swarm.ps1 -> http://localhost:7801
#>
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

function Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }

Step "0) Pre-flight"
git --version
$sdks = & dotnet --list-sdks 2>$null
if (-not ($sdks | Select-String -Pattern "^8\.|^9\.|^10\.")) {
  Write-Host "No .NET SDK found. Installing .NET 8 SDK (user-level, no admin)..." -ForegroundColor Yellow
  & winget install --id Microsoft.DotNet.SDK.8 -e --source winget
  Write-Host "Close and reopen PowerShell, then re-run this script." -ForegroundColor Yellow
  exit 1
} else {
  Write-Host "dotnet OK:"; $sdks | ForEach-Object { Write-Host "  $_" }
}

Step "1) Clone SwarmUI into tmp/ (local-only)"
if (-not (Test-Path "tmp\SwarmUI\SwarmUI.sln")) {
  git clone https://github.com/mcmonkeyprojects/SwarmUI tmp\SwarmUI
} else { Write-Host "tmp\SwarmUI already present, skipping clone." }

Step "2) Build (only if needed)"
if (-not (Test-Path "tmp\SwarmUI\src\bin\live_release\SwarmUI.exe")) {
  & dotnet build tmp\SwarmUI\src\SwarmUI.csproj --configuration Release -o tmp\SwarmUI\src\bin\live_release
} else { Write-Host "Already built, skipping." }

Step "3) Wire backend to our ComfyUI (graft, pre-baked)"
# Data/Backends.fds is created on first server start; if absent, first-run installer
# flow handles it (choose 'None / Custom / Choose Later', then add backend per runbook).
New-Item -ItemType Directory -Force "tmp\SwarmUI\Data" | Out-Null
$Backends = "tmp\SwarmUI\Data\Backends.fds"
if (-not (Test-Path $Backends)) {
  Write-Warning "Backends.fds not found. Start SwarmUI once (Start-Swarm.ps1), open http://localhost:7801/Install,"
  Write-Warning "choose 'None / Custom / Choose Later', then follow runbook.md sec.12 to add the backend."
} else {
  Write-Host "Backends.fds present - backend wiring already done."
}

Write-Host "`nDone. Start with:  powershell -ExecutionPolicy Bypass -File scripts\Start-Swarm.ps1" -ForegroundColor Green
Write-Host "Then open http://localhost:7801"
