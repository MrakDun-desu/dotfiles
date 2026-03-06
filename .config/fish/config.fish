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

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

set -gx PATH $PATH $HOME/.dotnet/tools
/usr/bin/mise activate fish | source
