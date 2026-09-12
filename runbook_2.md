# Runbook 2 — Video-model stack (agent workflow)

> Companion to `runbook.md` (base install). This file is written for an **AI agent**
> reproducing the model setup efficiently, but a human can follow it too.
> Goal: MiniMax H3 + LTX-2.5, most-downloaded official repos, 8GB-friendly quants,
> wired into ComfyUI via project-local `models/` (git-ignored), verified loadable.
> Preconditions: `runbook.md` §§0–6 done (Windows venv works, server boots).

---

## 1. Agent one-time setup: hf CLI skill

1. The HuggingFace skill lives at `.agents/hf-cli/SKILL.md` and **is committed** to this repo.
   Read it before any Hub work (`hf`, `huggingface`, model downloads, auth).
2. The `hf` CLI runs in the **dev environment** (here: WSL2). Model files are data —
   downloading from WSL onto the shared drive is fine. Never `pip install` from WSL.
3. Auth check: `hf auth whoami` → expect `user=<name>`. If not logged in: `hf auth login`
   (browser flow) and re-check. Installed CLI may be older than the skill doc
   (here: 1.10.2 vs 1.30.0) — `hf models card` etc. may not exist; fall back to the
   Hub HTTP API (`https://huggingface.co/api/models/<id>`) plus `curl` for READMEs.
   The user access token (for API calls) lives at `~/.cache/huggingface/token`.

## 2. Model selection procedure (most-downloaded, most-trusted)

1. Search: `hf models list --search "MiniMax H3" --limit 10` (same for `"LTX 2.5"`).
   Pick the official vendor/ComfyUI repos with the highest downloads:
   - H3 diffusion/encoders/VAE/LoRA: `Comfy-Org/MiniMax-H3` (~19M downloads, official
     ComfyUI repack of `MiniMaxAI/MiniMax-H3`). 8-step turbo LoRA exception: it lives at
     repo root of `lightx2v/Minimax-h3-Turbo` (~1.4M downloads, referenced by the template).
   - LTX-2.5 everything: `Lightricks/LTX-2.5` (~1.6M downloads, official).
2. Confirm native ComfyUI support in the local clone (`tmp/ComfyUI`):
   `comfy_extras/nodes_minimax_h3.py` (H3), `comfy_extras/nodes_lt*.py` (LTX).
3. Read the repo README (`.../raw/main/README.md`, auth header if gated) — it contains
   the exact per-folder placement table. Cross-check against the official workflow
   templates (`https://github.com/Comfy-Org/workflow_templates/blob/main/templates/video_minimax_h3_t2v.json`
   etc.): the widget defaults name the exact files (here: `minimax_h3_fl2va_pruned_int8_convrot`,
   `qwen3vl_32b_minimax_h3_nvfp4_awq`, both H3 VAEs, `minimax_h3_fl2v_turbo_8step...`).
4. Quant policy (8GB-VRAM target, cu130 torch): prefer `int8_convrot` diffusion over
   `bf16`/`fp8_scaled` (README says so explicitly), `nvfp4_awq` text encoder for H3,
   `comfy-int8-convrot` DiT + TE for LTX (distilled, fixed 8-step), conv VAE for LTX
   (faster/lighter). Only small files stay bf16/fp16/fp32 by design (LoRAs ~2GB,
   VAEs, upscalers). NVFP4 DiT exists for LTX but needs Blackwell `ltx-kernels` —
   skip it for ComfyUI.
5. Sizes: `GET /api/models/<id>/tree/main?recursive=true` → `size` per path
   (non-recursive default lies — only shows README). Totals here: H3 ~46GB, LTX ~40GB.

## 3. Gating flow (human-in-the-loop, recorded 2026-09-12)

`Lightricks/LTX-2.5` is gated. `Comfy-Org/MiniMax-H3` is not.

1. Agent detects gating: raw README fetch returns
   `Access to model ... is restricted...` (HTTP 200 body on API info is NOT proof —
   only file access counts).
2. Agent **asks the user** to open `https://huggingface.co/Lightricks/LTX-2.5` in a
   browser and click **"Agree and Access"** (accepts the LTX-2.x Community License +
   privacy/ad consent), then tell the agent when done.
3. Agent verifies: `hf download Lightricks/LTX-2.5 README.md --local-dir /tmp/ltx-test`
   → success means access granted. Do NOT start the 40GB pull before this passes.
4. Fresh-machine note for the runbook audience: same flow applies to any future gated
   repo — agent asks, human clicks, agent verifies, then downloads.

## 4. Download procedure (selective, resumable — NOT git clone)

Why not `git clone`: repos are Git-LFS (extra prereq, pointer-file footgun), a clone
pulls ALL variants (~300GB+ for H3 vs ~46GB needed), the set spans 3 repos, gated
clone needs credential setup, and LFS resume is poor. Selective `hf download` fetches
only the needed bytes with hash checks and resume.

