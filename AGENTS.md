# AGENTS.md - AI Assistant Guide for dotfiles

This document orients agentic coding tools for this dotfiles repository.
It focuses on build/lint/test commands and repository-specific style rules.

## Scope and Intent

- This is a dotfiles repo managed with Nix flakes and symlinks.
- Many files are user-facing configs; preserve existing structure and comments.
- Prefer incremental edits over large rewrites unless requested.

## Build, Lint, and Test Commands

### Setup and Verification

```bash
# Install all packages from the flake
nix profile add .#

# Enter dev shell with all packages
nix develop

# Verify all symlinks
./verify-links.sh
```

### Flake Validation (closest to tests)

```bash
# Validate flake and outputs
nix flake check
```

### Single Test / Targeted Check

There is no unit test framework. Use targeted checks instead:

```bash
# Validate flake for a single platform
nix flake check --system aarch64-darwin

# Verify symlinks only
./verify-links.sh
```

### Linting

No dedicated lint step exists. Use formatters or editor tooling relevant
to the file type (Lua, Nix, shell) only if the repository already uses them.
Do not introduce new tooling without approval.

## Repository Structure

```
~/dotfiles/
├── install.sh            # Bootstrap; creates symlinks
├── post-install.sh       # Extra tools (go/npm)
├── sync.sh               # Syncs packages / flake.lock
├── verify-links.sh       # Symlink verification
├── flake.nix             # Nix flake
├── flake.lock            # Locked nixpkgs
├── packages.txt          # Human-readable package list
├── .zshrc                # Primary shell config
└── .config/
    ├── nvim/             # Modular Neovim config (see .config/nvim/AGENTS.md)
    ├── nix/              # Nix configuration (binary caches)
    ├── fish/             # Fish config
    ├── nushell/          # Nushell config
    └── ...
```

## Symlink Strategy (Critical)

This repo uses a two-tier symlink strategy:

1. Top-level dotfiles are file symlinks (e.g., `~/.zshrc -> ~/dotfiles/.zshrc`).
2. `.config/<tool>` are directory symlinks (e.g., `~/.config/nvim -> ~/dotfiles/.config/nvim`).

Rules:
- Never create file-level symlinks inside directory-symlinked paths.
- If a file inside `~/dotfiles/.config/<tool>/` breaks, restore the file itself.
- Use `./verify-links.sh` after any symlink-related change.

## Code Style Guidelines

### General

- Preserve existing structure and commentary; this repo is intentionally verbose.
- Favor small, focused edits.
- Only add comments when a change is non-obvious.
- Do not add new tools or dependencies unless requested.

### Formatting

- Indentation style follows the file being edited:
  - Shell scripts: 2-space indentation, keep functions compact.
  - Nix: 2-space indentation, align lists vertically.
  - Lua (Neovim): 4-space indentation; keep heavy comments.
  - Markdown: wrap at ~80-100 columns where reasonable.
- Keep trailing whitespace clean; avoid extra blank lines.

### Imports and Modules

- Lua: use `require()` from `lua/` and keep one plugin per file in
  `.config/nvim/lua/plugins/`.
- Nix: keep package lists grouped by category with short inline comments.
- Shell: prefer explicit checks with `(( $+commands[cmd] ))` in zsh config.

### Naming Conventions

- Scripts: descriptive verbs (`install.sh`, `verify-links.sh`, `sync.sh`).
- Variables in shell: lowercase with underscores; avoid global pollution.
- Lua: module names match file names; local variables camelCase.
- Nix: `packageList`, `supportedSystems`, `forAllSystems` are existing patterns.

### Error Handling and Safety

- Shell scripts should use safe defaults; prefer `set -euo pipefail` if
  already present in the file. Do not add globally without agreement.
- Guard destructive operations with clear checks (path existence, backups).
- Never modify symlink behavior without understanding the two-tier strategy.

## Neovim Configuration Rules

Refer to `.config/nvim/AGENTS.md` for detailed Neovim conventions.
Key expectations:

- One plugin per file in `lua/plugins/`.
- Heavy, beginner-friendly comments must be preserved.
- Do not edit `lazy-lock.json` manually.

## Doc and Rules Sources

- `CLAUDE.md` is the primary repository guide.
- No Cursor rules (`.cursor/rules/` or `.cursorrules`) found.
- No Copilot rules (`.github/copilot-instructions.md`) found.

## When Unsure

- Ask before introducing new tooling, refactors, or layout changes.
- Prefer conservative changes and document assumptions in commit messages.
