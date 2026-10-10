# Qwen-Image-2.1 TURBO on the 8GB card (image generation)

## −1. README-FIRST RULE (read before downloading anything — no exceptions)

The people who published these quants already ran the model, found the working
sampling params, loader versions, and pitfalls. Their READMEs ARE the manual —
this file is only the local adaptation. Before any download, model pick, or
workflow edit:

1. Read these three READMEs END TO END (not skim — read):
   - https://huggingface.co/realrebelai/Qwen-Image-2.1-Turbo_GGUFs/blob/main/README.md
     (Turbo doctrine: steps, CFG, schedule, which files exist, install order)
   - https://huggingface.co/Comfy-Org/Qwen-Image-2.1/blob/main/README.md
     (official file layout: which TE/VAE/Lora belongs to Turbo vs base 2.1)
   - The README of WHICHEVER GGUF fork you install (leejet or molbal — supported
     architectures, node names, minimum ComfyUI version).
2. Follow THEIR references too: every link inside those READMEs (fork repos,
   workflow templates, Comfy-Org model pages) gets opened and checked against
   what you actually have on disk. A README saying "needs recent ComfyUI" means:
   check YOUR `git -C tmp/ComfyUI log` date, don't assume.
3. Extract to `memories.md` BEFORE acting: exact filenames, steps, CFG, sampler/
   scheduler, TE `type` value, VAE filename, file-placement map. If a README
   contradicts this skill file, the README wins and you UPDATE this file.
4. Re-read on failure: first debugging step for ANY image error is re-reading
   the quantizer README's install/troubleshooting section, not improvising.

Why: quantizer guidance (schedule, CFG 1.0, no stacked LoRAs, FIXED-filename trap)
is the difference between a first-try render and a lost afternoon. Trust people
who already burned the VRAM over your own priors.

ALL user-facing text Hungarian (see `hungarian-communication.md`).
Nicknames: képrajzoló = DiT GGUF, képszövegértő = text encoder, kép-összerakó = VAE.
Full file/size catalog: `MODELS.md` §image models. Download with your own
`hf` CLI (`hf download ... --include ...`); repos are OPEN (no token, no gate).

## 0. What you need (default set, ~14.4GB)

```text
models/diffusion_models/qwen_image_2.1_turbo_w4a8_convrot.safetensors  4.20 GB  (GPU VRAM, stock UNETLoader — NO fork)
   -- OR --
models/diffusion_models/Qwen-Image-2.1-Turbo-Q4_K_S.gguf   4.33 GB  (GPU VRAM, needs fork — fallback)
models/text_encoders/qwen3vl_8b_int8_convrot.safetensors   9.35 GB  (SYSTEM RAM!)
models/vae/qwen_image_2.1_vae_bf16.safetensors             0.68 GB  (GPU VRAM)
```

w4a8 source: realrebelai Turbo repo (same file family as the GGUFs). TE/VAE: same 2.1 family — abenzerps or Comfy-Org copy. RAM-saver TE alt: Comfy-Org `qwen3vl_8b_w4a8` 6.3GB. Machine needs 16GB+ system RAM.

Turbo doctrine (quantizer README, non-negotiable): **8 steps**, **CFG 1.0** start,
correct Turbo sigma schedule (generic Euler-8 is NOT equivalent), NEVER stack
another Turbo/accel LoRA on distilled weights.

## 1. Loader decision: w4a8 native FIRST (15-minute test, could skip §2 entirely)

The shipped realrebelai workflow contains BOTH a stock `UNETLoader` (w4a8_convrot)
and `UnetLoaderGGUF` branch — the quantizer expects you to try native first:

1. Requires recent ComfyUI (native Qwen-Image 2.1 support) → run
   `scripts\Update-ComfyUI.ps1` bump BEFORE this test if not bumped yet.
2. Wire the stock `UNETLoader` → `qwen_image_2.1_turbo_w4a8_convrot.safetensors`,
   render the benchmark prompt at 768². Criteria: validates + renders + quality
   on par with expectations → KEEP w4a8, skip §2 (no fork, no regression risk).
3. Only if w4a8 fails (missing kernels, artifacts, OOM): fall to the GGUF file
   and continue with §2.

