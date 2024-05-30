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

# install basic packages
echo -e "Which distribution?\n1) Debian\n2) SUSE"
read -p "" distro

echo -e "Adding essentials..."
if [ $distro == 1 ]
then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install lutris steam vlc meld yakuake wl-clipboard zsh btop gh zoxide eza bat fzf fd-find tldr wine obs-studio flatpak dropbox
elif [ $distro == 2 ]
then
    sudo zypper refresh
    sudo zypper install opi
    opi codecs
    sudo zypper install lutris steam vlc meld yakuake wl-clipboard zsh btop gh neovim zoxide eza bat fzf fd tldr wine obs-studio flatpak dropbox-cli
else
    echo "Invalid distro, aborting..."
fi

