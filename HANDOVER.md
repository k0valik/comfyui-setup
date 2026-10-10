# HANDOVER — maintenance packet `feat/remote-maintenance` (friend: paste below the line into their agent client)

Maintainer note: this whole file (below the line) is self-contained. Copy-paste
it to your friend as-is; they paste it into their agent client (mainly
opencode, sometimes Antigravity or Codex) running in the `comfyui-setup`
folder. English is intentional (no context-switch for the agent; the agent
itself talks Hungarian to the human).

---

Hi! Your maintainer prepared a remote maintenance packet for you: branch
`feat/remote-maintenance` (a few dozen small commits: context pruning, new
router, ComfyUI bump script, comfy CLI skills, Qwen image plan, a new 2K/3K
video workflow).

**Read this first — what this packet is and is NOT.** It is a BEST-EFFORT
AGENDA, written by the maintainer WITHOUT knowing your machine's current
state: exact commit counts, exact wording, and step details may not match
what you find. Do not dwell on the commits or treat any sentence as law where
it conflicts with reality on this machine. The intent is simply to bring you
the updates — better context (pruned memories/new router), the ComfyUI bump,
the Qwen image model plan, and the new workflow — in a safe, reversible way.
Precedence when things disagree: **this machine's actual state > `memories.md`
local files > `UPSTREAM_UPDATE.md` (the detailed playbook) > this paste.**
Apply changes SEMANTICALLY: understand intent, keep local tuning (memories,
tuned workflows, measured settings), take upstream structure. End goal = a
clean working setup, NOT a replayed git history — do NOT walk the commits one
by one. A file you never touched locally can be copied from the side copy
verbatim; only files you changed need judgment. Prefer safe operations; when
in doubt, ask the human (one short question, two options) instead of guessing.

FORBIDDEN on YOUR working tree (they can silently destroy your tuned state):
`git pull`, `git merge`, `git checkout <branch>`, `git stash`. Your working
tree is never touched with git — the branch gets reviewed from a side copy.

Step 1 — look, don't touch (git should exist — the `tmp/ComfyUI` clone proves
it was installed; if any git command fails, fall back to the plain-file
download, never improvise git magic):
```powershell
git fetch origin feat/remote-maintenance
git worktree add tmp/upstream-review origin/feat/remote-maintenance
```
(No `.git` — ZIP install? The agent downloads it itself, no browser, no
GitHub account needed:
`Invoke-WebRequest https://github.com/k0valik/comfyui-setup/archive/refs/heads/feat/remote-maintenance.zip -OutFile tmp\upstream.zip`
→ `Expand-Archive tmp\upstream.zip tmp\upstream-zip\` → move the CONTENTS of
`tmp\upstream-zip\comfyui-setup-feat-remote-maintenance\` into
`tmp\upstream-review\`. Continue either way — everything below works from
those plain file copies; git is a convenience, not a requirement.)

Step 2 — snapshot YOUR state: read `memories.md` Session state (checked = done,
protect it). Run `scripts\Verify-Setup.ps1`, save the output to
`tmp\backup-<today>\verify-before.txt`. Run `git status --short` if `.git`
exists. Back up ALL lightweight repo files (everything except `tmp\`,
`models\`, `.git\` — memories, workflows, skills, scripts, docs) to
`tmp\backup-<today>\` and record that path in the memories.md router log
immediately.

Step 3 — read the SHAPE, in this order: `tmp/upstream-review/UPSTREAM_UPDATE.md`
(the full playbook — obey it), then `UPSTREAM.version`, then the new `AGENTS.md`
vs yours, then the image plan (`MODELS.md` image section +
`.agents/skills/comfyui-drive/references/image-qwen.md` — skim headings only,
§−1; the deep read belongs to §7). Apply by understanding, not by copying:
keep your tuning (calibration rows, tuned workflows, local fixes), take the
upstream structure. The commit table in UPSTREAM_UPDATE §3 is an AREA MAP of
handling rules, not a to-do list and not a changelog. UPSTREAM_UPDATE §3 also
has an optional bucket-classification + `git merge-file` recipe for the
tricky files.

Step 4 — environment: `Verify-Setup.ps1` is UNCHANGED upstream — if `git status`
shows local mods to it, keep yours. Verify BEFORE, then bump with
`scripts\Update-ComfyUI.ps1` — UNVALIDATED upstream: read the whole script
first, check its assumptions out loud, fix before running if anything
mismatches. Target = the NEWEST STABLE ComfyUI release tag (fetch tags →
newest `vX.Y.Z` → checkout → `pip install -r requirements.txt`, existing torch
build stays — per the ComfyUI README), NOT master's tip. Stop the servers by
hand FIRST — the script refuses to run while they answer, it stops nothing
itself. Verify AFTER (all PASS), `comfy.exe --version` (prints the comfy-cli
version — proof the CLI runs), and run ONE short video generation to prove the
loop.

Step 5 — CHECKPOINT, then STOP. No Qwen yet (it is ~14GB + many renders — fresh
session work). Compress dead memories threads (old setup pain → one line each;
keep facts, calibration, decisions, bump hashes). H3 declutter + fresh-session
audit per UPSTREAM_UPDATE §6 — including the packet-manifest check BEFORE
removing the review copy, and writing the report file
`tmp/upstream-report-<date>.md`. Write a 50–100 word Hungarian handover ending
in the exact line `BREAKPOINT — next: UPSTREAM_UPDATE.md §7, bringing the Qwen
image workflow and model to ComfyUI.` (also add the BREAKPOINT line to the
memories.md fenced Session state). Then stop and show the human the restart
steps — client-agnostic (mainly opencode: copy summary to Notepad → CTRL+C
twice → `opencode --continue` → `/compact` → paste the summary back; another
client: same folder, new session, paste the same summary).

Step 6 (new session) — ask the human in Hungarian whether they want image
generation at all (yes → `image-qwen.md` from §−1, download, benchmark,
smoke-test with a short prompt; no → stop, docs stay for later). Either way,
pitch once: Qwen images → LTX image-to-video = better, more stable videos.

Step 7 (closing) — do NOT declare done yet: force a NEW COMPACTION (`/compact`,
or a fresh session in another client), then re-read `UPSTREAM_UPDATE.md` end
to end with that clean context and run the §8.3 final sweep — the playbook is
long and heavily numbered, so a second pass is how missed steps get caught
(mandatory after a Qwen install). Then finish per §8 and send the report file.

If anything breaks: stop at first red error, restore from backup, tell the
human in Hungarian what failed + 2 options, wait. Never delete `models/`,
`workflows/`, `tmp/ComfyUI` to "fix" anything.

Report-back: send the FILE `tmp/upstream-report-<date>.md` to the maintainer
(fallback: the NEWEST memories.md router-log entries — newest-first, so the
TOP of the log).