## 2. Node pack (GGUF path ONLY — skip entirely if w4a8 won)

Stock registry `ComfyUI-GGUF` (city96) does NOT know this architecture
(`Unknown model architecture!`). Order: **leejet/ComfyUI-GGUF first**,
**molbal/ComfyUI-GGUF as alt** (each named by a quantizer README).
Same node names → they COLLIDE → this is a REPLACE, not an addition:

1. Try: `comfy node install <fork-url>` (falls back to: `git clone <fork-url>`
   into `tmp/ComfyUI/custom_nodes/` after moving the city96 folder aside —
   never delete it, rename to `ComfyUI-GGUF-city96-disabled`).
2. Restart the backend (Swarm: Restart All Backends; direct: relaunch).
3. Regression check FIRST: `validate_workflow` the existing LTX GGUF video
   workflow — the fork must still load it. If validation breaks, roll back
   (reinstall city96 / rename back) and STOP with a Hungarian note + 2 options.
   Do not lose working video for unproven image.

## 2. Workflow: quantizer's shipped JSON first, official template as alt

Primary: `QWEN IMAGE 2.1 (WORKFLOW).json` from the realrebelai repo Files tab
(the quantizer's own Turbo-compatible graph — has both loader branches, see §1). Save a copy to repo `workflows/`
with a spaceless name (e.g. `image_qwen2_1_turbo_Q4KS.json`). Then the fix set —
the shipped JSON has TWO traps:

- `UnetLoaderGGUF` widget = `Qwen-Image-2.1-Turbo-Q4_K_S-FIXED.gguf` — a `-FIXED`
  file that is NOT in the Files tab → widget-swap to your real download.
- `CLIPLoader` widget = `qwen3vl_8b_w4a8.safetensors` → swap to
  `qwen3vl_8b_int8_convrot.safetensors`, type `qwen_image`, offload/device CPU.
- `VAELoader` = `qwen_image_2.1_vae_bf16.safetensors` (already right, just check
  the file is really there).
- Steps = 8, CFG = 1.0 (Turbo schedule — do not "improve" to 20 steps).

Alt (only if the shipped graph won't validate): official Comfy-Org templates
`image_qwen_image_2_1_t2i.json` / `..._image_edit.json` + UNET→GGUF-loader swap.
`validate_workflow` before EVERY queue (same rule as video).

## 3. 8GB tuning (this card's envelope)

- Batch 1, always. Resolution ladder: **768×768 first**, then 1024×1024.
  Resolution is the VRAM knob — weights fitting is NOT enough.
- Quant ladder: Q3_K_S 3.27GB (comfort) → Q4_K_S 4.33GB (default) → Q5_K_S 6.91GB
  (only if Q4 at 1024² shows ≥1GB headroom — heavier than it looks). One short
  render per rung before committing. 8 steps each, so iterations are cheap —
  use that: benchmark properly instead of guessing.
- If OOM: `--lowvram` backend flag before dropping quant (narrate the trade —
  never silently drop quality).
- If Turbo REFUSES a prompt (safety): uncensored path is abenzerps base-2.1 UC
  set + UC LoRA (MODELS.md fallback) — discuss in Hungarian BEFORE downloading
  a second image stack (~15GB more).

## 4. Benchmark protocol (first image session)

SAME prompt at 768² and 1024², w4a8 first then Q3/Q4 GGUF if reached (8 steps each, cheap).
Record per render: peak VRAM, wall time, quality verdict. Append to the drive
SKILL.md calibration table + `memories.md` log, e.g.:

| RTX 3060 Ti 8GB | Qwen2.1-Turbo Q4 t2i | 1024x1024, 8 steps, CFG 1.0, TE in RAM | ~X:XX, peak Y.YGB |

That table is how the next session estimates cost — sacred, like video rows.

## 5. Hungarian narration (beginner user!)

- Never say GGUF/VRAM/CLIP untranslated: "tömörített képrajzoló (ez lakik a
  videókártyán)", "szövegértő (ez a gép memóriájában, nem a kártyán)".
- Turbo in one sentence: "ez a gyorsított változat: 8 lépésben rajzol a régi
  20–30 helyett, ezért percek helyett másodpercek."
- One action per message; yes/no questions with the explanation inside the option.
