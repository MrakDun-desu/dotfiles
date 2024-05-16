# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="jonathan"

zstyle ':omz:update' mode auto      # update automatically without asking

# Auto-update frequency in days
zstyle ':omz:update' frequency 15

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Plugins
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins-Overview
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

export GODOT="$HOME/.config/godotenv/godot/bin/godot"
export PATH="$HOME/.config/godotenv/godot/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# school aliases and vars
alias sshmerlin="ssh xdanco00@merlin.fit.vutbr.cz"
export EVA_DOCS="xdanco00@eva.fit.vutbr.cz:/homes/eva/xd/xdanco00/Dokumenty/"

# git aliases
alias gittree="git log --graph --pretty=oneline --abbrev=commit"

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

# first clone this if it doesn't exist (change the repo name to start with .)
source ~/.fzf-git.sh/fzf-git.sh

# better cat
export BAT_THEME="Catppuccin Mocha"

# better ls
alias ls="eza --color=always --long --git --icons=always --no-time --no-permissions"
