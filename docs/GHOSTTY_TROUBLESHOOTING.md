# Ghostty Troubleshooting Guide

## Overview

This guide provides comprehensive troubleshooting steps for Ghostty terminal emulator issues on macOS. It covers common problems, their causes, and step-by-step solutions.

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Configuration Problems](#configuration-problems)
3. [Performance Issues](#performance-issues)
4. [Display and Rendering Issues](#display-and-rendering-issues)
5. [Shell Integration Problems](#shell-integration-problems)
6. [Keybinding Issues](#keybinding-issues)
7. [Font and Text Rendering](#font-and-text-rendering)
8. [macOS-Specific Issues](#macos-specific-issues)
9. [Testing and Validation](#testing-and-validation)
10. [Advanced Troubleshooting](#advanced-troubleshooting)

---

## Installation Issues

### Ghostty Not Found in PATH

**Problem**: `command not found: ghostty`

**Solutions**:
1. **Verify Installation**:
   ```bash
   brew list | grep ghostty
   ls -la /opt/homebrew/bin/ghostty
   ```

2. **Check PATH Configuration**:
   ```bash
   echo $PATH | grep -o "/opt/homebrew/bin"
   ```

3. **Reinstall if Necessary**:
   ```bash
   brew reinstall ghostty
   ```

4. **Verify Shell Configuration**:
   ```bash
   grep -n "eval.*brew" ~/.zshrc
   source ~/.zshrc
   ```

### Application Won't Launch

**Problem**: Ghostty app doesn't open when clicked or launched from terminal

**Solutions**:
1. **Check App Installation**:
   ```bash
   ls -la /Applications/Ghostty.app
   ```

2. **Verify Permissions**:
   ```bash
   sudo xattr -r -d com.apple.quarantine /Applications/Ghostty.app
   ```

3. **Check Security Settings**:
   - System Settings > Privacy & Security
   - Allow apps downloaded from: App Store and identified developers

4. **Restart After Security Changes**:
   ```bash
   # If you just allowed the app, restart it
   killall Ghostty 2>/dev/null || true
   open -a Ghostty
   ```

---

## Configuration Problems

### Configuration Not Applied

**Problem**: Changes to config file don't take effect

**Solutions**:
1. **Verify Config Location**:
   ```bash
   ls -la ~/.config/ghostty/config
   ```

2. **Check Symlink Status**:
   ```bash
   readlink ~/.config/ghostty/config
   ```

3. **Redeploy Configuration**:
   ```bash
   cd ~/dotfiles
   stow -D ghostty  # Remove existing
   stow ghostty      # Re-deploy
   ```

4. **Validate Config Syntax**:
   ```bash
   ./tests/test_ghostty_config_validation.sh
   ```

### Local Config Not Working

**Problem**: `config.local` overrides are ignored

**Solutions**:
1. **Local Config Support**:
   ```bash
   # Ghostty automatically loads config.local if it exists
   ls ~/.config/ghostty/config.local
   ```

2. **Create Local Config**:
   ```bash
   cp ghostty/.config/ghostty/config.local.template ~/.config/ghostty/config.local
   ```

3. **Test Local Config**:
   ```bash
   echo "font-size = 20" >> ~/.config/ghostty/config.local
   # Restart Ghostty to verify
   ```

---

## Performance Issues

### Slow Rendering or Lag

**Problem**: Ghostty feels sluggish, especially with large output

**Solutions**:
1. **Check Performance Settings**:
   ```bash
   # Ghostty automatically handles GPU acceleration
   grep -E "^background-opacity|^background-blur" ~/.config/ghostty/config
   ```

2. **Optimize for Older Macs**:
   ```bash
   # Add to config.local
   echo "background-blur = 0" >> ~/.config/ghostty/config.local
   ```

3. **Reduce Visual Effects**:
   ```bash
   # Add to config.local for older Macs
   cat >> ~/.config/ghostty/config.local << EOF
   background-blur = 0
   background-opacity = 1.0
   EOF
   ```

4. **Monitor Resource Usage**:
   ```bash
   # Check memory usage
   ps aux | grep -i ghostty
   # Check GPU usage
   system_profiler SPDisplaysDataType | grep "Metal"
   ```

### High Memory Usage

**Problem**: Ghostty consumes excessive memory

**Solutions**:
1. **Adjust Scrollback Buffer**:
   ```bash
   grep "scroll-limit" ~/.config/ghostty/config
   # Reduce if too large
   sed -i.bak 's/scroll-limit = .*/scroll-limit = 5000/' ~/.config/ghostty/config
   ```

2. **Disable Unnecessary Features**:
   ```bash
   # Add to config.local
   cat >> ~/.config/ghostty/config.local << EOF
   background-blur = 0
   font-ligatures = false
   subpixel-positioning = false
   EOF
   ```

---

## Display and Rendering Issues

### Font Rendering Problems

**Problem**: Text looks blurry, pixelated, or incorrect

**Solutions**:
1. **Check Font Installation**:
   ```bash
   fc-list | grep -i "iosevka"
   # If not found, install font
   brew tap homebrew/cask-fonts
   brew install font-iosevka-nerd-font
   ```

2. **Test Font Settings**:
   ```bash
   # Ghostty automatically handles font rendering
   # Test different font sizes in config.local
   echo "font-size = 16" >> ~/.config/ghostty/config.local
   ```

3. **Verify Font Configuration**:
   ```bash
   grep "font-family" ~/.config/ghostty/config
   # Should use SF Mono for macOS
   ```

4. **Restart Ghostty After Font Changes**:
   ```bash
   # Font changes require restart
   killall Ghostty 2>/dev/null || true
   open -a Ghostty
   ```

### Color Scheme Issues

**Problem**: Colors look wrong or don't match theme

**Solutions**:
1. **Verify Theme Configuration**:
   ```bash
   grep "^theme = " ~/.config/ghostty/config
   # Should be: theme = Gruvbox Dark
   ```

2. **Test Theme Loading**:
   ```bash
   # Ghostty automatically loads theme colors
   # Restart to see theme changes
   killall Ghostty 2>/dev/null || true
   open -a Ghostty
   ```

3. **Test Custom Colors**:
   ```bash
   # Add to config.local for testing
   cat >> ~/.config/ghostty/config.local << EOF
   foreground = #ffffff
   background = #000000
   EOF
   ```

### Multi-Monitor Issues

**Problem**: Ghostty windows move or resize incorrectly between monitors

**Solutions**:
1. **Check Window Settings**:
   ```bash
   # Ghostty automatically handles multi-monitor DPI
   grep "window-decoration" ~/.config/ghostty/config
   ```

2. **Adjust Window Settings**:
   ```bash
   # Add to config.local
   cat >> ~/.config/ghostty/config.local << EOF
   window-decoration = true
   background-opacity = 0.95
   EOF
   ```

3. **Check macOS Display Settings**:
   - System Settings > Displays
   - Ensure "Default for display" is selected
   - Check resolution and scaling settings

---

## Shell Integration Problems

### Shell Integration Not Working

**Problem**: Shell integration features don't function

**Solutions**:
1. **Verify Shell Configuration**:
   ```bash
   grep "shell-integration" ~/.config/ghostty/config
   # Should be: shell-integration = zsh
   ```

2. **Check Shell Features**:
   ```bash
   grep "shell-integration-features" ~/.config/ghostty/config
   # Should include: cursor,sudo,title
   ```

3. **Test Terminal Variables**:
   ```bash
   # In Ghostty terminal
   echo $TERM_PROGRAM
   echo $TERM_PROGRAM_VERSION
   ```

### Working Directory Not Inherited

**Problem**: New windows don't open in current directory

**Solutions**:
1. **Enable Directory Inheritance**:
   ```bash
   grep "window-inherit-working-directory" ~/.config/ghostty/config
   # Should be: window-inherit-working-directory = true
   ```

2. **Check Shell Integration**:
   ```bash
   # Test in Ghostty
   cd /tmp
   ghostty --new-window
   # Should open in /tmp
   ```

---

## Keybinding Issues

### Keybindings Not Working

**Problem**: Custom keybindings don't respond

**Solutions**:
1. **Check Keybinding Syntax**:
   ```bash
   grep "keybind = " ~/.config/ghostty/config
   ```

2. **Verify No Conflicts**:
   ```bash
   # Test for conflicts
   grep -E "keybind = ctrl\+[c-vk]=" ~/.config/ghostty/config
   ```

3. **Test Keybinding Format**:
   ```bash
   # Valid format examples:
   # keybind = ctrl+shift+c=copy_to_clipboard
   # keybind = cmd+enter=toggle_fullscreen
   ```

### Copy/Paste Not Working

**Problem**: Clipboard operations fail

**Solutions**:
1. **Check Permissions**:
   - System Settings > Privacy & Security > Accessibility
   - Ensure Ghostty is listed and enabled

2. **Verify Clipboard Settings**:
   ```bash
   grep -E "clipboard-(read|write)" ~/.config/ghostty/config
   # Should be "allow" for both read and write
   ```

3. **Test with Different Keybindings**:
   ```bash
   # Add to config.local
   cat >> ~/.config/ghostty/config.local << EOF
   keybind = cmd+shift+c=copy_to_clipboard
   keybind = cmd+shift+v=paste_from_clipboard
   EOF
   ```

---

## Font and Text Rendering

### Nerd Font Icons Not Displaying

**Problem**: Nerd Font symbols show as boxes or question marks

**Solutions**:
1. **Verify Font Installation**:
   ```bash
   fc-list | grep -i "nerd" | head -5
   ```

2. **Install Missing Fonts**:
   ```bash
   brew install font-iosevka-nerd-font
   # Or download from https://www.nerdfonts.com/
   ```

3. **Clear Font Cache**:
   ```bash
   fc-cache -fv
   # Restart Ghostty
   ```

4. **Test Font in Terminal**:
   ```bash
   echo "   "  # Should show nerd font icons
   ```

### Font Size Issues

**Problem**: Text is too small or too large

**Solutions**:
1. **Adjust Base Font Size**:
   ```bash
   grep "font-size = " ~/.config/ghostty/config
   # Edit as needed (12-20 is typical range)
   ```

2. **Use Dynamic Sizing**:
   ```bash
   # Test keybindings in Ghostty:
   # Ctrl+Plus  : Increase font size
   # Ctrl+Minus : Decrease font size
   # Ctrl+0     : Reset font size
   ```

3. **Configure Per-Monitor Settings**:
   ```bash
   # Add to config.local for specific displays
   cat >> ~/.config/ghostty/config.local << EOF
   # For 4K/Retina displays
   font-size = 16
   background-opacity = 0.9
   EOF
   ```

---

## macOS-Specific Issues

### Permission Errors

**Problem**: Ghostty can't access clipboard or files

**Solutions**:
1. **Check Accessibility Permissions**:
   - System Settings > Privacy & Security > Accessibility
   - Add Ghostty if not present

2. **Check Full Disk Access**:
   - System Settings > Privacy & Security > Full Disk Access
   - Add Ghostty if needed for advanced features

3. **Reset Permissions**:
   ```bash
   # Remove and re-add permissions
   sudo tccutil reset All com.mitchellh.ghostty
   # Then re-enable in System Settings
   ```

### Integration with macOS Services

**Problem**: macOS services don't work in Ghostty

**Solutions**:
1. **Enable Services Integration**:
   ```bash
   grep -E "macos-.*" ~/.config/ghostty/config
   ```

2. **Check Service Menu**:
   - In Ghostty: Ghostty > Services
   - Should show available macOS services

3. **Test Clipboard Integration**:
   ```bash
   # Test pbcopy/pbpaste
   echo "test" | pbcopy
   pbpaste
   # Should output: test
   ```

### Finder Integration Not Working

**Problem**: Finder Services or Quick Actions for Ghostty don't appear or work

**Solutions**:
1. **Verify Services Are Installed**:
   ```bash
   # Check for Quick Actions
   ls -la ~/Library/Services/ | grep -i ghostty

   # Rebuild services database
   /System/Library/CoreServices/pbs -flush
   killall Finder
   ```

2. **Check Permissions**:
   ```bash
   # Required permissions:
   # System Settings → Privacy & Security → Automation
   # → Enable: Finder → Ghostty

   # System Settings → Privacy & Security → Accessibility
   # → Add and enable Ghostty
   ```

3. **Install Quick Actions**:
   ```bash
   # Install from dotfiles
   ./ghostty/automator/install-quick-actions.sh

   # Verify installation
   ./ghostty/automator/install-quick-actions.sh --verify
   ```

4. **Test Finder Service**:
   - In Finder, right-click on a folder
   - Navigate to Services (or Quick Actions)
   - Look for "New Ghostty Window Here"
   - If not found, restart Finder and try again

5. **Keyboard Shortcut Not Working**:
   ```bash
   # Assign in System Settings:
   # Keyboard → Keyboard Shortcuts → Services
   # → Files and Folders → New Ghostty Window Here
   # → Click and assign ⌘⌥T or similar

   # Important: Use service manually once first
   # Then keyboard shortcut should work
   ```

6. **Wrong Directory Opens**:
   ```bash
   # Check Ghostty config
   grep "working-directory" ~/.config/ghostty/config

   # Comment out if set to static path:
   # working-directory = /Users/brennon

   # Ensure directory inheritance is enabled:
   window-inherit-working-directory = true
   ```

**See Also**: [Finder Integration Guide](./GHOSTTY_FINDER_INTEGRATION.md) for comprehensive setup instructions

---

## Testing and Validation

### Run Diagnostic Tests

**Built-in Test Scripts**:
```bash
# Configuration validation
./tests/test_ghostty_config_validation.sh

# Shell integration tests
./tests/test_ghostty_shell_integration.sh

# Full macOS integration test
./tests/test_macos_integration.sh
```

### Manual Validation Steps

**Basic Functionality**:
```bash
# 1. Launch Ghostty
ghostty

# 2. Test shell integration
echo $TERM_PROGRAM  # Should show "ghostty"

# 3. Test completion
ghostty <Tab><Tab>  # Should show available options

# 4. Test keybindings
# Ctrl+Shift+C/V for copy/paste
# Ctrl+Shift+N/T for new windows/tabs
```

**Advanced Features**:
```bash
# 1. Test tmux integration
# Use Ctrl+Shift+T keybindings

# 2. Test working directory inheritance
cd /tmp && ghostty --new-window

# 3. Test clipboard
echo "test" | pbcopy && ghostty -e "pbpaste"
```

---

## Advanced Troubleshooting

### Debug Mode

**Enable Debug Logging**:
```bash
# Ghostty automatically handles debugging
# Use built-in validation instead
ghostty +validate-config
```

### Performance Profiling

**Monitor Resource Usage**:
```bash
# CPU usage
top -pid $(pgrep Ghostty)

# Memory usage
ps aux | grep Ghostty

# GPU usage (if available)
sudo powermetrics --samplers gpu_power -i 1000
```

### Configuration Reset

**Reset to Defaults**:
```bash
# Backup current config
cp ~/.config/ghostty/config ~/.config/ghostty/config.backup

# Remove local overrides
rm ~/.config/ghostty/config.local

# Redeploy default config
cd ~/dotfiles
stow -D ghostty
stow ghostty
```

### Getting Help

**Collect Diagnostic Information**:
```bash
# System info
system_profiler SPSoftwareDataType
system_profiler SPDisplaysDataType

# Ghostty info
ghostty --version
ghostty --help

# Config info
cat ~/.config/ghostty/config
ls -la ~/.config/ghostty/

# Shell info
echo $SHELL
echo $TERM
zsh --version
```

**Community Resources**:
- Ghostty GitHub Issues: https://github.com/mitchellh/ghostty/issues
- Ghostty Discord Community
- macOS terminal forums

---

## Quick Reference

### Common Commands
```bash
# Install/Reinstall
brew install ghostty
brew reinstall ghostty

# Configuration
stow ghostty                           # Deploy config
stow -D ghostty                        # Remove config
cp ~/.config/ghostty/config.local.template ~/.config/ghostty/config.local

# Testing
./tests/test_ghostty_config_validation.sh
./tests/test_ghostty_shell_integration.sh

# Fonts
brew install font-iosevka-nerd-font
fc-cache -fv
```

### Default Keybindings
- `Ctrl+Shift+C/V` - Copy/Paste
- `Ctrl+Shift+N/T` - New window/tab
- System gestures for font size
- Standard tmux keybindings (Ctrl+A) within sessions
- Cmd+Enter for fullscreen (system-level)

### Important Config Locations
- Main config: `~/.config/ghostty/config`
- Local overrides: `~/.config/ghostty/config.local`
- Dotfiles config: `~/dotfiles/ghostty/.config/ghostty/config`
- Template: `~/dotfiles/ghostty/.config/ghostty/config.local.template`

---

**Last Updated**: October 31, 2025
**Version**: Compatible with Ghostty v1.2.3+ on macOS 12+
**Maintainer**: Dotfiles Project