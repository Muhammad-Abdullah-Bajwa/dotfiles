--[[
================================================================================
  DIFFVIEW.NVIM - BEAUTIFUL GIT DIFF VIEWER
================================================================================

  Diffview provides a comprehensive interface for viewing git diffs and
  file history. It's like having a visual git tool built into Neovim.

  WHY DIFFVIEW?
  - See all changed files in one view
  - Side-by-side diff comparison
  - Browse file history with full context
  - Review commits before pushing
  - Resolve merge conflicts visually

  MAIN FEATURES:
  1. DIFF VIEW: See all current changes (staged + unstaged)
  2. FILE HISTORY: Browse the history of any file
  3. MERGE TOOL: Resolve conflicts with a 3-way diff

  KEYBINDINGS:
    <leader>gd  = Open diff view (current changes)
    <leader>gh  = File history (current file)
    <leader>gH  = File history (entire repo)
    <leader>gq  = Close diffview

--]]

return {
  'sindrets/diffview.nvim',

  -- CMD: Also load when these commands are used
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose' },

  -- KEYS: Lazy load when these keys are pressed
  keys = {
    {
      '<leader>gd',
      '<cmd>DiffviewOpen<cr>',
      desc = 'Open git diff view',
    },
    {
      '<leader>gh',
      '<cmd>DiffviewFileHistory %<cr>',
      desc = 'File history (current file)',
    },
    {
      '<leader>gH',
      '<cmd>DiffviewFileHistory<cr>',
      desc = 'File history (entire repo)',
    },
    {
      '<leader>gq',
      '<cmd>DiffviewClose<cr>',
      desc = 'Close diff view',
    },
  },

  -- OPTS: Configuration (using mostly defaults)
  opts = {
    -- ENHANCED_DIFF_HL: Use better diff highlighting
    enhanced_diff_hl = true,

    -- VIEW: Default layout for the diff view
    view = {
      -- MERGE_TOOL: Layout for resolving merge conflicts
      merge_tool = {
        -- LAYOUT: '3-way' shows base, ours, and theirs
        layout = 'diff3_mixed',
      },
    },

    -- FILE_PANEL: The panel showing list of changed files
    file_panel = {
      -- WIN_CONFIG: Window size for the file panel
      win_config = {
        width = 35,
      },
    },
  },
}

--[[
================================================================================
  DIFFVIEW QUICK REFERENCE
================================================================================

  OPENING DIFFVIEW:
    <leader>gd     = Open diff view (working tree changes)
    <leader>gh     = History of current file
    <leader>gH     = History of entire repository
    <leader>gq     = Close diffview

  COMMANDS:
    :DiffviewOpen                     = View current changes
    :DiffviewOpen HEAD~3              = Compare with 3 commits ago
    :DiffviewOpen main...feature      = Compare two branches
    :DiffviewFileHistory              = Repo history
    :DiffviewFileHistory %            = Current file history
    :DiffviewFileHistory path/to/file = Specific file history
    :DiffviewClose                    = Close the diffview

  INSIDE DIFFVIEW:
    <Tab>        = Select next file
    <S-Tab>      = Select previous file
    <CR>         = Open file / select commit
    -            = Stage/unstage file
    s            = Stage file
    u            = Unstage file
    X            = Discard changes
    R            = Refresh
    g?           = Show help
    q            = Close

  INSIDE FILE HISTORY:
    <CR>         = Open diff for selected commit
    y            = Copy commit hash
    zR           = Expand all folds
    zM           = Collapse all folds

  MERGE CONFLICTS:
    When you have merge conflicts, use :DiffviewOpen to:
    1. See all conflicting files
    2. Open 3-way diff (ours | base | theirs)
    3. Choose which version to keep
    4. Save and mark as resolved

================================================================================
--]]
