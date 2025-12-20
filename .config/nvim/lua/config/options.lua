--[[
================================================================================
  EDITOR OPTIONS
================================================================================

  This file configures how Neovim looks and behaves.
  These are all built-in Neovim settings - no plugins needed.

  HOW TO READ THIS FILE:
  - vim.g.xxx     = Sets a global variable (g = global)
  - vim.opt.xxx   = Sets an option (like :set xxx in Vim)
  - vim.o.xxx     = Also sets an option (shorthand)

  You can check any option's current value by typing:
    :set optionname?
  
  Or get help on any option:
    :help 'optionname'

--]]

--------------------------------------------------------------------------------
-- LEADER KEY
--------------------------------------------------------------------------------
-- The "leader" key is a prefix for custom keyboard shortcuts.
-- When you see <leader>sf, it means: press Space, then s, then f
-- We set this BEFORE loading plugins so they can use it too.

vim.g.mapleader = ' '        -- Space as the main leader key
vim.g.maplocalleader = ' '   -- Space also for buffer-local leader

--------------------------------------------------------------------------------
-- COPILOT SETTINGS
--------------------------------------------------------------------------------
-- By default, Copilot uses Tab to accept suggestions.
-- We disable this because Tab is used for other things (completion, indentation)
-- Instead, we'll use Ctrl+y to accept Copilot suggestions (configured in copilot.lua)

vim.g.copilot_no_tab_map = true

--------------------------------------------------------------------------------
-- COMPATIBILITY FIX
--------------------------------------------------------------------------------
-- Neovim 0.11 removed a function that some plugins (Telescope) still use.
-- This creates an alias so old plugins still work.
-- You can remove this once Telescope updates their code.

vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang

--------------------------------------------------------------------------------
-- LINE NUMBERS
--------------------------------------------------------------------------------
-- Show line numbers on the left side of the screen.
-- Relative numbers show distance from current line - useful for jumping!
-- Example: To jump 5 lines down, type "5j" - relative numbers make this easy.

vim.opt.number = true         -- Show absolute line number on current line
vim.opt.relativenumber = true -- Show relative numbers on other lines

-- What you'll see:
--   3  | function foo()
--   2  |   local x = 1
--   1  |   local y = 2
--  42  |   return x + y    <- Current line shows absolute number (42)
--   1  | end
--   2  |
--   3  | function bar()

--------------------------------------------------------------------------------
-- MOUSE
--------------------------------------------------------------------------------
-- Enable mouse support in all modes.
-- You can click to position cursor, drag to select, scroll, resize splits, etc.
-- Set to '' (empty string) to disable mouse entirely.

vim.opt.mouse = ''  -- 'a' = all modes (normal, visual, insert, command)

--------------------------------------------------------------------------------
-- CLIPBOARD
--------------------------------------------------------------------------------
-- By default, Neovim has its own clipboard separate from your system.
-- This syncs them so you can copy/paste between Neovim and other apps.
-- Requires a clipboard tool: xclip (Linux), pbcopy (Mac), or win32yank (Windows)

vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard for all yank/paste

--------------------------------------------------------------------------------
-- DISPLAY
--------------------------------------------------------------------------------
-- These options control what Neovim shows (or hides) on screen.

vim.opt.showmode = false     -- Don't show "-- INSERT --" in command line
                             -- (We have a statusline plugin that shows this)

vim.opt.signcolumn = 'yes'   -- Always show the sign column (left of line numbers)
                             -- This prevents text from jumping when signs appear
                             -- Signs are used for: git changes, diagnostics, breakpoints

vim.opt.cursorline = true    -- Highlight the line where the cursor is
                             -- Makes it easier to find your cursor

vim.opt.termguicolors = true -- Enable 24-bit RGB colors (millions of colors!)
                             -- Required for modern colorschemes to look correct

vim.opt.scrolloff = 10       -- Keep 10 lines visible above/below cursor
                             -- Prevents cursor from reaching the very edge

--------------------------------------------------------------------------------
-- SEARCH
--------------------------------------------------------------------------------
-- These options make searching more intuitive.

vim.opt.hlsearch = true      -- Highlight all matches when searching
                             -- Press <Esc> to clear (we set up this keymap)

vim.opt.ignorecase = true    -- Case-insensitive search by default
                             -- "hello" matches "Hello", "HELLO", etc.

