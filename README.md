# Hunt

A fast, multi-mode file finder for the terminal. Built on [fzf](https://github.com/junegunn/fzf) with integrated preview, grep, file browsing, and directory jumping.

## Install

### With mise (recommended)

```sh
curl -fsSL https://raw.githubusercontent.com/bamaas/Hunt/main/install.sh | bash
```

Or manually:

```sh
# 1. Clone
git clone https://github.com/bamaas/Hunt.git ~/.hunt

# 2. Install dependencies globally from .mise/config.toml
cd ~/.hunt && grep '=' .mise/config.toml | grep -v '^\[' | while IFS='=' read -r tool version; do
  mise use -g "$(echo $tool | tr -d ' \"')@$(echo $version | tr -d ' \"')"
done

# 3. Source
echo 'source ~/.hunt/hunt.sh' >> ~/.zshrc
```

### Manual

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
- [tree](https://linux.die.net/man/1/tree) (for explore preview)
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
| `ctrl-/` | Toggle preview |
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
