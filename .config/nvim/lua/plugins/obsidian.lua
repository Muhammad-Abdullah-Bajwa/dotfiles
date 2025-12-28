--------------------------------------------------------------------------------
-- OBSIDIAN.NVIM - First-class Obsidian Support
--------------------------------------------------------------------------------
--
-- This plugin brings Obsidian vault features to Neovim:
--   - Wiki-style [[links]] with completion
--   - Daily notes
--   - Note search and navigation
--   - Backlinks
--   - Follow links with Enter or gf
--
-- YOUR VAULT: ~/repos/ObVault
--
-- HOW IT WORKS:
-- 1. Opens files from your vault as normal markdown
-- 2. Adds Obsidian-specific features on top
-- 3. Integrates with nvim-cmp for [[link]] completion
-- 4. Links use Obsidian's wiki-link format
--
-- KEYMAPS (all start with <leader>v for Vault):
--   <leader>vn    Create new note
--   <leader>vd    Open today's daily note
--   <leader>vs    Search notes by title
--   <leader>vb    Show backlinks to current note
--

return {
  'epwalsh/obsidian.nvim',
  version = '*', -- Use latest stable release

  -- LAZY LOADING: Only load for markdown files in your vault
  -- This prevents obsidian.nvim from activating for non-vault markdown
  ft = 'markdown',

  -- DEPENDENCIES
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required Lua utilities
  },

  opts = {
    -- ==========================================================================
    -- WORKSPACES (Your Obsidian Vaults)
    -- ==========================================================================
    -- Each workspace points to an Obsidian vault
    -- You can have multiple vaults and switch between them

    workspaces = {
      {
        name = 'vault',
        path = '~/repos/ObVault',
      },
      -- Add more vaults here if needed:
      -- { name = "work", path = "~/work-vault" },
    },

    -- ==========================================================================
    -- DAILY NOTES
    -- ==========================================================================
    -- Configure where and how daily notes are created
    -- Access with <leader>vd

    daily_notes = {
      folder = 'Daily', -- Store in Daily/ subfolder
      date_format = '%Y-%m-%d', -- Format: 2024-01-15
      -- You can add a template later:
      -- template = 'daily.md',
    },

    -- ==========================================================================
    -- NOTE CREATION
    -- ==========================================================================
    -- Configure how new notes are created

    notes_subdir = 'notes', -- New notes go to notes/ subfolder

    -- How to generate note IDs (filenames)
    -- This creates readable filenames like "my-new-note.md"
    note_id_func = function(title)
      -- If a title is given, slugify it (lowercase, dashes for spaces)
      if title ~= nil then
        return title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
      else
        -- If no title, use timestamp
        return tostring(os.time())
      end
    end,

    -- ==========================================================================
    -- COMPLETION
    -- ==========================================================================
    -- Integrates with nvim-cmp for [[link]] autocompletion

    completion = {
      nvim_cmp = true, -- Enable nvim-cmp integration
      min_chars = 2, -- Start completing after 2 characters
    },

    -- ==========================================================================
    -- UI SETTINGS
    -- ==========================================================================

    ui = {
      enable = true, -- Enable concealing and highlights
      checkboxes = {
        -- Custom checkbox icons
        [' '] = { char = '☐', hl_group = 'ObsidianTodo' },
        ['x'] = { char = '✔', hl_group = 'ObsidianDone' },
        ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
        ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
      },
    },

    -- ==========================================================================
    -- LINK HANDLING
    -- ==========================================================================

    -- Use wiki links [[like this]] instead of markdown links [like](this.md)
    wiki_link_func = function(opts)
      if opts.label ~= opts.path then
        return string.format('[[%s|%s]]', opts.path, opts.label)
      else
        return string.format('[[%s]]', opts.path)
      end
    end,

    -- What happens when you follow a link to a non-existent note
    follow_url_func = function(url)
      -- Open external URLs in browser
      vim.fn.jobstart({ 'open', url })
    end,
  },

  -- ==========================================================================
  -- KEYMAPS
  -- ==========================================================================
  -- All Obsidian keymaps use <leader>v prefix (v for Vault)

  keys = {
    -- Create a new note
    -- Prompts for title and creates in notes/ subfolder
    {
      '<leader>vn',
      '<cmd>ObsidianNew<cr>',
      desc = 'Vault: New note',
    },

    -- Open today's daily note
    -- Creates it if it doesn't exist (in Daily/ folder)
    {
      '<leader>vd',
      '<cmd>ObsidianToday<cr>',
      desc = 'Vault: Daily note',
    },

    -- Search notes by title
    -- Uses fzf/telescope to find notes
    {
      '<leader>vs',
      '<cmd>ObsidianSearch<cr>',
      desc = 'Vault: Search notes',
    },

    -- Show backlinks to current note
    -- Lists all notes that link TO this note
    {
      '<leader>vb',
      '<cmd>ObsidianBacklinks<cr>',
      desc = 'Vault: Backlinks',
    },

    -- Follow link under cursor
    -- Works on [[wiki links]] and URLs
    {
      '<leader>vl',
      '<cmd>ObsidianFollowLink<cr>',
      desc = 'Vault: Follow link',
    },

    -- Quick switch between notes
    -- Fast note switching without full search
    {
      '<leader>vq',
      '<cmd>ObsidianQuickSwitch<cr>',
      desc = 'Vault: Quick switch',
    },
  },
}

--------------------------------------------------------------------------------
-- OBSIDIAN KEYBINDING REFERENCE
--------------------------------------------------------------------------------
--
--   <leader>vn    Create a new note (prompts for title)
--   <leader>vd    Open today's daily note
--   <leader>vs    Search notes by title/content
--   <leader>vb    Show backlinks to current note
--   <leader>vl    Follow link under cursor
--   <leader>vq    Quick switch between notes
--
--   BUILT-IN VIM KEYS (also work with obsidian.nvim):
--   gf            Follow link under cursor (Go to File)
--   <CR>          Follow link under cursor (in some contexts)
--
--------------------------------------------------------------------------------
-- WORKFLOW TIPS
--------------------------------------------------------------------------------
--
--   1. DAILY NOTES
--      Start each day with <leader>vd to open your daily note.
--      Great for journaling, task lists, or meeting notes.
--
--   2. LINKING NOTES
--      Type [[ to start a link, then the note name.
--      Completion will suggest existing notes.
--      If the note doesn't exist, following the link creates it.
--
--   3. BACKLINKS
--      Use <leader>vb to see what links TO the current note.
--      Great for discovering connections in your knowledge base.
--
--   4. QUICK CAPTURE
--      Use <leader>vn to quickly create a new note.
--      The note is saved in your vault's notes/ folder.
--
