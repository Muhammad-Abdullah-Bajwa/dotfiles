--[[
================================================================================
  ABDULLAH'S NEOVIM CONFIGURATION
================================================================================

  Welcome! This is the main entry point for Neovim's configuration.
  
  WHAT IS THIS FILE?
  When Neovim starts, it looks for this file at ~/.config/nvim/init.lua
  Think of it as the "main()" function of your Neovim setup.

  HOW IS THIS CONFIG ORGANIZED?
  Instead of having one giant file, we split the config into smaller,
  focused files. This makes it easier to:
    - Find what you're looking for
    - Make changes without breaking everything
    - Understand what each part does

  DIRECTORY STRUCTURE:
  ~/.config/nvim/
  ├── init.lua                 <- You are here! Main entry point
  └── lua/                     <- All Lua modules live here
      ├── config/              <- Core Neovim settings (no plugins)
      │   ├── options.lua      <- Editor settings (line numbers, tabs, etc.)
      │   ├── keymaps.lua      <- Keyboard shortcuts
      │   ├── autocmds.lua     <- Automatic actions (events)
      │   └── lazy.lua         <- Plugin manager bootstrap
      └── plugins/             <- Plugin configurations
          ├── init.lua         <- List of all plugins to load
          ├── colorscheme.lua  <- Color theme (Gruvbox)
          ├── ui.lua           <- Dashboard, statusline, icons
          ├── editor.lua       <- Editing enhancements
          ├── telescope.lua    <- Fuzzy finder
          ├── lsp.lua          <- Language Server Protocol (code intelligence)
          ├── completion.lua   <- Autocompletion
          ├── git.lua          <- Git integration
          └── copilot.lua      <- GitHub Copilot AI

  HOW TO READ THIS CONFIG:
  1. Start here (init.lua) to see how everything connects
  2. Check lua/config/options.lua to understand editor settings
  3. Check lua/config/keymaps.lua to see keyboard shortcuts
  4. Explore lua/plugins/ to see how each plugin is configured

  TERMINOLOGY:
  - "Leader key": A prefix key for custom shortcuts (set to Space)
  - "LSP": Language Server Protocol - provides code intelligence
  - "Treesitter": Parser for syntax highlighting and code understanding
  - "Telescope": Fuzzy finder for searching files, text, etc.
  - "Lazy.nvim": Plugin manager that loads plugins efficiently

--]]

--------------------------------------------------------------------------------
-- STEP 1: Load core configuration (options, keymaps, autocommands)
--------------------------------------------------------------------------------

-- Load editor options (line numbers, tabs, colors, etc.)
-- This sets up how Neovim looks and behaves before any plugins load
require('config.options')

-- Load keyboard shortcuts that don't depend on plugins
-- These are basic mappings like clearing search highlight, window navigation
require('config.keymaps')

-- Load autocommands (automatic actions triggered by events)
-- Example: highlight text briefly when you copy (yank) it
require('config.autocmds')

--------------------------------------------------------------------------------
-- STEP 2: Initialize the plugin manager and load all plugins
--------------------------------------------------------------------------------

-- Bootstrap lazy.nvim (plugin manager) and load all plugins
-- This is where the magic happens - all the plugins are loaded here
require('config.lazy')

--[[
================================================================================
  QUICK REFERENCE - MOST USEFUL KEYBINDINGS
================================================================================

  NOTE: <leader> is the Space key in this config

  FINDING THINGS (Telescope):
    <leader>sf    Find files in project
    <leader>sg    Search for text (grep) in project
    <leader>/     Search in current file
    <leader><leader>  Switch between open files (buffers)

  CODE NAVIGATION (LSP):
    gd            Go to definition (where function is defined)
    gr            Find all references (where function is used)
    K             Show documentation popup
    <leader>ca    Show code actions (quick fixes)
    <leader>rn    Rename symbol everywhere

  EDITING:
    gcc           Toggle comment on current line
    gc            Toggle comment on selection (visual mode)
    <C-y>         Accept Copilot suggestion

  DIAGNOSTICS (Errors/Warnings):
    <leader>e     Show error message in popup
    [d            Go to previous error
    ]d            Go to next error

  WINDOWS:
    <C-h/j/k/l>   Move between split windows

  For the complete list, press <leader>sk to search keymaps!

================================================================================
--]]

