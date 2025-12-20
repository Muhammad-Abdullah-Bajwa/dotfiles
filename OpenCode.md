# OpenCode.md

## Build, Lint, Test Commands

### Installation:
- **Repository Setup:**
  ```bash
  git clone https://github.com/Muhammad-Abdullah-Bajwa/dotfiles ~/dotfiles
  cd ~/dotfiles
  ./install.sh
  ```

### Package Management:
- **Install All Flake Packages:**
  ```bash
  nix profile add .#
  ```
- **Sync Installed Packages:**
  ```bash
  ./sync.sh
  ```
- **Verify Symlinks:**
  ```bash
  ./verify-links.sh
  ```

### Linting:
N/A

### Test:
- **Check Nix Flake Validity:**
  ```bash
  nix flake check
  ```

## Code Style Guidelines
### General Repository Guidelines:
- Follow the Neovim modularity paradigm for `.nix-format`.
- .
Extra;} F.noise.signal testing guidelines`;twistingENDING