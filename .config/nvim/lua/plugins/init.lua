--[[
================================================================================
  PLUGIN LOADER
================================================================================

  This file tells lazy.nvim which plugins to load.
  
  It returns a Lua table containing all our plugin specifications.
  Each plugin is defined in its own file for better organization.

  HOW THIS WORKS:
  - lazy.nvim calls require('plugins') which loads this file
  - We return a table with all plugin specs
  - lazy.nvim processes each spec and loads/configures the plugins

  TO ADD A NEW PLUGIN:
  1. Create a new file in lua/plugins/ (e.g., myplugin.lua)
  2. Make it return a plugin spec table
  3. Add require('plugins.myplugin') to the table below

--]]

return {
  -- ============================================================================
  -- COLORSCHEME & APPEARANCE
  -- ============================================================================
  -- These plugins control how Neovim looks

  require('plugins.colorscheme'),  -- Gruvbox color theme
  require('plugins.ui'),           -- Dashboard, statusline, which-key, icons

  -- ============================================================================
  -- EDITOR ENHANCEMENTS
  -- ============================================================================
  -- These plugins make editing code easier

  require('plugins.editor'),       -- Treesitter, comments, autopairs, surround
  require('plugins.indent-blankline'), -- Visual indent guides

  -- ============================================================================
  -- FUZZY FINDER
  -- ============================================================================
  -- fzf-lua - blazing fast fuzzy finder

  require('plugins.fzf-lua'),      -- Fuzzy finder for files, text, and more

  -- ============================================================================
  -- CODE INTELLIGENCE (LSP)
  -- ============================================================================
  -- These plugins provide IDE-like features

  require('plugins.lsp'),          -- Language Server Protocol (code intelligence)
  require('plugins.completion'),   -- Autocompletion

  -- ============================================================================
  -- NAVIGATION
  -- ============================================================================
  -- Movement and navigation plugins

  require('plugins.flash'),        -- Lightning fast jump navigation (s key)
  require('plugins.aerial'),       -- Code outline & symbol navigation

  -- ============================================================================
  -- GIT INTEGRATION
  -- ============================================================================
  -- Git-related plugins

  require('plugins.git'),          -- Git signs in the gutter

  -- ============================================================================
  -- AI ASSISTANCE
  -- ============================================================================
  -- AI coding assistants

  require('plugins.copilot'),      -- GitHub Copilot

  -- ============================================================================
  -- UI ENHANCEMENTS
  -- ============================================================================
  -- Noice - Better cmdline and error UI

  require('plugins.noice'),        -- Noice - cmdline UI and message routing

  -- ============================================================================
  -- NOTE-TAKING
  -- ============================================================================
  -- Obsidian vault integration

  require('plugins.obsidian'),     -- Obsidian vault support (wiki links, daily notes)
}
