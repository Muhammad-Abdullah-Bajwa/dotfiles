#!/usr/bin/env bash
set -e

echo "=== Nix Flake Migration ==="
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    OS="linux"
fi

# Step 1: Restart nix daemon
echo "[1/4] Restarting nix daemon..."
if [[ "$OS" == "macos" ]]; then
    # Support both official Nix and Determinate Nix installers
    if [[ -f /Library/LaunchDaemons/systems.determinate.nix-daemon.plist ]]; then
        sudo launchctl kickstart -k system/systems.determinate.nix-daemon
    elif [[ -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist ]]; then
        sudo launchctl kickstart -k system/org.nixos.nix-daemon
    else
        echo "      Warning: No nix-daemon plist found. Skipping restart."
    fi
else
    sudo systemctl restart nix-daemon
fi
echo "      Done."
echo ""

# Step 2: Verify binary caches
echo "[2/4] Verifying binary caches..."
if nix show-config 2>/dev/null | grep -q "nix-community.cachix.org"; then
    echo "      Binary caches configured correctly."
else
    echo "      Warning: nix-community cache not detected."
    echo "      Ensure ~/.config/nix/nix.conf is symlinked."
fi
echo ""

# Step 3: Check flake validity
echo "[3/4] Checking flake validity..."
cd ~/dotfiles
if nix flake check 2>/dev/null; then
    echo "      Flake is valid."
else
    echo "      Warning: Flake check had issues (may be okay on first run)."
fi
echo ""

# Step 4: Install packages from flake
echo "[4/4] Installing packages from flake..."
echo "      This may take a moment..."
nix profile install .#
echo "      Done."
echo ""

# Verification
echo "=== Verification ==="
echo ""
echo "Testing key tools..."
for cmd in nvim hx fzf rg zoxide bat; do
    if command -v $cmd &>/dev/null; then
        echo "  ✓ $cmd"
    else
        echo "  ✗ $cmd (not found)"
    fi
done
echo ""

echo "=== Migration Complete ==="
echo ""
echo "Next steps:"
echo "  1. Open a new terminal to pick up changes"
echo "  2. Run: nix profile list  (to see installed packages)"
echo "  3. Commit your changes when ready"
echo ""
