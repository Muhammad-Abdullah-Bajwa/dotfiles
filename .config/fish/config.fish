# Optimized fish configuration
# Fish is already fast by default, but we can still optimize tool initialization

# Disable fish greeting
set -g fish_greeting

# ==============================================================================
# 0. PATH SETUP (must be first!)
# ==============================================================================
# Set up PATH before initializing any tools
if test -d /nix/var/nix/profiles/default/bin
    fish_add_path -p /nix/var/nix/profiles/default/bin
end

if test -d $HOME/.nix-profile/bin
    fish_add_path -p $HOME/.nix-profile/bin
end

# ==============================================================================
# 1. CACHING EXPENSIVE TOOL INITIALIZATION
# ==============================================================================
# Fish doesn't need completion optimization like zsh - it's already fast!
# But we can cache tool initialization scripts for faster startup

set -l cache_dir (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)/fish

# Regenerate a cached init script when the tool's resolved binary changes.
# Nix store files all have a 1970 mtime, so an `-nt` check never fires after
# an upgrade; the resolved store path does change, so stamp the cache with it.
function __cached_init --argument-names name cache_dir
    set -l bin (command -v $name); or return 1
    set -l stamp "# "(path resolve $bin)
    set -l cache $cache_dir/$name.fish
    if not test -f $cache; or test "$(head -n1 $cache)" != "$stamp"
        mkdir -p $cache_dir
        # Only replace the cache if generation succeeds.
        if $argv[3..] >$cache.tmp 2>/dev/null
            begin
                echo $stamp
                cat $cache.tmp
            end >$cache
        end
        rm -f $cache.tmp
    end
    test -f $cache; or return 1
    source $cache
    return 0
end

if __cached_init zoxide $cache_dir zoxide init fish
    alias cd='z'
end

__cached_init atuin $cache_dir atuin init fish
__cached_init starship $cache_dir starship init fish

set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
__cached_init carapace $cache_dir carapace _carapace

__cached_init fzf $cache_dir fzf --fish

functions -e __cached_init

# ==============================================================================
# 2. EDITOR CONFIGURATION
# ==============================================================================
set -gx EDITOR vim
set -gx VISUAL vim

# ==============================================================================
# 3. HISTORY CONFIGURATION
# ==============================================================================
# Fish has sensible defaults, but we'll match zsh settings
set -g fish_history_size 10000

# ==============================================================================
# 3. GIT ABBREVIATIONS (fish's smart aliases)
# ==============================================================================
abbr -a g git
abbr -a gs git status
abbr -a ga git add
abbr -a gc git commit
abbr -a gcm git commit -m
abbr -a gp git push
abbr -a gpl git pull
abbr -a gd git diff
abbr -a gco git checkout
abbr -a gb git branch
abbr -a gl git log --oneline
abbr -a gla git log --oneline --all --graph

# ==============================================================================
# 4. MODERN CLI TOOL ALIASES
# ==============================================================================
if command -v eza >/dev/null 2>&1
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -la --color=always --group-directories-first'
    alias la='eza -a --color=always --group-directories-first'
    alias lt='eza -T --color=always --group-directories-first'
end

if command -v bat >/dev/null 2>&1
    alias bat='bat --paging=never'
    alias bathelp='bat --plain --language=help'
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

if command -v delta >/dev/null 2>&1
    set -gx GIT_PAGER delta
end

# AI coding assistants
alias cc='claude'
alias oc='opencode'

# ==============================================================================
# 5. FZF CONFIGURATION
# ==============================================================================
if command -v fzf >/dev/null 2>&1
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"
    
    if command -v rg >/dev/null 2>&1
        set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    end
end

# ==============================================================================
# 6. CUSTOM FUNCTIONS (matching zsh functions)
# ==============================================================================
function copilot-pr
    echo "📄 PR Description Prompt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.copilot-prompts/pr-description.md 2>/dev/null; or echo "No prompt file found"
end

function copilot-commit
    echo "💬 Commit Message Prompt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.copilot-prompts/commit-message.md 2>/dev/null; or echo "No prompt file found"
end

function copilot-list
    echo "📋 Available Copilot Prompts:"
    ls -1 ~/.copilot-prompts/ 2>/dev/null; or echo "No prompts directory"
end

function gcom
    if test -z (git diff --cached --name-only 2>/dev/null)
        echo "⚠️  No staged changes. Use 'git add <files>' first."
        return 1
    end
    echo "💬 Ask Copilot: 'generate commit message'"
end

function gpr
    echo "📄 Current branch: "(git branch --show-current 2>/dev/null; or echo 'not a git repo')
    echo "💬 Ask Copilot: 'generate PR description'"
end

# ==============================================================================
# 7. CUSTOM CONFIG
# ==============================================================================
if test -f $HOME/.config/fish/config.custom.fish
    source $HOME/.config/fish/config.custom.fish
end

# post-install.sh: go and npm-global paths
fish_add_path -g $HOME/.npm-global/bin
fish_add_path -g $HOME/go/bin

# bun
set -gx BUN_INSTALL $HOME/.bun
fish_add_path -g $BUN_INSTALL/bin
