# 📐 Maths Helper (`mth` & `slv`)

> **Excel-style calculator & equation solver for Terminal & PowerShell**
> คิดเลขสไตล์ Excel + แก้สมการแบบไม่ต้องย้ายข้าง ติดตั้งบรรทัดเดียว

[🇹🇭 ภาษาไทย](#-ภาษาไทย) | [🇬🇧 English](#-english)

---

## 🇹🇭 ภาษาไทย

### เหมาะกับใคร? ใช้ยากไหม? (อ่านก่อน 30 วินาที)

**เหมาะกับ:**
- คนทำงานช่าง / โยธา / สำรวจ / บัญชี ที่คุ้นสูตร Excel (`SUM, AVG, IF, SQRT, POW`) อยู่แล้ว
- คนเขียน Bash script แล้วเบื่อ `awk` / `bc` เพราะสูตรซ้อนๆ อ่านไม่ออก + ต้องย้ายข้างสมการเอง

**พูดตรงๆ สำหรับ Non-IT:**
- ถ้าไม่เคยเปิด Terminal/PowerShell มาก่อน จะติดด่านแรก ไม่ใช่เพราะสูตรยาก แต่เพราะต้องเปิด terminal, วางคำสั่งติดตั้ง, ปิด-เปิด terminal ใหม่
- `mth` ง่ายกว่า `slv` มาก แนะนำให้เริ่มแค่ `mth` 5 คำสั่งแรกก่อน ถ้าใช้คล่องแล้วค่อยไป `slv`
- ถ้าใช้ Excel คล่องอยู่แล้วและไม่ได้อยู่หน้า Terminal ทุกวัน Excel ยังเร็วกว่า เครื่องมือนี้ชนะตอนที่ (1) อยู่หน้า Terminal อยู่แล้ว (2) เอาไปฝังใน script

### ⚡ ติดตั้ง 1 บรรทัด

#### 🪟 Windows (PowerShell)
เปิด **PowerShell** แล้ววาง:
```powershell
irm https://raw.githubusercontent.com/civenz-035/maths-helper/main/install.ps1 | iex
```

#### 🐧 🍎 Linux / macOS / WSL / Git Bash / Termux (Bash/Zsh)
เปิด **Terminal** แล้ววาง:
```bash
curl -fsSL https://raw.githubusercontent.com/civenz-035/maths-helper/main/install.sh | bash
```

> ติดตั้งเสร็จต้อง **ปิดแล้วเปิด terminal ใหม่ 1 ครั้ง** แล้วค่อยพิมพ์ `mth` / `slv` ถ้าขึ้น `command not found` 99% คือลืมข้อนี้ ไม่ต้องลงใหม่

ทดลองว่าใช้ได้แล้ว:
```bash
mth 10/3
mth "sqrt(3^2 + 4^2)"
slv "2x + 10 = 30"
```

---

### 🎯 1. `mth` — เครื่องคิดเลขสไตล์ Excel
*(พิมพ์ `calc` หรือ `math` แทนก็ได้ — คำสั่งเดียวกัน)*

| อยากทำ | ตัวอย่าง copy ได้เลย | ผลลัพธ์ | หมายเหตุ |
| :--- | :--- | :--- | :--- |
| หารทั่วไป | `mth 10/3` | `3.33` | ดีฟอลต์ทศนิยม 2 ตำแหน่ง |
| พีทาโกรัส | `mth "sqrt(3^2 + 4^2)"` | `5.00` | ใช้ `^` แทนยกกำลัง |
| ผลรวม | `mth "SUM(10, 20, 30)"` | `60` | เหมือน Excel |
| ค่าเฉลี่ย | `mth "AVG(10, 20, 30)"` | `20.00` | เหมือน Excel |
| น้ำหนักเหล็ก DB16 (กก./ม.) | `mth "pi() * (0.016/2)^2 * 7850"` | `1.58` | ตัวอย่างงานโยธา |
| เอาทศนิยม 4 ตำแหน่ง | `mth 10/3 4` | `3.3333` | เลขท้าย = จำนวนทศนิยม |
| ปัดขึ้นเสมอ | `mth 10/3 0 u` | `4` | `u` = roundup |
| ปัดลงเสมอ | `mth 10/3 0 d` | `3` | `d` = rounddown |
| เงื่อนไข | `mth 'if(100 > 50, "PASS", "FAIL")'` | `PASS` | เหมือน `IF` ใน Excel |
| sin 30 องศา (แนะนำ) | `mth "sind(30)"` | `0.50` | ปลอดภัยสำหรับคนทั่วไป |
| sin แบบพิมพ์องศาตรงๆ | `mth "sin(30deg)"` | `0.50` | หรือ `sin(30°)` ก็ได้ |

#### ⚠️ 3 กับดักที่ Non-IT เจอบ่อยที่สุด

1. **ลืมใส่ `" "`** — ถ้าสูตรมีช่องว่างหรือวงเล็บ ต้องครอบด้วย `" "` เสมอ
   ```bash
   # ผิดบ่อย / ถูก
   mth sqrt(3^2 + 4^2)      # shell แตกวงเล็บ
   mth "sqrt(3^2 + 4^2)"    # ถูก
   ```
   บน PowerShell ถ้า `" "` มีปัญหาให้ลองสลับเป็น `' '`

2. **`sin(30)` ได้ค่าผิด?** — ไม่ผิด แต่ `sin/cos/tan` ธรรมดารับหน่วย **radian** ถ้าจะคิดเป็นองศาต้องใช้ `sind/cosd/tand` หรือ `sin(30deg)` โปรแกรมจะเตือนสีเหลืองให้ถ้าพิมพ์มุมใหญ่ๆ เข้ามา

3. **ปัดเศษไม่เหมือน Excel?** — ดีฟอลต์คือ `round` แบบ Excel (ปัด 0.5 ขึ้น) ถ้าต้องการเบิกของเผื่อขาดให้เติม `u` ถ้าต้องการตัดเศษทิ้งให้เติม `d` ต่อท้าย

พิมพ์เปล่าๆ เพื่อดูวิธีใช้ก็ได้:
```bash
mth
```

---

### 🎯 2. `slv` — แก้สมการแบบไม่ต้องย้ายข้าง
*(พิมพ์ `solve` แทนก็ได้ — คำสั่งเดียวกัน)*

```bash
# 1. สมการเส้นตรงตัวแปรเดียว
slv "2x + 10 = 30"
# x = 10

# 2. มี 2 ตัวแปร รู้ค่า 1 ตัว
slv "x = 2x + y" "y = 2"
# x = -2, y = 2

# 3. คุมทศนิยมเหมือน mth
slv "x = 10/3" 4
# x = 3.3333

slv "x = 10/3" 20 d
# x = 3.33333333333333333333

# 4. ตรีโกณแบบองศา เติม --deg (ถ้าไม่เติม = radian)
slv --deg "h = a * sin(b)" "a = 10" "b = 30"
# h = 5  (sin 30° = 0.5)

# 5. งานคาน: รู้ผลรวมกับ Ra หา Rb
slv "Ra + Rb = 100" "Ra = 40"
# Rb = 60

# 6. พีทาโกรัสหาด้าน c
slv "a^2 + b^2 = c^2" "a = 3" "b = 4"
# c = 5
```

> `slv` ต้องใช้ **Python 3 + sympy** ตัว installer จะลงให้อัตโนมัติ ถ้าลงไม่ได้ให้รันเอง: `pip install sympy` บน Windows ถ้ายังไม่มี Python ให้ลงก่อน: `winget install Python.Python.3.11` แล้ว `mth` จะใช้สูตร Excel เต็มๆ ได้ด้วย ไม่งั้นจะเหลือแค่บวกลบคูณหารพื้นฐาน

พิมพ์เปล่าๆ เพื่อดูวิธีใช้:
```bash
slv
```

---

### 🤖 3. ใช้ใน Bash Script (ทำไมต้อง `slv -q`?)

ปกติคนเขียน script คิดเลขทศนิยมใช้กันอยู่ 3 ตัวนี้:

| เครื่องมือ | ตัวอย่าง | ข้อดี | ข้อจำกัด |
| :--- | :--- | :--- | :--- |
| `bc -l` | `echo "scale=8; 100/3" \| bc -l` | มีทุกเครื่อง มาตรฐาน | แก้สมการไม่เป็น ต้องย้ายข้างเองก่อน, คุมปัดขึ้น/ลงยาก |
| `awk` | `awk "BEGIN{printf \"%.8f\", 100/3}"` | เร็ว ไม่ต้องลงเพิ่ม | สูตรซ้อนๆ อ่านยาก, precision เป็น double (~15 หลักจริง เช่น `10/3` ได้ `3.33333333333333348136`), ต้องย้ายข้างเอง |
| `python3 -c` | `python3 -c "print(f'{(100/3):.8f}')"` | เป๊ะ ยืดหยุ่นสุด | เขียนยาว ต้อง escape quote ใน bash วุ่นวาย |

ปัญหาคือทั้ง 3 ตัว **คิดได้อย่างเดียว** สมมติสมการจริงคือ `base/bal = (m-1)/(m^n-1)` คุณต้องนั่งย้ายข้างหา `base` เองก่อนเอาเข้า script พอย้ายผิด script ก็ผิด

`slv` เขียนสมการตามกระดาษได้เลย แล้วเติม `-q` (หรือ `--raw`) เพื่อให้เหลือแต่ตัวเลขดิบ ไม่มีสี เอาไปใส่ `$()` ได้ทันที:

```bash
# แบบเดิมด้วย bc: ต้องย้ายข้างเอง
# base = bal*(m-1)/(m^n-1)  <- ต้องคิดเองก่อน
current_=$(echo "scale=8; 100*(2-1)/(2^5-1)" | bc -l)

# แบบ slv: วางสมการดิบได้เลย + คุมทศนิยม 8 ตำแหน่งปัดลง
current_=$(slv -q "base/bal=(m-1)/(m^n-1)" bal=100 m=2 n=5 8 d)
echo "$current_"
# 3.22580645
```

ออปชันที่ใช้ใน script บ่อย:
```bash
slv -q "F=m*a" "m=10" "a=9.8"
# 98  (เลขล้วน ไม่มีสี)

slv -q "x = 10/3" 4
# 3.3333

slv --deg -q "h=a*sin(b)" a=10 b=30
# 5
```

**ข้อควรระวังตามตรง:** `slv` บูต `sympy` ทุกครั้งที่เรียก (~0.3-0.8 วิ) ช้ากว่า `bc/awk` ที่ตอบทันที เหมาะกับ **คำนวณ 1-2 ครั้งตอนต้น script เพื่อหาค่า parameter** ไม่เหมาะกับเอาไปวนลูปหมื่นรอบ ถ้าอยู่ในลูปให้คำนวณข้างนอกครั้งเดียวแล้วส่งค่าเข้าไป

---

### 🛠️ Requirements

- **`mth`**: Linux/macOS/WSL/Git Bash ใช้แค่ `awk` + `bash` (ไม่ต้องลงเพิ่ม) / Windows PowerShell แนะนำให้มี Python 3 ถึงจะได้สูตร Excel ครบ
- **`slv`**: ต้องมี **Python 3 + sympy** (installer ลงให้อัตโนมัติ)

### 🗑️ Uninstall

- **Linux / macOS / WSL / Git Bash:**
  ```bash
  rm -rf ~/.maths-helper ~/.local/bin/mth ~/.local/bin/slv ~/.local/bin/calc ~/.local/bin/solve
  ```
  *(แล้วลบบรรทัด `maths-helper` ใน `~/.bashrc` หรือ `~/.zshrc`)*

- **Windows PowerShell:**
  ```powershell
  Remove-Item -Recurse -Force "$HOME\.maths-helper"
  ```
  *(แล้วลบบรรทัด `maths-helper` ใน `$PROFILE`)*

---

## 🇬🇧 English

### Who is this for? Is it hard? (30-second read)

**Good for:**
- Engineers / site / survey / accounting users who already know Excel formulas (`SUM, AVG, IF, SQRT, POW`)
- Bash scripters tired of painful `awk` / `bc` one-liners and manual equation rearranging

**Honest note for non-IT users:**
- If you have never opened a Terminal/PowerShell, the first barrier is the terminal itself, not the math. You need to paste one install line, then close and reopen the terminal once.
- `mth` is much easier than `slv`. Start with 5 `mth` commands first. Move to `slv` only when you really solve equations.
- If you already live in Excel and rarely touch a terminal, Excel is still faster. This tool wins when (1) you are already in a terminal or (2) you embed calculations in scripts.

### ⚡ 1-Line Installation

#### 🪟 Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/civenz-035/maths-helper/main/install.ps1 | iex
```

#### 🐧 🍎 Linux / macOS / WSL / Git Bash / Termux (Bash/Zsh)
```bash
curl -fsSL https://raw.githubusercontent.com/civenz-035/maths-helper/main/install.sh | bash
```

> After install, **close and reopen your terminal once**. `command not found` almost always means you skipped this step. No need to reinstall.

Verify:
```bash
mth 10/3
mth "sqrt(3^2 + 4^2)"
slv "2x + 10 = 30"
```

---

### 🎯 1. `mth` — Excel-Style Expression Evaluator
*(Aliases: `calc`, `math` — same command)*

| Goal | Copy-paste example | Output | Note |
| :--- | :--- | :--- | :--- |
| Division | `mth 10/3` | `3.33` | Default 2 decimals |
| Pythagoras | `mth "sqrt(3^2 + 4^2)"` | `5.00` | `^` = power |
| Sum | `mth "SUM(10, 20, 30)"` | `60` | Excel-like |
| Average | `mth "AVG(10, 20, 30)"` | `20.00` | Excel-like |
| Rebar weight DB16 (kg/m) | `mth "pi() * (0.016/2)^2 * 7850"` | `1.58` | Civil example |
| 4 decimals | `mth 10/3 4` | `3.3333` | Trailing number = decimals |
| Round up | `mth 10/3 0 u` | `4` | `u` = roundup |
| Round down | `mth 10/3 0 d` | `3` | `d` = rounddown |
| Condition | `mth 'if(100 > 50, "PASS", "FAIL")'` | `PASS` | Excel `IF` |
| sin 30 degrees (recommended) | `mth "sind(30)"` | `0.50` | Safe for non-IT |
| Degree suffix | `mth "sin(30deg)"` | `0.50` | `sin(30°)` also works |

#### 3 common pitfalls

1. **Missing quotes** — always wrap expressions with spaces/parens in `" "`:
   ```bash
   mth sqrt(3^2 + 4^2)      # broken: shell splits parens
   mth "sqrt(3^2 + 4^2)"    # correct
   ```
   On PowerShell try `' '` if `" "` misbehaves.

2. **`sin(30)` looks wrong?** — `sin/cos/tan` use **radians**. For degrees use `sind/cosd/tand` or `sin(30deg)`. The tool prints a yellow hint when the angle looks like degrees.

3. **Rounding** — default is Excel-style half-up. Append `u` to always round up (ordering extra material), `d` to truncate.

Run bare `mth` to see help:
```bash
mth
```

---

### 🎯 2. `slv` — Algebraic Equation Solver
*(Alias: `solve` — same command)*

```bash
# 1. Single variable
slv "2x + 10 = 30"
# x = 10

# 2. Two variables, one known
slv "x = 2x + y" "y = 2"
# x = -2, y = 2

# 3. Decimal control (same as mth)
slv "x = 10/3" 4
# x = 3.3333

slv "x = 10/3" 20 d
# x = 3.33333333333333333333

# 4. Degrees with --deg (default is radians)
slv --deg "h = a * sin(b)" "a = 10" "b = 30"
# h = 5

# 5. Beam reaction
slv "Ra + Rb = 100" "Ra = 40"
# Rb = 60

# 6. Pythagoras for c
slv "a^2 + b^2 = c^2" "a = 3" "b = 4"
# c = 5
```

> `slv` requires **Python 3 + sympy**. The installer tries to install it automatically. Manual fallback: `pip install sympy`. On Windows without Python, install first: `winget install Python.Python.3.11`. Without Python, `mth` falls back to basic arithmetic only.

Run bare `slv` to see help:
```bash
slv
```

---

### 🤖 3. Use in Bash Scripts (why `slv -q`?)

What scripters normally use for precise decimals:

| Tool | Example | Strength | Limitation |
| :--- | :--- | :--- | :--- |
| `bc -l` | `echo "scale=8; 100/3" \| bc -l` | Everywhere, standard | Evaluation only, you must rearrange the equation manually, hard to control up/down rounding |
| `awk` | `awk "BEGIN{printf \"%.8f\", 100/3}"` | Fast, no install | Messy for nested formulas, double precision only (~15 real digits, e.g. `10/3` = `3.33333333333333348136`), manual rearranging |
| `python3 -c` | `python3 -c "print(f'{(100/3):.8f}')"` | Most precise/flexible | Verbose, quote-escaping pain in bash |

None of them solves equations. If the real equation is `base/bal = (m-1)/(m^n-1)`, you must rearrange for `base` by hand before putting it in a script. One algebra mistake = wrong script.

`slv` accepts the equation as-written. Add `-q` (or `--raw`) for plain numeric output with no ANSI colors, ready for `$()`:

```bash
# Old way with bc: rearrange by hand first
# base = bal*(m-1)/(m^n-1)  <- you do this step
current_=$(echo "scale=8; 100*(2-1)/(2^5-1)" | bc -l)

# With slv: paste the raw equation + 8 decimals round-down
current_=$(slv -q "base/bal=(m-1)/(m^n-1)" bal=100 m=2 n=5 8 d)
echo "$current_"
# 3.22580645
```

Handy script options:
```bash
slv -q "F=m*a" "m=10" "a=9.8"
# 98 (pure number)

slv -q "x = 10/3" 4
# 3.3333

slv --deg -q "h=a*sin(b)" a=10 b=30
# 5
```

**Honest trade-off:** `slv` boots `sympy` on every call (~0.3-0.8s), slower than instant `bc/awk`. Best for **1-2 calculations at the start of a script to derive parameters**, not for 10k-iteration hot loops. Compute once outside the loop and pass the value in.

---

### 🛠️ Requirements

- **`mth`**: Linux/macOS/WSL/Git Bash needs only `awk` + `bash` (zero deps) / Windows PowerShell works best with Python 3 for full Excel functions
- **`slv`**: Requires **Python 3 + sympy** (auto-installed by installer)

### 🗑️ Uninstall

- **Linux / macOS / WSL / Git Bash:**
  ```bash
  rm -rf ~/.maths-helper ~/.local/bin/mth ~/.local/bin/slv ~/.local/bin/calc ~/.local/bin/solve
  ```
  *(Then remove the `maths-helper` line from `~/.bashrc` or `~/.zshrc`)*

- **Windows PowerShell:**
  ```powershell
  Remove-Item -Recurse -Force "$HOME\.maths-helper"
  ```
  *(Then remove the `maths-helper` line from `$PROFILE`)*

---

## 📄 License
MIT License © 2026 civenz-035
