--[[
================================================================================
  TREESITTER TEXTOBJECTS - CODE-AWARE MOTIONS AND SELECTIONS
================================================================================

  This plugin extends Treesitter to provide smart text objects and motions.
  Unlike vim's built-in text objects (like 'iw' for inner word), these
  understand your code's actual structure.

  WHAT ARE TEXT OBJECTS?
  Text objects let you operate on meaningful chunks of text.
  Format: {operator}{modifier}{object}
  
  Examples:
    daf  = Delete A Function (entire function)
    cif  = Change Inner Function (function body only)
    yac  = Yank A Class (entire class)

  BUILT-IN VS TREESITTER TEXT OBJECTS:
  Built-in 'dip' (delete inner paragraph) doesn't understand code.
  Treesitter 'dif' (delete inner function) knows exactly where functions start/end.

  THREE MAIN FEATURES:
  1. SELECT - Text objects for selecting code blocks (af, if, ac, ic, etc.)
  2. MOVE - Jump between functions, classes, parameters (]f, [f, ]c, [c)
  3. SWAP - Swap function parameters (<leader>sa, <leader>sA)

--]]

return {
  'nvim-treesitter/nvim-treesitter-textobjects',

  -- BRANCH: Must use 'main' branch - the 'master' branch is frozen and
  -- incompatible with nvim-treesitter 1.0+ (which removed nvim-treesitter.configs)
  branch = 'main',

  -- DEPENDENCIES: Requires Treesitter (obviously!)
  dependencies = { 'nvim-treesitter/nvim-treesitter' },

  -- EVENT: Load when opening a buffer (after Treesitter is ready)
  event = 'BufReadPost',

  config = function()
    -- NOTE: The 'main' branch of nvim-treesitter-textobjects uses a new API.
    -- Configuration is done via require('nvim-treesitter-textobjects').setup()

    require('nvim-treesitter-textobjects').setup({
      select = {
        -- LOOKAHEAD: If cursor isn't on a text object, look ahead for one
        lookahead = true,
        -- Include surrounding whitespace
        include_surrounding_whitespace = false,
      },
      move = {
        -- SET_JUMPS: Add jumps to the jumplist (Ctrl-o to go back)
        set_jumps = true,
      },
    })

    -- ========================================================================
    -- SELECT - Text objects for visual selection
    -- ========================================================================
    -- Use with: v (visual), d (delete), c (change), y (yank)
    -- 
    -- MODIFIER:
    --   'a' = "around" - includes function signature, class keyword, etc.
    --   'i' = "inner"  - just the body/content
    --
    -- EXAMPLES:
    --   vaf   = Select entire function (including signature)
    --   vif   = Select function body only
    --   dac   = Delete entire class
    --   caa   = Change the entire parameter (including comma)
    --   yia   = Yank just the parameter value

    local select_keymaps = {
      -- Function text objects
      ['af'] = '@function.outer',  -- Entire function (signature + body)
      ['if'] = '@function.inner',  -- Function body only

      -- Class text objects
      ['ac'] = '@class.outer',     -- Entire class
      ['ic'] = '@class.inner',     -- Class body only

      -- Parameter/argument text objects (SUPER useful for refactoring!)
      ['aa'] = '@parameter.outer', -- Parameter with comma
      ['ia'] = '@parameter.inner', -- Parameter value only

      -- Conditional (if/else) text objects
      ['ai'] = '@conditional.outer',
      ['ii'] = '@conditional.inner',

      -- Loop text objects
      ['al'] = '@loop.outer',
      ['il'] = '@loop.inner',
    }

    -- Set up select keymaps for operator-pending and visual modes
    for keymap, query in pairs(select_keymaps) do
      vim.keymap.set({ 'x', 'o' }, keymap, function()
        require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects')
      end, { desc = 'Textobject: ' .. query })
    end

    -- ========================================================================
    -- MOVE - Jump between code structures
    -- ========================================================================
    -- Navigate through your code by jumping to functions, classes, etc.
    --
    -- CONVENTION:
    --   ] = next (forward)
    --   [ = previous (backward)
    --   lowercase = start of element
    --   UPPERCASE = end of element
    --
    -- EXAMPLES:
    --   ]f   = Jump to next function start
    --   [f   = Jump to previous function start
    --   ]F   = Jump to next function END
    --   ]c   = Jump to next class start

    local move = require('nvim-treesitter-textobjects.move')

    -- GOTO_NEXT_START: Jump forward to the START of something
    local goto_next_start = {
      [']f'] = '@function.outer',  -- Next function start
      [']c'] = '@class.outer',     -- Next class start
      [']a'] = '@parameter.inner', -- Next parameter
    }

    -- GOTO_NEXT_END: Jump forward to the END of something
    local goto_next_end = {
      [']F'] = '@function.outer',  -- Next function end
      [']C'] = '@class.outer',     -- Next class end
    }

    -- GOTO_PREVIOUS_START: Jump backward to the START of something
    local goto_previous_start = {
      ['[f'] = '@function.outer',  -- Previous function start
      ['[c'] = '@class.outer',     -- Previous class start
      ['[a'] = '@parameter.inner', -- Previous parameter
    }

    -- GOTO_PREVIOUS_END: Jump backward to the END of something
    local goto_previous_end = {
      ['[F'] = '@function.outer',  -- Previous function end
      ['[C'] = '@class.outer',     -- Previous class end
    }

    -- Set up movement keymaps
    for keymap, query in pairs(goto_next_start) do
      vim.keymap.set({ 'n', 'x', 'o' }, keymap, function()
        move.goto_next_start(query, 'textobjects')
      end, { desc = 'Next ' .. query .. ' start' })
    end

    for keymap, query in pairs(goto_next_end) do
      vim.keymap.set({ 'n', 'x', 'o' }, keymap, function()
        move.goto_next_end(query, 'textobjects')
      end, { desc = 'Next ' .. query .. ' end' })
    end

    for keymap, query in pairs(goto_previous_start) do
      vim.keymap.set({ 'n', 'x', 'o' }, keymap, function()
        move.goto_previous_start(query, 'textobjects')
      end, { desc = 'Previous ' .. query .. ' start' })
    end

    for keymap, query in pairs(goto_previous_end) do
      vim.keymap.set({ 'n', 'x', 'o' }, keymap, function()
        move.goto_previous_end(query, 'textobjects')
      end, { desc = 'Previous ' .. query .. ' end' })
    end

    -- ========================================================================
    -- SWAP - Swap code elements
    -- ========================================================================
    -- Quickly reorder function parameters without cut/paste.
    --
    -- HOW IT WORKS:
    -- 1. Put cursor on a parameter
    -- 2. Press <leader>sa to swap with next parameter
    -- 3. Press <leader>sA to swap with previous parameter
    --
    -- EXAMPLE:
    --   function foo(a, b, c)
    --   Cursor on 'b', press <leader>sa:
    --   function foo(a, c, b)

    local swap = require('nvim-treesitter-textobjects.swap')

    vim.keymap.set('n', '<leader>sa', function()
      swap.swap_next('@parameter.inner')
    end, { desc = 'Swap with next argument' })

    vim.keymap.set('n', '<leader>sA', function()
      swap.swap_previous('@parameter.inner')
    end, { desc = 'Swap with previous argument' })
  end,
}

--[[
================================================================================
  TREESITTER TEXTOBJECTS QUICK REFERENCE
================================================================================

  TEXT OBJECTS (use with v, d, c, y):
    af / if   = Around/Inner function
    ac / ic   = Around/Inner class
    aa / ia   = Around/Inner argument/parameter
    ai / ii   = Around/Inner conditional (if/else)
    al / il   = Around/Inner loop

  MOVEMENT:
    ]f / [f   = Next/Previous function start
    ]F / [F   = Next/Previous function end
    ]c / [c   = Next/Previous class start
    ]C / [C   = Next/Previous class end
    ]a / [a   = Next/Previous parameter

  SWAP:
    <leader>sa  = Swap parameter with next
    <leader>sA  = Swap parameter with previous

  EXAMPLES:
    daf         = Delete entire function
    cif         = Change function body (keep signature)
    vac         = Select entire class
    ]f]f]f      = Jump forward 3 functions
    <leader>sa  = Move this parameter to the right

================================================================================
--]]
