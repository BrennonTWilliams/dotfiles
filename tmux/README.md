# Tmux Configuration

A comprehensive tmux configuration with Gruvbox theme, vim-style key bindings, and cross-platform clipboard integration.

## Installation

```bash
cd ~/.dotfiles
stow tmux
```

## Features

- **Gruvbox Dark Theme** - Consistent color scheme matching other dotfiles
- **Vi Mode** - Vim-style navigation and copy mode
- **Mouse Support** - Full mouse support for pane selection and resizing
- **Cross-Platform Clipboard** - Automatic detection of macOS (pbcopy) or Linux (xclip)
- **Plugin Management** - TPM (Tmux Plugin Manager) integration

## Key Bindings

### Prefix

The prefix key is changed from `C-b` to `C-a` for easier access.

### Pane Management

| Key | Action |
|-----|--------|
| `prefix + \|` | Split pane horizontally |
| `prefix + -` | Split pane vertically |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `Alt + Arrow` | Navigate panes (no prefix needed) |
| `prefix + S` | Toggle pane synchronization |

### Window Management

| Key | Action |
|-----|--------|
| `prefix + c` | Create new window |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |
| `prefix + 1-9` | Switch to window by number |

### Copy Mode (Vi-style)

| Key | Action |
|-----|--------|
| `prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy selection to system clipboard |
| `Enter` | Copy selection and exit |
| `C-y` | Copy selection (stay in copy mode) |

### Other Commands

| Key | Action |
|-----|--------|
| `prefix + r` | Reload configuration |

## Configuration Details

### Terminal Settings

- 256 color support enabled
- True color (24-bit) support via terminal overrides
- Faster escape time (0ms) for better vim/neovim responsiveness
- Focus events enabled for editor integration

### Window Behavior

- Windows and panes start at index 1 (not 0)
- Windows automatically renumber when one is closed
- 50,000 line scrollback buffer
- Aggressive resize for multiple clients

### Status Bar

The status bar displays:

- **Left**: Session name, hostname
- **Right**: CPU usage, time, and date

### Gruvbox Theme Colors

```
Background: #282828
Foreground: #ebdbb2
Active border: #b8bb26 (green)
Orange accent: #fe8019
```

## Plugins

This configuration uses TPM (Tmux Plugin Manager) with the following plugins:

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager |
| `tmux-plugins/tmux-sensible` | Sensible defaults |
| `tmux-plugins/tmux-yank` | Enhanced clipboard integration |
| `tmux-plugins/tmux-resurrect` | Session persistence |
| `tmux-plugins/tmux-continuum` | Automatic session saving |
| `tmux-plugins/tmux-cpu` | CPU monitoring |
| `tmux-plugins/tmux-battery` | Battery status |

### Installing Plugins

1. Install TPM:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

2. Start tmux and press `prefix + I` to install plugins

### Plugin Settings

- **Resurrect**: Saves nvim sessions
- **Continuum**: Automatic restore is disabled by default
- **Yank**: Configured for system clipboard integration

## Dependencies

- **tmux** 3.0+ (for modern features)
- **xclip** (Linux) or **pbcopy** (macOS) for clipboard
- **Nerd Font** (optional, for status bar icons)

Install on Debian/Ubuntu:
```bash
sudo apt install tmux xclip
```

Install on macOS:
```bash
brew install tmux
# pbcopy/pbpaste are built-in
```

## Clipboard Integration

The configuration automatically detects the platform:

- **macOS**: Uses `pbcopy` and `pbpaste`
- **Linux**: Uses `xclip -selection clipboard`

Copy from tmux works with:
- `y` key in copy mode
- Mouse drag selection
- `Enter` key to copy and exit

## Customization

### Local Overrides

Create `~/.tmux.conf.local` for machine-specific settings:

```bash
# Example: Change status bar update interval
set -g status-interval 1

# Example: Add custom key binding
bind M new-window -n "music" "ncmpcpp"
```

Source it in your tmux.conf:
```bash
if-shell "[ -f ~/.tmux.conf.local ]" "source ~/.tmux.conf.local"
```

### Theme Customization

To modify colors, update the variables in the "Gruvbox Dark Theme" section:

```bash
# Status bar background
set -g status-style bg='#282828',fg='#ebdbb2'

# Active pane border
set -g pane-active-border-style fg='#b8bb26'
```

## Troubleshooting

### Colors look wrong

Ensure your terminal supports true color and has the correct TERM setting:

```bash
# Add to your shell rc file
export TERM="xterm-256color"
```

### Clipboard not working

Verify xclip is installed (Linux):
```bash
which xclip || sudo apt install xclip
```

Test clipboard manually:
```bash
echo "test" | xclip -selection clipboard
xclip -selection clipboard -o
```

### Plugins not loading

1. Verify TPM is installed: `ls ~/.tmux/plugins/tpm`
2. Reload config: `tmux source ~/.tmux.conf`
3. Install plugins: Press `prefix + I`

## Related Configuration

- **Starship** - Prompt configuration works inside tmux
- **Ghostty/Foot** - Terminal emulators that work well with tmux
- **Neovim** - Focus events are enabled for better integration
