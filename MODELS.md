# Model Catalog (downloadable, validated links)

Two committed profiles live in `scripts/Download-Models.ps1`; everything else here is
the on-demand catalog. The agent downloads from this catalog on request (setup
discipline: official/most-downloaded repos, selective `hf download` via
`Download-Models.ps1` patterns or venv `huggingface_hub`, record what was added).

## Canonical picks (one file per role — workflows get swapped TO these, never re-downloaded around)

| Role (nickname) | Canonical file | Why |
|---|---|---|
| videó-agy, GGUF (friend) | `LTX-2.5-Distilled-Q3_K_M.gguf` 11.5GB (realrebelai) | most-downloaded quant; matches curated civitai workflow |
| videó-agy, native (friend alt) | `LTX-2.5-Distilled-w4a8.safetensors` 12.5GB (Rebels) | no GGUF pack needed |
| videó-agy (full) | `ltx-2.5-22b-distilled-transformer-comfy-int8-convrot.safetensors` (Lightricks) | official |
| szövegértő (friend) | `gemma4-12b-ltx25-w4a8.safetensors` 8.4GB (Rebels) | smallest working |
| szövegértő (full) | `gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot.safetensors` (Lightricks) | official |
| képösszerakó | `ltx-2.5-video-vae-conv-bf16.safetensors` (Lightricks) | workflows naming the non-conv file get swapped to this |
| hangagy | `ltx-2.5-audio-vae-bf16.safetensors` (Lightricks) | only one |
| felnagyító | `ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors` (Lightricks) | only one |
| képrajzoló, GGUF Turbo (8GB default) | `Qwen-Image-2.1-Turbo-Q4_K_S.gguf` 4.33GB (realrebelai) | official 8-step distilled; Q3_K_S 3.27GB = comfort fallback; Q5_K_S 6.91GB only if headroom proven |
| képszövegértő (CPU RAM!) | `text_encoders/qwen3vl_8b_int8_convrot.safetensors` 9.35GB (same repo) | 8B encoder NEVER goes in VRAM on 8GB cards — offload to system RAM, encodes once per prompt |
| kép-összerakó (VAE) | `vae/qwen_image_2.1_vae_bf16.safetensors` 0.68GB (same repo) | tiny; stays in VRAM |

## Profiles

| Profile | Target | Contents | Size | Set by |
|---|---|---|---|---|
| `friend` (default) | 8GB VRAM | LTX GGUF DiT Q3_K_M + w4a8 Gemma4 encoder + 2 VAEs + spatial upscaler + duration head | ~23 GB | `Download-Models.ps1` |
| `full` | 16GB+ (author reference, verified) | full manifest in `runbook_2.md` §7 (H3 int8+nvfp4, LTX int8 distilled+int8 TE, 4 VAEs, 2 turbo LoRAs, upscaler, duration head) | ~86 GB | `Download-Models.ps1 -Profile full` |

`-WithW4A8DiT` switch (friend): adds native w4a8 LTX DiT (12.5GB, stock Load-Diffusion-
Model node — alternative to GGUF, no ComfyUI-GGUF pack needed).

