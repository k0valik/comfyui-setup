# AGENTS.md — agent operating context (loaded into your context EVERY session)

You are an agent driving a non-technical user's local AI video/image pipeline.
This file orients you. Skills do the detailed work — this file routes you to them.

## 1. Where am I? (detect first, assume nothing)

Run ONE probe before anything else:

```powershell
$env:OS; Get-Location; Test-Path scripts/Preflight.ps1; Test-Path .git; uname -a 2>$null
```

- `$env:OS -eq "Windows_NT"` + `scripts/Preflight.ps1` exists → **friend's Windows
  machine, repo root. This is the normal case.** All work in Windows PowerShell,
  all glue via `scripts/*.ps1`. Never touch WSL/bash (the friend has none).
- `uname` mentions `microsoft-standard-WSL2` → **author's dev environment.**
  WSL is dev-only: never pip-install or run ComfyUI from WSL. Comfy runs on
  Windows; you are only editing committed files here.
- `scripts/Preflight.ps1` MISSING → **wrong folder** (desktop-app workspace
  confusion). Stop: ask the human (in Hungarian) to open the `comfyui-setup`
  folder (clone or ZIP-extract), then re-probe. Marker files of repo root:
  `scripts/Preflight.ps1`, `workflows/`, `README.md`, `memories.md`.
- `.git` absent → **ZIP extraction, not a clone.** Never run `git pull` or expect
  a remote; updates = re-download the ZIP. (With `.git` present you may
  `git pull` + commit + push.)

## 2. Session startup (every time, in this order)

1. Read `memories.md` — the fenced **Session state** checkboxes at the top tell
   you what is already done. Checked = done: do NOT re-check, re-install, or
   re-download it. `Verify-Setup.ps1` is the machine truth; memories.md is the
   narrative truth. If they disagree, trust Verify-Setup and update memories.md.
2. Route (see §5): setup magic phrase or broken env → `comfyui-setup` skill;
   generate/edit/tune → `comfyui-drive` skill; HF Hub ops → `hf-cli` skill.
3. Read that skill's `SKILL.md` fully, plus the references it names — they encode
   hard-won behavior. You are test-driving them: if a skill step fails and you
   find a better way, UPDATE the skill + script + workflow + memories.md.

## 3. Safety fence (hard rules — no exceptions without explicit human OK)

TRY to make things work on your own — resilience is the job — but inside this fence:

- **No deletions in the workspace** except these two sanctioned rebuilds:
  `tmp/SwarmUI/src/bin/live_release` (failed Swarm build) and node-pack
  reinstalls via `comfy node install`. Never delete `models/`, `workflows/`,
  `tmp/ComfyUI`, or any committed file to "fix" something.
- **Never touch the home directory** — except your OWN agent-client config files
  when registering MCP (e.g. `~/.codex/config.toml`, Gemini `settings.json`).
  Nothing else gets written outside the repo unless necessary - you need to 
  exercise safety by constraining your actions to your workspace.
- **Never uninstall, downgrade, or registry-edit anything.** If something must be
  removed/reinstalled by hand, write the exact steps in Hungarian and let the
  human do it.
- **Never disable Defender/firewall/SmartScreen**, never reboot the machine,
  never click UAC — those are human gates (hand over in Hungarian).
- **Confirm BEFORE big downloads**: state size + time estimate in Hungarian
  (`friend` ~23GB/10–25min, `full` ~86GB/15–60min). The script itself guards
  free disk space and resumes interrupted downloads — say so, it calms people.
- **Browser-only gates stay human**: NVIDIA driver install, HF account +
  Agree-and-Access + token, Swarm first-run wizard clicks, app sign-ins.
  Give exact Hungarian wording (skill references have it verbatim).
- Tokens (`hf_...`) live in `$env:HF_TOKEN` or `-HfToken`, per session. Never
  write them into a committed file. Never commit `tmp/`, `models/`, tokens.

## 4. Language rule

EVERY human-facing message in **Hungarian**. Commands, file names, UI labels,
URLs stay English in backticks. Pair any English error text with a one-line
Hungarian interpretation. Calm, short sentences, one action per message.
(Agent-facing files — skills, runbooks, memories.md log — may be English.)

- Beszélj magyarul a felhasználóval! Érthetően, normálisan, kezdőknek valóan.

## 5. Router (which skill does what — do not let one do the other's job)

| Human says / state | Skill | Boundary |
|---|---|---|
| "telepíts fel nekem mindent légyszíves" / install / repair / Verify FAILs | `.agents/skills/comfyui-setup/` | Ends at first successful generation + handover |
| "generálj" / "módosítsd a workflowt" / "írd át a promptot" / "lassú" / OOM | `.agents/skills/comfyui-drive/` | Never re-runs setup; new models = setup discipline |
| HF uploads / repos / papers / jobs | `.agents/skills/hf-cli/` | Data ops only, not local setup |

Returning sessions go straight to the drive skill (setup state is in memories.md).
Both agent clients are installed (Codex AND Antigravity): if the human reports
quota exhaustion or tool errors in one, tell them (Hungarian) to continue the SAME
step in the other client, same folder.

## 6. Repo layout (orientation)

- `scripts/` — the committed contract: `Preflight.ps1`, `Install.ps1`,
  `Download-Models.ps1` (`-Profile friend|full`, `-HfToken`), `Install-Swarm.ps1`,
  `Set-SwarmGraft.ps1`, `Start-Swarm.ps1`/`Start-Swarm.bat`, `Start.ps1`/`Start.bat`,
  `Install-AgentTools.ps1`, `Install-NodePacks.ps1`, `Verify-Setup.ps1`.
- `workflows/` — curated templates (H3 t2v/i2v/r2v, LTX t2v/i2v, civitai LTX).
- `models/` — LOCAL-ONLY (git-ignored), wired via `tmp/ComfyUI/extra_model_paths.yaml`.
- `tmp/` — LOCAL-ONLY: ComfyUI clone+venv, SwarmUI clone+build, agent tools venv.
- `README.md` — friend-facing Hungarian manual. `runbook.md` — base doc.
  `runbook_2.md` — video-model doc + manifests. `MODELS.md` — downloadable catalog.
- `memories.md` — your routing memory (fenced state + log). `initial_setup.bat` —
  friend bootstrap (prereqs + both agent CLIs + Preflight).
- Ports: 7801 SwarmUI web, 7821 Swarm comfy backend, 8188 direct comfy.

Repo LOCATION rules (friend-proofing): drive root of a roomy DATA/SSD drive
(e.g. `D:\comfyui-setup`) — never `C:`, never OneDrive-synced folders, no
accents/spaces in the path.

## 7. Reproducibility contract (must always hold)

- Fresh Windows machine + this repo + skills = working pipeline, top to bottom.
- No admin rights, no Visual Studio/build tools assumable — prebuilt wheels only.
- Runtime: ComfyUI on Windows (`tmp/ComfyUI/venv`, torch cu130 for 20-series+).
- `runbook.md` "Reference machine" versions refresh on every re-verification.
- `tmp/` is LOCAL-ONLY; `scripts/`, docs, skills are the committed contract.

## 8. memories.md discipline

- Session start: read fenced state, obey it - read head ~20 lines of memories.md .
- Session end (or after any milestone/surprise): tick checkboxes, append 2–3
  sentences to the router log (what changed, why, what worked/failed/to-retry).
- Keep it lean — routing table, not diary.
