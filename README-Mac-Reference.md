# Mac Reference System Setup Guide

This guide explains how to set up and maintain a Mac reference system that preserves standard macOS hotkeys and behavior.

## What We've Fixed

### Hotkey Changes Reverted
1. **Ghostty Terminal**: Disabled custom keybindings (`Ctrl+Shift+C/V/N/T`)
2. **IntelliShell**: Completely disabled initialization to prevent shell-level hotkey conflicts
3. **Rectangle**: Not installed (no action needed)
4. **SketchyBar**: Not configured (no action needed)

### Prevention Measures Added
1. **New `--reference-mac` flag** for install script
2. **Safe package list** (`packages-macos-reference.txt`)
3. **Hotkey filtering logic** in install script

## Safe Installation Methods

### Option 1: Reference Mac Installation (Recommended)
```bash
./install.sh --all --reference-mac
```
This will:
- Install only hotkey-safe packages
- Use `packages-macos-reference.txt` instead of full `packages-macos.txt`
- Skip Rectangle, SketchyBar, and other hotkey-affecting packages
- Preserve standard macOS behavior

### Option 2: Selective Installation
```bash
./install.sh zsh git tmux --reference-mac
```
Install only specific packages you need.

### Option 3: Packages Only
```bash
./install.sh --packages --reference-mac
```
Install system packages without dotfiles.

## Packages Considered Safe for Reference Systems

### Core Tools
- `git`, `curl`, `wget`, `stow`, `htop`, `tmux`, `zsh`
- `python3`, `ripgrep`, `fd`, `fzf`, `tree`, `unzip`, `jq`

### Terminal Emulator
- `ghostty` (with custom keybindings disabled in config)

### Development Tools
- `mas` (Mac App Store CLI)

### Packages to Avoid
- `rectangle` - Window manager with system-wide hotkeys
- `sketchybar` - Status bar that registers hotkeys
- Any tools that modify system keyboard shortcuts

## Configuration Changes Made

### ~/.config/ghostty/config
```bash
# Custom keybinds disabled for Mac reference system
# Using standard macOS keybindings instead
# keybind = ctrl+shift+c=copy_to_clipboard
# keybind = ctrl+shift+v=paste_from_clipboard
# keybind = ctrl+shift+n=new_window
# keybind = ctrl+shift+t=new_tab
```

### ~/.zshrc
```bash
# IntelliShell - DISABLED for Mac reference system to prevent hotkey conflicts
# export INTELLI_HOME="/Users/brennon/Library/Application Support/org.IntelliShell.Intelli-Shell"
# export PATH="$INTELLI_HOME/bin:$PATH"
# eval "$(intelli-shell init zsh)"
```

## Verification Steps

After installation, verify standard macOS hotkeys work:

1. **System Hotkeys**
   - `Cmd+Tab` - App switching
   - `Cmd+Space` - Spotlight search
   - `Cmd+C/V/X` - Standard copy/paste/cut
   - `Cmd+Q/W` - Quit/Close applications

2. **Terminal Hotkeys**
   - `Cmd+C/V` - Copy/paste in terminal
   - `Cmd+T/N` - New tab/window in Terminal.app
   - Standard bash/zsh keybindings

3. **Clipboard Functionality**
   ```bash
   echo "test" | pbcopy  # Should work
   pbpaste              # Should return "test"
   ```

## If You Need Hotkey-Enhancing Tools

If you later decide you want window management or other hotkey tools:

1. **Install manually**: `brew install rectangle`
2. **Configure carefully**: Set non-conflicting hotkeys
3. **Use regular install**: `./install.sh --all` (without `--reference-mac`)

## Troubleshooting

### If Hotkeys Still Don't Work
1. Restart the terminal/shell
2. Check System Preferences > Keyboard > Shortcuts
3. Look for conflicting applications in System Settings
4. Check running processes: `ps aux | grep -i rectangle`

### Restoring Changes
If you need to undo our changes:
1. Restore IntelliShell: Uncomment lines in ~/.zshrc
2. Restore Ghostty keybindings: Uncomment keybind lines in ~/.config/ghostty/config
3. Install hotkey tools: `brew install rectangle sketchybar`

## Maintenance

To keep your Mac reference system clean:
- Always use `--reference-mac` flag for installations
- Review new packages before installing
- Test system hotkeys after any major changes