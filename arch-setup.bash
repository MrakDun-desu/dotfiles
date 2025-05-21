#!/usr/bin/bash

programs=("vkd3d" "lib32-vkd3d" "noto-fonts-cjk" "noto-fonts-extra"
    "linux-headers" "linux-firmware" "octopi")

continue=false

while ! $continue; do

    continue=true
    echo "GPU drivers - nvidia/nvidia-open/amd? (n/o/a)"
    read answer
    answer="${answer,,}"

    case "$answer" in
    n | nvidia)
        programs+=("nvidia-utils" "lib32-nvidia-utils" "nvidia-settings")
        ;;
    o | nvidia-open)
        programs+=("nvidia-utils" "lib32-nvidia-utils" "nvidia-settings"
            "vulkan-nouveau" "lib32-vulkan-nouveau" "xf86-video-nouveau")
        ;;
    a | amd)
        programs+=("amdvlk" "lib32-amdvlk" "xf86-video-amdgpu"
            "vulkan-radeon" "vulkan-mesa-layers" "lib32-vulkan-radeon")
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
    echo "Install dev programs? (y/n)"
    read answer
    answer="${answer,,}"

    case "$answer" in
    y | yes)
        programs+=("neovim" "docker" "docker-compose" "github-cli" "git-delta"
            "docker-buildx" "fd" "fzf" "npm" "wl-clipboard" "luarocks" "lazygit")
        ;;
    n | no) ;;
    *)
        echo "Unknown option, choose again."
        continue=false
        ;;
    esac

done

continue=false
has_stow=false

while ! $continue; do

    continue=true
    echo "Install other programs (mrak's recommendations)? (y/n)"
    read answer
    answer="${answer,,}"

    case "$answer" in
    y | yes)
        programs+=("fish" "fisher" "ttf-fantasque-nerd" "haruna" "steam"
            "steam-native-runtime" "tetrio-desktop" "vesktop-bin" "zen-browser-bin"
            "mission-center" "libreoffice-still" "stow" "eza" "bat")
        has_stow=true
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

echo "Installing specified programs..."
echo "${programs[@]}"
sudo pacman -S --needed "${programs[@]}"
