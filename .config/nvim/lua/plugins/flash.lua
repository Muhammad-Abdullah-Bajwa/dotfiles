--[[
================================================================================
  FLASH.NVIM - LIGHTNING FAST NAVIGATION
================================================================================

  Flash lets you jump to any location on screen with minimal keystrokes.
  
  HOW IT WORKS:
  1. Press '<leader>j' to activate flash (j for jump)
  2. Type 1-2 characters you want to jump to
  3. Labels appear on all matches
  4. Press the label key to jump there instantly

  EXAMPLE:
  You see "function" on line 50 and want to jump there:
  1. Press '<leader>j'
  2. Type 'fu'
  3. A label like 'a' appears on "function"
  4. Press 'a' to jump there

  WHY FLASH?
  - Faster than searching with /
  - Faster than line numbers (50G)
  - Works across visible screen
  - Visual feedback shows exactly where you'll land

  PHILOSOPHY:
  This config keeps flash separate from regular search (/).
  - '<leader>j' = Flash jump (j for jump, frees 's' for mini.surround)
  - '/' = Regular search (unchanged)

  One key, one action.

--]]

return {
  'folke/flash.nvim',

  -- EVENT: Load on these keys being pressed (lazy loading)
  event = 'VeryLazy',

  opts = {
    -- LABELS: Characters used for jump targets (in order of preference)
    -- Using home row keys first for easier reach
    labels = 'asdfghjklqwertyuiopzxcvbnm',

    -- SEARCH: Flash search settings
    search = {
      -- Don't use flash for regular '/' search
      -- This keeps '/' behaving exactly as before
      mode = 'search',
      incremental = true,
    },

    -- JUMP: What happens when you jump
    jump = {
      -- Jump to the start of the match
      pos = 'start',
      -- Save location in jumplist (so you can press Ctrl-o to go back)
      history = true,
      -- Register as jump for jumplist
      register = true,
      -- Clear highlight after jump
      nohlsearch = true,
      -- Automatically jump if there's only one match
      autojump = false,
    },

    -- LABEL: How labels are displayed
    label = {
      -- Show labels after the match (not on top of text)
      after = true,
      before = false,
      -- Allow uppercase labels to double available targets
      uppercase = true,
      -- Characters that won't be used as labels
      exclude = '',
      -- Minimum pattern length before showing labels
      min_pattern_length = 0,
      -- Use rainbow colors for labels (makes them easier to distinguish)
      rainbow = {
        enabled = true,
        shade = 5,
      },
    },

    -- MODES: Different flash modes
    modes = {
      -- Regular search with / - DISABLED to keep default behavior
      search = {
        enabled = false,  -- Don't modify / behavior
      },

      -- Character motions (f, F, t, T) - keep default behavior
      char = {
        enabled = false,  -- Don't modify f/F/t/T behavior
      },

      -- Treesitter mode for selecting code blocks
      treesitter = {
        labels = 'asdfghjklqwertyuiop',
        jump = { pos = 'range' },
        search = { incremental = false },
        label = { before = true, after = true, style = 'inline' },
        highlight = {
          backdrop = false,
          matches = false,
        },
      },
    },

    -- PROMPT: What shows in the command line
    prompt = {
      enabled = true,
      prefix = { { '⚡', 'FlashPromptIcon' } },
    },
  },

  -- KEYMAPS: Dedicated keys for flash (doesn't override anything)
  -- Using <leader>j instead of 's' to avoid conflict with mini.surround
  -- mini.surround uses: sa (add), sd (delete), sr (replace)
  keys = {
    {
      '<leader>j',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash [J]ump',
    },
    {
      '<leader>J',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter (select code block)',
    },
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash (operator pending)',
    },
    {
      'R',
      mode = { 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Treesitter Search',
    },
    -- INCREMENTAL TREESITTER SELECTION
    -- Press Ctrl+Space to start selecting, then:
    --   Ctrl+Space again = expand selection to next parent node
    --   Backspace = shrink selection to previous node
    -- 
    -- EXAMPLE:
    -- Cursor on 'x' in: if (x > 0) { return x * 2; }
    -- 1. Ctrl+Space: selects 'x'
    -- 2. Ctrl+Space: selects 'x > 0'
    -- 3. Ctrl+Space: selects '(x > 0)'
    -- 4. Ctrl+Space: selects 'if (x > 0) { return x * 2; }'
    -- 5. Backspace: shrinks back to '(x > 0)'
    {
      '<C-Space>',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter({
          jump = { pos = 'start' },
          label = { before = true, after = true },
        })
      end,
      desc = 'Treesitter incremental selection',
    },
  },
}

--[[
================================================================================
  FLASH KEYBINDING REFERENCE
================================================================================

  BASIC USAGE:
    <leader>j     Jump to any location (type chars, then label)
    <leader>J     Select code block using Treesitter

  OPERATOR PENDING (use with d, y, c, etc.):
    r             Remote flash - jump somewhere, do action, return
    R             Treesitter search

  EXAMPLES:
    <leader>j + "if" + a   Jump to the "if" labeled 'a'
    <leader>J              Expand selection to function/block
    d<leader>j + "x" + a   Delete from cursor to the "x" labeled 'a'

  INSIDE FLASH (after pressing '<leader>j'):
    <Esc>         Cancel flash
    <CR>          Jump to first match
    <Tab>         Toggle label display
    Any label     Jump to that location

  TIPS:
  - Type more characters to narrow down matches
  - Labels prioritize home row keys (a, s, d, f...)
  - Use <leader>J to quickly select functions, if-blocks, etc.
  - 's' key is now free for mini.surround (sa/sd/sr)

================================================================================
--]]
