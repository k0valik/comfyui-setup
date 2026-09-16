# memories.md — agent routing memory (agent-facing; English OK, Hungarian only when quoting friend-facing text)

<!-- ========================================================================
FENCED: SESSION STATE — this section STAYS at the top of this file.
Update the checkboxes as milestones complete. Never delete this section.
On session start, read it first: checked = done, do NOT re-check or redo.
========================================================================= -->
## Session state (update checkboxes, never delete)

- [ ] Prereqs on friend machine (`initial_setup.bat`: Git, Python 3.13, .NET 8, Node 24, Codex + Antigravity)
- [ ] NVIDIA driver installed + reboot done (`nvidia-smi` shows card)
- [ ] HF gate done (account + Agree-and-Access on Lightricks/LTX-2.5 + Read token)
- [ ] ComfyUI installed (`scripts/Install.ps1`, CUDA check True)
- [ ] Models downloaded — profile: `friend` (~23GB) / `full` (~86GB) — circle one
- [ ] Node packs installed (`scripts/Install-NodePacks.ps1`: rgthree, Easy-Use, GGUF)
- [ ] SwarmUI installed + grafted + launches (`scripts/Start-Swarm.bat` → :7801)
- [ ] Agent tools registered (comfy-cli + comfy-mcp in `tmp/agent-tools/`, MCP in client, client restarted)
- [ ] Encoder swap done on LTX workflows if profile=friend (CLIPLoader → w4a8 encoder)
- [ ] First generation succeeded (template workflow ran, output file exists)

<!-- END FENCED -->

## Router log (newest on top; 2–3 sentences per bullet: what changed, why, what worked / failed / to retry)

- **2026-09-16 — 3 YouTube workflows adopted (inspected, not yet run).** Renamed to spaceless names (`LTX2.5-director-2.0.json`, `RTX-SR-upscaler-video.json`, kept `LTX_2.5_FLF2V_8GB_NATIVE_AUDIO_NEGATIVE.json`). JSON inspection: FLF2V refs int8+w4a8_convrot (switchable), non-conv VAE name, keeps TextGenerateLTX2Prompt by design, author's personal PNGs; Director needs Kijai+VHS packs (VHS NOT in default set); RTX-SR needs VSR pack (exact registry name unconfirmed) + VHS. Drive skill has inspection checklist + per-workflow swap maps; workflows/README has HU blurbs; MODELS.md has Winnougan repo (open, 12.5/12.5/10.6GB, INT4 files absent). To verify: agent installs missing packs, performs swaps, runs one short render per workflow, records results.
- **2026-09-16 — HF-token fallback codified (friend-proofing stage 3).** Big friend-profile weights are OPEN repos (no token); only 4 small Lightricks files (~3GB) are gated. `Download-Models.ps1` got `Get-GatedRepoFiles` (401/403 → prints exact browser-download links + target subfolders, HU-safe), skill has the no-token runbook, HU comms has click-by-click token creation + manual-download message with 4 links. Rate-limit note: anonymous downloads may throttle — token preferred, retry on 429.
- **2026-09-16 — AGENTS.md flipped to agent-context-first (loaded every call).** Now: environment probe (§1: friend-Win11 vs author-WSL vs wrong-folder vs ZIP-no-.git), session-startup order (memories.md → route → read skill), explicit safety fence (§3: sanctioned deletions only, home-dir exception ONLY for own MCP client configs, no uninstall/registry/reboot/UAC), repo map + location rules, router table, memories discipline. Fixed 3 stale `.agents/...` paths (missing `skills/`) in runbook_2/scripts-README/presets; verified zero remain. Also fixed drive-skill garbled bullet + profile-aware HU gate texts (86GB→friend/full sizes, H3-first-gen→profile-matched workflow). To verify: fresh agent session starting from AGENTS.md alone should reach the right skill without re-doing PASSed stages.

- **2026-09-16 — repo still on AUTHOR machine, friend has run nothing yet (all boxes above unchecked).** Profiles landed: `Download-Models.ps1 -Profile friend|full` (friend=GGUF DiT+w4a8 encoder+VAEs ~23GB, default), `Verify-Setup.ps1` profile-aware, new `MODELS.md` catalog, drive skill owns the CLIPLoader→w4a8 encoder swap as first edit on friend machines, both Codex+Antigravity installed by `initial_setup.bat` (quota-switch policy). To retry/verify: friend runs `initial_setup.bat` on fresh Win11, says the magic phrase, agent drives setup skill.
- **2026-09-16 — README rewritten friend-first (ZIP+`initial_setup.bat` path A, desktop-app path B).** Fixed stale model numbers (friend ~23GB vs full ~86GB), admin/UAC note, skip-notes for bootstrap-covered steps, SwarmUI added to §9. Still to verify: friend comprehension — if they stumble on Shift+right-click PowerShell step, simplify further.
- **Open question: desktop-app MCP/skill registration paths (ChatGPT app, Antigravity app).** CLI registration is committed and verified; app-side config locations unconfirmed — agent must look them up at runtime when friend uses path B, then commit findings to the setup skill.
