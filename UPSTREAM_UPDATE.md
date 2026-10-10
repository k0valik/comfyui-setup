# UPSTREAM_UPDATE — read this FIRST (friend's agent)

This branch (`feat/remote-maintenance`) is a **remote maintenance packet** from the
repo maintainer. It was written WITHOUT knowing your machine's current state.
Your local state wins every disagreement. Merge **semantically** (by hand, with
understanding) — never with git automation.

## 0. Forbidden commands

Do NOT run any of these: `git pull`, `git merge`, `git checkout <branch>`,
`git stash`. They can silently overwrite the tuned local state
(`memories.md`, `workflows/*.json`). The review copy lives OUTSIDE your working
tree (in gitignored `tmp/`), so your checkout is never at risk.

## 1. Setup (read-only) — git optional, files are the contract

Primary path (this machine HAS git — the ComfyUI clone in `tmp/` proves it):

```powershell
git fetch origin feat/remote-maintenance
git worktree add tmp/upstream-review origin/feat/remote-maintenance
```

If this folder has no `.git` (ZIP install) OR any git command fails: do NOT
improvise git magic — download the branch as plain files instead. No GitHub
account needed, no browser needed:

```powershell
Invoke-WebRequest https://github.com/k0valik/comfyui-setup/archive/refs/heads/feat/remote-maintenance.zip -OutFile tmp\upstream.zip
Expand-Archive tmp\upstream.zip tmp\upstream-zip\
New-Item -ItemType Directory -Force tmp\upstream-review | Out-Null
Move-Item tmp\upstream-zip\comfyui-setup-feat-remote-maintenance\* tmp\upstream-review\
```

(Browser download of the same ZIP is the last resort.) Either way you end up
with the branch as plain files in `tmp/upstream-review/` — EVERY later step in
this playbook works from those file copies, with or without git. Git here is a
convenience (status/diff/worktree), never a requirement; if a git command
falls over, fall back to comparing files directly.

## 2. Snapshot YOUR state first

1. Read `memories.md` fenced Session state (top of file). Checked = done.
   This is the narrative truth — protect it.
2. Run `powershell -ExecutionPolicy Bypass -File scripts\Verify-Setup.ps1`.
   This is the machine truth. Save its full output to
   `tmp/backup-<today>/verify-before.txt`.
3. Run `git status --short` if `.git` exists. Note every locally modified file
   — that list is your "do not lose" list. (No `.git`? Skip — the backup below
   covers you anyway.)
4. Backup the whole LIGHTWEIGHT state (gitignored, safe): copy everything in
   the repo root EXCEPT `tmp/`, `models/`, `.git/` — i.e. `memories.md`,
   `workflows/`, `.agents/`, `scripts/`, all docs — to `tmp/backup-<today>/`.
   This is deliberately broader than "memories + workflows": your tuned skill
   text, script fixes and AGENTS.md additions live in those other files too.
5. Record the backup path in the `memories.md` router log NOW
   ("pre-packet backup: `tmp/backup-<today>/`") so no later session — or a
   session in a different client — can lose track of it.

## 3. Review the branch by SHAPE, not commit by commit

This branch has a few dozen small commits — that is the maintainer's
bookkeeping, NOT your work plan. Do NOT walk them one by one or try to replay
their order; nobody on that side manages strict git history, and the goal is a
working clean state on THIS machine, not a replayed history. Read the shape
instead, in this order:

1. `tmp/upstream-review/UPSTREAM_UPDATE.md` (this file, whole thing first).
2. `tmp/upstream-review/UPSTREAM.version` (one page — what this packet holds).
3. `tmp/upstream-review/AGENTS.md` vs your `AGENTS.md` (the new router).
4. `tmp/upstream-review/MODELS.md` image section +
   `.agents/skills/comfyui-drive/references/image-qwen.md` (the image plan —
   skim the HEADINGS only; the deep read belongs to §7. Do not fill this
   session with a 14GB plan you must not start yet.)
5. Everything else by diff only where it touches something you tuned.

