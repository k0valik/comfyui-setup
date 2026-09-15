#Requires -Version 5.1
<#
  Agent glue: installs the AGENT TOOLING layer (comfy-cli + comfy-mcp) into a
  dedicated venv at tmp/agent-tools so MCP clients can launch it with absolute
  paths (no PATH dependence). Points comfy-cli's workspace at tmp/ComfyUI.
  Usage: powershell -ExecutionPolicy Bypass -File scripts/Install-AgentTools.ps1 [-RepoRoot <path>]
  Exit: 0 ok | 1 error. Idempotent - safe to re-run (upgrades packages).
#>
param([string]$RepoRoot = "")
$ErrorActionPreference = "Stop"
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
Set-Location $RepoRoot

$Tools = Join-Path $RepoRoot "tmp/agent-tools"
$PyExe = Join-Path $Tools "Scripts/python.exe"
$ComfyExe = Join-Path $Tools "Scripts/comfy.exe"
$McpExe = Join-Path $Tools "Scripts/comfy-mcp.exe"

if (-not (Test-Path $PyExe)) {
  Write-Host "Creating tools venv at $Tools"
  # Prefer 3.13 for max package compatibility; fall back to current python.
  $base = $null
  try { $v = (& py -3.13 --version 2>$null); if ($v -match "3\.13") { $base = "py -3.13" } } catch {}
  if (-not $base) { $base = "python" }
  if ($base -eq "py -3.13") { & py -3.13 -m venv $Tools } else { & python -m venv $Tools }
  if (-not (Test-Path $PyExe)) { Write-Error "venv creation failed."; exit 1 }
}
& $PyExe -m pip install --upgrade pip --quiet
& $PyExe -m pip install --upgrade "comfy-cli>=1.14.0" comfy-mcp --quiet
if ($LASTEXITCODE -ne 0) { Write-Error "pip install comfy-cli/comfy-mcp failed."; exit 1 }

if (-not (Test-Path $ComfyExe)) { Write-Error "comfy.exe not produced."; exit 1 }
if (-not (Test-Path $McpExe)) { Write-Error "comfy-mcp.exe not produced."; exit 1 }

# Point comfy-cli at OUR existing comfy checkout (never comfy install a second one).
$setdef = & $ComfyExe set-default (Join-Path $RepoRoot "tmp/ComfyUI") 2>&1
Write-Host "comfy set-default: $setdef"

Write-Host "`n[OK] agent tools ready:" -ForegroundColor Green
Write-Host "  COMFY_BIN = $ComfyExe"
Write-Host "  MCP cmd   = $McpExe   (register this as an MCP stdio server in the agent client)"
exit 0
