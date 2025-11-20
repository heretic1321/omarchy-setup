BKP="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BKP"

# tmux
[ -e "$HOME/.tmux.conf" ] && mv "$HOME/.tmux.conf" "$BKP/"
# wezterm (move the entire dir if you keep multiple files)
[ -d "$HOME/.config/wezterm" ] && mv "$HOME/.config/wezterm" "$BKP/"
# neovim (your whole config, not caches)
[ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$BKP/"

# place into repo in Stow layout
[ -e "$BKP/.tmux.conf" ] && mv "$BKP/.tmux.conf" tmux/.tmux.conf
[ -d "$BKP/wezterm" ]    && mv "$BKP/wezterm" wezterm/.config/
[ -d "$BKP/nvim" ]       && mv "$BKP/nvim"    nvim/.config/

