This folder and repository is about setting up a personal video and picture generation pipeline with ComfyUI.

The environment will operate on Windows - ComfyUI will run under Windows, and the development itself is only done on WSL2 for the time being.
Installation of software and requirements should be done on Windows.

The repository contains a runbook.md which shall be a living document about setting up from start to finish the full ComfyUI pipeline, with an example workflow run as we progress. Update it automatically.

Use powershell where required.

Operator reality (2026-09-12, supersedes dev-only assumptions for the END USER):
- The end user (friend) runs Windows ONLY: PowerShell / Windows Terminal, no WSL, no dev tools. WSL2 remains available to US (repo authors) for development/setup assistance only — never assume it exists on the friend's machine, never run friend-facing steps from WSL.
- The friend is non-technical and does NOT know English (partial at best). ALL friend-facing text (README, runbook instructions meant for them, agent messages) must be Hungarian. Technical references, commands, file names, UI labels stay English.
- The friend cannot operate a shell: everything scriptable must be a committed script in scripts/ they can run with one copy-paste line or double-click. Anything not scriptable (browser accounts, license clicks, web wizards) is an explicit human gate the agent must hand over in Hungarian.
- The friend installs agent TUIs (Codex AND Google Antigravity - BOTH, so they can
  switch when one runs out of quota/errors) and drives setup conversationally. Entry ritual: clone this repo, install their agent, start it in the repo, and say: "telepíts fel nekem mindent légyszíves". The agent then executes the whole setup via the project skill at .agents/comfyui-setup/ (Windows PowerShell driver, stages, gates, verification). Update that skill whenever scripts or flows change. If the friend reports quota exhaustion or tool errors in one client, tell them (in Hungarian) to continue the SAME step in the other client, same folder.
- Two-skill split (2026-09-16): .agents/comfyui-setup/ owns installing/repairing the environment (stages, gates, Verify-Setup). .agents/comfyui-drive/ owns generation sessions: workflow editing, prompt craft, constrained-hardware tuning, MCP-driven runs — with Hungarian narration and cost grounding for the learning user. Returning sessions go straight to the drive skill; setup skill hands off at the setup boundary. Do not let one skill do the other's job (no accidental re-setup during drive sessions, no generation doctrine inside setup).
- Reproducible end state: verified scripts run top-to-bottom on a fresh Windows machine; setup skill ends when the template workflows in workflows/ run a first successful generation; drive skill covers everything after.

Agent tooling layer (stage 7 of the skill, committed 2026-09-12):
- Agent installs comfy-cli (>=1.14) + comfy-mcp into a dedicated venv `tmp/agent-tools/` (scripts/Install-AgentTools.ps1) — NEVER inside tmp/ComfyUI/venv (that venv is comfy's runtime) and NEVER via `comfy install` (would clone a second comfy; `comfy set-default tmp/ComfyUI` points the CLI at the existing checkout).
- Agent registers the comfy-mcp stdio server with its own client (codex: `codex mcp add comfy-mcp --env COMFY_BIN=<path> -- <path to comfy-mcp.exe>` or ~/.codex/config.toml; gemini/antigravity: mcpServers in settings). Absolute paths only — MCP clients launch servers with their own env, no PATH.
- `comfy skills install` (bundled in comfy-cli) writes the comfy skills for the client/AGENTS.md. The Comfy-Org/comfy-skills repo's skills/ folder is the deprecated legacy set — do not install from it; its claude-code plugin (comfy-cloud MCP) is the PAID cloud connection, separate from our local setup.
- Source of truth for the MCP layer: .agents/comfyui-setup/references/comfy-mcp-docs.md (committed copy of docs.comfy.org/agent-tools/mcp). Returning-session usage patterns: references/session-playbook.md.

Reproducibility contract (must always hold):
- This is a reproducible example repo. Someone cloning it on Windows with similar specs (RTX 20-series+, incl. lower VRAM 8-12GB) must be able to follow runbook.md top-to-bottom on a fresh machine.
- Audience is non-technical: prefer half-automation via committed scripts/ (Install.ps1, Start.ps1/.bat) + copy-paste PowerShell blocks. No admin rights, no Visual Studio / build essentials may be assumed — everything must install from prebuilt wheels.
- Runtime split: ComfyUI runs on Windows (venv at tmp/ComfyUI/venv, torch cu130 default for 20-series+/Blackwell). WSL2 is dev-only — never pip-install or run ComfyUI from WSL.
- tmp/ is LOCAL-ONLY (git-ignored): ComfyUI clone + venv + models live there and are never committed. scripts/, runbook.md, AGENTS.md are the committed contract.
- runbook.md §"Reference machine" versions (Python, torch, ComfyUI commit) must be refreshed whenever the setup is re-verified.