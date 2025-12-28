--[[
================================================================================
  FZF-LUA - BLAZING FAST FUZZY FINDER
================================================================================

  fzf-lua is a faster alternative to Telescope with the same features.
  It provides fuzzy finding for:
    - Files in your project
    - Text in your project (grep)
    - Buffers (open files)
    - Help documentation
    - Keymaps
    - LSP symbols
    - And much more!

  WHY FZF-LUA OVER TELESCOPE?
  - 2-3x faster, especially on large projects
  - Lower memory footprint
  - Native fzf speed (written in Lua but uses fzf algorithm)
  - Full LSP integration
  - Same features, better performance

  DEPENDENCIES:
  - fzf: The fuzzy finder binary (optional but recommended)
  - ripgrep (rg): For fast text searching
  - fd: For fast file finding (optional)
  - bat: For syntax-highlighted previews (optional)

--]]

return {
  'ibhagwan/fzf-lua',

  -- EVENT: Load on VimEnter (after startup)
  event = 'VimEnter',

  -- DEPENDENCIES
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' }, -- File type icons
  },

  config = function()
    -- ==========================================================================
    -- FZF-LUA SETUP
    -- ==========================================================================
    local fzf = require('fzf-lua')

    fzf.setup({
      -- Use a preset configuration that's similar to Telescope
      -- Options: 'default', 'fzf-native', 'fzf-vim', 'max-perf', 'telescope'
      'telescope',

      -- WINOPTS: Window and preview options
      winopts = {
        -- HEIGHT/WIDTH: Picker size
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,

        -- PREVIEW: Preview window configuration
        preview = {
          -- Default previewer (bat for syntax highlighting)
          default = 'bat',
          border = 'border',
          wrap = 'nowrap',
          hidden = 'nohidden',
          vertical = 'down:45%',
          horizontal = 'right:50%',
          layout = 'flex',
          flip_columns = 120,

          -- Scrollbar
          scrollbar = 'float',
          scrolloff = '-2',
          scrollchars = { '█', '' },
        },
      },

      -- KEYMAP: Custom keybindings inside fzf-lua
      keymap = {
        builtin = {
          ['<C-/>'] = 'toggle-help',
          ['<C-d>'] = 'preview-page-down',
          ['<C-u>'] = 'preview-page-up',
        },
        fzf = {
          ['ctrl-q'] = 'select-all+accept',
        },
      },

      -- FILES: File finder options
      files = {
        -- Use fd if available, otherwise find
        cmd = 'fd --type f --hidden --follow --exclude .git',
        prompt = 'Files❯ ',
        multiprocess = true,        -- Use multiple processes for speed
        file_icons = true,
        color_icons = true,
        git_icons = true,
      },

      -- GREP: Text search options
      grep = {
        prompt = 'Grep❯ ',
        input_prompt = 'Grep For❯ ',
        multiprocess = true,
        file_icons = true,
        color_icons = true,
        git_icons = true,
        -- Use ripgrep with some useful flags
        rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e',
      },

      -- LSP: LSP picker options
      lsp = {
        prompt = 'LSP❯ ',
        file_icons = true,
        color_icons = true,
        git_icons = false,
        symbols = {
          symbol_style = 1,        -- 1: icon+kind, 2: icon only, 3: kind only
        },
      },
    })

    -- ==========================================================================
    -- KEYMAPS
    -- ==========================================================================
    -- All search keymaps start with <leader>s for consistency

    -- HELP & DISCOVERY
    vim.keymap.set('n', '<leader>sh', fzf.helptags, {
      desc = '[S]earch [H]elp',
    })
    vim.keymap.set('n', '<leader>sk', fzf.keymaps, {
      desc = '[S]earch [K]eymaps',
    })

    -- FILE FINDING
    vim.keymap.set('n', '<leader>sf', fzf.files, {
      desc = '[S]earch [F]iles',
    })

    -- TEXT SEARCH (GREP)
    vim.keymap.set('n', '<leader>sg', fzf.live_grep, {
      desc = '[S]earch by [G]rep',
    })
    vim.keymap.set('n', '<leader>sw', fzf.grep_cword, {
      desc = '[S]earch current [W]ord',
    })

    -- NEOVIM INTERNALS
    vim.keymap.set('n', '<leader>ss', fzf.builtin, {
      desc = '[S]earch [S]elect fzf-lua picker',
    })
    vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, {
      desc = '[S]earch [D]iagnostics',
    })

    -- RESUME & RECENT
    vim.keymap.set('n', '<leader>sr', fzf.resume, {
      desc = '[S]earch [R]esume (last picker)',
    })
    vim.keymap.set('n', '<leader>s.', fzf.oldfiles, {
      desc = '[S]earch Recent Files ("." = repeat)',
    })

    -- BUFFERS
    vim.keymap.set('n', '<leader><leader>', fzf.buffers, {
      desc = '[ ] Find existing buffers',
    })

    -- CURRENT BUFFER SEARCH
    vim.keymap.set('n', '<leader>/', fzf.blines, {
      desc = '[/] Fuzzy search in current buffer',
    })

    -- GREP IN OPEN FILES
    vim.keymap.set('n', '<leader>s/', function()
      fzf.grep({
        search = '',
        prompt = 'Live Grep in Open Files❯ ',
        fzf_opts = { ['--filter-prompt'] = 'Grep❯ ' },
      })
    end, {
      desc = '[S]earch [/] in Open Files',
    })

    -- NEOVIM CONFIG FILES
    vim.keymap.set('n', '<leader>sn', function()
      fzf.files({ cwd = vim.fn.stdpath('config') })
    end, {
      desc = '[S]earch [N]eovim config files',
    })

    -- GIT FILES (faster than regular files in git repos)
    vim.keymap.set('n', '<leader>gf', function()
      fzf.git_files()
    end, {
      desc = '[G]it [F]iles',
    })

    -- COMMANDS (bonus feature)
    vim.keymap.set('n', '<leader>sc', fzf.commands, {
      desc = '[S]earch [C]ommands',
    })

    -- SPELL SUGGESTIONS (fuzzy picker for z=)
    -- More visual alternative to built-in z= spell suggestions
    -- Only useful when spell checking is enabled (markdown files)
    vim.keymap.set('n', '<leader>zs', fzf.spell_suggest, {
      desc = '[Z] [S]pell suggestions',
    })
  end,
}

--[[
================================================================================
  FZF-LUA USAGE TIPS
================================================================================

  INSIDE FZF-LUA (when picker is open):

  Navigation:
    <C-n>/<C-j>  -- Next item
    <C-p>/<C-k>  -- Previous item
    <C-u>        -- Scroll preview up
    <C-d>        -- Scroll preview down

  Actions:
    <CR>         -- Open selected item
    <C-x>        -- Open in horizontal split
    <C-v>        -- Open in vertical split
    <C-t>        -- Open in new tab
    <Esc>        -- Close picker

  Multi-select:
    <Tab>        -- Toggle selection and move to next
    <S-Tab>      -- Toggle selection and move to prev
    <C-q>        -- Send all selected to quickfix

  GREP TIPS:
    - fzf-lua uses ripgrep for blazing fast text search
    - <leader>sw searches for exact word under cursor
    - All searches support regex patterns
    - Use -- to pass flags to ripgrep

  PERFORMANCE TIPS:
    - fzf-lua is already optimized, no extra config needed
    - Uses native fzf algorithm for maximum speed
    - Multiprocessing enabled by default
    - Async operations don't block editor

================================================================================
--]]