vim.opt.smartcase = true     -- BUT if you type uppercase, become case-sensitive
                             -- "Hello" only matches "Hello", not "hello"

vim.opt.inccommand = 'split' -- Show live preview of :substitute command
                             -- Type :%s/old/new/ and see changes before confirming

--------------------------------------------------------------------------------
-- INDENTATION & TABS
--------------------------------------------------------------------------------
-- These control how indentation works.
-- In programming, consistent indentation is crucial for readability.

vim.opt.tabstop = 4          -- A <Tab> character displays as 4 spaces
vim.opt.shiftwidth = 4       -- Indentation (>> or <<) moves by 4 spaces
vim.opt.expandtab = true     -- Press Tab key inserts spaces, not a tab character
                             -- This is the modern standard for most languages

vim.opt.breakindent = true   -- Wrapped lines continue visually indented
                             -- Makes long lines easier to read

-- NOTE: The vim-sleuth plugin will auto-detect indent settings per file,
-- so if you open a file that uses 2-space indents, it will adjust automatically.

--------------------------------------------------------------------------------
-- WHITESPACE VISUALIZATION
--------------------------------------------------------------------------------
-- Show invisible characters so you can spot issues.
-- Trailing spaces and wrong indentation cause real bugs!

vim.opt.list = true          -- Enable showing invisible characters
vim.opt.listchars = {
  tab = '» ',                -- Show tabs as » followed by spaces
  trail = '·',               -- Show trailing spaces as dots
  nbsp = '␣',                -- Show non-breaking spaces with this symbol
}

--------------------------------------------------------------------------------
-- UNDO & BACKUP
--------------------------------------------------------------------------------
-- Persistent undo - even after closing a file, you can undo changes!
-- Neovim stores undo history in ~/.local/state/nvim/undo/

vim.opt.undofile = true      -- Save undo history to a file

--------------------------------------------------------------------------------
-- SPLITS
--------------------------------------------------------------------------------
-- When you split the window (like :vsplit or :split), these control
-- where the new window appears.

vim.opt.splitright = true    -- Vertical splits open to the right
vim.opt.splitbelow = true    -- Horizontal splits open below

-- This feels more natural - new content appears in fresh space,
-- and your original content stays where it was.

--------------------------------------------------------------------------------
-- TIMING
--------------------------------------------------------------------------------
-- These affect responsiveness and how quickly things happen.

vim.opt.updatetime = 250     -- Trigger CursorHold event after 250ms of no movement
                             -- Used for: showing diagnostics, highlighting references
                             -- Default is 4000ms (4 seconds) which feels slow

vim.opt.timeoutlen = 300     -- Time (ms) to wait for a mapped sequence to complete
                             -- If you type <leader> and wait 300ms without pressing
                             -- another key, Neovim gives up on the mapping
                             -- which-key plugin shows hints before this timeout

--------------------------------------------------------------------------------
-- CODE FOLDING
--------------------------------------------------------------------------------
-- Folding lets you collapse sections of code to see the big picture.
-- We use Treesitter-based folding which understands code structure.
--
-- HOW IT WORKS:
-- - Treesitter analyzes your code and knows where functions/classes/etc. are
-- - Neovim can fold (collapse) these regions
-- - By default, everything starts unfolded (foldlevel = 99)
--
-- FOLDING COMMANDS:
--   za      -- Toggle fold under cursor
--   zo      -- Open fold under cursor
--   zc      -- Close fold under cursor
--   zR      -- Open ALL folds in file
--   zM      -- Close ALL folds in file
--   zj/zk   -- Move to next/previous fold

vim.opt.foldmethod = 'expr'                      -- Use an expression to determine folds
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'  -- Treesitter decides fold regions
vim.opt.foldlevel = 99                           -- Start with all folds open
vim.opt.foldlevelstart = 99                      -- When opening a file, unfold everything

--------------------------------------------------------------------------------
-- GUI SETTINGS
--------------------------------------------------------------------------------
-- These only apply if you use a GUI Neovim (like Neovide, VimR, etc.)
-- They're ignored in terminal Neovim.

vim.opt.guifont = 'Iosevka Nerd Font:h14'  -- Font name and size for GUI
                                            -- Nerd Fonts include icons used by plugins
