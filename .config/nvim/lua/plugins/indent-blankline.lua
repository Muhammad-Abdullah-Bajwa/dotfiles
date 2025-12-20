--[[
================================================================================
  INDENT-BLANKLINE - VISUAL INDENT GUIDES
================================================================================

  Shows vertical lines to indicate indentation levels.
  Makes it easier to see code structure at a glance.

  WHY USE THIS?
  - Quickly identify indentation levels
  - Spot indentation errors visually
  - Better understanding of nested code blocks
  - Especially helpful in Python, YAML, and deeply nested code

  HOW IT WORKS:
  - Draws subtle vertical lines at each indentation level
  - Uses Treesitter to understand code context
  - Highlights the current indentation scope
  - Respects your colorscheme

  WHAT YOU'LL SEE:
    function example() {
    │ if (condition) {
    │ │ console.log("nested");
    │ │ │ if (deep) {
    │ │ │ │ return true;
    │ │ │ }
    │ │ }
    │ }
    }

  The vertical lines (│) show each indentation level.

--]]

return {
  'lukas-reineke/indent-blankline.nvim',

  -- MAIN: This is the main module name for v3+
  main = 'ibl',

  -- EVENT: Load when opening a file
  event = 'BufReadPost',

  -- CONFIG: Custom setup function
  config = function()
    -- Set up custom highlights BEFORE initializing the plugin
    local hooks = require('ibl.hooks')

    -- Register highlight setup hook
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      -- Define custom highlight groups for indent guides
      -- These colors work well with Gruvbox but will adapt to any colorscheme
      vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#3c3836', nocombine = true })
      vim.api.nvim_set_hl(0, 'IblScope', { fg = '#7c6f64', nocombine = true })
    end)

    -- Now initialize indent-blankline with configuration
    require('ibl').setup({
      -- INDENT: Configure the indent guides
      indent = {
        -- CHAR: Character to use for indent guides
        -- Options: '│', '┊', '┆', '¦', '|', '▏'
        char = '│',

        -- TAB_CHAR: Character for tab indentation (if using tabs)
        tab_char = '│',
      },

      -- SCOPE: Highlight the current scope (current function/block)
      scope = {
        -- ENABLED: Show the current scope highlight
        enabled = true,

        -- SHOW_START: Show underline at the start of scope
        show_start = true,

        -- SHOW_END: Show underline at the end of scope
        show_end = true,
      },

      -- EXCLUDE: File types and buffer types to exclude
      exclude = {
        filetypes = {
          'help',
          'dashboard',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
          'neo-tree',
          'aerial',
        },
        buftypes = {
          'terminal',
          'nofile',
          'quickfix',
          'prompt',
        },
      },
    })
  end,
}

--[[
================================================================================
  INDENT-BLANKLINE QUICK REFERENCE
================================================================================

  FEATURES:
    ✓ Shows vertical lines at each indentation level
    ✓ Highlights the current scope (function/block you're in)
    ✓ Works with spaces and tabs
    ✓ Integrates with Treesitter for better scope detection
    ✓ Respects your colorscheme

  COMMANDS:
    :IBLEnable          = Enable indent guides
    :IBLDisable         = Disable indent guides
    :IBLToggle          = Toggle indent guides on/off
    :IBLEnableScope     = Enable scope highlighting
    :IBLDisableScope    = Disable scope highlighting
    :IBLToggleScope     = Toggle scope highlighting

  CUSTOMIZATION:
    If you want to change the appearance, edit this file and modify:
    - indent.char        (the character used for guides)
    - scope.enabled      (whether to highlight current scope)
    - exclude.filetypes  (file types to exclude)

  COLORS:
    The plugin uses these highlight groups:
    - IndentBlanklineChar           (normal indent guides - subtle gray)
    - IndentBlanklineContextChar    (current scope guides - brighter)
    - IndentBlanklineContextStart   (underline at scope start)

    Colors are defined in the config function above and match Gruvbox theme.
    They will automatically adapt if you change colorschemes.

================================================================================
--]]
