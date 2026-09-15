This folder and repository is about setting up a personal video and picture generation pipeline with ComfyUI.

The environment will operate on Windows - ComfyUI will run under Windows, and the development itself is only done on WSL2 for the time being.
Installation of software and requirements should be done on Windows.

The repository contains a runbook.md which shall be a living document about setting up from start to finish the full ComfyUI pipeline, with an example workflow run as we progress. Update it automatically.

Use powershell where required.

Operator reality (2026-09-12, supersedes dev-only assumptions for the END USER):
- The end user (friend) runs Windows ONLY: PowerShell / Windows Terminal, no WSL, no dev tools. WSL2 remains available to US (repo authors) for development/setup assistance only — never assume it exists on the friend's machine, never run friend-facing steps from WSL.
- The friend is non-technical and does NOT know English (partial at best). ALL friend-facing text (README, runbook instructions meant for them, agent messages) must be Hungarian. Technical references, commands, file names, UI labels stay English.
- The friend cannot operate a shell: everything scriptable must be a committed script in scripts/ they can run with one copy-paste line or double-click. Anything not scriptable (browser accounts, license clicks, web wizards) is an explicit human gate the agent must hand over in Hungarian.
- The friend installs an agent TUI (Codex or Google Antigravity) and drives setup conversationally. Entry ritual: clone this repo, install their agent, start it in the repo, and say: "telepíts fel nekem mindent légyszíves". The agent then executes the whole setup via the project skill at .agents/comfyui-setup/ (Windows PowerShell driver, stages, gates, verification). Update that skill whenever scripts or flows change.
- Reproducible end state: verified scripts run top-to-bottom on a fresh Windows machine; skill ends when the template workflows in workflows/ run a first successful generation.

Reproducibility contract (must always hold):
- This is a reproducible example repo. Someone cloning it on Windows with similar specs (RTX 20-series+, incl. lower VRAM 8-12GB) must be able to follow runbook.md top-to-bottom on a fresh machine.
- Audience is non-technical: prefer half-automation via committed scripts/ (Install.ps1, Start.ps1/.bat) + copy-paste PowerShell blocks. No admin rights, no Visual Studio / build essentials may be assumed — everything must install from prebuilt wheels.
- Runtime split: ComfyUI runs on Windows (venv at tmp/ComfyUI/venv, torch cu130 default for 20-series+/Blackwell). WSL2 is dev-only — never pip-install or run ComfyUI from WSL.
- tmp/ is LOCAL-ONLY (git-ignored): ComfyUI clone + venv + models live there and are never committed. scripts/, runbook.md, AGENTS.md are the committed contract.
- runbook.md §"Reference machine" versions (Python, torch, ComfyUI commit) must be refreshed whenever the setup is re-verified.