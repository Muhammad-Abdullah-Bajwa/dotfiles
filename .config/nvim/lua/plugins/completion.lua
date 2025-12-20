--[[
================================================================================
  AUTOCOMPLETION (NVIM-CMP)
================================================================================

  Autocompletion shows suggestions as you type and lets you insert them.
  
  HOW IT WORKS:
  1. You start typing
  2. Completion sources provide suggestions:
     - LSP (function names, variables, methods)
     - Snippets (code templates)
     - Buffer (words from current file)
     - Path (file paths)
  3. You navigate the menu and select a completion
  4. The text is inserted

  COMPLETION SOURCES (in priority order):
  1. nvim_lsp: Intelligent completions from language servers
  2. luasnip: Snippet completions (templates you can expand)
  3. buffer: Words from the current buffer
  4. path: File system paths

  SNIPPETS:
  Snippets are templates that expand into larger code structures.
  Example: Type "fn" and expand to a full function definition.
  We use LuaSnip as the snippet engine.

--]]

return {
  'hrsh7th/nvim-cmp',

  -- EVENT: Only load when entering insert mode
  -- Completion isn't needed until you start typing
  event = 'InsertEnter',

  -- DEPENDENCIES: Completion sources and snippet engine
  dependencies = {
    -- LUASNIP: Snippet engine
    -- Handles expanding and navigating snippets
    {
      'L3MON4D3/LuaSnip',
      build = 'make install_jsregexp',  -- Optional: enables JS regex support
    },

    -- COMPLETION SOURCES:
    'saadparwaiz1/cmp_luasnip',   -- Snippet completions
    'hrsh7th/cmp-nvim-lsp',       -- LSP completions
    'hrsh7th/cmp-path',           -- File path completions
    'hrsh7th/cmp-buffer',         -- Buffer word completions
  },

  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    -- Initialize LuaSnip with default settings
    luasnip.config.setup({})

    -- ==========================================================================
    -- CMP SETUP
    -- ==========================================================================
    cmp.setup({
      -- SNIPPET: How to expand snippets
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      -- COMPLETION OPTIONS
      completion = {
        -- completeopt controls completion menu behavior
        -- menu: show completion menu
        -- menuone: show menu even with one item
        -- noinsert: don't insert until explicitly selected
        completeopt = 'menu,menuone,noinsert',
      },

      -- ========================================================================
      -- KEYBINDINGS
      -- ========================================================================
      -- These are the keys you use to interact with the completion menu.
      -- The philosophy here is: ONE KEY = ONE ACTION (no "smart" keys)

      mapping = cmp.mapping.preset.insert({
        -- NAVIGATE the completion menu
        -- Ctrl+n = next item (down)
        -- Ctrl+p = previous item (up)
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- SCROLL documentation preview
        -- Ctrl+b = back (up)
        -- Ctrl+f = forward (down)
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- CONFIRM selection
        -- Enter = insert the selected completion
        -- select = true means auto-select first item if none selected
        ['<CR>'] = cmp.mapping.confirm({ select = true }),

        -- MANUALLY TRIGGER completion menu
        -- Ctrl+Space = open completion menu
        -- Useful when completion doesn't auto-show
        ['<C-Space>'] = cmp.mapping.complete(),

        -- SNIPPET NAVIGATION
        -- After expanding a snippet, jump between placeholders
        -- Ctrl+l = jump to next placeholder
        -- Ctrl+h = jump to previous placeholder
        --
        -- Example snippet: function ${1:name}(${2:params}) ${3:body} end
        -- After expanding, Ctrl+l moves: name -> params -> body
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),  -- Works in insert and select modes

        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
      }),

      -- ========================================================================
      -- COMPLETION SOURCES
      -- ========================================================================
      -- Order matters! First source has highest priority.
      -- If LSP provides completions, they'll appear first.

      sources = {
        {
          name = 'nvim_lsp',  -- Completions from language servers
          -- This is the most intelligent source
        },
        {
          name = 'luasnip',   -- Snippet completions
          -- Code templates you can expand
        },
        {
          name = 'buffer',    -- Words from current buffer
          -- Useful for variable names you've already typed
        },
        {
          name = 'path',      -- File system paths
          -- Start typing a path and it auto-completes
        },
      },
    })
  end,
}

--[[
================================================================================
  COMPLETION KEYBINDING SUMMARY
================================================================================

  IN THE COMPLETION MENU:
    <C-n>         Next item (down)
    <C-p>         Previous item (up)
    <CR>          Confirm/insert selection
    <C-Space>     Manually trigger completion
    <C-b>/<C-f>   Scroll documentation

  IN SNIPPETS:
    <C-l>         Jump to next placeholder
    <C-h>         Jump to previous placeholder

  WHY NOT TAB?
  Tab is intentionally NOT used for completion because:
  1. Tab is used for indentation
  2. Tab is used by Copilot for accepting suggestions
  3. Having one key do multiple things is confusing
  
  Instead, we use explicit keys:
  - Ctrl+n/p for navigation (like shell history)
  - Enter to confirm (natural choice)
  - Ctrl+y for Copilot (vim tradition for "yes")

================================================================================
  HOW COMPLETION WORKS
================================================================================

  1. AUTO-TRIGGER
     As you type, cmp automatically shows completions.
     You don't need to press any key to start.

  2. FUZZY MATCHING
     Type "fn" to match "function", "findName", etc.
     You don't need exact prefixes.

  3. SORTING
     Results are sorted by:
     - Source priority (LSP > snippets > buffer)
     - Match quality (exact > fuzzy)
     - Alphabetically

  4. DOCUMENTATION
     When you highlight an item, docs appear in a preview window.
     Use Ctrl+f/b to scroll if docs are long.

================================================================================
--]]
