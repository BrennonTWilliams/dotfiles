# Foot Terminal Configuration

Foot is a fast, lightweight terminal emulator for Wayland. This configuration provides a Gruvbox-themed setup for Linux/Wayland environments.

## Platform

**Linux/Wayland only** - Foot is designed specifically for Wayland compositors like Sway.

For macOS, use Ghostty instead (see `ghostty/` directory).

## Installation

```bash
cd ~/.dotfiles
stow foot
```

This creates a symlink: `~/.config/foot/foot.ini`

## Features

- **Gruvbox Dark Theme** - Consistent color scheme matching other dotfiles
- **Nerd Font Support** - Configured for IosevkaTerm Nerd Font
- **Minimal Configuration** - Fast startup with sensible defaults
- **Wayland Native** - No X11 dependencies

## Configuration

The configuration file is located at `.config/foot/foot.ini`.

### Font Settings

```ini
[main]
font=IosevkaTerm Nerd Font:size=11
```

To change the font:
1. Ensure your desired font is installed
2. Update the font name and size in `foot.ini`
3. Reload foot or open a new terminal

### Color Scheme

The Gruvbox Dark color palette:

| Color | Normal | Bright |
|-------|--------|--------|
| Black | #282828 | #928374 |
| Red | #cc241d | #fb4934 |
| Green | #98971a | #b8bb26 |
| Yellow | #d79921 | #fabd2f |
| Blue | #458588 | #83a598 |
| Magenta | #b16286 | #d3869b |
| Cyan | #689d6a | #8ec07c |
| White | #a89984 | #ebdbb2 |

**Background:** #282828
**Foreground:** #ebdbb2

## Dependencies

- **foot** - The terminal emulator
- **IosevkaTerm Nerd Font** (or another Nerd Font)

### Installing Foot

**Debian/Ubuntu:**
```bash
sudo apt install foot
```

**Fedora:**
```bash
sudo dnf install foot
```

**Arch:**
```bash
sudo pacman -S foot
```

### Installing Fonts

**Nerd Fonts:**
```bash
# Download from https://www.nerdfonts.com/
# Or on Arch:
yay -S ttf-iosevkaterm-nerd
```

## Customization

### Common Options

Add these to `[main]` section in `foot.ini`:

```ini
[main]
# Font and size
font=IosevkaTerm Nerd Font:size=11

# Terminal dimensions
initial-window-size-chars=120x35

# Padding around text
pad=10x10

# Enable bold text
bold-text-bright=yes
```

### Cursor Settings

```ini
[cursor]
# Cursor style: block, underline, or beam
style=block
blink=no
```

### Scrollback

```ini
[scrollback]
# Number of lines to keep in scrollback
lines=10000
```

### URL Handling

```ini
[url]
# Launch URLs with this command
launch=xdg-open ${url}

# Enable clickable URLs
protocols=http, https, ftp
```

### Key Bindings

```ini
[key-bindings]
# Custom key bindings
scrollback-up-page=Shift+Page_Up
scrollback-down-page=Shift+Page_Down
clipboard-copy=Control+Shift+c
clipboard-paste=Control+Shift+v
```

## Integration with Sway

Foot is configured as the default terminal in the Sway configuration:

```bash
# In sway config
set $term foot
bindsym $mod+Return exec $term
```

## Troubleshooting

### Font not rendering correctly

1. Verify the font is installed:
   ```bash
   fc-list | grep -i iosevka
   ```

2. Check font name matches exactly (use `fc-list` output)

3. Try a different font:
   ```ini
   font=monospace:size=11
   ```

### Colors look wrong

1. Ensure Wayland is running (not XWayland)
2. Check that the color values are valid hex codes without `#`
3. Restart foot after changes

### Terminal not launching

1. Check foot is installed: `which foot`
2. Ensure Wayland session is active
3. Check for errors: `foot --log-level=info`

## Foot vs Ghostty

| Feature | Foot | Ghostty |
|---------|------|---------|
| Platform | Linux/Wayland | macOS, Linux |
| Protocol | Wayland-native | Multiple |
| Config | INI format | Custom format |
| GPU acceleration | No | Yes |
| Resource usage | Minimal | Low |

Use **Foot** for Wayland/Sway environments and **Ghostty** for macOS or when you need GPU acceleration.

## Related Configuration

- **sway/** - Window manager that uses foot as default terminal
- **ghostty/** - Alternative terminal emulator for macOS
- **tmux/** - Terminal multiplexer that works inside foot
- **starship/** - Prompt that displays in foot

## Resources

- [Foot Documentation](https://codeberg.org/dnkl/foot)
- [Foot Wiki](https://codeberg.org/dnkl/foot/wiki)
