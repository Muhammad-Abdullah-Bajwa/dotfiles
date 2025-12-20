#!/usr/bin/env bash
#
# Bootstrap script for dotfiles
# Installs Nix (if needed), configures caches, installs packages, and symlinks dotfiles
#
# USAGE:
#   ./install.sh              # Default: use flakes if available
#   ./install.sh --legacy     # Force legacy packages.txt method
#   ./install.sh --flakes     # Force flakes method
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Dotfiles directory: $DOTFILES_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
USE_FLAKES="auto"
while [[ $# -gt 0 ]]; do
    case $1 in
        --legacy)
            USE_FLAKES="no"
            shift
            ;;
        --flakes)
            USE_FLAKES="yes"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# ==============================================================================
# STEP 1: INSTALL NIX
# ==============================================================================

if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}==> Installing Nix via Determinate Systems installer...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
        sh -s -- install --no-confirm

    # Source Nix for this session
    if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    elif [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi

    echo -e "${GREEN}==> Nix installed successfully${NC}"
else
    echo -e "${GREEN}==> Nix already installed${NC}"
fi

# ==============================================================================
# STEP 2: CONFIGURE NIX (binary caches, flakes)
# ==============================================================================

echo -e "${YELLOW}==> Configuring Nix...${NC}"

# Create user nix config directory
mkdir -p "$HOME/.config/nix"

# Symlink or copy nix.conf if it exists in dotfiles
if [[ -f "$DOTFILES_DIR/.config/nix/nix.conf" ]]; then
    if [[ -L "$HOME/.config/nix/nix.conf" ]]; then
        rm "$HOME/.config/nix/nix.conf"
    elif [[ -f "$HOME/.config/nix/nix.conf" ]]; then
        backup="$HOME/.config/nix/nix.conf.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "  ${YELLOW}Backing up existing nix.conf -> $backup${NC}"
        mv "$HOME/.config/nix/nix.conf" "$backup"
    fi

    ln -s "$DOTFILES_DIR/.config/nix/nix.conf" "$HOME/.config/nix/nix.conf"
    echo -e "  ${GREEN}Linked nix.conf (binary caches + flakes enabled)${NC}"
else
    # Create minimal nix.conf if dotfiles version doesn't exist
    cat > "$HOME/.config/nix/nix.conf" << 'EOF'
# Minimal Nix configuration
experimental-features = nix-command flakes
substituters = https://cache.nixos.org https://nix-community.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
EOF
    echo -e "  ${GREEN}Created minimal nix.conf${NC}"
fi

# Verify caches are configured
echo -e "  ${BLUE}Binary caches configured:${NC}"
echo -e "    - cache.nixos.org (official)"
echo -e "    - nix-community.cachix.org (community)"

# ==============================================================================
# STEP 3: INSTALL PACKAGES
# ==============================================================================

# Determine installation method
if [[ "$USE_FLAKES" == "auto" ]]; then
    if [[ -f "$DOTFILES_DIR/flake.nix" ]] && nix flake --help &>/dev/null; then
        USE_FLAKES="yes"
    else
        USE_FLAKES="no"
    fi
fi

if [[ "$USE_FLAKES" == "yes" ]]; then
    echo -e "${YELLOW}==> Installing packages via Nix flakes...${NC}"

    # Change to dotfiles directory for flake operations
    cd "$DOTFILES_DIR"

    # Generate flake.lock if it doesn't exist
    if [[ ! -f "flake.lock" ]]; then
        echo -e "  ${BLUE}Generating flake.lock...${NC}"
        nix flake lock
    fi

    # Install all packages from the flake
    echo -e "  ${BLUE}Installing packages (this may take a moment on first run)...${NC}"
    if nix profile install ".#default" 2>/dev/null; then
        echo -e "${GREEN}  Packages installed successfully via flake${NC}"
    else
        # Package might already be installed, try upgrading
        echo -e "  ${YELLOW}Packages may already be installed, checking...${NC}"
        nix profile list 2>/dev/null || true
    fi

    cd - > /dev/null

else
    echo -e "${YELLOW}==> Installing packages from packages.txt (legacy method)...${NC}"

    while IFS= read -r package; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue

        # Remove leading/trailing whitespace
        package=$(echo "$package" | xargs)

        echo -n "  Installing $package... "
        if nix profile install "nixpkgs#$package" 2>/dev/null; then
            echo -e "${GREEN}done${NC}"
        else
            # Package might already be installed
            echo -e "${YELLOW}(already installed or not found)${NC}"
        fi
    done < "$DOTFILES_DIR/packages.txt"
fi

# ==============================================================================
# STEP 4: INSTALL NON-NIXPKGS PACKAGES
# ==============================================================================

echo -e "${YELLOW}==> Checking packages not in nixpkgs...${NC}"

# Claude Code (installed via npm)
if command -v npm &>/dev/null; then
    if ! command -v claude &>/dev/null; then
        echo -e "  ${BLUE}Installing claude-code via npm...${NC}"
        npm install -g @anthropic-ai/claude-code 2>/dev/null || \
            echo -e "  ${YELLOW}Could not install claude-code (requires npm login or permissions)${NC}"
    else
        echo -e "  ${GREEN}claude-code already installed${NC}"
    fi
else
    echo -e "  ${YELLOW}npm not found, skipping claude-code (install nodejs first)${NC}"
fi

# ==============================================================================
# STEP 5: SYMLINK DOTFILES
# ==============================================================================

echo -e "${YELLOW}==> Symlinking dotfiles...${NC}"

# Function to backup and symlink
backup_and_link() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "  ${YELLOW}Backing up $(basename "$target") -> $backup${NC}"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        # Remove old symlink
        rm "$target"
    fi

    ln -s "$source" "$target"
    echo -e "  ${GREEN}Linked $(basename "$target")${NC}"
}

