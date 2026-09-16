---
name: comfyui-drive
description: Drive an EXISTING ComfyUI+SwarmUI install (this repo's layout, wired via comfy-mcp) for actual generation work - modify workflows, rewrite prompts, run templates, tune for constrained VRAM, narrate every change in Hungarian for the learning user. Use when the setup is already done (tmp/ComfyUI + models exist) and the user asks to generate/edit/improve/tune ("generálj", "módosítsd a workflowt", "írd át a promptot", "lassú", "OOM"). Do not use for installing or repairing the environment (comfyui-setup skill), HF Hub data ops (hf-cli skill), or WSL-side dev.
---

# ComfyUI Drive (generation sessions)

## Philosophy

Results now, teaching always. The user learns node graphs from watching the agent
edit them — every change is narrated in Hungarian (what changed, which knob it maps
to, why, what it costs in generation time). The machine is slow: a video render is
minutes to an hour, so changes are BATCHED per render and each batched change is
explained individually — iterating one edit per 20-minute render teaches nothing.
Edits are grounded, never speculative: validate before queue, estimate cost before
running, verify what was actually submitted.

## Vocabulary

- **parameter surface** — the few widgets a workflow exposes to the human; everything
  else is fixed implementation.
- **widget edit** — changing existing node values (prompt, steps, frames, res, seed).
  Default edit type.
- **graph surgery** — adding/removing/relinking nodes. Allowed, but narrated with
  before/after and only when the request cannot be a widget edit.
- **flight recorder** — ComfyUI embeds the full graph in output files; when results
  contradict assumptions, read the graph out of the output, not from memory.
- **director** — whatever rewrites the human's raw idea into a model-ready prompt:
  the agent itself, or LTX-2.5's built-in enhancer. A dedicated local director LLM is
  RESERVED FOR FUTURE (user decision) — advanced workflows may embed their own.
- **calibration table** — measured generation times used for cost estimates (below).

## Branch

1. **Session start** (always): follow `references/session-playbook.md` — cold start,
   server_info, health. No generation talk before servers answer.
2. Then pick the task type:
   - "make/generate X" → Session playbook template flow, then `prompt-craft.md`.
   - "modify the workflow / change how it looks" → `workflow-editing.md`.
   - "too slow / OOM / doesn't fit" → `constrained-hardware.md` (read it BEFORE
     proposing fixes; the server may need a restart after lever changes).
   - "I saw a video style / want a specific format" → check
     `references/external-skill-catalog.md` (official H3 skill catalog) before
     building anything.

## Execution workflow

1. Read `references/session-playbook.md` → bring servers up → confirm workspace.
2. Load target workflow JSON (repo `workflows/` or Swarm export). Read its notes +
   subgraph structure BEFORE editing. Read `references/workflow-editing.md` first
   time per session.
3. Plan the change set: list every widget edit + every surgery step; translate each
   into Hungarian for the user; state combined time estimate (calibration table).
   Send the plan, then execute (no approval gate needed for widget edits; graph
   surgery needs explicit user OK).
4. Apply edits → `validate_workflow` → fix what validation flags → run → wait →
   `fetch_outputs` into a Hungarian-named dated folder → give the human the Windows
   path.
5. On complaint (slow/OOM/ugly): `references/constrained-hardware.md` levers, one
   lever class per render, narrated.

## Hard rules

- ALL user-facing text Hungarian (`../comfyui-setup/references/hungarian-communication.md`).
- `validate_workflow` before EVERY queue — stale node names/wrong types are caught
  in seconds, not after a 40-minute render.
- NEVER queue a workflow containing `TextGenerateLTX2Prompt` (or any LLM prompt
  rewriter) without surfacing it: it silently rewrites prompts inside a subgraph and
  poisons fidelity (see sources). Our civitai-derived `workflows/LTX2.5-downloaded-workflow.json`
  has it OFF by design — keep it that way. When the agent is the director, double
  rewriting is waste: agent rewrites → rewriter rewrites → both wrong.
- NEVER add models/nodes ad hoc. New model file = setup discipline (official repos,
  selective download, manifest update, `../comfyui-setup/SKILL.md` rules). New node
  pack = `comfy node install` + record in node-packs note.
- Never claim a render time without the calibration table + hardware check
  (nvidia-smi via Verify-Setup). Friend profile (8GB) and author profile (16GB) have
  different default presets — check which machine you are on.
- Batch edits, don't drip: group all changes for the next render, narrate each.
- Outputs: one dated HU-named folder per batch; report the full Windows path.

## Calibration table (edit with measured data)

| Machine | Workflow | Settings | Time |
|---|---|---|---|
| RTX 4060 8GB / 16GB RAM | H3 i2v (Kijai + 4B TE) | 608x352, 5s, 20 steps | ~1:35 |
| RTX 4060 8GB | H3 i2v | 0.4MP, 3s / 2s | ~3:00 |
| RTX 5090 32GB | LTX-2.5 distilled int8 | 1280x704, 5s + audio | ~40-60s |
| RTX 5090 32GB | LTX-2.5 | 12s | ~5:40; 20s = OOM |

Estimation heuristics: time scales ~linearly with pixels × frames; two-stage LTX
(draft+refine) ≈ 2× single pass at same settings; enhancer ON adds 60–100s/render.

## When stuck

- Missing node error → registry search (`comfy node update-cache` then
  `comfy node install <name-or-url>`), install, note it in the node-packs list
  (see `references/workflow-editing.md` §node-packs), restart backend.
- Workflow needs a model file we don't have → setup discipline (never improvise);
  tell the user (HU) what + how big + where it will live.
- Two renders from different prompts look identical → flight-recorder check
  (workflow-editing.md §verification) before touching prompts.
- OOM → constrained-hardware.md ladder; never resolve by silently dropping quality
  (narrate the trade).

## Anti-patterns

- Do NOT edit JSON blind: read nodes + subgraph definitions first; subgraph internals
  are where the behavior lives (the LTX rewriter was invisible on the main canvas).
- Do NOT delete/disable memory-freeing nodes (`cleanGpuUsed`, free-memory) to "clean
  up" a graph — they exist because VRAM stays dirty between renders on small cards.
- Do NOT run prompts through extra rewriters when the agent already wrote the prompt.
- Do NOT iterate one widget per render (resource-constrained machine; batch + narrate).
- Do NOT promise capabilities from memory (looping, multishot limits) — check the
  catalog/prompt-craft refs; H3/LTX differ (H3: 17-frame blocks, LTX: (F-1)%8==0).
- Do NOT keep the user in English or in silence during long renders: narrate progress
  in Hungarian with expected time.

## Done

Output delivered to the named folder + HU summary: what was changed (each edit),
what it cost, what the next lever would be. Session ends with servers running or
stopped per user's wish.

## References (read at the stated trigger)

- `references/session-playbook.md` — ALWAYS at session start: cold start, health,
  template flow, output locations.
- `references/workflow-editing.md` — before first edit each session: edit doctrine,
  verification (flight recorder, submitted-graph check), node-packs list.
- `references/prompt-craft.md` — before writing/rewriting any prompt: LTX style
  guide, H3 prompt structure, enhancer policy, preset vocabulary.
- `references/constrained-hardware.md` — on slow/OOM/fit complaints: VRAM levers,
  valid dimension/frame grids, GGUF track, calibration data.
- `references/external-skill-catalog.md` — before building a new workflow: official
  MiniMax H3 skills (8 style generators + prompt-writing) worth fetching instead.
- `references/sources/` — verbatim clippings the distilled refs are built from.
- `../comfyui-setup/references/comfy-mcp-docs.md` — MCP tool reference.
- `../comfyui-setup/references/hungarian-communication.md` — language rules + phrases.
