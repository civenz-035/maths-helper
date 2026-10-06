# ============================================================
# maths-helper 1-Line Installer for Windows PowerShell
# Repository: https://github.com/joece035/maths-helper
# ============================================================

$ErrorActionPreference = "Continue"

$RAW_URL = "https://raw.githubusercontent.com/joece035/maths-helper/main"
$INSTALL_DIR = Join-Path $HOME ".maths-helper"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "   Installing maths-helper for PowerShell (mth & slv) " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Cyan

# 0. Adjust ExecutionPolicy if restricted
try {
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if ($policy -in @('Restricted', 'Undefined')) {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue
    }
} catch {}

# 1. Create directory
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
}

# 2. Download files
$files = @("maths.ps1", "maths.py", "maths.sh")
foreach ($f in $files) {
    $dest = Join-Path $INSTALL_DIR $f
    Write-Host "📥 Downloading $f..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri "$RAW_URL/$f" -OutFile $dest -UseBasicParsing
    } catch {
        (New-Object System.Net.WebClient).DownloadFile("$RAW_URL/$f", $dest)
    }
    # Unblock downloaded file to prevent Windows ExecutionPolicy block
    try { Unblock-File -Path $dest -ErrorAction SilentlyContinue } catch {}
}

# 3. Check Python and Sympy
$pyCmd = $null
if (Get-Command python -ErrorAction SilentlyContinue) { $pyCmd = "python" }
elseif (Get-Command py -ErrorAction SilentlyContinue) { $pyCmd = "py" }
elseif (Get-Command python3 -ErrorAction SilentlyContinue) { $pyCmd = "python3" }

if ($pyCmd) {
    Write-Host "🐍 Found Python ($pyCmd)" -ForegroundColor Green
    & $pyCmd -c "import sympy" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "📦 Installing sympy library for equation solver..." -ForegroundColor Yellow
        & $pyCmd -m pip install --quiet sympy
    }
} else {
    Write-Host "⚠️ Python not detected." -ForegroundColor Yellow
    Write-Host "   mth will run with basic math expressions."
    Write-Host "   For full Excel formulas & slv equation solver, install Python:" -ForegroundColor Gray
    Write-Host "   winget install Python.Python.3.11" -ForegroundColor Cyan
}

# 4. Add to PowerShell Profile
if (-not (Test-Path $PROFILE)) {
    $profileDir = Split-Path -Parent $PROFILE
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$profileSnippet = "`n# maths-helper (mth, slv, calc, solve)`nif (Test-Path `"`$HOME\.maths-helper\maths.ps1`") { . `"`$HOME\.maths-helper\maths.ps1`" }"

$profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
if (-not $profileContent -or -not $profileContent.Contains(".maths-helper\maths.ps1")) {
    Add-Content -Path $PROFILE -Value $profileSnippet
    Write-Host "✅ Added configuration to $PROFILE" -ForegroundColor Green
}

# 5. Load into current session
. (Join-Path $INSTALL_DIR "maths.ps1")

Write-Host "`n🎉 Installation completed successfully!" -ForegroundColor Green
Write-Host "`nQuick Test:" -ForegroundColor Yellow
Write-Host "  mth 10/3            → $(mth 10/3)"
Write-Host "  mth sqrt(5^2+12^2)  → $(mth "sqrt(5^2+12^2)")"

Write-Host "`nCommands available in PowerShell:" -ForegroundColor Cyan
Write-Host "  mth   (or calc, math)  : Excel-style calculation" -ForegroundColor Green
Write-Host "  slv   (or solve)       : Algebraic equation solver" -ForegroundColor Green
Write-Host "`n💡 You can use 'mth' and 'slv' in any new PowerShell terminal immediately!`n"
