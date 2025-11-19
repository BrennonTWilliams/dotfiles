# Ghostty Automator Quick Actions

## Overview

This directory contains macOS Automator Quick Actions for Finder integration with Ghostty terminal.

## Available Quick Actions

### Open Ghostty Here

Opens a new Ghostty terminal window at the selected folder location or current Finder directory.

**Features:**
- Works with folder selection or current directory
- Activates Ghostty window automatically
- Handles errors gracefully
- Compatible with macOS 12+

## Installation

### Automatic Installation

Run the installation script from the dotfiles root:

```bash
./ghostty/automator/install-quick-actions.sh
```

### Manual Installation

Copy the workflow files to your Services directory:

```bash
# Install all Quick Actions
cp -r "ghostty/automator/"*.workflow ~/Library/Services/

# Refresh Services database
/System/Library/CoreServices/pbs -flush
killall Finder
```

### Verification

Check that the Quick Actions are installed:

```bash
ls -la ~/Library/Services/ | grep -i ghostty
```

## Usage

### Via Context Menu

1. **In Finder**, right-click on a folder or within a folder window
2. Navigate to **Quick Actions** submenu
3. Select **"Open Ghostty Here"**
4. Ghostty opens with the folder as working directory

### Via Keyboard Shortcut

Assign a keyboard shortcut for instant access:

1. **System Settings** → **Keyboard** → **Keyboard Shortcuts** → **Services**
2. Find **"Open Ghostty Here"** under **Files and Folders**
3. Click and assign shortcut (recommended: `⌘⌥T`)
4. Use the shortcut in any Finder window

### Via Finder Toolbar

Add Quick Actions to your Finder toolbar:

1. **View** → **Customize Toolbar** in Finder
2. Drag **Quick Actions** button to toolbar
3. Click button to access all Quick Actions
4. Select **"Open Ghostty Here"** when needed

## Configuration

### Modifying Quick Actions

To customize the behavior:

1. **Open the workflow** in Automator:
   ```bash
   open "ghostty/automator/Open Ghostty Here.workflow"
   ```

2. **Edit the AppleScript** to change behavior:
   - Modify working directory handling
   - Add custom commands to execute
   - Change window/tab behavior

3. **Save** and test in Finder

### Example Customizations

**Run Git Status After Opening:**
```applescript
on run {input, parameters}
    -- [existing code to get currentPath]

    tell application "Ghostty"
        activate
        do script "cd " & quoted form of currentPath & " && git status"
    end tell

    return input
end run
```

**Open in New Tab Instead of Window:**
```applescript
on run {input, parameters}
    -- [existing code to get currentPath]

    tell application "System Events"
        tell process "Ghostty"
            set frontmost to true
            keystroke "t" using {command down, shift down}
        end tell
    end tell

    delay 0.3
    tell application "Ghostty"
        do script "cd " & quoted form of currentPath in front window
    end tell

    return input
end run
```

## Troubleshooting

### Quick Action Doesn't Appear

**Problem:** The Quick Action doesn't show up in Finder context menu

**Solutions:**

1. **Verify Installation:**
   ```bash
   ls -la ~/Library/Services/
   ```

2. **Rebuild Services Cache:**
   ```bash
   /System/Library/CoreServices/pbs -flush
   killall Finder
   ```

3. **Check Permissions:**
   - System Settings → Privacy & Security → Automation
   - Ensure Finder can control Ghostty

### Wrong Directory Opens

**Problem:** Ghostty opens in home directory instead of selected folder

**Solutions:**

1. **Check Ghostty Config:**
   ```bash
   grep "working-directory" ~/.config/ghostty/config
   ```
   Comment out if set to a static path.

2. **Test Selection Method:**
   - Right-click **on** a folder (for that specific folder)
   - Right-click **inside** a folder window (for current directory)

### Permission Errors

**Problem:** "Operation not permitted" or similar errors

**Solutions:**

1. **Grant Automation Permissions:**
   - System Settings → Privacy & Security → Automation
   - Enable Finder → Ghostty

2. **Grant Accessibility Permissions:**
   - System Settings → Privacy & Security → Accessibility
   - Add and enable Ghostty

3. **Restart Services:**
   ```bash
   launchctl stop com.apple.pbs
   launchctl start com.apple.pbs
   killall Finder
   ```

### Keyboard Shortcut Not Working

**Problem:** Assigned keyboard shortcut doesn't trigger the Quick Action

**Solutions:**

1. **Use Service Manually First:**
   - Trigger via context menu once
   - Then try keyboard shortcut

2. **Check for Conflicts:**
   - System Settings → Keyboard → Keyboard Shortcuts
   - Review all categories for conflicts

3. **Restart Finder:**
   ```bash
   killall Finder
   ```

## Uninstallation

To remove the Quick Actions:

```bash
# Remove workflow files
rm -rf ~/Library/Services/"Open Ghostty Here.workflow"

# Refresh Services
/System/Library/CoreServices/pbs -flush
killall Finder
```

## Creating Custom Quick Actions

### Template Structure

Use the existing workflows as templates:

```
YourAction.workflow/
├── Contents/
│   ├── Info.plist       # Service configuration
│   └── document.wflow   # Automator workflow definition
```

### Key Components

**Info.plist:**
- Defines service name and menu item
- Specifies accepted file types
- Configures Finder integration

**document.wflow:**
- Contains the AppleScript logic
- Defines input/output handling
- Configures action parameters

### Development Workflow

1. **Create in Automator:**
   ```bash
   open -a Automator
   ```
   - Select "Quick Action" document type
   - Configure workflow settings
   - Add "Run AppleScript" action
   - Write and test script

2. **Save to Services:**
   - File → Save (automatically goes to ~/Library/Services/)

3. **Test in Finder:**
   - Navigate to a folder
   - Right-click → Quick Actions → Your Action

4. **Export to Dotfiles:**
   ```bash
   cp -r ~/Library/Services/"Your Action.workflow" ~/dotfiles/ghostty/automator/
   ```

## Related Documentation

- [Ghostty Finder Integration Guide](../../docs/GHOSTTY_FINDER_INTEGRATION.md)
- [Ghostty README](../README.md)
- [Ghostty Troubleshooting](../../docs/GHOSTTY_TROUBLESHOOTING.md)

## Support

For issues with:
- **Quick Actions**: See troubleshooting section above
- **Ghostty configuration**: Check main Ghostty documentation
- **macOS Services**: Consult macOS System Settings

---

**Last Updated:** November 11, 2025
**macOS Compatibility:** macOS 12+ (Monterey and later)
**Ghostty Version:** 1.2.0+
