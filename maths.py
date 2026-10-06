#!/usr/bin/env python3
"""
maths.py — Cross-platform backend for mth & slv
Repository: https://github.com/joece035/maths-helper
"""
import sys
import re
import math

def run_mth(args):
    if not args:
        print("""mth — Excel-style Maths Helper (alias: calc, math)
Usage: mth <expression> [decimals] [mode]
       mode: r|round (default) | u|up | d|down
Examples:
  mth 10/3                 # 3.33
  mth sqrt(5^2+10^2)       # 11.18
  mth SUM(10,20,30)        # 60
  mth POW(2,10)            # 1024
  mth if(100>50,"y","n")   # y
""", file=sys.stderr)
        return 1

    scale = 2
    mode = "round"

    # Leading arg scale/mode
    if len(args) >= 2 and args[0].isdigit():
        scale = int(args[0])
        args = args[1:]
        if args and args[0].lower() in ["u", "up", "roundup", "ceil", "d", "down", "rounddown", "floor", "r", "round"]:
            m = args[0].lower()
            if m in ["u", "up", "roundup", "ceil"]: mode = "up"
            elif m in ["d", "down", "rounddown", "floor"]: mode = "down"
            else: mode = "round"
            args = args[1:]

    raw = " ".join(args).strip()

    # Trailing arg peel (scale/mode)
    parts = raw.split()
    peeled = True
    while peeled and len(parts) >= 2:
        peeled = False
        last = parts[-1].lower()
        if last in ["u", "up", "roundup", "ceil"]:
            mode = "up"; parts.pop(); peeled = True
        elif last in ["d", "down", "rounddown", "floor"]:
            mode = "down"; parts.pop(); peeled = True
        elif last in ["r", "round"]:
            mode = "round"; parts.pop(); peeled = True
        elif last.isdigit() and (parts[-2][-1].isdigit() or parts[-2].endswith(")")):
            scale = int(last); parts.pop(); peeled = True

    expr = " ".join(parts).strip()
    expr = expr.replace("**", "^")

    # Math environment functions
    def roundup(val, digits=0):
        m = 10 ** int(digits)
        sgn = 1 if val >= 0 else -1
        av = abs(val) * m
        iv = int(av)
        return sgn * (iv + 1 if av > iv else iv) / m

    def rounddown(val, digits=0):
        m = 10 ** int(digits)
        sgn = 1 if val >= 0 else -1
        return sgn * int(abs(val) * m) / m

    def excel_round(val, digits=0):
        m = 10 ** int(digits)
        sgn = 1 if val >= 0 else -1
        return sgn * int(abs(val) * m + 0.5) / m

    env = {
        "sqrt": math.sqrt, "abs": abs, "int": int,
        "round": excel_round, "roundup": roundup, "rounddown": rounddown,
        "ceil": math.ceil, "floor": math.floor,
        # Radian trig (standard)
        "sin": math.sin, "cos": math.cos, "tan": math.tan,
        "asin": math.asin, "acos": math.acos, "atan": math.atan,
        # Degree-friendly trig — Non-IT safe 🙌
        "sind":  lambda x: math.sin(math.radians(x)),
        "cosd":  lambda x: math.cos(math.radians(x)),
        "tand":  lambda x: math.tan(math.radians(x)),
        "asind": lambda x: math.degrees(math.asin(x)),
        "acosd": lambda x: math.degrees(math.acos(x)),
        "atand": lambda x: math.degrees(math.atan(x)),
        "log": lambda x, b=10: math.log(x, b), "ln": math.log,
        "exp": math.exp, "pow": math.pow,
        "pi": math.pi, "e": math.e,
        "sum": lambda *a: sum(a),
        "avg": lambda *a: sum(a)/len(a) if a else 0,
        "min": lambda *a: min(a),
        "max": lambda *a: max(a),
        "if": lambda cond, t, f: t if cond else f,
    }

    # Normalize expression for python eval:
    # replace ^ with **
    # handle functions case-insensitively
    def replace_fn(match):
        fn = match.group(1).lower()
        if fn in env:
            return fn + "("
        return match.group(0)

    # ── Unit Suffix Pre-processing ──────────────────────────────────
    # 30deg → (30*pi/180)  |  30° → (30*pi/180)  |  1.57rad → 1.57
    PI = math.pi
    expr = re.sub(r'(\d+\.?\d*)\s*deg\b', lambda m: f'({float(m.group(1))}*{PI}/180)', expr, flags=re.IGNORECASE)
    expr = re.sub(r'(\d+\.?\d*)\u00b0', lambda m: f'({float(m.group(1))}*{PI}/180)', expr)
    expr = re.sub(r'(\d+\.?\d*)\s*rad\b', lambda m: m.group(1), expr, flags=re.IGNORECASE)

    # ── Smart Hint: detect sin/cos/tan(large_angle) ────────────────
    _smart_hint = None
    _trig_match = re.search(r'\b(?:sin|cos|tan)\(([^)]+)\)', expr, re.IGNORECASE)
    if _trig_match:
        try:
            _ang_val = float(_trig_match.group(1).strip())
            if _ang_val > 2 * PI:  # > 6.28 → almost certainly meant degrees
                _smart_hint = (
                    f"\033[1;33m💡 Tip: sin/cos/tan ใช้หน่วย Radian — "
                    f"ถ้าต้องการมุม {_trig_match.group(1).strip()} องศา "
                    f"ให้ใช้ sind/cosd/tand แทนครับ\033[0m"
                )
        except (ValueError, TypeError):
            pass

    # replace case-insensitive function calls
    norm_expr = re.sub(r'\b([a-zA-Z_][a-zA-Z0-9_]*)\s*\(', replace_fn, expr)
    norm_expr = norm_expr.replace("^", "**")
    norm_expr = re.sub(r'\bpi\(\)', 'pi', norm_expr, flags=re.IGNORECASE)
    norm_expr = re.sub(r'\be\(\)', 'e', norm_expr, flags=re.IGNORECASE)

    try:
        res = eval(norm_expr, {"__builtins__": {}}, env)
    except Exception as e:
        print(f"mth: calculation error ({e}) in expression: {expr}", file=sys.stderr)
        return 1

    if isinstance(res, (int, float)):
        val = float(res)
        if mode == "up":
            final_res = roundup(val, scale)
        elif mode == "down":
            final_res = rounddown(val, scale)
        else:
            final_res = excel_round(val, scale)
        print(f"{final_res:.{scale}f}")
    else:
        print(res)
    # Smart hint to stderr (non-blocking, won't break pipes)
    if _smart_hint:
        print(_smart_hint, file=sys.stderr)
    return 0


