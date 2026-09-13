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

## 0. From-zero prerequisites: Git + Python + NVIDIA driver (~15 min, do this first)

Assume a fresh Windows 10/11 machine with **nothing** installed. You need exactly 3 things.
Pick **Option A (one-line, recommended)** or **Option B (manual download)** per item.
After each item, run its **Check** line in a *fresh* PowerShell window
(Start menu → type `PowerShell` → Enter; after any install, close and reopen it).

### 0.1 Git (required — without it you cannot even download this repo)

```powershell
# Option A (recommended): one line, accepts defaults for you
winget install --id Git.Git -e --source winget
```
- Option B: open https://git-scm.com/download/win → download the 64-bit installer →
  Next through everything (defaults are fine).
- Check (fresh PowerShell):
  ```powershell
  git --version
  # expect e.g.: git version 2.53.0.windows.2
  ```
- If `git: command not found`: close ALL PowerShell/terminal windows, reopen, retry.
  Still failing? Reinstall Git and leave the "Add Git to PATH" option enabled.

### 0.2 Python 3.13 or 3.14, 64-bit (required — ComfyUI runs on it)

```powershell
# Option A (recommended): Python 3.13 (most compatible with custom nodes)
winget install --id Python.Python.3.13 -e --source winget
```
- Option B: open https://www.python.org/downloads/ → download Python 3.13 (or 3.14) 64-bit →
  run installer → **on the very first screen, tick "Add python.exe to PATH"** →
  then "Install Now". This checkbox is the #1 cause of failures — do not skip it.
  (Verified on 3.14.3; ComfyUI docs: 3.14 works, 3.13 is very well supported.)
- Check (fresh PowerShell):
  ```powershell
  python --version
  # expect e.g.: Python 3.13.x or Python 3.14.3
  ```
- If `python: command not found`: reboot-shell first (close/reopen PowerShell).
  Still failing? `py --version` may work instead — then use `py` wherever this guide says `python`.
  Last resort: reinstall Python with the PATH checkbox ticked, or
  `winget install --id Python.Python.3.13 -e --source winget --force`.

### 0.3 NVIDIA driver (required for GPU; skip only for CPU-only mode)

- Open https://www.nvidia.com/drivers/ → your card (e.g. RTX 5070 Ti) → Download → Install → Reboot.
- Check:
  ```powershell
  nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv
  # expect e.g.: NVIDIA GeForce RTX 5070 Ti, 616.56, 16303 MiB
  ```
- If `nvidia-smi` is unknown: driver install didn't take — reinstall + reboot.

### 0.4 Disk space + what you DON'T need

- 20 GB minimum free (torch ~2 GB + deps + starter model 7–30 GB). E: or C: both fine.
- You do **NOT** need: admin rights (except if *you* choose system-wide Python),
  Visual Studio, C++ build tools, Chocolatey, Node.js, Docker, WSL, or CUDA Toolkit
  (PyTorch bundles its own CUDA — the driver from §0.3 is enough).
  If any `pip install` ever asks for a compiler, stop — something deviated from this guide.

## 1. Get this repo (needs Git from §0.1)

```powershell
# fresh PowerShell, pick a home for it (Documents, E:\, etc.)
git clone <this-repo-url> comfyui
cd comfyui
```
No Git yet? Go back to §0.1 — there is no way around it.

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

> Video models (MiniMax H3 + LTX-2.5) live in `runbook_2.md` — agent-oriented workflow
> covering gated-access, selective download into `models/`, and loader verification.

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

### Stopping ComfyUI

- Started in a terminal (`Start.ps1`, `Start.bat`, or manual): focus that window, press
  **Ctrl+C** (answer `Y` if it asks to terminate the batch job), then close the window.
- Running detached / lost the window: Task Manager → find the `python.exe` running
  `main.py` → End task. Check `http://127.0.0.1:8188` no longer responds.

### 7.1 Where models go (starter: SDXL-Turbo recommended for 16 GB, great for ≤8 GB too)

| File type | Folder |
|---|---|
| Checkpoints (`*.ckpt`, `*.safetensors` — the big model) | `tmp\ComfyUI\models\checkpoints\` |
| VAE | `tmp\ComfyUI\models\vae\` |
| LoRA | `tmp\ComfyUI\models\loras\` |
| ControlNet / upscalers / etc. | matching subfolder under `tmp\ComfyUI\models\` |

Suggested first model (fast, small, 1–4 steps): SDXL-Turbo — place the `.safetensors` in `models\checkpoints\`, refresh the browser (R), select it in the **Load Checkpoint** node, Queue. (Heavier options for later: Flux.1-Schnell, SD3.5, Wan 2.1/2.2 for video.)

### 7.2 Interface language (i18n)

The UI is switchable per user: gear icon → Settings → **Language** (`Comfy.Locale`).
Frontend 1.52.7 ships 14 languages: English (default), Chinese (simplified + traditional),
Russian, Japanese, Korean, French, Spanish, Arabic, Turkish, Portuguese (BR), Farsi,
Hebrew, Italian. **Hungarian is NOT bundled** — a Hungarian-speaking user picks one of
the above for now (or uses browser auto-translate as a stopgap). New languages come from
community translation PRs to `Comfy-Org/ComfyUI_frontend` and arrive via a frontend
package update — no server flag needed, the setting is per browser.

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

## 9.5 SwarmUI (easier graphical front-end on top of ComfyUI) — setup + agent checklist

SwarmUI is a friendly web UI (no node graphs unless you want them) that manages a ComfyUI
backend underneath. It REUSES our pre-baked install (venv + 86GB models + Manager) —
it does not replace it. Server: `http://localhost:7801`; it auto-starts its own comfy
process on port 7821 (so a manually-run :8188 stays untouched).

