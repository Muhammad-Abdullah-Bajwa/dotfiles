--[[
================================================================================
  COLORSCHEMES - MULTIPLE THEMES WITH PICKER
================================================================================

  A colorscheme controls the colors used throughout Neovim:
  - Syntax highlighting colors (keywords, strings, functions, etc.)
  - UI elements (statusline, line numbers, popups, etc.)
  - Plugin highlights (diagnostics, search matches, etc.)

  INSTALLED COLORSCHEMES:
    - dracula (default - high contrast purple/pink)
    - onedark (Atom's classic dark theme)
    - shades_of_purple (bold purple, VS Code port)
    - spaceduck (cosmic dark theme)
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
  'dracula',           -- Default: High contrast purple/pink classic
  'onedark',           -- Atom's iconic dark theme
  'shades_of_purple',  -- All-in on purple, high contrast
  'spaceduck',         -- Cosmic dark theme with deep blues
  'fluoromachine',     -- Retrowave synthwave aesthetic
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
  -- DRACULA (High contrast purple/pink) - DEFAULT
  -- ===========================================================================
  -- The classic dark theme with excellent readability
  -- Purple, pink, cyan, green accents on dark background
  -- Colors: Background #282a36, Foreground #f8f8f2, Accent #bd93f9
  {
    'Mofiqul/dracula.nvim',
    lazy = false,     -- Load immediately (it's our default theme)
    priority = 1000,  -- Load before other plugins

    config = function()
      require('dracula').setup({
        transparent_bg = false,
        italic_comment = true,
        show_end_of_buffer = false,
        lualine_bg_color = '#44475a',
        -- Full treesitter support is built-in
      })

      -- Set dracula as the default colorscheme
      vim.cmd.colorscheme('dracula')

      -- Register the colorscheme picker keymap
      vim.keymap.set('n', '<leader>cs', function()
        _G.ColorschemeModule.pick_colorscheme()
      end, {
        desc = '[C]olorscheme [S]witch',
      })
    end,
  },

  -- ===========================================================================
  -- ONEDARK (Atom's iconic dark theme)
  -- ===========================================================================
  -- The classic dark theme from Atom editor, balanced and easy on the eyes
  -- Great treesitter support, semantic highlighting, and LSP integration
  -- Colors: Background #282c34, Foreground #abb2bf, Accent #61afef
  {
    'navarasu/onedark.nvim',
    lazy = true,      -- Load on demand
    priority = 1000,

    config = function()
      require('onedark').setup({
        style = 'dark',
        transparent = false,
        term_colors = true,
        code_style = {
          comments = 'italic',
        },
        lsp_semantic_highlights = true,
        diagnostics = {
          darker = true,
          undercurl = true,
          background = true,
        },
      })
    end,
  },

  -- ===========================================================================
  -- SHADES OF PURPLE (All-in on purple)
  -- ===========================================================================
  -- A professional dark theme with bold purple tones
  -- Ported from the popular VS Code theme by Ahmad Awais
  -- Colors: Background #2D2B55, Foreground #A599E9, Accent #FAD000
  {
    'Rigellute/shades-of-purple.vim',
    lazy = true,      -- Load on demand
    priority = 1000,
  },

  -- ===========================================================================
  -- SPACEDUCK (Cosmic dark theme)
  -- ===========================================================================
  -- Deep space blues with cream/yellow accents
  -- A muted, cosmic aesthetic for long coding sessions
  {
    'pineapplegiant/spaceduck',
    branch = 'main',
    lazy = true,      -- Load on demand (no longer default)
    priority = 1000,

    config = function()
      vim.opt.termguicolors = true
    end,
  },

  -- ===========================================================================
  -- FLUOROMACHINE (Synthwave/Retrowave aesthetic)
  -- ===========================================================================
  -- Neon-on-dark synthwave theme with glow effects
  -- Variants: fluoromachine, retrowave, delta
  {
    'maxmx03/fluoromachine.nvim',
    lazy = true,      -- Load on demand (no longer default)
    priority = 1000,

    config = function()
      require('fluoromachine').setup({
        theme = 'retrowave',  -- 'fluoromachine', 'retrowave', or 'delta'
        glow = true,          -- Enable neon glow effect (CRT aesthetic)

        overrides = {
          -- Ensure comments are italic for readability
          ['@comment'] = { italic = true },
          ['Comment'] = { italic = true },
        },
      })
    end,
  },

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
