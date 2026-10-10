#!/usr/bin/env bash
# ============================================================
# maths-helper Installer -- Bash / Zsh / ACodex compatible
# Repository: https://github.com/civenz-035/maths-helper
# ============================================================
set -e

REPO_URL="https://github.com/civenz-035/maths-helper.git"
RAW_URL="https://raw.githubusercontent.com/civenz-035/maths-helper/main"
INSTALL_DIR="$HOME/.maths-helper"
BIN_DIR="$HOME/.local/bin"

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}====================================================${NC}"
echo -e "${GREEN}   Installing maths-helper (mth & slv)             ${NC}"
echo -e "${CYAN}====================================================${NC}"

# ============================================================
# Detect ACodex / restricted environment
# ACodex uses BusyBox grep (no -P flag).
# pip may require --user when running as root in ACodex.
# Detection priority:
#   1. grep -P fails  -> BusyBox/toybox env
#   2. TERM_PROGRAM=acode or ACODE_TERMINAL=1 -> explicit ACodex
# ============================================================
_IS_ACODEX=0
if ! echo "" | grep -P "" 2>/dev/null; then
    _IS_ACODEX=1
fi
if [[ "${TERM_PROGRAM:-}" == "acode" || "${ACODE_TERMINAL:-}" == "1" ]]; then
    _IS_ACODEX=1
fi

# -- 1. Create target directories ----------------------------
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# -- Helper: download files via curl -------------------------
_download_files() {
    curl -fsSL "$RAW_URL/maths.sh" -o "$INSTALL_DIR/maths.sh"
    curl -fsSL "$RAW_URL/maths.py" -o "$INSTALL_DIR/maths.py"
    mkdir -p "$INSTALL_DIR/bin"
    curl -fsSL "$RAW_URL/bin/mth"  -o "$INSTALL_DIR/bin/mth"
    curl -fsSL "$RAW_URL/bin/slv"  -o "$INSTALL_DIR/bin/slv"
}

# -- 2. Download/Update repository ---------------------------
if command -v git >/dev/null 2>&1; then
    if [ -d "$INSTALL_DIR/.git" ]; then
        echo -e "Updating existing installation in ${INSTALL_DIR}..."
        (cd "$INSTALL_DIR" && git pull --quiet origin main || true)
    else
        echo -e "Cloning repository into ${INSTALL_DIR}..."
        git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" 2>/dev/null || {
            echo -e "${YELLOW}Git clone failed, downloading files directly...${NC}"
            _download_files
        }
    fi
else
    echo -e "Downloading files directly via curl..."
    _download_files
fi

# -- 3. Ensure permissions -----------------------------------
chmod +x "$INSTALL_DIR/maths.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/maths.py" 2>/dev/null || true

# -- 4. Write wrapper scripts with real-path resolution ------
# readlink -f resolves the symlink so SCRIPT_DIR always points to
# the real ~/.maths-helper/bin/, not the ~/.local/bin/ symlink.
# This fixes the BASH_SOURCE[0] symlink bug.
mkdir -p "$INSTALL_DIR/bin"
cat > "$INSTALL_DIR/bin/mth" <<'WRAPPER'
#!/usr/bin/env bash
_self="${BASH_SOURCE[0]}"
if command -v readlink >/dev/null 2>&1; then
    _real="$(readlink -f "$_self" 2>/dev/null || readlink "$_self" 2>/dev/null || echo "$_self")"
else
    _real="$_self"
fi
SCRIPT_DIR="$(cd "$(dirname "$_real")/.." && pwd)"
"$SCRIPT_DIR/maths.sh" mth "$@"
WRAPPER

cat > "$INSTALL_DIR/bin/slv" <<'WRAPPER'
#!/usr/bin/env bash
_self="${BASH_SOURCE[0]}"
if command -v readlink >/dev/null 2>&1; then
    _real="$(readlink -f "$_self" 2>/dev/null || readlink "$_self" 2>/dev/null || echo "$_self")"
else
    _real="$_self"
fi
SCRIPT_DIR="$(cd "$(dirname "$_real")/.." && pwd)"
"$SCRIPT_DIR/maths.sh" slv "$@"
WRAPPER

chmod +x "$INSTALL_DIR/bin/mth" "$INSTALL_DIR/bin/slv"

# -- 5. Symlink binaries to ~/.local/bin ---------------------
ln -sf "$INSTALL_DIR/bin/mth"  "$BIN_DIR/mth"
ln -sf "$INSTALL_DIR/bin/slv"  "$BIN_DIR/slv"
ln -sf "$INSTALL_DIR/bin/mth"  "$BIN_DIR/calc"
ln -sf "$INSTALL_DIR/bin/slv"  "$BIN_DIR/solve"

