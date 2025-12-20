# Dotfiles

Personal dotfiles with Nix package management and flake-based reproducibility.

## Quick Start

```bash
git clone https://github.com/Muhammad-Abdullah-Bajwa/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will:
1. Install Nix (via Determinate Systems installer) if not present
2. Configure binary caches for fast downloads
3. Install all packages via Nix flakes
4. Symlink dotfiles to your home directory

## Structure

```
~/dotfiles/
├── install.sh              # Bootstrap script
├── sync.sh                 # Sync installed packages
├── verify-links.sh         # Verify symlinks
├── flake.nix               # Nix flake (reproducible packages)
├── flake.lock              # Locked package versions
├── packages.txt            # Package list (readable reference)
├── CLAUDE.md               # AI assistant guidance
├── .zshrc                  # Zsh configuration (optimized <200ms)
├── .gitconfig              # Git configuration
└── .config/
    ├── nix/                # Nix settings (binary caches)
    ├── nvim/               # Neovim (modular lazy.nvim config)
    ├── helix/              # Helix editor
    ├── fish/               # Fish shell
    ├── nushell/            # Nushell
    ├── zellij/             # Terminal multiplexer
    ├── atuin/              # Shell history
    └── ...
```

## Package Management

### Flake-Based (Recommended)

```bash
# Install all packages
nix profile install .#

# Update nixpkgs to latest
nix flake update

# Apply updates
nix profile upgrade --all

# Check what will change
nix flake check
```

### Legacy (packages.txt)

```bash
# Force legacy installation
./install.sh --legacy

# Install single package
nix profile install nixpkgs#<package>

# Sync installed packages to packages.txt
./sync.sh
```

### Common Commands

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
```

## Binary Caches

Binary caches are configured in `.config/nix/nix.conf`:

- **cache.nixos.org** - Official Nixpkgs cache
- **nix-community.cachix.org** - Community packages (neovim, rust-analyzer, etc.)

This means most packages download in seconds instead of building from source.

## Package Versions

Current versions in nixpkgs-unstable:

| Package | Version | Description |
|---------|---------|-------------|
| neovim | 0.11.5 | Primary editor |
| helix | 25.07.1 | Secondary editor |
| atuin | 18.10.0 | Shell history manager |
| starship | 1.24.1 | Cross-shell prompt |
| fzf | 0.67.0 | Fuzzy finder |
| zoxide | 0.9.8 | Smart cd |
| bat | 0.26.1 | cat with syntax highlighting |
| eza | 0.23.4 | Modern ls |
| ripgrep | 15.1.0 | Fast grep |
| zellij | 0.43.1 | Terminal multiplexer |

## Dotfile Management

Dotfiles are symlinked, so changes are immediately reflected:

```bash
# Edit a dotfile
nvim ~/.zshrc

# Changes are in the repo
cd ~/dotfiles
git diff
git add .
git commit -m "Update zshrc"
git push
```

### Adding New Dotfiles

```bash
# Move to repo
mv ~/.vimrc ~/dotfiles/

# Re-run install to create symlink
./install.sh

# Or manually symlink
ln -s ~/dotfiles/.vimrc ~/.vimrc
```

### Verify Symlinks

```bash
./verify-links.sh
```

## Shell Configurations

### Zsh (Primary)

Heavily optimized for startup speed (<200ms):
- Compinit caching (24-hour refresh)
- Cached init scripts for zoxide, atuin, starship, carapace, fzf
- Deferred syntax highlighting

```bash
# Measure startup time
time zsh -i -c exit

# Clear caches if needed
rm -rf ~/.cache/zsh/
```

### Fish

Alternative shell with same tool integrations.

### Nushell

Data-focused shell for structured data processing.

## Neovim

Modular Lua configuration with lazy.nvim:

```bash
# Health check
nvim +checkhealth

# Update plugins
nvim +"Lazy update"

# Check LSP status
nvim +"LspInfo"
```

Key features:
- LSP for C++, Rust, C#, Lua
- fzf-lua for fuzzy finding
- Treesitter for syntax
- Copilot integration

## Tool Stack

**Shells:** zsh (primary), fish, nushell
**Editors:** Neovim (primary), Helix
**CLI:** eza, bat, fd, ripgrep, fzf, delta, zoxide, atuin
**Multiplexer:** zellij
**Git:** gh, delta pager

## Non-Nixpkgs Packages

Some packages aren't in nixpkgs:

```bash
# Claude Code
npm install -g @anthropic-ai/claude-code
```

## Troubleshooting

### Packages building from source?

Check that binary caches are configured:

```bash
nix show-config | grep substituters
# Should include cache.nixos.org and nix-community.cachix.org
```

### Shell startup slow?

Clear cached init scripts:

```bash
rm -rf ~/.cache/zsh/
rm -rf ~/.cache/fish/
```

### Symlinks broken?

Re-run the install script:

```bash
./install.sh
./verify-links.sh
```
