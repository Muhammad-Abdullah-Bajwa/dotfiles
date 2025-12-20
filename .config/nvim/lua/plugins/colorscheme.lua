--[[
================================================================================
  COLORSCHEME - GRUVBOX
================================================================================

  A colorscheme controls the colors used throughout Neovim:
  - Syntax highlighting colors (keywords, strings, functions, etc.)
  - UI elements (statusline, line numbers, popups, etc.)
  - Plugin highlights (diagnostics, search matches, etc.)

  WHY GRUVBOX?
  - Easy on the eyes (warm retro colors)
  - Great contrast in dark mode
  - Widely supported by other tools (terminal, IDE, etc.)
  - "Hard" contrast variant is even easier to read

  ALTERNATIVES:
  If you want to try a different colorscheme, some popular ones are:
    - 'catppuccin/nvim'     -- Pastel colors, modern look
    - 'folke/tokyonight.nvim' -- Purple/blue, very popular
    - 'rebelot/kanagawa.nvim' -- Japanese-inspired, elegant
    - 'rose-pine/neovim'    -- Soft, muted colors
    - 'sainnhe/everforest'  -- Green-based, comfortable

  TO CHANGE COLORSCHEME:
  1. Replace this plugin spec with your preferred colorscheme
  2. Update vim.cmd.colorscheme() to use the new name
  3. Restart Neovim

--]]

return {
  'zootedb0t/citruszest.nvim',

  -- PRIORITY: Load this plugin FIRST before other plugins
  -- This ensures colors are available when other plugins load
  -- Default priority is 50, colorschemes should use 1000
  priority = 1000,

  -- CONFIG: Function that runs after the plugin loads
  config = function()
    -- Set up citruszest with our preferred options
    require('citruszest').setup({
      option = {
        transparent = false,  -- Disable background transparency
        bold = false,         -- Don't use bold globally
        italic = true,        -- Enable italic for comments, etc.
      },
    })

    -- ACTIVATE: Tell Neovim to use this colorscheme
    -- This must be called AFTER setup() to apply our options
    vim.cmd.colorscheme('citruszest')
  end,
}

--[[
================================================================================
  UNDERSTANDING HIGHLIGHTS
================================================================================

  Neovim uses "highlight groups" to color different elements.
  Each group has:
    - fg (foreground/text color)
    - bg (background color)
    - bold, italic, underline, etc.

  Common highlight groups:
    Normal        -- Regular text
    Comment       -- Code comments
    String        -- "string literals"
    Function      -- function names
    Keyword       -- if, for, while, etc.
    Type          -- int, string, bool, etc.
    Error         -- Error messages
    Warning       -- Warning messages

  You can see all highlights with :highlight
  You can see a specific group with :highlight GroupName

  To customize a specific highlight:
    vim.api.nvim_set_hl(0, 'Comment', { fg = '#888888', italic = true })

================================================================================
--]]
