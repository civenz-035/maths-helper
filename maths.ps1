# ============================================================
# maths.ps1 — PowerShell Module for maths-helper (Windows Native)
# Repository: https://github.com/joece035/maths-helper
# ============================================================

$script:MATHS_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

function Get-MathsPython {
    if (Get-Command python -ErrorAction SilentlyContinue) {
        return "python"
    }
    if (Get-Command py -ErrorAction SilentlyContinue) {
        return "py"
    }
    if (Get-Command python3 -ErrorAction SilentlyContinue) {
        return "python3"
    }
    return $null
}

function mth {
    <#
    .SYNOPSIS
        Excel-style Maths Helper for PowerShell
    .EXAMPLE
        mth 10/3
        mth "sqrt(5^2+12^2)"
        mth "SUM(10,20,30)"
    #>
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments = $true)]$Expression)

    if (-not $Expression) {
        Write-Host "mth — Excel-style Maths Helper (alias: calc, math)" -ForegroundColor Cyan
        Write-Host "Usage: mth <expression> [decimals] [mode]"
        Write-Host "Examples:"
        Write-Host "  mth 10/3                # 3.33"
        Write-Host "  mth ""sqrt(5^2+12^2)""    # 13.00"
        Write-Host "  mth ""SUM(10,20,30)""     # 60"
        return
    }

    $py = Get-MathsPython
    $mathsPy = Join-Path $script:MATHS_DIR "maths.py"

    if ($py -and (Test-Path $mathsPy)) {
        & $py $mathsPy mth @Expression
    } else {
        # Fallback to pure PowerShell evaluation if python is absent
        try {
            $exprStr = ($Expression -join " ").Replace("^", "**")
            $res = Invoke-Expression $exprStr
            if ($res -is [double] -or $res -is [int]) {
                [math]::Round($res, 2)
            } else {
                $res
            }
        } catch {
            Write-Error "mth: Python is recommended for full Excel math features. Install Python via: winget install Python.Python.3.11"
        }
    }
}

function slv {
    <#
    .SYNOPSIS
        Algebraic Equation Solver for PowerShell
    .EXAMPLE
        slv "x=2x+y" "y=2"
        slv --deg "h=a*sin(b)" a=10 b=30
    #>
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments = $true)]$EquationArgs)

    if (-not $EquationArgs) {
        Write-Host "slv — Algebraic Equation Solver (alias: solve)" -ForegroundColor Cyan
        Write-Host "Usage: slv [--deg|-d] <equation> [var=value] ..."
        Write-Host "Examples:"
        Write-Host "  slv ""x=2x+y"" ""y=2""               # x=-2  y=2"
        Write-Host "  slv --deg ""h=a*sin(b)"" a=10 b=30   # h=5"
        Write-Host "  slv ""a^2+b^2=c^2"" ""a=3"" ""b=4""    # c=5"
        return
    }

    $py = Get-MathsPython
    $mathsPy = Join-Path $script:MATHS_DIR "maths.py"

    if (-not $py) {
        Write-Error "slv requires Python with sympy. Install Python via: winget install Python.Python.3.11"
        return
    }

    & $py $mathsPy slv @EquationArgs
}

# Aliases
Set-Alias -Name calc -Value mth -ErrorAction SilentlyContinue
Set-Alias -Name math -Value mth -ErrorAction SilentlyContinue
Set-Alias -Name solve -Value slv -ErrorAction SilentlyContinue
