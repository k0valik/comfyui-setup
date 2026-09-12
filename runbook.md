# ComfyUI Pipeline — Runbook (living document)

> Audience: non-technical Windows user, fresh machine, **no dev / build tools**.
> Everything below installs from prebuilt wheels — you do **not** need Visual Studio,
> C++ build tools, Chocolatey, Node.js, or admin rights (unless *you* choose to install Python system-wide).
> Fast path: run `scripts\Install.ps1`, then `scripts\Start.ps1`. The manual steps underneath are the same thing, spelled out.

Reference machine (verified 2026-09-12): Windows 11 64-bit (build 26100), i5-11400F, 32 GB RAM,
NVIDIA RTX 5070 Ti 16 GB (Blackwell), driver 616.56 / CUDA UMD 13.4, E: drive with 700+ GB free.
Reproduced with: Python 3.14.3 (windows), torch 2.14.0+cu130, ComfyUI `c75d8c96` (Comfy-Org/ComfyUI, 2026-09-12).
Lower VRAM (e.g. 8–12 GB) works too — see §8 for the flags.

---

## 0. What you need before starting (~10 min)

1. **NVIDIA driver (current).** https://www.nvidia.com/drivers/ — install, reboot, then check:
   ```powershell
   nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv
   # expect e.g.: NVIDIA GeForce RTX 5070 Ti, 616.56, 16303 MiB
   ```
2. **Git for Windows.** https://git-scm.com/download/win — accept defaults, then check:
   ```powershell
   git --version
   ```
3. **Python 3.13 or 3.14, 64-bit.** https://www.python.org/downloads/
   - IMPORTANT: tick **"Add python.exe to PATH"** during install.
   - ComfyUI docs: 3.14 works, 3.13 is very well supported. This repo was verified on 3.14.3.
   - Check: `python --version`
4. **Disk space.** 20 GB minimum free (torch ~2 GB + deps + a starter model 7–30 GB). E: or C: both fine.
5. No build essentials needed. If `pip install` ever asks for a compiler, stop and tell us — it should never happen.

## 1. Get this repo

```powershell
git clone <this-repo-url> comfyui
cd comfyui
```

