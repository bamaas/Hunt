#!/usr/bin/env bash
set -euo pipefail

HUNT_DIR="${HUNT_DIR:-$HOME/.hunt}"
REPO="https://github.com/bamaas/Hunt.git"
AUTO=false
[[ "${1:-}" == "--yes" ]] && AUTO=true

if [[ "$SHELL" != */zsh ]]; then
  echo "Hunt requires zsh as your default shell." >&2
  echo "Your current shell is: $SHELL" >&2
  exit 1
fi

echo "Installing Hunt..."

# Clone or update
if [[ -d "$HUNT_DIR/.git" ]]; then
  echo "Updating Hunt..."
  git -C "$HUNT_DIR" pull --quiet
elif [[ ! -d "$HUNT_DIR" ]]; then
  echo "Cloning Hunt..."
  git clone --quiet "$REPO" "$HUNT_DIR"
fi

# Ask about dependency installation
if [[ "$AUTO" == "true" ]]; then
  answer="y"
else
  echo ""
  echo "Hunt requires: fzf, fd, ripgrep, bat, zoxide, tree, zsh"
  echo ""
  echo "Install dependencies automatically with mise (https://mise.jdx.dev)? (y/n)"
  read -r answer < /dev/tty
fi

if [[ "$answer" =~ ^[Yy]$ ]]; then
  # Install mise if needed
  MISE_INSTALLED=false
  if ! command -v mise &>/dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
    eval "$(~/.local/bin/mise activate bash)"
    MISE_INSTALLED=true
  fi

  # Symlink config into mise conf.d so tools are installed/managed automatically
  MISE_CONFD="${XDG_CONFIG_HOME:-$HOME/.config}/mise/conf.d"
  mkdir -p "$MISE_CONFD"
  ln -sf "$HUNT_DIR/.mise/config.toml" "$MISE_CONFD/hunt.toml"
  echo "Linked config to $MISE_CONFD/hunt.toml"

  mise trust "$MISE_CONFD/hunt.toml"
  echo "Installing dependencies..."
  mise install -C "$HUNT_DIR" --yes
else
  echo "Skipping dependency installation."
  echo "Make sure the following are installed: fzf, fd, ripgrep, bat, zoxide, tree, zsh"
fi

# Add to shell config
SHELL_RC="$HOME/.zshrc"

# Add mise activation if we just installed it
if [[ "${MISE_INSTALLED:-false}" == "true" ]]; then
  MISE_LINE='eval "$(~/.local/bin/mise activate zsh)"'
  if ! grep -qF "$MISE_LINE" "$SHELL_RC" 2>/dev/null; then
    echo "$MISE_LINE" >> "$SHELL_RC"
    echo "Added mise activation to $SHELL_RC"
  fi
fi

SOURCE_LINE="source $HUNT_DIR/hunt.sh"
if [[ -f "$SHELL_RC" ]] && grep -qF "$SOURCE_LINE" "$SHELL_RC"; then
  echo "Already sourced in $SHELL_RC"
else
  echo "$SOURCE_LINE" >> "$SHELL_RC"
  echo "Added to $SHELL_RC"
fi

echo ""
echo "Done! Restart your shell or run: source $SHELL_RC"
