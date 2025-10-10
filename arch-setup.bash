#!/usr/bin/env bash

packages="vkd3d lib32-vkd3d noto-fonts-cjk noto-fonts-extra linux-headers linux-firmware octopi"

continue=false

while ! $continue; do

    continue=true
    echo "GPU drivers - nvidia/nvidia-open/amd? (n/o/a)"
    read answer
    answer="${answer,,}"

    case "$answer" in
    n | nvidia)
        packages="$packages nvidia nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings"
        ;;
    o | nvidia-open)
        packages="$packages nvidia-open nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings
            vulkan-nouveau lib32-vulkan-nouveau xf86-video-nouveau"
        ;;
    a | amd)
        packages="$packages amdvlk lib32-amdvlk xf86-video-amdgpu
            vulkan-radeon vulkan-mesa-layers lib32-vulkan-radeon"
        ;;
    *)
        echo "Unknown option, choose again."
        continue=false
        ;;
    esac

done

continue=false

while ! $continue; do

    continue=true
    echo "Install dev packages? (y/n)"
    read answer
    answer="${answer,,}"

    case "$answer" in
    y | yes)
        packages="$packages neovim docker docker-compose github-cli git-delta
            docker-buildx fd fzf npm wl-clipboard luarocks lazygit"
        ;;
    n | no) ;;
    *)
        echo "Unknown option, choose again."
        continue=false
        ;;
    esac

done

continue=false
has_bat=false

while ! $continue; do

    continue=true
    echo "Install other packages (mrak's recommendations)? (y/n)"
    read answer
    answer="${answer,,}"

    case "$answer" in
    y | yes)
        packages="$packages fish ttf-fantasque-nerd haruna steam
            steam-native-runtime tetrio-desktop vesktop-bin zen-browser-bin
            mission-center libreoffice-still stow eza bat"
        has_bat=true
        ;;
    n | no) ;;
    *)
        echo "Unknown option, choose again."
        continue=false
        ;;
    esac

done

echo "Enabling pacman color, parallel downloads and multilib..."
sudo sed -i 's/^#ParallelDownloads = .*/ParallelDownloads = 5/' /etc/pacman.conf
sudo sed -Ei 's/^#(Color|\[multilib\]|Include)/\1/' /etc/pacman.conf

echo "Installing paru for AUR..."
sudo pacman -S --needed base-devel &&
    git clone https://aur.archlinux.org/paru.git &&
    cd paru &&
    makepkg -si &&
    cd .. &&
    rm -rf paru

echo "Installing specified packages..."
echo $packages"
paru -S --noconfirm --skipreview --needed $packages

if $has_bat; then
    bat cache --build
fi
