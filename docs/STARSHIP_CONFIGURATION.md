# Starship Prompt Configuration

This guide covers the Starship prompt system configuration, including the recently implemented Nerd Font icons for Git status and the new display mode system.

## Overview

Starship is the primary prompt system used in this dotfiles configuration. It provides a fast, customizable, and informative prompt that works consistently across macOS and Linux environments.

## Features

- **Cross-platform compatibility** (macOS & Linux)
- **Three display modes** (Compact, Standard, Verbose)
- **Nerd Font icons** for better visual appeal
- **Git status indicators** with multiple icon styles
- **Development environment detection**
- **Performance optimized** with 1000ms timeout
- **Modular configuration** with easy customization

## Configuration Files

### Location and Structure

**Main Configuration**: `~/.config/starship.toml` (symlinked from `starship/modes/`)

**Modular Structure**:
```
starship/
├── formats/                    # Format strings only
│   ├── compact-format.toml     # Compact mode format
│   ├── standard-format.toml    # Standard mode format
│   └── verbose-format.toml     # Verbose mode format
├── modules/                    # Shared module configurations
│   ├── core-base.toml          # Character (never overridden)
│   ├── core-overridable.toml   # Core modules (directory, git, etc.)
│   ├── language-modules.toml   # Programming languages
│   ├── container-modules.toml  # Docker, Kubernetes, etc.
│   ├── platform-modules.toml  # Custom platform modules
│   ├── system-modules.toml     # Battery, time, memory
│   └── base-modules.toml       # Status and local IP
├── modes/                      # Mode-specific configurations
│   ├── compact.toml            # Complete compact config
│   ├── standard.toml           # Complete standard config
│   ├── verbose.toml            # Complete verbose config
│   ├── compact-overrides.toml  # Compact mode overrides
│   ├── standard-overrides.toml # Standard mode overrides
│   └── verbose-overrides.toml  # Verbose mode overrides
└── build-configs.sh            # Configuration builder script
```

### Building Configurations

The modular components are assembled into complete configurations using the `build-configs.sh` script:

```bash
# Build all configurations
./build-configs.sh

# Build specific modes (future feature)
./build-configs.sh build

# Clean generated files
./build-configs.sh clean
```

**Note**: The current configurations in `modes/` are the working originals. The build script creates new configurations from the modular components when needed.

### Display Modes

The Starship configuration supports three distinct display modes that can be switched on-demand:

#### 1. Compact Mode 🚀
- **Purpose**: Minimal information for focused work
- **Layout**: Single line with essential information only
- **Content**: Directory + Git branch + Git status + Character
- **Best for**: Development sessions, quick navigation, distraction-free work

#### 2. Standard Mode 📋
- **Purpose**: Balanced information display (default)
- **Layout**: 3-line boxed layout with comprehensive info
- **Content**: User, host, git, languages, containers, tools
- **Best for**: Everyday development, general use

#### 3. Verbose Mode 📊
- **Purpose**: Maximum context and system information
- **Layout**: 5-line layout with ALL available details
- **Content**: Everything from Standard + system info, environment indicators
- **Best for**: System administration, debugging, full context needed

## Git Status Icons

### Available Icon Styles

The configuration includes three distinct Nerd Font icon styles for Git status:

#### 1. Material Design (Default - Active)
- Consistent Material Design Icons
- Clean, modern appearance
- Excellent readability

#### 2. Font Awesome
- Classic Font Awesome icons
- Traditional look and feel
- Wide recognition

#### 3. Minimalist
- Simple line art icons
- Subtle, professional appearance
- Minimal visual noise

### Icon Mappings

| Status | Emoji (Old) | Material Design | Font Awesome | Minimalist |
|--------|-------------|-----------------|--------------|------------|
| Modified | 📝 |  |  |  |
| Added/Staged | ++ | ✓ | ✓ | ✓ |
| Untracked | 🤷 |  |  |  |
| Conflicted | 🏳 |  |  |  |
| Ahead | 🏎💨 |  |  |  |
| Behind | 😰 |  |  |  |
| Diverged | 😵 |  |  |  |
| Stashed | 📦 |  |  |  |
| Renamed | 👅 |  |  |  |
| Deleted | 🗑 |  |  |  |
| Up to Date | ✓ |  |  |  |

## Display Mode Switching

### Quick Commands

The Starship display modes can be switched instantly using shell functions:

```bash
# Switch to Compact Mode
starship-compact    # or sc

# Switch to Standard Mode
starship-standard    # or ss

# Switch to Verbose Mode
starship-verbose     # or sv

# Show Current Mode
starship-mode        # or sm
```

