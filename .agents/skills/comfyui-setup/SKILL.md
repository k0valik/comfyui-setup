---
name: comfyui-setup
description: Drive a non-technical Hungarian-speaking Windows user through the full local AI video/image pipeline setup (ComfyUI + SwarmUI + 86GB of MiniMax-H3/LTX-2.5 models + workflow templates) using this repo's committed PowerShell scripts. Trigger on the magic phrase "telepíts fel nekem mindent légyszíves" or any "install/set up comfyui/swarmui for me" request from the repo.
---

# ComfyUI Setup Driver (Windows, Hungarian end-user)

## Philosophy

One phrase in, working pipeline out. The human only does what only a human can:
browser accounts, license clicks, wizard clicks, waiting. Everything scriptable is a
committed script — run it, never hand-roll its steps. User-facing text is Hungarian;
commands, file names, error text stay English. Predictability over cleverness: the
repo layout (`tmp/ComfyUI`, `tmp/SwarmUI`, `models/`, `workflows/`) is the contract —
recreate it exactly, mirror this repo's verified setup, never adapt it to "what's
already on the machine".

## Vocabulary

- **repo root** — folder containing `runbook.md`, `AGENTS.md`, `scripts/`.
- **direct comfy** — manually-run ComfyUI on port 8188 (`scripts/Start.ps1`).
- **backend** — SwarmUI's ComfyUI Self-Starting child on port 7821 (our venv).
- **graft** — `tmp/SwarmUI/Data/Backends.fds` pointing the backend at
  `tmp/ComfyUI/main.py`; makes Swarm reuse our venv + models + Manager.
- **gate** — a step only the human can complete; agent waits, then verifies.

## Branch

Two modes — decide first, wrong mode wastes the session:
- **Fresh setup** (no `tmp/ComfyUI/venv` or Verify-Setup has setup FAILs): run all
  stages 1→7 in order. Resume at first FAIL.
- **Returning session** (setup was done on a previous day; human wants to USE the
  pipeline: generate, modify workflows, rewrite prompts): hand off to the
  `comfyui-drive` skill (`.agents/comfyui-drive/SKILL.md`) — it owns cold-start,
  generation, workflow editing, tuning. This skill stops at the setup boundary.

Partial state mid-fresh-setup? `scripts/Verify-Setup.ps1` tells you exactly which
stage is done — resume at the first FAIL, never redo PASSed stages (downloads resume
in place; installs skip if present).

## Execution workflow

Read `references/windows-environment.md` before stage 1 (PowerShell rules, port map,
troubleshooting). Read `references/hungarian-communication.md` before ANY user message
(all human-facing text in Hungarian, exact gate wording lives there).

### Stage 1 — Preflight
Run: `powershell -ExecutionPolicy Bypass -File scripts\Preflight.ps1`
- exit 0 → proceed. exit 2 → tell human (HU) to reopen PowerShell, re-run script;
  loop until 0. exit 1 → follow the printed manual URL; gate: driver install + reboot
  is the only human-only part here.
- Completion: exit 0.

### Stage 2 — Base install (comfy + venv + torch + Manager)
Run: `powershell -ExecutionPolicy Bypass -File scripts\Install.ps1` (10–20 min).
- Completion: output ends with CUDA verify `True` + GPU name, no red errors.
- Skips cleanly if already installed — safe to re-run.

### Stage 3 — HuggingFace gate + model download (profile-aware)
Gate: human does 3 browser things (HU wording in reference):
1. create/enter HF account;
2. open `https://huggingface.co/Lightricks/LTX-2.5` → click **Agree and Access**;
3. create Read token at `https://huggingface.co/settings/tokens`, paste it to agent.
Verify token: `Invoke-WebRequest -Headers @{Authorization="Bearer <tok>"} https://huggingface.co/api/models/Lightricks/LTX-2.5` → 200.
Run: `$env:HF_TOKEN="<tok>"; powershell -ExecutionPolicy Bypass -File scripts\Download-Models.ps1`
- **Profile default = `friend`** (~23GB: LTX GGUF Q3_K_M DiT + w4a8 encoder + VAEs +
  upscaler + duration head; matches the curated civitai workflow). `-Profile full`
  = the verified 16GB reference manifest (~86GB incl. H3) for machines with VRAM
  headroom. `-WithW4A8DiT` adds the native w4a8 DiT (no GGUF pack needed).
  Catalog of everything else: `MODELS.md` (repo root).
