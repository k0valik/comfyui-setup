---
title: "How to Run a Video Generation Model Locally: A Low VRAM Guide"
source: "https://ltx.io/blog/run-video-generation-model-locally"
author:
  - "[[LTX Team]]"
published: 2026-08-16
created: 2026-09-16
description: "Set up local AI video generation on consumer GPUs. Covers VRAM tiers, pipeline selection, FP8 quantization, and ComfyUI workflows."
tags:
  - "clippings"
---
Key Takeaways

- Local LTX-2.5 video generation requires CUDA 13.2+ and an Nvidia GPU with at least 32GB of VRAM, with the distilled checkpoint as the recommended starting point on anything below the A100 and H100 tier, thanks to its 8-step inference and lower memory footprint than the dev checkpoint.
- FP8 quantization (fp8-cast for broad GPU support, fp8-scaled-mm for Hopper) is the primary lever for reducing VRAM, cutting memory use by roughly 40%. Always set PYTORCH\_CUDA\_ALLOC\_CONF=expandable\_segments:True before any pipeline run.
- Use the incremental scaling approach: validate at minimum settings first, then increase resolution and frame count one step at a time to find the highest stable configuration for your hardware.

Running AI video generation locally gives you full control over your workflow, no API costs, and no rate limits. The trade-off is hardware: video generation models are memory-intensive, and running them requires navigating VRAM constraints, optimization settings, and the right pipeline choices.

This guide covers how to set up local AI video generation using LTX-2.5, an open source DiT-based model with multiple pipeline variants optimized for different hardware tiers. It focuses on getting the most out of a constrained GPU, including quantization options and the distilled model for faster, lighter inference.

## Prerequisites

### Hardware Requirements

[LTX-2.5](https://ltx.io/model/ltx-2-5) requires CUDA 13.2 or higher and targets Nvidia GPUs. The documented minimum is:

- **GPU:** Nvidia with 32GB+ VRAM
- **System RAM:** 32GB
- **Storage:** 100GB free
- **CUDA:** 13.2 or higher
- **Python:** 3.10 or higher

The recommended configuration is an A100 (80GB) or H100 with 64GB of system RAM and 200GB of SSD storage.

By tier:

- **80GB+ (A100, H100):** Run the dev checkpoint at full precision through the two-stage pipeline
- **32GB (RTX 5090 class):** Run the distilled checkpoint with FP8 quantization enabled, single IC-LoRA groups
- **Below 32GB:** Below the documented minimum. Some configurations may run at reduced resolution with aggressive memory optimization, but this is unsupported and you should expect to spend time on it

### Software Dependencies

LTX-2.5 requires CUDA 13.2+, Python 3.10+, and PyTorch 2.7, with uv for dependency management. Linux is the primary supported environment for the Python pipelines. ComfyUI users on Windows can use the portable install path documented in the ComfyUI setup guide.

## Installation

1. Clone the repository: `git clone https://github.com/Lightricks/LTX-2.git`
2. Set up the environment: `cd LTX-2 && uv sync --frozen && source .venv/bin/activate`
3. Set the memory environment variable before running any pipeline: `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`

Download model files from the LTX-2.5 HuggingFace repository. Required files depend on which pipeline you use:

- **Distilled checkpoint:** the fastest starting point, and the one to use on 32GB hardware
- **Dev checkpoint:** only if running the full model at higher quality
- **Gemma 4 text encoder:** required for all pipelines
- **Gemma 4 prompt enhancer:** optional, expands a short prompt before it is encoded
- **Video VAE and audio VAE:** LTX-2.5 decodes picture and sound through separate VAEs, so both are needed for generations with audio
- **Spatial upsampler:** required for two-stage pipeline outputs

## FP8 Quantization

FP8 quantization reduces the transformer's memory footprint by representing weights in 8-bit floating point, cutting VRAM usage by around 40% with minimal quality loss. LTX-2.5 supports two FP8 backends:

- **fp8-cast:** downcasts weights on load, upcasts during inference. Works on any GPU with FP8 support. Enable with `--quantization fp8-cast`
- **fp8-scaled-mm:** uses TensorRT-LLM scaled matrix multiplication for better performance on Hopper (H100) GPUs. Install with `uv sync --frozen --extra fp8-trtllm`

Enable via CLI:

`PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True python -m ltx_pipelines.ti2vid_two_stages --quantization fp8-cast --checkpoint-path /path/to/checkpoint.safetensors`

## ComfyUI Integration

For a visual, node-based workflow, LTX-2.5 ships with built-in ComfyUI templates. Click **Templates**, search for **LTX-2.5**, and pick Text-to-Video, Image-to-Video, or First-Frame/Last-Frame, then press **Download all** to fetch the model files. This is a lower-friction path than the CLI and no longer requires hunting down a plugin first.

The underlying nodes come from the ComfyUI-LTXVideo repository, which also bundles advanced workflows for IC-LoRA control and in/outpainting.

## LTX Desktop

[LTX Desktop](https://ltx.io/ltx-desktop) is a standalone GUI application for local AI video generation. It wraps the core LTX pipelines in a graphical interface, handling model management, pipeline configuration, and output organization without requiring command-line operation. For users who prefer a desktop application over CLI or ComfyUI, it provides the same generation capabilities with lower setup overhead.

## Incremental Scaling Approach for Constrained Hardware

When working with limited VRAM, start minimal and scale up rather than attempting full settings immediately:

**1\. Start minimal.** Begin with the distilled checkpoint at 512 pixels and 49 frames, with `--quantization fp8-cast` and the memory environment variable set. If this generates successfully, proceed.

**2\. Increase resolution.** Move up one step at a time, verifying stability at each level. Dimensions have to satisfy the model's constraints: width and height must be divisible by 64 for two-stage pipelines and by 32 for one-stage. That means working in valid steps such as 512, 576, 640, 704, 768 rather than jumping to a broadcast label like 720 or 1080, which are not divisible by either.

**3\. Increase frame count.** Once resolution is stable, work toward your target. Frame counts must satisfy `(F-1) % 8 == 0`, so valid values are 9, 17, 25, 33, 41, 49, 57, 65 and upward.

**4\. Add IC-LoRA.** If using IC-LoRA for pose, depth, or edge control, add one group at a time. Multiple simultaneous groups on lower-VRAM GPUs may cause OOM errors.

## Conclusion

Local video generation with LTX-2.5 is straightforward once the settings are right. Start with the distilled checkpoint, enable FP8 quantization, and use the incremental approach to find the highest stable configuration for your GPU. For a full breakdown of VRAM tiers and hardware recommendations, see the hardware guide.

If you click this button, Facebook will be able to track your visit to this site.