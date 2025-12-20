--[[
================================================================================
  AERIAL.NVIM - CODE OUTLINE & SYMBOL NAVIGATION
================================================================================

  Aerial shows a sidebar with an outline of your code's structure.
  Think of it like a table of contents for your code file.

  WHY USE THIS?
  - See all functions/classes in a file at a glance
  - Jump to any symbol instantly
  - Understand unfamiliar code structure quickly
  - Navigate large files efficiently

  HOW IT WORKS:
  - Uses Treesitter (or LSP) to understand your code
  - Shows a tree of symbols: classes, functions, methods, etc.
  - Highlights which symbol your cursor is currently inside
  - Click or navigate to jump to that location

  KEYBINDINGS:
    <leader>o   = Toggle the outline sidebar
    <leader>O   = Toggle floating navigation window
    [o / ]o     = Jump to previous/next symbol

--]]

return {
  'stevearc/aerial.nvim',

  -- DEPENDENCIES: Multiple plugins enhance aerial's functionality
  dependencies = {
    'nvim-treesitter/nvim-treesitter',  -- For parsing code structure
    'nvim-tree/nvim-web-devicons',       -- For file type icons
  },

  -- KEYS: Only load when these keys are pressed (lazy loading)
  keys = {
    { '<leader>o', '<cmd>AerialToggle<cr>', desc = 'Toggle code outline' },
    { '<leader>O', '<cmd>AerialNavToggle<cr>', desc = 'Navigate symbols (floating)' },
  },

  -- OPTS: Configuration passed to aerial.setup()
  opts = {
    -- LAYOUT: How the sidebar appears
    layout = {
      -- WIDTH: Minimum width of the aerial window
      min_width = 30,

      -- DEFAULT_DIRECTION: Which side the outline appears
      -- Options: 'prefer_right', 'prefer_left', 'right', 'left', 'float'
      default_direction = 'prefer_right',
    },

    -- FILTER_KIND: Which symbol types to show
    -- false = show everything (functions, classes, variables, etc.)
    -- You can also specify a list like { 'Function', 'Class', 'Method' }
    filter_kind = false,

    -- HIGHLIGHT_ON_HOVER: Highlight the code when hovering in aerial
    highlight_on_hover = true,

    -- AUTOJUMP: Automatically jump to location when moving in aerial
    autojump = false,

    -- ON_ATTACH: Function called when aerial attaches to a buffer
    -- We use this to set up buffer-local keymaps
    on_attach = function(bufnr)
      -- Navigate between symbols with [o and ]o
      -- These only work in buffers where aerial is active
      vim.keymap.set('n', '[o', '<cmd>AerialPrev<cr>', {
        buffer = bufnr,
        desc = 'Previous symbol',
      })
      vim.keymap.set('n', ']o', '<cmd>AerialNext<cr>', {
        buffer = bufnr,
        desc = 'Next symbol',
      })
    end,
  },

  -- CONFIG: Custom setup (extends opts)
  config = function(_, opts)
    -- Initialize aerial with our options
    require('aerial').setup(opts)
  end,
}

--[[
================================================================================
  AERIAL QUICK REFERENCE
================================================================================

  KEYBINDINGS:
    <leader>o    = Toggle the outline sidebar on/off
    <leader>O    = Toggle floating navigation window
    [o           = Jump to previous symbol
    ]o           = Jump to next symbol

  INSIDE AERIAL WINDOW:
    <CR>         = Jump to symbol under cursor
    <C-v>        = Open symbol in vertical split
    <C-s>        = Open symbol in horizontal split
    o            = Toggle fold under cursor
    O            = Toggle all folds
    q            = Close aerial window
    ?            = Show help

  COMMANDS:
    :AerialToggle       = Open/close the aerial window
    :AerialOpen         = Open aerial (if closed)
    :AerialClose        = Close aerial (if open)
    :AerialNavToggle    = Toggle a floating navigation window

  SUPPORTED LANGUAGES:
    Aerial works with any language that has:
    - Treesitter parser installed, OR
    - LSP server attached
    
    It automatically picks the best backend.

================================================================================
--]]
