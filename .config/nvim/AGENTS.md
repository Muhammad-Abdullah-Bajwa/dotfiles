# AGENTS.md - AI Assistant Guide for Neovim Configuration

This document provides context for AI assistants working with this Neovim configuration.

## Overview

This is a **modular Neovim configuration** written entirely in Lua, using **lazy.nvim** as the plugin manager. It's designed for C++, Rust, and C# development, with heavy commenting to help beginners learn.

## Design Philosophy

- **One key does one thing** - Keybindings are simple and predictable. No "smart" Tab that behaves differently in different contexts. Each key has a single, consistent action.
- **Explicit over implicit** - Prefer clear, obvious configurations over magic behavior. Users should understand what each setting does.
- **Modular and organized** - Each plugin gets its own file. Configuration is split into logical units for easy navigation and maintenance.
- **Beginner-friendly** - Heavy commenting throughout. Every non-obvious setting has an explanation.
- **Minimal but complete** - Include essential features for development without bloat. Every plugin earns its place.
- **Predictable defaults** - Follow Vim conventions where sensible. Don't remap core functionality unexpectedly.

## Directory Structure

```
~/.config/nvim/
├── init.lua                 # Entry point - loads all config modules
├── lazy-lock.json           # Plugin version lockfile (do not manually edit)
├── README.md                # User documentation
├── AGENTS.md                # This file
└── lua/
    ├── config/              # Core Neovim settings (no plugins)
    │   ├── options.lua      # Editor settings (tabs, line numbers, colors)
    │   ├── keymaps.lua      # Non-plugin keyboard shortcuts
    │   ├── autocmds.lua     # Automatic actions triggered by events
    │   └── lazy.lua         # Plugin manager bootstrap & configuration
    └── plugins/             # Individual plugin configurations
        ├── init.lua         # Master plugin list (imports all others)
        ├── colorscheme.lua  # Gruvbox theme
        ├── ui.lua           # Dashboard, statusline, which-key, icons
        ├── editor.lua       # Treesitter, comments, autopairs, surround
        ├── telescope.lua    # Fuzzy finder
        ├── lsp.lua          # Language Server Protocol configuration
        ├── completion.lua   # nvim-cmp autocompletion
        ├── flash.lua        # Jump navigation
        ├── git.lua          # Gitsigns
        └── copilot.lua      # GitHub Copilot
```

## Key Conventions

### File Organization
- **One plugin per file** in `lua/plugins/` - each file returns a lazy.nvim spec table
- **Config files are heavily commented** - preserve this style when making changes
- **Plugin files return tables**, not call setup directly
- All paths use `require()` from `lua/` directory (e.g., `require('plugins.lsp')`)

### Code Style
- Use **4-space indentation** (configured in options.lua)
- Add **section headers** using comment blocks with `====` borders
- Include **explanatory comments** for non-obvious settings
- Follow existing naming patterns in keymaps

### Leader Key
- The **leader key is Space** (`<Space>`)
- Most custom keybindings start with `<leader>`

## Important Files

| File | Purpose | When to Modify |
|------|---------|----------------|
| `lua/config/options.lua` | Vim options | Changing editor behavior |
| `lua/config/keymaps.lua` | Core keybindings | Adding non-plugin shortcuts |
| `lua/plugins/lsp.lua` | LSP configuration | Adding language servers |
| `lua/plugins/init.lua` | Plugin list | Adding new plugin files |

## Adding a New Plugin

1. Create `lua/plugins/<name>.lua`:
```lua
return {
  '<author>/<plugin>',
  opts = {
    -- configuration
  },
}
```

2. Add to `lua/plugins/init.lua`:
```lua
require('plugins.<name>'),
```

## Adding a New Language Server

Edit `lua/plugins/lsp.lua` and add to the `servers` table:
```lua
local servers = {
  clangd = {},
  rust_analyzer = {},
  pyright = {},  -- Add new server here
}
```

Mason will auto-install it on next startup.

## Adding a New Keymap

- **Plugin-specific**: Add in the plugin's `keys` table in its spec file
- **General/Non-plugin**: Add in `lua/config/keymaps.lua`
- Use `vim.keymap.set(mode, lhs, rhs, opts)` format

## Plugin Manager Commands

- `:Lazy` - Open plugin manager UI
- `:Lazy sync` - Install/update all plugins
- `:Lazy clean` - Remove unused plugins
- `:Lazy profile` - View startup time

## LSP/Mason Commands

- `:Mason` - Open Mason UI (LSP installer)
- `:LspInfo` - Check attached LSP clients
- `:LspRestart` - Restart LSP for current buffer

## Testing Changes

After modifying config files:
1. Save the file
2. Restart Neovim (`:qa` then `nvim`)
3. Check `:checkhealth` for issues
4. Run `:Lazy` to verify plugins loaded

## Common Patterns

### Plugin with lazy loading
```lua
return {
  'plugin/name',
  event = 'VeryLazy',  -- or 'BufReadPost', 'InsertEnter'
  opts = {},
}
```

### Plugin with dependencies
```lua
return {
  'plugin/name',
  dependencies = { 'dep/one', 'dep/two' },
  config = function()
    require('name').setup({})
  end,
}
```

### Plugin with keymaps
```lua
return {
  'plugin/name',
  keys = {
    { '<leader>xx', '<cmd>PluginCommand<cr>', desc = 'Description' },
  },
}
```

## Gotchas

- **Don't edit `lazy-lock.json` manually** - it's auto-generated
- **Treesitter parsers** need a C compiler to build
- **Mason installs go to** `~/.local/share/nvim/mason/`
- **Plugin data is in** `~/.local/share/nvim/lazy/`
- **Copilot requires** Node.js and authentication (`:Copilot auth`)

## Dependencies

External tools this config expects:
- **Neovim 0.10+** (0.11 recommended)
- **Git** (for plugin installation)
- **Nerd Font** (for icons)
- **Node.js** (for Copilot)
- **ripgrep** (`rg`) (for Telescope grep)
- **C compiler** (for Treesitter)

## Debugging Tips

- `:messages` - View recent messages/errors
- `:checkhealth` - Diagnose common issues
- `:Lazy profile` - Check slow plugins
- `:verbose map <key>` - See where a keymap is defined
