--[[
================================================================================
  LAZY.NVIM - PLUGIN MANAGER
================================================================================

  This file sets up lazy.nvim, the most popular Neovim plugin manager.
  
  WHY LAZY.NVIM?
  - Fast: Only loads plugins when needed (lazy loading)
  - Modern: Written in Lua, designed for Neovim
  - Reliable: Lockfile ensures reproducible installs
  - Nice UI: Beautiful interface for managing plugins (:Lazy)

  HOW IT WORKS:
  1. Check if lazy.nvim is installed
  2. If not, automatically download it from GitHub
  3. Add it to Neovim's runtime path
  4. Load all plugin specifications from lua/plugins/

  USEFUL COMMANDS:
    :Lazy           -- Open the lazy.nvim UI (manage plugins)
    :Lazy sync      -- Install missing plugins and update existing ones
    :Lazy update    -- Update all plugins to latest versions
    :Lazy clean     -- Remove plugins that are no longer in your config
    :Lazy profile   -- Show startup time for each plugin

--]]

--------------------------------------------------------------------------------
-- BOOTSTRAP LAZY.NVIM
--------------------------------------------------------------------------------
-- This code automatically installs lazy.nvim if it's not already installed.
-- It runs only on first startup or if you delete the lazy.nvim folder.

-- Where lazy.nvim will be installed
-- vim.fn.stdpath('data') = ~/.local/share/nvim on Linux/Mac
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Check if lazy.nvim is already installed
-- vim.loop.fs_stat returns file info if path exists, nil if it doesn't
if not vim.loop.fs_stat(lazypath) then
  -- Not installed, so clone it from GitHub
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'

  -- Run git clone to download lazy.nvim
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',  -- Don't download file history (faster)
    '--branch=stable',      -- Use stable release, not bleeding edge
    lazyrepo,
    lazypath,
  })
end

-- Add lazy.nvim to the runtime path so Neovim can find it
-- This must happen before calling require('lazy')
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- LOAD PLUGINS
--------------------------------------------------------------------------------
-- Now we tell lazy.nvim to load our plugin specifications.
-- 
-- The first argument can be:
--   - A table of plugin specs (inline configuration)
--   - A string like 'plugins' to load from lua/plugins/
--
-- We use the second approach because it's cleaner for larger configs.
-- lazy.nvim will automatically load:
--   - lua/plugins/init.lua (must return a table of plugin specs)
--   - OR all .lua files in lua/plugins/ directory

require('lazy').setup(
  -- Load plugin specs from lua/plugins/init.lua
  -- That file imports all the individual plugin configs
  'plugins',

  -- lazy.nvim configuration options (second argument)
  {
    -- Customize the UI icons shown in :Lazy
    ui = {
      icons = {
        cmd = '⌘',           -- Commands
        config = '🛠',        -- Configuration
        event = '📅',         -- Event triggers
        ft = '📂',            -- File type triggers
        init = '⚙',          -- Initialization
        keys = '🗝',          -- Key mappings
        plugin = '🔌',        -- Plugin
        runtime = '💻',       -- Runtime
        require = '🌙',       -- Require (module loading)
        source = '📄',        -- Source files
        start = '🚀',         -- Startup
        task = '📌',          -- Task
        lazy = '💤 ',         -- Lazy-loaded plugins
      },
    },

    -- Check for plugin updates automatically (on startup)
    -- Disabled by default because it can slow startup
    checker = {
      enabled = false,       -- Set to true to enable
      notify = true,         -- Show notification when updates available
    },

    -- Automatically check for config changes and reload
    change_detection = {
      enabled = true,        -- Watch for config changes
      notify = true,         -- Notify when changes detected
    },
  }
)

--[[
================================================================================
  PLUGIN SPECIFICATION FORMAT
================================================================================

  Each plugin is specified as a table with these common fields:

  REQUIRED:
    [1] or name     -- The plugin's GitHub repo: "username/repo"

  OPTIONAL:
    dependencies    -- Other plugins this one needs
    config          -- Function to run after plugin loads
    opts            -- Table passed to plugin's setup() function
    init            -- Function to run at startup (before plugin loads)
    lazy            -- If true, don't load until needed
    event           -- Load when this event fires (e.g., "BufEnter")
    cmd             -- Load when this command is run (e.g., "Telescope")
    ft              -- Load for these file types (e.g., "lua")
    keys            -- Load when these keys are pressed
    priority        -- Load order (higher = earlier, default 50)
    build           -- Command to run after install/update

  EXAMPLES:

    -- Simple plugin (loads at startup):
    { 'tpope/vim-sleuth' }

    -- Plugin with configuration:
    {
      'some/plugin',
      opts = {
        setting1 = true,
        setting2 = 'value',
      },
    }

    -- Lazy-loaded plugin (loads when command is used):
    {
      'telescope.nvim',
      cmd = 'Telescope',  -- Only load when :Telescope is run
      keys = {            -- Or when these keys are pressed
        { '<leader>sf', ':Telescope find_files<CR>' },
      },
    }

    -- Plugin with dependencies:
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',  -- Telescope needs this library
      },
    }

================================================================================
--]]
