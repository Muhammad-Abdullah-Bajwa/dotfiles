--[[
================================================================================
  KEYBOARD SHORTCUTS (KEYMAPS)
================================================================================

  This file defines keyboard shortcuts that DON'T depend on plugins.
  Plugin-specific keymaps are defined in each plugin's config file.

  HOW KEYMAPS WORK:
  vim.keymap.set(mode, key, action, options)
  
  MODES:
    'n' = Normal mode (default, when you're navigating)
    'i' = Insert mode (when you're typing text)
    'v' = Visual mode (when you're selecting text)
    'x' = Visual block mode
    't' = Terminal mode (inside :terminal)
    '' or {'n','v','i'} = Multiple modes

  COMMON OPTIONS:
    desc = "Description"     -- Shows up in which-key and help
    silent = true            -- Don't show the command in command line
    noremap = true           -- Don't allow the mapping to be remapped (default)
    expr = true              -- The action is an expression to evaluate
    buffer = 0               -- Only for current buffer

  NOTATION:
    <CR>      = Enter/Return key
    <Esc>     = Escape key
    <C-x>     = Ctrl + x
    <M-x>     = Alt + x (Meta)
    <S-x>     = Shift + x
    <leader>  = Leader key (Space in our config)
    <cmd>     = Command mode (same as pressing :)

--]]

--------------------------------------------------------------------------------
-- SEARCH
--------------------------------------------------------------------------------
-- After searching with / or ?, all matches stay highlighted.
-- This can be distracting, so we map Escape to clear the highlights.

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', {
  desc = 'Clear search highlighting',
})

-- Now you can:
-- 1. Search for something: /pattern<Enter>
-- 2. See all matches highlighted
-- 3. Press Escape to clear highlights when done

--------------------------------------------------------------------------------
-- CENTERED SCROLLING
--------------------------------------------------------------------------------
-- When scrolling half-page up/down, keep the cursor centered on screen.
-- This prevents losing your place when navigating large files.

vim.keymap.set('n', '<C-d>', '<C-d>zz', {
  desc = 'Scroll down and center',
})

vim.keymap.set('n', '<C-u>', '<C-u>zz', {
  desc = 'Scroll up and center',
})

-- TIP: You can also add centering to search navigation:
--   n = nzz (next match, centered)
--   N = Nzz (prev match, centered)

--------------------------------------------------------------------------------
-- DIAGNOSTICS
--------------------------------------------------------------------------------
-- Diagnostics are errors, warnings, and hints from LSP (Language Server).
-- These keymaps help you navigate and view them.

-- Jump to the previous diagnostic (error/warning)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {
  desc = 'Go to previous diagnostic',
})

-- Jump to the next diagnostic (error/warning)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {
  desc = 'Go to next diagnostic',
})

-- Show the full diagnostic message in a floating window
-- Useful when the message is too long to fit in the sign column
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {
  desc = 'Show diagnostic error messages',
})

-- Put all diagnostics from current file into the "quickfix list"
-- The quickfix list is a special window for navigating through a list of items
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
  desc = 'Open diagnostic quickfix list',
})

--------------------------------------------------------------------------------
-- TERMINAL MODE
--------------------------------------------------------------------------------
-- Neovim has a built-in terminal emulator (:terminal)
-- By default, Escape doesn't exit terminal mode, which is confusing.
-- This makes double-Escape exit terminal mode and return to normal mode.

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {
  desc = 'Exit terminal mode',
})

-- To use the terminal:
-- 1. :terminal           -- Open a terminal in current window
-- 2. i                   -- Enter insert mode to type commands
-- 3. <Esc><Esc>          -- Exit back to normal mode
-- 4. :q                  -- Close the terminal

--------------------------------------------------------------------------------
-- WINDOW NAVIGATION
--------------------------------------------------------------------------------
-- When you have multiple splits (windows), these let you move between them
-- using Ctrl + h/j/k/l (like Vim's movement keys).
--
-- Window layout example:
-- ┌─────────────┬─────────────┐
-- │             │             │
-- │   Window 1  │   Window 2  │
-- │   (Ctrl+h)  │   (Ctrl+l)  │
-- │             │             │
-- ├─────────────┼─────────────┤
-- │             │             │
-- │   Window 3  │   Window 4  │
-- │   (Ctrl+j)  │             │
-- │             │             │
-- └─────────────┴─────────────┘

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', {
  desc = 'Move focus to the left window',
})

vim.keymap.set('n', '<C-l>', '<C-w><C-l>', {
  desc = 'Move focus to the right window',
})

