# Sway Window Manager Configuration

Sway is a tiling Wayland compositor and a drop-in replacement for i3. This configuration provides a keyboard-driven workflow with vim-style navigation.

## Platform

**Linux/Wayland only** - Sway runs on Wayland and is not available for macOS.

For macOS window management, consider Rectangle (included in `packages-macos.txt`).

## Installation

```bash
cd ~/.dotfiles
stow sway
```

This creates a symlink: `~/.config/sway/config`

## Features

- **Vim-style Navigation** - h/j/k/l keys for movement
- **Workspaces** - 10 workspaces with easy switching
- **Auto-start Applications** - Waybar, mako, nm-applet
- **Media Keys** - Volume, brightness, and screenshot support
- **HiDPI Support** - Output scaling configured

## Key Bindings

The modifier key is **Super (Windows key)** by default.

### Application Launch

| Key | Action |
|-----|--------|
| `Mod + Return` | Open terminal (foot) |
| `Mod + d` | Open application launcher (wmenu) |

### Window Management

| Key | Action |
|-----|--------|
| `Mod + Shift + q` | Close focused window |
| `Mod + h/j/k/l` | Move focus (vim-style) |
| `Mod + Shift + h/j/k/l` | Move window |
| `Mod + Arrow keys` | Move focus |
| `Mod + Shift + Arrow keys` | Move window |

### Layout

| Key | Action |
|-----|--------|
| `Mod + b` | Split horizontally |
| `Mod + v` | Split vertically |
| `Mod + s` | Stacking layout |
| `Mod + w` | Tabbed layout |
| `Mod + e` | Toggle split |
| `Mod + f` | Toggle fullscreen |
| `Mod + Shift + Space` | Toggle floating |
| `Mod + Space` | Toggle focus between tiling/floating |

### Workspaces

| Key | Action |
|-----|--------|
| `Mod + 1-0` | Switch to workspace 1-10 |
| `Mod + Shift + 1-0` | Move window to workspace 1-10 |

### Resize Mode

Enter resize mode with `Mod + r`, then:

| Key | Action |
|-----|--------|
| `h/Left` | Shrink width |
| `l/Right` | Grow width |
| `k/Up` | Shrink height |
| `j/Down` | Grow height |
| `Return/Escape` | Exit resize mode |

### Scratchpad

| Key | Action |
|-----|--------|
| `Mod + Shift + -` | Move window to scratchpad |
| `Mod + -` | Show/cycle scratchpad windows |

### Utilities

| Key | Action |
|-----|--------|
| `Mod + Shift + c` | Reload configuration |
| `Mod + Shift + e` | Exit sway |
| `Print` | Take screenshot |

### Media Keys

| Key | Action |
|-----|--------|
| `XF86AudioMute` | Toggle mute |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessDown` | Brightness -5% |
| `XF86MonBrightnessUp` | Brightness +5% |

## Configuration Details

### Default Applications

```bash
# Terminal
set $term foot

# Application launcher
set $menu wmenu-run
```

### Auto-start

The configuration starts these applications on login:

- **waybar** - Status bar
- **mako** - Notification daemon
- **nm-applet** - Network Manager applet

### Window Appearance

```bash
# 3-pixel borders for windows
default_border pixel 3

# Focus doesn't follow mouse
focus_follows_mouse no
```

### Output Configuration

For HiDPI displays:

```bash
# Scale HDMI output by 2x
output HDMI-A-1 scale 2.0
```

List your outputs:
```bash
swaymsg -t get_outputs
```

### Status Bar

The default status bar shows date and time. For a more feature-rich bar, Waybar is auto-started and will override this.

## Dependencies

Install all Sway-related packages:

```bash
# Debian/Ubuntu
sudo apt install sway swaybg swayidle swaylock waybar foot wmenu grim mako-notifier network-manager-gnome brightnessctl

# Arch
sudo pacman -S sway swaybg swayidle swaylock waybar foot wmenu grim mako networkmanager brightnessctl
```

Or use the package list:
```bash
xargs -a packages-linux.txt sudo apt install -y
```

### Required Packages

| Package | Purpose |
|---------|---------|
| sway | Window manager |
| swaybg | Background setter |
| swayidle | Idle management |
| swaylock | Screen locker |
| waybar | Status bar |
| foot | Terminal emulator |
| wmenu | Application launcher |
| grim | Screenshot tool |
| mako-notifier | Notification daemon |
| brightnessctl | Brightness control |

## Customization

### Background/Wallpaper

```bash
# Add to sway config
output * bg /path/to/wallpaper.png fill
```

### Idle and Lock

Uncomment and configure in the config file:

```bash
exec swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
    before-sleep 'swaylock -f -c 000000'
```

### Input Devices

Configure touchpad, keyboard, etc.:

```bash
input "type:touchpad" {
    dwt enabled
    tap enabled
    natural_scroll enabled
    middle_emulation enabled
}

input "type:keyboard" {
    xkb_options caps:escape
}
```

List your inputs:
```bash
swaymsg -t get_inputs
```

### Gaps

Add gaps between windows:

```bash
gaps inner 10
gaps outer 5
```

### Colors

Customize window colors:

```bash
# class                 border  bg      text    indicator child_border
client.focused          #b8bb26 #282828 #ebdbb2 #b8bb26   #b8bb26
client.unfocused        #3c3836 #282828 #928374 #3c3836   #3c3836
```

## Troubleshooting

### Sway not starting

1. Ensure you're not already in a graphical session
2. Start from a TTY: `sway`
3. Check logs: `cat ~/.local/share/sway/sway.log`

### Applications not launching

1. Verify applications are installed
2. Check PATH includes `/usr/bin`
3. Try running from terminal to see errors

### Display not detected

1. List outputs: `swaymsg -t get_outputs`
2. Check cable connections
3. For HiDPI, adjust scale values

### No audio/brightness keys

1. Install required utilities (pactl, brightnessctl)
2. Verify user is in appropriate groups:
   ```bash
   groups $USER
   # Should include: video, audio
   ```

### Waybar not showing

1. Check if waybar is installed
2. Verify configuration: `waybar`
3. Check for errors in waybar config

## File Locations

- **Configuration:** `~/.config/sway/config`
- **Logs:** `~/.local/share/sway/sway.log`
- **System config:** `/etc/sway/config`

## Related Configuration

- **foot/** - Default terminal emulator for Sway
- **waybar/** - Status bar (if separate configuration exists)
- **tmux/** - Terminal multiplexer for use inside foot

## Resources

- [Sway Wiki](https://github.com/swaywm/sway/wiki)
- [Sway Man Page](https://man.archlinux.org/man/sway.5)
- [i3 User Guide](https://i3wm.org/docs/userguide.html) (mostly compatible)
