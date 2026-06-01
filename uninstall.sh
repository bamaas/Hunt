#!/usr/bin/env bash
set -euo pipefail

HUNT_DIR="${HUNT_DIR:-$HOME/.hunt}"
SHELL_RC="${ZDOTDIR:-$HOME}/.zshrc"

echo "Uninstalling Hunt..."

# Backup shell config before modifying
cp "$SHELL_RC" "${SHELL_RC}.hunt.bak" 2>/dev/null || true

# Remove Hunt block from shell config
if grep -qF "# >>> Hunt >>>" "$SHELL_RC" 2>/dev/null; then
  sed -i.tmp '/# >>> Hunt >>>/,/# <<< Hunt <<</d' "$SHELL_RC"
  rm -f "${SHELL_RC}.tmp"
  echo "Removed Hunt block from $SHELL_RC"
else
  echo "No Hunt block found in $SHELL_RC"
fi

# Remove mise conf.d symlink
MISE_CONFD="${XDG_CONFIG_HOME:-$HOME/.config}/mise/conf.d"
if [[ -L "$MISE_CONFD/hunt.toml" ]]; then
  rm "$MISE_CONFD/hunt.toml"
  echo "Removed mise config symlink"
fi

# Remove Hunt directory
if [[ -d "$HUNT_DIR" ]]; then
  rm -rf "$HUNT_DIR"
  echo "Removed $HUNT_DIR"
fi

echo ""
echo "Note: mise and zoxide were left installed."
echo "If you no longer need them, remove manually:"
echo "  mise:   run 'mise implode' and remove 'mise activate' from $SHELL_RC"
echo "  zoxide: remove 'zoxide init' from $SHELL_RC"
echo ""
printf '\033[0;32m%s\033[0m\n' "Done! Restart your shell or run: source $SHELL_RC"
