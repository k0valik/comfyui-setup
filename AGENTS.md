# AGENTS.md — agent operating context (loaded into your context EVERY session)

You are an agent on **this Windows 11 video PC**. The pipeline (ComfyUI + SwarmUI +
models + workflows) is **already installed and verified**. Your job is generation
work: run templates, edit workflows, rewrite prompts, tune for this card.

## 1. Session startup (every time, in this order)

1. Read `memories.md` — the fenced **Session state** checkboxes at the top are the
   truth about what is done. Checked = done: do NOT re-check, re-install, or
   re-download it.
2. Run `powershell -ExecutionPolicy Bypass -File scripts\Verify-Setup.ps1` if the
   session touches the environment at all (slow renders, new nodes, odd errors).
   It is the machine truth; `memories.md` is the narrative truth. If they disagree,
   trust Verify-Setup and update memories.md.
3. Pick ONE skill and read its `SKILL.md` fully, plus the references it names:
   - **generate / edit / tune** ("generálj", "módosítsd a workflowt", "írd át a
     promptot", "lassú", "OOM") → `.agents/skills/comfyui-drive/`
   - **Hugging Face Hub ops** (uploads, repos, downloads) → `.agents/skills/hf-cli/`
   - **comfy CLI** (debug a failed run, custom nodes, narrative video, cloud
     deploy) → the matching `.agents/skills/comfy*/` skill (see drive skill §References)
4. Confirm you are in the repo root: `scripts\Verify-Setup.ps1` and `workflows/`
   and `memories.md` must exist. If not, ask the human (in Hungarian) to open the
   right folder, then stop.

If a skill step fails and you find a better way, UPDATE the skill + script +
workflow + memories.md so the next session inherits the fix.

**Multiple clients:** the human rotates between agent clients in this SAME
folder (mainly opencode, also Antigravity and Codex). All state lives in files
(`memories.md`, this AGENTS.md, the skills) — a brand-new or compacted context
is NORMAL: read the files, continue the current step, never redo completed
work, and never assume a missing detail from "your" earlier conversation was
unimportant — it is probably written down.

## 2. Safety fence (hard rules — no exceptions without explicit human OK)

TRY to make things work on your own — resilience is the job — but inside this fence:

- **No deletions** except these two sanctioned rebuilds:
  `tmp/SwarmUI/src/bin/live_release` (failed Swarm build) and node-pack
  reinstalls via `comfy node install`. Never delete `models/`, `workflows/`,
  `tmp/ComfyUI`, or any committed file to "fix" something.
- **Never touch the home directory** — except your OWN agent-client config files
  when registering MCP (e.g. `~/.codex/config.toml`, Gemini `settings.json`).
  Nothing else gets written outside the repo.
- **Never uninstall, downgrade, or registry-edit anything.** If something must be
  removed/reinstalled by hand, write the exact steps in Hungarian and let the
  human do it.
- **Never disable Defender/firewall/SmartScreen**, never reboot the machine,
  never click UAC — those are human gates (hand over in Hungarian).
- **Confirm BEFORE big downloads**: state size + time estimate in Hungarian.
  Model downloads resume in place — say so, it calms people.
- **Browser-only gates stay human**: NVIDIA driver install, HF account +
  Agree-and-Access + token, Swarm first-run wizard clicks, app sign-ins.
  Give exact Hungarian wording (drive skill references have it verbatim).
- Tokens (`hf_...`) live in `$env:HF_TOKEN` per session. Never write them into a
  committed file. Never commit `tmp/`, `models/`, tokens.

## 3. Language rule

EVERY human-facing message in **Hungarian**. Commands, file names, UI labels,
URLs stay English in backticks. Pair any English error text with a one-line
Hungarian interpretation. Calm, short sentences, one action per message.
(Agent-facing files — skills, runbooks, memories.md log — may be English.)

The user does NOT know what VAE, text encoder, safetensors, or VRAM requirements
mean. Explain briefly and simply, like to a beginner:

- Beszélj magyarul a felhasználóval! Érthetően, normálisan, kezdőknek valóan.
- Legyél kreatív a leírásaiddal, próbáld el röviden, tömören de érthetően
  elmagyarázni egy laikusnak éppen mit és miért csináljon, vagy csináltál.
- Nem kell hosszú prózákat írni, hacsak nem a felhasználó kíváncsi többre,
  vagy valami nem tiszta neki.
- Tegyél fel eldöntendő kérdéseket (igen/nem), vagy ajánlj lehetőségeket úgy,
  hogy az opciók magukban hordozzák a magyarázatot.

## 4. Repo layout (orientation)

- `scripts/` — the committed contract: `Verify-Setup.ps1` (truth),
  `Update-ComfyUI.ps1` (safe ComfyUI bump with venv backup),
  `Download-Models.ps1`, `Install-NodePacks.ps1`, `Start-Swarm.ps1`/`Start-Swarm.bat`,
  `Start.ps1`/`Start.bat`, `Install-AgentTools.ps1`.
- `workflows/` — YOUR templates. Treat local files as sacred: never overwrite a
  tuned workflow with an upstream copy without asking (in Hungarian) first.
- `models/` — LOCAL-ONLY (git-ignored), wired via `tmp/ComfyUI/extra_model_paths.yaml`.
- `tmp/` — LOCAL-ONLY: ComfyUI clone+venv, SwarmUI clone+build, agent tools venv.
- `memories.md` — your routing memory (fenced state + log).
- `archive/setup-legacy/` — the retired setup skill. Open it ONLY if
  `Verify-Setup.ps1` shows FAILs you cannot fix any other way.
- Ports: 7801 SwarmUI web, 7821 Swarm comfy backend, 8188 direct comfy.

Keep this repo at the drive root of a roomy DATA/SSD drive — never `C:`, never a
OneDrive-synced folder, no accents/spaces in the path.

## 5. memories.md discipline

- Session start: read fenced state, obey it.
- Session end (or after any milestone/surprise): tick checkboxes, append 2–3
  sentences to the router log (what changed, why, what worked/failed/to-retry).
- Keep it lean — routing table, not diary.
