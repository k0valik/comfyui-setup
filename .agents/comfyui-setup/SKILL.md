---
name: comfyui-setup
description: Drive a non-technical Hungarian-speaking Windows user through the full local AI video/image pipeline setup (ComfyUI + SwarmUI + 86GB of MiniMax-H3/LTX-2.5 models + workflow templates) using this repo's committed PowerShell scripts. Trigger on the magic phrase "telepíts fel nekem mindent légyszíves" or any "install/set up comfyui/swarmui for me" request from the repo. Do not use for: WSL/Linux-side development, post-setup generation tuning (runbook_2.md), or HF Hub data operations (hf-cli skill).
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

Single mode: fresh end-to-end setup. Partial state? `scripts/Verify-Setup.ps1` tells
you exactly which stage is done — resume at the first FAIL, never redo PASSed stages
(downloads resume in place; installs skip if present).

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

### Stage 3 — HuggingFace gate + model download (~86 GB)
Gate: human does 3 browser things (HU wording in reference):
1. create/enter HF account;
2. open `https://huggingface.co/Lightricks/LTX-2.5` → click **Agree and Access**;
3. create Read token at `https://huggingface.co/settings/tokens`, paste it to agent.
Verify token: `Invoke-WebRequest -Headers @{Authorization="Bearer <tok>"} https://huggingface.co/api/models/Lightricks/LTX-2.5` → 200.
Run: `$env:HF_TOKEN="<tok>"; powershell -ExecutionPolicy Bypass -File scripts\Download-Models.ps1` (15–60 min).
- Interrupted → re-run same command (resumes). Expired/401 → token issue, re-gate.
- Completion: script lists ~86 GB across `models/`; 12 safetensors present
  (`scripts\Verify-Setup.ps1` models section all PASS).

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
- `scripts\Verify-Setup.ps1` → `RESULT: all critical checks PASS`.
- Report end state to human in Hungarian (reference: final handover text):
  how to start (`Start-Swarm.ps1` / `Start.bat`), stop (Ctrl+C), where outputs land.
- Capture durably: if torch/python/ComfyUI versions differ from runbook's
  "Reference machine" block, update `runbook.md` + commit + push.

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
- `scripts/Start-Swarm.ps1` / `Start.ps1` / `Start.bat` — launchers.
- `scripts/Verify-Setup.ps1` — full PASS/FAIL status report; resume pointer.

## References

- `references/windows-environment.md` — READ BEFORE STAGE 1: PowerShell-only rules,
  repo layout, port map, FDS format notes, model manifest, troubleshooting table.
- `references/hungarian-communication.md` — READ BEFORE ANY USER MESSAGE: language
  rules + exact Hungarian wording for every gate, progress state, and the final
  handover.