Repo layout (what's what):

```text
comfyui/
  runbook.md          <- you are here
  scripts/            <- committed helper scripts (Install.ps1, Start.ps1, Start.bat)
  tmp/                <- LOCAL ONLY, never committed (ComfyUI clone + venv + models live here)
```

## 2. Half-automated setup (recommended)

From the repo root, in normal (non-admin) PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Install.ps1
```

It does §§3–6 for you: clones ComfyUI into `tmp\ComfyUI`, creates `tmp\ComfyUI\venv`,
installs PyTorch cu130 + `requirements.txt`, and verifies CUDA. Then:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Start.ps1
# or double-click scripts\Start.bat
```

Open http://127.0.0.1:8188 — you should see the ComfyUI canvas. Skip to §7.

## 3. Manual setup — clone ComfyUI into local tmp/

`tmp/` is git-ignored on purpose (multi-GB clone + venv + models must not be committed).
From the repo root:

```powershell
mkdir tmp
git clone https://github.com/Comfy-Org/ComfyUI tmp\ComfyUI
```

## 4. Manual setup — create the Windows venv

All installs happen on **Windows** (WSL is dev-only in this repo — never `pip install` from WSL):

```powershell
python -m venv tmp\ComfyUI\venv
tmp\ComfyUI\venv\Scripts\python.exe --version
tmp\ComfyUI\venv\Scripts\python.exe -m pip install --upgrade pip
```

## 5. Manual setup — install PyTorch for YOUR gpu

Pick **one** line. Default = NVIDIA RTX 20-series and newer (incl. 30/40/50 Blackwell, e.g. RTX 5070 Ti).
This is what the reference machine used (torch 2.14.0+cu130):

```powershell
# NVIDIA 20-series+ / RTX 50 Blackwell (recommended default)
tmp\ComfyUI\venv\Scripts\pip.exe install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu130
```

| Your GPU | Use this instead |
|---|---|
| GTX 10-series or older | `pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126` |
| Want nightly (perf experiments) | `pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu132` |
| AMD on Windows (ROCm 10, Python 3.13) | `pip install --index-url https://stable.repo.amd.com/rocm/whl-next/ "torch[device-all]==2.13.0+rocm10.0.0" "torchvision[device-all]==0.28.0+rocm10.0.0" "torchaudio==2.11.0.2+rocm10.0.0"` |
| Intel Arc | `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/xpu` |
| No GPU (CPU only) | `pip install torch torchvision torchaudio` |

Why cu130? ComfyUI requires cu130+ on NVIDIA 20-series and above; older CUDA builds lack Blackwell (sm_120) kernels and fail with "Torch not compiled with CUDA enabled" or missing-kernel errors.

## 6. Manual setup — install ComfyUI dependencies + verify

```powershell
tmp\ComfyUI\venv\Scripts\pip.exe install -r tmp\ComfyUI\requirements.txt
tmp\ComfyUI\venv\Scripts\python.exe -c "import torch; print(torch.__version__, torch.cuda.is_available(), torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'no-cuda')"
# expect e.g.: 2.14.0+cu130 True NVIDIA GeForce RTX 5070 Ti
```

If CUDA prints `False`: re-install torch with the §5 line (and `pip uninstall torch` first if needed), then update your NVIDIA driver.

## 7. First run (example workflow: empty canvas → default image)

```powershell
cd tmp\ComfyUI
.\venv\Scripts\python.exe main.py --listen 127.0.0.1 --port 8188
```

1. Open http://127.0.0.1:8188 — the default workflow loads automatically.
2. Press **Queue** (or Ctrl+Enter). First run downloads nothing by default but errors `model not found` until you add a checkpoint — that's expected, see §7.1.
3. Output lands in `tmp\ComfyUI\output\`. Input images go in `tmp\ComfyUI\input\`.

### 7.1 Where models go (starter: SDXL-Turbo recommended for 16 GB, great for ≤8 GB too)

| File type | Folder |
|---|---|
| Checkpoints (`*.ckpt`, `*.safetensors` — the big model) | `tmp\ComfyUI\models\checkpoints\` |
| VAE | `tmp\ComfyUI\models\vae\` |
| LoRA | `tmp\ComfyUI\models\loras\` |
| ControlNet / upscalers / etc. | matching subfolder under `tmp\ComfyUI\models\` |

Suggested first model (fast, small, 1–4 steps): SDXL-Turbo — place the `.safetensors` in `models\checkpoints\`, refresh the browser (R), select it in the **Load Checkpoint** node, Queue. (Heavier options for later: Flux.1-Schnell, SD3.5, Wan 2.1/2.2 for video.)

## 8. Lower-VRAM / different-PC notes (8–12 GB GPUs)

Same steps work unchanged. Only the launch flags and model choice differ:

```powershell
# 8 GB or less — streams weights through CPU/RAM (slower, but fits)
.\venv\Scripts\python.exe main.py --listen 127.0.0.1 --port 8188 --lowvram
# Alternatives: --normalvram (force normal mode), --highvram (16GB+, keeps more on GPU),
# --disable-smart-memory (old fallback), --cpu (no GPU at all, very slow)
```

Tips: prefer Turbo/Schnell/distilled checkpoints, keep batch size 1, generate at 512–1024px first,
close browsers/Discord overlays to free VRAM, and use `--lowvram` before assuming a model "doesn't fit".

## 9. Updating later

```powershell
cd tmp\ComfyUI
git pull
.\venv\Scripts\pip.exe install -r requirements.txt
```

Our wrapper repo itself updates normally (`git pull` at the root); `tmp/` never conflicts because it's ignored.

## 10. Troubleshooting

| Symptom | Fix |
|---|---|
| `Torch not compiled with CUDA enabled` | `pip uninstall torch`, reinstall with the §5 line for your GPU, update NVIDIA driver |
| `pip` tries to build from source / asks for Visual Studio | Wrong Python or index URL — use Python 3.13/3.14 64-bit and the exact §5/§6 commands |
| Port 8188 busy | `python main.py --port 8189` |
| Can't reach UI from another device | Only bind LAN deliberately: `--listen 0.0.0.0` (default stays localhost for safety) |
| `git clone` into `tmp/` fails | Check Git installed on Windows (not WSL): `git --version` in PowerShell |

---
*Changelog: 2026-09-12 — initial manual install verified (venv + torch cu130 + requirements.txt + CUDA smoke test on RTX 5070 Ti). Next: first real image workflow + starter model download.*
