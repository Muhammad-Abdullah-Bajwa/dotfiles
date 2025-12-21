# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **dotfiles repository** managed with Nix flakes and symlinks. It contains shell configurations (zsh, fish, nushell), editor configs (Neovim, Helix), and various CLI tool configurations. The repository is designed for easy deployment on new machines and maintaining consistency across development environments.

## Repository Structure

```
~/dotfiles/
├── install.sh          # Bootstrap: installs Nix, configures caches, installs packages
├── post-install.sh     # Optional post-install tasks and additional tools
├── sync.sh             # Syncs installed packages and updates flake.lock
├── verify-links.sh     # Verifies all symlinks are correct
├── flake.nix           # Nix flake definition (reproducible packages)
├── flake.lock          # Locked package versions (auto-generated)
├── packages.txt        # Human-readable package list (reference)
├── .zshrc              # Zsh configuration (optimized <200ms startup)
├── .gitconfig          # Git configuration
└── .config/
    ├── nix/            # Nix settings (binary caches, flakes)
    ├── nvim/           # Neovim config (modular lazy.nvim-based)
    ├── helix/          # Helix editor config
    ├── fish/           # Fish shell config
    ├── nushell/        # Nushell config
    ├── zellij/         # Terminal multiplexer config
    ├── atuin/          # Shell history manager
    └── ...
```

## Common Commands

### Initial Setup
```bash
# On a fresh machine
git clone https://github.com/Muhammad-Abdullah-Bajwa/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Package Management (Flake-Based - Recommended)
```bash
# Install all packages from flake
nix profile add .#default

# Update nixpkgs to latest
nix flake update

# Apply updates to installed packages
nix profile upgrade --all

# Check flake validity
nix flake check

# Enter dev shell with all packages
nix develop
```

### Package Management (Legacy)
```bash
# Force legacy installation method
./install.sh --legacy

# Install single package manually
nix profile add nixpkgs#<package>

# Sync installed packages to packages.txt
./sync.sh

# Update flake.lock to latest nixpkgs
./sync.sh --update
```

### Common Nix Commands
```bash
# List installed packages
nix profile list

# Remove a package
nix profile remove <name>

# Search for packages
nix search nixpkgs <name>

# Check package version
nix eval --raw nixpkgs#<package>.version

# Garbage collect old generations
nix-collect-garbage -d

# Check binary cache configuration
nix show-config | grep substituters
```

### Symlink Verification
```bash
./verify-links.sh
```

### Dotfile Management
Since dotfiles are symlinked, edits in `~/` or `~/.config/` are immediately reflected in the repo:
```bash
# Edit a config
nvim ~/.zshrc  # or hx ~/.zshrc

# Commit changes
cd ~/dotfiles
git add .
git commit -m "Update config"
git push
```

## Key Architectural Details

### Nix Flakes
The repository uses Nix flakes for reproducible package management:
- **flake.nix** - Defines all packages to install
- **flake.lock** - Locks exact versions for reproducibility
- **packages.txt** - Human-readable reference (synced with flake.nix)

Benefits:
- Reproducible builds across machines
- Fast updates with `nix flake update`
- Better dependency resolution
- Standard in modern Nix ecosystem

### Binary Caches
Configured in `.config/nix/nix.conf` for fast package downloads:
- **cache.nixos.org** - Official Nixpkgs cache
- **nix-community.cachix.org** - Community packages (neovim, rust-analyzer, etc.)

Most packages download in seconds instead of building from source.

### Symlinking Strategy

**CRITICAL: Understand this before making any symlink changes!**

This repository uses a **two-tier symlinking strategy**:

#### 1. File-Level Symlinks (Top-Level Dotfiles)
Top-level dotfiles are symlinked as individual files:
```
~/.zshrc     → ~/dotfiles/.zshrc      (file symlink)
~/.bashrc    → ~/dotfiles/.bashrc     (file symlink)
~/.gitconfig → ~/dotfiles/.gitconfig  (file symlink)
```

#### 2. Directory-Level Symlinks (.config/)
`.config` subdirectories are symlinked as **entire directories**, not individual files:
```
~/.config/nix/     → ~/dotfiles/.config/nix/     (directory symlink)
~/.config/nvim/    → ~/dotfiles/.config/nvim/    (directory symlink)
~/.config/fish/    → ~/dotfiles/.config/fish/    (directory symlink)
~/.config/helix/   → ~/dotfiles/.config/helix/   (directory symlink)
~/.config/zellij/  → ~/dotfiles/.config/zellij/  (directory symlink)
~/.config/atuin/   → ~/dotfiles/.config/atuin/   (directory symlink)
```

**Inside these directory-symlinked paths, all files are regular files:**
```
~/dotfiles/.config/nix/nix.conf       (regular file, NOT a symlink)
~/dotfiles/.config/nvim/init.lua      (regular file, NOT a symlink)
~/dotfiles/.config/fish/config.fish   (regular file, NOT a symlink)
```

#### How to Diagnose Symlink Issues

**BEFORE attempting any symlink fixes, check the directory first:**
```bash
# Check if a directory is symlinked
ls -ld ~/.config/nix

