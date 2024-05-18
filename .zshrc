# ------------- Basic theme setup ---------------------

THEME_HOME=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
if [ ! -d $THEME_HOME ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $THEME_HOME
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------- Basic oh-my-zsh setup -----------------

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# enable auto-update every 15 days
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 15

# faster status check on large git repos
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Plugins
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins-Overview
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git)

source $ZSH/oh-my-zsh.sh

# ------------- Plugins, better commands, configuration -----------------

# zoxide (better cd)
eval "$(zoxide init --cmd cd zsh)"

# fzf and fd instead of find
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
# ** completion for directories
_fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
}

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)     fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
        ssh)    fzf --preview 'dig {}' "$@" ;;
        *)      fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
    esac
}

# better cat
if [ ! -f "$(bat --config-dir)/themes/Catppuccin Mocha.tmTheme" ]; then
    mkdir -p "$(bat --config-dir)/themes"
    wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
    bat cache --build
fi
export BAT_THEME="Catppuccin Mocha"
alias cat="bat"

# better ls
alias ls="eza --color=always --long --git --icons=always --no-time"

# nice git log
alias gittree="git log --graph --pretty=oneline --abbrev=commit"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ------------- School and envvar stuff -----------------

export GODOT="$HOME/.config/godotenv/godot/bin/godot"
export PATH="$HOME/.config/godotenv/godot/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# school aliases and vars
alias sshmerlin="ssh xdanco00@merlin.fit.vutbr.cz"
export EVA_DOCS="xdanco00@eva.fit.vutbr.cz:/homes/eva/xd/xdanco00/Dokumenty/"
