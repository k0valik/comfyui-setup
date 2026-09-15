# Node Packs + Presets — committed environment extensions

## Install-NodePacks.ps1

Installs curated ComfyUI custom-node packs into `tmp/ComfyUI/custom_nodes` via
comfy-cli (uses the `tmp/agent-tools` venv). Idempotent. Run:
`powershell -ExecutionPolicy Bypass -File scripts\Install-NodePacks.ps1`
Optional: `-Packs "rgthree-comfy,ComfyUI-Easy-Use,ComfyUI-GGUF"` to override the set.
Restart the backend afterwards (Swarm: Restart All Backends).

Curated default set (why: see .agents/comfyui-drive/references/workflow-editing.md):

- `rgthree-comfy` — group bypassers/reroutes (LTX civitai workflow)
- `ComfyUI-Easy-Use` — VRAM hygiene nodes (cleanGpuUsed), proven on 8GB
- `ComfyUI-GGUF` — quantized DiT loaders (LTX Q3_K_M track)

Others are installed on-demand by the agent when a workflow provably needs them
(missing-node error → registry lookup → install → record in the table above → commit).

## Prompt presets

`presets/prompts.md` — the small HU-labeled vocabulary (camera/motion/mood/style →
EN prompt fragments). The drive skill uses it when rewriting prompts; new entries get
committed instead of invented inline.