def run_slv(args):
    clean_args = []
    deg_mode = False
    for arg in args:
        if arg in ["-d", "--deg", "--degree"]:
            deg_mode = True
        else:
            clean_args.append(arg)

    if not clean_args:
        print("""slv — Algebraic Equation Solver (alias: solve)
Usage: slv [--deg|-d] <equation> [var=value] ...
Examples:
  slv "x=2x+y" "y=2"                # x=-2  y=2
  slv --deg "h=a*sin(b)" a=10 b=30  # h=5
  slv "a^2+b^2=c^2" "a=3" "b=4"     # c=5
""", file=sys.stderr)
        return 1

    try:
        from sympy import (symbols, Eq, solve, simplify, sympify,
                           sqrt, Rational, pi, E as euler, zoo, oo, nan,
                           sin, cos, tan, asin, acos, atan, sinh, cosh, tanh,
                           exp, log, Abs, factorial, floor, ceiling, I, rad, deg)
        from sympy.parsing.sympy_parser import (parse_expr,
            standard_transformations, implicit_multiplication_application,
            convert_xor)
    except ImportError:
        print("slv: sympy library is required. Install via: pip install sympy", file=sys.stderr)
        return 1

    transformations = (standard_transformations +
                       (implicit_multiplication_application, convert_xor))

    eq_str = clean_args[0]
    knowns = clean_args[1:]

    MATH_FUNCS = {
        "sqrt": sqrt, "pi": pi, "e": euler, "E": euler,
        "sinh": sinh, "cosh": cosh, "tanh": tanh,
        "exp": exp, "log": log, "ln": log,
        "abs": Abs, "Abs": Abs,
        "factorial": factorial, "floor": floor, "ceiling": ceiling,
        "rad": rad, "deg": deg,
        "sind": lambda x: sin(rad(x)),
        "cosd": lambda x: cos(rad(x)),
        "tand": lambda x: tan(rad(x)),
        "asind": lambda x: deg(asin(x)),
        "acosd": lambda x: deg(acos(x)),
        "atand": lambda x: deg(atan(x)),
    }

    if deg_mode:
        MATH_FUNCS.update({
            "sin": lambda x: sin(rad(x)),
            "cos": lambda x: cos(rad(x)),
            "tan": lambda x: tan(rad(x)),
            "asin": lambda x: deg(asin(x)),
            "acos": lambda x: deg(acos(x)),
            "atan": lambda x: deg(atan(x)),
        })
    else:
        MATH_FUNCS.update({
            "sin": sin, "cos": cos, "tan": tan,
            "asin": asin, "acos": acos, "atan": atan,
        })

    BUILTINS = set(MATH_FUNCS.keys()) | {"int","mod","pow","min","max","sum","avg"}

    raw_vars_set = set(re.findall(r'[a-zA-Z_][a-zA-Z0-9_]*', eq_str))
    raw_vars_set = {v for v in raw_vars_set if v not in BUILTINS}

    for kv in knowns:
        k = kv.split("=", 1)[0].strip()
        if k and k not in BUILTINS:
            raw_vars_set.add(k)

    raw_vars = sorted(raw_vars_set)
    sym_map = {v: symbols(v) for v in raw_vars}

    def parse(s):
        ns = dict(MATH_FUNCS)
        ns.update({str(v): v for v in sym_map.values()})
        return parse_expr(s, local_dict=ns, transformations=transformations)

    subs = {}
    for kv in knowns:
        if "=" not in kv:
            print(f"slv: bad known value '{kv}' (need var=value)", file=sys.stderr)
            return 1
        k, v = kv.split("=", 1)
        k, v = k.strip(), v.strip()
        if k in sym_map:
            try:
                subs[sym_map[k]] = parse(v)
            except Exception:
                subs[sym_map[k]] = sympify(v)

    if "=" not in eq_str:
        print("slv: equation must contain '='", file=sys.stderr)
        return 1

    lhs_s, rhs_s = eq_str.split("=", 1)
    try:
        lhs = parse(lhs_s.strip())
        rhs = parse(rhs_s.strip())
    except Exception as exc:
        print(f"slv: parse error — {exc}", file=sys.stderr)
        return 1

    equation = Eq(lhs, rhs)
    equation_subst = equation.subs(subs)

    if equation_subst.has(zoo) or lhs.subs(subs).has(zoo) or rhs.subs(subs).has(zoo):
        print("\n  \033[1;31mUndefined\033[0m (division by zero / singularity)\n")
        return 0

    unknowns = [sym_map[v] for v in raw_vars if sym_map[v] not in subs]

    if not unknowns:
        val = simplify(lhs.subs(subs) - rhs.subs(subs))
        if val == 0:
            print("\n  \033[1;32m✓ Equation is satisfied (both sides equal).\033[0m\n")
        else:
            print(f"\n  \033[1;31m✗ Equation NOT satisfied (difference = {val}).\033[0m\n")
        return 0

    try:
        sol = solve(equation_subst, unknowns, dict=True)
    except Exception as exc:
        print(f"slv: solver error — {exc}", file=sys.stderr)
        return 1

    ANSI_G  = "\033[1;32m"
    ANSI_C  = "\033[1;36m"
    ANSI_Y  = "\033[1;33m"
    ANSI_R  = "\033[0m"

    def fmt_val(v):
        try:
            if v.is_number and v.is_real:
                f = float(v)
                if f == int(f) and abs(f) < 1e15:
                    return str(int(f))
                if abs(f) > 1e10 or (f != 0 and abs(f) < 1e-4):
                    return f"{f:.6g}"
                return f"{f:.6g}"
        except (TypeError, ValueError, AttributeError):
            pass
        return str(simplify(v))

    print()

    def _prefer_positive(solutions, unks, sbs):
        if len(solutions) <= 1:
            return solutions[0] if solutions else {}
        for candidate in solutions:
            vals = [candidate.get(sym, sym).subs(sbs) for sym in unks]
            try:
                if all(v.is_real and float(v) > 0 for v in vals):
                    return candidate
            except (TypeError, ValueError, AttributeError):
                pass
        return solutions[0]

    def _symbolic_solve(l, r, unks, sbs):
        expr = simplify(l - r)
        printed_any = False
        for unk in unks:
            try:
                sym_sol = solve(expr.subs(sbs), unk)
                if sym_sol:
                    chosen = sym_sol[0]
                    chosen_str = fmt_val(chosen)
                    if str(chosen) != str(unk):
                        note = f"  {ANSI_Y}(imaginary / no real solution){ANSI_R}" if chosen.has(I) else ""
                        print(f"  {ANSI_G}{unk}{ANSI_R} = {ANSI_C}{chosen_str}{ANSI_R}{note}")
                        printed_any = True
                        break
            except Exception:
                pass
        if not printed_any:
            for unk in unks:
                print(f"  {ANSI_G}{unk}{ANSI_R} = {ANSI_C}(no closed-form solution){ANSI_R}")

    if sol:
        solution = _prefer_positive(sol, unknowns, subs)
        for sym in unknowns:
            val = solution.get(sym, sym)
            val_sub = val.subs(subs)
            if val_sub == sym and len(unknowns) > 1 and len(solution) < len(unknowns):
                continue
            s_name = str(sym)
            s_val  = fmt_val(val_sub)
            note   = f"  {ANSI_Y}(imaginary / no real solution){ANSI_R}" if val_sub.has(I) else ""
            print(f"  {ANSI_G}{s_name}{ANSI_R} = {ANSI_C}{s_val}{ANSI_R}{note}")
        for sym, val in subs.items():
            s_name = str(sym)
            s_val  = fmt_val(val)
            print(f"  {ANSI_G}{s_name}{ANSI_R} = {ANSI_C}{s_val}{ANSI_R}")
    else:
        _symbolic_solve(lhs, rhs, unknowns, subs)
        for sym, val in subs.items():
            print(f"  {ANSI_G}{sym}{ANSI_R} = {ANSI_C}{fmt_val(val)}{ANSI_R}")
    print()
    return 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: maths.py [mth|slv] <args...>")
        sys.exit(1)
    sub = sys.argv[1].lower()
    rest = sys.argv[2:]
    if sub in ["mth", "calc", "math"]:
        sys.exit(run_mth(rest))
    elif sub in ["slv", "solve"]:
        sys.exit(run_slv(rest))
    else:
        print(f"Unknown command: {sub}")
        sys.exit(1)
