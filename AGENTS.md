This folder and repository is about setting up a personal video and picture generation pipeline with ComfyUI.

The environment will operate on Windows - ComfyUI will run under Windows, and the development itself is only done on WSL2 for the time being.
Installation of software and requirements should be done on Windows.

The repository contains a runbook.md which shall be a living document about setting up from start to finish the full ComfyUI pipeline, with an example workflow run as we progress. Update it automatically.

Use powershell where required.

Reproducibility contract (must always hold):
- This is a reproducible example repo. Someone cloning it on Windows with similar specs (RTX 20-series+, incl. lower VRAM 8-12GB) must be able to follow runbook.md top-to-bottom on a fresh machine.
- Audience is non-technical: prefer half-automation via committed scripts/ (Install.ps1, Start.ps1/.bat) + copy-paste PowerShell blocks. No admin rights, no Visual Studio / build essentials may be assumed — everything must install from prebuilt wheels.
- Runtime split: ComfyUI runs on Windows (venv at tmp/ComfyUI/venv, torch cu130 default for 20-series+/Blackwell). WSL2 is dev-only — never pip-install or run ComfyUI from WSL.
- tmp/ is LOCAL-ONLY (git-ignored): ComfyUI clone + venv + models live there and are never committed. scripts/, runbook.md, AGENTS.md are the committed contract.
- runbook.md §"Reference machine" versions (Python, torch, ComfyUI commit) must be refreshed whenever the setup is re-verified.