# -- 6. Configure shell rc files ----------------------------
# ACodex mode:
#   mth  -> alias -> python3 maths.py mth
#           (avoids grep -P and non-interactive shell function issues)
#   slv  -> alias -> maths.sh slv
#           (maths.sh handles sympy install via pip --user)
# Normal mode:
#   source maths.sh (provides shell functions mth/slv/calc/solve)
if [[ "$_IS_ACODEX" -eq 1 ]]; then
    echo -e "${YELLOW}ACodex environment detected -- using alias mode${NC}"
    _RC_BLOCK="# maths-helper aliases (ACodex mode)
alias mth='python3 \"\$HOME/.maths-helper/maths.py\" mth'
alias calc='python3 \"\$HOME/.maths-helper/maths.py\" mth'
alias math='python3 \"\$HOME/.maths-helper/maths.py\" mth'
alias slv='\"\$HOME/.maths-helper/maths.sh\" slv'
alias solve='\"\$HOME/.maths-helper/maths.sh\" slv'"
    _MARKER="maths-helper aliases (ACodex mode)"
else
    _RC_BLOCK='# maths-helper (mth, slv, calc, solve)
[ -f "$HOME/.maths-helper/maths.sh" ] && source "$HOME/.maths-helper/maths.sh"'
    _MARKER="maths-helper/maths.sh"
fi

for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$rc_file" ]; then
        if ! grep -Fq "$_MARKER" "$rc_file"; then
            printf '\n%s\n' "$_RC_BLOCK" >> "$rc_file"
            echo -e "Added to ${rc_file}"
        fi
    fi
done

# -- 7. Ensure ~/.local/bin is in PATH -----------------------
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc_file" ] && ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$rc_file"; then
            echo "$PATH_LINE" >> "$rc_file"
        fi
    done
fi

# -- 8. Apply to current session immediately -----------------
export PATH="$BIN_DIR:$PATH"

if [[ "$_IS_ACODEX" -eq 1 ]]; then
    alias mth="python3 \"$INSTALL_DIR/maths.py\" mth"
    alias calc="python3 \"$INSTALL_DIR/maths.py\" mth"
    alias math="python3 \"$INSTALL_DIR/maths.py\" mth"
    alias slv="\"$INSTALL_DIR/maths.sh\" slv"
    alias solve="\"$INSTALL_DIR/maths.sh\" slv"
elif [ -f "$INSTALL_DIR/maths.sh" ]; then
    # shellcheck disable=SC1090
    source "$INSTALL_DIR/maths.sh"
fi

# -- 9. Sympy availability check ----------------------------
# ACodex: use pip --user (avoids root write-access errors)
if ! python3 -c "import sympy" 2>/dev/null; then
    if [[ "$_IS_ACODEX" -eq 1 ]]; then
        echo -e "${YELLOW}Installing sympy (--user, no root required)...${NC}"
        python3 -m pip install --user --quiet sympy 2>/dev/null || \
        python3 -m pip install --user --quiet --break-system-packages sympy 2>/dev/null || \
        echo -e "${RED}sympy install failed. Run manually: pip install --user sympy${NC}"
    fi
fi

echo -e "${GREEN}Installation completed successfully!${NC}\n"
echo -e "${YELLOW}Quick Test:${NC}"
if [[ "$_IS_ACODEX" -eq 1 ]]; then
    echo -e "  ${CYAN}python3 ~/.maths-helper/maths.py mth '10/3'${NC}"
    echo -e "  ${CYAN}python3 ~/.maths-helper/maths.py mth 'sqrt(5^2+12^2)'${NC}"
else
    echo -e "  mth 10/3            -> $("$INSTALL_DIR/bin/mth" 10/3 2>/dev/null || echo '(run after restart)')"
    echo -e "  mth sqrt(5^2+12^2)  -> $("$INSTALL_DIR/bin/mth" "sqrt(5^2+12^2)" 2>/dev/null || echo '(run after restart)')"
fi

echo -e "\n${CYAN}Commands available:${NC}"
echo -e "  ${GREEN}mth${NC}   (or ${GREEN}calc${NC}, ${GREEN}math${NC})  : Excel-style calculation"
echo -e "  ${GREEN}slv${NC}   (or ${GREEN}solve${NC})         : Algebraic equation solver"

if [[ "$_IS_ACODEX" -eq 1 ]]; then
    echo -e "\n${YELLOW}ACodex mode:${NC} aliases ready. If not found, run:"
    echo -e "   ${CYAN}source ~/.bashrc${NC}"
else
    if [ -e /dev/tty ]; then
        printf "\nWant to open a new shell now? (recommended Y) [y/N]: "
        _mh_answer=""
        IFS= read -r _mh_answer < /dev/tty || true
        case "$_mh_answer" in
            [Yy]*)
                _mh_shell="${SHELL:-bash}"
                echo -e "${CYAN}Opening new shell (${_mh_shell})...${NC}"
                exec "$_mh_shell" -l
                ;;
            *)
                echo -e "\nReady to use. Restart terminal or run:"
                echo -e "   ${CYAN}source ~/.bashrc${NC}\n"
                ;;
        esac
    else
        echo -e "\nIf commands not recognized yet, restart terminal or run:"
        echo -e "   ${CYAN}source ~/.bashrc${NC}\n"
    fi
fi
