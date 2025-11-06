# Git Configuration

This directory contains Git configuration files managed via GNU Stow.

## Files

- `.gitconfig` - Main Git configuration with user settings and aliases
- `.gitignore` - Prevents local configuration files from being committed

## Setup

1. Stow the git configuration:
   ```bash
   cd ~/.dotfiles
   stow git
   ```

2. Update your personal information:
   ```bash
   # Edit the stowed configuration file
   ~/.gitconfig

   # Or create a local override file (recommended)
   ~/.gitconfig.local
   ```

3. Verify configuration:
   ```bash
   git config --global user.name
   git config --global user.email
   ```

## Local Overrides

Create `~/.gitconfig.local` for machine-specific or sensitive settings:

```ini
[user]
    name = Your Actual Name
    email = your.actual.email@example.com

[credential]
    helper = osxkeychain  # macOS
    # helper = manager    # Linux

# GitHub token (if needed)
[github]
    token = your_github_token
```

The local file is automatically included by the main configuration and will not be tracked in version control.