--[[
================================================================================
  COLORSCHEMES - MULTIPLE THEMES WITH PICKER
================================================================================

  A colorscheme controls the colors used throughout Neovim:
  - Syntax highlighting colors (keywords, strings, functions, etc.)
  - UI elements (statusline, line numbers, popups, etc.)
  - Plugin highlights (diagnostics, search matches, etc.)

  INSTALLED COLORSCHEMES:
    - rose-pine (main, moon, dawn variants)
    - duskfox (from nightfox.nvim)

  QUICK SWITCH:
  Use <leader>sc to open the colorscheme picker

  TO ADD MORE COLORSCHEMES:
  1. Add the plugin spec to the return table below
  2. Add the colorscheme name to M.colorschemes table
  3. Restart Neovim

--]]

-- =============================================================================
-- COLORSCHEME PICKER MODULE
-- =============================================================================

local M = {}

-- List of colorschemes to show in the picker
-- Add new colorschemes here when you install them
M.colorschemes = {
  'rose-pine',
  'rose-pine-main',
  'rose-pine-moon',
  'rose-pine-dawn',
  'duskfox',
  'nightfox',
  'dayfox',
  'nordfox',
  'terafox',
  'carbonfox',
}

-- Pick a colorscheme using fzf-lua
function M.pick_colorscheme()
  local fzf = require('fzf-lua')

  fzf.fzf_exec(M.colorschemes, {
    prompt = 'Colorscheme❯ ',
    winopts = {
      height = 0.4,
      width = 0.3,
      row = 0.4,
    },
    actions = {
      ['default'] = function(selected)
        if selected and selected[1] then
          vim.cmd.colorscheme(selected[1])
          -- Save the selection so it persists (optional)
          vim.g.current_colorscheme = selected[1]
        end
      end,
    },
    -- Preview the colorscheme as you navigate
    fzf_opts = {
      ['--preview-window'] = 'hidden',
    },
  })
end

-- Store module globally so keymaps can access it
_G.ColorschemeModule = M

-- =============================================================================
-- PLUGIN SPECS
-- =============================================================================

return {
  -- ===========================================================================
  -- ROSÉ PINE
  -- ===========================================================================
  -- Soft, muted colors with elegant "soho vibes" aesthetic
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,

    config = function()
      require('rose-pine').setup({
        variant = 'main',       -- 'main', 'moon', or 'dawn'
        dark_variant = 'main',  -- Used when vim.o.background = 'dark'

        styles = {
          bold = false,
          italic = true,
          transparency = false,
        },

        highlight_groups = {
          Comment = { italic = true },
        },
      })
    end,
  },

  -- ===========================================================================
  -- NIGHTFOX (includes duskfox)
  -- ===========================================================================
  -- A highly customizable theme with multiple variants
  -- Variants: nightfox, dayfox, dawnfox, duskfox, nordfox, terafox, carbonfox
  {
    'EdenEast/nightfox.nvim',
    priority = 1000,

    config = function()
      require('nightfox').setup({
        options = {
          styles = {
            comments = 'italic',
            keywords = 'bold',
            functions = 'NONE',
          },
          inverse = {
            match_paren = false,
          },
        },
      })

      -- Set the default colorscheme (rose-pine)
      -- Change this if you want a different default
      vim.cmd.colorscheme('duskfox')

      -- Register the colorscheme picker keymap
      vim.keymap.set('n', '<leader>cs', function()
        _G.ColorschemeModule.pick_colorscheme()
      end, {
        desc = '[C]olorscheme [S]witch',
      })
    end,
  },
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
