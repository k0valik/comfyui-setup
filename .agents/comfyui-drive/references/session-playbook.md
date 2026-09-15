# Session Playbook (returning sessions / MCP-driven use)

Read on any "returning session" branch — human already has the pipeline; they want
RESULTS now (generate, modify a workflow, improve a prompt). All human-facing text
Hungarian (see `../comfyui-setup/references/hungarian-communication.md`); the playbook here is agent-side.

## Cold start (next day, machine rebooted, nothing running)

Order matters; each step has a check:

1. Repo state quick check: `scripts\Verify-Setup.ps1` — setup sections should all
   PASS. If a setup FAIL appears, fall back to SKILL.md fresh-setup stages.
2. Start SwarmUI (human double-clicks `scripts\Start-Swarm.bat`, or agent runs
   `powershell -ExecutionPolicy Bypass -File scripts\Start-Swarm.ps1` detached).
   Backend comfy (:7821) auto-starts; first load pulls models from disk (~1–2 min).
3. MCP comfy session: either the Swarm backend OR a direct comfy via
   `launch_comfyui` (uses tmp/ComfyUI/venv, port 8188). Both share the same install,
   models, venv. Run only ONE direct comfy (port conflict otherwise).
4. Health: MCP `server_info()` → workspace = `tmp/ComfyUI`, comfy reachable.
   Then `search_models` or Verify-Setup models row — 12 safetensors visible.
- Completion: server_info ok + one of the servers answering HTTP.

## Workflow patterns (comfy-mcp tools)

Discover → fetch → adapt → validate → run → wait → fetch. Never hand-build a graph
from scratch when a template exists; never guess node names (introspect the LIVE
install — custom nodes included):

1. **Run a template as-is**: `search_templates` (tag-filter for the model family,
   e.g. minimax/ltx) → `fetch_template` writes runnable JSON → `run_workflow(path)`.
2. **Modify an existing workflow** (human: " változtasd meg úgy, hogy..."):
   load the workflow JSON (repo `workflows/` or fetched template) → edit node params
   (resolution, frames, steps, loras, prompts) → `validate_workflow` BEFORE running
   (pre-flight against live object_info; catches stale node names, wrong types) →
   `run_workflow` → `job_status`/`wait_for_job` → `fetch_outputs(prompt_id, out_dir)`.
   Keep edits surgical: change widgets/values, preserve links; rename nothing.
3. **Prompt improvement loop** (human: "írd át szebbre és generálj"):
   rewrite the human's HU prompt into a richer EN generation prompt (video models are
   EN-trained; keep the human's intent, add shot/camera/lighting/audio direction when
   the template expects it — H3 templates carry audio direction in the same prompt
   block). Show the human the new prompt in the chat (HU framing + EN prompt), then
   generate. Iterate on their feedback — regenerate with edits, not new workflows.
4. **Looped/seamless video**: native loop is model-dependent. Prefer template-native
   features (H3/LTX shot sequencing, LTX multishot) before hacks; if the human wants
   a perfect loop, generate + check last↔first frame continuity, and be honest (HU)
   that true seamless looping may need post (crossfade) or IC-LoRAs. Do not invent
   node graphs for looping without first checking `search_nodes` for existing helpers.
5. **SwarmUI UI-side edits**: if the human edits in Swarm's Comfy Workflow Editor,
   the saved workflow JSON lands in Swarm's Data — ask them to save/export, then load
   that JSON into the MCP flow the same way.

## Where outputs land

- direct comfy (8188 / launch_comfyui): `tmp/ComfyUI/output/`
- Swarm backend (7821): Swarm's output dir under `tmp/SwarmUI/Data` (+ per-user paths)
- MCP: `fetch_outputs(prompt_id, out_dir)` — copy into a fresh, human-named folder
  (HU name it for them, e.g. `kimenet/2026-09-13-hajnalban`), then TELL the human the
  full Windows path in chat.

## Session rules

- Long jobs: `run_workflow(wait=False)` + `wait_for_job`; keep the human informed (HU)
  with expected duration; video gens are minutes, not seconds.
- OOM/red errors: read backend log (Swarm backend card → View Logs) or comfy console;
  known levers: lower resolution/steps, turbo LoRA variants, `--lowvram` direct comfy,
  close overlays. See windows-environment.md troubleshooting table first.
- Setup-vs-use boundary: if a request requires NEW nodes/models (e.g. " install a
  checkpoint they saw online"), that is a SETUP action — follow runbook_2/skill
  discipline (official repos, selective download, update manifests), never ad-hoc
  pip/hf one-offs from the session.
- End of session: report (HU) what was made + where it is; leave servers running or
  stop per human's wish (Ctrl+C / Task Manager; closing the Swarm window kills its
  backend child too).
