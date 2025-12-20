# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **dotfiles repository** managed with Nix package management and symlinks. It contains shell configurations (zsh, fish), editor configs (Neovim, Helix), and various CLI tool configurations. The repository is designed for easy deployment on new machines and maintaining consistency across development environments.

## Repository Structure

```
~/dotfiles/
├── install.sh          # Bootstrap: installs Nix, packages, and symlinks dotfiles
├── sync.sh             # Syncs manually-installed Nix packages back to packages.txt
├── verify-links.sh     # Verifies all symlinks are correct
├── packages.txt        # List of Nix packages to install
├── .bashrc, .zshrc     # Shell configurations (symlinked to ~/)
├── .gitconfig          # Git configuration
└── .config/            # App configs (each subdir symlinked to ~/.config/)
    ├── nvim/           # Neovim config (heavily modular, lazy.nvim-based)
    ├── helix/          # Helix editor config
    ├── fish/           # Fish shell config
    ├── zellij/         # Terminal multiplexer config
    ├── atuin/          # Shell history manager
    └── ...
```

## Common Commands

### Initial Setup
```bash
# On a fresh machine
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Package Management
```bash
# Sync installed packages to packages.txt (after manual nix profile install)
./sync.sh

# Install packages from packages.txt
while read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  nix profile install "nixpkgs#$(echo $pkg | xargs)"
done < packages.txt

# List installed Nix packages
nix profile list

# Remove a package
nix profile remove <name or index>

# Upgrade all packages
nix profile upgrade '.*'

# Garbage collect
nix-collect-garbage -d
```

### Symlink Verification
```bash
# Verify all symlinks point to correct locations
./verify-links.sh
```

### Dotfile Management
Since dotfiles are symlinked, edits in `~/` or `~/.config/` are immediately reflected in the repo:
```bash
# Edit a config
vim ~/.zshrc  # or hx ~/.zshrc

# Commit changes
cd ~/dotfiles
git add .
git commit -m "Update config"
git push
```

## Key Architectural Details

### Symlinking Strategy
- **Top-level dotfiles** (`.bashrc`, `.zshrc`, `.gitconfig`) are symlinked directly to `~/`
- **Config directories** (`.config/nvim`, `.config/fish`, etc.) are symlinked as entire directories to `~/.config/`
- The `install.sh` script backs up existing files/dirs before creating symlinks

### Nix Package Management
- Packages are managed via **single-user Nix** (not NixOS, not home-manager)
- `packages.txt` is the source of truth for declarative package installation
- `sync.sh` detects manually-installed packages and adds them to `packages.txt`

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

### CLI Tools (from packages.txt)
- **eza** - Modern `ls` replacement
- **bat** - Modern `cat` with syntax highlighting
- **ripgrep** (`rg`) - Fast search
- **delta** - Git diff pager
- **fzf** - Fuzzy finder
- **zoxide** - Smart `cd` replacement
- **atuin** - Shell history manager
- **starship** - Cross-shell prompt
- **carapace** - Multi-shell completion bridge
- **zellij** - Terminal multiplexer

### Development Tools
- **Git** with `gh` CLI for GitHub
- **Rust toolchain** (rustup)
- **Node.js** (for Copilot)
- **Nix** package manager

## Important Notes

### When Modifying Neovim Config
- Preserve heavy commenting style
- Each plugin gets its own file in `lua/plugins/`
- Never edit `lazy-lock.json` manually
- Use `:Lazy sync` to update plugins
- Read `AGENTS.md` in `.config/nvim/` for detailed guidance

### When Adding New Packages
Two workflows:
1. **Declarative**: Add to `packages.txt`, then install via loop
2. **Imperative**: `nix profile install nixpkgs#<package>`, then run `./sync.sh` to update `packages.txt`

### When Adding New Dotfiles
```bash
# Move to repo
mv ~/.vimrc ~/dotfiles/

# Create symlink
ln -s ~/dotfiles/.vimrc ~/.vimrc

# For .config items
mv ~/.config/nvim ~/dotfiles/.config/
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
```

### Performance Considerations
- Zsh config caches init scripts - delete `~/.cache/zsh/` to regenerate
- Neovim uses lazy-loading - check `:Lazy profile` for startup time
- Compinit dump regenerates every 24 hours automatically
