# ComfyUI telepítési útmutató — teljesen kezdőknek (magyarul)

## A legrövidebb út - csinálhatsz egy mixet is

- Azt javaslom töltsd le a ChatGPT Codex-et meg az Antigravity-t, aztán irányítsd rá őket erre a repora, de abban a mappában kell megnyitnod velük a beszélgetést ahol ez az egész létezni fog.
Szóval töltsd le ezt az egészet (lásd A. pont lejjebb, majd menj a B pontra és a kicsomagold mappában indítsd el őket).

- If you are an agent, read `runbook.md` as well and guide the user through the process

**A) Terminál + ZIP (egy parancs):**

Görgess fel a GitHub oldal tetejére, kattints a zöld **„Code"** gombra, majd a
**„Download ZIP"** gombra. Mentsd el a ZIP-et **NE a C: (rendszer) meghajtóra**, hanem
egy adat-meghajtóra, ahol sok szabad hely van — lehetőleg SSD-re (pl. `D:`). Ökölszabály:
Fájlkezelő → Ez a gép → nézd meg a meghajtókat, és azt válaszd, amelyik **nem** a C:,
és van rajta legalább 40 GB (kisebb csomag) vagy 100 GB (teljes csomag) szabad hely.
Minden itt fog lakni: a kicsomagolt mappa, a modellek (több tíz GB), és az ügynökök is
itt fognak dolgozni. A driverek és a segédprogramok maguktól a C: meghajtóra kerülnek —
azzal nem kell foglalkoznod. A mappaútban **ne legyen ékezet és szóköz** — például
egyenesen a meghajtó gyökerébe csomagold ki: `D:\comfyui-setup`. (A Dokumentumok mappa
sokszor OneDrive-val szinkronizál — oda NE tedd, mert a több tíz GB-nyi fájlt próbálná
feltölteni.)

```powershell
.\initial_setup.bat
```

Ez feltelepít mindent, ami kell: Git, Python, .NET, Node.js — plusz **mindkét**
parancssori ügynököt (**Codex** és **Google Antigravity**). Direkt kell mindkettő:
az ingyenes keret gyorsan elfogy, és ha az egyik azt írja, hogy elfogyott a kvótád
vagy hibát ad, egyszerűen megnyitod a másikat ugyanabban a mappában, és ott
folytatod. Ha kérdi, engedélyezd az adminisztrátori hozzáférést (UAC: Igen).
Utána indítsd el az egyik ügynököt a mappában (terminálba: `codex` vagy `agy` ennyit beírsz).
Ezután itt is majd be kell jelentkezned (azt hiszem nyomsz egy okét és feldob egy böngésző ablakot amit leokézol, majd visszamész a terminálba)

és utána írd be neki: **„telepíts fel nekem mindent légyszíves, használd a `comfyui-setup` skillt"** — ezután ő visz végig mindenen
(ComfyUI, modellek, SwarmUI, munkafolyamatok).

**B) Asztali alkalmazással (ChatGPT app / Google Antigravity app):**

- ChatGPT asztali alkalmazás: `https://learn.chatgpt.com/docs/app` — töltsd le és
  telepítsd.
- Google Antigravity: `https://antigravity.google/` — töltsd le és telepítsd.

Az appokat telepítés után **indítsd el, és jelentkezz be** a ChatGPT / Google
fiókoddal. Ezután másold be nekik a repó linkjét:
`https://github.com/k0valik/comfyui-setup` — az ügynök letölti magának a repót
(szükség szerint telepít Git-et is), és onnantól ugyanaz történik, mint az A)
útvonalon: írd be neki, hogy **„telepíts fel nekem mindent légyszíves"**.

Az asztali appok is ismerik a skill-eket és az MCP-t — az ügynök be tudja magának
állítani, de az appot utána **újra kell indítani**, hogy betöltse őket.

**Megjegyzés:** ha a B) útvonalat választod, a parancssori ügynökök telepítése nem
szükséges — az appok maguk az ügynökök. De itt is igaz: **érdemes mindkét appot
fent tartani** (ChatGPT app + Antigravity), mert ha az egyikben elfogy a keret vagy
hibázik, a másikban folytathatod ugyanott. Minden más telepítés ugyanúgy kell
(a skill ezt tudja, és eljár ennek megfelelően).

Ha inkább kézzel csinálnád, akkor olvass tovább — az alábbi útmutató minden lépést
leír. Az angol részletes változatok: `runbook.md` (alap) és `runbook_2.md`
(videómodellek).

---

