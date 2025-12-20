# Neovim Configuration

A clean, modular Neovim config optimized for C++/Rust/C# development.
Heavily commented for beginners to learn from!

## Features

- **LSP Support**: clangd (C/C++), rust-analyzer (Rust), omnisharp (C#), lua_ls
- **Treesitter**: Syntax highlighting and code understanding
- **GitHub Copilot**: Inline AI suggestions
- **Telescope**: Fuzzy finder for files, text, and more
- **Dashboard**: Nice startup screen with quick actions
- **Gruvbox Dark Hard**: Easy on the eyes, high contrast
- **Simple Keybinds**: One key does one thing (no "smart" Tab)
- **Modular Structure**: Easy to understand and customize

## Directory Structure

```
~/.config/nvim/
├── init.lua                 # Entry point - loads everything
├── README.md                # This file
├── lazy-lock.json           # Plugin version lockfile
└── lua/
    ├── config/              # Core settings (no plugins)
    │   ├── options.lua      # Editor settings (tabs, numbers, etc.)
    │   ├── keymaps.lua      # Keyboard shortcuts
    │   ├── autocmds.lua     # Automatic actions
    │   └── lazy.lua         # Plugin manager setup
    └── plugins/             # Plugin configurations
        ├── init.lua         # Plugin list
        ├── colorscheme.lua  # Gruvbox theme
        ├── ui.lua           # Dashboard, statusline, which-key
        ├── editor.lua       # Treesitter, comments, autopairs
        ├── telescope.lua    # Fuzzy finder
        ├── lsp.lua          # Language servers
        ├── completion.lua   # Autocompletion
        ├── git.lua          # Git signs
        └── copilot.lua      # GitHub Copilot
```

## Prerequisites

1. **Neovim 0.10+** (0.11 recommended)
2. **Nerd Font** (e.g., Iosevka Nerd Font) - [Download](https://www.nerdfonts.com/)
3. **Node.js** (for Copilot)
4. **ripgrep** (for Telescope grep)
5. **A C compiler** (for Treesitter)

### Install dependencies (Ubuntu/Debian):
```bash
sudo apt install build-essential ripgrep fd-find nodejs npm
```

### Install dependencies (NixOS):
Already handled via your Nix configuration.

### Install Iosevka Nerd Font:
```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Iosevka.zip
unzip Iosevka.zip -d Iosevka
rm Iosevka.zip
fc-cache -fv
```

## Installation

```bash
# Backup existing config (if any)
mv ~/.config/nvim ~/.config/nvim.bak

# Clone or copy this config
# Then start Neovim - plugins auto-install
nvim
```

## First Run

1. Open Neovim: `nvim`
2. Lazy.nvim will auto-install all plugins
3. Run `:TSInstallAll` to install Treesitter parsers
4. Run `:Copilot auth` to authenticate with GitHub
5. Run `:Mason` to verify LSP servers are installed
6. Run `:checkhealth` to verify everything is working

## Keybind Reference

### Completion (Insert Mode)
| Key | Action |
|-----|--------|
| `<C-n>` | Next completion item |
| `<C-p>` | Previous completion item |
| `<CR>` | Confirm completion |
| `<C-Space>` | Trigger completion manually |
| `<C-l>` | Jump to next snippet placeholder |
| `<C-h>` | Jump to previous snippet placeholder |

### Copilot (Insert Mode)
| Key | Action |
|-----|--------|
| `<C-y>` | Accept suggestion |
| `<C-]>` | Next suggestion |
| `<C-[>` | Previous suggestion |
| `<C-\>` | Dismiss suggestion |

### LSP (Normal Mode)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>th` | Toggle inlay hints |

### Search (Telescope)
| Key | Action |
|-----|--------|
| `<leader>sf` | Find files |
| `<leader>sg` | Grep search |
| `<leader>sw` | Search word under cursor |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Resume last search |
| `<leader>s.` | Recent files |
| `<leader>/` | Fuzzy search in buffer |
| `<leader><leader>` | Find buffers |

### Diagnostics
| Key | Action |
|-----|--------|
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>e` | Show diagnostic float |
| `<leader>q` | Diagnostic quickfix list |

### General
| Key | Action |
|-----|--------|
| `<Esc>` | Clear search highlight |
| `<C-h/j/k/l>` | Navigate windows |
| `gcc` | Toggle line comment |
| `gc` | Toggle comment (visual) |

## Customization

### Add more LSP servers

Edit the `servers` table in `init.lua`:

```lua
local servers = {
  clangd = {},
  rust_analyzer = {},
  omnisharp = {},
  pyright = {},  -- Add Python
  ts_ls = {},    -- Add TypeScript
}
```

### Change colorscheme

Replace the gruvbox plugin with another, e.g.:
- `catppuccin/nvim` - Pastel colors
- `folke/tokyonight.nvim` - Purple/blue theme
- `rebelot/kanagawa.nvim` - Japanese-inspired

## Troubleshooting

**Copilot not working?**
- Run `:Copilot status` to check connection
- Run `:Copilot auth` to re-authenticate

**LSP not attaching?**
- Run `:LspInfo` to check status
- Run `:Mason` to install missing servers

**Treesitter highlighting broken?**
- Run `:TSUpdate` to update parsers
- Run `:TSInstall <language>` for specific parsers

**Font icons not showing?**
- Make sure a Nerd Font is installed and your terminal is using it

**Telescope errors?**
- Run `:Lazy update` to update plugins
- Ensure ripgrep is installed: `which rg`
