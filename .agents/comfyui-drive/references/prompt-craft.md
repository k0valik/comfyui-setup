# Prompt Craft (LTX-2.5 + MiniMax H3)

## Who rewrites what (director policy)

- The AGENT is the primary director: the human's Hungarian idea → structured EN
  generation prompt, shown to the human before running (HU framing, EN prompt).
- LTX-2.5 official templates embed `TextGenerateLTX2Prompt` (LLM rewriter, ON by
  default, hidden in a subgraph). Our curated LTX civitai workflow ships WITHOUT it —
  keep it that way; prompt fidelity beats auto-expansion, and agent+rewriter = double
  rewriting. Symptom of an active rewriter: output unrelated to prompt, different
  prompts → same video, +60-100s render time. Details:
  `sources/ltx25-hidden-prompt-rewriter.md`.
- Dedicated local director LLM: RESERVED FOR FUTURE (user decision). Some advanced
  workflows (official H3 style skills) embed their own planning models already.

## LTX-2.5 style rules (from sources/ltx25-prompt-guide.md)

1. Present tense ("She walks...", not "will walk" / "walking").
2. Camera language, not vibes: "wide tracking shot, slow push-in, shallow depth of
   field" beats "epic cinematic feeling".
3. Specific people: age, build, clothing, distinctive features; re-state identifiers
   on every cut.
4. One coherent light logic per shot.
5. Real camera terms: tracking shot, push-in, low angle, over-the-shoulder, dolly,
   handheld.
6. Audio IS part of the prompt (LTX generates synced audio): wind, footsteps,
   distant traffic, a sudden tear.
7. Multi-shot: one chronological paragraph; cuts named in prose ("A hard cut
   transitions to...", "The view cuts to a close-up of..."); re-establish shot scale
   + character identifiers + audio continuity at every cut. 2-4 shots per 10s.
8. Never: numbered timelines ("0-3s: ..."), SD weight syntax (word:1.4), vague
   emotion labels, unexplained costume/geography changes, overloaded shots.

## MiniMax H3 prompt structure (official `h3-prompt-writing` skill)

H3 wants structured multimodal prompts, not LTX prose:
- `integrated_multimodal_description` — the scene, shot by shot
- `overall_soundscape` — ambience/dialogue/SFX plan
- `non_diegetic_music` — score
- Keyframe alignment + reference labels for I2VA/Ref2VA inputs.
Full guide: fetch `h3-prompt-writing` from the official repo
(see external-skill-catalog.md) — or read its references/base-en.txt + ref-en.txt.
H3 templates carry audio direction INSIDE the same prompt block (H3 generates native
audio), unlike LTX's separated fields.

## Preset vocabulary (translate HU choice -> EN prompt fragment)

Committed in `presets/prompts.md` — camera/motion/mood/style fragments. When the
human picks "lassú orbit" or "álmodozó", use the mapped EN fragment; when they ask
for something outside the vocabulary, add it there (commit) instead of inventing
inline every time.

## Rewrite loop with the human

1. Human gives HU idea (voice message, few words, whatever).
2. Agent produces EN prompt in the correct model structure + HU one-line summary of
   the creative choices made.
3. Run. On feedback ("több eső, kevesebb neon"), edit the SPECIFIC fragment, show the
   diff line, regenerate — batch with any other queued changes.
