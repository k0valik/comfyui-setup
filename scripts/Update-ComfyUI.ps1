#Requires -Version 5.1
<#
  Agent glue: SAFE ComfyUI bump for an already-working machine.
  Records the current state, moves ComfyUI to the NEWEST STABLE RELEASE tag
  (not master's tip — the ComfyUI README warns that commits outside stable
  release tags may be very unstable and break many custom nodes), reinstalls
  requirements, re-verifies torch/CUDA. Never deletes models or workflows,
  and never stops servers itself.

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts\Update-ComfyUI.ps1 [-RepoRoot <path>] [-FullVenvBackup]

  - Default backup = cheap (git hashes + pip freeze). Fast, enough to roll back packages.
  - -FullVenvBackup = full copy of tmp/ComfyUI/venv to tmp/comfy-backup-<date>/venv.
    Slow (venv is many GB) — the script asks for confirmation in Hungarian first.
  - Stops WITHOUT changing anything if: servers are running on :7801/:7821/:8188,
    or the ComfyUI checkout has modified TRACKED files (untracked files, e.g.
    installed custom nodes or extra_model_paths.yaml, are fine).

  Exit: 0 ok | 1 stopped early (read the message — it tells you what to do).
#>
param([string]$RepoRoot = "", [switch]$FullVenvBackup)
$ErrorActionPreference = "Stop"
if (-not $RepoRoot) { $RepoRoot = Split-Path -Parent $PSScriptRoot }
Set-Location $RepoRoot

$ComfyDir = Join-Path $RepoRoot "tmp/ComfyUI"
$VenvPy = Join-Path $ComfyDir "venv/Scripts/python.exe"
if (-not (Test-Path (Join-Path $ComfyDir "main.py"))) { Write-Error "tmp/ComfyUI/main.py missing — ComfyUI is not installed here. This script only bumps an existing install."; exit 1 }
if (-not (Test-Path $VenvPy)) { Write-Error "tmp/ComfyUI/venv missing — cannot bump safely without the venv."; exit 1 }

function HttpUp($url) {
  try { $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3 -MaximumRedirection 0; return ($r.StatusCode -in 200,302) }
  catch { return $false }
}
$running = @()
if (HttpUp "http://127.0.0.1:7801/") { $running += ":7801 SwarmUI" }
if (HttpUp "http://127.0.0.1:7821/") { $running += ":7821 Swarm backend" }
if (HttpUp "http://127.0.0.1:8188/") { $running += ":8188 direct comfy" }
if ($running.Count -gt 0) {
  Write-Host "[STOP] A script nem állít le semmit — előbb állítsd le a futó szervereket (Ctrl+C abban az ablakban), aztán futtasd újra." -ForegroundColor Yellow
  Write-Host ("Running now: {0}" -f ($running -join ", "))
  exit 1
}

$stamp = Get-Date -Format "yyyyMMdd-HHmm"
$BackupDir = Join-Path $RepoRoot ("tmp/comfy-backup-" + $stamp)
New-Item -ItemType Directory -Force $BackupDir | Out-Null

Write-Host "=== 1) Record current state ===" -ForegroundColor Cyan
$before = (& git -C $ComfyDir rev-parse HEAD 2>$null)
if (-not $before) { Write-Error "tmp/ComfyUI is not a git checkout — refusing to bump an unknown tree."; exit 1 }
$before | Out-File (Join-Path $BackupDir "comfy-commit-before.txt")
& $VenvPy -m pip freeze > (Join-Path $BackupDir "requirements-frozen-before.txt")
Write-Host "before: $before"
Write-Host "frozen package list -> $BackupDir"

# Refuse on modified TRACKED files (a git pull/checkout would fight them).
# Untracked files (custom_nodes, extra_model_paths.yaml, ...) do NOT block:
# a tag checkout leaves them alone.
$tracked = @(& git -C $ComfyDir status --porcelain 2>$null) | Where-Object { $_ -notmatch '^\?\?' }
if ($tracked) {
  Write-Host "[STOP] A tmp/ComfyUI mappában követett fájlok vannak módosítva — a frissítés most nem biztonságos." -ForegroundColor Yellow
  Write-Host "Mutasd meg az ügynöknek: git -C tmp/ComfyUI status"
  exit 1
}

