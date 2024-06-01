#!/usr/bin/bash

# link the non-config files that need to be in root
ln -sf $(realpath .editorconfig) $HOME
ln -sf $(realpath .gitconfig) $HOME
ln -sf $(realpath .zshrc) $HOME
for f in ./*
do
    if [ -f $f ] && [ $f != ".git" ] && [ $f != install.sh ]
    then
        ln -sf $(realpath $f) $HOME
    fi
done

# link all .config directories
for f in ./.config/*
do
    if [ -d $f ]
    then
        ln -sf $(realpath $f) $HOME/.config
    fi
done

# sudo apt-get install lutris steam vlc meld yakuake wl-clipboard zsh btop gh zoxide eza bat fzf fd-find tldr wine obs-studio flatpak dropbox
