#Requires -Version 5.1
<#
  Download video-model files into repo-root models/ (git-ignored), then wire up
  tmp/ComfyUI/extra_model_paths.yaml.

  TWO PROFILES:
    -Profile friend  (DEFAULT - 8GB VRAM target, ~23 GB total)
        GGUF DiT:            LTX-2.5-Distilled-Q3_K_M.gguf          11.5 GB (matches
                             the curated civitai workflow's LoaderGGUF exactly)
        Text encoder (w4a8): gemma4-12b-ltx25-w4a8.safetensors      8.4  GB (needs a
                             one-widget CLIPLoader swap in workflows - the agent
                             narrates it; stock nodes, no extra packs)
        + LTX VAEs + spatial upscaler + duration head (Lightricks official)
        Optional switch -WithW4A8DiT: adds LTX-2.5-Distilled-w4a8.safetensors (12.5 GB,
        stock "Load Diffusion Model" node, no GGUF pack needed).
    -Profile full    (16GB+ author reference manifest, ~86 GB, the verified setup)
        H3 int8 DiT + nvfp4 TE + LTX int8 distilled DiT + int8 TE + 4 VAEs + 2 LoRAs
        + upscaler + duration head.

  H3 on 8GB is an EXPERIMENT TRACK (drive skill) - not part of either default profile.

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts/Download-Models.ps1 [-Profile friend|full] [-WithW4A8DiT] [-HfToken "hf_..."]
  The -HfToken parameter is an alternative to setting $env:HF_TOKEN beforehand
  (the env var is per-shell: opening a new PowerShell loses it).
  Needs: tmp/ComfyUI/venv (Install.ps1). $env:HF_TOKEN must hold a Read token from
  https://huggingface.co/settings/tokens AND the human must have clicked "Agree and
  Access" on https://huggingface.co/Lightricks/LTX-2.5 (gated repo). Realrebelai
  repos are open. Downloads resume - re-run if interrupted.
#>
param(
  [string]$Profile = "friend",
  [switch]$WithW4A8DiT,
  [string]$HfToken = "",
  [string]$RepoRoot = ""
)
$ErrorActionPreference = "Stop"
if ($HfToken) { $env:HF_TOKEN = $HfToken }
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
Set-Location $RepoRoot

# --- Free-space guard: fail early with a clear message instead of dying mid-download ---
$needGB = if ($Profile -eq "full") { 95 } elseif ($WithW4A8DiT) { 45 } else { 30 }
$drive = (Get-Item $RepoRoot).PSDrive.Name
$freeGB = [math]::Round(((Get-PSDrive $drive).Free / 1e9), 1)
if ($freeGB -lt $needGB) {
  Write-Error ("Not enough free space on drive {0}: {1} GB free, need ~{2} GB for profile '{3}'. Free up space or move the repo to a bigger drive." -f $drive, $freeGB, $needGB, $Profile)
}
Write-Host ("Drive {0}: {1} GB free, need ~{2} GB - OK" -f $drive, $freeGB, $needGB)

$VenvPy = "tmp/ComfyUI/venv/Scripts/python.exe"
if (-not (Test-Path $VenvPy)) { Write-Error "venv not found. Run scripts/Install.ps1 first." }
New-Item -ItemType Directory -Force "models" | Out-Null

function Get-RepoFiles($RepoId, $Patterns) {
  Write-Host "`n=== $RepoId ===" -ForegroundColor Cyan
  $patJson = ($Patterns | ForEach-Object { '"' + $_ + '"' }) -join ","
  $code = "from huggingface_hub import snapshot_download; snapshot_download(repo_id='$RepoId', local_dir='models', allow_patterns=[$patJson])"
  & $VenvPy -c $code
}

# Gated repo (Lightricks): needs Agree-and-Access + token. On 401/403, print the
# MANUAL fallback (browser download, no token needed - just login + Agree) instead
# of dying cryptically. snapshot_download skips files already on disk, so after a
# manual download the human just re-runs this script and it completes.
function Get-GatedRepoFiles($RepoId, $Patterns) {
  try {
    Get-RepoFiles $RepoId $Patterns
  } catch {
    Write-Host "`n[FAIL] gated download failed ($RepoId). Most likely: no HF_TOKEN, token expired," -ForegroundColor Red
    Write-Host "or 'Agree and Access' not clicked on https://huggingface.co/$RepoId" -ForegroundColor Red
    Write-Host "MANUAL FALLBACK (no token needed - browser, logged in, after Agree):" -ForegroundColor Yellow
    Write-Host "download each file via its page's Download button into the given models/ subfolder:"
    foreach ($p in $Patterns) {
      $sub = ($p -split "/")[0]; $file = ($p -split "/")[-1]
      Write-Host ("  https://huggingface.co/{0}/blob/main/{1}  ->  models/{2}/" -f $RepoId, $p, $sub)
    }
    Write-Host "Then re-run this script - existing files are skipped." -ForegroundColor Yellow
    throw "gated repo download failed; manual fallback printed above"
  }
}

if ($Profile -eq "friend") {
  # --- friend profile: 8GB-VRAM LTX stack (matches curated civitai workflow) ---
  Get-RepoFiles "realrebelai/LTX-2.5_GGUFs" @(
    "LTX-2.5-Distilled-Q3_K_M.gguf"
  )
  Get-RepoFiles "realrebelai/Rebels_w4a8s" @(
    "LTX/ENCODERS/gemma4-12b-ltx25-w4a8.safetensors"
  )
  Get-GatedRepoFiles "Lightricks/LTX-2.5" @(
    "vae/ltx-2.5-video-vae-conv-bf16.safetensors",
    "vae/ltx-2.5-audio-vae-bf16.safetensors",
    "latent_upscale_models/ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors",
    "model_patches/ltx-2.5-duration-head-bf16.safetensors"
  )
  if ($WithW4A8DiT) {
    Get-RepoFiles "realrebelai/Rebels_w4a8s" @(
      "LTX/LTX-2.5-Distilled-w4a8.safetensors"
    )
  }
  # Node packs required by the curated workflow (GGUF loader, rgthree, Easy-Use):
  Write-Host "`nNOTE: friend profile needs node packs:" -ForegroundColor Yellow
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts/Install-NodePacks.ps1" -ForegroundColor Yellow
}
elseif ($Profile -eq "full") {
  # --- full profile: verified 16GB reference manifest (runbook_2 sec.7) ---
  Get-RepoFiles "Comfy-Org/MiniMax-H3" @(
    "diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors",
    "text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors",
    "vae/minimax_h3_video_vae_fp16.safetensors",
    "vae/minimax_h3_audio_vae_fp32.safetensors",
    "loras/minimax_h3_fl2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors"
  )
  Get-RepoFiles "lightx2v/Minimax-h3-Turbo" @(
    "minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors"
  )
  if (Test-Path "models/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors") {
    Move-Item -Force "models/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors" "models/loras/"
  }
  Get-GatedRepoFiles "Lightricks/LTX-2.5" @(
    "diffusion_models/ltx-2.5-22b-distilled-transformer-comfy-int8-convrot.safetensors",
    "text_encoders/gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors",
    "vae/ltx-2.5-video-vae-conv-bf16.safetensors",
    "vae/ltx-2.5-audio-vae-bf16.safetensors",
    "latent_upscale_models/ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors",
    "model_patches/ltx-2.5-duration-head-bf16.safetensors"
  )
}
else {
  Write-Error "Unknown profile '$Profile' (use: friend | full)."
  exit 1
}

# --- Wire into ComfyUI (machine-local absolute base_path, regenerated per machine) ---
$base = ($RepoRoot -replace "\\", "/")
@"
# Generated by scripts/Download-Models.ps1 - do not hand-edit, re-run the script.
comfyui_video_models:
    base_path: $base
    diffusion_models: models/diffusion_models/
    text_encoders: models/text_encoders/
    vae: models/vae/
    loras: models/loras/
    latent_upscale_models: models/latent_upscale_models/
    model_patches: models/model_patches/
"@ | Out-File -Encoding utf8 "tmp/ComfyUI/extra_model_paths.yaml"

Write-Host "`n=== models/ (profile: $Profile) ===" -ForegroundColor Cyan
Get-ChildItem -Recurse -File "models" -Include "*.safetensors","*.gguf" | ForEach-Object { "{0,8:N1} GB  {1}" -f ($_.Length / 1e9), $_.FullName.Substring($RepoRoot.Length + 1) }
Write-Host "`nDone. Restart ComfyUI (scripts/Start.ps1) so it picks up the new paths." -ForegroundColor Green
