---
title: "LTX-2.5 in ComfyUI: The Hidden Prompt Rewriter That Poisoned Two Rounds of My Benchmark"
source: "https://askaillex.com/guides/ltx-2-5-comfyui-hidden-prompt-enhancer/"
author:
  - "[[Aillex / DIY AI]]"
published: 2026-08-14
created: 2026-09-16
description: "We benched LTX-2.5 for two full rounds and got confident, wrong answers, because the official templates ship an LLM prompt rewriter that is on by default and buried inside a subgraph. Here is how to find it, how to actually turn it off, and what the model does once your prompts reach it intact."
tags:
  - "clippings"
---
One of our early test renders asked for a presenter in a studio, seated, mid sentence. What came back was a bloodied stranger standing in a forest.

No error. No warning. The render completed normally and the file played fine. It just had nothing to do with what we typed.

That clip cost us about twenty minutes of GPU time, and it was the cheapest lesson of the whole exercise. The expensive one came later, when we found out the same problem had quietly invalidated two entire rounds of benchmarking and produced two headline conclusions that were both wrong.

## First, which LTX are we talking about

There are two products with confusingly similar names from the same company, and we have now had three separate people ask us about this in one month.

**LTX Studio** is a paid cloud product. **LTX Video** is the open weights model you download and run yourself, which is what this guide covers. LTX-2.5 is the current release of the open one. If you came here after seeing a subscription price, you were looking at the other thing.

