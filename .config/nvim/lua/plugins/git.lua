--[[
================================================================================
  GIT INTEGRATION - GITSIGNS
================================================================================

  Gitsigns shows git status directly in your editor:
  - Added lines: + sign in the gutter (left margin)
  - Modified lines: ~ sign in the gutter
  - Deleted lines: _ sign in the gutter

  This gives you immediate visual feedback about what you've changed
  without running git diff or leaving Neovim.

  OTHER GIT PLUGINS YOU MIGHT WANT:
  - vim-fugitive: Full git interface (:Git commands)
  - lazygit.nvim: Terminal UI for git
  - diffview.nvim: Better diff viewing
  - neogit: Magit-like git interface

--]]

return {
  'lewis6991/gitsigns.nvim',

  -- OPTS: Configuration passed to setup()
  -- When you use 'opts', lazy.nvim automatically calls setup(opts)
  opts = {
    -- SIGNS: Characters shown in the sign column (gutter)
    -- The sign column is the narrow column left of line numbers
    signs = {
      add = { text = '+' },           -- New lines not in the repo
      change = { text = '~' },        -- Modified lines
      delete = { text = '_' },        -- Deleted lines (shown on line above)
      topdelete = { text = '‾' },     -- Deleted lines at top of file
      changedelete = { text = '~' },  -- Changed then deleted
    },

    -- You can customize many more things:
    --
    -- current_line_blame = true,  -- Show git blame on current line
    -- current_line_blame_opts = {
    --   delay = 500,  -- ms to wait before showing blame
    -- },
    --
    -- on_attach = function(bufnr)
    --   -- Custom keymaps when gitsigns attaches to a buffer
    --   local gs = package.loaded.gitsigns
    --
    --   -- Navigation between hunks
    --   vim.keymap.set('n', ']c', gs.next_hunk, { buffer = bufnr, desc = 'Next git hunk' })
    --   vim.keymap.set('n', '[c', gs.prev_hunk, { buffer = bufnr, desc = 'Prev git hunk' })
    --
    --   -- Actions
    --   vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
    --   vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
    --   vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
    --   vim.keymap.set('n', '<leader>hb', gs.blame_line, { buffer = bufnr, desc = 'Blame line' })
    -- end,
  },
}

--[[
================================================================================
  GIT TERMINOLOGY
================================================================================

  For those new to git, here's what the signs mean:

  HUNK: A contiguous group of changed lines
        Git diff shows changes in "hunks" - sections of consecutive changes.

  STAGED: Changes marked to be included in the next commit
          (git add <file> stages changes)

  UNSTAGED: Changes in your working directory not yet staged
            (what you see before running git add)

  BLAME: Shows who last modified each line and when
         Useful for understanding code history

================================================================================
  USEFUL GITSIGNS COMMANDS
================================================================================

  These commands are available when gitsigns is active:

  :Gitsigns toggle_signs           -- Toggle showing signs
  :Gitsigns toggle_current_line_blame  -- Toggle inline blame
  :Gitsigns preview_hunk           -- Preview the hunk under cursor
  :Gitsigns stage_hunk             -- Stage the hunk under cursor
  :Gitsigns reset_hunk             -- Undo changes in hunk
  :Gitsigns stage_buffer           -- Stage all changes in file
  :Gitsigns reset_buffer           -- Undo all changes in file
  :Gitsigns diffthis               -- Show diff of current file

================================================================================
--]]
