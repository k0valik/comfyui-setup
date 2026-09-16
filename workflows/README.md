# Munkafolyamat-könyvtár (workflows)

Ez a mappa tartalmazza az előre elkészített, tesztelt munkafolyamatokat.
Betöltés: SwarmUI `Comfy Workflow Editor` fül (vagy ComfyUI felület) — nyisd meg
a JSON-t, majd SwarmUI-ban kattints `Use This Workflow` gombra.

Mindet az ügynök (agent) is tudja futtatni és módosítani — kérd tőle magyarul.

## Video — MiniMax H3 (hanggal generál, 17 képkockás blokkok, 24 fps)

| Fájl | Mit tud | Amit te babrálhatsz |
|---|---|---|
| `video_minimax_h3_t2v.json` | szövegből videó (több snitt is) | prompt, hossz (mp), felbontás (max 768 rövid oldal), seed, turbo LoRA (4 vagy 8 lépés) |
| `video_minimax_h3_i2v.json` | képből videó | + kezdőkép |
| `video_minimax_h3_r2v.json` | referencia-alapú (karakter/térköp konzisztencia) | + referencia képek |

Modell-igény: a `models/` mappában lévő H3 csomag (int8 DiT + nvfp4 szövegértő +
2 VAE + turbo LoRA-k). Nincs rejtélyes extra — amit a workflow kér, az fent van.

## Video — LTX-2.5 (native többsnittes, szinkron hang, 8 lépéses distilled)

| Fájl | Mit tud | Amit te babrálhatsz |
|---|---|---|
| `video_ltx2_5_t2v.json` | szövegből videó (hivatalos sablon) | prompt, felbontás (32/64 osztó!), képkockák ((F-1)%8==0), seed |
| `video_ltx2_5_i2v.json` | képből videó (hivatalos sablon) | + kezdőkép |
| `LTX2.5-downloaded-workflow.json` | **kép + szöveg → videó, kettős léptékű (draft → upscale → finomítás), civitai-ról, valós generálásokkal igazolt** | felső szinten: prompt (JW mező), felbontás (16:9 selector), képkockák, LoadImage; a t2v/i2v ág közti váltás az rgthree „Fast Groups Bypasser" kapcsolókkal történik |

Fontos: a letöltött civitai workflow-ban **NINCS prompt-átíró LLM** (a hivatalos
sablonokban van egy bekapcsolt, ami átfirja a promptodat — itt nincs). A te
szöveged megy a modellbe. Az ügynök tudja ezt, és így együtt dolgoztok: az ügynök
írja a profi promptot, a gép azt használja fel módosítás nélkül.

⚠️ A civitai workflow 11,5 GB-os GGUF modellt kér (`LTX-2.5-Distilled-Q3_K_M.gguf`)
és 3 node-csomagot (rgthree, Easy-Use, GGUF). Ezeket az ügynök telepíti
(`scripts\Install-NodePacks.ps1` + modellletöltés) — kérdezd meg tőle.

## Video — YouTube-ról hozott LTX workflow-k (az ügynök állítja be őket)

Ezeket YouTube-videókból hoztuk, erősebbek az alapoknál — de az ügynöknek kell őket
az első használat előtt a gépedhez igazítania (modellek kicserélése, saját képeid
betétele). Csak szólj neki, hogy melyiket szeretnéd kipróbálni.

| Fájl | Mit tud | Amit te babrálhatsz |
|---|---|---|
| `LTX_2.5_FLF2V_8GB_NATIVE_AUDIO_NEGATIVE.json` | **kezdő- és záróképből videó** (megmondod, mivel kezdődjön és mivel végződjön) + **ki-bekapcsolható gyári hang**; 8 GB-os kártyára tesztelt beállítások | kezdőkép, zárókép, prompt, hang ki/be |
| `LTX2.5-director-2.0.json` | **rendezői mód**: idősáv-vezérlés (eleje–közepe–vége), többképes image-to-video, videó-folytatás és klip-hosszabbítás, szakaszonkénti promptok, folytonos hang | szegmens-prompteket, útmutató képek |
| `RTX-SR-upscaler-video.json` | **videó-felnagyítás** NVIDIA RTX-szuperfelbontással (egy kész videót tesz élesebbé/nagyobbá) | bemeneti videó |

Ezek plusz kiegészítőket kérhetnek (pl. Kijai-csomag, videós segédcsomag) és olyan
modellváltozatokat, amik nincsenek fent a gépeden — az ügynök mindent telepít és
átállít, csak kérdezd meg tőle. Az első beállítás pár perc, utána ugyanúgy működnek.

## Tippek a barátnak

- Az első generálás mindig lassabb (a modellnek be kell töltődnie).
- 8 GB-os kártyán: kisebb felbontás + rövidebb klipek (608x352 / 5 mp) a jó kiindulás.
- A kész videók a `tmp\ComfyUI\output` (illetve Swarm kimeneti) mappába kerülnek.
- Kérj bátran példákat az ügynöktől: „csinálj egy 10 mp-es klipet esős neon utcáról".