## Catalog — LTX-2.5
| What | Repo / file | Size | Notes |
|---|---|---|---|
| GGUF DiT ladder | https://huggingface.co/realrebelai/LTX-2.5_GGUFs | Q2_K 8.8 / Q3_K_M 11.5 / Q4_K_S 13.9 / Q4_K_M 15.1 / Q5_K_M 16.8 / Q6_K 18.7 / Q8_0 23.6 GB | Q3_K_M = curated workflow default; go UP for quality, DOWN for VRAM |
| w4a8 DiT (native) | https://huggingface.co/realrebelai/Rebels_w4a8s — `LTX/LTX-2.5-Distilled-w4a8.safetensors` (+ `-audiofix` 15.2GB) | 12.5 GB | stock nodes; `asym_w4a8_int8` kernels (needs 20-series+) |
| w4a8 encoder | same repo — `LTX/ENCODERS/gemma4-12b-ltx25-w4a8.safetensors` (+ `-v2`) | 8.4 GB | stock CLIPLoader; friend-profile default; swap = one widget edit |
| w4a8_convrot DiT (distilled/dev) | https://huggingface.co/Winnougan/ltx-2.5-w4a8-convrot-int4-convrot-Winnougan-Blessing — `diffusion_models/ltx-2.5-22b-{distilled,dev}-transformer-w4a8_convrot.safetensors` | 12.5 GB each | OPEN repo (no token); selected by the FLF2V curated workflow; INT4 files mentioned in its README are NOT uploaded (only w4a8 present) |
| w4a8_convrot encoder | same Winnougan repo — `text_encoders/gemma4-12b-with-proj-ltx-2.5-w4a8_convrot.safetensors` | 10.6 GB | OPEN repo; alternative to the Rebels w4a8 encoder |
| video VAE (non-conv) | https://huggingface.co/Lightricks/LTX-2.5/blob/main/vae/ltx-2.5-video-vae-bf16.safetensors | ~1.5 GB | GATED; referenced by Director/FLF2V workflows — swap widget to our `-conv-` file instead of downloading |
| VAEs (both) | https://huggingface.co/Lightricks/LTX-2.5/tree/main/vae | 1.45 + 0.36 GB | in both profiles |
| Upscalers | https://huggingface.co/Lightricks/LTX-2.5/tree/main/latent_upscale_models | 1.0 GB spatial (+0.26 temporal) | spatial in both profiles |

## Catalog — MiniMax H3 (8GB experiment tracks + upgrades)

| What | Repo / file | Size | Notes |
|---|---|---|---|
| Official ComfyUI pack (full profile) | https://huggingface.co/Comfy-Org/MiniMax-H3 | 21+15.7+7+2+4 GB | int8 DiT + nvfp4 TE — the verified setup |
| H3 w4a8 (native) | https://huggingface.co/realrebelai/Rebels_w4a8s — `MiniMax/MiniMax-H3-REF2VA-w4a8.safetensors` | 24.5 GB | REF2VA + audio; mixed int8 adaln rows |
| Kijai experimental | https://huggingface.co/Kijai/MiniMax-H3-experimental | various | the proven 8GB-4060 recipe (see drive skill sources) |
| Small H3 text encoders | 4B: https://huggingface.co/Merserk/qwen3vl-4b-int4-convrot — 8B alt: https://huggingface.co/Winnougan/Comfy-Qwen3-VL-INT8 | few GB | swap for the 32B nvfp4 TE on constrained machines |

## Catalog — image models (TURBO is the plan: official 8-step distilled, ~3x fewer steps than base 2.1)

Default repo (OPEN — no token, no gate): https://huggingface.co/realrebelai/Qwen-Image-2.1-Turbo_GGUFs — **realrebelai**, the same quantizer as the friend-profile LTX GGUFs (trusted toolchain). Base: official `Qwen/Qwen-Image-2.1-Turbo` (also OPEN). License: Qwen Research. Sizes recorded 2026-10-10. Turbo doctrine (from the quantizer README): 8 steps, **CFG 1.0 start**, correct Turbo sigma schedule required (generic Euler-8 is NOT equivalent), NEVER stack another Turbo/accel LoRA on distilled weights.

| What | File | Size | Notes |
|---|---|---:|---|
| képrajzoló w4a8_convrot (**test FIRST — could skip the fork entirely**) | `qwen_image_2.1_turbo_w4a8_convrot.safetensors` → `models/diffusion_models/` | 4.20 GB | stock UNETLoader, NO GGUF fork needed, same asym kernels as the friend LTX w4a8 path (3060 Ti qualifies); needs recent ComfyUI (bump first). Smaller than Q4 GGUF — keep unless GGUF visibly wins |
| képrajzoló Q4_K_S (default if w4a8 disappoints) | `Qwen-Image-2.1-Turbo-Q4_K_S.gguf` → `models/diffusion_models/` | 4.33 GB | needs leejet/molbal fork (below); proven GGUF pattern, same as LTX video |
| képrajzoló Q3_K_S (comfort fallback) | `Qwen-Image-2.1-Turbo-Q3_K_S.gguf` → same | 3.27 GB | if Q4 OOMs at 1024² |
| képrajzoló Q5_K_S (only if headroom proven) | `Qwen-Image-2.1-Turbo-Q5_K_S.gguf` → same | 6.91 GB | heavier than it looks (mixed-precision preset) — benchmark BEFORE committing |
| képszövegértő int8 (**unchanged**) | `text_encoders/qwen3vl_8b_int8_convrot.safetensors` → `models/text_encoders/` | 9.35 GB | same 2.1 family (abenzerps or Comfy-Org copy); lives in SYSTEM RAM, never VRAM |
| VAE (**unchanged**) | `vae/qwen_image_2.1_vae_bf16.safetensors` → `models/vae/` | 0.68 GB | same family |

