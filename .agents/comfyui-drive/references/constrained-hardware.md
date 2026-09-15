# Constrained Hardware (tuning ladder)

Human profile: 8-12GB VRAM (friend), author profile: 16GB (RTX 5070 Ti). Check which
machine via `scripts\Verify-Setup.ps1` (nvidia-smi) BEFORE quoting times or choosing
defaults. Sources: `sources/ltx25-low-vram-guide.md` (LTX official),
`sources/h3-on-8gb-rtx4060-reddit.md` (measured 8GB H3 data).

## Lever ladder (try in order; one class per render; narrate the trade in HU)

1. **Model tier**: distilled > dev; quantized DiT (GGUF Q3_K_M 12.9GB / Q4_K_S 15.3GB
   for LTX) > bf16 monolith. Our default LTX install IS int8 distilled; the civitai
   workflow wants the GGUF Q3_K_M instead (needs ComfyUI-GGUF pack).
2. **Resolution x frames**: scale incrementally from the floor, never jump to a
   "broadcast" label. Valid grids:
   - LTX: width/height divisible by 32 (one-stage) or 64 (two-stage) — 512, 576, 640,
     704, 768...; frames satisfy `(F-1) % 8 == 0` → 97, 121, ...
   - H3: 17-frame-per-block grid (17k+5) at 24fps; native canvas 768 short edge,
     max 768x1344, multiples of 32; floor 608x352 (0.2MP).
3. **Launch flags** (direct comfy; for Swarm backend put them in backend ExtraArgs):
   `--lowvram --disable-pinned-memory --use-ck-attention` (proven combo on 8GB 4060
   for H3). Optional env: `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`.
   Swarm default lacks these — add when OOM appears.
4. **Memory hygiene**: keep `cleanGpuUsed`/free-memory nodes after generation stages
   (VRAM stays dirty between renders on small cards — the reddit poster measured the
   slowdown themselves). Never remove them to "tidy" a graph.
5. **Text encoder swap** (H3 experiment track, NOT default): the 32B nvfp4 TE (15.7GB)
   can be replaced by community 4B/8B convrot quants (~int4 ≈ few GB). Works, big
   speedup, slightly weaker prompt understanding. Only on explicit request; setup
   discipline applies (official-ish repos, record in manifest).
6. **Duration**: trade pixels for seconds (0.4MP at 3s ≈ 0.2MP at 5s in time).
   LTX on 32GB: 12s practical ceiling, 20s = hard OOM. Shorter clips are the economy.

## Measured calibration (from sources; extend with own measurements)

- H3 i2v, RTX 4060 8GB laptop, 16GB RAM, Kijai experimental weights + 4B int8 TE,
  20-step Euler Simple, `--lowvram --disable-pinned-memory --use-ck-attention`:
  608x352 (0.2MP) 5s ≈ 1:35. Higher res via shorter duration: 0.3MP 3s, 0.4MP 2s
  ≈ ~3 min.
- LTX-2.5 distilled int8, RTX 5090: 1280x704 5s+audio ≈ 40-60s; 12s ≈ 5:40; 20s OOM.
- Duration scales worse than linearly — the last seconds are the expensive ones.

## Experiment tracks (never mix into default manifests)

- **H3 via Kijai experimental weights + 4B/8B TE**: the 8GB proof setup. Different
  files than our Comfy-Org pack; only adopt deliberately (setup discipline, separate
  workflow JSONs, record which workflow needs which files).
- **LTX GGUF DiT (Q3_K_M/Q4_K_S)**: friend-profile default candidate; requires
  ComfyUI-GGUF pack; file lives in `models/diffusion_models/` like any DiT.
- **Junction trick for parallel installs**: testing a new model version is done in a
  sandbox comfy on another port with model folders shared via NTFS junction — never
  upgrade the working install to evaluate something.
