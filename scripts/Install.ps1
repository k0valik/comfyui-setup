#Requires -Version 5.1
<#
  Half-automated ComfyUI setup for Windows (no admin required).
  Run from the repo root, e.g.:  powershell -ExecutionPolicy Bypass -File scripts\Install.ps1
  Assumes: Windows 10/11 64-bit, Git + Python 3.13/3.14 + current NVIDIA driver already installed.
  No Visual Studio / build tools needed — everything installs from prebuilt wheels.
#>
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSSplitPath
Set-Location $RepoRoot

function Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }

Step "0) Pre-flight checks (see runbook §0 if anything is missing)"
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  Write-Error "Python not found. Install it first:  winget install --id Python.Python.3.13 -e --source winget  (or https://www.python.org/downloads/ — tick 'Add python.exe to PATH'), then close/reopen PowerShell. Details: runbook.md §0.2"
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "Git not found. Install it first:  winget install --id Git.Git -e --source winget  (or https://git-scm.com/download/win), then close/reopen PowerShell. Details: runbook.md §0.1"
}
python --version
git --version
try { nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv | Select-Object -First 5 } catch {
  Write-Warning "nvidia-smi not found. Install the latest NVIDIA driver from https://www.nvidia.com/drivers/, reboot, and re-run. (CPU-only is possible but very slow.) Details: runbook.md §0.3"
}

Step "1) Clone ComfyUI into tmp/ (local-only, git-ignored)"
if (-not (Test-Path "tmp\ComfyUI\main.py")) {
  New-Item -ItemType Directory -Force tmp | Out-Null
  git clone https://github.com/Comfy-Org/ComfyUI tmp\ComfyUI
} else {
  Write-Host "tmp\ComfyUI already present, skipping clone."
}

Step "2) Create Windows venv"
if (-not (Test-Path "tmp\ComfyUI\venv\Scripts\python.exe")) {
  python -m venv tmp\ComfyUI\venv
}
& "tmp\ComfyUI\venv\Scripts\python.exe" --version

Step "3) Upgrade pip"
& "tmp\ComfyUI\venv\Scripts\python.exe" -m pip install --upgrade pip

Step "4) Install PyTorch (NVIDIA 20-series and newer, incl. RTX 50 Blackwell -> cu130)"
# Verified 2026-09-12: installs torch 2.14.0+cu130, CUDA OK on RTX 5070 Ti 16GB.
& "tmp\ComfyUI\venv\Scripts\pip.exe" install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130
# --- Alternatives (uncomment ONE if the default does not fit your GPU): ---
# Older GTX 10-series or older:      pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126
# Bleeding-edge nightly (perf test): pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu132
# AMD on Windows (ROCm 10, Py3.13):  pip install --index-url https://stable.repo.amd.com/rocm/whl-next/ "torch[device-all]==2.13.0+rocm10.0.0" "torchvision[device-all]==0.28.0+rocm10.0.0" "torchaudio==2.11.0.2+rocm10.0.0"
# Intel Arc (XPU):                   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu
# CPU only (no GPU):                 pip install torch torchvision torchaudio

Step "5) Install ComfyUI dependencies"
& "tmp\ComfyUI\venv\Scripts\pip.exe" install -r tmp\ComfyUI\requirements.txt

Step "6) Verify CUDA"
& "tmp\ComfyUI\venv\Scripts\python.exe" -c "import torch; print('torch', torch.__version__); print('cuda_available', torch.cuda.is_available()); print(torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'no-cuda-gpu')"

Write-Host "`nDone. Start ComfyUI with:  powershell -ExecutionPolicy Bypass -File scripts\Start.ps1" -ForegroundColor Green
Write-Host "Then open http://127.0.0.1:8188 in your browser."
