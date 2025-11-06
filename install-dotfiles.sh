#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Parrot OS Dev Environment — Dotfiles Bootstrap Installer
# Maintainer: Ty Evs
# Repo: https://github.com/tyevs399/dotfiles
# ==========================================================

ZIP_URL="https://github.com/tyevs399/dotfiles/releases/latest/download/dotfiles_repo.zip"
DOTFILES_DIR="$HOME/.dotfiles"
TMP_ZIP="$(mktemp)"

info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

# === PRECHECKS ===
if ! command -v curl >/dev/null 2>&1; then
  error "curl is required but not installed. Install it and rerun."
fi
if ! command -v unzip >/dev/null 2>&1; then
  error "unzip is required but not installed. Install it and rerun."
fi

# === FETCH DOTFILES ===
info "Downloading latest dotfiles package..."
curl -fsSL "$ZIP_URL" -o "$TMP_ZIP" || error "Failed to download dotfiles."

info "Extracting to $DOTFILES_DIR ..."
rm -rf "$DOTFILES_DIR"
mkdir -p "$DOTFILES_DIR"
unzip -o "$TMP_ZIP" -d "$DOTFILES_DIR" >/dev/null
rm "$TMP_ZIP"

# === SYMLINK HELPER ===
link_file() {
  src="$1"
  dest="$2"
  mkdir -p "$(dirname "$dest")"
  ln -sf "$src" "$dest"
  echo "Linked $src -> $dest"
}

# === LINK CORE FILES ===
info "Linking configuration files..."

link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/nvim/init.vim" "$HOME/.config/nvim/init.vim"
mkdir -p "$HOME/.config"
link_file "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# === OPTIONAL TOOLS ===
info "Applying shell and Neovim enhancements..."

if command -v zsh >/dev/null 2>&1; then
  if [ "$SHELL" != "$(command -v zsh)" ]; then
    warn "Switching default shell to zsh..."
    chsh -s "$(command -v zsh)" || warn "Could not change default shell (needs sudo)."
  fi
fi

if command -v nvim >/dev/null 2>&1; then
  info "Installing vim-plug for Neovim..."
  curl -fsSLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# === CLEANUP ===
info "Bootstrap complete! Dotfiles are active."
echo
echo "Next steps:"
echo "  1. Restart your terminal (or log out/in)."
echo "  2. Run 'nvim' and execute :PlugInstall to get plugins."
echo "  3. Enjoy your fully-configured Parrot dev environment."
echo
info "All done ✅"