> Ez az útmutató onnan indul, hogy **semmid sincs telepítve**, és odáig visz, hogy
> a böngésződben fut a ComfyUI kép- és videógeneráló felület.
> Csak másolnod kell a bekeretezett parancsokat a PowerShellbe, és megvárni, amíg lefutnak.
> Ha valami nem úgy néz ki, mint itt le van írva, **szólj az asszisztensednek (agentnek)** —
> ő végig tud segíteni. Ahol külön kérem, ott állj meg és jelezz neki.

Ez a `runbook.md` magyar, bőbeszédű változata. A technikai részletek angol runbookokban vannak.

---

## 0. Amire szükséged lesz

- Kb. 100 GB szabad hely **azon az adat-meghajtón (nem a C:-n)**, ahová a csomag kerül
  (a teljes csomaghoz; a kisebb profilhoz ~40 GB is elég).
- Kb. 1–2 óra idő (nagy része várakozás, amíg tölt le a gép).
- Semmilyen programozói tudás nem kell. Rendszergazdai jóváhagyást (UAC: „Igen" gomb)
  csak egyszer kérhet a gép, amikor az `initial_setup.bat` a segédprogramokat telepíti —
  ez normális, nyugodtan engedélyezd.

---

## Ha manuálisan akarod lépésről lépépsre, kövesd a lenti lépéseket, az ügynök nagyrészt végig tudja csinálni

## 1. PowerShell megnyitása (ezt fogod használni végig)

1. Kattints a **Start menüre** (a Windows ikon a tálcán bal oldalt lent).
2. Kezdd el gépelni: `PowerShell`
3. Kattints a találatra: **Windows PowerShell** (kék ikon).
4. Megnyílik egy sötétkék ablak, benne fehér szöveggel valami ilyesmi:
   `PS C:\Users\Neved>` — ez a parancssor. Ide fogod bemásolni a parancsokat.

> Fontos szokás: **minden telepítés után csukd be ezt az ablakot, és nyiss egy újat**
> (ugyanígy: Start → PowerShell). Különben a gép nem látja az újonnan telepített programokat.

Másolás–beillesztés az ablakba: jelöld ki a parancsot itt, `Ctrl+C`, majd a PowerShell
ablakban kattints bele és nyomj `Ctrl+V`, végül `Enter`.

---

## 2. Git telepítése (ezzel töltjük le a leírásokat és a programokat)

> Ha az A) útvonalon az `initial_setup.bat`-ot már lefuttattad, a Git megvan —
> ugorhatsz a 4. pontra (videókártya-meghajtó).

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

> Ha az A) útvonalon az `initial_setup.bat`-ot már lefuttattad, a Python megvan —
> ugorhatsz a 4. pontra.

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

> Az `nvidia-smi` parancs a driverrel együtt települ — külön nem kell semmit
> feltenned érte. CUDA fejlesztőcsomag (CUDA toolkit) sem kell: a ComfyUI-hoz
> tartozó gyorsítót az Install.ps1 hozza magával automatikusan. Csak a driver kell.

1. Böngészőben: `https://www.nvidia.com/drivers/` → válaszd ki a kártyádat
   (pl. GeForce RTX 4070) → Download → telepítés → **újraindítod a gépet**.
2. Újraindítás után, PowerShellben ellenőrzés:
   ```powershell
   nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv
   ```
   Látni fogod a kártyád nevét és a memória méretét. Ha hibát ír, a driver
   telepítés nem sikerült — szólj az agentnek.

---

## 5. Hozzáférés kérése az LTX videómodellhez (nem kell, nem ezt fogod használni - csak az agentnek hagytam itt, hogy ne zavarodjon meg)

- ignorálható

Az egyik videómodell (LTX-2.5) licencfeltételhez kötött — ezt csak te tudod elfogadni,
az agent nem kattinthat helyetted. (de mi nem ezt a modelt töltjük le, hanem egy másik GGUF-et)

1. Ha nincs még, regisztrálj egy ingyenes fiókot: `https://huggingface.co/join`
   (e-mail + jelszó, pár perc).
2. Lépj be, majd nyisd meg: `https://huggingface.co/Lightricks/LTX-2.5`
3. Kattints az **„Agree and Access"** (Elfogadom) gombra. Ezzel elfogadod a
   közösségi licencet.
