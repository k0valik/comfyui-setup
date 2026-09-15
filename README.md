# ComfyUI telepítési útmutató — teljesen kezdőknek (magyarul)

## A legröbb út: hagyd, hogy egy AI ügynök telepítse neked

Ha van Codex vagy Google Antigravity (Gemini) programod, NEM kell végig menned ezen
az útmutatón kézzel. Elég ennyi:

1. Telepítsd az ügynököt:
   - Google Antigravity: nyiss egy PowerShell ablakot (lásd 1. pont) és futtasd:
     ```powershell
     irm https://antigravity.google/cli/install.ps1 | iex
     ```
   - Codex (OpenAI): az aktuális hivatalos telepítési útmutatójuk szerint:
     `https://developers.openai.com/codex/` (szükség lehet Node.js-re is).
2. Töltsd le ezt a csomagot (a 6. pont szerint):
   ```powershell
   git clone https://github.com/k0valik/comfyui-setup.git comfyui-setup
   cd comfyui-setup
   ```
   (Ehhez kell a Git — ha nincs, a 2. pontból.)
3. Indítsd el az ügynököt ebben a mappában, és írd be neki, hogy:
   **„telepíts fel nekem mindent légyszíves"**
4. Az ügynök végigvisz mindenen: előfeltételek, ComfyUI, 86 GB videómodell,
   SwarmUI, munkafolyamatok. Csak akkor kell közbeszállítanod, ha kérdezi
   (pl. fiókgyártás, licencek elfogadása, néhány kattintás a böngészőben).

Ha nincs agentod, vagy inkább kézzel csinálnád, akkor olvass tovább —
az alábbi útmutató minden lépést leír. Az angol részletes változatok:
`runbook.md` (alap) és `runbook_2.md` (videómodellek).

---

> Ez az útmutató onnan indul, hogy **semmid sincs telepítve**, és odáig visz, hogy
> a böngésződben fut a ComfyUI kép- és videógeneráló felület.
> Csak másolnod kell a bekeretezett parancsokat a PowerShellbe, és megvárni, amíg lefutnak.
> Ha valami nem úgy néz ki, mint itt le van írva, **szólj az asszisztensednek (agentnek)** —
> ő végig tud segíteni. Ahol külön kérem, ott állj meg és jelezz neki.

Ez a `runbook.md` magyar, bőbeszédű változata. A technikai részletek angol runbookokban vannak.

---

## 0. Amire szükséged lesz

- Egy Windows 10 vagy Windows 11-es számítógép (NVIDIA videókártyával — pl. RTX 3060 vagy újabb).
- Internetkapcsolat (a letöltések nagyok: összesen kb. 90 GB).
- Kb. 100 GB szabad hely a lemezen.
- Kb. 1–2 óra idő (nagy része várakozás, amíg tölt le a gép).
- Semmilyen programozói tudás nem kell. Rendszergazdai jog sem kell.

---

## 1. PowerShell megnyitása (ezt fogod használni végig)

1. Kattints a **Start menüre** (a Windows ikon a tálcán bal oldalt lent).
2. Kezdd el gépelni: `PowerShell`
3. Kattints a találatra: **Windows PowerShell** (kék ikon).
4. Megnyílik egy sötétkék ablak, benne fehér szöveggel valami ilyesmi:
   `PS C:\Users\Neved>` — ez a parancssor. Ide fogod bemásolni a parancsokat.

> Fontos szokás: **minden telepítés után csukd be ezt az ablakot, és nyiss egy újat**
> (ugyanígy: Start → PowerShell). Különben a gép nem látja az újonnan telepített programokat.

Másolás beillesztés az ablakba: jelöld ki a parancsot itt, `Ctrl+C`, majd a PowerShell
ablakban kattints bele és nyomj `Ctrl+V`, végül `Enter`.

---

## 2. Git telepítése (ezzel töltjük le a leírásokat és a programokat)

1. A PowerShellbe másold be ezt, majd `Enter`:
   ```powershell
   winget install --id Git.Git -e --source winget
   ```