# Link top-level dotfiles
for file in "$DOTFILES_DIR"/.[^.]*; do
    # Skip if not a file or directory
    [ -e "$file" ] || continue

    # Skip .git directory
    filename=$(basename "$file")
    [[ "$filename" == ".git" ]] && continue

    # Skip .config (we'll handle it separately)
    [[ "$filename" == ".config" ]] && continue

    if [ -f "$file" ]; then
        backup_and_link "$file" "$HOME/$filename"
    fi
done

# Handle .config directory specially
if [ -d "$DOTFILES_DIR/.config" ]; then
    echo -e "${YELLOW}==> Symlinking .config directories...${NC}"
    mkdir -p "$HOME/.config"

    for config_item in "$DOTFILES_DIR/.config"/*; do
        [ -e "$config_item" ] || continue
        itemname=$(basename "$config_item")
        backup_and_link "$config_item" "$HOME/.config/$itemname"
    done
fi

# ==============================================================================
# STEP 6: VERIFICATION
# ==============================================================================

echo ""
echo -e "${GREEN}==> Installation complete!${NC}"
echo ""

# Show summary
echo -e "${BLUE}Summary:${NC}"
if [[ "$USE_FLAKES" == "yes" ]]; then
    echo -e "  Package method: ${GREEN}Nix Flakes${NC} (reproducible)"
    echo -e "  Lock file: ${GREEN}flake.lock${NC}"
else
    echo -e "  Package method: ${YELLOW}Legacy (packages.txt)${NC}"
    echo -e "  Consider migrating to flakes for reproducibility"
fi

# Count installed packages
pkg_count=$(nix profile list 2>/dev/null | grep -c "^" || echo "?")
echo -e "  Installed packages: ${GREEN}$pkg_count${NC}"

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Verify symlinks: ./verify-links.sh"
echo "  3. Check Neovim: nvim +checkhealth"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  nix flake update       # Update all packages"
echo "  nix profile upgrade    # Apply updates"
echo "  ./sync.sh              # Sync installed packages to packages.txt"
echo "  nix-collect-garbage -d # Clean old generations"
