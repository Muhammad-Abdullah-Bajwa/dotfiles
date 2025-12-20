#!/usr/bin/env bash
#
# Sync script for dotfiles
# Updates packages.txt with any packages installed via Nix that aren't already listed
# Also handles flake.lock updates
#
# USAGE:
#   ./sync.sh                # Sync packages.txt with installed packages
#   ./sync.sh --update       # Also update flake.lock to latest nixpkgs
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$DOTFILES_DIR/packages.txt"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse arguments
UPDATE_FLAKE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_FLAKE=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: ./sync.sh [--update]"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}==> Syncing dotfiles package management${NC}"
echo ""

# ==============================================================================
# STEP 1: SYNC PACKAGES.TXT WITH INSTALLED PACKAGES
# ==============================================================================

echo -e "${BLUE}==> Syncing packages.txt with installed Nix packages${NC}"

# Get currently installed packages from nix profile (strip ANSI color codes)
# The format varies depending on Nix version, so we try multiple patterns
installed_packages=""
if nix profile list --json &>/dev/null; then
    # New Nix format (JSON output)
    installed_packages=$(nix profile list --json 2>/dev/null | jq -r '.elements | to_entries[] | .value.attrPath // .value.storePaths[0]' 2>/dev/null | sed 's/.*\.//g' | sort -u)
else
    # Legacy format
    installed_packages=$(nix profile list 2>/dev/null | grep -oP '(?<=Name:\s)[\w-]+' | sort -u)
fi

# Fallback: parse the output line by line
if [[ -z "$installed_packages" ]]; then
    installed_packages=$(nix profile list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | grep -E "^[0-9]|Name:" | grep "Name:" | awk '{print $2}' | sort -u)
fi

if [[ -z "$installed_packages" ]]; then
    echo -e "  ${YELLOW}Could not parse installed packages. Skipping sync.${NC}"
else
    # Read packages from packages.txt (excluding comments and empty lines)
    existing_packages=$(grep -v '^[[:space:]]*#' "$PACKAGES_FILE" 2>/dev/null | grep -v '^[[:space:]]*$' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sort -u)

    # Find packages that are installed but not in packages.txt
    new_packages=()
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if ! echo "$existing_packages" | grep -q "^${pkg}$"; then
            new_packages+=("$pkg")
        fi
    done <<< "$installed_packages"

    # Add new packages to packages.txt
    if [ ${#new_packages[@]} -eq 0 ]; then
        echo -e "  ${GREEN}packages.txt is up to date! No new packages to add.${NC}"
    else
        echo -e "  ${YELLOW}Found ${#new_packages[@]} new package(s) to add:${NC}"
        for pkg in "${new_packages[@]}"; do
            echo "    + $pkg"
            echo "$pkg" >> "$PACKAGES_FILE"
        done

        echo -e "  ${GREEN}Updated packages.txt${NC}"

        # Sort packages.txt (keep comments at top, sort the rest)
        temp_file=$(mktemp)

        # Extract header comments
        grep '^[[:space:]]*#' "$PACKAGES_FILE" > "$temp_file"
        echo "" >> "$temp_file"

        # Sort package names
        grep -v '^[[:space:]]*#' "$PACKAGES_FILE" | grep -v '^[[:space:]]*$' | sort -u >> "$temp_file"

        mv "$temp_file" "$PACKAGES_FILE"

        echo -e "  ${BLUE}Sorted and deduplicated packages.txt${NC}"
    fi
fi

# ==============================================================================
# STEP 2: HANDLE FLAKE.LOCK (if using flakes)
# ==============================================================================

if [[ -f "$DOTFILES_DIR/flake.nix" ]]; then
    echo ""
    echo -e "${BLUE}==> Flake status${NC}"

    if [[ -f "$DOTFILES_DIR/flake.lock" ]]; then
        # Show current nixpkgs revision
        nixpkgs_rev=$(jq -r '.nodes.nixpkgs.locked.rev // "unknown"' "$DOTFILES_DIR/flake.lock" 2>/dev/null | head -c 7)
        nixpkgs_date=$(jq -r '.nodes.nixpkgs.locked.lastModified // 0' "$DOTFILES_DIR/flake.lock" 2>/dev/null)

        if [[ "$nixpkgs_date" != "0" ]] && [[ "$nixpkgs_date" != "null" ]]; then
            nixpkgs_date=$(date -r "$nixpkgs_date" "+%Y-%m-%d" 2>/dev/null || date -d "@$nixpkgs_date" "+%Y-%m-%d" 2>/dev/null || echo "unknown")
        else
            nixpkgs_date="unknown"
        fi

        echo -e "  Current nixpkgs: ${GREEN}${nixpkgs_rev}${NC} (${nixpkgs_date})"

        if [[ "$UPDATE_FLAKE" == true ]]; then
            echo -e "  ${YELLOW}Updating flake.lock...${NC}"
            cd "$DOTFILES_DIR"
            nix flake update
            cd - > /dev/null

            # Show new revision
            new_rev=$(jq -r '.nodes.nixpkgs.locked.rev // "unknown"' "$DOTFILES_DIR/flake.lock" 2>/dev/null | head -c 7)
            echo -e "  Updated nixpkgs: ${GREEN}${new_rev}${NC}"
            echo ""
            echo -e "  ${BLUE}To apply the update, run:${NC}"
            echo -e "    nix profile upgrade --all"
        else
            echo -e "  ${BLUE}Run './sync.sh --update' to update flake.lock${NC}"
        fi
    else
        echo -e "  ${YELLOW}flake.lock not found. Run 'nix flake lock' to generate.${NC}"
    fi
fi

# ==============================================================================
# STEP 3: SHOW SUMMARY
# ==============================================================================

echo ""
echo -e "${BLUE}==> Summary${NC}"

# Count packages
if [[ -n "$installed_packages" ]]; then
    installed_count=$(echo "$installed_packages" | wc -l | xargs)
else
    installed_count=$(nix profile list 2>/dev/null | grep -c "^" || echo "?")
fi
packages_txt_count=$(grep -v '^[[:space:]]*#' "$PACKAGES_FILE" 2>/dev/null | grep -v '^[[:space:]]*$' | wc -l | xargs)

echo -e "  Installed packages: ${GREEN}$installed_count${NC}"
echo -e "  packages.txt entries: ${GREEN}$packages_txt_count${NC}"

# Show flake status
if [[ -f "$DOTFILES_DIR/flake.nix" ]]; then
    if [[ -f "$DOTFILES_DIR/flake.lock" ]]; then
        echo -e "  Flake status: ${GREEN}locked${NC}"
    else
        echo -e "  Flake status: ${YELLOW}unlocked${NC}"
    fi
fi

echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  nix profile list       # List installed packages"
echo "  nix flake update       # Update flake.lock to latest nixpkgs"
echo "  nix profile upgrade    # Apply flake.lock updates"
echo "  nix-collect-garbage -d # Clean up old generations"