2. Végigmegy egy telepítő. Ha bármit kérdez, mehet az alapértelmezett (`Y` / `Enter`).
3. Ha a `winget` parancsot nem ismeri fel a gép (hibát ír), akkor kézzel:
   nyisd meg a böngészőben: `https://git-scm.com/download/win`
   töltsd le a 64-bites telepítőt, indítsd el, és végig kattints a `Next` gombokon.
4. **Csukd be a PowerShellt, nyiss újat** (lásd 1. pont).
5. Ellenőrzés — másold be, `Enter`:
   ```powershell
   git --version
   ```
   Ilyesmit kell látnod: `git version 2.53.0.windows.2` (a szám eltérhet). Ha ehelyett
   hibát ír (`not recognized`), szólj az agentnek.

---

## 3. Python telepítése (ebben fut majd a ComfyUI)

1. Új PowerShell ablakba másold be, majd `Enter`:
   ```powershell
   winget install --id Python.Python.3.13 -e --source winget
   ```
2. Ha a `winget` nem működik, kézzel: böngészőben `https://www.python.org/downloads/`
   → legfrissebb Python 3.13 letöltése → telepítő indítása →
   **az ELSŐ képernyőn pipáld be: „Add python.exe to PATH"** (ez a legfontosabb
   kattintás az egész útmutatóban — nélküle semmi nem fog működni!) → `Install Now`.
3. **Csukd be a PowerShellt, nyiss újat.**
4. Ellenőrzés:
   ```powershell
   python --version
   ```
   Ilyesmit kell látnod: `Python 3.13.x`. Ha hibát ír, szólj az agentnek
   (tartalék: próbáld meg azt, hogy `py --version`).

---

## 4. NVIDIA driver (videókártya meghajtó)

1. Böngészőben: `https://www.nvidia.com/drivers/` → válaszd ki a kártyádat
   (pl. GeForce RTX 4070) → Download → telepítés → **újraindítod a gépet**.
2. Újraindítás után, PowerShellben ellenőrzés:
   ```powershell
   nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv
   ```
   Látni fogod a kártyád nevét és a memória méretét. Ha hibát ír, a driver
   telepítés nem sikerült — szólj az agentnek.

---

## 5. Hozzáférés kérése az LTX videómodellhez (emberi kattintás kell!)

Az egyik videómodell (LTX-2.5) licencfeltételhez kötött — ezt csak te tudod elfogadni,
az agent nem kattinthat helyetted.

1. Ha nincs még, regisztrálj egy ingyenes fiókot: `https://huggingface.co/join`
   (e-mail + jelszó, pár perc).
2. Lépj be, majd nyisd meg: `https://huggingface.co/Lightricks/LTX-2.5`
3. Kattints az **„Agree and Access"** (Elfogadom) gombra. Ezzel elfogadod a
   közösségi licencet.
