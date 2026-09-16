# Workflow Editing Doctrine

## Before touching anything

1. Read the whole JSON: top-level nodes, MarkdownNotes, AND `definitions.subgraphs`
   (behavior hides in subgraph internals — the LTX hidden rewriter lived there).
2. Identify the parameter surface: which widgets are meant to change (prompts,
   resolution/frames primitives, seeds, group bypassers) vs implementation.
3. Note the custom-node dependencies (rgthree bypassers, Easy-Use memory cleaners,
   GGUF loaders, JW string nodes) — they imply node-packs that must be installed.

## Edit types (in order of preference)

1. **Widget edit** — change values in place. Default. Zero structural risk.
2. **Batch of widget edits** — the NORMAL case on slow machines: collect all changes
   the user asked for, narrate each (HU), one render, explain the combined result.
3. **Graph surgery** — add/remove/relink nodes. Only when the request cannot be a
   widget edit. Requires explicit user OK; narrate before/after ("mi volt, mi lett,
   miért"). Teach the concept by name (bypass, conditioning link, latent chain) —
   the user reads graphs (DaVinci/Photoshop background) and is learning.

## Verification (do not trust the canvas)

- `validate_workflow` against live `object_info` before every queue.
- **Submitted-graph check**: what goes to the sampler is the serialized prompt, not
  widget state. For LTX graphs: confirm the switch/boolean that selects raw prompt vs
  `TextGenerateLTX2Prompt` output is set to RAW. Two different prompts producing near-
  identical video = rewriter still active or something is bypassed wrong.
- **Flight recorder**: ComfyUI embeds the full graph in the output mp4/png. When a
  result contradicts the edit history, read the graph out of the output file.
- **Output hash check** on suspicion: two renders with identical bytes from different
  prompts = the prompt never reached the model.

## Encoder swap (friend profile - the FIRST edit on any LTX workflow)

The curated `workflows/LTX2.5-downloaded-workflow.json` and the official LTX templates
ship pointing at the int8 encoder (`gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot`,
15.4GB). The friend profile downloads the w4a8 encoder
(`gemma4-12b-ltx25-w4a8.safetensors`, 8.4GB) instead. So on the friend machine:
- widget-edit every `CLIPLoader` node's filename to the w4a8 encoder present in
  models/text_encoders (narrate: "a szovegertot lecsereltem a 8,4GB-os tomoritett
  valtozatra - kevesebb VRAM, elvileg elhanyagolhato minosegveszteseg").
- `validate_workflow` catches missing-model errors before queueing; trust it.
- Swap on-demand both ways: slower machine / long renders -> w4a8; quality-critical
  run with VRAM headroom -> int8 (download from MODELS.md catalog first).

## Quant dedup (canonical models — read BEFORE downloading anything)

Different workflows reference different people's quants of the SAME base model
(same role, same loader family) — they are functionally interchangeable. NEVER
download the same role twice in different quant clothing because 4 workflows name
4 files. Canonical source: realrebelai (most downloaded = best-tested). Procedure:
1. Workflow needs file X with role R (DiT / text encoder / VAE / upscaler).
2. If a canonical file for R is already in `models/` → widget-swap the workflow
   to it (narrate with nicknames, see HU glossary), do NOT download X.
3. Download X only if: no canonical file for R exists, or canonical provably
   fails (OOM / validation error) — then record WHY in the session + MODELS.md.
4. The friend CAN pick files in UI dropdowns when guided (nickname + filename +
   where to click) but prefers the agent to do it.

Canonical picks live in `MODELS.md` (§Canonical picks).

## YouTube-curated workflows (inspect + adapt before first run)

Three workflows from YouTube videos live in `workflows/` (friend-facing blurbs in
`workflows/README.md`). Doctrine: NEVER run as-is — inspect, swap, record.

**Inspection checklist (every curated workflow, before first queue):**
1. Extract all loader widget filenames (DiT/TE/VAE/LoRA/GGUF) — script pattern:
   parse JSON, list nodes whose type contains Load/Loader/GGUF + their
   widgets_values. Compare against `models/`: HAVE vs NEED.
2. List custom node types (anything outside core: KJ/LTX*, rgthree, VHS_, Easy-Use,
   RTX*) → missing packs install via `comfy node install`, then RECORD in
   node-packs list + restart backend.
3. Find personal inputs (LoadImage/VHS_LoadVideo pointing at someone else's files)
   → swap with the user's own images/video (narrate in HU).
4. Subgraphs hide loaders/rewriters — check `definitions.subgraphs` too.
5. `TextGenerateLTX2Prompt` (or any prompt rewriter) → SURFACE to the user before
   queueing (drive hard rule), even when the workflow keeps it by design.
6. Record every swap in the session + `workflows/README.md` if it becomes the
   recommended path for a profile.

**Per-workflow maps (verified 2026-09-16 by JSON inspection, NOT yet run):**

- `LTX_2.5_FLF2V_8GB_NATIVE_AUDIO_NEGATIVE.json` — official-template-derived FLF2V
  (first+last frame) in a subgraph, native-audio ON/OFF via ComfySwitchNode guider
  select. References BOTH int8-official and w4a8_convrot DiT+TE (switchable):
  friend profile → select w4a8_convrot (Winnougan, 12.5+10.6GB, catalog — NOT
  downloaded by default); full profile → int8 works as-is. VAEs referenced as
  `ltx-2.5-video-vae-bf16` (NON-conv — not in our manifest; swap widget to our
  `-conv-` file or download the non-conv) + audio VAE (have). KEEPS
  `TextGenerateLTX2Prompt` enhancer by design → surface it, offer OFF. LoadImage
  slots = author's personal PNGs → swap. 8GB-tested settings per author.
- `LTX2.5-director-2.0.json` — timeline directing (LTXDirector/Guide, segment
  prompts, first/mid/last guidance, v2v continuation). REQUIRES Kijai nodes
  (`DiffusionModelLoaderKJ`, `LTXDirector*`, `LTXV*` → install Kijai pack) +
  VHS (`VHS_VideoCombine` → VideoHelperSuite, NOT in default pack set) + rgthree.
  VAE widgets non-conv → swap to conv. CLIP int8 → friend swaps w4a8 encoder.
  DiT int8 via KJ loader (full profile has it).
- `RTX-SR-upscaler-video.json` — 3 nodes: VHS_LoadVideo →
  `RTXVideoSuperResolution` → VHS_VideoCombine. REQUIRES the RTX VSR node pack
  (exact registry name unconfirmed — `comfy node update-cache`, search, install,
  RECORD the name here) + VHS. Input = author's mp4 → swap with user's video.
  Needs RTX card (both our machines qualify).

## Node packs (installed into tmp/ComfyUI/custom_nodes via `comfy node install`)

Current known set (keep updated as workflows demand):

| Pack | Why | Used by |
|---|---|---|
| rgthree-comfy | Fast Groups Bypasser (t2v/i2v switches), reroutes | LTX civitai workflow |
| ComfyUI-Easy-Use | `cleanGpuUsed` free-VRAM nodes (dirty VRAM between renders) | LTX civitai workflow (26 nodes), H3 8GB recipes |
| ComfyUI-GGUF | LoaderGGUF for quantized DiTs | LTX civitai workflow (Q3_K_M) |
| ComfyUI-JWNode (JWStringMultiline) | multiline string primitive | LTX civitai workflow |

Install: `tmp\agent-tools\Scripts\comfy.exe node install <pack-name-or-url>` →
restart backend (Swarm: Restart All Backends; direct comfy: Ctrl+C + relaunch).
Missing-node discovery: `comfy node update-cache` then search the registry; install
by exact name, record here + commit.

## Batching example (HU narration pattern)

> Ebben a körben három dolgot állítok át egyszerre, hogy ne várj háromszor 20 percet:
> 1. A promptból kikerül a "cartoon" szó — az húzta a képet cartoon irányba (widget
>    edit, a CLIPTextEncode szövege).
> 2. Lépésszám 8 → 12: élesebb mozgás, kb. 1,5x hosszabb render.
> 3. Seed fix (randomize → fixed), hogy a három változás hatását ugyanarról a
>    kiindulásról lássuk.
> Együtt kb. 6-8 perc. Indítom.

## Cost estimation

Time ≈ base × (pixels/0.2MP) × (frames/base_frames) × (steps/base_steps), two-stage
≈ 2x. State the estimate BEFORE queueing; if the real time exceeds it by >2x,
investigate (enhancer on, wrong model tier, VRAM spillover) instead of shrugging.
