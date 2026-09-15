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
> 3. Nyisd meg: `https://huggingface.co/settings/tokens` → **Create new token** →
>    név: akármi (pl. `comfyui`), típus: **Read** → Create → másold ki a
>    `hf_...` kezdetű kódot, és illeszd be ide a chatbe.
>
> A kódot csak gépeden használjuk fel a letöltéshez, sehol máshova nem kerül.

Verify: API 200 → then (HU):

> Szuper, a kulcs működik. Indítom a letöltést — ez kb. 86 GB, gyors neten 15-40
> perc. Ha megszakad, nem baj, csak újra futtatom, onnan folytatja, ahol abbahagyta.
> Közben nyugodtan csinálj mást, szólok, ha kész.

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
> meg az egyik munkafolyamatot (pl. `video_minimax_h3_t2v.json` a `workflows`
> mappából), kattints **„Use This Workflow"**, majd a Generate gombra.
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