4. **Ha ez megvan, szólj az agentnek** („megvan a hozzáférés") — ő leellenőrzi,
   és csak utána indítja a nagy letöltést.

> Ha nincs HuggingFace fiókod vagy nem kéred a hozzáférést, a MiniMax modell
> akkor is működni fog — csak az LTX marad ki.

---

## 6. A beállító csomag letöltése (ez a repo)

1. PowerShellben menj oda, ahová tenni szeretnéd (pl. a Dokumentumok mappa).
   Példa — másold be, `Enter`:
   ```powershell
   cd $HOME\Documents
   ```
2. Töltsd le a csomagot:
   ```powershell
   git clone https://github.com/k0valik/comfyui-setup.git comfyui-setup
   ```
3. Lépj be a mappába:
   ```powershell
   cd comfyui-setup
   ```
4. Ha idáig eljutottál hiba nélkül, minden előfeltétel megvan.

---

## 7. Alaptelepítés — mit csinál az Install.ps1?

Másold be, `Enter` (a mappa gyökeréből, ahová az előbb beléptél):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Install.ps1
```

Ez kb. 10–20 percig dolgozik. Lépésről lépésre, amit látni fogsz:

1. **Előzetes ellenőrzés** — kiírja a Python és Git verzióját, és a videókártyádat.
   Ha itt valami hiányzik, a hibaüzenet megmondja, mit kell pótolni (2–4. pont).
2. **ComfyUI letöltése** — a program forráskódja a `tmp\ComfyUI` mappába kerül.
   (Ez a `tmp` mappa direkt nincs a verziókezelésben: több GB, és újratelepíthető.)
3. **Saját Python-környezet (venv)** — a ComfyUI kap egy elszigetelt környezetet
   (`tmp\ComfyUI\venv`). A géped többi Pythonja nem változik meg.
4. **PyTorch telepítése** — a videókártyához illő gyorsítócsomag (kb. 2 GB).
5. **ComfyUI függőségek** — minden segédcsomag.
6. **ComfyUI-Manager** — a bővítménykezelő (ezzel telepítesz majd extra csomópontokat
   a grafikus felületről).
7. **CUDA-ellenőrzés** — a végén ilyesmit kell látnod:
   `2.14.0+cu130 True NVIDIA GeForce RTX ...` — a `True` a lényeg: látja a kártyát.

Ha a végén azt írja, hogy kész (`Done`), mehetsz tovább. Ha piros hibaüzenet van,
másold ki az utolsó 20 sort és küldd el az agentnek.

---

## 8. Modellek letöltése — mit csinál a Download-Models.ps1?

Először a hozzáférési kulcs (csak az LTX miatt kell; az 5. pontban kérted meg a
hozzáférést, most a kulcsot adjuk oda a gépnek):

1. Böngészőben, belépve: `https://huggingface.co/settings/tokens`
2. Kattints: **Create new token** → adj neki nevet (pl. `comfyui`) → típusa
   `Read` (olvasás) → Create. Kimásolod a `hf_...` karaktersort.
3. PowerShellbe másold be így (a `hf_...` helyére a saját kulcsodat tedd!), `Enter`:
   ```powershell
   $env:HF_TOKEN="hf_IDE_JON_A_SAJAT_KULCSOD"
   ```
   (Nincs visszaigazolás — ez normális.)

Most indítsd a letöltést (ugyanabban az ablakban!):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Download-Models.ps1
```

Amit csinál, sorban:

1. Letölti a **MiniMax H3** csomagot (~46 GB): a videó-agy (tömörített `int8`
   változat — direkt a kis memóriájú kártyákhoz), a szövegértő (`nvfp4`
   tömörített), a videó- és hang-dekóderek, plusz a 4 és 8 lépéses „turbó"
   gyorsítók. Ezekkel 8 GB videómemóriával is elfut a generálás.
2. Letölti az **LTX-2.5** csomagot (~40 GB): a lepárolt, `int8` videó-agy
   (csak 8 lépés kell neki!), a tömörített szövegértő, a gyors konvolúciós VAE,
   a hang-VAE, a térbeli felskálázó (ez kell majd a videó felnagyításához) és az
   időtartam-fej.
3. Mindent a repo gyökerében lévő `models` mappába tesz (ez sincs verziókezelve —
   túl nagy). A mappaszerkezetet direkt úgy alakítja ki, ahogy a ComfyUI várja
   (`diffusion_models`, `text_encoders`, `vae`, `loras`, ...).
4. Legenerálja a `tmp\ComfyUI\extra_model_paths.yaml` fájlt, ami megmondja a
   ComfyUI-nak: „a modellek itt vannak". (Ez gépenként újragenerálódik, ezért
   nem tesszük verziókezelésbe.)
5. A végén kilistázza a letöltött fájlokat méretekkel — összesen kb. 86 GB.

Ez a leghosszabb lépés (gyors nettel is 15–40 perc). Ha megszakad (áramszünet,
netkimaradás), **csak futtasd újra ugyanazt a parancsot** — onnan folytatja,
ahol abbahagyta, nem kezdi elölről.

---

## 9. Indítás — mit csinálnak a Start fájlok?

Két egyforma lehetőség, válassz egyet:

- **A)** PowerShellben (a repo gyökeréből):
  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts\Start.ps1
  ```
- **B)** Dupla kattintás a `scripts\Start.bat` fájlon a Fájlkezelőben.

