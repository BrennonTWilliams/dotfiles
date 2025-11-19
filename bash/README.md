# Bash Configuration

Bash shell configuration files for login shells and fallback shell environments.

## Purpose

This module provides bash configuration primarily for:

- **Login shells** - When bash is used as a login shell
- **Fallback shell** - When zsh is not available
- **Cross-platform compatibility** - Works on both macOS and Linux

**Note:** The primary shell configuration in this dotfiles repository is zsh. These bash files ensure a consistent experience when bash is required.

## Installation

```bash
cd ~/.dotfiles
stow bash
```

## Files

| File | Purpose |
|------|---------|
| `.bash_profile` | Login shell configuration (sourced for login shells) |
| `.bashrc` | Interactive shell configuration (sourced for non-login shells) |
| `.bash_logout` | Commands to run on logout |
| `.profile` | Generic profile for sh-compatible shells |

## Configuration Details

### .bash_profile

The main login shell configuration that:

1. **Initializes Conda** - Cross-platform conda setup with path resolution
2. **Loads platform utilities** - Sources cross-platform utilities if available
3. **Platform-specific enhancements** - Adds macOS or Linux-specific tools
4. **Sources .bashrc** - Ensures interactive settings are loaded
5. **Local overrides** - Sources `~/.bash_profile.local` if present

### Conda Integration

The configuration includes robust conda initialization that:

- Uses cross-platform path resolution when available
- Falls back to traditional path detection
- Supports multiple conda installation locations:
  - `~/miniforge3`
  - `/opt/homebrew/Caskroom/miniforge/base`
  - `/opt/homebrew/bin/conda`

### Cross-Platform Support

The configuration integrates with the zsh cross-platform utilities:

```bash
# Source cross-platform utilities if available
if [[ -f ~/.zsh_cross_platform ]]; then
    source ~/.zsh_cross_platform 2>/dev/null || true
fi
```

This allows the same platform detection and path resolution functions to work in bash.

## Dependencies

- **bash** 4.0+ recommended (macOS ships with older bash)
- **conda/miniforge** (optional) - For conda initialization

### Updating Bash on macOS

macOS ships with an older version of bash. To get bash 5.x:

```bash
brew install bash
# Add to /etc/shells
sudo echo /opt/homebrew/bin/bash >> /etc/shells
# Optionally set as default
chsh -s /opt/homebrew/bin/bash
```

## Customization

### Local Overrides

Create `~/.bash_profile.local` for machine-specific settings:

```bash
# Example: Add company-specific tools
export PATH="$HOME/company-tools/bin:$PATH"

# Example: Set custom environment variables
export COMPANY_ENV="production"
```

Create `~/.bashrc.local` for interactive shell customizations:

```bash
# Example: Custom aliases
alias work="cd ~/work/projects"

# Example: Custom prompt (if not using Starship)
PS1='\u@\h:\w\$ '
```

### IntelliShell Integration

The configuration includes optional IntelliShell support for macOS:

```bash
# Uncomment if IntelliShell is installed
# eval "$(intelli-shell init bash)"
```

**Recommendation:** Use Starship prompt instead of IntelliShell for better cross-platform compatibility.

## Shell Loading Order

Understanding when files are sourced:

1. **Login shell** (e.g., SSH login, terminal login):
   - `.bash_profile` is sourced
   - `.bash_profile` sources `.bashrc`

2. **Non-login interactive shell** (e.g., new terminal tab):
   - `.bashrc` is sourced directly

3. **Non-interactive shell** (e.g., scripts):
   - Neither file is sourced by default

## Integration with Zsh

Since zsh is the primary shell, the bash configuration is designed to:

- Share cross-platform utilities where possible
- Maintain similar environment variables
- Provide consistent PATH setup

## Troubleshooting

### Conda not initializing

1. Verify conda is installed:
   ```bash
   which conda
   ```

2. Check conda paths in `.bash_profile`

3. Run initialization manually:
   ```bash
   eval "$(conda shell.bash hook)"
   ```

### Commands not found

Ensure PATH is set correctly:
```bash
echo $PATH
```

The PATH should include:
- `/usr/local/bin`
- `~/bin` or `~/.local/bin`
- Homebrew paths (macOS)

### Profile not loading

1. Verify file permissions:
   ```bash
   ls -la ~/.bash_profile ~/.bashrc
   ```

2. Check for syntax errors:
   ```bash
   bash -n ~/.bash_profile
   bash -n ~/.bashrc
   ```

## Related Configuration

- **zsh/** - Primary shell configuration
- **starship/** - Cross-platform prompt (works in bash too)

## Notes

- The `.profile` file is kept minimal for sh compatibility
- `.bash_logout` can be customized for cleanup tasks
- Consider using zsh as your primary shell for the full dotfiles experience
