# Migration Guide: Flake-Based Package Management

This guide walks you through migrating from the legacy `packages.txt` approach to Nix flakes with binary caches.

## Prerequisites

- Nix installed (via Determinate Systems installer)
- Git repository with uncommitted changes (the new files)

## Phase 1: Binary Caches (Immediate Impact)

**Time:** ~2 minutes
**Impact:** 10-50x faster package installs

### Step 1: Apply the nix.conf

```bash
# The new nix.conf is already in the repo
# Symlink it to your config
mkdir -p ~/.config/nix
ln -sf ~/dotfiles/.config/nix/nix.conf ~/.config/nix/nix.conf
```

### Step 2: Verify Caches

```bash
# Check configuration
nix show-config | grep substituters
# Should show: cache.nixos.org nix-community.cachix.org

# Test cache speed (should be <2 seconds)
time nix build nixpkgs#bat --no-link
```

### Step 3: Restart Nix Daemon (if needed)

```bash
# macOS
sudo launchctl kickstart -k system/org.nixos.nix-daemon

# Linux
sudo systemctl restart nix-daemon
```

## Phase 2: Flake Migration

**Time:** ~5 minutes
**Impact:** Reproducible, versioned packages

### Step 1: Add Flake Files to Git

```bash
cd ~/dotfiles
git add flake.nix .config/nix/nix.conf
```

### Step 2: Generate Lock File

```bash
nix flake lock
# This creates flake.lock with pinned versions
```

### Step 3: Verify Flake

```bash
nix flake check
# Should pass without errors
```

### Step 4: Install via Flake

```bash
# Option A: Install all packages as a bundle
nix profile install .#

# Option B: Keep existing packages, just verify flake works
nix develop  # Enter shell with all packages
exit
```

## Phase 3: Full Migration

**Time:** ~10 minutes
**Impact:** Complete modernization

### Step 1: Clean Up Old Profile (Optional)

```bash
# List current packages
nix profile list

# Remove all packages (fresh start)
nix profile remove '.*'

# Or keep them and just add the flake bundle
```

### Step 2: Install from Flake

```bash
nix profile install .#
```

### Step 3: Verify Installation

```bash
# Check all tools are available
which neovim helix fzf ripgrep zoxide

# Check versions match flake
neovim --version
```

### Step 4: Commit Changes

```bash
cd ~/dotfiles
git add .
git commit -m "feat(nix): migrate to flakes for reproducible builds

- Add flake.nix with all packages
- Add .config/nix/nix.conf for binary caches
- Update install.sh to support flakes
- Update sync.sh for flake.lock handling
- Update documentation"
```

## Verification Checklist

Run these commands to verify everything works:

```bash
# Nix Infrastructure
nix show-config | grep substituters    # Binary caches configured
nix flake check                         # Flake is valid
nix profile list                        # Packages installed

# Shell Startup
time zsh -i -c exit                     # Should be <200ms

# Tool Integrations
z /tmp && cd -                          # zoxide works
echo "test" | bat                       # bat works
rg --version                            # ripgrep works
fzf --version                           # fzf works

# Neovim
nvim +checkhealth +qa                   # No errors
nvim +"Lazy health" +qa                 # Plugins healthy

# Symlinks
./verify-links.sh                       # All symlinks correct
```

## Rollback Procedure

If something goes wrong:

```bash
# Remove flake packages
nix profile remove '.*'

# Reinstall via legacy method
./install.sh --legacy

# Or revert git changes
git checkout -- flake.nix install.sh sync.sh
```

## Updating Packages

### Weekly Updates

```bash
cd ~/dotfiles

# Update nixpkgs
nix flake update

# Apply updates
nix profile upgrade --all

# Commit lock file
git add flake.lock
git commit -m "chore(nix): update flake.lock"
```

### Adding New Packages

1. Edit `flake.nix` - add to `packageList`
2. Edit `packages.txt` - add for documentation
3. Run: `nix profile install .#`

## Performance Comparison

### Before (Building from Source)

| Package | Time |
|---------|------|
| neovim | 10-15 min |
| rust-analyzer | 15-20 min |
| helix | 5-10 min |
| Total install | 30-60 min |

### After (Binary Caches)

| Package | Time |
|---------|------|
| neovim | <2 sec |
| rust-analyzer | <5 sec |
| helix | <2 sec |
| Total install | <1 min |

## Troubleshooting

### "Path not tracked by Git"

```bash
git add flake.nix
nix flake check
```

### Packages still building

```bash
# Verify caches
nix show-config | grep substituters

# Force cache check
nix build nixpkgs#neovim --no-link -L
# Look for "copying path" vs "building"
```

### Flake check fails

```bash
# Check for syntax errors
nix flake show

# Check specific system
nix flake check --system aarch64-darwin
```

### Profile conflicts

```bash
# Remove conflicting package
nix profile remove <index>

# Or remove all and reinstall
nix profile remove '.*'
nix profile install .#
```

## Future Enhancements

Consider these for further optimization:

1. **Home Manager** - Declarative dotfile management
2. **Cachix** - Personal binary cache
3. **nix-direnv** - Per-project environments
4. **devenv** - Development environments
5. **flake-parts** - Modular flake structure

These are optional and can be added incrementally.
