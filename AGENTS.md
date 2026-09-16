This folder and repository is about setting up a personal video and picture generation pipeline with ComfyUI.

The environment will operate on Windows - ComfyUI will run under Windows.
Installation of software and requirements should be done on Windows.

The repository contains a runbook.md which shall be a living document about setting up from start to finish the full ComfyUI pipeline, with an example workflow run as we progress. Update it automatically.

Use powershell where required.

Assume, that you are running on "friend's machine", anywhere where you see that reference. Confirm once per session (nvidia-smi should show as 3060 TI - 8GB vram)

- Amikor a felhasználónak írsz, beszélj magyarul és érthetően, szakszavakat használhatsz angolul. 

Operator reality:
- The end user (friend) runs Windows ONLY: PowerShell / Windows Terminal, no WSL, no dev tools - unless installed already.
- The friend is non-technical and does NOT know English (partial at best). ALL friend-facing text (README, runbook instructions meant for them, agent messages) must be Hungarian. Technical references, commands, file names, UI labels stay English.
- The friend cannot operate a shell: everything scriptable must be a committed script in scripts/ they can run with one copy-paste line or double-click. Anything not scriptable (browser accounts, license clicks, web wizards) is an explicit human gate the agent must hand over in Hungarian.
- The friend installs agent TUIs (Codex AND Google Antigravity - BOTH, so they can
  switch when one runs out of quota/errors) and drives setup conversationally. Entry ritual: clone this repo, install their agent, start it in the repo, and say: "telepíts fel nekem mindent légyszíves". The agent then executes the whole setup via the project skill at .agents/skills/comfyui-setup/ (Windows PowerShell driver, stages, gates, verification). Update that skill whenever scripts or flows change. If the friend reports quota exhaustion or tool errors in one client, tell them (in Hungarian) to continue the SAME step in the other client, same folder.
- Two-skill split (2026-09-16): .agents/skills/comfyui-setup/ owns installing/repairing the environment (stages, gates, Verify-Setup). .agents/skills/comfyui-drive/ owns generation sessions: workflow editing, prompt craft, constrained-hardware tuning, MCP-driven runs — with Hungarian narration and cost grounding for the learning user. Returning sessions go straight to the drive skill; setup skill hands off at the setup boundary. Do not let one skill do the other's job (no accidental re-setup during drive sessions, no generation doctrine inside setup).
- Reproducible end state: verified scripts run top-to-bottom on a fresh Windows machine; setup skill ends when the template workflows in workflows/ run a first successful generation; drive skill covers everything after.

Agent tooling layer (stage 7 of the skill):
- Agent installs comfy-cli (>=1.14) + comfy-mcp into a dedicated venv `tmp/agent-tools/` (scripts/Install-AgentTools.ps1) — NEVER inside tmp/ComfyUI/venv (that venv is comfy's runtime) and NEVER via `comfy install` (would clone a second comfy; `comfy set-default tmp/ComfyUI` points the CLI at the existing checkout).
- Agent registers the comfy-mcp stdio server with its own client (codex: `codex mcp add comfy-mcp --env COMFY_BIN=<path> -- <path to comfy-mcp.exe>` or ~/.codex/config.toml; gemini/antigravity: mcpServers in settings). Absolute paths only — MCP clients launch servers with their own env, no PATH.
- `comfy skills install` (bundled in comfy-cli) writes the comfy skills for the client/AGENTS.md. The Comfy-Org/comfy-skills repo's skills/ folder is the deprecated legacy set — do not install from it; its claude-code plugin (comfy-cloud MCP) is the PAID cloud connection, separate from our local setup.
- Source of truth for the MCP layer: .agents/skills/comfyui-setup/references/comfy-mcp-docs.md (committed copy of docs.comfy.org/agent-tools/mcp). Returning-session usage patterns: references/session-playbook.md.

Reproducibility contract (must always hold):
- This is a reproducible example repo. Someone cloning it on Windows with similar specs (RTX 30-series+, incl. lower VRAM 8-12GB) must be able to follow runbook.md top-to-bottom on a fresh machine.
- Audience is non-technical: prefer half-automation via committed scripts/ (Install.ps1, Start.ps1/.bat) + copy-paste PowerShell blocks. No admin rights, no Visual Studio / build essentials may be assumed — everything must install from prebuilt wheels.
- Runtime split: ComfyUI runs on Windows (venv at tmp/ComfyUI/venv, torch cu130 default for 30-series+/Blackwell).
- tmp/ is LOCAL-ONLY (git-ignored): ComfyUI clone + venv + models live there and are never committed. scripts/, runbook.md, AGENTS.md are the committed contract.
- runbook.md §"Reference machine" versions (Python, torch, ComfyUI commit) must be refreshed whenever the setup is re-verified.

- You have a `MEMORIES.md` in the root of the repo. Maintain it, update it. It is your empty template. Rely heavily on the provided skills and the `references` subfolders for skills - they encode good behaviour. You are test driving the skills. If something needs updating, did not work, and you've found a better way to make it work, update it. Update the skill, update the script, update the workflow etc.
- `MEMORIES.md` should be relatively lean routing table, serving as a living document. It is your agent-facing guidance that should evolve to avoid repeating catastrophic failures, failed generations, wrong models used for generations, resource issues, things you could note down. This saves time, effort and tokens for you, headache for the user.
