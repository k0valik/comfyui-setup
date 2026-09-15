#Requires -Version 5.1
<#
  Agent glue: installs curated ComfyUI custom-node packs into tmp/ComfyUI/custom_nodes
  via comfy-cli (tmp/agent-tools venv). Idempotent.
  Usage: powershell -ExecutionPolicy Bypass -File scripts/Install-NodePacks.ps1
         [-Packs "rgthree-comfy,ComfyUI-Easy-Use,ComfyUI-GGUF"] [-RepoRoot <path>]
  Restart the backend afterwards (Swarm: Restart All Backends; direct comfy: relaunch).
  Exit: 0 ok | 1 error.
#>
param(
  [string]$Packs = "rgthree-comfy,ComfyUI-Easy-Use,ComfyUI-GGUF",
  [string]$RepoRoot = ""
)
$ErrorActionPreference = "Continue"
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
$Comfy = Join-Path $RepoRoot "tmp/agent-tools/Scripts/comfy.exe"
if (-not (Test-Path $Comfy)) {
  Write-Error "comfy.exe not found at $Comfy - run scripts/Install-AgentTools.ps1 first."
  exit 1
}
$failed = @()
foreach ($pack in $Packs.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }) {
  Write-Host "`n=== installing $pack ===" -ForegroundColor Cyan
  & $Comfy node install $pack 2>&1 | Select-Object -Last 5
  if ($LASTEXITCODE -ne 0) { $failed += $pack }
}
Write-Host ""
if ($failed.Count -gt 0) {
  Write-Host "[FAIL] failed packs: $($failed -join ', ')" -ForegroundColor Red
  Write-Host "Registry search hint: comfy node update-cache, then comfy node install <exact-name-or-url>"
  exit 1
}
Write-Host "[OK] all packs installed. RESTART the backend so nodes load." -ForegroundColor Green
exit 0