4. **Ha ez megvan, szólj az agentnek** („megvan a hozzáférés") — ő leellenőrzi,
   és csak utána indítja a nagy letöltést.

> Ha nincs HuggingFace fiókod vagy nem kéred a hozzáférést, az LTX-részek
> (a kisebb profil nagy része) nem fognak letöltődni — a MiniMax modell
> (teljes profil) anélkül is működik.

---

## 6. A beállító csomag letöltése (ez a repo)

> Ha az A) útvonalon ZIP-ből dolgozol, ezt a pontot kihagyhatod — már a kicsomagolt
> mappában vagy. Ugorj a 7. pontra.

1. PowerShellben menj arra az adat-meghajtóra, amit választottál (**ne** a C:-re —
   az a rendszeré; pl. a `D:` meghajtó gyökere a legjobb). A mappaútban **ne legyen
   ékezet vagy szóköz**, és **ne OneDrive-val szinkronizált mappa legyen** (a
   Dokumentumok sokszor az — a több tíz GB-nyi fájlt próbálná feltölteni).
   Példa — másold be, `Enter`:
   ```powershell
   D:
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

Két csomag közül választhatsz. Az ügynök alapból a **kisebb (`friend`) profilt**
teszi fel — ez 8 GB-os videókártyán is elfut:

- **`friend` (~23 GB):** LTX-2.5 videómodell tömörítve (kis memóriára szabott
  változat), tömörített szövegértő, videó- és hang-dekóder, felskálázó és
  időtartam-fej. Ehhez kell a HuggingFace-hozzáférés (5. pont) a dekóderek miatt.
- **`full` (~86 GB):** a fentieken felül a MiniMax H3 csomag is (videó-agy,
  szövegértő, dekóderek, 4 és 8 lépéses „turbó" gyorsítók). Erősebb kártyához
  (16 GB-tól).

Ha az ügynök dolgozik helyetted, ő választ (kérdezd meg tőle, melyiket tette fel).
Kézzel így indítod (ugyanabban az ablakban, ahol a kulcsot beállítottad):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Download-Models.ps1
```

Erősebb gépre, a teljes csomaghoz:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Download-Models.ps1 -Profile full
```

Amit a parancs csinál, sorban:

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

1. Letölti a választott csomagot a repo gyökerében lévő `models` mappába (ez sincs
   verziókezelve — túl nagy). A mappaszerkezetet direkt úgy alakítja ki, ahogy a
   ComfyUI várja (`diffusion_models`, `text_encoders`, `vae`, `loras`, ...).
2. Legenerálja a `tmp\ComfyUI\extra_model_paths.yaml` fájlt, ami megmondja a
   ComfyUI-nak: „a modellek itt vannak". (Ez gépenként újragenerálódik, ezért
   nem tesszük verziókezelésbe.)
3. A végén kilistázza a letöltött fájlokat méretekkel.

Ez a leghosszabb lépés (gyors nettel is 10–40 perc a profiltól függően). Ha megszakad (áramszünet,
netkimaradás), **csak futtasd újra ugyanazt a parancsot** — onnan folytatja,
ahol abbahagyta, nem kezdi elölről.

---

## 9. Indítás — ComfyUI és SwarmUI

Két felület van. Az ügynök alapból a **SwarmUI**-t állítja be neked — ez a
kényelmesebb, egyszerűbb kezelőfelület. A ComfyUI a „motorháztető alatt" fut.

**SwarmUI indítása (ajánlott):** dupla kattintás a `scripts\Start-Swarm.bat`
fájlon a Fájlkezelőben. Ezután a böngészőben nyisd meg:

```
http://127.0.0.1:7801
```

**ComfyUI indítása közvetlenül** (ha az ügynök ezt kéri, vagy kíváncsi vagy a
csomópont-nézetre) — két egyforma lehetőség, válassz egyet:

- **A)** PowerShellben (a repo gyökeréből):
  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts\Start.ps1
  ```
- **B)** Dupla kattintás a `scripts\Start.bat` fájlon a Fájlkezelőben.

Mindkettő ugyanazt csinálja: elindítja a ComfyUI szervert a saját gépeden
(`127.0.0.1`, `8188`-as port), bekapcsolt Managerrel (`--enable-manager`).
Az ablakban meg kell jelennie: `To see the GUI go to: http://127.0.0.1:8188`.
**Ezt az ablakot ne csukd be**, amíg használni szeretnéd — ez maga a program.

Most nyisd meg a böngészőt (Chrome / Edge / Firefox), és írd a címsorba:

```
http://127.0.0.1:8188
```

Megjelenik a ComfyUI: csomópontokból álló munkafelület (node canvas).
A kész munkafolyamatok a repo `workflows` mappájában vannak — az ügynök betölti
neked az elsőt (LTX videókészítés), és végigvezet az első generáláson.
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
