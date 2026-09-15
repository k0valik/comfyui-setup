# External Skill Catalog (fetch, don't invent)

Before building a new workflow from scratch, check whether an official/maintained
skill already encodes the recipe. Fetch at runtime (anti-rot), never vendor whole
catalogs into this repo.

## MiniMax H3 official skills — https://github.com/MiniMax-AI/MiniMax-H3/tree/main/skills

1 prompt-writing skill + 8 style-specific video generator skills, each an installable
SKILL.md (+ Chinese variants), actively maintained by MiniMax:

- `h3-prompt-writing` — structured prompts for all five H3 modes (T2VA/I2VA/FL2VA/
  L2VA/Ref2VA): `integrated_multimodal_description` + `overall_soundscape` +
  `non_diegetic_music`, keyframe alignment, reference labels. Ships
  `references/base-en.txt` + `ref-en.txt`. READ BEFORE writing any H3 prompt.
- Style generators: `minimalist-product-ad-generator`, `3d-animation-short-generator`,
  `brand-promo-video-generator`, `co-op-game-intro-generator`,
  `handdrawn-live-video-generator`, `music-video-subtitle-generator`,
  `paper-collage-explainer-generator`, `papercraft-stop-motion-explainer`.
  Each = planning workflow + prompt patterns + assembly steps. Most transfer to LTX
  (shot planning/storyboard logic is model-agnostic; prompt STRUCTURE differs —
  apply prompt-craft.md rules per model).

Fetch pattern (agent runtime):
`curl -s https://raw.githubusercontent.com/MiniMax-AI/MiniMax-H3/main/skills/<skill>/SKILL.md`
(references via the same raw pattern). Install-for-client option:
`npx skills add https://github.com/MiniMax-AI/MiniMax-H3 --skill <name>` (needs
Node; the friend's machine may not have it — raw fetch is the default).

## Also known

- ComfyUI built-in template browser (bundled via comfyui-workflow-templates package):
  first stop for "is there an official template for X" — search in the UI, or MCP
  `search_templates`.
- LTX advanced workflows (IC-LoRA control, in/outpainting):
  https://github.com/Lightricks/ComfyUI-LTXVideo + Lightricks/LTX-2.5 repo files
  (`video_ltx2_5_*_GGUF.json` live in the GGUF HF repo too).
- ComfyUI-VideoHelperSuite: the standard video utility pack (load/combine/encode) —
  candidate for extend/concat/stylize workflows; install via node pack discipline
  when a workflow needs it (see workflow-editing.md §node-packs).

## Rule

New workflow idea → catalog check → official template/skill first → community
validated (civitai w/ real outputs) second → build-from-scratch last. Whatever enters
the repo lands in `workflows/` + this catalog's notes (which node packs + model files
it needs), committed.
