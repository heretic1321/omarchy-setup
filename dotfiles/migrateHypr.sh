set -euo pipefail
BKP="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BKP"

# move out of the way only after confirming we can copy later
copy_tree() {
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$1/" "$2/"
  else
    cp -a "$1/." "$2/"
  fi
}

# ensure repo target exists
mkdir -p "$HOME/dotfiles/hypr/.config/hypr"

# if live config exists, move it to backup, then copy into repo
if [ -d "$HOME/.config/hypr" ]; then
  mv "$HOME/.config/hypr" "$BKP/"
  copy_tree "$BKP/hypr" "$HOME/dotfiles/hypr/.config/hypr"
else
  echo "~/.config/hypr not found; nothing to migrate."
fi
