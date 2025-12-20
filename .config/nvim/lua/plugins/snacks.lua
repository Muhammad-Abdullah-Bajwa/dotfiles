--[[
================================================================================
  SNACKS.NVIM - COLLECTION OF QOL PLUGINS
================================================================================

  Snacks is a collection of QoL plugins by folke that includes:
  - Notifier: Beautiful notifications (replaces noice/nvim-notify)
  - Dashboard: Startup screen (replaces alpha.nvim)
  - Statuscolumn: Enhanced status column with git signs and folds
  - Toggle: Toggle keymaps for various options
  - And many more utilities

  FEATURES:
  - Beautiful notification popups
  - Fancy dashboard with ASCII art
  - LSP progress indicators
  - Message routing and filtering

  COMMANDS:
  - :Snacks dashboard      - Show dashboard
  - :Snacks notifier       - Show notification history
  - :Snacks git blame_line - Show git blame for current line
  - :Snacks lazygit        - Open lazygit

--]]

return {
  'folke/snacks.nvim',

  priority = 1000,
  lazy = false,

  opts = {
    -- Enable/disable features
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true },
      },
    },

    -- ==========================================================================
    -- DASHBOARD CONFIGURATION (replaces alpha.nvim)
    -- ==========================================================================
    dashboard = {
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },

      -- ASCII ART HEADER
      preset = {
        header = [[
                             __
                   _ ,___,-'",-=-.
       __,-- _ _,-'_)_  (""`'-._\ `.
    _,'  __ |,' ,-' __)  ,-     /. |
  ,'_,--'   |     -'  _)/         `\
,','      ,'       ,-'_,`           :
,'     ,-'       ,(,-(              :
     ,'       ,-' ,    _            ;
    /        ,-._/`---'            /
   /        (____)(----. )       ,'
  /         (      `.__,     /\ /,
 :           ;-.___         /__\/|
 |         ,'      `--.      -,\ |
 :        /            \    .__/
  \      (__            \    |_
   \       ,`-, *       /   _|,\
    \    ,'   `-.     ,'_,-'    \
   (_\,-'    ,'\")--,'-'       __\
    \       /  // ,'|      ,--'  `-.
     `-.    `-/ \'  |   _,'         `.
        `-._ /      `--'/             \
           ,'           |              \
          /             |               \
       ,-'              |               /
      /                 |             -'
]],
        -- QUICK ACTION KEYS
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
          { icon = " ", key = "e", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
          { icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
          { icon = " ", key = "c", desc = "Config", action = ":e $MYVIMRC" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },

    -- ==========================================================================
    -- NOTIFIER CONFIGURATION (replaces noice/nvim-notify)
    -- ==========================================================================
    notifier = {
      enabled = true,
      timeout = 5000,  -- 5 seconds auto-dismiss
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = "✎ ",
      },
      style = "compact",
    },

    -- ==========================================================================
    -- STATUSCOLUMN CONFIGURATION
    -- ==========================================================================
    statuscolumn = {
      left = { "mark", "sign" },
      right = { "fold", "git" },
      folds = {
        open = false,
        git_hl = false,
      },
      git = {
        patterns = { "GitSign", "MiniDiffSign" },
      },
    },

    -- ==========================================================================
    -- STYLES
    -- ==========================================================================
    styles = {
      notification = {
        wo = { wrap = true },
        border = "rounded",
      },
      notification_history = {
        border = "rounded",
      },
    },
  },

  keys = {
    -- NOTIFICATION KEYMAPS
    { "<leader>nd", function() Snacks.notifier.hide() end, desc = "[N]otifications [D]ismiss" },
    { "<leader>nh", function() Snacks.notifier.show_history() end, desc = "[N]otifications [H]istory" },

    -- DASHBOARD
    { "<leader>db", function() Snacks.dashboard() end, desc = "[D]ash[b]oard" },

    -- GIT UTILITIES
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "[G]it [B]lame Line" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "[G]it [B]rowse" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "[G]it [F]ile History" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "[G]it Lazy[g]it" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "[G]it [L]og" },

    -- TOGGLE UTILITIES
    { "<leader>tz", function() Snacks.zen() end, desc = "[T]oggle [Z]en Mode" },
    { "<leader>tZ", function() Snacks.zen.zoom() end, desc = "[T]oggle [Z]oom" },

    -- BUFFER UTILITIES
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "[B]uffer [D]elete" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "[B]uffer Delete [O]thers" },

    -- RENAME
    { "<leader>rn", function() Snacks.rename.rename_file() end, desc = "[R]e[n]ame File" },

    -- NOTIFICATION IN CMDLINE
    { "<leader>nl", function() Snacks.notifier.show_history() end, desc = "[N]otification [L]ast" },
  },

  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for convenience
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd

        -- Create autocmd for dashboard on startup
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
              require("snacks").dashboard.open()
            end
          end,
        })
      end,
    })
  end,
}
