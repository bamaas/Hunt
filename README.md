# Hunt

A fast, multi-mode file finder for the terminal. Built on [fzf](https://github.com/junegunn/fzf) with integrated preview, grep, file browsing, and directory jumping.

## Install

### With mise (recommended)

```sh
curl -fsSL https://raw.githubusercontent.com/bamaas/Hunt/main/install.sh | bash
```

Or manually with [mise](https://mise.jdx.dev):

```sh
# 1. Clone
git clone https://github.com/bamaas/Hunt.git ~/.hunt

# 2. Symlink config into mise conf.d to install dependencies
mkdir -p ~/.config/mise/conf.d
ln -sf ~/.hunt/.mise/config.toml ~/.config/mise/conf.d/hunt.toml
mise trust ~/.config/mise/conf.d/hunt.toml
mise install

# 3. Source
echo 'source ~/.hunt/hunt.sh' >> ~/.zshrc
```

### Docker

```sh
docker run --rm -it -e EDITOR=vim -v "$PWD":/workspace ghcr.io/bamaas/hunt:latest
```

### Without mise

Install the dependencies with your package manager, then:

```sh
git clone https://github.com/bamaas/Hunt.git ~/.hunt
echo 'source ~/.hunt/hunt.sh' >> ~/.zshrc
```

## Usage

```sh
# Search in current directory
hunt

# Search in a specific directory
hunt ~/projects
```

## Dependencies

- [fzf](https://github.com/junegunn/fzf) >= 0.55
- [fd](https://github.com/sharkdp/fd)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [bat](https://github.com/sharkdp/bat)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [eza](https://github.com/eza-community/eza) (for explore preview)
- zsh

## Modes

| Mode | Description |
|------|-------------|
| **files** | Fuzzy find files by name |
| **grep** | Live ripgrep search across file contents |
| **recent** | Files modified in the last 7 days |
| **explore** | Browse directories with tree preview |
| **jump** | Quick directory jump via [zoxide](https://github.com/ajeetdsouza/zoxide) |

## Keybindings

Keybindings adapt automatically: `ctrl-` on macOS/Linux, `alt-` in Windows Terminal.

| Key | Action |
|-----|--------|
| `ctrl-f` / `alt-f` | Switch to files mode |
| `ctrl-g` / `alt-g` | Switch to grep mode |
| `ctrl-r` / `alt-r` | Switch to recent mode |
| `ctrl-e` / `alt-e` | Switch to explore mode |
| `ctrl-j` / `alt-j` | Jump to directory (zoxide) |
| `ctrl-/` / `alt-/` | Toggle preview |
| `enter` | Open file in editor (or cd into directory in explore) |
| `esc` | Go up a directory (explore mode) |
| `ctrl-c` | Exit |

## Configuration

Environment variables (all optional):

| Variable | Default | Description |
|----------|---------|-------------|
| `HUNT_EDITOR` | `$EDITOR` or `vim` | Editor to open files with |
| `HUNT_PREVIEW_POSITION` | `right` | Preview position: `right`, `left`, `up`, `down` |
| `HUNT_PREVIEW_SIZE` | `40` | Preview size as percentage (1-99) |

Optionally, add a short alias to your `~/.zshrc`:

```sh
alias h="hunt "
```
