#Requires -Version 5.1
<#
  Start ComfyUI (Windows). Double-click friendly.
  Usage: powershell -ExecutionPolicy Bypass -File scripts\Start.ps1 [--lowvram] [--cpu] [extra ComfyUI args...]
  Examples:
    scripts\Start.ps1
    scripts\Start.ps1 --lowvram        # 8GB or less VRAM
    scripts\Start.ps1 --normalvram     # force normal VRAM mode
    scripts\Start.ps1 --cpu            # no GPU at all
#>
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location "$RepoRoot\tmp\ComfyUI"

$Python = ".\venv\Scripts\python.exe"
if (-not (Test-Path $Python)) {
  Write-Error "venv not found. Run scripts\Install.ps1 first."
}

# Default: localhost only. Add --listen 0.0.0.0 only if you need LAN access.
$ComfyArgs = @("main.py", "--listen", "127.0.0.1", "--port", "8188") + $args
Write-Host "Starting: $Python $($ComfyArgs -join ' ')" -ForegroundColor Cyan
& $Python @ComfyArgs
