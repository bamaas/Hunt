#!/usr/bin/env bash
set -euo pipefail

docker run --rm -it ubuntu:latest bash -c '
  set -euo pipefail

  apt-get update && apt-get install -y zsh tree vim git curl

  # Set zsh as default shell
  chsh -s /usr/bin/zsh

  # Install Hunt
  SHELL=/usr/bin/zsh zsh -c "$(curl -fsSL https://raw.githubusercontent.com/bamaas/Hunt/main/install.sh)"

  # Drop into zsh to test
  zsh
'
