--[[
================================================================================
  LSP - LANGUAGE SERVER PROTOCOL
================================================================================

  LSP is what gives Neovim IDE-like features:
    - Go to definition
    - Find references
    - Auto-completion (via nvim-cmp)
    - Error checking (diagnostics)
    - Code actions (quick fixes)
    - Rename symbols
    - Hover documentation
    - And more!

  HOW IT WORKS:
  1. A "Language Server" runs in the background (one per language)
  2. It analyzes your code and provides intelligence
  3. Neovim communicates with it using the LSP protocol
  4. You get IDE features without a bloated IDE!

  COMPONENTS IN THIS CONFIG:
  - nvim-lspconfig: Configuration for various language servers
  - mason.nvim: Installer for language servers (like an app store)
  - mason-lspconfig.nvim: Bridge between mason and lspconfig
  - fidget.nvim: Shows LSP progress in the corner

  CONFIGURED LANGUAGE SERVERS:
  - clangd: C/C++
  - rust_analyzer: Rust
  - omnisharp: C#
  - lua_ls: Lua (for Neovim config)

--]]

return {
  'neovim/nvim-lspconfig',

  -- DEPENDENCIES: Other plugins needed for full LSP experience
  dependencies = {
    -- Mason: Package manager for LSP servers, formatters, linters
    -- Run :Mason to see available tools
    'williamboman/mason.nvim',

    -- Bridge between mason and lspconfig
    -- Ensures servers installed by Mason work with lspconfig
    'williamboman/mason-lspconfig.nvim',

    -- Auto-install tools listed in ensure_installed
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Fidget: Shows LSP progress messages in bottom right
    -- "Indexing workspace..." "Checking file..." etc.
    { 'j-hui/fidget.nvim', opts = {} },
  },

  config = function()
    -- ==========================================================================
    -- LSP ATTACH AUTOCMD
    -- ==========================================================================
    -- This runs every time a language server attaches to a buffer.
    -- We use it to set up buffer-local keymaps and options.

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        -- Helper function to create buffer-local keymaps
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, {
            buffer = event.buf,
            desc = 'LSP: ' .. desc,
          })
        end

        -- ======================================================================
        -- NAVIGATION KEYMAPS
        -- ======================================================================
        -- These help you navigate around your code

        -- Go to where a function/variable is DEFINED
        -- This is probably the most-used LSP feature!
        map('gd', require('fzf-lua').lsp_definitions, '[G]oto [D]efinition')

        -- Find all REFERENCES to the symbol under cursor
        -- Shows everywhere a function/variable is used
        map('gr', require('fzf-lua').lsp_references, '[G]oto [R]eferences')

        -- Go to IMPLEMENTATION (useful for interfaces/abstract classes)
        -- In C++: Go to the .cpp file from a .h declaration
        map('gI', require('fzf-lua').lsp_implementations, '[G]oto [I]mplementation')

        -- Go to DECLARATION (often same as definition)
        -- In C/C++: Goes to forward declaration in header
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Go to TYPE definition
        -- On a variable, jump to its type's definition
        map('<leader>D', require('fzf-lua').lsp_typedefs, 'Type [D]efinition')

        -- ======================================================================
        -- SYMBOL SEARCH
        -- ======================================================================
        -- Find symbols (functions, classes, variables) by name

        -- Search symbols in current FILE
        map('<leader>ds', require('fzf-lua').lsp_document_symbols, '[D]ocument [S]ymbols')

        -- Search symbols in entire WORKSPACE
        map('<leader>ws', require('fzf-lua').lsp_live_workspace_symbols, '[W]orkspace [S]ymbols')

        -- ======================================================================
        -- CODE ACTIONS
        -- ======================================================================
        -- Actions you can take on your code

        -- RENAME symbol under cursor (updates all references!)
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- CODE ACTIONS: Quick fixes, refactorings, etc.
        -- Examples: Add import, extract function, fix typo
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        -- HOVER: Show documentation for symbol under cursor
        -- This is incredibly useful! Press K on anything to learn about it
        map('K', vim.lsp.buf.hover, 'Hover Documentation')

        -- FORMAT: Format the current buffer using LSP
        -- Works with any LSP that supports formatting (rust-analyzer, clangd, lua_ls, etc.)
        map('<leader>cf', function()
          vim.lsp.buf.format({ async = true })
        end, '[C]ode [F]ormat')

        -- ======================================================================
        -- HIGHLIGHT REFERENCES
        -- ======================================================================
        -- When cursor sits on a symbol, highlight other occurrences

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

          -- Highlight references when cursor holds on a symbol
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          -- Clear highlights when cursor moves
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          -- Clean up when LSP detaches
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
            end,
          })
        end

        -- ======================================================================
        -- INLAY HINTS
        -- ======================================================================
        -- Show inline hints (types, parameter names)
        -- Example: function(x: int, y: int) shows types inline

        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- ==========================================================================
    -- LSP CAPABILITIES
    -- ==========================================================================
    -- Tell language servers what features our editor supports
    -- nvim-cmp adds additional capabilities for completion

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend(
      'force',
      capabilities,
      require('cmp_nvim_lsp').default_capabilities()
    )

    -- ==========================================================================
    -- LANGUAGE SERVER CONFIGURATIONS
    -- ==========================================================================
    -- Each key is a server name, value is the server's configuration

    local servers = {
      -- C/C++ - clangd
      -- Provides: completion, diagnostics, go-to-definition, etc.
      -- Requires: clang/LLVM installed on system
      clangd = {},

      -- Rust - rust_analyzer
      -- Provides: excellent Rust support, cargo integration
      -- Requires: rustup (rust toolchain)
      rust_analyzer = {},

      -- C# - omnisharp
      -- Provides: .NET/C# support
      -- Requires: .NET SDK
      omnisharp = {},

      -- Lua - lua_ls (lua-language-server)
      -- Provides: Lua support, especially for Neovim config
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',  -- Better snippet expansion
            },
            diagnostics = {
              globals = { 'vim' },  -- Don't warn about 'vim' global
            },
            -- You can add more settings here:
            -- workspace = { library = vim.api.nvim_get_runtime_file('', true) },
            -- telemetry = { enable = false },
          },
        },
      },
    }

    -- ==========================================================================
    -- MASON SETUP
    -- ==========================================================================
    -- Mason is a package manager for LSP servers, formatters, and linters
    -- Run :Mason to open the UI and install/manage tools

    require('mason').setup()

    -- List of tools to automatically install
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua',  -- Lua formatter
      -- Add more tools here:
      -- 'clang-format',  -- C/C++ formatter
      -- 'rustfmt',       -- Rust formatter (usually comes with rustup)
    })

    require('mason-tool-installer').setup({
      ensure_installed = ensure_installed,
    })

    -- ==========================================================================
    -- CONNECT MASON TO LSPCONFIG
    -- ==========================================================================
    -- This makes servers installed by Mason work with lspconfig

    require('mason-lspconfig').setup({
      handlers = {
        -- Default handler: called for each installed server
        function(server_name)
          local server = servers[server_name] or {}

          -- Merge our capabilities with any server-specific capabilities
          server.capabilities = vim.tbl_deep_extend(
            'force',
            {},
            capabilities,
            server.capabilities or {}
          )

          -- Set up the server with lspconfig
          require('lspconfig')[server_name].setup(server)
        end,
      },
    })
  end,
}

--[[
================================================================================
  LSP KEYBINDING REFERENCE
================================================================================

  NAVIGATION:
    gd            Go to definition
    gr            Find all references
    gI            Go to implementation
    gD            Go to declaration
    <leader>D     Go to type definition

  SYMBOLS:
    <leader>ds    Document symbols (current file)
    <leader>ws    Workspace symbols (entire project)

  ACTIONS:
    K             Hover documentation
    <leader>ca    Code actions (quick fixes)
    <leader>cf    Format buffer via LSP
    <leader>rn    Rename symbol

  TOGGLES:
    <leader>th    Toggle inlay hints

================================================================================
  TROUBLESHOOTING
================================================================================

  LSP not working? Try these commands:

  :LspInfo          -- Show attached LSP clients for current buffer
  :LspLog           -- View LSP log file
  :Mason            -- Check if server is installed
  :checkhealth lsp  -- Run health check

  Common issues:
  1. Server not installed -> Run :Mason and install it
  2. Server not starting -> Check :LspLog for errors
  3. Server not attaching -> Check if file type is correct
  4. No completions -> Make sure nvim-cmp is configured

================================================================================
--]]
