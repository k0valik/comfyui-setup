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

⚠️ A civitai workflow 12,9 GB-os GGUF modellt kér (`LTX-2.5-Distilled-Q3_K_M.gguf`)
és 3 node-csomagot (rgthree, Easy-Use, GGUF). Ezeket az ügynök telepíti
(`scripts\Install-NodePacks.ps1` + modellletöltés) — kérdezd meg tőle.

## Tippek a barátnak

- Az első generálás mindig lassabb (a modellnek be kell töltődnie).
- 8 GB-os kártyán: kisebb felbontás + rövidebb klipek (608x352 / 5 mp) a jó kiindulás.
- A kész videók a `tmp\ComfyUI\output` (illetve Swarm kimeneti) mappába kerülnek.
- Kérj bátran példákat az ügynöktől: „csinálj egy 10 mp-es klipet esős neon utcáról".
