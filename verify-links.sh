#!/usr/bin/env bash
#
# Verify that all dotfiles are properly symlinked
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==> Verifying dotfile symlinks${NC}"
echo ""

errors=0
warnings=0
success=0

# Check top-level dotfiles
echo -e "${BLUE}Checking top-level dotfiles:${NC}"
for file in "$DOTFILES_DIR"/.[^.]*; do
    [ -e "$file" ] || continue

    filename=$(basename "$file")

    # Skip .git and .config
    [[ "$filename" == ".git" ]] && continue
    [[ "$filename" == ".config" ]] && continue

    # Only check files, not directories
    [ -f "$file" ] || continue

    target="$HOME/$filename"

    if [ -L "$target" ]; then
        # It's a symlink, check if it points to the right place
        link_target=$(readlink "$target")
        if [ "$link_target" = "$file" ]; then
            echo -e "  ${GREEN}✓${NC} $filename -> symlinked correctly"
            ((success++))
        else
            echo -e "  ${YELLOW}⚠${NC} $filename -> symlinked to wrong location: $link_target"
            echo -e "    Expected: $file"
            ((warnings++))
        fi
    elif [ -e "$target" ]; then
        echo -e "  ${RED}✗${NC} $filename -> exists but is NOT a symlink"
        ((errors++))
    else
        echo -e "  ${YELLOW}⚠${NC} $filename -> not linked (file doesn't exist in home)"
        ((warnings++))
    fi
done

echo ""
echo -e "${BLUE}Checking .config directories:${NC}"

# Check .config items
if [ -d "$DOTFILES_DIR/.config" ]; then
    for config_item in "$DOTFILES_DIR/.config"/*; do
        [ -e "$config_item" ] || continue

        itemname=$(basename "$config_item")
        target="$HOME/.config/$itemname"

        if [ -L "$target" ]; then
            # It's a symlink, check if it points to the right place
            link_target=$(readlink "$target")
            if [ "$link_target" = "$config_item" ]; then
                echo -e "  ${GREEN}✓${NC} .config/$itemname -> symlinked correctly"
                ((success++))
            else
                echo -e "  ${YELLOW}⚠${NC} .config/$itemname -> symlinked to wrong location: $link_target"
                echo -e "    Expected: $config_item"
                ((warnings++))
            fi
        elif [ -e "$target" ]; then
            echo -e "  ${RED}✗${NC} .config/$itemname -> exists but is NOT a symlink"
            ((errors++))
        else
            echo -e "  ${YELLOW}⚠${NC} .config/$itemname -> not linked (doesn't exist in ~/.config)"
            ((warnings++))
        fi
    done
fi

echo ""
echo -e "${BLUE}==> Summary${NC}"
echo -e "  ${GREEN}Correctly linked: $success${NC}"
echo -e "  ${YELLOW}Warnings: $warnings${NC}"
echo -e "  ${RED}Errors: $errors${NC}"

if [ $errors -gt 0 ]; then
    echo ""
    echo -e "${RED}Some dotfiles are not properly symlinked!${NC}"
    echo "Run ./install.sh to fix the symlinks."
    exit 1
elif [ $warnings -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Some dotfiles are not linked yet.${NC}"
    exit 0
else
    echo ""
    echo -e "${GREEN}All dotfiles are properly symlinked!${NC}"
    exit 0
fi