Our production pipeline has been running the previous version, LTX-2.3, for months. That guide is [here](https://askaillex.com/guides/local-ai-video-with-ltx/) and everything in it still applies.

## The hidden enhancer

LTX-2.5’s official ComfyUI templates include a node called `TextGenerateLTX2Prompt`. It is an LLM that rewrites your prompt before the video model ever sees it. It ships **on**, and it lives inside a subgraph, so it is not visible on the main canvas unless you go looking.

For casual text to video this is arguably a feature. Vague prompts get expanded into something more detailed and the results look better. For anything where the prompt is the experiment, it is a disaster, because you are no longer testing what you think you are testing.

The symptom is the part worth memorising, because it does not look like a bug:

- Output that has no relationship to your prompt, with no error message
- Two different prompts producing near identical video
- Wildly inconsistent adherence between runs
- Renders taking 60 to 100 seconds longer than they should

A beginner hitting this reads it as their own failure at prompting. That is why we think it is the most useful thing we learned all week.

## Turning it off, and the trap inside the trap

Finding the node is the easy half. We flipped what looked like the off switch, watched our next renders come back still rewritten, and spent hours blaming everything else.

The template has a widget that toggles the LLM’s own decoding behaviour, and it sits right next to the control that actually matters. The real gate is a boolean feeding a switch node, and that boolean is what decides whether your text or the rewritten text becomes the conditioning. We had been confidently flipping the wrong one across every render in both rounds.

Two habits came out of this that we now apply to any node graph we do not fully understand:

**Verify what gets submitted, not what the interface shows.** Widget state is a claim about intent. The serialized graph that goes to the sampler is the fact. We ended up writing a check that reads the submitted prompt, inspects the switch selector, and refuses to run at all if it does not match what we asked for. It caught a real mismatch on its second use.

**Hash your outputs when something smells wrong.** Two renders from two different prompts that come back visually identical is a five second check with `ffmpeg -f hash`, and it would have caught this before any of it reached a decision. Also worth knowing: ComfyUI embeds the full graph in the mp4 it writes, so the output file is its own flight recorder. When results argue with your assumptions, read the graph out of the video rather than trusting your memory of the canvas.

## What the model actually does, once prompts arrive intact

Every finding below is from re-runs behind that verification gate. Two of them reverse conclusions we had already written down and would have published.

**Prompt scripted hard cuts work.** We had concluded, across six probes, that LTX-2.5 could not produce cuts, and that a multi shot prompt would render as one continuous camera move through the requested framings. That was the enhancer flattening our shot lists before the model saw them. Raw, an eight second prompt asking for three shots produced all three, with true single frame cuts. Twelve seconds and four shots also landed, the model self pacing the cuts at roughly three second intervals. Being able to script an edit inside one generation is a real capability, and we had written it off.

**Heavy physics land without wrecking the scene.** Rain visibly soaks the subject. Wind actually strews the papers on the desk. Identity and set survive it. The older version would obey a physics instruction by degrading everything around it, so this is straightforwardly better rather than differently broken.

**Short scripted dialogue is intelligible.** Our first verdict on generated speech was “gibberish”, recorded before we knew about the enhancer, which had been mangling quoted dialogue on the way in. Re-run raw, with the lines in quotes, it is understandable. We still drive our own talking footage from recorded voiceover rather than generated speech, because a cloned voice we control beats a generated one we do not, but the model is not the problem we said it was.

## The audio finding that sounds like a contradiction

LTX-2.5 generates an audio track alongside the video. Two things are true about it that appear to conflict.

The audio does not stitch. Cut four generated clips together, keep each clip’s own audio, and you get four sound worlds fighting each other. Room tone shifts at every boundary and the result is unusable without replacing the whole bed.

The audio is also a genuinely useful sound library. Generate one clip specifically to harvest its sound, keep the audio, throw the picture away, and you have local ambience and foley in about a minute per clip. Rain, room tone, a crowd.

The difference is intent, not the feature. Multiple clips means multiple worlds, which is incoherent by construction. One clip is one world, which is coherent by definition. For us this is the only thing in the entire benchmark that gave us a capability we did not previously have in some form, and it came from the part of the model we were not testing.

## What it costs on a consumer card

Numbers from a single RTX 5090, with the enhancer off, warm model.

- Five second clip at 1280x704 with audio: roughly 40 to 60 seconds
- Twelve second clip: about 340 seconds
- Twenty seconds: hard CUDA out of memory, every attempt

Duration scales worse than linearly, so short clips are where the economics live. Twelve seconds is the practical ceiling on this card and twenty is simply out of reach. Compared against our production 2.3 setup, which renders 832x480 silent in 143 seconds, the newer model lands at roughly per pixel parity while adding a soundtrack. It is not slower for what you get. It is bigger for what you get.

We deliberately do not quote peak VRAM figures here. We watched them live during the run and never wrote them to a file, and a number we cannot open is not a number we will publish. That is the honest version.

## Three setup gates that will bite you

1. **ComfyUI 0.32.0 or newer.** LTX-2.5 will not run on older releases.
2. **Pin kornia to 0.7.3.** Version 0.8.3 breaks the LTX video node pack import outright.
3. **Your old LTX graphs will not run.** Graphs built for the 2.3 era fail against the 2.5 node pack with a latent shape mismatch, because the sampler API changed. Migration means rebuilding your graphs on the new templates. It is not a version bump.

That third one is why we ran the whole benchmark in an isolated second ComfyUI install on a different port, with the model folders shared by junction so nothing was duplicated on disk. Production kept rendering the entire time and never noticed. If you have a pipeline that people depend on, do not upgrade it to evaluate something. Stand up a sandbox beside it.

## Our verdict: we are not migrating

Production stays on LTX-2.3. The upgrade cost is real, it means rebuilding every graph and pinning new dependencies, and our current setup is tuned and working. Nothing in the benchmark was worth breaking that this week.

The sandbox stays alive as a capability tier with four standing jobs: prompt scripted cuts, action and physics shots, short scripted dialogue, and ambience harvesting. That is a fair description of where the newer model earns its keep for us right now.

## What we did not test

Our findings come from the distilled int8 model, using the shipped ComfyUI templates. We did not test the full precision development weights, we did not test the standalone Python pipeline, and we did not get to 4K. Any of those could change the picture, particularly on the shot control question. We would rather say that than let a narrow test read as a broad conclusion.

One last thing worth saying plainly. After we finished, we went back and found a community write up that mentions, in a single sentence, that prompt enhance is on by default. Reading it first would have saved us a chunk of GPU time and one wrong verdict. It would not have told us about the dependency pins or the graph incompatibility, which needed hands on the machine. Both kinds of source matter, and we now sweep community write ups before starting a bench rather than after.

*More from the Engine Room: [animating images locally](https://askaillex.com/guides/comfyui-video-basics/), [our LTX-2.3 workhorse](https://askaillex.com/guides/local-ai-video-with-ltx/), and [the Wan 2.2 bench](https://askaillex.com/guides/wan-2-2-local-video/). If your card cannot hold a video model, [renting one by the hour](https://askaillex.com/can-i-run-it/) is covered in the calculator.*