Then apply SEMANTICALLY: understand each change's intent, carry over your local
tuning (calibration rows, tuned workflows, local script fixes, memories state),
take the upstream structure. "Semantic" does NOT mean "hand-rewrite
everything": a file you did NOT touch locally can be copied from
`tmp/upstream-review/` verbatim — clean applies need no ceremony. Only files
YOU changed need real judgment. The area map below is a MAP for orientation —
which area touches what and how to handle it — not a sequence to execute and
not a changelog; the branch was built in a few hours of maintenance, its
internal commit history has no value to you.

Optional tool — bucket classification (when `.git` exists, this turns "merge
by feel" into a mechanical checklist):

```powershell
$base = git merge-base HEAD origin/feat/remote-maintenance   # your fork point
git diff --name-only $base origin/feat/remote-maintenance    # what upstream changed
git status --short                                           # what YOU changed
```

- upstream changed, you didn't → copy from `tmp/upstream-review/` (clean apply).
- you changed, upstream didn't → keep yours untouched.
- both changed → compare the two files directly. If `$base` exists you can get
  an automatic three-way merge first (never touches your file):

  ```powershell
  git show "${base}:<path>" > tmp\base.md
  git show "origin/feat/remote-maintenance:<path>" > tmp\up.md
  git merge-file -p <path> tmp\base.md tmp\up.md > tmp\merged.md
  ```

  then hand-resolve any `<<<<<<<` markers in `tmp\merged.md` before adopting it.
- No common ancestor or no git (ZIP-based tree): same buckets, just do the
  last step as a direct two-file comparison against `tmp/upstream-review/`.

If any git command fails, drop down to plain file comparison — git is a
convenience here, the file copy in `tmp/upstream-review/` is the contract.

| # | Area | Handling rule |
|---|---|---|
| 1 | Repo hygiene: archive move + `.gitignore` | The setup skill moves to `archive/setup-legacy/` — carry any local edits inside it WITH it, don't drop them. `.gitignore` now allows small `models/` sidecars (`*.md/*.txt/*.json`) to be committed later; binaries stay ignored. Side effect: `git status` may suddenly show many small files under `models/` — that is EXPECTED, do NOT commit them mid-packet. |
| 2 | 7 vendored comfy skills | Accept as-is: 7 new folders under `.agents/skills/`. Do NOT run `comfy install skills` — that would download extra skills we don't want. These exact 7 are the set. |
| 3 | Drive skill re-point | Accept, BUT diff first: if you tuned the drive skill locally (prompts, calibration table!), keep your tuning and apply only the reference-path fixes + CLI pointers around it. The calibration table rows you measured are sacred. |
| 4 | New AGENTS.md | Accept as the new router, ONLY after areas 1–3 are in place (it references them). If your local AGENTS.md has hand-written additions, carry them into the new file, then replace. |
| 5 | Image plan (`MODELS.md` image section + `references/image-qwen.md`) | Keep your local model rows/picks, merge around the new Qwen block. Headline: image path = official Qwen Turbo via realrebelai (Q4_K_S 4.33GB; base-UC demoted to fallback, Abiray/AtomicChat documented as alts); shipped-workflow-first + its two widget traps; w4a8_convrot 4.20GB is the FIRST encoder test (stock loader, no fork; GGUF + leejet→molbal fork swap = fallback, with a real LTX regression check); Q3→Q4→Q5 ladders. See the README-FIRST note below. |
| 6 | New 2K/3K workflow | `workflows/ltx25Pure2K3KUltraLow_v10.json` as-is ([CivitAI 2877939 v3252415](https://civitai.com/models/2877939/ltx-25-pure-2k3k-ultra-low-vram-universal-workflow?modelVersionId=3252415)) + HU README blurb (NOT-READY status) + 8-step vetting map in `workflow-editing.md` (RAM check, gated-int8 swap plan, 3 extra files, pack list, <12GB rewiring, prompt doctrine). UI strings are already RU→HU (wiring verified identical; node BODIES stay RU for the agent to translate during vetting). This is an ADD — your existing `workflows/` files are sacred, never replaced by it. |
| 7 | `scripts/Update-ComfyUI.ps1` + bump policy | New file, no conflict possible — but UNVALIDATED upstream: read it fully before first run (§5). Moves ComfyUI to the newest stable release tag; torch build stays untouched. |
| 8 | Handoff docs (`UPSTREAM_UPDATE.md`, `UPSTREAM.version`, `HANDOVER.md`) | Accept — this playbook + the paste doc + the version marker. |
| 9 | Checkpoint structure (§6–§9) + review pass | §6 CHECKPOINT: memories hygiene, H3 declutter, fresh-session audit + packet manifest, report file, BREAKPOINT in the fenced state, client-agnostic restart. §7 Qwen OPTIONAL post-restart with i2v pitch. §8 finish + compacted second-pass sweep. §9 breaks. |

General rule per area: `diff` upstream vs local (`git diff` or WinMerge-style
compare against `tmp/upstream-review/`), keep local tuning, take upstream
structure. When in doubt, ask the human in Hungarian (one short question, two
options) instead of guessing.

> README-FIRST (area 5 especially): the HF repo READMEs
> named in `references/image-qwen.md` §−1 are PRIMARY sources, this branch is
> secondary. Read them end to end + follow their references BEFORE downloading
> or wiring anything. A quantizer README contradicting branch docs wins — take
> the README's value and note the correction in `memories.md`.

## 4. Files you must NEVER overwrite with upstream copies

- `memories.md` — merge by hand only (tick boxes you actually verified).
- `workflows/*.json` — tuned graphs are sacred. Compare node-by-node if an
  upstream workflow changed; ask before replacing.
- `models/` and `tmp/` — local-only, git-ignored; upstream never touches them.
- Your measured calibration-table rows in the drive skill.

## 5. ComfyUI bump + CLI check (after the merge)

> FIGYELEM / NOTE: `scripts/Update-ComfyUI.ps1` was written on a dev machine
> that has NO ComfyUI checkout — it could NOT be executed or validated upstream.
> Treat its first run on THIS machine as a trial. BEFORE running it:
> 1. Read the whole script (~120 lines, commented). Check every path it
>    touches exists on this machine (`tmp/ComfyUI/main.py`, `venv/Scripts/python.exe`).
> 2. Check its assumptions out loud: `git -C tmp/ComfyUI status` must be clean
>    (untracked files are OK — modified TRACKED files are not), and
>    `git -C tmp/ComfyUI remote -v` must point at Comfy-Org/ComfyUI; the
>    machine must be able to reach GitHub to fetch release tags.
> 3. If ANY step looks wrong for this machine (different venv layout, custom
>    torch build, forked ComfyUI remote), DO NOT run it — fix the script first,
>    note the fix in `memories.md`, and only then execute. The script is a
>    proposal, not a proven tool.

**Stable-release policy (this comes from the ComfyUI repo itself, not from
us):** ComfyUI ships a stable tag roughly every 2 weeks (`v0.39.x` etc.), and
its README warns that commits *outside* stable release tags "may be very
unstable and break many custom nodes". So the bump target is the NEWEST
STABLE TAG, not `master`'s tip: `git -C tmp/ComfyUI fetch origin --tags` →
take the newest `vX.Y.Z` tag → check it out → apply the repo's own update steps
(`pip install -r requirements.txt`; leave the existing torch build alone —
20-series+ stays on cu130 per the README's NVIDIA section). The script below
does exactly this — verify that while reading it.

1. `scripts/Verify-Setup.ps1` was NOT changed upstream — there is nothing to
   merge. If `git status` shows local modifications to it, keep yours; if it is
   unmodified, leave it alone.
2. Run the pre-bump verify:
   `powershell -ExecutionPolicy Bypass -File scripts\Verify-Setup.ps1`
   → save output to `tmp/backup-<today>/verify-before.txt`.
3. **Stop the servers first, by hand:** the script stops NOTHING itself — if
   any of :7801/:7821/:8188 answers, it refuses and asks the human to close
   the server window (Ctrl+C there). Do that, then re-run.
4. Run the bump: `powershell -ExecutionPolicy Bypass -File scripts\Update-ComfyUI.ps1`
   (default cheap backup is fine; full venv backup only if the human says yes —
   it's many GB).
5. Run the post-bump verify: → must be all PASS (the **friend-profile PASS**
   is the target; full-profile H3 FAILs are expected — see §6.2c).
6. CLI check: `tmp\agent-tools\Scripts\comfy.exe --version` prints the
   comfy-cli version — that is the point, it proves the CLI runs. The
   ComfyUI commit before/after lives in the bump's backup folder
   (`comfy-commit-before.txt` / `comfy-commit-after.txt`). If comfy.exe is
   missing, re-run `scripts\Install-AgentTools.ps1` first (it installs
   comfy-cli + comfy-mcp and points the workspace at `tmp/ComfyUI`).
7. Queue ONE short generation (cheapest template) to prove the loop still works.

## 6. CHECKPOINT — stop here, clean up, hand over to yourself (Qwen comes AFTER restart)

Do NOT start the Qwen image stage in this session. It downloads ~14GB and runs
many renders — the context will be full of merge details by now and you will
make worse decisions. Instead:

1. **Memories hygiene.** The router log surely holds stale entries: initial
   setup struggles, driver/HF-gate pain, workarounds for problems that no longer
exist (setup is done, ComfyUI is bumped). Compress them: merge each dead thread
   into ONE line (what it was, that it is resolved, the one lesson if any) and
   delete the rest. KEEP: hardware facts, calibration rows, workflow tuning,
   decisions + why, the bump before/after hashes. `memories.md` must read like a
   fresh machine dossier, not a diary.
2. **H3 declutter (this 8GB card cannot run MiniMax-H3 — dead weight).**
   a. List what's actually on disk (friend profile never downloads H3, so this
      may be a no-op): `Get-ChildItem models/ -Recurse | Where-Object { $_.Name
      -match 'minimax|h3' } | Select-Object Name, @{n='GB';e={[math]::Round($_.Length/1e9,1)}}`
      If empty → one line in the log, skip to (c).
   b. If H3 files exist: ask the human in Hungarian with the EXACT number
      ("A MiniMax-H3 modellek X GB-ot foglalnak, de ez a kártya nem bírja el
      őket — törölhetem? Bármikor újraletölthetők.") → delete ONLY after an
      explicit yes. Record every deleted filename + size + source repo in
      `memories.md` (restorable on demand).
   c. After deletion: `Verify-Setup.ps1` MUST show the **friend-profile PASS**.
      Full-profile H3 FAILs after this are EXPECTED, not a problem — note that
      in the log so no future session "repairs" them by re-downloading H3.
   d. References: do NOT delete committed H3 docs/workflows (upstream owns
      them — flag "H3 retired on this machine, archive candidate" in the
      report-back instead). DO add one line to local `memories.md`: "H3 retired
      <date>, <GB> freed" — that alone steers every future session away.
3. **Fresh-session audit.** Confirm ALL of these, fix or note gaps:
   - new `AGENTS.md` is in place and its skill paths resolve (open each one).
   - `Verify-Setup.ps1` → all PASS (post-bump).
   - no stale references: `grep -rn "comfyui-setup" .agents/skills/comfyui-drive/`
     returns only the archive pointer + the repo-folder prose mention.
   - 7 `comfy*` skills present under `.agents/skills/`; `comfy.exe --version` works.
   - `workflows/` untouched except intended changes; `models/` + `tmp/` intact.
   - PACKET MANIFEST — every packet file exists in YOUR tree (check the real
     files, not the review copy): `UPSTREAM_UPDATE.md`, `UPSTREAM.version`,
     `HANDOVER.md`, `scripts/Update-ComfyUI.ps1`, `archive/README.md` +
     `archive/setup-legacy/`, 7 folders under `.agents/skills/comfy*`,
     `.agents/skills/comfyui-drive/references/image-qwen.md`, the MODELS.md
     image section, `workflows/ltx25Pure2K3KUltraLow_v10.json`.
   - the `BREAKPOINT — next: UPSTREAM_UPDATE.md §7` line is in the `memories.md`
     fenced Session state (see step 5).
   - ONLY after ALL of the above: remove the review copy —
     `git worktree remove tmp/upstream-review` (if it refuses because of stray
     files inside, add `--force`; if there is no git, just delete the folder —
     it is a disposable copy, re-downloadable any time).
4. **Append the merge report** to the `memories.md` router log (what was taken,
   local tuning preserved, bump before/after hashes, verify result) AND write
   the full version to `tmp/upstream-report-<date>.md`: `git status --short`
   (or a plain file listing if no `.git`), verify before/after summaries, bump
   hashes, one line per table row (taken / kept-local / modified + why), any
   problems hit. The human forwards THAT FILE to the maintainer — it is the
   only telemetry they get from this machine.
5. **Write the self-handover and STOP.** Output (Hungarian), 50–100 words:
   what was done, the fresh-session audit result, and the literal reference
   "folytatás: `UPSTREAM_UPDATE.md` 7. pont". End it with this exact line:
   `BREAKPOINT — next: UPSTREAM_UPDATE.md §7, bringing the Qwen image workflow and model to ComfyUI.`
   Also add one line to the `memories.md` fenced Session state —
   `- [ ] BREAKPOINT — next: UPSTREAM_UPDATE.md §7 (Qwen image stage)` —
   so ANY future session in ANY client resumes from the file, not the chat.
6. **Human handover / restart — client-agnostic.** The human rotates between
   agent clients (mainly opencode, also Antigravity and Codex — same folder,
   same files; all state lives in `memories.md`). Show the steps in Hungarian:
   - Jelöld ki és másold ki a fenti összefoglalót egy üres Notepad-be.
   - opencode: CTRL+C kétszer a kilépéshez (másik kliens: zárd be ugyanabban
     a mappában).
   - Indítsd újra ugyanabban a mappában: opencode-ban `opencode --continue`,
     majd `/compact` (összetömöríti az előzményeket). Másik kliensben: nyiss
     új beszélgetést — nincs szükség semmilyen folytatás-parancsra.
   - Másold VISSZA a Notepad-ből az összefoglalót, küldd el — és folytatjuk.

## 7. Qwen image stage (new session, OPTIONAL — the human decides here)

First message after restart: present the choice in Hungarian (one question,
the explanation inside the options):

- **Igen, kérek képgenerálást** → Qwen-Turbo út (`references/image-qwen.md` §−1-től):
  README-first, ~14GB letöltés, 8-lépéses benchmark, próbarajz rövid prompttal.
- **Nem, most nem kell** → stop here, nothing more to do. No download, no fork,
  no changes. (Revisit anytime: the docs stay in the repo.)

Either way, make this pitch once (short, Hungarian): LTX tud **képből videót**
(image-to-video workflow-val) — vagyis a csővezeték lehet: Qwen megrajzolja a
képet promptból → LTX megmozgatja prompt + referenciakép alapján. A referenciaképes
videó szebb, stabilabb kimenetet ad, és jobb workflow-kat lehet rá építeni. So the
image stage is not a toy — it is the front half of a better video pipeline.

## 8. Finish (only after §7 resolves either way)

1. Append the final 3–5 sentences to the `memories.md` router log (§7 outcome,
   Qwen benchmark rows if any) and append the §7 outcome to
   `tmp/upstream-report-<date>.md`.
2. Tell the human (in Hungarian, short): what changed overall, that everything
   still works, and hand them the report-back FILE
   (`tmp/upstream-report-<date>.md`). Fallback if a file cannot be sent: paste
   the NEWEST `memories.md` router-log entries — the log is newest-first, so
   quote the TOP lines, not the bottom.
3. **Final sweep with compacted context — do not skip.** `UPSTREAM_UPDATE.md`
   is very long and heavily numbered; first passes miss steps (that is
   expected, not a failure). Before declaring done: request a NEW COMPACTION
   (opencode: `/compact`; other client: start a fresh session — all state is in
   the files), then re-read `UPSTREAM_UPDATE.md` end to end with that clean
   context and re-check every section's end-state against the machine:
   §1 review copy existed and is now removed · §2 backup folder exists and its
   path is in the router log · §3 bucket/apply notes recorded · §4 sacred files
   untouched · §5 verify before/after both PASS + bump hashes recorded · §6
   manifest complete, H3 decision recorded, BREAKPOINT in the fenced state,
   report file written · §7 Qwen outcome recorded (installed + benchmark rows,
   or declined) · §8 this sweep done. This second pass is MANDATORY after a
   Qwen install (download + renders push the earlier steps out of any context),
   and applies in the declined case too. Append "secondary pass: OK" — or each
   gap found and fixed — to `tmp/upstream-report-<date>.md` and the router log.

## 9. If anything breaks

Stop at the first red error. Do NOT delete `models/`, `workflows/`,
`tmp/ComfyUI`, or any committed file to "fix" something. Restore from
`tmp/backup-<today>/`, write down (Hungarian, for the human) what failed + what
you tried + 2 concrete options, and wait.