Total download either path: ~14.2–14.4GB. Needs 16GB+ system RAM. RAM-saver alt: Comfy-Org `text_encoders/qwen3vl_8b_w4a8.safetensors` 6.3GB instead of int8 9.35GB (same RAM slot, less of it). Official Comfy-Org Turbo int8_convrot (7.26GB) is DISCARDED for 8GB — fatter than Q6 GGUF, no point. VRAM math same as before — resolution is the knob: 768² first, then 1024², batch 1, TE on CPU.

Starter workflow: the quantizer SHIPS one in-repo — `QWEN IMAGE 2.1 (WORKFLOW).json` — prefer it over the generic Comfy-Org template. Two traps inside: it references `Qwen-Image-2.1-Turbo-Q4_K_S-FIXED.gguf` (a `-FIXED` file NOT in the Files tab → widget-swap to the real download) and a `qwen3vl_8b_w4a8` TE (swap to our int8 file). `validate_workflow` before queue, as always.

Node pack (ONLY for the GGUF path): **leejet/ComfyUI-GGUF first** (stable-diffusion.cpp author, named by the abenzerps README), **`molbal/ComfyUI-GGUF` as alt** (named by the realrebelai README). Either REPLACES registry city96 (same node names = collision = swap, not addition). If w4a8 wins the benchmark, NO fork swap happens at all. LTX GGUF regression check + rollback rule unchanged (drive `references/image-qwen.md`).

Documented ALTS (not the default): **Abiray `viggle-4-steps-turbo-GGUF`** (58k downloads, 4-step = even faster — but third-party Viggle finetune base, not official Qwen Turbo); **AtomicChat abliterated-UC Turbo GGUFs** (uncensored claim, unknown author, unvalidated); **abenzerps base-2.1 UC set + UC LoRA** (previous default — keep as the uncensored fallback path if Turbo refuses prompts).

Superseded default (kept as UNCENSORED fallback): abenzerps base-2.1 UC set — `qwen-image-2.1-UC-Q5_K_M.gguf` 5.22GB (default) / Q4_K_M 4.60GB (fallback) / Q6_K 5.88GB (borderline) + same TE/VAE + optional `qwen-image-2.1-uncensored-lora.safetensors` — https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF (OPEN). Use ONLY if Turbo refuses prompts and no Turbo-side fix works.

VRAM math for the 8GB card (Turbo Q4 default) — weights are NOT the whole story:

```text
8.0 GiB physical
− ~0.5–1.0 GiB  Windows / display / CUDA / ComfyUI overhead
− ~4.3 GiB     Q4 Turbo DiT weights
− ~0.7 GiB     VAE
− ~2–6 GiB     activations + attention workspace + latents (grows with resolution!)
```

Ladder rule: Q3 → Q4 → Q5(S!), one short render per rung, record peak VRAM + time (drive skill `references/image-qwen.md` has the protocol).

w4a8 alts (not the plan, kept for reference): https://huggingface.co/realrebelai/Rebels_w4a8s — `Flux2-Klein-4B-w4a8` 2.5GB (6GB cards), `Z-Image-Turbo-w4a8` 3.7GB (8 steps), `Flux2-Klein-9B-w4a8` 5.6GB, `Krea-2-Turbo-w4a8` 7.2GB. Also `MiniMax-Music-3-w4a8` 1.5GB (audio), `Wan-Animate-2-TURBO-w4a8` 9.6GB (video+animate), `Qwen-Image-2512-w4a8` 14.5GB.

## Rules

- New model file → goes in the matching `models/` subfolder; loader widget in
  workflows may need a name swap (drive skill narrates it).
- Quality ladder rule: prefer the SAME model at a higher quant before switching
  models entirely; validate a new quant with one short render before committing.
- Where HF links rot, re-check the repo tree via the HF API (sizes above recorded
  2026-09-16).
