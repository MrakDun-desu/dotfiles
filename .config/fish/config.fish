if not status is-interactive
    return
end

function fish_greeting
    fastfetch
end

alias ls='eza -la --color=always --group-directories-first --icons'
alias lt='eza -lT --color=always --group-directories-first --icons'

function cd
    builtin cd $argv && eza -la --color=always --group-directories-first --icons
end

set -gx EDITOR nvim
