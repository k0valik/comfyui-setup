LTX-2.5 is one of the strongest open video models right now — native multi-shot, excellent motion, sharp prompt understanding (thanks to the custom Gemma 4 backbone), and real cinematic quality when you feed it the right language.

But like every good model, it rewards clarity and structure. Vague prompts get average results. Precise, cinematic prompts get the kind of clips you actually want to show people.

Here’s the practical way to write strong prompts for it.

### Core Principles

1. **Write in present tense** “She walks…” not “She will walk…” or “A woman walking…”
2. **Describe what the camera sees, not abstract vibes** Bad: “epic cinematic feeling” Good: “wide tracking shot, slow push-in, shallow depth of field”
3. **Be specific about people** Age, build, clothing, distinctive features. The model remembers identities better when you re-state them cleanly.
4. **Lighting and atmosphere matter a lot** One coherent light logic per shot works far better than mixed sources.
5. **Camera language is powerful** Use real terms: tracking shot, push-in, low angle, over-the-shoulder, slow dolly, handheld, etc.
6. **Audio is part of the prompt** Mention wind, waves, footsteps, a sudden tear, distant traffic, etc. LTX-2.5 generates synchronized audio.

### Single Continuous Shot vs Multi-Shot

**Single continuous take** (best for fluid motion): Write one flowing paragraph of 4–8 sentences. No numbers, no timestamps.

**Multi-shot** (LTX-2.5’s big strength): Still write it as one chronological paragraph, but clearly name the cuts:

- “A hard cut transitions to…”
- “The view cuts to a close-up of…”
- “A match cut connects…”

On every cut you should:

- Re-establish the shot scale and who’s in frame
- Keep the same visual identifiers for recurring characters
- Note whether the audio continues or changes

Prefer 2–4 shots in a 10-second clip. More than that usually needs tighter writing.

### Common Mistakes to Avoid

- Numbered timelines like “0-3s: … 3-6s: …” (the model prefers natural prose)
- Keyword stuffing or Stable Diffusion weight syntax (word:1.4)
- Vague emotional labels (“she looks sad”) instead of physical cues
- Conflicting geography or sudden unexplained costume changes between cuts
- Overloading one shot with too many actions

---

### 3 Ready-to-Run 10-Second Prompt Ideas

These are written in the exact style LTX-2.5 likes. You can paste them directly.

**1\. Hoverbike Chase Through Neon Canyon (Futuristic Action)**

```
A dynamic tracking shot races through a narrow neon-lit canyon of towering holographic skyscrapers at night. A sleek black hoverbike streaks forward, its blue underlights cutting through the rain-slicked air. The rider, a young woman in a reflective silver jacket and glowing visor helmet, banks hard around a corner as holographic advertisements flicker past. The camera stays locked tightly behind her, slightly low, following every sharp turn while reflections of pink and cyan light streak across the wet surfaces. Distant sirens and the deep hum of the hover engines fill the air. Photorealistic, ultra-detailed, cinematic cyberpunk lighting, 8k masterpiece.
```


---

The other two examples stay the same:

**2\. Rainy Neon Street (Atmospheric Mood)**

```
A slow tracking shot moves through a rainy neon-lit Tokyo side street at night. Reflections of pink and blue signs shimmer on the wet asphalt. A young woman in a long dark coat walks toward camera under a transparent umbrella, raindrops catching the neon light. She stops, lowers the umbrella slightly, and looks up at the glowing signs with a quiet smile. Soft rain and distant traffic create the only sound. Cinematic, shallow depth of field, rich colors, highly detailed, 8k.
```


**3\. Desert Motorcycle Reveal (Dynamic Reveal)**

```
A low-angle tracking shot races across golden desert dunes under a blazing midday sun. Dust trails behind a powerful black motorcycle as it crests a ridge. The camera pushes forward and rises as the rider — a woman in a black leather jacket and helmet — brings the bike to a controlled stop at the top of the dune. She removes her helmet, revealing short dark hair and a confident expression while the vast empty desert stretches behind her. Engine sound fades into dry wind. Cinematic, sharp detail, strong contrast, 8k masterpiece.
```


This new first one feels fresher, more sci-fi, and plays better to LTX-2.5’s strengths with fast motion, reflections, and strong atmospheric lighting. Want me to make it multi-shot or tweak anything else?

---

These three cover different strengths of the model: fluid action + physics, atmospheric mood + lighting, and dynamic camera + character reveal.

Run them, then tweak one element at a time (camera move, lighting, or a single action) and you’ll quickly feel how LTX-2.5 responds.