if ($FullVenvBackup) {
  Write-Host "=== 2) Full venv backup (lassú, több GB — kávészünet) ===" -ForegroundColor Cyan
  $answer = Read-Host "Biztosan másoljam a teljes venv-et? [i/n] (igen=nem kell sietni)"
  if ($answer -notin @("i","I","igen","y","Y","yes")) { Write-Host "Venv-másolás kihagyva, folytatás a gyors mentéssel."; }
  else { Copy-Item (Join-Path $ComfyDir "venv") (Join-Path $BackupDir "venv") -Recurse -Force; Write-Host "venv backup -> $BackupDir" }
} else {
  Write-Host "=== 2) Venv backup kihagyva (gyors mód; -FullVenvBackup kapcsolóval kérhető teljes másolat) ===" -ForegroundColor Cyan
}

Write-Host "=== 3) Fetch tags + move to the newest STABLE RELEASE ===" -ForegroundColor Cyan
& git -C $ComfyDir fetch origin --tags
if ($LASTEXITCODE -ne 0) {
  Write-Host "[STOP] git fetch failed (network/remote) — semmi nem változott. Mutasd meg az ügynöknek a fenti hibát." -ForegroundColor Yellow
  exit 1
}
# Newest stable = highest vX.Y.Z-shaped tag (release tags only; no branches, no prereleases)
$tag = (& git -C $ComfyDir tag --sort=-v:refname) | Where-Object { $_ -match '^v\d+\.\d+\.\d+$' } | Select-Object -First 1
if (-not $tag) { Write-Error "No vX.Y.Z release tag found after fetch — refusing to guess a target."; exit 1 }
$beforeTags = @(& git -C $ComfyDir tag --points-at $before) | Where-Object { $_ -match '^v\d+\.\d+\.\d+$' }
if ($beforeTags -contains $tag) {
  Write-Host "[SKIP] Already on the newest stable release $tag — no checkout needed."
} else {
  & git -C $ComfyDir checkout $tag
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[STOP] A checkout nem sikerült — a fa változatlan. Mutasd meg az ügynöknek a fenti hibát." -ForegroundColor Yellow
    exit 1
  }
}
$after = (& git -C $ComfyDir rev-parse HEAD 2>$null)
$after | Out-File (Join-Path $BackupDir "comfy-commit-after.txt")
Write-Host "stable tag: $tag"
Write-Host "after:  $after"

Write-Host "=== 4) Reinstall requirements into the existing venv ===" -ForegroundColor Cyan
& $VenvPy -m pip install -r (Join-Path $ComfyDir "requirements.txt")
if ($LASTEXITCODE -ne 0) { Write-Error "pip install -r requirements.txt failed."; exit 1 }

Write-Host "=== 5) Verify torch/CUDA (+ torch drift guard) ===" -ForegroundColor Cyan
$torch = & $VenvPy -c "import torch; print(torch.__version__, torch.cuda.is_available())" 2>$null
Write-Host "torch: $torch"
if ($torch -notmatch "True") { Write-Error "CUDA check FAILED after bump ($torch). Visszaállítás: az ügynök a $BackupDir alapján dolgozzon."; exit 1 }
# The machine's torch build is machine-specific (cu130 on 20-series+). If the
# new requirements.txt silently dragged in a different torch, warn loudly —
# cuda.is_available() can still be True on a wrong build.
$torchBefore = (Select-String -Path (Join-Path $BackupDir "requirements-frozen-before.txt") -Pattern '^torch==').Line
$torchNow = @(& $VenvPy -m pip freeze) | Where-Object { $_ -match '^torch==' }
if ($torchBefore -and ($torchNow -notcontains $torchBefore)) {
  Write-Host "[FIGYELEM] A torch csere! A requirements.txt új minimumot hozhatott, és a pip másik buildet rakott be." -ForegroundColor Yellow
  Write-Host ("  before: {0}" -f $torchBefore)
  Write-Host ("  after:  {0}" -f ($torchNow -join " / "))
  Write-Host "  Ha a régi kell:  $VenvPy -m pip install $torchBefore --index-url https://download.pytorch.org/whl/cu130"
  Write-Host "  (20-series+ kártyára a README cu130+ ajánlja; a régi build a requirements-frozen-before.txt-ben megvan.)"
}

Write-Host ""
Write-Host "[OK] ComfyUI bump kész: $before -> $after ($tag)" -ForegroundColor Green
Write-Host "Ha bármi furcsa: az ügynök a $BackupDir mentés alapján vissza tud állni."
Write-Host "Következő lépés: powershell -ExecutionPolicy Bypass -File scripts\Verify-Setup.ps1"
exit 0
