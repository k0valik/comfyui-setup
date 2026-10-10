# Retired setup skill (archived, not deleted)

The pipeline on the target machine is installed and verified, so the full
`comfyui-setup` install driver no longer belongs in `.agents/skills/` (it
polluted every session's context window for a job that is done).

Moved here with history via `git mv` on the `feat/remote-maintenance` branch.
Keep for two purposes only:

1. **Repair fallback** — if `scripts/Verify-Setup.ps1` ever shows FAILs the
   drive skill cannot fix, the staged install procedures + Hungarian gate
   wordings here are still the reference.
2. **Fresh-machine installs** — if a second PC ever needs the pipeline from
   zero, resurrect from here.

Do NOT point the agent router at this folder in normal sessions.