### Command Aliases

For convenience, these aliases are available:
- `sc` → `starship-compact`
- `ss` → `starship-standard`
- `sv` → `starship-verbose`
- `sm` → `starship-mode`

### Mode Switching Examples

```bash
# Check current mode
$ starship-mode
📋 Current mode: STANDARD (current multi-line layout)
Active configuration: /Users/brennon/AIProjects/ai-workspaces/dotfiles/starship/modes/standard.toml

# Switch to compact mode for focused work
$ starship-compact
🚀 Starship mode: COMPACT (minimal information)
Configuration: /Users/brennon/AIProjects/ai-workspaces/dotfiles/starship/modes/compact.toml

# Switch to verbose mode for debugging
$ sv
📊 Starship mode: VERBOSE (full context with all details)
Configuration: /Users/brennon/AIProjects/ai-workspaces/dotfiles/starship/modes/verbose.toml
```

### Configuration File Structure

The starship configuration uses a modular structure with separate mode files:

```
starship/
├── modes/                  # Complete mode configurations
│   ├── compact.toml        # Minimal single-line layout
│   ├── standard.toml       # Balanced multi-line layout (default)
│   ├── verbose.toml        # Maximum information display
│   ├── gruvbox-rainbow.toml # Gruvbox rainbow theme
│   └── *-overrides.toml    # Mode-specific override files
├── modules/                # Shared module configurations
│   ├── core-base.toml
│   ├── language-modules.toml
│   └── ...
├── formats/                # Format configurations
│   ├── compact-format.toml
│   └── ...
└── build-configs.sh        # Configuration builder script
```

The `~/.config/starship.toml` file is a symlink that points to the currently active mode configuration file in the `modes/` directory.

## Switching Between Icon Styles

1. **Open the active mode configuration file:**
   ```bash
   # Edit the mode file you're currently using
   vim ~/.dotfiles/starship/modes/standard.toml
   # or whichever mode you prefer (compact.toml, verbose.toml, gruvbox-rainbow.toml)
   ```

2. **Comment out the current active section:**
   ```toml
   # [git_status]
   # ... current configuration ...
   ```

3. **Uncomment your preferred style:**
   ```toml
   [git_status]
   ... your chosen style configuration ...
   ```

4. **Reload your shell:**
   ```bash
   source ~/.zshrc
   ```

## Custom Icons

### Adding Custom Icons

You can customize individual icons by modifying the active `[git_status]` section:

```toml
[git_status]
format = "([\\[$all_status$ahead_behind\\]]($style) )"
style = "bold red"
# Custom icon examples
conflicted = "⚠️ "
modified = "• "
untracked = "? "
staged = "✓ "
```

### Testing Icons

Use the provided test script to verify icon rendering:

```bash
./scripts/nerd-font-test.sh
```

This script will display all available icon styles and help you verify that your terminal font supports the chosen icons.

## Platform-Specific Modules

Starship includes intelligent platform detection:

### macOS-Specific
- **Terminal Detection**: Shows 👻 Ghostty when running in Ghostty
- **System Information**: Displays macOS-specific details
- **Clipboard Integration**: Optimized for pbcopy/pbpaste

### Linux-Specific
- **Terminal Detection**: Shows 🦶 Foot when running in Foot terminal
- **Window Manager**: Detects Sway window manager
- **Package Managers**: Adapts to local package manager

## Development Environment Indicators

### Language Modules
- **Go**: 🐹 with version detection
- **Python**: 🐍 with virtual environment display
- **Node.js**: 📗 with npm/yarn detection
- **Rust**: 🦀 with Cargo.toml detection
- **Java**: ☕ with Maven/Gradle detection

### Container Tools
- **Docker**: 🐳 context display
- **Kubernetes**: ☸ cluster and namespace
- **Terraform**: 💠 workspace indicator

## Performance Optimization

- **Timeout**: 1000ms command timeout prevents hangs
- **Conditional Display**: Modules only show when relevant
- **Parallel Execution**: Fast module loading
- **Caching**: Smart caching for repeated operations

## Troubleshooting

### Display Mode Issues

#### Mode Not Switching
1. **Check the symlink is correct:**
   ```bash
   ls -la ~/.config/starship.toml
   ```

2. **Verify mode function availability:**
   ```bash
   which starship-compact starship-standard starship-verbose starship-mode
   ```

3. **Manual mode switch:**
   ```bash
   # Switch to compact mode manually
   ln -sf ~/.dotfiles/starship/modes/compact.toml ~/.config/starship.toml
   exec zsh
   ```

