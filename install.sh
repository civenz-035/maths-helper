#!/usr/bin/env bash
# ============================================================
# maths-helper 1-Line Installer for Bash / Zsh
# Repository: https://github.com/joece035/maths-helper
# ============================================================
set -e

REPO_URL="https://github.com/joece035/maths-helper.git"
RAW_URL="https://raw.githubusercontent.com/joece035/maths-helper/main"
INSTALL_DIR="$HOME/.maths-helper"
BIN_DIR="$HOME/.local/bin"

# ANSI Colors
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}====================================================${NC}"
echo -e "${GREEN}   Installing maths-helper (mth & slv)             ${NC}"
echo -e "${CYAN}====================================================${NC}"

# 1. Create target directories
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# 2. Check if git is available to clone, or download directly via curl/wget
if command -v git >/dev/null 2>&1; then
    if [ -d "$INSTALL_DIR/.git" ]; then
        echo -e "🔄 Updating existing installation in ${INSTALL_DIR}..."
        (cd "$INSTALL_DIR" && git pull --quiet origin main || true)
    else
        echo -e "📥 Cloning repository into ${INSTALL_DIR}..."
        git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" 2>/dev/null || {
            echo -e "${YELLOW}Git clone failed or repo is private, downloading files directly...${NC}"
            curl -fsSL "$RAW_URL/maths.sh" -o "$INSTALL_DIR/maths.sh"
            mkdir -p "$INSTALL_DIR/bin"
            curl -fsSL "$RAW_URL/bin/mth" -o "$INSTALL_DIR/bin/mth"
            curl -fsSL "$RAW_URL/bin/slv" -o "$INSTALL_DIR/bin/slv"
        }
    fi
else
    echo -e "📥 Downloading files directly via curl..."
    curl -fsSL "$RAW_URL/maths.sh" -o "$INSTALL_DIR/maths.sh"
    mkdir -p "$INSTALL_DIR/bin"
    curl -fsSL "$RAW_URL/bin/mth" -o "$INSTALL_DIR/bin/mth"
    curl -fsSL "$RAW_URL/bin/slv" -o "$INSTALL_DIR/bin/slv"
fi

# Ensure permissions
chmod +x "$INSTALL_DIR/maths.sh" "$INSTALL_DIR/bin/mth" "$INSTALL_DIR/bin/slv" 2>/dev/null || true

# Symlink binaries to ~/.local/bin
ln -sf "$INSTALL_DIR/bin/mth" "$BIN_DIR/mth"
ln -sf "$INSTALL_DIR/bin/slv" "$BIN_DIR/slv"
ln -sf "$INSTALL_DIR/bin/mth" "$BIN_DIR/calc"
ln -sf "$INSTALL_DIR/bin/slv" "$BIN_DIR/solve"

# 3. Configure shell rc files
CONFIG_LINE="[ -f \"\$HOME/.maths-helper/maths.sh\" ] && source \"\$HOME/.maths-helper/maths.sh\""

for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$rc_file" ]; then
        if ! grep -Fq "maths-helper/maths.sh" "$rc_file"; then
            echo "" >> "$rc_file"
            echo "# maths-helper (mth, slv, calc, solve)" >> "$rc_file"
            echo "$CONFIG_LINE" >> "$rc_file"
            echo -e "✅ Added to ${rc_file}"
        fi
    fi
done

# Ensure ~/.local/bin is in PATH in ~/.bashrc or ~/.zshrc
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc_file" ] && ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$rc_file"; then
            echo "$PATH_LINE" >> "$rc_file"
        fi
    done
fi

# Source for current session if possible
if [ -f "$INSTALL_DIR/maths.sh" ]; then
    source "$INSTALL_DIR/maths.sh"
fi

echo -e "${GREEN}🎉 Installation completed successfully!${NC}\n"
echo -e "${YELLOW}Quick Test:${NC}"
echo -e "  mth 10/3            → $($INSTALL_DIR/bin/mth 10/3)"
echo -e "  mth sqrt(5^2+12^2)  → $($INSTALL_DIR/bin/mth "sqrt(5^2+12^2)")"

echo -e "\n${CYAN}Commands available:${NC}"
echo -e "  ${GREEN}mth${NC}   (or ${GREEN}calc${NC}, ${GREEN}math${NC})  : Excel-style calculation"
echo -e "  ${GREEN}slv${NC}   (or ${GREEN}solve${NC})         : Algebraic equation solver"
echo -e "\n💡 If commands are not recognized yet, restart your terminal or run:"
echo -e "   ${CYAN}source ~/.bashrc${NC}  (or source ~/.zshrc)\n"
