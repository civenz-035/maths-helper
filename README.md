# 📐 Maths Helper (`mth` & `slv`)

> **Excel-style calculation & algebraic equation solver for Terminal & PowerShell**  
> ใช้ง่าย ติดตั้งในบรรทัดเดียว ไม่ต้องพึ่งพาระบบใดๆ (Standalone 100%)

[🇹🇭 ภาษาไทย](#-ภาษาไทย) | [🇬🇧 English](#-english)

---

## 🇹🇭 ภาษาไทย

### ⚡ ติดตั้งง่ายใน 1 บรรทัด (One-Liner Install)

#### 🪟 สำหรับผู้ใช้ Windows (PowerShell)
เปิด **PowerShell** หรือ **Windows Terminal** แล้ววางคำสั่งนี้:
```powershell
irm https://raw.githubusercontent.com/joece035/maths-helper/main/install.ps1 | iex
```

#### 🐧 🍎 สำหรับ Linux / macOS / WSL / Git Bash / Termux (Bash/Zsh)
เปิด **Terminal** แล้ววางคำสั่งนี้:
```bash
curl -fsSL https://raw.githubusercontent.com/joece035/maths-helper/main/install.sh | bash
```

> **คำแนะนำ:** เมื่อติดตั้งเสร็จ จะต้องปิดแล้วเปิด terminal session ใหม่ จึงจะสามารถพิมพ์ `mth` หรือ `slv` ในหน้าต่าง Terminal ถัดไปได้ทันที!

---

### 🎯 1. `mth` — เครื่องคิดเลขสไตล์ Excel
*(ชื่อเรียกแทน: `calc`, `math`)*

รองรับสูตรคณิตศาสตร์และฟังก์ชัน Excel ทั้งหมด:

| รูปแบบการใช้งาน | ตัวอย่างคำสั่ง | ผลลัพธ์ | คำอธิบาย |
| :--- | :--- | :--- | :--- |
| **คำนวณทั่วไป** | `mth 10/3` | `3.33` | ค่าเริ่มต้นทศนิยม 2 ตำแหน่ง(รองรับกี่ตำแหน่งก็ได้) |
| **พีทาโกรัส / รากที่สอง** | `mth "sqrt(3^2 + 4^2)"` | `5.00` | ใช้ `^` แทนเลขยกกำลัง |
| **ฟังก์ชัน Excel SUM** | `mth "SUM(10, 20, 30)"` | `60` | ผลรวม |
| **ฟังก์ชัน Excel AVG** | `mth "AVG(10, 20, 30)"` | `20.00` | ค่าเฉลี่ย |
| **น้ำหนักเหล็กเส้น (งานโยธา)** | `mth "pi() * (0.016/2)^2 * 7850"` | `1.58` | กก./เมตร สำหรับเหล็ก DB16 |
| **กำหนดจำนวนทศนิยม** | `mth 10/3 4` | `3.3333` | ปัดเศษ 4 ตำแหน่ง |
| **ปัดขึ้น (ROUNDUP)** | `mth 10/3 0 u` | `4` | `u` = roundup (ปัดขึ้นเสมอ) |
| **ปัดลง (ROUNDDOWN)** | `mth 10/3 0 d` | `3` | `d` = rounddown (ปัดลงเสมอ) |
| **เงื่อนไข IF** | `mth 'if(100 > 50, "PASS", "FAIL")'` | `PASS` | Excel IF condition |

---

### 🎯 2. `slv` — โปรแกรมแก้สมการพีชคณิต (Algebraic Solver)
*(ชื่อเรียกแทน: `solve`)*

แก้สมการหาค่าตัวแปรได้ทั้งแบบติดตัวแปร (Symbolic) และแบบแทนค่าตัวเลข (Numeric):

```bash
# 1. สมการเชิงเส้นตัวแปรเดียว
slv "2x + 10 = 30"
# ผลลัพธ์: x = 10

# 2. สมการ 2 ตัวแปร โดยกำหนดค่าตัวแปรหนึ่ง
slv "x = 2x + y" "y = 2"
# ผลลัพธ์: x = -2,  y = 2

# 3. ตรีโกณมิติแบบองศา(--deg หรือ -d) ถ้าไม่เติม --deg,-d จะ defaultเ มุมเป็นหน่วย radian
slv --deg "h = a * sin(b)" "a = 10" "b = 30"
# ผลลัพธ์: h = 5,  a = 10,  b = 30   (sin 30° = 0.5)

# 4. ตัวอย่างงานวิศวกรรม: หาแรงปฏิกิริยาคาน (Reaction)
slv "Ra + Rb = 100" "Ra = 40"
# ผลลัพธ์: Rb = 60,  Ra = 40

# 5. ปิทาโกรัสหาด้านตรงข้ามมุมฉาก c
slv "a^2 + b^2 = c^2" "a = 3" "b = 4"
# ผลลัพธ์: c = 5,  a = 3,  b = 4
```

---

## 🇬🇧 English

### ⚡ 1-Line Installation

#### 🪟 Windows (PowerShell)
Open **PowerShell** or **Windows Terminal** and run:
```powershell
irm https://raw.githubusercontent.com/joece035/maths-helper/main/install.ps1 | iex
```

#### 🐧 🍎 Linux / macOS / WSL / Git Bash / Termux (Bash/Zsh)
Open **Terminal** and run:
```bash
curl -fsSL https://raw.githubusercontent.com/joece035/maths-helper/main/install.sh | bash
```

> **Note:** Once installed, the `mth` and `slv` commands will be available in any new terminal session!

---

### 🎯 1. `mth` — Excel-Style Expression Evaluator
*(Aliases: `calc`, `math`)*

Evaluate mathematical expressions using familiar Excel function syntax:

| Usage | Example Command | Output | Description |
| :--- | :--- | :--- | :--- |
| **Arithmetic** | `mth 10/3` | `3.33` | Default 2 decimal places |
| **Pythagoras / Roots** | `mth "sqrt(3^2 + 4^2)"` | `5.00` | Power operator `^` supported |
| **Excel SUM** | `mth "SUM(10, 20, 30)"` | `60` | Variadic summation |
| **Excel AVG** | `mth "AVG(10, 20, 30)"` | `20.00` | Average calculation |
| **Civil Engineering Example** | `mth "pi() * (0.016/2)^2 * 7850"` | `1.58` | Weight of DB16 rebar (kg/m) |
| **Decimal Precision** | `mth 10/3 4` | `3.3333` | 4 decimal places |
| **Round Up** | `mth 10/3 0 u` | `4` | `u` = roundup (away from zero) |
| **Round Down** | `mth 10/3 0 d` | `3` | `d` = rounddown (truncate) |
| **Excel IF Logic** | `mth 'if(100 > 50, "PASS", "FAIL")'` | `PASS` | Conditional evaluation |

---

### 🎯 2. `slv` — Algebraic Equation Solver
*(Alias: `solve`)*

Solves linear, polynomial, trigonometric, and multi-variable equations symbolically or numerically:

```bash
# 1. Single variable linear equation
slv "2x + 10 = 30"
# Output: x = 10

# 2. Multi-variable substitution
slv "x = 2x + y" "y = 2"
# Output: x = -2,  y = 2

# 3. Trigonometry in degrees (--deg or -d) , default radain ( run without --deg,-d )
slv --deg "h = a * sin(b)" "a = 10" "b = 30"
# Output: h = 5,  a = 10,  b = 30   (sin 30° = 0.5)

# 4. Beam reaction example (Civil engineering)
slv "Ra + Rb = 100" "Ra = 40"
# Output: Rb = 60,  Ra = 40

# 5. Pythagorean theorem (finds positive root automatically)
slv "a^2 + b^2 = c^2" "a = 3" "b = 4"
# Output: c = 5,  a = 3,  b = 4
```

---

## 🛠️ Requirements

- **`mth`**:
  - Linux / macOS / WSL / Git Bash: Built with POSIX `awk` and `bash` (Zero external dependencies).
  - Windows PowerShell: Works with Python 3 or native basic math evaluation.
- **`slv`**:
  - Requires **Python 3** and `sympy` (automatically verified and installed by the installer).

---

## 🗑️ Uninstall

- **Linux / macOS / WSL / Git Bash**:
  ```bash
  rm -rf ~/.maths-helper ~/.local/bin/mth ~/.local/bin/slv ~/.local/bin/calc ~/.local/bin/solve
  ```
  *(Then remove the `maths-helper` line from your `~/.bashrc` or `~/.zshrc`)*

- **Windows PowerShell**:
  ```powershell
  Remove-Item -Recurse -Force "$HOME\.maths-helper"
  ```
  *(Then remove the `maths-helper` line from your `$PROFILE`)*

---

## 📄 License
MIT License © 2026 joece035
