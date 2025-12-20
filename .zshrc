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

# Zoxide: Cache the init script instead of running eval every time
_zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zoxide.zsh"
if [[ ! -f "$_zoxide_cache" ]] || [[ $(command -v zoxide) -nt "$_zoxide_cache" ]]; then
    mkdir -p "${_zoxide_cache:h}"
    zoxide init zsh > "$_zoxide_cache"
fi
source "$_zoxide_cache"
alias cd='z'

# Atuin: Cache the init script
_atuin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/atuin.zsh"
if [[ ! -f "$_atuin_cache" ]] || [[ $(command -v atuin) -nt "$_atuin_cache" ]]; then
    mkdir -p "${_atuin_cache:h}"
    atuin init zsh > "$_atuin_cache"
fi
source "$_atuin_cache"

# Starship: Cache the init script
_starship_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/starship.zsh"
if [[ ! -f "$_starship_cache" ]] || [[ $(command -v starship) -nt "$_starship_cache" ]]; then
    mkdir -p "${_starship_cache:h}"
    starship init zsh > "$_starship_cache"
fi
source "$_starship_cache"

# Carapace: Cache the init script
_carapace_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/carapace.zsh"
if command -v carapace >/dev/null 2>&1; then
    if [[ ! -f "$_carapace_cache" ]] || [[ $(command -v carapace) -nt "$_carapace_cache" ]]; then
        mkdir -p "${_carapace_cache:h}"
        export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
        carapace _carapace > "$_carapace_cache"
    fi
    source "$_carapace_cache"
fi

# FZF: Cache the init script  
_fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/fzf.zsh"
if command -v fzf >/dev/null 2>&1; then
    if [[ ! -f "$_fzf_cache" ]] || [[ $(command -v fzf) -nt "$_fzf_cache" ]]; then
        mkdir -p "${_fzf_cache:h}"
        fzf --zsh > "$_fzf_cache" 2>/dev/null
    fi
    source "$_fzf_cache" 2>/dev/null
fi

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
