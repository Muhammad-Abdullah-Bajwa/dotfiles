#!/usr/bin/env bash
#
# Post-install script for tools not in nixpkgs
# Run this after `nix profile add .#` to install remaining tools
#
# TOOLS INSTALLED:
#   - beads (bd)        - via go install (steveyegge/beads)
#   - beads-viewer (bv) - via go install (Dicklesworthstone/beads_viewer)
#   - opencode          - via go install
#   - claude-code       - via npm install -g
#
# PREREQUISITES:
#   - Go toolchain (from nix flake)
#   - Node.js + npm (from nix flake)
#   - Rust/Cargo via rustup (from nix flake, needs `rustup default stable` first)
#
# USAGE:
#   ./post-install.sh           # Install all tools
#   ./post-install.sh --check   # Just check what's installed
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
CHECK_ONLY=false
if [[ "$1" == "--check" ]]; then
    CHECK_ONLY=true
fi

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              POST-INSTALL: EXTRA TOOLS                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ==============================================================================
# PREREQUISITE CHECKS
# ==============================================================================

echo -e "${BLUE}==> Checking prerequisites...${NC}"

MISSING_PREREQS=false

# Check Go
if command -v go &>/dev/null; then
    GO_VERSION=$(go version | awk '{print $3}')
    echo -e "  ${GREEN}✓${NC} Go installed: $GO_VERSION"
else
    echo -e "  ${RED}✗${NC} Go not found - run 'nix profile add .#' first"
    MISSING_PREREQS=true
fi

# Check npm
if command -v npm &>/dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "  ${GREEN}✓${NC} npm installed: v$NPM_VERSION"
else
    echo -e "  ${RED}✗${NC} npm not found - run 'nix profile add .#' first"
    MISSING_PREREQS=true
fi

# Check rustup/cargo
if command -v rustup &>/dev/null; then
    if rustup show active-toolchain &>/dev/null; then
        RUST_VERSION=$(rustc --version 2>/dev/null | awk '{print $2}' || echo "not configured")
        echo -e "  ${GREEN}✓${NC} Rust toolchain: $RUST_VERSION"
    else
        echo -e "  ${YELLOW}⚠${NC} rustup installed but no toolchain - run 'rustup default stable'"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} rustup not found (optional, for cargo install tools)"
fi

echo ""

if [[ "$MISSING_PREREQS" == true ]]; then
    echo -e "${RED}Missing prerequisites. Please install them first:${NC}"
    echo "  nix profile add .#"
    exit 1
fi

# ==============================================================================
# CONFIGURE NPM GLOBAL DIRECTORY (for Nix compatibility)
# ==============================================================================

NPM_GLOBAL_DIR="$HOME/.npm-global"
NPM_GLOBAL_BIN="$NPM_GLOBAL_DIR/bin"

