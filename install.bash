echo "Installing current directory dotfiles to home..."
stow -R --ignore="^[^\.].*" -t "$HOME" .
