--[[
================================================================================
  NOICE.NVIM - BETTER UI FOR MESSAGES, CMDLINE & POPUPMENU
================================================================================

  Noice replaces Neovim's UI for:
  - Messages (echo, print, errors, warnings)
  - Command line (:commands)
  - Popup menu (completion menu in cmdline)

  FEATURES:
  - Beautiful notification popups instead of the message area
  - Fancy cmdline with icons
  - LSP progress indicators
  - Message history with :Noice command

  COMMANDS:
  - :Noice           - Show message history
  - :Noice last      - Show last message in popup
  - :Noice dismiss   - Dismiss all visible messages
  - :Noice errors    - Show error messages

--]]

return {
  'folke/noice.nvim',

  -- Load after startup for better performance
  event = 'VeryLazy',

  -- DEPENDENCIES
  -- nui.nvim: Required for popup/split rendering
  -- nvim-notify: Optional but recommended for notifications
  dependencies = {
    'MunifTanjim/nui.nvim',
    'rcarriga/nvim-notify',
  },

  config = function()
    -- Configure nvim-notify first with 5 second timeout
    require('notify').setup({
      -- Messages auto-dismiss after 5 seconds (5000ms)
      timeout = 5000,

      -- Animation style
      stages = 'fade_in_slide_out',

      -- Don't show too many notifications at once
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,

      -- Position notifications in top-right
      top_down = true,
    })

    -- Now configure noice
    require('noice').setup({
      -- LSP OVERRIDES
      -- Use Treesitter for better rendering of LSP markdown
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },

      -- PRESETS
      -- Enable some nice default behaviors
      presets = {
        bottom_search = true,         -- Classic bottom cmdline for search
        command_palette = true,       -- Cmdline and popupmenu together
        long_message_to_split = true, -- Long messages go to split
        inc_rename = false,           -- No special input for inc-rename
        lsp_doc_border = true,        -- Add border to hover docs
      },

      -- ROUTES
      -- Custom routing rules for messages
      routes = {
        -- Skip "written" messages (e.g., "file.lua 50L, 1234B written")
        {
          filter = {
            event = 'msg_show',
            kind = '',
            find = 'written',
          },
          opts = { skip = true },
        },
        -- Skip search count messages in virtual text (less distracting)
        {
          filter = {
            event = 'msg_show',
            kind = 'search_count',
          },
          opts = { skip = true },
        },
      },

      -- VIEWS
      -- Customize how different message types appear
      views = {
        -- Mini view for LSP progress (bottom right)
        mini = {
          timeout = 5000,  -- 5 seconds
        },
      },

      -- NOTIFY SETTINGS
      notify = {
        enabled = true,
        view = 'notify',
      },

      -- MESSAGES SETTINGS
      messages = {
        enabled = true,
        view = 'notify',          -- Use notify for messages
        view_error = 'notify',    -- Errors as notifications
        view_warn = 'notify',     -- Warnings as notifications
        view_history = 'messages', -- :messages in split
        view_search = false,       -- Disable search count (can be noisy)
      },

      -- CMDLINE SETTINGS
      cmdline = {
        enabled = true,
        view = 'cmdline_popup',   -- Fancy popup cmdline
      },

      -- POPUPMENU
      popupmenu = {
        enabled = true,
        backend = 'nui',
      },
    })

    -- KEYMAPS
    -- Scroll in LSP hover/signature docs
    vim.keymap.set({ 'n', 'i', 's' }, '<C-f>', function()
      if not require('noice.lsp').scroll(4) then
        return '<C-f>'
      end
    end, { silent = true, expr = true, desc = 'Scroll forward in docs' })

    vim.keymap.set({ 'n', 'i', 's' }, '<C-b>', function()
      if not require('noice.lsp').scroll(-4) then
        return '<C-b>'
      end
    end, { silent = true, expr = true, desc = 'Scroll backward in docs' })

    -- Dismiss all notifications
    vim.keymap.set('n', '<leader>nd', function()
      require('noice').cmd('dismiss')
    end, { desc = '[N]oice [D]ismiss all' })

    -- Show message history
    vim.keymap.set('n', '<leader>nh', function()
      require('noice').cmd('history')
    end, { desc = '[N]oice [H]istory' })

    -- Show last message
    vim.keymap.set('n', '<leader>nl', function()
      require('noice').cmd('last')
    end, { desc = '[N]oice [L]ast message' })
  end,
}