vim.keymap.set('n', '<C-j>', '<C-w><C-j>', {
  desc = 'Move focus to the lower window',
})

vim.keymap.set('n', '<C-k>', '<C-w><C-k>', {
  desc = 'Move focus to the upper window',
})

-- TIP: To create splits:
--   :vsplit or <C-w>v    -- Vertical split (side by side)
--   :split or <C-w>s     -- Horizontal split (stacked)
--   :q                   -- Close current window
--   <C-w>=               -- Make all windows equal size
--   <C-w>_               -- Maximize current window height
--   <C-w>|               -- Maximize current window width

--------------------------------------------------------------------------------
-- BUFFER MANAGEMENT
--------------------------------------------------------------------------------
-- WINDOWS vs BUFFERS:
-- - A BUFFER is a file loaded into memory (like a "document")
-- - A WINDOW is a viewport showing a buffer (like a "pane")
-- - Multiple windows can show the same buffer
-- - Closing a window (:q) doesn't close the buffer!
--
-- Example:
-- ┌─────────────────────────────────────────────┐
-- │ Window 1        │ Window 2                  │
-- │ (Buffer: a.lua) │ (Buffer: b.lua)           │
-- └─────────────────────────────────────────────┘
-- If you :q Window 1, Buffer a.lua is still open in background!
-- Use these keymaps to actually close buffers.

-- Close current buffer
-- :bdelete removes the buffer from the buffer list but keeps it in memory
-- (can be accessed with :buffer <name> if needed)
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', {
  desc = 'Close buffer',
})

-- Force close buffer (discard unsaved changes)
-- The '!' makes it ignore unsaved changes - use carefully!
vim.keymap.set('n', '<leader>bD', '<cmd>bdelete!<CR>', {
  desc = 'Force close buffer (discard changes)',
})

-- Close all other buffers (keep only current one)
-- %bdelete = close ALL buffers
-- e# = reopen the alternate file (last buffer we were in)
-- bd# = delete that alternate buffer, leaving only current
vim.keymap.set('n', '<leader>bo', '<cmd>%bdelete|e#|bd#<CR>', {
  desc = 'Close other buffers',
})

-- TIP: Useful buffer commands:
--   :ls or :buffers      -- List all open buffers
--   :bnext or :bn        -- Go to next buffer
--   :bprev or :bp        -- Go to previous buffer
--   :buffer <name>       -- Switch to buffer by name
--   :b <partial>         -- Switch with tab-completion

--------------------------------------------------------------------------------
-- SMART YANK COMMANDS FOR AI CONTEXT
--------------------------------------------------------------------------------
-- These keymaps help you copy code with rich context for AI assistants.
-- When working with Copilot, ChatGPT, or other AI tools, providing
-- context like file paths and line numbers makes the AI more accurate.
--
-- WHY THESE ARE USEFUL:
-- - AI tools work better with context (file path, line numbers)
-- - Copying code blocks with proper markdown formatting
-- - Building up context by appending multiple selections
--
-- APPEND VS REPLACE BEHAVIOR:
-- - Code yanks (yc, yC, ys, yF) APPEND to clipboard by default
--   This lets you gather context from multiple files easily!
-- - Path/location yanks (yp, yP, yl, yL, yf, yd) REPLACE clipboard
--   These are typically used standalone
--
-- WORKFLOW EXAMPLE:
-- 1. <leader>yX         -- Clear clipboard (start fresh)
-- 2. Go to file A, select code, <leader>yx  -- Smart yank (first item)
-- 3. Go to file B, select code, <leader>yx  -- Appends to clipboard
-- 4. Go to file C, <leader>yF              -- Append entire function
-- 5. Paste everything into AI chat!
--
-- Use <leader>yX to clear the clipboard when starting fresh
--
-- ALL YANK COMMANDS USE THE '+' REGISTER (system clipboard)

--------------------------------------------------------------------------------
-- HELPER FUNCTION: append_to_clipboard
--------------------------------------------------------------------------------
-- This helper appends content to the clipboard instead of replacing it.
-- If clipboard is empty, it just sets the content (no leading newlines).
-- If clipboard has content, it adds two newlines as separator then appends.
--
-- PARAMETERS:
--   content (string) - The text to add to clipboard
--   message (string) - What to print to user (for feedback)
--
-- EXAMPLE:
--   Clipboard: "first block"
--   append_to_clipboard("second block", "my code")
--   Clipboard: "first block\n\nsecond block"
--   Prints: "Appended: my code"
local function append_to_clipboard(content, message)
  -- Get current clipboard contents using the '+' register
  -- The '+' register is the system clipboard on Linux/Mac/Windows
  local existing = vim.fn.getreg('+')

  if existing ~= '' then
    -- Clipboard has content - append with separator
    -- Two newlines create visual separation between code blocks
    vim.fn.setreg('+', existing .. '\n\n' .. content)
    print('Appended: ' .. message)
  else
    -- Clipboard is empty - just set content (no leading newlines)
    vim.fn.setreg('+', content)
    print('Copied: ' .. message)
  end
