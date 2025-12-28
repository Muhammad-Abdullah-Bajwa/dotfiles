--[[
================================================================================
  AUTOCOMMANDS
================================================================================

  Autocommands let you run code automatically when certain events happen.
  Think of them as "event listeners" or "hooks" in other programming languages.

  HOW AUTOCOMMANDS WORK:
  vim.api.nvim_create_autocmd(event, options)

  EVENTS are things like:
    "BufEnter"      -- When you enter a buffer (file)
    "BufWritePre"   -- Before writing (saving) a file
    "FileType"      -- When a file type is detected
    "VimEnter"      -- When Neovim finishes starting up
    "TextYankPost"  -- After you copy (yank) text
    "LspAttach"     -- When a language server attaches to a buffer

  AUGROUPS (Autocommand Groups):
  Groups help organize autocommands and prevent duplicates.
  When you source your config again, setting { clear = true } removes
  old autocommands before creating new ones.

  You can see all autocommands with:
    :autocmd

--]]

--------------------------------------------------------------------------------
-- HIGHLIGHT ON YANK
--------------------------------------------------------------------------------
-- When you copy (yank) text in Neovim, briefly highlight what was copied.
-- This gives visual feedback so you know exactly what you yanked.
--
-- Try it: Press "yy" to yank a line, or "yiw" to yank a word.
-- You'll see the text flash briefly.

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

--------------------------------------------------------------------------------
-- SPELL CHECK FOR MARKDOWN
--------------------------------------------------------------------------------
-- Enable spell checking for markdown files (notes, documentation).
-- Spell errors appear as underlines. Navigate with [s and ]s.
-- Add words to dictionary with zg. Show suggestions with z= or <leader>zs.
--
-- SPELL KEYBINDINGS (built-in):
--   [s        Go to previous misspelling
--   ]s        Go to next misspelling
--   z=        Show spell suggestions (popup)
--   zg        Add word to dictionary (good word)
--   zw        Mark word as wrong
--   zug       Undo zg (remove from dictionary)

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable spell checking for markdown',
  group = vim.api.nvim_create_augroup('markdown-spell', { clear = true }),
  pattern = { 'markdown', 'md' },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = 'en_us'
  end,
})
