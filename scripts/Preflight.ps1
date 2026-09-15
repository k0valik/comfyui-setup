#Requires -Version 5.1
<#
  Agent glue (runbook 9.6 / skill comfyui-setup): checks prerequisites and
  auto-installs missing ones via winget (user-level, no admin).
  Usage: powershell -ExecutionPolicy Bypass -File scripts/Preflight.ps1 [-RepoRoot <path>]
  Exit codes: 0 = all good | 2 = installed something, REOPEN SHELL and re-run |
              1 = unfixable here (manual step needed - see printed message)
#>
param([string]$RepoRoot = "")
$ErrorActionPreference = "Continue"
if (-not $RepoRoot) {
  $RepoRoot = Split-Path -Parent $PSScriptRoot
}
Set-Location $RepoRoot
$script:InstalledSomething = $false
$script:Fatal = @()

function Refresh-Path {
  # Pull fresh PATH from registry so a winget install in THIS process is usable.
  $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
  $user = [Environment]::GetEnvironmentVariable("Path", "User")
  $env:Path = "$machine;$user"
}

function Ensure-Command($Name, $Check, $WingetId, $ManualUrl) {
  if (& $Check) { Write-Host "[OK]   $Name" -ForegroundColor Green; return $true }
  Write-Host "[MISS] $Name - installing via winget: $WingetId" -ForegroundColor Yellow
  if (Get-Command winget -ErrorAction SilentlyContinue) {
    & winget install --id $WingetId -e --source winget --accept-source-agreements --accept-package-agreements
    Refresh-Path
    if (& $Check) { $script:InstalledSomething = $true; Write-Host "[OK]   $Name (installed)" -ForegroundColor Green; return $true }
    $script:Fatal += "$Name installed but not on PATH yet (reopen shell)."
    return $false
  }
  $script:Fatal += "$Name missing and winget unavailable. Manual: $ManualUrl"
  return $false
}

# 1) Git
$gitOk = Ensure-Command "git" { Get-Command git -ErrorAction SilentlyContinue } "Git.Git" "https://git-scm.com/download/win"

# 2) Python 3.13 or 3.14 (ComfyUI-supported versions)
$pyOk = Ensure-Command "python 3.13/3.14" {
  $v = (& python --version 2>$null)
  if ($v -match "Python 3\.(13|14)") { $true } else { $false }
} "Python.Python.3.13" "https://www.python.org/downloads/ (tick 'Add python.exe to PATH')"

# 3) .NET SDK 8+ (SwarmUI build)
$dotnetOk = Ensure-Command ".NET SDK 8/9/10" {
  $sdks = (& dotnet --list-sdks 2>$null)
  if ($sdks | Select-String -Pattern "^8\.|^9\.|^10\.") { $true } else { $false }
} "Microsoft.DotNet.SDK.8" "https://dotnet.microsoft.com/en-us/download/dotnet/8.0"

# 3b) Node.js + npm (agent CLI tooling: npx skills add, codex/antigravity ecosystems)
if ((& node -v 2>$null) -and (& npm -v 2>$null)) {
  Write-Host "[OK]   node/npm  ($(& node -v) / npm $(& npm -v))" -ForegroundColor Green
} elseif (Get-Command choco -ErrorAction SilentlyContinue) {
  Write-Host "[MISS] node - installing via choco (pinned 24.21.0)..." -ForegroundColor Yellow
  & choco install nodejs --version="24.21.0" -y
  Refresh-Path
  if ((& node -v 2>$null) -and (& npm -v 2>$null)) { $script:InstalledSomething = $true; Write-Host "[OK]   node/npm (installed)" -ForegroundColor Green }
  else { $script:Fatal += "node installed but not on PATH (reopen shell, re-run)." }
} else {
  $nodeOk = Ensure-Command "node/npm" { (& node -v 2>$null) -and (& npm -v 2>$null) } "OpenJS.NodeJS" "https://nodejs.org/ (24.x LTS)"
}

# 4) NVIDIA driver (report-only: install needs reboot, agent cannot click it)
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) {
  & nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader | Select-Object -First 1
  Write-Host "[OK]   NVIDIA driver" -ForegroundColor Green
} else {
  Write-Host "[WARN] nvidia-smi not found - GPU generation unavailable until the NVIDIA driver is installed. Manual: https://www.nvidia.com/drivers/ then REBOOT." -ForegroundColor Yellow
}

Write-Host ""
if ($script:Fatal.Count -gt 0) {
  $script:Fatal | ForEach-Object { Write-Host "[FAIL] $_" -ForegroundColor Red }
  exit 1
}
if ($script:InstalledSomething) {
  Write-Host "[DONE] Prerequisites installed. CLOSE AND REOPEN PowerShell, then re-run this script (exit 2)." -ForegroundColor Yellow
  exit 2
}
Write-Host "[DONE] All prerequisites present." -ForegroundColor Green
exit 0