```bash
mkdir -p models/{diffusion_models,text_encoders,vae,loras,latent_upscale_models,model_patches}

hf download Comfy-Org/MiniMax-H3 \
  diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors \
  text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors \
  vae/minimax_h3_video_vae_fp16.safetensors \
  vae/minimax_h3_audio_vae_fp32.safetensors \
  loras/minimax_h3_fl2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors \
  --local-dir models

hf download lightx2v/Minimax-h3-Turbo \
  minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors \
  --local-dir /tmp/h3turbo
mv /tmp/h3turbo/minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors models/loras/

hf download Lightricks/LTX-2.5 \
  diffusion_models/ltx-2.5-22b-distilled-transformer-comfy-int8-convrot.safetensors \
  text_encoders/gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors \
  vae/ltx-2.5-video-vae-conv-bf16.safetensors \
  vae/ltx-2.5-audio-vae-bf16.safetensors \
  latent_upscale_models/ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors \
  model_patches/ltx-2.5-duration-head-bf16.safetensors \
  --local-dir models
```

Notes: positional filenames (this `hf` version's `--include` is single-pattern);
`--local-dir` preserves repo subfolder layout; interrupted runs resume in place
(partials under `models/.cache/`, only `.metadata` crumbs remain after success);
~86GB needs ~15 min on a fast link. `models/` is git-ignored (see `.gitignore`).

## 5. Wiring: extra_model_paths.yaml (machine-local)

`models/` lives at repo root; ComfyUI reads it via `tmp/ComfyUI/extra_model_paths.yaml`
(generated, local-only — never committed; per-machine absolute `base_path`):

```yaml
comfyui_video_models:
    base_path: E:/comfyui            # <-- repo root on THIS machine
    diffusion_models: models/diffusion_models/
    text_encoders: models/text_encoders/
    vae: models/vae/
    loras: models/loras/
    latent_upscale_models: models/latent_upscale_models/
    model_patches: models/model_patches/
```

Windows users reproduce everything (download + this file) with one command —
`scripts/Download-Models.ps1` (committed; uses the venv's `huggingface_hub`, no hf CLI
needed; set `$env:HF_TOKEN` from https://huggingface.co/settings/tokens first for the
gated LTX repo; re-runnable/resumable).

## 6. Verification (fast → slow)

1. Loader check (no server boot; mimics `main.py` lines ~142-144):
   ```powershell
   cd tmp/ComfyUI
   ./venv/Scripts/python.exe -c "from utils import extra_config; extra_config.load_extra_path_config('extra_model_paths.yaml'); import folder_paths; [print(k, '->', sorted(folder_paths.get_filename_list(k))) for k in ['diffusion_models','text_encoders','vae','loras','latent_upscale_models','model_patches']]"
   ```
   Expect all 12 files (2 DiT, 2 TE, 4 VAE, 2 LoRA, 1 upscaler, 1 duration head).
   Bare `import folder_paths` lists NOTHING — the yaml loads only via `main.py` or the
   explicit call above (gotcha recorded 2026-09-12).
2. Server boot: `scripts/Start.ps1`, `GET /` → 200, `/system_stats` → torch
   `2.14.0+cu130`, `cuda:0 RTX 5070 Ti`. (Done for base install; repeat after model
   changes if loaders misbehave.)
3. Generation test (per template, `--lowvram` on ≤8GB, text-encoder caching on,
   608x352-ish, turbo 4/8-step or LTX distilled 8-step): pending — first real
   text→image→video→upscale run is the next milestone (user supplies example workflows).

## 7. Exact file manifest (verified 2026-09-12)

| ComfyUI folder | File | Size | Source repo |
|---|---|---|---|
| diffusion_models | minimax_h3_fl2va_pruned_int8_convrot.safetensors | 21.0 GB | Comfy-Org/MiniMax-H3 |
| diffusion_models | ltx-2.5-22b-distilled-transformer-comfy-int8-convrot.safetensors | 21.5 GB | Lightricks/LTX-2.5 |
| text_encoders | qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors | 15.7 GB | Comfy-Org/MiniMax-H3 |
| text_encoders | gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors | 15.4 GB | Lightricks/LTX-2.5 |
| vae | minimax_h3_video_vae_fp16.safetensors | 5.2 GB | Comfy-Org/MiniMax-H3 |
| vae | minimax_h3_audio_vae_fp32.safetensors | 0.6 GB | Comfy-Org/MiniMax-H3 |
| vae | ltx-2.5-video-vae-conv-bf16.safetensors | 1.5 GB | Lightricks/LTX-2.5 |
| vae | ltx-2.5-audio-vae-bf16.safetensors | 0.4 GB | Lightricks/LTX-2.5 |
| loras | minimax_h3_fl2v_turbo_4step_v1.0_768p_comfyui_bf16.safetensors | 2.0 GB | Comfy-Org/MiniMax-H3 |
| loras | minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors | 2.0 GB | lightx2v/Minimax-h3-Turbo |
| latent_upscale_models | ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors | 1.0 GB | Lightricks/LTX-2.5 |
| model_patches | ltx-2.5-duration-head-bf16.safetensors | ~0 GB | Lightricks/LTX-2.5 |

Deliberately NOT downloaded: bf16 full DiTs (66/42GB), bf16 TEs (51/26GB), ref2va
flavor, fp8 variants, dev transformers, DiffVAE, temporal upscaler, GGUF community
packs (need extra custom node). Revisit if quality demands it.

---
*Changelog: 2026-09-12 — H3+LTX stack downloaded (~86GB), wired, loader-verified.
Next: example workflows + first text→image→video→upscale generation.*