end

--------------------------------------------------------------------------------
-- PATH YANKS (replace clipboard - standalone use)
--------------------------------------------------------------------------------
-- These copy file paths/locations. They REPLACE the clipboard because
-- you typically use these one at a time, not building up context.

-- YANK FILE PATH (relative)
-- Copies the file path relative to the current working directory
-- Example: "lua/config/keymaps.lua"
--
-- WHEN TO USE: When sharing file locations in a project
-- The '%' register contains the current file name
vim.keymap.set('n', '<leader>yp', function()
  -- vim.fn.expand('%') gets the filename as it was opened
  -- If you opened "lua/config/keymaps.lua", that's what you get
  local path = vim.fn.expand('%')
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, { desc = 'Yank file path (relative)' })

-- YANK FILE PATH (absolute)
-- Copies the full path from root
-- Example: "/home/user/project/lua/config/keymaps.lua"
--
-- WHEN TO USE: When you need the complete unambiguous path
-- The ':p' modifier expands to full path
vim.keymap.set('n', '<leader>yP', function()
  -- '%:p' = current file ('%') expanded to full path (':p')
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, { desc = 'Yank file path (absolute)' })

-- YANK FILE:LINE
-- Copies file path with current line number
-- Example: "lua/config/keymaps.lua:42"
--
-- WHEN TO USE: Directing someone (or AI) to a specific line
-- Many editors and tools understand this format for jumping to locations
vim.keymap.set('n', '<leader>yl', function()
  -- vim.fn.line('.') returns current line number (1-indexed)
  local loc = vim.fn.expand('%') .. ':' .. vim.fn.line('.')
  vim.fn.setreg('+', loc)
  print('Copied: ' .. loc)
end, { desc = 'Yank file:line' })

-- YANK FILE:LINE:COLUMN
-- Copies file path with line AND column number
-- Example: "lua/config/keymaps.lua:42:15"
--
-- WHEN TO USE: Maximum precision, exact cursor position
-- Some tools use this for precise navigation
vim.keymap.set('n', '<leader>yL', function()
  -- vim.fn.col('.') returns current column number (1-indexed)
  local loc = vim.fn.expand('%') .. ':' .. vim.fn.line('.') .. ':' .. vim.fn.col('.')
  vim.fn.setreg('+', loc)
  print('Copied: ' .. loc)
end, { desc = 'Yank file:line:col' })

-- YANK FILENAME ONLY
-- Copies just the filename without any directory path
-- Example: "keymaps.lua"
--
-- WHEN TO USE: When you just need the file name
-- The ':t' modifier means "tail" (last component of path)
vim.keymap.set('n', '<leader>yf', function()
  -- '%:t' = current file, tail only (filename)
  local name = vim.fn.expand('%:t')
  vim.fn.setreg('+', name)
  print('Copied: ' .. name)
end, { desc = 'Yank filename only' })

-- YANK DIRECTORY PATH
-- Copies the directory containing the current file
-- Example: "/home/user/project/lua/config"
--
-- WHEN TO USE: For cd commands or referencing the folder
-- The ':p:h' means full path (':p') then head/directory (':h')
vim.keymap.set('n', '<leader>yd', function()
  -- '%:p:h' = current file, full path, head (directory part)
  local dir = vim.fn.expand('%:p:h')
  vim.fn.setreg('+', dir)
  print('Copied: ' .. dir)
end, { desc = 'Yank directory path' })

--------------------------------------------------------------------------------
-- CODE YANKS (append to clipboard - build up context)
--------------------------------------------------------------------------------
-- These copy code with rich context. They APPEND to clipboard so you can
-- gather context from multiple locations/files before pasting to AI.

