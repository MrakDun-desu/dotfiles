if not status is-interactive
    return
end

function fish_greeting
    fastfetch --logo "$HOME/Pictures/Pfps/mari_no_bg.png"
end

alias ls='eza -la --color=always --group-directories-first --icons=always'
alias lt='eza -lT --color=always --group-directories-first --icons=always'

function cd
    builtin cd $argv && ls
end

set -gx EDITOR nvim

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

set -gx PATH $PATH $HOME/.dotnet/tools

source (/usr/bin/starship init fish --print-full-init | psub)
