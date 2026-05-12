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

# Clone or update
if [[ -d "$HUNT_DIR/.git" ]]; then
  echo "Updating Hunt..."
  git -C "$HUNT_DIR" pull --quiet
elif [[ ! -d "$HUNT_DIR" ]]; then
  echo "Installing Hunt..."
  echo "Cloning repository..."
  git clone --quiet --depth 1 "$REPO" "$HUNT_DIR"
fi

# Ask about dependency installation
if [[ "$AUTO" == "true" ]]; then
  answer="y"
else
  echo ""
  echo "Hunt requires: fzf, fd, ripgrep, bat, zoxide, eza, zsh"
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
  echo "Make sure the following are installed: fzf, fd, ripgrep, bat, zoxide, eza, zsh"
fi

# Add to shell config
SHELL_RC="${ZDOTDIR:-$HOME}/.zshrc"

# Backup shell config before modifying
cp "$SHELL_RC" "${SHELL_RC}.hunt.bak" 2>/dev/null || true
echo "Backed up $SHELL_RC to ${SHELL_RC}.hunt.bak"

# Add mise activation if Hunt just installed it AND not already present
if [[ "${MISE_INSTALLED:-false}" == "true" ]] && ! grep -q "mise activate" "$SHELL_RC" 2>/dev/null; then
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> "$SHELL_RC"
  echo "Added mise activation to $SHELL_RC"
fi

# Add zoxide init if not already present
if ! grep -q "zoxide init" "$SHELL_RC" 2>/dev/null; then
  echo 'eval "$(zoxide init zsh)"' >> "$SHELL_RC"
  echo "Added zoxide init to $SHELL_RC"
fi

# Add Hunt block (idempotent) — only contains what Hunt owns
HUNT_BEGIN="# >>> Hunt >>>"
HUNT_END="# <<< Hunt <<<"

if grep -qF "$HUNT_BEGIN" "$SHELL_RC" 2>/dev/null; then
  echo "Hunt block already present in $SHELL_RC"
else
  {
    echo ""
    echo "$HUNT_BEGIN"
    echo "source $HUNT_DIR/hunt.sh"
    echo "$HUNT_END"
  } >> "$SHELL_RC"
  echo "Added Hunt block to $SHELL_RC"
fi

echo ""
printf '\033[0;32m%s\033[0m\n' "Done! Restart your shell or run: source $SHELL_RC"
