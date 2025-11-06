# VS Code Configuration

This directory contains VS Code settings, extensions, and keybindings managed via GNU Stow.

## Files

- `settings.json` - Editor settings and preferences
- `extensions.txt` - Essential extensions for development
- `keybindings.json` - Custom keyboard shortcuts

## Setup

1. Stow the VS Code configuration:
   ```bash
   cd ~/.dotfiles
   stow vscode
   ```

2. Install extensions:
   ```bash
   # Install all listed extensions
   xargs -a ~/.dotfiles/vscode/extensions.txt code --install-extension

   # Or install manually from the list
   cat ~/.dotfiles/vscode/extensions.txt
   ```

3. Restart VS Code to load the configuration.

## Customization

### Local Settings Override

For machine-specific settings, create a local override file:
```bash
# Create local settings (will not be tracked)
~/.config/Code/User/settings.json
```

### Extensions Management

The `extensions.txt` file contains curated essential extensions. To manage extensions:

```bash
# List installed extensions
code --list-extensions

# Install from file
xargs -a extensions.txt code --install-extension

# Uninstall extension
code --uninstall-extension <extension-id>
```

### Keybindings

Custom keybindings are defined in `keybindings.json`. These focus on:

- Enhanced terminal management
- Improved editor navigation
- Quick file access
- Panel and sidebar management

## Configuration Highlights

- **Auto-format on save** with ESLint and Prettier
- **Smart file nesting** for related files
- **Productivity keybindings** for common actions
- **Excluded patterns** for cleaner search results
- **Security settings** balanced with functionality