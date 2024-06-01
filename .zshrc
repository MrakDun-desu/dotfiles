# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# theme
zinit ice depth=1; zinit light romkatv/powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# useful plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# snippets (plugins from oh-my-zsh)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# history options for better autocompletion
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# if eza exists, use it instead of ls
ls=ls
if [ $+commands[eza] ]
then
    alias ls="eza --color=always --git --icons=always --no-time"
    ls=eza
else
    alias ls="ls --color"
fi

# if zoxide exists, use it instead of cd
cd=cd
if [ $+commands[z] ]
then
    eval "$(zoxide init --cmd cd zsh)"
    cd=z
fi

# decide which tool to use for finding -
# debian uses fdfind, others fd, if not available just use find
find=find
if [ $+commands[fdfind] ]
then
    find=fdfind
elif [ $+commands[fd] ]
then
    find=fd
fi
alias fd="$find"

# decide which tool to use for cat -
# debian uses batcat, others bat, if not available just use cat
cat=cat
if [ $+commands[batcat] ]
then
    cat=batcat
fi
if [ $+commands[bat] ]
then
    cat=bat
fi
alias cat="$cat"

# install catppuccin for bat
if [ $cat != "cat" ]
then
    if [ ! -f "$($cat --config-dir)/themes/Catppuccin Mocha.tmTheme" ]
    then
        mkdir -p "$($cat --config-dir)/themes"
        wget -P "$($cat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
        $cat cache --build
    fi
    export BAT_THEME="Catppuccin Mocha"
fi

# fzf
if [ $+commands[fzf] ]
then
    # eval "$(fzf --zsh)" # doesn't work with debian version of fzf
    export FZF_DEFAULT_COMMAND="$find --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$find --type=d --hidden --strip-cwd-prefix --exclude .git"
    if [ $cat != "cat" ]
    then
        export FZF_CTRL_T_OPTS="--preview '$cat -n --color=always --line-range :500 {}'"
    fi
    if [ $ls != "ls" ]
    then
        export FZF_ALT_C_OPTS="--preview '$ls --tree --color=always {} | head -200'"
    fi

    zstyle ":fzf-tab:complete:cd:*" fzf-preview "$ls --color $realpath"
    zstyle ":fzf-tab:complete:__zoxide_z:*" fzf-preview "ls --color $realpath"

    _fzf_compgen_path() {
        $find --hidden --exclude .git . "$1"
    }

    _fzf_compgen_dir() {
        $find --type=d --hidden --exclude .git . "$1"
    }
fi

bindkey -e
bindkey '^n' history-search-backward
bindkey '^n' history-search-forward

# completion styling
zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"
zstyle ":completion:*" menu no

# school stuff
alias sshmerlin="ssh xdanco00@merlin.fit.vutbr.cz"
export EVA_DOCS="xdanco00@eva.fit.vutbr.cz:/homes/eva/xd/xdanco00/Dokumenty"

# path stuff
export PATH="/home/mrak/.dotnet/tools:$PATH"
export GODOT="/home/mrak/.config/godotenv/godot/bin/godot"
export PATH="/home/mrak/.config/godotenv/godot/bin:$PATH"