# If output shows "lrwxr-xr-x" and "->", it's a directory symlink!
# Example: ~/.config/nix -> /Users/you/dotfiles/.config/nix
```

#### What NOT to Do ⚠️

**NEVER create file-level symlinks inside directory-symlinked paths!**

For example, if `~/.config/nix/` is already a directory symlink, **do NOT do this:**
```bash
# ❌ WRONG - Creates a symlink loop!
ln -s ~/dotfiles/.config/nix/nix.conf ~/.config/nix/nix.conf

# Why it breaks:
# ~/.config/nix/ → ~/dotfiles/.config/nix/  (directory symlink)
# When you create ~/.config/nix/nix.conf → ~/dotfiles/.config/nix/nix.conf
# It actually creates: ~/dotfiles/.config/nix/nix.conf → ~/dotfiles/.config/nix/nix.conf
# Result: INFINITE LOOP! ♾️
```

#### How to Fix Broken Files in Directory-Symlinked Paths

If a file inside a directory-symlinked path is broken (e.g., `~/dotfiles/.config/nix/nix.conf`):

**✅ CORRECT approach:**
```bash
# 1. Restore the regular file from git
git -C ~/dotfiles checkout HEAD -- .config/nix/nix.conf

# OR manually extract from git history
git -C ~/dotfiles show HEAD:.config/nix/nix.conf > ~/dotfiles/.config/nix/nix.conf

# 2. Verify it's a regular file (NOT a symlink)
file ~/dotfiles/.config/nix/nix.conf
# Should say: "ASCII text" (not "symbolic link")