### What the human does (one-time install)

1. Prereq: .NET SDK 8 or 10 (check: `dotnet --list-sdks`). Missing? The install script
   offers to add SDK 8 via winget (user-level, no admin).
2. `powershell -ExecutionPolicy Bypass -File scripts\Install-Swarm.ps1`
   — clones SwarmUI to `tmp\SwarmUI` and builds it (~30s, 0 warnings expected).
3. `powershell -ExecutionPolicy Bypass -File scripts\Start-Swarm.ps1`
   — starts the server; a browser opens (or go to) `http://localhost:7801/Install`.
4. **Installer wizard — what to pick (critical!):**
   - Theme/account: anything (e.g. modern_dark, 'just yourself').
   - **"What backend would you like to use?" → choose `None / Custom / Choose Later`.**
     (Do NOT click 'ComfyUI (Local)' — that downloads a SECOND 20GB+ comfy into
     Swarm's own dlbackend folder and duplicates everything.)
5. After the wizard: main interface → **Server tab → Backends** → **Add Backend** →
   type: **ComfyUI Self-Starting** → set **StartScript** =
   `E:/comfyui/tmp/ComfyUI/main.py` (adapt drive if repo lives elsewhere) →
   leave every other field default → Save → **Restart All Backends**.
6. First boot takes ~2–4 min: the log shows repeated
   `Self-Start ComfyUI (Installing 'rembg') exited properly.` lines — that is Swarm's
   staged dependency check pip-installing a handful of helper packages INTO OUR VENV
   (rembg, onnxruntime, matplotlib, opencv-python-headless, imageio-ffmpeg, dill,
   omegaconf; plus updates: diffusers, ultralytics, comfyui_frontend_package).
   This is expected and one-time. Wait for:
   `Self-Start ComfyUI-0 on port 7821 started.`
7. Sanity check: generate a small image from the Generate tab. Done.

### What the agent does (support checklist)

- Verify build: `dotnet build` output ends `0 Error(s)`.
- Verify graft after the human saves the backend — read `tmp/SwarmUI/Data/Backends.fds`:
  expect `type: comfyui_selfstart`, `StartScript: E:/comfyui/tmp/ComfyUI/main.py`,
  `enabled: true`. (`ExtraArgs` may contain `\x` — harmless placeholder.)
- Verify live state:
  - `http://127.0.0.1:7801/` → 302 (webserver up)
  - `http://127.0.0.1:7821/` → 200 (comfy backend up)
  - listeners: 7801 = SwarmUI.exe, 7821 = python (our venv)
- Explain the log lines if the human pastes them (see step 6 — dependency staging,
  not errors).
- Never let the human point StartScript at a different comfy or delete `tmp/ComfyUI`.
- GUI fallback for backend management: Server → Backends → ✎ edit / Restart / View Logs.

### Comfy workflow tab

SwarmUI has a full Comfy node-graph editor built in (top tab `Comfy Workflow Editor`):
the multi-node text→image→video→upscale pipeline can be built/edited there and saved
via `Use This Workflow`. The backend must be a ComfyUI backend (it is).

## 10. Troubleshooting

| Symptom | Fix |
|---|---|
| `python: command not found` | See §0.2: close/reopen PowerShell; try `py --version`; reinstall Python with **Add to PATH** ticked |
| `git: command not found` | See §0.1: close/reopen PowerShell; reinstall Git (keep Add-to-PATH enabled) |
| `winget: command not found` | Old Windows — use Option B manual downloads in §0.1/§0.2, or update App Installer from Microsoft Store |
| `Torch not compiled with CUDA enabled` | `pip uninstall torch`, reinstall with the §5 line for your GPU, update NVIDIA driver |
| `pip` tries to build from source / asks for Visual Studio | Wrong Python or index URL — use Python 3.13/3.14 64-bit and the exact §5/§6 commands |
| Port 8188 busy | `python main.py --port 8189` |
| Can't reach UI from another device | Only bind LAN deliberately: `--listen 0.0.0.0` (default stays localhost for safety) |
| `git clone` into `tmp/` fails | Check Git installed on Windows (not WSL): `git --version` in PowerShell |

---
*Changelog:*
- *2026-09-12 — manual install verified (venv + torch 2.14.0+cu130 + requirements.txt + CUDA smoke test on RTX 5070 Ti).*
- *2026-09-12 — scripts e2e-tested in isolated `tmp/script-e2e-test/` (fresh clone + fresh venv via Install.ps1, boot via Start.ps1): `GET /` → 200 ComfyUI page, `/system_stats` → comfyui 0.35.0 / python 3.14.3 / torch 2.14.0+cu130 / cuda:0 RTX 5070 Ti (17.1 GB VRAM). Next: first real image workflow + starter model download.*
