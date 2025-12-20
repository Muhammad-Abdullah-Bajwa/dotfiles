--[[
================================================================================
  EDITOR PLUGINS - TREESITTER, CONTEXT, COMMENTS, AUTOPAIRS, SLEUTH
================================================================================

  These plugins enhance the core editing experience:

  1. TREESITTER
     Provides advanced syntax highlighting and code understanding.
     Unlike regex-based highlighting, Treesitter actually PARSES your code.

  2. TREESITTER-CONTEXT
     Shows the current function/class at the top of the screen.
     Never lose track of where you are in long files!

  3. COMMENT.NVIM
     Easy code commenting with gcc (line) and gc (selection).

  4. NVIM-AUTOPAIRS
     Automatically closes brackets, quotes, etc.
     Type ( and get () with cursor in the middle.

  5. VIM-SLEUTH
     Automatically detects indent settings (tabs vs spaces, width).

--]]

return {
  -- ==========================================================================
  -- TREESITTER
  -- ==========================================================================
  -- Treesitter is a parser generator tool and incremental parsing library.
  -- In simpler terms: it understands your code's structure, not just patterns.
  --
  -- BENEFITS:
  -- - More accurate syntax highlighting (understands context)
  -- - Better indentation (knows code structure)
  -- - Enables other features: text objects, folding, etc.
  --
  -- HOW IT WORKS:
  -- 1. Each language has a "parser" (grammar rules)
  -- 2. Treesitter parses your code into a syntax tree
  -- 3. Plugins can query this tree for highlighting, navigation, etc.
  {
    'nvim-treesitter/nvim-treesitter',

    -- BUILD: Command to run after installing/updating
    -- ':TSUpdate' updates all installed parsers to latest versions
    build = ':TSUpdate',

    config = function()
      -- List of parsers to install
      local parsers = {
        'bash',
        'c',
        'cpp',
        'c_sharp',
        'rust',
        'lua',
        'luadoc',
        'markdown',
        'vim',
        'vimdoc',
        'toml',
        'json',
        'yaml',
        'python',
      }

      -- Configure Treesitter (minimal setup, new API doesn't use setup)
      -- The new nvim-treesitter API is much simpler and doesn't need setup()
      -- Just install parsers and they work automatically

      -- Install parsers on first run (this runs once when config loads)
      vim.schedule(function()
        require('nvim-treesitter').install(parsers)
      end)

      -- Auto-install missing parsers when opening a file
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local parser = vim.treesitter.language.get_lang(args.match)
          if parser and not vim.treesitter.query.get(parser, 'highlights') then
            vim.schedule(function()
              vim.cmd('TSInstall! ' .. parser)
            end)
          end
        end,
      })

      -- USEFUL TREESITTER COMMANDS:
      -- :TSInstall {language}   -- Install a parser
      -- :TSUpdate               -- Update all parsers
      -- :TSInstallInfo          -- Show installed parsers
      -- :InspectTree            -- Show syntax tree for current buffer
    end,
  },

  -- ==========================================================================
  -- TREESITTER-CONTEXT
  -- ==========================================================================
  -- Shows the current function/class at the top of the screen.
  -- 
  -- WHY THIS IS USEFUL:
  -- In long files, you scroll down and lose track of what function you're in.
  -- This plugin "pins" the function signature at the top so you always know.
  --
  -- EXAMPLE:
  -- You're on line 500 of a long function, the screen shows:
  -- ┌─────────────────────────────────────────────────────┐
  -- │ function processData(items, options) {  <- PINNED  │
  -- ├─────────────────────────────────────────────────────┤
  -- │     // ... line 500 of the function                │
  -- │     if (items.length > 100) {                      │
  -- │         ...                                        │
  -- └─────────────────────────────────────────────────────┘
  --
  -- Now you can always see you're inside processData()!
  {
    'nvim-treesitter/nvim-treesitter-context',

    -- EVENT: Load when opening any file
    event = 'BufReadPost',

    opts = {
      -- MAX_LINES: Maximum number of context lines to show
      -- 3 is enough to see function + maybe a class, but not overwhelming
      max_lines = 3,

      -- MIN_WINDOW_HEIGHT: Only show context if window is at least this tall
      -- Prevents context from taking up too much space in small windows
      min_window_height = 20,

      -- MODE: How to determine context ('cursor' or 'topline')
      -- 'cursor' shows context for the line the cursor is on
      mode = 'cursor',

      -- TRIM_SCOPE: What to trim if line is too long
      -- 'inner' trims the inside, keeping start/end visible
      trim_scope = 'outer',
    },

    -- COMMANDS:
    -- :TSContextToggle  = Turn context on/off
    -- :TSContextEnable  = Turn on
    -- :TSContextDisable = Turn off
  },

  -- ==========================================================================
  -- COMMENT.NVIM
  -- ==========================================================================
  -- Makes commenting code effortless.
  --
  -- USAGE:
  --   gcc         -- Toggle comment on current line
  --   gc{motion}  -- Toggle comment with motion (e.g., gcap = comment paragraph)
  --   gc          -- Toggle comment on selection (visual mode)
  --   gbc         -- Toggle block comment on current line
  --
  -- EXAMPLES:
  --   gcc on "let x = 1" becomes "// let x = 1" (JS) or "-- let x = 1" (Lua)
  --   Select 3 lines, press gc to comment them all
  --   gcap to comment the entire paragraph/block
  {
    'numToStr/Comment.nvim',

    -- OPTS: Empty table means use all default settings
    -- Comment.nvim auto-detects the comment string for each language
    opts = {},
  },

  -- ==========================================================================
  -- AUTOPAIRS
  -- ==========================================================================
  -- Automatically inserts closing pairs:
  --   ( → ()     [ → []     { → {}
  --   " → ""     ' → ''     ` → ``
  --
  -- SMART FEATURES:
  -- - Won't add closing pair if one already exists
  -- - Pressing ) when already on ) will skip over it
  -- - Pressing Backspace on () deletes both
  -- - Works correctly with treesitter (won't pair inside strings/comments)
  {
    'windwp/nvim-autopairs',

    -- EVENT: Only load when entering insert mode (when you start typing)
    -- This is "lazy loading" - plugin isn't loaded until needed
    event = 'InsertEnter',

    -- CONFIG = TRUE: Just call setup() with default settings
    -- Shorthand for config = function() require('nvim-autopairs').setup({}) end
    config = true,
  },

  -- ==========================================================================
  -- VIM-SLEUTH
  -- ==========================================================================
  -- Automatically detects indent settings by examining existing files.
  --
  -- WHY THIS IS USEFUL:
  -- Different projects use different indentation:
  --   - Some use 2 spaces
  --   - Some use 4 spaces
  --   - Some use tabs
  --
  -- vim-sleuth looks at existing files in the project and sets:
  --   - 'tabstop' - how wide tabs appear
  --   - 'shiftwidth' - how much to indent
  --   - 'expandtab' - use spaces or actual tabs
  --
  -- This means you don't have to manually configure indent per project!
  {
    'tpope/vim-sleuth',

    -- No configuration needed - it just works automatically
  },
}

--[[
================================================================================
  TEXT OBJECTS QUICK REFERENCE
================================================================================

  Text objects let you operate on meaningful chunks of code.
  Format: {operator}{a/i}{object}

  OPERATORS:
    d = delete    y = yank (copy)    c = change    v = visual select

  MODIFIERS:
    i = "inner" (inside, excluding delimiters)
    a = "around" (including delimiters)

  BUILT-IN OBJECTS:
    w   = word           W   = WORD (space-delimited)
    s   = sentence       p   = paragraph
    (   = parentheses    )   = same as (
    [   = brackets       ]   = same as [
    {   = braces         }   = same as {
    <   = angle brackets >   = same as <
    "   = double quotes  '   = single quotes
    `   = backticks      t   = HTML/XML tag

  EXAMPLES:
    diw   = delete inner word (just the word)
    daw   = delete around word (word + surrounding space)
    ci"   = change inside quotes (clear and type new text)
    ca(   = change around parentheses (including the parens)
    yip   = yank inner paragraph
    vit   = select inner tag content

  MINI.AI ADDITIONS (from mini.ai plugin):
    f   = function call
    a   = argument
    q   = quote (any kind)
    b   = bracket (any kind)

================================================================================
--]]
