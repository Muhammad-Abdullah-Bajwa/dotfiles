--[[
================================================================================
  OIL.NVIM - FILE EXPLORER AS A BUFFER
================================================================================

  Oil presents your file system as a regular Neovim buffer.
  Instead of a tree sidebar, directories open like files!

  WHY OIL INSTEAD OF A TREE?
  - You can EDIT the filesystem using normal Vim commands
  - Rename files by changing text
  - Delete files by deleting lines
  - Create files by adding new lines
  - Move files with yank/paste
  - Use all your Vim muscle memory!

  PHILOSOPHY:
  Oil treats files like text. The file system is just another buffer.
  This aligns with Vim's core idea: everything is text manipulation.

  HOW IT WORKS:
  1. Press '-' to open the parent directory
  2. Navigate like any buffer (j/k, /, etc.)
  3. Press <CR> on a file to open it, on a directory to enter it
  4. Press '-' again to go up another level
  5. Press 'q' to close

  EDITING FILES:
  1. Open oil with '-'
  2. Rename: Change the filename text
  3. Delete: Delete the line (dd)
  4. Create: Add a new line with a filename
  5. Save: Press <CR> or :w to apply changes
  
  Oil shows pending changes and asks for confirmation.

--]]

return {
  'stevearc/oil.nvim',

  -- DEPENDENCIES: Icons for file types
  dependencies = { 'nvim-tree/nvim-web-devicons' },

  -- KEYS: Press '-' to open oil (mirrors vim's default for netrw)
  -- The '-' key in vanilla vim opens netrw, so we keep this convention
  keys = {
    { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
  },

  -- OPTS: Configuration passed to oil.setup()
  opts = {
    -- VIEW_OPTIONS: What files/folders to show
    view_options = {
      -- SHOW_HIDDEN: Display hidden files (dotfiles)
      -- Press 'g.' in oil to toggle this
      show_hidden = true,
    },

    -- KEYMAPS: Custom keybindings inside oil buffers
    -- These only apply when you're inside an oil buffer
    keymaps = {
      -- CLOSE: Press 'q' to close oil and return to previous buffer
      ['q'] = 'actions.close',

      -- VERTICAL SPLIT: Open file in a vertical split
      ['<C-v>'] = 'actions.select_vsplit',

      -- HORIZONTAL SPLIT: Open file in a horizontal split
      ['<C-s>'] = 'actions.select_split',

      -- PREVIEW: Preview file without leaving oil
      ['<C-p>'] = 'actions.preview',

      -- REFRESH: Reload the directory contents
      ['<C-r>'] = 'actions.refresh',
    },

    -- FLOAT: Oil can open in a floating window instead of replacing buffer
    -- We keep the default (false) for the "directory as buffer" experience
    float = {
      padding = 2,
      max_width = 80,
      max_height = 30,
    },

    -- SKIP_CONFIRM_FOR_SIMPLE_EDITS: Skip confirmation for safe operations
    -- When true, simple renames don't show a confirmation dialog
    skip_confirm_for_simple_edits = true,

    -- DELETE_TO_TRASH: Move deleted files to trash instead of permanent delete
    -- Requires 'trash-cli' to be installed on your system
    -- Install with: sudo apt install trash-cli (or equivalent)
    delete_to_trash = true,
  },
}

--[[
================================================================================
  OIL.NVIM QUICK REFERENCE
================================================================================

  OPENING OIL:
    -             = Open parent directory of current file
    :Oil          = Open oil in current window
    :Oil <path>   = Open oil at specific path

  NAVIGATION:
    <CR>          = Open file or enter directory
    -             = Go to parent directory
    g.            = Toggle hidden files
    q             = Close oil

  FILE OPERATIONS:
    Edit text     = Rename file (change the filename)
    dd            = Delete file (delete the line)
    o             = Add new file (add a line with filename)
    O             = Add new directory (add a line ending with /)
    yy/p          = Copy/paste files
    :w            = Apply all pending changes

  OPENING FILES:
    <CR>          = Open in current window
    <C-v>         = Open in vertical split
    <C-s>         = Open in horizontal split
    <C-p>         = Preview without leaving oil

  TIPS:
  - End a filename with '/' to create a directory
  - Use '/' to search for files (it's just a buffer!)
  - Use visual mode to select multiple files for operations
  - Changes aren't applied until you save (:w)

================================================================================
--]]
