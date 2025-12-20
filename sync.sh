#!/usr/bin/env bash
#
# Sync script for dotfiles
# Updates packages.txt with any packages installed via Nix that aren't already listed
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$DOTFILES_DIR/packages.txt"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==> Syncing packages.txt with installed Nix packages${NC}"

# Get currently installed packages from nix profile (strip ANSI color codes)
installed_packages=$(nix profile list | grep "Name:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $2}' | sort)

# Read packages from packages.txt (excluding comments and empty lines)
existing_packages=$(grep -v '^[[:space:]]*#' "$PACKAGES_FILE" | grep -v '^[[:space:]]*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort)

# Find packages that are installed but not in packages.txt
new_packages=()
while IFS= read -r pkg; do
    if ! echo "$existing_packages" | grep -q "^${pkg}$"; then
        new_packages+=("$pkg")
    fi
done <<< "$installed_packages"

# Add new packages to packages.txt
if [ ${#new_packages[@]} -eq 0 ]; then
    echo -e "${GREEN}==> packages.txt is up to date! No new packages to add.${NC}"
else
    echo -e "${YELLOW}==> Found ${#new_packages[@]} new package(s) to add:${NC}"
    for pkg in "${new_packages[@]}"; do
        echo "  + $pkg"
        echo "$pkg" >> "$PACKAGES_FILE"
    done

    echo -e "${GREEN}==> Updated packages.txt${NC}"

    # Sort packages.txt (keep comments at top, sort the rest)
    temp_file=$(mktemp)

    # Extract header comments
    grep '^[[:space:]]*#' "$PACKAGES_FILE" > "$temp_file"
    echo "" >> "$temp_file"

    # Sort package names
    grep -v '^[[:space:]]*#' "$PACKAGES_FILE" | grep -v '^[[:space:]]*$' | sort -u >> "$temp_file"

    mv "$temp_file" "$PACKAGES_FILE"

    echo -e "${BLUE}==> Sorted and deduplicated packages.txt${NC}"
fi

# Show summary
total_packages=$(echo "$installed_packages" | wc -l | xargs)
echo ""
echo -e "${BLUE}Total packages installed: $total_packages${NC}"
