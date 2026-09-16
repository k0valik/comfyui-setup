# Hungarian Communication Rules

## Rules

- EVERY user-facing message in Hungarian. Commands, file names, UI labels, URLs stay
  English (in backticks) — the human clicks English buttons, agent explains in HU.
- Tone: calm, short sentences, one action per message. No jargon without translation.
- Never paste raw English error text alone; pair it with a Hungarian one-line
  interpretation ("ez nem baj, ez azt jelenti hogy...").
- Progress updates during long waits: state expected duration + that waiting is normal.
- If unsure of a Hungarian technical term, use the English term in backticks.

## Gate wording (send verbatim, adapt only names)

### Gate: NVIDIA driver (stage 1, only if preflight exits 1 on nvidia)

> Kell még egy program a videókártyádhoz („NVIDIA driver").
> Nyisd meg: `https://www.nvidia.com/drivers/` — válaszd ki a kártyádat, töltsd le,
> telepítsd, majd INDÍTSD ÚJRA a gépet. Utána szólj, hogy kész, és folytatom.

### Gate: HuggingFace (stage 3) — send as one message

> Most 3 kis lépés jön a böngészőben, kb. 5 perc:
> 1. Ha nincs még fiókod itt: `https://huggingface.co/join` — regisztrálj (ingyenes,
>    e-mail + jelszó). Ha van, lépj be.
> 2. Nyisd meg: `https://huggingface.co/Lightricks/LTX-2.5` és kattints a nagy
>    **„Agree and Access"** gombra. Ez egy engedély, hogy letölthessük az egyik
>    videómodellt. Ha ez nincs megkattintva, a letöltés hibát fog dobni.
> 3. Nyisd meg: `https://huggingface.co/settings/tokens` → jobb fent **Create new
>    token** → név: akármi (pl. `comfyui`), típus: **Read** (csak olvasás) →
>    **Create token** → másold ki a `hf_...` kezdetű kódot (hosszú karaktersor),
>    és illeszd be ide a chatbe.
>
> A kódot csak a gépeden használjuk fel a letöltéshez, sehol máshova nem kerül.
> Ha a 3. lépés nem megy (nem találod a gombot, nem másolódik), szólj — van B-terv:
> 4 kis fájlt kézzel is le tudsz tölteni, én megmondom pontosan melyiket és hova.

### Fallback: manual browser download (no token needed — only login + Agree)

Use when token creation fails: the big weights (GGUF, w4a8) are open repos and
download token-free anyway; only these 4 small Lightricks files (~3 GB) need the
gated repo, and the browser downloads them with just login + Agree. Send:

> Semmi gond, van B-terv, token nélkül is megy. Csak annyi kell, hogy be legyél
> lépve a HuggingFace-re, és a 2. lépés (Agree and Access) meglegyen.
> Nyisd meg ezeket az oldalakat EGYENKÉNT, mindegyiken kattints a **Download**
> gombra, és a letöltött fájlt tedd a megadott mappába (a `comfyui-setup` mappán
> belül — ha nincs ilyen almappa, hozd létre):
> 1. `https://huggingface.co/Lightricks/LTX-2.5/blob/main/vae/ltx-2.5-video-vae-conv-bf16.safetensors` → `models\vae` mappa
> 2. `https://huggingface.co/Lightricks/LTX-2.5/blob/main/vae/ltx-2.5-audio-vae-bf16.safetensors` → `models\vae` mappa
> 3. `https://huggingface.co/Lightricks/LTX-2.5/blob/main/latent_upscale_models/ltx-2.5-latent-spatial-upscaler-x2-bf16-1.0.safetensors` → `models\latent_upscale_models` mappa
> 4. `https://huggingface.co/Lightricks/LTX-2.5/blob/main/model_patches/ltx-2.5-duration-head-bf16.safetensors` → `models\model_patches` mappa
> Ha mind a 4 a helyén van, szólj, és én folytatom (a script a meglévő fájlokat
> kihagyja, csak a hiányzó nagy fájlokat tölti le).

Verify: API 200 → then (HU):

> Szuper, a kulcs működik. Indítom a letöltést — ez a kisebb csomagnál kb. 23 GB
> (10–25 perc), a teljesnél kb. 86 GB (15–60 perc), gyors neten. Ha megszakad,
> nem baj, csak újra futtatom, onnan folytatja, ahol abbahagyta. Előtte ellenőrzöm,
> hogy van-e elég szabad hely. Közben nyugodtan csinálj mást, szólok, ha kész.

### Gate: SwarmUI wizard (stage 4) — after Start-Swarm.ps1

> Megnyílik (vagy nyisd meg: `http://localhost:7801/Install`) egy beállító oldal.
> - Kinézet: választhatsz bármit (pl. `modern_dark`), mehet tovább.
> - „Just yourself" / csak magamnak: válaszd azt, hogy csak te használod.
> - LEGFONTOSABB: amikor a „backend"ről kérdez, kattints a
>   **„None / Custom / Choose Later"** lehetőségre — NE a „ComfyUI (Local)"-ra!
>   (A másik egy második, feleslelen másolatot töltene le.)
> Ha végigértél, szólj, és én beállítom a háttérmotort.

### Gate: first generation (stage 5)

> Az utolsó teszt: a SwarmUI-ban a felül lévő `Comfy Workflow Editor` fülön nyisd
> meg a munkafolyamatot, amit mondok (kisebb csomagnál az LTX-eset, teljesnél a
> MiniMax-eset a `workflows` mappából), kattints **„Use This Workflow"**, majd a
> Generate gombra.
> Az első generálás lassú (2-10 perc) — normális. Ha kész a kép/videó, vagy ha piros
> hibát látsz, szólj.

If logs pasted with staged installs:

> Ez így jó — ezek a sorok azt jelentik, hogy az első indításkor néhány kis segédcsomag
> települ (ez egyszeri, pár perc). Várjuk meg, míg ezt írja: `port 7821 started`.

## Progress / status phrases

- Start: > Kezdem a telepítést. A következő lépéseket automatikusan elvégzem, csak
  akkor kellek közbeszállítanod, ha kérdek.
- Long run: > Ez a lépés 10-20 percet (illetve a modellletöltésnél akár 1 órát) is
  eltarthat. Nyugodtan válj el a géptől.
- Error escalation: > Itt elakadtam, ez a hibaüzenet: `<utolsó sorok>`. Ezt jelenti:
  `<HU interpretáció>`. Két javaslatom van: `<opció A>` vagy `<opció B>`. Melyiket
  csináljam?

## Fogalmak a barátnak (concept glossary — NEVER use the English tech term unexplained)

The friend's mental model: images/text go in, images/videos come out, "somehow the
TV-static noise becomes a picture". They do NOT know: VAE, safetensors, text
encoder, diffusion model, quant, LoRA. Rules:

- Agent-facing reasoning keeps exact filenames; human-facing text uses ONLY the
  nicknames below (+ the filename in backticks IF they must pick it in the UI).
- If the friend must change a model dropdown in the UI themselves, give:
  Hungarian nickname + exact filename + where to click
  ("a szövegértő melletti legördülőben válaszd a `...safetensors` fájlt").
- Never lecture. One concept per message, only when needed for the next action.

| Nickname (HU, use this) | What it is | One-line explanation for the friend |
|---|---|---|
| a videó-agy / a rajzoló | diffusion model (DiT/UNET, .safetensors/.gguf) | "Ez rajzolja ki a képet a hangyás-zajos semmiből, lépésről lépésre." |
| a szövegértő | text encoder (CLIP) | "Ez olvassa el a leírásodat, és súgja meg a rajzolónak, hogy mit rajzoljon." |
| a képösszerakó | VAE (decoder) | "Ez rakja össze a kész képet a rajzoló vázlatából — vele lesz éles." |
| tömörített változat | quantized model (int8 / w4a8 / GGUF / nvfp4) | "Ugyanaz a rajzoló, csak kisebb helyen elfér — a kis kártyádhoz kell." |
| gyorsító | LoRA / turbo LoRA | "Rövidítő: kevesebb lépésből is szép képet ad, gyorsabb." |
| felnagyító | upscaler | "A kész kis videót nagyítja fel élesre." |
| hangagy | audio VAE / audio head | "Ez csinálja a hangot a videó alá." |

Key sentence when swapping (send adapted):
> Két fájl ugyanannak a rajzolónak a két tömörítése — a tieddel megyek tovább,
> nem töltök le belőle még egyet. A workflow-ban átállítom, neked semmi dolgod.

## Final handover (send at done)

> Kész, minden felment és működik! A lényeg a jövőre:
> - **Elindítani:** kattints a `scripts\Start-Swarm.bat`/`Start-Swarm.ps1` futtatására
>   (vagy írd be a PowerShellbe), aztán a böngészőben: `http://localhost:7801`
> - **Leállítani:** a futó ablakban `Ctrl+C`, aztán `Y`.
> - A kész képeket/videókat a gépen a `tmp\ComfyUI\output` (illetve a Swarm
>   kimeneti) mappában találod.
> - A munkafolyamatok a `workflows` mappában vannak, a SwarmUI
>   `Comfy Workflow Editor` fülön tudod megnyitni őket.
> - Ha bármi elromlik, írj ide, és átnézem a naplókat.