-- YANK CODE BLOCK WITH CONTEXT (visual mode)
-- APPENDS to clipboard - gather context from multiple files!
--
-- HOW IT WORKS:
-- 1. Select some code in visual mode (v, V, or Ctrl-v)
-- 2. Press <leader>yc
-- 3. Selection is copied with markdown formatting and file info
--
-- OUTPUT FORMAT:
-- ```lua
-- // lua/config/keymaps.lua:10-15
-- local x = 1
-- local y = 2
-- return x + y
-- ```
--
-- WHY MARKDOWN CODE FENCES:
-- - AI tools render them nicely
-- - Syntax highlighting in chat
-- - Clear boundaries between code blocks
vim.keymap.set('v', '<leader>yc', function()
  -- Get the line numbers of the visual selection
  -- vim.fn.line('v') = line where visual mode started
  -- vim.fn.line('.') = current cursor line
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')

  -- Handle selection made upward (end before start)
  -- If you select from line 20 to line 10, swap them
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  -- Get the actual text content of those lines
  -- nvim_buf_get_lines(buffer, start, end, strict_indexing)
  --   buffer 0 = current buffer
  --   start is 0-indexed, so subtract 1
  --   end is exclusive, so end_line is correct
  --   strict_indexing false = don't error on out-of-bounds
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Get file path for context
  local path = vim.fn.expand('%')

  -- Build the markdown-formatted output
  -- string.format works like printf in C
  -- %s = string, %d = integer
  local content = string.format(
    '```%s\n// %s:%d-%d\n%s\n```',
    vim.bo.filetype,              -- Language for syntax highlighting (e.g., "lua")
    path,                          -- File path
    start_line,                    -- Starting line number
    end_line,                      -- Ending line number
    table.concat(lines, '\n')      -- Join all lines with newlines
  )

  -- Append to clipboard (or set if empty)
  append_to_clipboard(content, #lines .. ' lines from ' .. path)
end, { desc = 'Yank code with context (appends)' })

-- YANK CODE WITH SURROUNDING CONTEXT (visual mode)
-- APPENDS to clipboard - gather context from multiple files!
--
-- DIFFERENCE FROM <leader>yc:
-- This includes 5 lines BEFORE and AFTER your selection.
-- Helps AI understand what surrounds your code.
--
-- EXAMPLE:
-- You select lines 50-52. This copies lines 45-57 (5 before, 5 after)
-- The output notes which lines were your actual selection.
--
-- OUTPUT FORMAT:
-- ```lua
-- // lua/config/keymaps.lua:45-57 (selection: 50-52)
-- -- line 45 (context before)
-- -- ...
-- -- line 50 (your selection starts)
-- -- line 51
-- -- line 52 (your selection ends)
-- -- ...
-- -- line 57 (context after)
-- ```
--
-- WHEN TO USE:
-- When AI needs to understand the surrounding code to help you
-- e.g., "Why isn't this working?" - AI sees what's around it
vim.keymap.set('v', '<leader>yC', function()
  -- How many lines of context to include above and below
  local context = 5

  -- Get visual selection boundaries (same as <leader>yc)
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  -- Calculate the expanded range with context
  -- math.max ensures we don't go below line 1
  -- math.min ensures we don't go past end of file
  local buf_lines = vim.api.nvim_buf_line_count(0)  -- Total lines in buffer
  local ctx_start = math.max(1, start_line - context)
  local ctx_end = math.min(buf_lines, end_line + context)

  -- Get all the lines (selection + context)
  local lines = vim.api.nvim_buf_get_lines(0, ctx_start - 1, ctx_end, false)
  local path = vim.fn.expand('%')

  -- Format includes both the full range AND the original selection
  -- So AI knows what you actually selected vs context
  local content = string.format(
    '```%s\n// %s:%d-%d (selection: %d-%d)\n%s\n```',
    vim.bo.filetype,
    path,
    ctx_start,              -- Start of context
    ctx_end,                -- End of context
    start_line,             -- Original selection start
    end_line,               -- Original selection end
    table.concat(lines, '\n')
  )

  append_to_clipboard(content, 'lines with surrounding context from ' .. path)
end, { desc = 'Yank with surrounding context (appends)' })

-- YANK WITH SMART CONTEXT (visual mode)
-- APPENDS to clipboard - gather context from multiple files!
--
-- THE SMARTEST YANK - Uses Treesitter to understand your code!
--
-- WHAT IT DOES:
-- 1. Copies your visual selection
-- 2. Uses Treesitter to find what FUNCTION you're inside
-- 3. Uses Treesitter to find what CLASS you're inside
-- 4. Includes the function signature and class declaration
--
-- WHY THIS IS POWERFUL:
-- AI now knows:
-- - What file you're in
-- - What class this code belongs to
-- - What function this code is part of
-- - The exact lines you selected
--
-- OUTPUT FORMAT:
-- ```cpp
-- // src/player.cpp:150-155
-- // Class: class Player : public Entity {
-- // Function:
-- void Player::update(float deltaTime) {
--
-- // Selection:
--     position.x += velocity.x * deltaTime;
--     position.y += velocity.y * deltaTime;
-- ```
--
-- TREESITTER BACKGROUND:
-- Treesitter parses your code into a syntax tree. Each piece of code
-- is a "node" in the tree. Functions contain statements, classes contain
-- functions, etc. We walk UP the tree to find containing structures.
vim.keymap.set('v', '<leader>yx', function()
  -- Get visual selection (same as other yanks)
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  -- Get the selected text
  local selected_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- ======================================================================
  -- TREESITTER MAGIC: Walk up the syntax tree to find context
  -- ======================================================================
  -- Start at the current cursor position's syntax node
  -- NOTE: vim.treesitter.get_node() replaced nvim-treesitter's ts_utils in 1.0+
  local node = vim.treesitter.get_node()

  -- Check if treesitter is working for this buffer
  if not node then
    print('Treesitter not available (install parser with :TSInstall ' .. vim.bo.filetype .. ')')
    return
  end

  local func_node = nil   -- Will hold the function node if found
  local class_node = nil  -- Will hold the class node if found

  -- Walk up the tree (node -> parent -> grandparent -> ...)
  -- until we find function and class nodes (or reach the root)
  while node do
    local type = node:type()  -- e.g., "function_definition", "class_declaration"

    -- Check for function-like nodes
    -- Different languages use different node types, so we check many:
    -- - "function_definition" (Python, Lua)
    -- - "function_declaration" (C, JavaScript)
    -- - "method_definition" (JavaScript classes)
    -- - "function_item" (Rust)
    -- - type:match('function') catches things like "arrow_function"
    if
      not func_node
      and (
        type:match('function')
        or type:match('method')
        or type == 'function_definition'
        or type == 'function_declaration'
        or type == 'method_definition'
        or type == 'function_item'
      )
    then
      func_node = node
    end

    -- Check for class-like nodes
    -- Again, different languages use different types:
    -- - "class_definition" (Python)
    -- - "class_declaration" (JavaScript, TypeScript)
    -- - "class_specifier" (C++)
    -- - "struct_item" (Rust struct)
    -- - "impl_item" (Rust impl block)
    if
      not class_node
      and (
        type:match('class')
        or type == 'class_definition'
        or type == 'class_declaration'
        or type == 'class_specifier'
        or type == 'struct_item'
        or type == 'impl_item'
      )
    then
      class_node = node
    end

    -- Move up to parent node
    node = node:parent()
  end

  -- ======================================================================
  -- BUILD THE CONTEXT STRING
  -- ======================================================================
  local context_parts = {}
  local path = vim.fn.expand('%')

  -- Add class context if we found one
  if class_node then
    -- node:range() returns (start_row, start_col, end_row, end_col)
    -- All 0-indexed. We just need start_row for the first line.
    local class_start, _, _, _ = class_node:range()
    -- Get just the first line of the class (the declaration line)
    local class_line = vim.api.nvim_buf_get_lines(0, class_start, class_start + 1, false)[1]
    -- vim.trim() removes leading/trailing whitespace
    table.insert(context_parts, '// Class: ' .. vim.trim(class_line))
  end

  -- Add function context if we found one
  if func_node then
    local func_start, _, _, _ = func_node:range()
    local func_lines = {}

    -- Get the function signature (first few lines until we hit '{' or '=>')
    -- This captures multi-line function signatures like:
    --   function foo(
    --     arg1: string,
    --     arg2: number
    --   ) {
    for i = func_start, math.min(func_start + 5, vim.api.nvim_buf_line_count(0) - 1) do
      local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
      table.insert(func_lines, line)
      -- Stop when we see the opening brace or arrow function
      if line:match('{') or line:match('=>') then
        break
      end
    end
    table.insert(context_parts, '// Function:\n' .. table.concat(func_lines, '\n'))
  end

  -- ======================================================================
  -- ASSEMBLE FINAL OUTPUT
  -- ======================================================================
  local header = string.format('// %s:%d-%d', path, start_line, end_line)

  -- Join context parts (class + function) with newlines
  -- Add extra newline before selection for readability
  local context = #context_parts > 0 and (table.concat(context_parts, '\n') .. '\n\n') or ''

  local content = string.format(
    '```%s\n%s\n%s// Selection:\n%s\n```',
    vim.bo.filetype,
    header,
    context,
    table.concat(selected_lines, '\n')
  )

  append_to_clipboard(content, 'smart context from ' .. path)
end, { desc = 'Yank with smart context (appends)' })

-- YANK ENTIRE FUNCTION WITH CONTEXT (normal mode)
-- APPENDS to clipboard - gather context from multiple files!
--
-- THE LAZY YANK - Just be inside a function and press <leader>yF!
--
-- HOW IT WORKS:
-- 1. No need to select anything - just have cursor inside a function
-- 2. Treesitter finds the entire function boundaries
-- 3. Copies the WHOLE function with class context
--
-- WHEN TO USE:
-- - "Here's the function I'm working on"
-- - "What's wrong with this function?"
-- - Faster than selecting the whole function manually
--
-- OUTPUT FORMAT:
-- ```python
-- // src/utils.py:45-62
-- // In: class DataProcessor:
--
-- def process_batch(self, items: List[Item]) -> List[Result]:
--     """Process a batch of items."""
--     results = []
--     for item in items:
--         results.append(self.process_item(item))
--     return results
-- ```
--
-- NOTE: This is a NORMAL MODE mapping, not visual mode!
-- You don't need to select anything first.
vim.keymap.set('n', '<leader>yF', function()
  -- Start at cursor and walk up the tree
  -- NOTE: vim.treesitter.get_node() replaced nvim-treesitter's ts_utils in 1.0+
  local node = vim.treesitter.get_node()

  -- Check if treesitter is working for this buffer
  if not node then
    print('Treesitter not available (install parser with :TSInstall ' .. vim.bo.filetype .. ')')
    return
  end

  local func_node = nil
  local class_node = nil

  -- Walk up to find function and class (same logic as <leader>yx)
  while node do
    local type = node:type()

    -- Look for function nodes
    if
      not func_node
      and (
        type:match('function')
        or type:match('method')
        or type == 'function_definition'
        or type == 'function_declaration'
        or type == 'method_definition'
        or type == 'function_item'
      )
    then
      func_node = node
    end

    -- Look for class nodes
    if
      not class_node
      and (
        type:match('class')
        or type == 'class_definition'
        or type == 'class_declaration'
        or type == 'class_specifier'
        or type == 'struct_item'
        or type == 'impl_item'
      )
    then
      class_node = node
    end
    node = node:parent()
  end

  -- Must be inside a function to use this
  if not func_node then
    print('Not inside a function')
    return
  end

  local path = vim.fn.expand('%')

  -- Get the ENTIRE function using Treesitter's range info
  -- node:range() returns 0-indexed (start_row, start_col, end_row, end_col)
  local func_start, _, func_end, _ = func_node:range()

  -- Get all lines of the function
  -- Note: func_end is the last row, but nvim_buf_get_lines end is exclusive
  -- So we use func_end + 1 to include the last line
  local func_lines = vim.api.nvim_buf_get_lines(0, func_start, func_end + 1, false)

  -- Build class context (simpler than <leader>yx - just one line)
  local context = ''
  if class_node then
    local class_start, _, _, _ = class_node:range()
    local class_line = vim.api.nvim_buf_get_lines(0, class_start, class_start + 1, false)[1]
    context = '// In: ' .. vim.trim(class_line) .. '\n\n'
  end

  -- Assemble final output
  -- Note: func_start/func_end are 0-indexed, add 1 for human-readable line numbers
  local content = string.format(
    '```%s\n// %s:%d-%d\n%s%s\n```',
    vim.bo.filetype,
    path,
    func_start + 1,  -- Convert to 1-indexed for display
    func_end + 1,    -- Convert to 1-indexed for display
    context,
    table.concat(func_lines, '\n')
  )

  append_to_clipboard(content, 'function from ' .. path)
end, { desc = 'Yank entire function with context (appends)' })

--------------------------------------------------------------------------------
-- UTILITY YANKS
--------------------------------------------------------------------------------
-- These are helper yanks for special situations.

-- YANK PROJECT TREE
-- Copies a tree view of the project structure
--
-- WHY THIS IS USEFUL:
-- AI can understand your project layout to give better suggestions.
-- "Here's my project structure, where should I add a new feature?"
--
-- HOW IT WORKS:
-- 1. Tries the 'tree' command first (prettier output)
-- 2. Falls back to 'find' if tree isn't installed
-- 3. Excludes common junk directories (node_modules, .git, etc.)
--
-- REQUIREMENTS:
-- - For best results, install 'tree': sudo apt install tree
-- - Works without tree, but output is less pretty
--
-- OUTPUT FORMAT:
-- ```
-- .
-- ├── src/
-- │   ├── main.lua
-- │   └── utils/
-- │       └── helpers.lua
-- ├── tests/
-- │   └── test_main.lua
-- └── README.md
-- ```
vim.keymap.set('n', '<leader>yt', function()
  -- Run tree command (or find as fallback)
  -- -L 3: limit to 3 levels deep
  -- -I "...": ignore these patterns
  -- --noreport: don't show summary line
  -- 2>/dev/null: suppress errors if tree not installed
  -- || find ...: fallback if tree fails
  local handle = io.popen(
    'tree -L 3 -I "node_modules|target|build|.git|__pycache__|*.o|*.obj" --noreport 2>/dev/null || find . -maxdepth 3 -type f | head -50'
  )

  -- Read entire output
  local tree = handle:read('*a')
  handle:close()

  -- Wrap in markdown code fence (no language = plain text)
  local content = string.format('```\n%s```', tree)
  vim.fn.setreg('+', content)  -- Replace clipboard (not append)
  print('Copied project tree')
end, { desc = 'Yank project tree' })

-- YANK GIT DIFF
-- Copies the current git diff (unstaged or staged)
-- APPENDS to clipboard for building context
--
-- WHAT IT COPIES:
-- 1. First tries unstaged changes (git diff)
-- 2. If no unstaged, tries staged changes (git diff --cached)
-- 3. Prints "No changes" if nothing to copy
--
-- WHY THIS IS USEFUL:
-- - "Here's what I changed, does it look right?"
-- - "I'm getting an error after these changes"
-- - Code review context for AI
--
-- OUTPUT FORMAT:
-- ```diff
-- diff --git a/file.lua b/file.lua
-- --- a/file.lua
-- +++ b/file.lua
-- @@ -10,3 +10,4 @@
--  existing line
-- +new line I added
-- ```
vim.keymap.set('n', '<leader>yD', function()
  -- Try unstaged changes first
  local handle = io.popen('git diff --no-color 2>/dev/null')
  local diff = handle:read('*a')
  handle:close()

  -- If no unstaged changes, try staged changes
  if diff == '' then
    handle = io.popen('git diff --cached --no-color 2>/dev/null')
    diff = handle:read('*a')
    handle:close()
  end

  -- Nothing to copy
  if diff == '' then
    print('No changes')
    return
  end

  -- Use 'diff' language for syntax highlighting
  local content = string.format('```diff\n%s```', diff)
  append_to_clipboard(content, 'git diff')
end, { desc = 'Yank git diff (appends)' })

-- YANK RAW (visual mode) - REPLACES clipboard
-- For when you want to copy code WITHOUT appending
--
-- USE CASE:
-- You've been building up context, but now you want to start fresh
-- with just one selection. Use this instead of yX + yc.
--
-- This is identical to <leader>yc but REPLACES instead of appending.
vim.keymap.set('v', '<leader>yr', function()
  local start_line = vim.fn.line('v')
  local end_line = vim.fn.line('.')
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local path = vim.fn.expand('%')
  local content = string.format(
    '```%s\n// %s:%d-%d\n%s\n```',
    vim.bo.filetype,
    path,
    start_line,
    end_line,
    table.concat(lines, '\n')
  )

  -- Note: setreg REPLACES (unlike append_to_clipboard which appends)
  vim.fn.setreg('+', content)
  print('Copied (replaced clipboard): ' .. #lines .. ' lines')
end, { desc = 'Yank code (replaces clipboard)' })

-- CLEAR CLIPBOARD
-- Start fresh when building up context
--
-- WORKFLOW:
-- 1. You've pasted your accumulated context to AI
-- 2. Now you want to start gathering new context
-- 3. <leader>yX clears the clipboard
-- 4. Continue with yc, ys, yF, etc.
vim.keymap.set('n', '<leader>yX', function()
  vim.fn.setreg('+', '')  -- Set clipboard to empty string
  print('Clipboard cleared')
end, { desc = 'Clear clipboard' })

--------------------------------------------------------------------------------
-- PROMPT LIBRARY PICKER
--------------------------------------------------------------------------------
-- These keymaps let you manage a library of reusable prompts.
-- Store your favorite AI prompts in ~/.copilot-prompts/ and quickly access them.
--
-- WORKFLOW:
-- 1. Create prompt files in ~/.copilot-prompts/ (e.g., refactor.md, explain.md)
-- 2. Use <leader>pp to browse and copy a prompt to clipboard
-- 3. Paste into your AI chat with Ctrl+v
--
-- PROMPT DIRECTORY: ~/.copilot-prompts/
-- Create this directory and add .md files with your prompts

-- PICK PROMPT AND COPY TO CLIPBOARD
-- Opens Telescope to browse your prompt library
vim.keymap.set('n', '<leader>pp', function()
  local prompts_dir = vim.fn.expand('~/.copilot-prompts')

  -- Check if directory exists
  if vim.fn.isdirectory(prompts_dir) == 0 then
    print('Prompts directory not found: ' .. prompts_dir)
    print('Create it with: mkdir ~/.copilot-prompts')
    return
  end

  require('telescope.builtin').find_files({
    prompt_title = 'Select Prompt',
    cwd = prompts_dir,
    previewer = true,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      -- Override default action to copy file content to clipboard
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        local filepath = prompts_dir .. '/' .. selection.value
        local file = io.open(filepath, 'r')
        if file then
          local content = file:read('*a')
          file:close()
          vim.fn.setreg('+', content)
          print('Copied: ' .. selection.value)
        end
      end)

      return true
    end,
  })
end, { desc = 'Pick prompt and copy' })

-- APPEND PROMPT TO CLIPBOARD
-- Add a prompt to existing clipboard content
vim.keymap.set('n', '<leader>pa', function()
  local prompts_dir = vim.fn.expand('~/.copilot-prompts')

  if vim.fn.isdirectory(prompts_dir) == 0 then
    print('Prompts directory not found: ' .. prompts_dir)
    return
  end

  require('telescope.builtin').find_files({
    prompt_title = 'Append Prompt',
    cwd = prompts_dir,
    previewer = true,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        local filepath = prompts_dir .. '/' .. selection.value
        local file = io.open(filepath, 'r')
        if file then
          local content = file:read('*a')
          file:close()
          local existing = vim.fn.getreg('+')
          vim.fn.setreg('+', existing .. '\n\n' .. content)
          print('Appended: ' .. selection.value)
        end
      end)

      return true
    end,
  })
end, { desc = 'Append prompt to clipboard' })

-- EDIT PROMPTS
-- Opens a prompt file for editing
vim.keymap.set('n', '<leader>pe', function()
  local prompts_dir = vim.fn.expand('~/.copilot-prompts')

  if vim.fn.isdirectory(prompts_dir) == 0 then
    print('Prompts directory not found: ' .. prompts_dir)
    return
  end

  require('telescope.builtin').find_files({
    prompt_title = 'Edit Prompt',
    cwd = prompts_dir,
  })
end, { desc = 'Edit prompt' })

-- CREATE NEW PROMPT FROM CLIPBOARD
-- Save current clipboard content as a new prompt
vim.keymap.set('n', '<leader>pn', function()
  local prompts_dir = vim.fn.expand('~/.copilot-prompts')

  -- Create directory if it doesn't exist
  if vim.fn.isdirectory(prompts_dir) == 0 then
    vim.fn.mkdir(prompts_dir, 'p')
  end

  vim.ui.input({ prompt = 'Prompt name: ' }, function(name)
    if name and name ~= '' then
      local filepath = prompts_dir .. '/' .. name
      -- Add .md extension if no extension provided
      if not name:match('%.') then
        filepath = filepath .. '.md'
      end

      local content = vim.fn.getreg('+')
      local file = io.open(filepath, 'w')
      if file then
        file:write(content)
        file:close()
        print('Saved: ' .. filepath)
        vim.cmd('edit ' .. filepath)
      end
    end
  end)
end, { desc = 'New prompt from clipboard' })

--[[
================================================================================
  KEYBINDING PHILOSOPHY
================================================================================

  This config follows these principles:

  1. ONE KEY = ONE ACTION
     Each key combination does exactly one thing.
     No "smart" keys that do different things in different contexts.

  2. MNEMONICS
     Keybindings are designed to be memorable:
     - [d and ]d for prev/next Diagnostic
     - <leader>e for Error
     - <leader>q for Quickfix

  3. DISCOVERABILITY
     The which-key plugin shows available keys when you press <leader>
     Press <leader> and wait to see what's available!

  4. CONSISTENCY
     Similar actions use similar patterns:
     - [ and ] for prev/next navigation
     - g prefix for "go to" actions
     - <leader> for custom actions

================================================================================
--]]