Mindkettő ugyanazt csinálja: elindítja a ComfyUI szervert a saját gépeden
(`127.0.0.1`, `8188`-as port), bekapcsolt Managerrel (`--enable-manager`).
Az ablakban meg kell jelennie: `To see the GUI go to: http://127.0.0.1:8188`
**Ezt az ablakot ne csukd be**, amíg használni szeretnéd — ez maga a program.

Most nyisd meg a böngészőt (Chrome / Edge / Firefox), és írd a címsorba:

```
http://127.0.0.1:8188
```

Megjelenik a ComfyUI: csomópontokból álló munkafelület (node canvas).
- Fent a **Manager** gomb: itt telepíthetsz extra csomópontokat és frissítéseket.
- A fogaskerék (Settings) → **Language**: a felület nyelve váltható
  (angol, német, francia, kínai, japán stb. — **magyar sajnos nincs** a csomagban,
  angol a legjobb választás).
- Generálás: állíts be egy munkafolyamatot (workflow), majd **Queue** gomb
  (vagy `Ctrl+Enter`). Az eredmény a `tmp\ComfyUI\output` mappába kerül.

> 8 GB-os (vagy kisebb) videókártya esetén így indítsd, hogy ne fogyjon el a memória:
> ```powershell
> powershell -ExecutionPolicy Bypass -File scripts\Start.ps1 --lowvram
> ```
> Ez lassabb, de belefér a kisebb kártyába (a RAM-ból pótolja).

---

## 10. Leállítás

1. Kattints vissza abba az ablakba, ahol a szerver fut.
2. Nyomj **Ctrl+C**-t. Ha kérdezi (`Terminate batch job (Y/N)?`), nyomj `Y`-t.
3. Csukd be az ablakot. Kész — legközelebb a 9. ponttól folytatod
   (telepíteni már nem kell semmit).

Ellenőrzés: frissítsd rá a `http://127.0.0.1:8188` oldalt — ha nem tölti be,
a szerver tényleg leállt.

---

## 11. Ha valami elromlik (hibaelhárítás)

| Amit látsz | Mit csinálj |
|---|---|
| `python: command not found` / `not recognized` | Csukd be az ÖSSZES PowerShell ablakot, nyiss újat. Ha még mindig: Python újratelepítés a PATH-pipával (3. pont) |
| `git: command not found` | Ugyanaz: új ablak; ha nem elég, Git újratelepítés (2. pont) |
| `Torch not compiled with CUDA enabled` | Másold ki a hibaüzenetet az agentnek — valószínűleg driver-frissítés kell (4. pont) |
| `8188`-as port foglalt | Indítsd másik porttal: a Start parancs végére írd oda: `--port 8189`, és a böngészőben is azt nyisd meg |
| Letöltés félbeszakadt | Futtasd újra ugyanazt a parancsot — folytatja |
| `Agree and Access` / 401-es hiba letöltéskor | Nincs (vagy lejárt a) hozzáférés: 5. pont + 8. pont eleje (HF_TOKEN) |
| Bármi más piros szöveg | Másold ki az utolsó ~20 sort, küldd el az agentnek |

---

## 12. Miben segít az agent (mikor szólj neki)

- Bármelyik ellenőrző parancs nem azt írja, mint itt → küldd el neki a kimenetet.
- Az 5. pontban a hozzáférés megadása után → szólj neki („megvan"), ő leellenőrzi.
- A 7–8. pont végén a záró sorok értelmezése → másold be neki, megerősíti.
- Új munkafolyamat (workflow) betöltése, első videó legenerálása → ő végigvezet.

*Karbantartás: frissítéskor `tmp\ComfyUI` mappában `git pull`, majd a venv-ben
`pip install -r requirements.txt` — vagy szólj az agentnek, megcsinálja.*