# Check if npm is from Nix (read-only prefix)
NPM_PREFIX=$(npm config get prefix 2>/dev/null)
if [[ "$NPM_PREFIX" == /nix/store/* ]]; then
    echo -e "${YELLOW}Note: Configuring npm to use user-writable global directory${NC}"
    echo -e "      (Nix npm prefix is read-only: $NPM_PREFIX)"
    
    # Create the directory
    mkdir -p "$NPM_GLOBAL_DIR"
    
    # Configure npm to use it
    npm config set prefix "$NPM_GLOBAL_DIR"
    
    echo -e "  ${GREEN}✓${NC} npm global prefix set to: $NPM_GLOBAL_DIR"
    echo ""
fi

# ==============================================================================
# UPDATE SHELL CONFIGS WITH PATH
# ==============================================================================

echo -e "${BLUE}==> Configuring shell PATH...${NC}"

# Marker comment to identify our additions
MARKER="# post-install.sh: go and npm-global paths"

# --- ZSH CONFIG ---
ZSHRC="$HOME/.zshrc"
ZSH_PATH_LINE='export PATH="$HOME/.npm-global/bin:$HOME/go/bin:$PATH"'

if [[ -f "$ZSHRC" ]]; then
    if grep -q "npm-global" "$ZSHRC" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} .zshrc already has npm-global in PATH"
    else
        echo "" >> "$ZSHRC"
        echo "$MARKER" >> "$ZSHRC"
        echo "$ZSH_PATH_LINE" >> "$ZSHRC"
        echo -e "  ${GREEN}✓${NC} Added PATH to .zshrc"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} .zshrc not found, skipping"
fi

# --- FISH CONFIG ---
FISH_CONFIG="$HOME/.config/fish/config.fish"

if [[ -d "$HOME/.config/fish" ]]; then
    if [[ -f "$FISH_CONFIG" ]] && grep -q "npm-global" "$FISH_CONFIG" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} fish config already has npm-global in PATH"
    else
        # Create config.fish if it doesn't exist
        mkdir -p "$HOME/.config/fish"
        
        # Add fish-style path additions
        echo "" >> "$FISH_CONFIG"
        echo "$MARKER" >> "$FISH_CONFIG"
        echo 'fish_add_path -g $HOME/.npm-global/bin' >> "$FISH_CONFIG"
        echo 'fish_add_path -g $HOME/go/bin' >> "$FISH_CONFIG"
        echo -e "  ${GREEN}✓${NC} Added PATH to fish config"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} fish config directory not found, skipping"
fi

echo ""

# ==============================================================================
# INSTALLATION FUNCTIONS
# ==============================================================================

install_go_tool() {
    local name="$1"
    local binary="$2"
    local package="$3"
    local description="$4"

    echo -n "  $name ($description)... "

    if [[ "$CHECK_ONLY" == true ]]; then
        if command -v "$binary" &>/dev/null; then
            echo -e "${GREEN}installed${NC}"
        else
            echo -e "${YELLOW}not installed${NC}"
        fi
        return
    fi

    if command -v "$binary" &>/dev/null; then
        echo -e "${GREEN}already installed${NC}"
    else
        echo -e "${YELLOW}installing...${NC}"
        if go install "$package" 2>/dev/null; then
            echo -e "    ${GREEN}✓ installed${NC}"
        else
            echo -e "    ${RED}✗ failed${NC}"
        fi
    fi
}

install_npm_tool() {
    local name="$1"
    local binary="$2"
    local package="$3"
    local description="$4"

    echo -n "  $name ($description)... "

    if [[ "$CHECK_ONLY" == true ]]; then
        if command -v "$binary" &>/dev/null || [[ -x "$NPM_GLOBAL_BIN/$binary" ]]; then
            echo -e "${GREEN}installed${NC}"
        else
            echo -e "${YELLOW}not installed${NC}"
        fi
        return
    fi

    if command -v "$binary" &>/dev/null || [[ -x "$NPM_GLOBAL_BIN/$binary" ]]; then
        echo -e "${GREEN}already installed${NC}"
    else
        echo -e "${YELLOW}installing...${NC}"
        if npm install -g "$package" 2>/dev/null; then
            echo -e "    ${GREEN}✓ installed${NC}"
        else
            echo -e "    ${RED}✗ failed (may need sudo or check npm prefix)${NC}"
        fi
    fi
}

# ==============================================================================
# ENSURE GOPATH/GOBIN IS IN PATH (for this session)
# ==============================================================================

# Go installs binaries to ~/go/bin by default
export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="${GOBIN:-$GOPATH/bin}"
export PATH="$NPM_GLOBAL_BIN:$GOBIN:$PATH"

# ==============================================================================
# INSTALL TOOLS
# ==============================================================================

echo -e "${BLUE}==> Installing Go tools...${NC}"

# Beads - the main beads CLI (bd command)
install_go_tool "beads" "bd" "github.com/steveyegge/beads/cmd/bd@latest" "context bundler for AI"

# Beads Viewer - viewer for beads files (bv command)
install_go_tool "beads-viewer" "bv" "github.com/Dicklesworthstone/beads_viewer/cmd/bv@latest" "beads file viewer"

# OpenCode - AI coding assistant
install_go_tool "opencode" "opencode" "github.com/opencode-ai/opencode@latest" "AI coding assistant"

echo ""
echo -e "${BLUE}==> Installing npm tools...${NC}"

# Claude Code - Anthropic's coding assistant
install_npm_tool "claude-code" "claude" "@anthropic-ai/claude-code" "Anthropic's AI assistant"

# ==============================================================================
# SUMMARY
# ==============================================================================

echo ""
echo -e "${BLUE}==> Installation Summary${NC}"
echo ""

check_tool() {
    local name="$1"
    local binary="$2"
    local alt_path="$3"
    
    if command -v "$binary" &>/dev/null; then
        local version=$("$binary" --version 2>/dev/null | head -1 || echo "installed")
        echo -e "  ${GREEN}✓${NC} $name: $version"
    elif [[ -n "$alt_path" && -x "$alt_path" ]]; then
        local version=$("$alt_path" --version 2>/dev/null | head -1 || echo "installed")
        echo -e "  ${GREEN}✓${NC} $name: $version"
    else
        echo -e "  ${RED}✗${NC} $name: not found"
    fi
}

check_tool "beads (bd)" "bd" ""
check_tool "beads-viewer (bv)" "bv" ""
check_tool "opencode" "opencode" ""
check_tool "claude-code" "claude" "$NPM_GLOBAL_BIN/claude"

echo ""

# ==============================================================================
# POST-INSTALL NOTES
# ==============================================================================

echo -e "${BLUE}==> Notes${NC}"
echo ""
echo "  Go binaries installed to: $GOBIN"
echo "  npm global binaries: $NPM_GLOBAL_BIN"
echo ""
echo -e "  ${GREEN}Shell configs updated. Restart your shell or run:${NC}"
echo "    source ~/.zshrc      # for zsh"
echo "    exec fish            # for fish"
echo ""
echo "  For claude-code, authenticate with:"
echo "    claude auth"
echo ""
echo "  For beads stealth mode (hides .beads from git):"
echo "    bd init --stealth"
echo ""
