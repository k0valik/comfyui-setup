For anyone else with a similar setup, I am able to create a 0.2 MP (608x352 pixel) 5-second video in 1:35 (1 minute, 35 seconds). This is with 20 step Euler Simple, Spectrum and ComfyKitchenAttention with an image (generated locally with Krea2) as the first frame. I am running it on a laptop with a RTX4060 (8GB) and 16gb ram. I am using the latest version of ComfyUI windows portable, and the following startup flags: --disable-pinned-memory --lowvram --use-ck-attention. The attached video is an example I generated (0.2MP).

I can also create higher resolution videos with a similar generation time if I reduce the video duration (3 seconds for 0.3MP, or 2 seconds for 0.4MP).

I used kijai's models from here for the video models and video vae: https://huggingface.co/Kijai/MiniMax-H3-experimental/tree/main

I used a qwen3_vl_4b_int8_convrot for the clip. I can't remember if its this one that I use but this is one option: https://huggingface.co/Winnougan/Comfy-Qwen3-VL-INT8/tree/main

Here is some extra info regarding that clip: https://www.reddit.com/r/StableDiffusion/comments/1vkk500/minimax_h3_with_a_4b_or_8b_text_encoder_instead/

My workflows:

FL2V workflow Updated FL2V workflow

REF2V workflow Updated REF2V workflow

Updates: I've updated the workflow with some changes

    Added startup flag --use-ck-attention instead of using the node
    Switched from int8 convrot to int4 convrot for the clip (https://huggingface.co/Merserk/qwen3vl-4b-int4-convrot/tree/main)
    Added a "free memory (model)" node after the spectrum node generation. It seemed to help with subsequent generations that didn't always seem to clear the vram and resulted in slowdowns

With the changes I can create a 5 second 0.4 MP clip in roughly 3 minutes.