#### Configuration Errors
1. **Check syntax validity:**
   ```bash
   starship explain
   ```

2. **Verify file permissions:**
   ```bash
   ls -la ~/.config/starship.toml
   ls -la ~/.dotfiles/starship/modes/
   ```

3. **Reset to standard mode:**
   ```bash
   starship-standard
   ```

### Icons Not Displaying

1. **Check your terminal font:**
   ```bash
   echo $TERM
   fc-list | grep -i "iosevka"
   ```

2. **Verify Nerd Font installation:**
   ```bash
   ./scripts/nerd-font-test.sh
   ```

3. **Ensure Ghostty is using correct font:**
   - Check `ghostty/.config/ghostty/config`
   - Verify `font-family = IosevkaTerm Nerd Font`

### Prompt Not Updating

1. **Reload Starship:**
   ```bash
   starship preset reset
   exec zsh
   ```

2. **Check configuration syntax:**
   ```bash
   starship explain
   ```

3. **Verify configuration file:**
   ```bash
   starship config --help
   ```

### Performance Issues

1. **Increase timeout for slow commands:**
   ```toml
   command_timeout = 2000
   ```

2. **Disable unused modules:**
   ```toml
   [battery]
   disabled = true
   ```

## Advanced Customization

### Custom Modules

Add custom modules to the configuration:

```toml
[custom.weather]
command = "curl wttr.in?format=3"
when = "true"
format = "[$output]($style) "
style = "bold blue"
```

### Conditional Display

Use conditions for smart module display:

```toml
[custom.aws_profile]
command = "echo $AWS_PROFILE"
when = "[[ -n $AWS_PROFILE ]]"
format = "[🔐 AWS: $output]($style) "
style = "bold yellow"
```

## Integration with Other Tools

### Tmux Integration
Starship works seamlessly with tmux statusbar configuration.

### Git Integration
Advanced Git status detection including:
- Branch tracking
- Stash count
- Remote sync status
- Worktree detection

### Editor Integration
Vim/Neovim mode detection and cursor style changes.

## Maintenance

### Regular Updates
```bash
# Update Starship
brew upgrade starship  # macOS
sudo apt upgrade starship  # Linux

# Test configuration
starship explain
```

### Backup Configuration
The original emoji configuration is preserved as comments in the file for easy rollback.

### Performance Monitoring
Use `starship explain` to diagnose slow modules and optimize configuration.

## Modular Configuration Customization

### Understanding the Structure

The modular configuration system separates concerns to make maintenance easier:

- **Formats**: Only contain format strings and basic settings
- **Modules**: Reusable component configurations
- **Overrides**: Mode-specific customizations that override module defaults

### Adding New Modules

To add a new shared module:

1. **Create the module file** in `modules/`:
   ```bash
   # Example: modules/aws-modules.toml
   [custom.aws_region]
   command = "aws configure get region"
   when = "[[ -n $AWS_PROFILE ]]"
   format = "[🌍 $output]($style) "
   style = "bold yellow"
   ```

2. **Reference it in format files**:
   ```toml
   # formats/verbose-format.toml
   format = """...$custom.aws_region..."""
   ```

3. **Build new configurations**:
   ```bash
   ./build-configs.sh
   ```

### Customizing Existing Modules

#### Method 1: Direct Module Editing
Edit the module file directly for changes that affect all modes:
```bash
# Edit language modules
vim modules/language-modules.toml
```

#### Method 2: Mode-Specific Overrides
Add mode-specific customizations without affecting other modes:
```bash
# Edit compact overrides only
vim modes/compact-overrides.toml
```

### Working with the Build System

The build system assembles configurations from components:

```bash
# Build all configurations from scratch
./build-configs.sh build

# Clean generated files
./build-configs.sh clean

# Get help
./build-configs.sh help
```

### Manual Configuration (Fallback)

If the build system has issues, you can edit the complete configurations directly:
- `modes/compact.toml` - Complete compact configuration
- `modes/standard.toml` - Complete standard configuration
- `modes/verbose.toml` - Complete verbose configuration

**Note**: Manual edits to complete configurations will be overwritten when running the build system.

## Resources

- [Official Starship Documentation](https://starship.rs/config/)
- [Nerd Font Documentation](https://www.nerdfonts.com/)
- [Iosevka Font Family](https://be5invis.github.io/Iosevka/)
- [Ghostty Terminal](https://ghostty.org/)
- [TOML Documentation](https://toml.io/en/)