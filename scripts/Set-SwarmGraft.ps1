#Requires -Version 5.1
<#
  Agent glue: pre-bakes tmp/SwarmUI/Data/Backends.fds so SwarmUI grafts onto the
  repo's existing ComfyUI (venv + models + Manager) WITHOUT the human having to
  configure anything in the web installer.
  Usage: powershell -ExecutionPolicy Bypass -File scripts/Set-SwarmGraft.ps1 [-StartScript <path-to-main.py>] [-Force]
  Must run BEFORE first SwarmUI launch (or stop SwarmUI first).
  Exit: 0 written/skip-present | 1 error
#>
param(
  [string]$RepoRoot = "",
  [string]$StartScript = "",
  [switch]$Force
)
$ErrorActionPreference = "Stop"
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
if (-not $StartScript) {
  $StartScript = (($RepoRoot -replace "\\", "/") + "/tmp/ComfyUI/main.py")
}
if (-not (Test-Path $StartScript)) {
  Write-Error "StartScript not found: $StartScript (run scripts/Install.ps1 first)."
  exit 1
}
$SwarmData = Join-Path $RepoRoot "tmp/SwarmUI/Data"
$Target = Join-Path $SwarmData "Backends.fds"
if (Test-Path $Target) {
  if (-not $Force) {
    $has = (Get-Content $Target -Raw) -match [regex]::Escape($StartScript)
    if ($has) { Write-Host "[SKIP] $Target already points at $StartScript" -ForegroundColor Green; exit 0 }
    Write-Host "[WARN] $Target exists with different content. Re-run with -Force to overwrite." -ForegroundColor Yellow
    exit 0
  }
} else {
  New-Item -ItemType Directory -Force $SwarmData | Out-Null
}

# FDS format mirrors the file SwarmUI itself writes (verified 2026-09-12):
# one numeric section per backend; settings keys must match ComfyUISelfStartSettings.
$content = @"
0:
	type: comfyui_selfstart
	title: ComfyUI Self-Starting
	enabled: true
	settings:
		#The location of the 'main.py' file. Can be an absolute or relative path, but must end with 'main.py'.
		#If you used the installer, this should be 'dlbackend/comfy/ComfyUI/main.py'.
		StartScript: $StartScript
		#Any arguments to include in the launch script.
		ExtraArgs: \x
		#If unchecked, the system will automatically add some relevant arguments to the comfy launch. If checked, automatic args (other than port) won't be added.
		DisableInternalArgs: false
		AutoUpdate: false
		UpdateManagedNodes: false
		FrontendVersion: LatestSwarmValidated
		EnablePreviews: true
		GPU_ID: 0
		OverQueue: 1
		AutoRestart: true
"@
Set-Content -Path $Target -Value $content -Encoding ASCII
Write-Host "[OK]   Wrote $Target (StartScript: $StartScript)" -ForegroundColor Green
Write-Host "       In the first-run web wizard the human only picks theme + 'just yourself'" -ForegroundColor Green
Write-Host "       + backend 'None / Custom / Choose Later' - the backend is already wired." -ForegroundColor Green
exit 0
