echo "Installing current directory dotfiles to home..."
stow --ignore="^[^\.].*" --adopt -t "$HOME" .
