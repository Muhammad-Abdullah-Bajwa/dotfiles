#!/usr/bin/env bash
#
# Bootstrap script for dotfiles
# Installs Nix (if needed), packages, and symlinks dotfiles
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Dotfiles directory: $DOTFILES_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Install Nix if not present
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}==> Installing Nix (single-user)...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
        sh -s -- install --no-confirm

    # Source Nix for this session
    . ~/.nix-profile/etc/profile.d/nix.sh
    echo -e "${GREEN}==> Nix installed successfully${NC}"
else
    echo -e "${GREEN}==> Nix already installed${NC}"
fi

# Install packages from packages.txt
echo -e "${YELLOW}==> Installing packages...${NC}"
while IFS= read -r package; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue

    # Remove leading/trailing whitespace
    package=$(echo "$package" | xargs)

    echo "  Installing $package..."
    if nix profile install "nixpkgs#$package" 2>/dev/null; then
        echo -e "${GREEN}    ✓ $package${NC}"
    else
        # Package might already be installed
        echo -e "${YELLOW}    ~ $package (already installed or error)${NC}"
    fi
done < "$DOTFILES_DIR/packages.txt"

# Symlink dotfiles
echo -e "${YELLOW}==> Symlinking dotfiles...${NC}"

# Function to backup and symlink
backup_and_link() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "  ${YELLOW}Backing up existing $(basename "$target") -> $backup${NC}"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        # Remove old symlink
        rm "$target"
    fi

    ln -s "$source" "$target"
    echo -e "  ${GREEN}✓ Linked $(basename "$target")${NC}"
}

# Link top-level dotfiles
for file in "$DOTFILES_DIR"/.[^.]*; do
    # Skip if not a file or directory
    [ -e "$file" ] || continue

    # Skip .git directory and this script
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

echo -e "${GREEN}==> Done! Dotfiles installed successfully.${NC}"
echo ""
echo "Next steps:"
echo "  1. cd ~/dotfiles"
echo "  2. git init"
echo "  3. git add ."
echo "  4. git commit -m 'Initial dotfiles commit'"
echo "  5. Create a repo on GitHub and push"