- friend profile: also run `scripts\Install-NodePacks.ps1` (GGUF/rgthree/Easy-Use).
- Interrupted → re-run same command (resumes). Expired/401 → token issue, re-gate.
- Completion: script lists the profile's files; Verify-Setup models section PASSes
  (profile-aware).

### Stage 4 — SwarmUI install + graft + first launch
1. `powershell -ExecutionPolicy Bypass -File scripts\Install-Swarm.ps1`
   (clones `tmp/SwarmUI`, builds, ~1 min; needs .NET SDK — preflight covered it).
2. BEFORE first launch: `powershell -ExecutionPolicy Bypass -File scripts\Set-SwarmGraft.ps1`
   — pre-bakes the graft so the human never configures backends manually.
3. `powershell -ExecutionPolicy Bypass -File scripts\Start-Swarm.ps1`
4. Gate: human clicks through first-run wizard: theme → 'just yourself' →
   backend: **None / Custom / Choose Later** (never 'ComfyUI (Local)' — it downloads
   a duplicate 20 GB comfy). Graft already did the rest.
5. First backend boot takes 2–4 min; log shows staged pip installs into OUR venv
   (`Installing 'rembg' exited properly` ... then `port 7821 started`) — normal,
   one-time; reassure the human in HU if they paste scary logs.
- Completion: `scripts\Verify-Setup.ps1` → SwarmUI :7801 PASS + backend :7821 PASS.

