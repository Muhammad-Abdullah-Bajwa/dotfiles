--[[
================================================================================
  UI PLUGINS - DASHBOARD, STATUSLINE, ICONS, WHICH-KEY
================================================================================

  These plugins improve Neovim's visual interface:

  1. ALPHA-NVIM (Dashboard)
     Shows a nice welcome screen when you open Neovim without a file.
     Includes quick shortcuts to common actions.

  2. MINI.STATUSLINE
     The bar at the bottom showing file info, mode, position, etc.
     Part of the mini.nvim collection.

  3. MINI.AI & MINI.SURROUND
     Enhanced text objects and surround operations.
     Part of the mini.nvim collection.

  4. WHICH-KEY
     Shows a popup with available keybindings when you start a key sequence.
     Press <leader> and wait to see what keys are available!

  5. TODO-COMMENTS
     Highlights special comments like TODO, FIXME, HACK, NOTE, etc.

--]]

-- Return a TABLE of plugins (multiple specs in one file)
-- Each item in the table is a separate plugin spec
return {
  -- ==========================================================================
  -- DASHBOARD (ALPHA-NVIM)
  -- ==========================================================================
  -- Shows a pretty startup screen when you open Neovim without arguments.
  -- Press the highlighted letter to activate each action.
  {
    'goolord/alpha-nvim',

    -- This plugin needs icons
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    config = function()
      -- Load alpha and the dashboard theme
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      -- HEADER: ASCII art shown at the top
      -- Each string is one line of the art
      -- Pro tip: Search "ASCII art generator" online to make your own!
      dashboard.section.header.val = {
        [[                             __                                ]],
        [[                   _ ,___,-'",-=-.                             ]],
        [[       __,-- _ _,-'_)_  (""`'-._\ `.                           ]],
        [[    _,'  __ |,' ,-' __)  ,-     /. |                           ]],
        [[  ,'_,--'   |     -'  _)/         `\                           ]],
        [[,','      ,'       ,-'_,`           :                          ]],
        [[,'     ,-'       ,(,-(              :                          ]],
        [[     ,'       ,-' ,    _            ;                          ]],
        [[    /        ,-._/`---'            /                           ]],
        [[   /        (____)(----. )       ,'                            ]],
        [[  /         (      `.__,     /\ /,                             ]],
        [[ :           ;-.___         /__\/|                             ]],
        [[ |         ,'      `--.      -,\ |                             ]],
        [[ :        /            \    .__/                               ]],
        [[  \      (__            \    |_                                ]],
        [[   \       ,`-, *       /   _|,\                               ]],
        [[    \    ,'   `-.     ,'_,-'    \                              ]],
        [[   (_\,-'    ,'\")--,'-'       __\                             ]],
        [[    \       /  // ,'|      ,--'  `-.                           ]],
        [[     `-.    `-/ \'  |   _,'         `.                         ]],
        [[        `-._ /      `--'/             \                        ]],
        [[           ,'           |              \                       ]],
        [[          /             |               \                      ]],
        [[       ,-'              |               /                      ]],
        [[      /                 |             -'                       ]],
      }

      -- BUTTONS: Quick actions on the dashboard
      -- Format: dashboard.button(shortcut, icon + text, command)
      dashboard.section.buttons.val = {
        dashboard.button('f', '  Find file', ':FzfLua files<CR>'),
        dashboard.button('e', '  New file', ':ene <BAR> startinsert<CR>'),
        dashboard.button('r', '  Recent files', ':FzfLua oldfiles<CR>'),
        dashboard.button('g', '  Find text', ':FzfLua live_grep<CR>'),
        dashboard.button('c', '  Configuration', ':e $MYVIMRC<CR>'),
        dashboard.button('l', '󰒲  Lazy', ':Lazy<CR>'),
        dashboard.button('q', '  Quit', ':qa<CR>'),
      }

      -- FOOTER: Shows plugin load stats
      -- This is a function because stats aren't available until lazy loads
      dashboard.section.footer.val = function()
        local stats = require('lazy').stats()
        return '⚡ ' .. stats.loaded .. '/' .. stats.count .. ' plugins loaded'
      end

      -- COLORS: Set highlight groups for each section
      dashboard.section.header.opts.hl = 'AlphaHeader'
      dashboard.section.buttons.opts.hl = 'AlphaButtons'
      dashboard.section.footer.opts.hl = 'AlphaFooter'

      -- Activate alpha with our dashboard configuration
      alpha.setup(dashboard.opts)

      -- Disable code folding on the dashboard
      vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
    end,
  },

  -- ==========================================================================
  -- WHICH-KEY
  -- ==========================================================================
  -- When you press a key like <leader> and pause, which-key shows a popup
  -- displaying all available key combinations starting with that prefix.
  -- This makes it much easier to learn and remember keybindings!
  {
    'folke/which-key.nvim',

    -- EVENT: When to load this plugin
    -- 'VimEnter' means load after Neovim finishes starting up
    event = 'VimEnter',

    config = function()
      -- Initialize which-key with default settings
      require('which-key').setup()

      -- REGISTER KEY GROUPS
      -- This adds descriptive names for key prefixes
      -- When you press <leader>, you'll see these group names
      require('which-key').add({
        { '<leader>c', group = '[C]ode' },       -- Code actions group
        { '<leader>d', group = '[D]ocument' },   -- Document actions
        { '<leader>r', group = '[R]ename' },     -- Rename operations
        { '<leader>s', group = '[S]earch' },     -- Search (fzf-lua)
        { '<leader>w', group = '[W]orkspace' },  -- Workspace actions
        { '<leader>t', group = '[T]oggle' },     -- Toggle features
      })
    end,
  },

  -- ==========================================================================
  -- MINI.NVIM COLLECTION
  -- ==========================================================================
  -- Mini.nvim is a collection of small, focused plugins.
  -- Instead of installing many separate plugins, mini provides
  -- multiple features in one package. We use:
  --   - mini.ai: Enhanced text objects (select inside/around)
  --   - mini.surround: Add/change/delete surrounding pairs
  --   - mini.statusline: Simple, fast statusline
  {
    'echasnovski/mini.nvim',

    config = function()
      -- MINI.AI - Enhanced Text Objects
      -- Text objects let you operate on chunks of text.
      -- Examples:
      --   vib   = Select inside brackets: (cursor here)
      --   vaq   = Select around quotes: "including quotes"
      --   cif   = Change inside function call arguments
      --   daa   = Delete around argument in function(a, b, c)
      require('mini.ai').setup({
        n_lines = 500,  -- Search this many lines for text objects
      })

      -- MINI.SURROUND - Surround Operations
      -- Quickly add, change, or delete surrounding characters.
      -- Default keybindings:
      --   sa{motion}{char}  = Add surrounding (e.g., saiw" adds quotes around word)
      --   sd{char}          = Delete surrounding (e.g., sd" removes quotes)
      --   sr{old}{new}      = Replace surrounding (e.g., sr"' changes " to ')
      require('mini.surround').setup()

      -- MINI.STATUSLINE - Bottom Status Bar
      -- Shows: mode, file name, git status, diagnostics, position
      local statusline = require('mini.statusline')
      statusline.setup({
        use_icons = true,  -- Use nerdfont icons (requires a Nerd Font)
      })

      -- Customize the location section (line:column display)
      -- %2l = line number (2 chars wide), %-2v = column (2 chars, left-aligned)
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  -- ==========================================================================
  -- TODO COMMENTS
  -- ==========================================================================
  -- Highlights special comments in your code:
  --   TODO: Something to do later
  --   FIXME: Broken code that needs fixing
  --   HACK: Workaround that should be improved
  --   NOTE: Important information
  --   PERF: Performance-related note
  --   WARNING: Potential issue
  {
    'folke/todo-comments.nvim',

    event = 'VimEnter',

    -- This plugin needs plenary for async operations
    dependencies = { 'nvim-lua/plenary.nvim' },

    -- OPTS: Simple configuration (passed to setup())
    -- When you use 'opts' instead of 'config', lazy.nvim
    -- automatically calls require('todo-comments').setup(opts)
    opts = {
      signs = false,  -- Don't show signs in the gutter (cleaner look)
    },

    -- You can search all TODOs with :TodoQuickFix
    -- to put them in the quickfix list
  },
}

--[[
================================================================================
  ICON REQUIREMENTS
================================================================================

  Many plugins in this config use icons (file types, git status, etc.)
  These icons come from "Nerd Fonts" - fonts patched with extra icons.

  TO GET ICONS WORKING:
  1. Download a Nerd Font from https://www.nerdfonts.com/
     Recommended: "Iosevka Nerd Font" or "JetBrainsMono Nerd Font"
  2. Install the font on your system
  3. Configure your terminal to use the Nerd Font
  4. For GUI Neovim, set vim.opt.guifont (already done in options.lua)

  WITHOUT NERD FONTS:
  Icons will show as missing character boxes or question marks.
  Everything still works, just without pretty icons.

================================================================================
--]]
