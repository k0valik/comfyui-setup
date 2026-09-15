#Requires -Version 5.1
<#
  Agent glue: full setup status report. PASS/FAIL lines, exit 0 if all critical
  checks pass, 1 otherwise. Usage:
    powershell -ExecutionPolicy Bypass -File scripts/Verify-Setup.ps1 [-RepoRoot <path>]
  Sections: prerequisites, comfy install, models, swarm graft, live servers, workflows.
#>
param([string]$RepoRoot = "")
$ErrorActionPreference = "Continue"
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
$script:Fails = 0
function Check($Name, $Ok, $Detail) {
  if ($Ok) { Write-Host ("[PASS] {0}  {1}" -f $Name, $Detail) -ForegroundColor Green }
  else { $script:Fails++; Write-Host ("[FAIL] {0}  {1}" -f $Name, $Detail) -ForegroundColor Red }
}

Write-Host "=== prerequisites ===" -ForegroundColor Cyan
Check "git"        ((Get-Command git -ErrorAction SilentlyContinue) -ne $null)  ((& git --version 2>$null))
Check "python"     ((& python --version 2>$null) -match "Python 3\.(13|14)")    (& python --version 2>$null)
Check "dotnet sdk" ((& dotnet --list-sdks 2>$null | Select-String -Pattern "^8\.|^9\.|^10\.") -ne $null) ""
Check "nvidia"     ((Get-Command nvidia-smi -ErrorAction SilentlyContinue) -ne $null) (& nvidia-smi --query-gpu=name --format=csv,noheader 2>$null | Select-Object -First 1)

Write-Host "=== comfy install ===" -ForegroundColor Cyan
$venvPy = Join-Path $RepoRoot "tmp/ComfyUI/venv/Scripts/python.exe"
Check "venv python" (Test-Path $venvPy) $venvPy
if (Test-Path $venvPy) {
  $torch = & $venvPy -c "import torch; print(torch.__version__, torch.cuda.is_available())" 2>$null
  Check "torch cuda" ($torch -match "True") $torch
}
Check "extra_model_paths.yaml" (Test-Path (Join-Path $RepoRoot "tmp/ComfyUI/extra_model_paths.yaml")) ""

Write-Host "=== models ===" -ForegroundColor Cyan
$models = Get-ChildItem -Recurse -File -Filter "*.safetensors" (Join-Path $RepoRoot "models") -ErrorAction SilentlyContinue
$gb = [math]::Round((($models | Measure-Object Length -Sum).Sum / 1e9), 1)
Check "12 expected model files" (($models | Measure-Object).Count -ge 12) ("count=$($models.Count) total=${gb}GB")
foreach ($must in @("diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors",
                    "text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors",
                    "diffusion_models/ltx-2.5-22b-distilled-transformer-comfy-int8-convrot.safetensors",
                    "text_encoders/gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors")) {
  Check ("model " + (Split-Path $must -Leaf)) (Test-Path (Join-Path $RepoRoot "models/$must")) ""
}

Write-Host "=== swarm graft ===" -ForegroundColor Cyan
$exe = Join-Path $RepoRoot "tmp/SwarmUI/src/bin/live_release/SwarmUI.exe"
Check "SwarmUI.exe built" (Test-Path $exe) ""
$fds = Join-Path $RepoRoot "tmp/SwarmUI/Data/Backends.fds"
$expect = (($RepoRoot -replace "\\", "/") + "/tmp/ComfyUI/main.py")
$graftOk = $false
if (Test-Path $fds) { $graftOk = ((Get-Content $fds -Raw) -match [regex]::Escape("StartScript: $expect")) }
Check "Backends.fds graft" $graftOk ("expect StartScript: $expect")

Write-Host "=== live servers ===" -ForegroundColor Cyan
function HttpCode($url) {
  try { return (Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -MaximumRedirection 0).StatusCode } catch {
    if ($_.Exception.Response) { return [int]$_.Exception.Response.StatusCode }
    return 0
  }
}
$swarm = HttpCode "http://127.0.0.1:7801/"
$comfy = HttpCode "http://127.0.0.1:7821/"
$direct = HttpCode "http://127.0.0.1:8188/"
Check "SwarmUI :7801" ($swarm -in 200,302) "http=$swarm"
Check "Swarm comfy backend :7821" ($comfy -eq 200) "http=$comfy"
if ($direct -gt 0) { Write-Host "[INFO] manually-run comfy :8188 is also up (fine, separate process)" -ForegroundColor DarkCyan }

Write-Host "=== workflows ===" -ForegroundColor Cyan
$wf = Get-ChildItem -File -Filter "*.json" (Join-Path $RepoRoot "workflows") -ErrorAction SilentlyContinue
Check "workflows present" (($wf | Measure-Object).Count -ge 5) ("count=$($wf.Count)")

Write-Host ""
if ($script:Fails -gt 0) { Write-Host "RESULT: $script:Fails FAIL(s) - fix the [FAIL] lines above." -ForegroundColor Red; exit 1 }
Write-Host "RESULT: all critical checks PASS." -ForegroundColor Green
exit 0
