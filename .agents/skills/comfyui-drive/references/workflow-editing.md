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
