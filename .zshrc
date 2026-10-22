# Optimized zshrc configuration
# Target: < 200ms startup time

# ==============================================================================
# 1. COMPINIT OPTIMIZATION (biggest win!)
# ==============================================================================
# Personal computer: skip ALL security checks (compaudit)
# -C = skip security check, -d = specify dump file
# -i = ignore insecure directories/files completely
autoload -Uz compinit
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n $zcompdump(#qN.mh+24) ]]; then
    # Dump is older than 24 hours, regenerate
    compinit -i -C -d "$zcompdump"
else
    # Use cached dump, skip ALL checks
    compinit -C -d "$zcompdump"
fi
unset zcompdump

# Compile zcompdump in background for faster loading next time
{
    if [[ -s "${ZDOTDIR:-$HOME}/.zcompdump" && (! -s "${ZDOTDIR:-$HOME}/.zcompdump.zwc" || "${ZDOTDIR:-$HOME}/.zcompdump" -nt "${ZDOTDIR:-$HOME}/.zcompdump.zwc") ]]; then
        zcompile "${ZDOTDIR:-$HOME}/.zcompdump"
    fi
} &!

# ==============================================================================
# 2. LAZY-LOAD EXPENSIVE TOOLS
# ==============================================================================

# Regenerate a cached init script when the tool's resolved binary changes.
# Nix store files all have a 1970 mtime, so an `-nt` check never fires after
# an upgrade; the resolved store path does change, so stamp the cache with it.
_cached_init() {
    local name=$1; shift
    local bin=${commands[$name]}
    [[ -n "$bin" ]] || return 1
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$name.zsh"
    local stamp="# ${bin:A}"
    if [[ ! -f "$cache" ]] || [[ "$(head -n1 "$cache")" != "$stamp" ]]; then
        mkdir -p "${cache:h}"
        # Only replace the cache if generation succeeds.
        if "$@" > "$cache.tmp" 2>/dev/null; then
            { print -r -- "$stamp"; cat "$cache.tmp" } > "$cache"
        fi
        rm -f "$cache.tmp"
    fi
    [[ -f "$cache" ]] || return 1
    source "$cache"
    return 0
}

_cached_init zoxide zoxide init zsh && alias cd='z'
_cached_init atuin atuin init zsh
_cached_init starship starship init zsh
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
_cached_init carapace carapace _carapace
_cached_init fzf fzf --zsh
unfunction _cached_init

# ==============================================================================
# 3. HISTORY CONFIGURATION
# ==============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY HIST_EXPAND HIST_IGNORE_ALL_DUPS

# ==============================================================================
# 4. KEY BINDINGS (no cost)
# ==============================================================================
bindkey "^[[1;5C" forward-word                     # Ctrl+Right
bindkey "^[[1;5D" backward-word                    # Ctrl+Left
bindkey "^[[5~" beginning-of-buffer-or-history     # Page up
bindkey "^[[6~" end-of-buffer-or-history           # Page down
bindkey "^[[H" beginning-of-line                   # Home
bindkey "^[[F" end-of-line                         # End
bindkey "^[[2~" overwrite-mode                     # Insert
bindkey "^[[3~" delete-char                        # Delete
bindkey "^H" backward-delete-word                  # Ctrl+Backspace
bindkey "^[^[[C" forward-word                      # Alt+Right
bindkey "^[^[[D" backward-word                     # Alt+Left
bindkey "^[[1;3C" forward-word                     # Alt+Right (alternative)
bindkey "^[[1;3D" backward-word                    # Alt+Left (alternative)

# ==============================================================================
# 5. ALIASES (no cost - just string definitions)
# ==============================================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline'
alias gla='git log --oneline --all --graph'

# Modern CLI tools - use (( $+commands[cmd] )) instead of command -v
# This is a zsh-native check that's much faster
(( $+commands[eza] )) && {
    alias ls='eza --color=always --group-directories-first'
    alias ll='eza -la --color=always --group-directories-first'
    alias la='eza -a --color=always --group-directories-first'
    alias lt='eza -T --color=always --group-directories-first'
}

(( $+commands[bat] )) && {
    alias bat='bat --paging=never'
    alias bathelp='bat --plain --language=help'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    # NOTE: Removed 'alias cat=bat' - this was causing parse errors
    # Use 'bat' directly or create a different alias
}

(( $+commands[delta] )) && export GIT_PAGER=delta

# AI coding assistants
alias cc='claude'
alias oc='opencode'

# ==============================================================================
# 6. FZF CONFIGURATION (just env vars, fast)
# ==============================================================================
(( $+commands[fzf] )) && {
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
    (( $+commands[rg] )) && {
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    }
}

# ==============================================================================
# 7. COMPLETION CONFIGURATION (after compinit)
# ==============================================================================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zmodload zsh/complist

# Vim keys in completion menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# ==============================================================================
# 8. EDITOR CONFIGURATION
# ==============================================================================
export EDITOR=vim
export VISUAL=vim

# ==============================================================================
# 9. NIX PATH
# ==============================================================================
[[ -d "/nix/var/nix/profiles/default/bin" ]] && export PATH="/nix/var/nix/profiles/default/bin:$PATH"

# ==============================================================================
# 9. ZSH PLUGINS (source directly, already optimized paths)
# ==============================================================================
[[ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && {
    source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    # Performance: use async mode
    ZSH_AUTOSUGGEST_USE_ASYNC=1
}

# Syntax highlighting MUST be last plugin - defer to precmd for faster startup
[[ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && {
    _load_syntax_highlighting() {
        source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        add-zsh-hook -d precmd _load_syntax_highlighting
    }
    add-zsh-hook precmd _load_syntax_highlighting
}

# ==============================================================================
# 10. CUSTOM CONFIG
# ==============================================================================
[[ -f "$HOME/.zshrc.custom" ]] && source "$HOME/.zshrc.custom"

# ==============================================================================
# 11. FUNCTIONS (define functions BEFORE any conflicting aliases)
# ==============================================================================
copilot-pr() {
    echo "📄 PR Description Prompt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.copilot-prompts/pr-description.md 2>/dev/null || echo "No prompt file found"
}

copilot-commit() {
    echo "💬 Commit Message Prompt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat ~/.copilot-prompts/commit-message.md 2>/dev/null || echo "No prompt file found"
}

copilot-list() {
    echo "📋 Available Copilot Prompts:"
    ls -1 ~/.copilot-prompts/ 2>/dev/null || echo "No prompts directory"
}

gcom() {
    [[ -z "$(git diff --cached --name-only 2>/dev/null)" ]] && {
        echo "⚠️  No staged changes. Use 'git add <files>' first."
        return 1
    }
    echo "💬 Ask Copilot: 'generate commit message'"
}

gpr() {
    echo "📄 Current branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
    echo "💬 Ask Copilot: 'generate PR description'"
}

# post-install.sh: go and npm-global paths
export PATH="$HOME/.npm-global/bin:$HOME/go/bin:$PATH"

# opencode
export PATH=/Users/abdullahbajwa/.opencode/bin:$PATH

# bun completions
[ -s "/Users/abdullahbajwa/.bun/_bun" ] && source "/Users/abdullahbajwa/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
