# Ghostty Finder Integration Guide

## Overview

This guide provides comprehensive instructions for integrating Ghostty terminal with macOS Finder, enabling quick terminal access from any folder. Multiple integration methods are covered, from built-in macOS Services to custom Automator workflows.

## Table of Contents

1. [Built-in Finder Services](#built-in-finder-services)
2. [Keyboard Shortcut Setup](#keyboard-shortcut-setup)
3. [Custom Automator Quick Actions](#custom-automator-quick-actions)
4. [Third-Party Alternatives](#third-party-alternatives)
5. [Troubleshooting](#troubleshooting)
6. [Advanced Configuration](#advanced-configuration)

---

## Built-in Finder Services

Ghostty includes native macOS Services integration that allows you to open terminal windows directly from Finder.

### Features

- **New Ghostty Window Here**: Opens a new Ghostty window in the selected folder
- **New Ghostty Tab Here**: Opens a new tab in the existing Ghostty window
- Available via right-click context menu
- Supports keyboard shortcuts
- Works with single or multiple folder selections

### Activation Steps

#### 1. Enable Services in Finder

Ghostty's services are automatically available after installation. To use them:

1. **In Finder**, navigate to any folder
2. **Right-click** (or Control+click) on a folder or within the folder window
3. Navigate to **Services** submenu
4. Select **"New Ghostty Window Here"** or **"New Ghostty Tab Here"**

#### 2. First-Time Permissions

When using Finder Services for the first time, you may need to grant permissions:

**System Settings → Privacy & Security → Automation**
- Ensure **Finder** is allowed to control **Ghostty**
- Toggle the switch if needed and restart Finder

**System Settings → Privacy & Security → Accessibility**
- Add **Ghostty** to the list if not present
- Enable the checkbox for Ghostty

### Usage Methods

#### Via Context Menu

**Method 1: Folder Selection**
```
1. Right-click a folder in Finder
2. Services → New Ghostty Window Here
3. Ghostty opens with the folder as working directory
```

**Method 2: Inside Folder**
```
1. Open a folder in Finder
2. Right-click in empty space (not on a file)
3. Services → New Ghostty Tab Here
4. New tab opens in current window
```

**Method 3: Finder Toolbar**
```
1. Navigate to desired folder
2. Use keyboard shortcut (configured below)
3. Terminal opens instantly
```

---

## Keyboard Shortcut Setup

Configure system-wide keyboard shortcuts for instant terminal access from any Finder window.

### Configuration Steps

#### 1. Open Keyboard Shortcuts

```
System Settings → Keyboard → Keyboard Shortcuts → Services
```

#### 2. Locate Ghostty Services

Navigate to the **Files and Folders** section and find:
- `New Ghostty Window Here`
- `New Ghostty Tab Here`

#### 3. Assign Shortcuts

Click on the service and assign your preferred shortcut:

**Recommended Shortcuts:**
```
New Ghostty Window Here: ⌘⌥T (Cmd+Opt+T)
New Ghostty Tab Here:    ⌘⌥⇧T (Cmd+Opt+Shift+T)
```

**Alternative Shortcuts:**
```
New Ghostty Window Here: ⌃⌥T (Ctrl+Opt+T)
New Ghostty Tab Here:    ⌃⌥⇧T (Ctrl+Opt+Shift+T)
```

#### 4. Verify Configuration

1. Open Finder and navigate to any folder
2. Press your assigned keyboard shortcut
3. Ghostty should open with the folder as working directory

### Shortcut Activation

If shortcuts don't work immediately:
1. **Trigger service manually once** from Services menu
2. **Restart Finder**: `killall Finder` in terminal
3. **Log out and log back in** to refresh keyboard shortcuts
4. **Check for conflicts** in System Settings → Keyboard → Keyboard Shortcuts

---

## Custom Automator Quick Actions

For enhanced workflow integration, create custom Automator Quick Actions with additional functionality.

### Creating a Quick Action

#### 1. Launch Automator

```bash
open -a Automator
```

Select **Quick Action** as document type.

#### 2. Configure Workflow Settings

At the top of the workflow:
- **Workflow receives current**: `files or folders`
- **in**: `Finder`
- **Image**: Choose terminal icon (optional)
- **Color**: Choose color (optional)

#### 3. Add Run AppleScript Action

Search for "Run AppleScript" and drag it to the workflow.

#### 4. AppleScript Code

Replace the default code with:

**For New Window:**
```applescript
on run {input, parameters}
    tell application "Finder"
        if (count of input) > 0 then
            set currentPath to POSIX path of (item 1 of input as alias)
        else
            set currentPath to POSIX path of (target of front window as alias)
        end if
    end tell

    tell application "Ghostty"
        activate
        do script "cd " & quoted form of currentPath
    end tell

    return input
end run
```

**For New Tab (Advanced):**
```applescript
on run {input, parameters}
    tell application "Finder"
        if (count of input) > 0 then
            set currentPath to POSIX path of (item 1 of input as alias)
        else
            set currentPath to POSIX path of (target of front window as alias)
        end if
    end tell

    tell application "System Events"
        tell process "Ghostty"
            set frontmost to true
            keystroke "t" using {command down, shift down}
            delay 0.2
        end tell
    end tell

    delay 0.3
    tell application "Ghostty"
        do script "cd " & quoted form of currentPath in front window
    end tell

    return input
end run
```

#### 5. Save Quick Action

1. **File → Save**
2. Name it: `Open Ghostty Here`
3. Location: `~/Library/Services/` (automatic)
4. The Quick Action is immediately available in Finder

### Installing Pre-configured Quick Actions

If using the dotfiles provided Quick Actions:

```bash
# Copy Quick Actions from dotfiles
cp -r ~/dotfiles/ghostty/automator/*.workflow ~/Library/Services/

# Refresh Services menu
killall Finder

# Verify installation
ls -la ~/Library/Services/ | grep -i ghostty
```

### Using Quick Actions

After installation, Quick Actions appear in multiple locations:

**Right-Click Menu:**
- Right-click folder → Quick Actions → Open Ghostty Here

**Finder Toolbar:**
1. View → Customize Toolbar
2. Drag Quick Actions button to toolbar
3. Click to access all Quick Actions

**Touch Bar (if available):**
- Quick Actions appear in Touch Bar context

---

## Third-Party Alternatives

### OpenInTerminal

Professional Finder toolbar integration with support for multiple terminal emulators.

#### Features

- ✓ Finder toolbar button
- ✓ Multiple terminal support (Ghostty, iTerm2, Terminal, etc.)
- ✓ Text editor integration
- ✓ Keyboard shortcuts
- ✓ Dark mode support
- ✓ Active development

#### Installation

**Via Homebrew:**
```bash
brew install --cask openinterminal
```

**Manual Installation:**
1. Download from [GitHub Releases](https://github.com/Ji4n1ng/OpenInTerminal/releases)
2. Move to Applications folder
3. Launch and configure

#### Configuration

1. **Launch OpenInTerminal**
2. **Open Preferences**
3. **Terminal Settings**:
   - Select **Ghostty** as default terminal
   - Enable "Open in new window" or "Open in new tab"
4. **Keyboard Shortcuts**:
   - Assign global shortcut (e.g., `⌃⌥T`)
5. **Toolbar Integration**:
   - Drag OpenInTerminal to Finder toolbar
   - Configure appearance and behavior

#### Usage

**Via Toolbar:**
- Click OpenInTerminal button in Finder toolbar
- Ghostty opens in current directory

**Via Keyboard:**
- Press assigned shortcut anywhere in Finder
- Instant terminal access

**Via Context Menu:**
- Right-click folder → Open in Ghostty

### Comparison: Built-in vs OpenInTerminal

| Feature | Built-in Services | OpenInTerminal |
|---------|------------------|----------------|
| Cost | Free | Free |
| Installation | Pre-installed | Separate app |
| Toolbar Button | Via Quick Action | Native |
| Multi-Terminal | Ghostty only | Multiple |
| Keyboard Shortcuts | System Settings | In-app config |
| Visual Polish | Standard macOS | Custom icons |
| Maintenance | Automatic | Manual updates |
| Configuration | System-level | App-level |

**Recommendation:**
- **Built-in Services**: Best for simplicity and system integration
- **OpenInTerminal**: Best for power users with multiple terminals

---

## Troubleshooting

### Services Not Appearing in Finder

**Problem**: Finder Services menu doesn't show Ghostty options

**Solutions:**

1. **Verify Ghostty Installation**:
   ```bash
   ls -la /Applications/Ghostty.app
   open -a Ghostty
   ```

2. **Rebuild Services Database**:
   ```bash
   /System/Library/CoreServices/pbs -flush
   killall Finder
   ```

3. **Check Services Folder**:
   ```bash
   ls -la ~/Library/Services/
   ls -la /System/Library/Services/
   ```

4. **Restart Services**:
   ```bash
   launchctl stop com.apple.pbs
   launchctl start com.apple.pbs
   killall Finder
   ```

### Keyboard Shortcuts Not Working

**Problem**: Assigned shortcuts don't trigger services

**Solutions:**

1. **Check for Conflicts**:
   - System Settings → Keyboard → Keyboard Shortcuts
   - Review all categories for conflicting shortcuts
   - Try alternative key combinations

2. **Enable Service Manually First**:
   ```
   1. Use service once via context menu
   2. Try keyboard shortcut again
   3. Restart Finder if needed
   ```

3. **Verify Accessibility Permissions**:
   ```
   System Settings → Privacy & Security → Accessibility
   → Ensure Ghostty is enabled
   ```

4. **Reset Keyboard Shortcuts**:
   ```bash
   # Backup current shortcuts
   defaults export com.apple.universalaccess ~/shortcuts-backup.plist

   # Reset keyboard shortcuts
   defaults delete com.apple.universalaccess
   killall Finder

   # Reconfigure shortcuts in System Settings
   ```

### Wrong Directory Opens

**Problem**: Ghostty opens in home directory instead of selected folder

**Solutions:**

1. **Verify Selection Method**:
   - Right-click **on** the folder (not inside it) for specific directory
   - Right-click **inside** folder to use current directory

2. **Check Ghostty Configuration**:
   ```bash
   grep "working-directory" ~/.config/ghostty/config

   # Should NOT have static working-directory set
   # Comment out if present:
   # working-directory = /Users/yourusername
   ```

3. **Test with Terminal**:
   ```bash
   # If built-in Terminal works but Ghostty doesn't:
   # Check Ghostty's shell integration
   grep "shell-integration" ~/.config/ghostty/config
   ```

4. **Enable Directory Inheritance**:
   ```bash
   # Ensure in Ghostty config:
   window-inherit-working-directory = true
   ```

### Permission Errors

**Problem**: "Ghostty is not allowed to control Finder" or similar

**Solutions:**

1. **Grant Automation Permissions**:
   ```
   System Settings → Privacy & Security → Automation
   → Finder → Enable Ghostty
   ```

2. **Grant Accessibility Permissions**:
   ```
   System Settings → Privacy & Security → Accessibility
   → Add Ghostty → Enable checkbox
   ```

3. **Reset All Permissions**:
   ```bash
   sudo tccutil reset AppleEvents
   sudo tccutil reset Accessibility

   # Then re-grant permissions in System Settings
   # Restart Ghostty and Finder
   ```

4. **Full Disk Access (if needed)**:
   ```
   System Settings → Privacy & Security → Full Disk Access
   → Add Ghostty → Enable
   ```

### Quick Actions Not Appearing

**Problem**: Custom Automator Quick Actions don't show up

**Solutions:**

1. **Verify Installation Location**:
   ```bash
   ls -la ~/Library/Services/*.workflow
   ```

2. **Check Quick Action Settings**:
   ```
   Open the .workflow file in Automator
   → Verify "Workflow receives current: files or folders in Finder"
   → Save again
   ```

3. **Rebuild Quick Actions**:
   ```bash
   # Clear cache
   rm -rf ~/Library/Caches/com.apple.Automator/

   # Refresh services
   /System/Library/CoreServices/pbs -flush
   killall Finder
   ```

4. **Check System Preferences**:
   ```
   System Settings → Extensions → Finder
   → Ensure Quick Actions are enabled
   ```

---

## Advanced Configuration

### Custom Working Directory Behavior

Modify how Ghostty handles directory opening:

```bash
# In ~/.config/ghostty/config.local

# Always inherit current directory
window-inherit-working-directory = true

# Always start in home directory (override services)
# working-directory = ~/

# Start in project directory
# working-directory = ~/Projects
```

### Multiple Quick Actions

Create variations for different workflows:

1. **Open in New Window (Always)**
2. **Open in New Tab (If Window Exists)**
3. **Open and Run Command** (e.g., git status)
4. **Open with Specific Profile**

**Example: Open and Run Git Status**
```applescript
on run {input, parameters}
    tell application "Finder"
        set currentPath to POSIX path of (target of front window as alias)
    end tell

    tell application "Ghostty"
        activate
        do script "cd " & quoted form of currentPath & " && git status"
    end tell

    return input
end run
```

### Integration with Keyboard Maestro

For power users with Keyboard Maestro:

1. **Create New Macro**
2. **Trigger**: Keyboard shortcut (e.g., ⌃⌥T)
3. **Condition**: Front application is Finder
4. **Action**: Execute AppleScript
   ```applescript
   tell application "Finder"
       set currentPath to POSIX path of (target of front window as alias)
   end tell

   tell application "Ghostty"
       activate
       do script "cd " & quoted form of currentPath
   end tell
   ```

### Shell Integration Scripts

Create custom shell functions for reverse integration:

```bash
# In ~/.zshrc

# Open Finder at current directory
alias finder='open -a Finder .'

# Open Finder at specific path
function findercd() {
    open -a Finder "${1:-.}"
}

# Reveal current directory in Finder
function reveal() {
    open -R "${1:-.}"
}
```

---

## Best Practices

### Recommended Workflow

1. **Use Built-in Services** for basic terminal access
2. **Assign Keyboard Shortcuts** for frequent use
3. **Install OpenInTerminal** if managing multiple terminals
4. **Create Custom Quick Actions** for specialized workflows

### Performance Considerations

- **Services are lightweight**: No performance impact
- **Quick Actions execute instantly**: Minimal overhead
- **Third-party apps**: Small memory footprint (~50MB)

### Security Considerations

- **Grant only necessary permissions**: Automation and Accessibility
- **Review AppleScript code**: Understand what Quick Actions do
- **Use official apps**: Avoid unverified third-party tools

---

## Quick Reference

### Enabling Built-in Services

```bash
# 1. Verify Ghostty is installed
open -a Ghostty

# 2. Rebuild services database
/System/Library/CoreServices/pbs -flush
killall Finder

# 3. Configure shortcuts
# System Settings → Keyboard → Keyboard Shortcuts → Services
# → Files and Folders → New Ghostty Window Here
# → Assign: ⌘⌥T
```

### Installing Quick Actions

```bash
# Install from dotfiles
cp -r ~/dotfiles/ghostty/automator/*.workflow ~/Library/Services/

# Refresh
/System/Library/CoreServices/pbs -flush
killall Finder

# Verify
ls -la ~/Library/Services/
```

### Installing OpenInTerminal

```bash
# Install via Homebrew
brew install --cask openinterminal

# Configure
open -a OpenInTerminal
# Set Ghostty as default terminal in preferences
```

### Permission Checklist

- [ ] System Settings → Privacy & Security → Automation → Finder → Ghostty
- [ ] System Settings → Privacy & Security → Accessibility → Ghostty
- [ ] System Settings → Extensions → Finder → Quick Actions enabled
- [ ] Test with right-click → Services → New Ghostty Window Here

---

## Related Documentation

- [Ghostty README](../ghostty/README.md) - Main Ghostty configuration guide
- [Ghostty Troubleshooting](./GHOSTTY_TROUBLESHOOTING.md) - Comprehensive troubleshooting
- [Main README](../README.md) - Overall dotfiles documentation
- [macOS Setup](../macos-setup.md) - macOS environment configuration

---

**Last Updated**: November 11, 2025
**Version**: Compatible with Ghostty v1.2.0+ on macOS 12+
**Maintainer**: Dotfiles Project
**License**: MIT