# 3. Test access through the directory symlink
cat ~/.config/nix/nix.conf
# Should work automatically via the directory symlink
```

**The directory symlink handles everything - no file symlinks needed!**

#### Setup Details
- The `install.sh` script creates all symlinks automatically
- Backs up existing files/dirs before creating symlinks (`.backup.YYYYMMDD_HHMMSS`)
- Use `./verify-links.sh` to check all symlinks are correct

### Shell Configuration Philosophy (.zshrc)
The `.zshrc` is heavily optimized for startup speed (target: <200ms):
- **Compinit caching**: Completion system only refreshes every 24 hours
- **Lazy-loading via cache files**: Tools like `zoxide`, `atuin`, `starship`, `carapace`, and `fzf` cache their init scripts to `~/.cache/zsh/`
- **Deferred syntax highlighting**: `zsh-syntax-highlighting` is loaded via `precmd` hook to avoid blocking startup
- Aliases use zsh-native `(( $+commands[cmd] ))` checks instead of `command -v`

### Neovim Configuration Architecture
Located in `.config/nvim/`, this is a **modular, lazy.nvim-based** config:

**Design Philosophy:**
- **One key, one action** - No "smart" Tab with context-dependent behavior
- **Explicit over implicit** - Clear configurations with heavy commenting
- **Beginner-friendly** - Every non-obvious setting is explained

**Structure:**
- `init.lua` - Entry point, loads all modules
- `lua/config/` - Core Neovim settings (no plugins)
  - `options.lua` - Editor settings
  - `keymaps.lua` - Non-plugin keybindings
  - `autocmds.lua` - Autocommands
  - `lazy.lua` - Plugin manager bootstrap
- `lua/plugins/` - One file per plugin/feature
  - Each file returns a lazy.nvim spec table
  - `init.lua` imports all plugin files

**Language Support:**
- Configured for C++, Rust, and C# development
- LSP servers auto-installed via Mason
- Add new servers by editing `servers` table in `lua/plugins/lsp.lua`
- Uses nvim-treesitter 1.0+ API (modern, simplified)

**Key Conventions:**
- Leader key: `<Space>`
- 4-space indentation
- Section headers use `====` comment blocks
- Plugin-specific keymaps defined in plugin files using `keys` table

**Important Files:**
- `lua/plugins/lsp.lua` - Add language servers here
- `lua/plugins/init.lua` - Import new plugin files here
- `README.md` and `AGENTS.md` in `.config/nvim/` - Full documentation

**Testing Neovim Changes:**
1. Edit config file
2. Restart Neovim (`:qa` then `nvim`)
3. Run `:checkhealth` to verify
4. Run `:Lazy` to check plugin status

### Git Configuration
- Uses `delta` as pager (configured in `.gitconfig`)
- Default editor: `hx` (Helix)
- Default branch: `main`
- GitHub credential helper via `gh` CLI

## Tool Stack

### Shells
- **zsh** - Primary shell (highly optimized startup)
- **fish** - Alternative shell
- **nushell** - Data-focused shell

### Editors
- **Neovim** - Primary editor (modular Lua config)
- **Helix** - Secondary editor (configured as git core.editor)

### CLI Tools (from flake.nix/packages.txt)
- **eza** - Modern `ls` replacement
- **bat** - Modern `cat` with syntax highlighting
- **fd** - Modern `find` replacement
- **ripgrep** (`rg`) - Fast grep
- **delta** - Git diff pager
- **fzf** - Fuzzy finder
- **zoxide** - Smart `cd` replacement
- **atuin** - Shell history manager
- **starship** - Cross-shell prompt
- **carapace** - Multi-shell completion bridge
- **zellij** - Terminal multiplexer
- **procs** - Modern `ps` replacement

### Development Tools
- **Git** with `gh` CLI for GitHub
- **Rust toolchain** (rustup)
- **Node.js** (for Copilot, some LSPs)
- **Zig** - Programming language
- **Nix** package manager with flakes

## Important Notes

### When Modifying Neovim Config
- Preserve heavy commenting style
- Each plugin gets its own file in `lua/plugins/`
- Never edit `lazy-lock.json` manually
- Use `:Lazy sync` to update plugins
- Read `AGENTS.md` in `.config/nvim/` for detailed guidance

### When Adding New Packages
Three workflows:
1. **Flake (recommended)**: Add to `flake.nix` packageList, then `nix profile add .#`
2. **Declarative**: Add to `packages.txt`, then `./install.sh --legacy`
3. **Imperative**: `nix profile add nixpkgs#<package>`, then run `./sync.sh`

### When Adding New Dotfiles
```bash
# Move to repo
mv ~/.vimrc ~/dotfiles/

# Re-run install to create symlink
./install.sh

# Or manually symlink
ln -s ~/dotfiles/.vimrc ~/.vimrc
```

### Performance Considerations
- Zsh config caches init scripts - delete `~/.cache/zsh/` to regenerate
- Neovim uses lazy-loading - check `:Lazy profile` for startup time
- Compinit dump regenerates every 24 hours automatically
- Binary caches avoid slow local builds

### Packages Not in Nixpkgs
Some packages must be installed separately:
```bash
# Claude Code (via npm)
npm install -g @anthropic-ai/claude-code

# opencode - check project repository for installation
```