### Stage 5 — Workflows
Committed templates live in repo `workflows/` (H3 t2v/i2v/r2v, LTX-2.5 t2v/i2v from
`Comfy-Org/workflow_templates`). If missing/stale, re-download from
`https://raw.githubusercontent.com/Comfy-Org/workflow_templates/main/templates/<name>`
and commit. Validate each parses as JSON and its referenced model filenames exist in
`models/` (grep `*.safetensors` mentions in the JSON's MarkdownNote/widgets).
Gate: human loads one in SwarmUI (`Comfy Workflow Editor` tab → open JSON →
`Use This Workflow`) or direct comfy UI (Workflow Browser), presses Generate once.
- Completion: one successful generation through the backend (image appears / file
  lands in `tmp/SwarmUI/Data` output or `tmp/ComfyUI/output`), no red backend errors.

### Stage 6 — Done
- `scripts/Verify-Setup.ps1` → `RESULT: all critical checks PASS`.
- Report end state to human in Hungarian (reference: final handover text):
  how to start (`Start-Swarm.ps1` / `Start.bat`), stop (Ctrl+C), where outputs land.
- Capture durably: if torch/python/ComfyUI versions differ from runbook's
  "Reference machine" block, update `runbook.md` + commit + push.

### Stage 7 — Agent tooling (self-provisioning; enables stages 8+)
The agent installs ITS OWN tools so future sessions can drive comfy programmatically:
1. `powershell -ExecutionPolicy Bypass -File scripts\Install-AgentTools.ps1`
   — creates `tmp/agent-tools` venv (comfy-cli >= 1.14 + comfy-mcp), sets comfy-cli
   workspace to `tmp/ComfyUI` (existing checkout — NEVER `comfy install` a second
   comfy). Completion: prints `COMFY_BIN` and `MCP cmd` paths, both files exist.
2. Install bundled comfy skills into the client: run
   `tmp\agent-tools\Scripts\comfy.exe skills install` (writes skills for Claude Code,
   Cursor, and AGENTS.md-aware tools). Completion: skill files appear / command exits 0.
3. Register the MCP server with the running client (stdio, absolute paths — MCP
   clients launch servers with their own env, so no PATH dependence):
   - Codex: `codex mcp add comfy-mcp --env COMFY_BIN=<COMFY_BIN> -- <MCP cmd>`
     (verify syntax: `codex mcp add --help`; or edit `~/.codex/config.toml`:
     `[mcp_servers.comfy-mcp]` with `command` + `env`).
   - Gemini/Antigravity: check `--help` for its `mcp add` (gemini-compatible:
     settings.json `mcpServers` with `command` + `env`).
   - Any other client: same contract — command = comfy-mcp.exe, env COMFY_BIN = comfy.exe.
   Official reference (committed copy): `references/comfy-mcp-docs.md`.
4. Restart the agent client / start a new session — MCP servers load at session start.
- Completion: client lists a `comfy-mcp` server; calling `server_info()` returns the
  local workspace (after a comfy is running — see playbook).

### Stage 8 — Prove the loop (one MCP-driven generation)
Start comfy via MCP (`launch_comfyui` tool or `comfy launch` in tmp/ComfyUI; uses our
venv, port 8188), then: `search_templates` → `fetch_template` (H3 t2v) →
`validate_workflow` → `run_workflow` → `fetch_outputs`. One video = the plumbing works.
- Completion: output file fetched. Then hand the human the playbook promise:
  next day they just start the agent and ask in Hungarian for generations/edits.
  All further driving (edits, prompts, tuning) belongs to the `comfyui-drive` skill —
  do not duplicate its doctrine here.

## Ask-the-user gates (only these; never delegate them)

| Gate | Why human-only | Verification after |
|---|---|---|
| NVIDIA driver install | reboot + license click | preflight exit 0 |
| HF account + Agree and Access + token | browser login, license consent | API 200 with token |
| Swarm first-run wizard | GUI click-through Swarm requires | :7801/:7821 up |
| First generation | visual confirmation output is sane | output file exists |

## When stuck

Map symptom → fix via `references/windows-environment.md` troubleshooting table.
If a script exits red and no table row matches: capture last ~30 lines, state (HU)
what failed + what was tried, propose 2 concrete options, stop. Never improvise a
new install path (no conda, no scoop, no choco, no manual pip outside the venv).
Partial HF download → just re-run; partial build → delete
`tmp/SwarmUI/src/bin/live_release` and re-run Install-Swarm.

## Anti-patterns

- Do NOT run anything from WSL/bash — the end user has no WSL; agent must stay in
  Windows PowerShell (`powershell.exe`), all glue scripts are `.ps1`.
- Do NOT choose 'ComfyUI (Local)' in the Swarm wizard or point StartScript anywhere
  but `<repo>/tmp/ComfyUI/main.py` — duplicates installs, breaks the graft.
- Do NOT pip-install into the venv by hand; staged Swarm installs + `requirements.txt`
  own that venv. Ad-hoc installs drift it from the reproducible state.
- Do NOT re-download a model that exists on disk; downloads are selective+resumable.
- Do NOT write user-facing text in English (partial English OK for tech terms only).
- Do NOT commit `tmp/`, `models/`, `workflows/*.safetensors`, HF tokens. Token goes
  in `$env:HF_TOKEN` per-session, never in a file that gets committed.
- Do NOT redo stages that Verify-Setup shows PASS — resume at first FAIL.

## Done

Verify-Setup all PASS + first generation succeeded + Hungarian handover delivered +
runbook versions refreshed if changed. End state: friend runs one script to start,
types prompts in the UI, workflows load from `workflows/`.

## Scripts

- `scripts/Preflight.ps1` — checks git/python/dotnet/nvidia; winget-installs missing
  (exit 0 ok | 2 reopen-shell-and-rerun | 1 manual step needed).
- `scripts/Install.ps1` — base install (already committed; assumes preflight OK).
- `scripts/Download-Models.ps1` — selective 86 GB model pull + extra_model_paths.yaml
  (needs `$env:HF_TOKEN` for LTX).
- `scripts/Install-Swarm.ps1` — clone + build SwarmUI.
- `scripts/Set-SwarmGraft.ps1` — pre-bakes Backends.fds graft (run before first launch).
- `scripts/Install-AgentTools.ps1` — tools venv: comfy-cli + comfy-mcp, workspace =
  tmp/ComfyUI; prints COMFY_BIN + MCP cmd for MCP registration.
- `scripts/Start-Swarm.ps1` / `Start.ps1` / `Start.bat` — launchers.
- `scripts/Verify-Setup.ps1` — full PASS/FAIL status report; resume pointer.

## References

- `references/windows-environment.md` — READ BEFORE STAGE 1: PowerShell-only rules,
  repo layout, port map, FDS format notes, model manifest, troubleshooting table.
- `references/hungarian-communication.md` — READ BEFORE ANY USER MESSAGE: language
  rules + exact Hungarian wording for every gate, progress state, and the final
  handover.
- `references/comfy-mcp-docs.md` — committed copy of the official Comfy MCP doc
  (docs.comfy.org/agent-tools/mcp): tool list, client configs, FAQ, troubleshooting.
- Generation-driving doctrine lives in the sibling skill: `.agents/comfyui-drive/`.
