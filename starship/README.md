# Starship Prompt Configuration

A modular Starship prompt configuration system with multiple modes and a build script for generating complete configurations.

## Overview

This directory contains a build system for generating Starship configurations from modular components. Instead of maintaining multiple separate configuration files, common modules are shared and combined with mode-specific overrides.

## Directory Structure

```
starship/
  build-configs.sh       # Build script to assemble configurations
  formats/               # Format string configurations for each mode
    compact-format.toml
    standard-format.toml
    verbose-format.toml
    gruvbox-rainbow-format.toml
  modules/               # Shared module configurations
    core-base.toml       # Character prompt (never overridden)
    core-modules.toml    # Core prompt modules
    core-overridable.toml # Core modules that may be overridden
    language-modules.toml # Programming language support
    container-modules.toml # Docker, Kubernetes, etc.
    platform-modules.toml # Platform-specific modules
    system-modules.toml   # System info (memory, battery, etc.)
    base-modules.toml     # Status and IP modules
    github-modules.toml   # GitHub integration
  modes/                 # Mode-specific overrides and generated configs
    compact.toml         # Generated compact config
    compact-overrides.toml
    standard.toml        # Generated standard config
    standard-overrides.toml
    verbose.toml         # Generated verbose config
    verbose-overrides.toml
    gruvbox-rainbow.toml # Generated gruvbox-rainbow config
    gruvbox-rainbow-overrides.toml
```

## Available Modes

| Mode | Description |
|------|-------------|
| **compact** | Minimal prompt for small terminals or when you want less distraction |
| **standard** | Balanced prompt with essential information |
| **verbose** | Full-featured prompt with detailed system and project information |
| **gruvbox-rainbow** | Colorful Gruvbox-themed prompt with rainbow styling |

## Building Configurations

### Build All Modes

```bash
cd ~/.dotfiles/starship
./build-configs.sh
```

Or explicitly:
```bash
./build-configs.sh build
```

### Clean Generated Files

```bash
./build-configs.sh clean
```

### View Help

```bash
./build-configs.sh help
```

## Build Process

The build script performs these steps for each mode:

1. **Start with header** - Schema reference and generation notice
2. **Add format configuration** - Mode-specific format strings from `formats/`
3. **Analyze overrides** - Determine which modules will be overridden
4. **Add shared modules** - Include all modules from `modules/`, filtering overridden ones
5. **Apply overrides** - Add mode-specific customizations from `modes/*-overrides.toml`
6. **Validate TOML** - Check syntax using Python if available
7. **Install to modes/** - Copy generated config to `modes/` directory

## Using Starship

### Installation

1. Install Starship:
   ```bash
   # macOS
   brew install starship

   # Linux (various methods)
   curl -sS https://starship.rs/install.sh | sh
   ```

2. Build configurations:
   ```bash
   cd ~/.dotfiles/starship
   ./build-configs.sh
   ```

3. Create symlink to desired mode:
   ```bash
   ln -sf ~/.dotfiles/starship/modes/standard.toml ~/.config/starship.toml
   ```

4. Add to your shell rc file:
   ```bash
   # For zsh (~/.zshrc)
   eval "$(starship init zsh)"

   # For bash (~/.bashrc)
   eval "$(starship init bash)"
   ```

### Switching Modes

Use the provided shell functions (if available in your zsh configuration):

```bash
starship-compact        # Switch to compact mode
starship-standard       # Switch to standard mode
starship-verbose        # Switch to verbose mode
starship-gruvbox-rainbow # Switch to gruvbox-rainbow mode
```

Or manually update the symlink:

```bash
ln -sf ~/.dotfiles/starship/modes/verbose.toml ~/.config/starship.toml
```

## Customization

### Adding a New Module

1. Create or edit a module file in `modules/`:
   ```toml
   # modules/my-modules.toml
   [custom.mymodule]
   command = "echo 'Hello'"
   when = "true"
   ```

2. Add the module to the build script's module list in `build_config()`:
   ```bash
   local modules=(
       ...
       "my-modules.toml"
   )
   ```

3. Rebuild configurations:
   ```bash
   ./build-configs.sh
   ```

### Overriding a Module for a Specific Mode

1. Add the override to the appropriate `modes/*-overrides.toml`:
   ```toml
   # modes/verbose-overrides.toml
   [git_status]
   format = '[$all_status$ahead_behind]($style) '
   ```

2. Rebuild configurations:
   ```bash
   ./build-configs.sh
   ```

### Creating a New Mode

1. Create format file: `formats/newmode-format.toml`
2. Create overrides file: `modes/newmode-overrides.toml`
3. Add mode to the `MODES` array in `build-configs.sh`:
   ```bash
   MODES=("compact" "standard" "verbose" "gruvbox-rainbow" "newmode")
   ```
4. Rebuild configurations

## Module Categories

### Core Modules

- **character** - Prompt character (success/error indicator)
- **directory** - Current directory
- **git_branch** - Git branch name
- **git_status** - Git repository status

### Language Modules

Support for various programming languages:
- Node.js, Python, Rust, Go, Java
- Ruby, PHP, Lua, Elixir
- Terraform, Helm, AWS

### Container Modules

- Docker context
- Kubernetes context and namespace
- Nix shell

### System Modules

- Memory usage
- Battery status
- Time
- Username and hostname

### GitHub Modules

- GitHub notifications (requires token)

## Generated File Notice

Generated configuration files include this header:

```toml
# ===================================
# Starship [Mode] Mode Configuration
# ===================================
# Generated by build-configs.sh - DO NOT EDIT DIRECTLY
# Edit the modular components instead and rebuild
```

Always edit the source files in `formats/`, `modules/`, and `modes/`, then rebuild.

## Dependencies

- **starship** - The prompt itself
- **python3** (optional) - For TOML validation during build
- **Nerd Font** (recommended) - For icons in the prompt

## Troubleshooting

### Prompt not showing

1. Ensure Starship is installed: `which starship`
2. Check shell initialization in rc file
3. Verify config file exists: `ls ~/.config/starship.toml`

### Icons not displaying

Install a Nerd Font and configure your terminal to use it.

### Build validation failing

1. Check TOML syntax in source files
2. Ensure no duplicate module definitions
3. Run build with verbose output to see errors

### Module not appearing

1. Ensure the module is in a file listed in the build script
2. Check that the module isn't being filtered out by overrides
3. Verify the module's `disabled` setting isn't `true`

## Related Configuration

- **zsh/** - Shell configuration that initializes Starship
- **bash/** - Alternative shell that can also use Starship
- **ghostty/** - Terminal emulator with Nerd Font support
- **foot/** - Wayland terminal with Nerd Font support

## Resources

- [Starship Documentation](https://starship.rs/config/)
- [Starship Presets](https://starship.rs/presets/)
- [Nerd Fonts](https://www.nerdfonts.com/)
