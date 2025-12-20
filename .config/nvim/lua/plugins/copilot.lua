--[[
================================================================================
  GITHUB COPILOT - AI CODE ASSISTANT
================================================================================

  GitHub Copilot is an AI pair programmer that suggests code as you type.
  It uses OpenAI's Codex model trained on billions of lines of code.

  HOW IT WORKS:
  1. As you type, Copilot analyzes context (current file, open tabs, etc.)
  2. It generates suggestions shown as "ghost text" (dimmed text)
  3. You can accept, reject, or cycle through suggestions
  4. Accepted code is inserted at your cursor

  REQUIREMENTS:
  - GitHub Copilot subscription (free for students/open source)
  - Run :Copilot auth to sign in on first use

  KEYBINDINGS (set below):
  - Ctrl+y: Accept suggestion (vim tradition for "yes")
  - Alt+]: Next suggestion
  - Alt+[: Previous suggestion
  - Ctrl+\: Dismiss suggestion

  WHY NOT TAB?
  Tab is disabled for Copilot because:
  1. Tab is for indentation
  2. Tab could conflict with completion
  3. Explicit Ctrl+y is clearer about intent

--]]

return {
  'github/copilot.vim',

  -- CONFIG: Custom setup function
  -- copilot.vim is a Vimscript plugin, so we use vim.keymap for mappings
  config = function()
    -- ==========================================================================
    -- KEYMAPS
    -- ==========================================================================
    -- These control how you interact with Copilot suggestions

    -- ACCEPT: Insert the current suggestion
    -- Ctrl+y is the traditional vim key for "yes, accept"
    vim.keymap.set('i', '<C-y>', 'copilot#Accept("<CR>")', {
      expr = true,           -- The right side is an expression to evaluate
      replace_keycodes = false,  -- Don't interpret special keys
      desc = 'Accept Copilot suggestion',
    })

    -- NEXT: Cycle to the next suggestion
    -- Copilot often has multiple suggestions; this shows the next one
    vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)', {
      desc = 'Next Copilot suggestion',
    })

    -- PREVIOUS: Cycle to the previous suggestion
    vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)', {
      desc = 'Previous Copilot suggestion',
    })

    -- DISMISS: Clear the current suggestion
    -- Useful when the suggestion is distracting and you want to type freely
    vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-dismiss)', {
      desc = 'Dismiss Copilot suggestion',
    })
  end,
}

--[[
================================================================================
  GETTING STARTED WITH COPILOT
================================================================================

  FIRST TIME SETUP:
  1. Install the plugin (happens automatically with lazy.nvim)
  2. Run :Copilot auth
  3. Follow the prompts to sign in with GitHub
  4. Start coding! Suggestions appear automatically.

  USEFUL COMMANDS:
  :Copilot status    -- Check if Copilot is running
  :Copilot enable    -- Enable Copilot
  :Copilot disable   -- Disable Copilot
  :Copilot panel     -- Open panel with multiple suggestions
  :Copilot auth      -- Re-authenticate with GitHub

================================================================================
  TIPS FOR BETTER SUGGESTIONS
================================================================================

  1. WRITE COMMENTS FIRST
     Describe what you want in a comment, then let Copilot generate code.
     // Function to validate email address
     <Copilot suggests the function>

  2. USE DESCRIPTIVE NAMES
     Better variable/function names = better suggestions.
     userEmailAddress is better than x

  3. PROVIDE CONTEXT
     Open related files. Copilot uses open tabs for context.

  4. START FUNCTIONS WITH SIGNATURES
     Type the function signature, Copilot suggests the body.
     fn calculate_total(items: &[Item]) -> f64 {
     <Copilot suggests implementation>

  5. ITERATE
     If the first suggestion isn't right, try Ctrl+] for alternatives.

================================================================================
  COPILOT ALTERNATIVES
================================================================================

  If you want to try other AI assistants:

  - copilot.lua + copilot-cmp: Copilot as a completion source (integrates with cmp)
  - codeium.nvim: Free alternative to Copilot
  - cmp-tabnine: TabNine completions
  - ChatGPT.nvim: Chat with GPT in a split window

================================================================================
--]]
