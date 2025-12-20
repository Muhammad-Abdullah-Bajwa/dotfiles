# Dotfiles

Simple dotfiles management with Nix package management.

## Structure

```
~/dotfiles/
├── install.sh          # Bootstrap script
├── packages.txt        # List of Nix packages to install
├── .bashrc            # Bash configuration
├── .zshrc             # Zsh configuration
├── .gitconfig         # Git configuration
└── .config/           # Application configs
    ├── helix/
    ├── fish/
    └── ...
```

## Installation

On a new machine:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will:
1. Install Nix (single-user) if not present
2. Install all packages from `packages.txt`
3. Symlink dotfiles to your home directory
4. Backup any existing files

## Managing Packages

### Syncing Installed Packages

If you install packages manually with `nix profile install`, sync them to `packages.txt`:

```bash
cd ~/dotfiles
./sync.sh
git add packages.txt
git commit -m "Update packages"
```

The sync script will:
- Find all packages installed via Nix
- Add any missing packages to `packages.txt`
- Sort and deduplicate the list

### Installing Packages

Edit `packages.txt` to add/remove packages, then run:

```bash
# Install new packages
while read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  nix profile install "nixpkgs#$(echo $pkg | xargs)"
done < packages.txt

# List installed packages
nix profile list

# Remove a package
nix profile remove <name or index>

# Upgrade all packages
nix profile upgrade '.*'
```

## Managing Dotfiles

Since dotfiles are symlinked, just edit them in place:

```bash
# Edit a dotfile
vim ~/.zshrc

# Changes are immediately reflected in the repo
cd ~/dotfiles
git diff
git add .
git commit -m "Update zshrc"
git push
```

## Adding New Dotfiles

```bash
# Move existing dotfile to repo
mv ~/.vimrc ~/dotfiles/
cd ~/dotfiles
ln -s ~/dotfiles/.vimrc ~/.vimrc

# Or for .config items
mv ~/.config/nvim ~/dotfiles/.config/
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
```

## Useful Nix Commands

```bash
# Search for packages
nix search nixpkgs <package-name>

# See what's in your profile
nix profile list

# Update nixpkgs
nix flake update

# Garbage collect old packages
nix-collect-garbage -d
```
