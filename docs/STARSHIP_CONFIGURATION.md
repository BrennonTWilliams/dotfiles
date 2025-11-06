# Starship Prompt Configuration

This guide covers the Starship prompt system configuration, including the recently implemented Nerd Font icons for Git status.

## Overview

Starship is the primary prompt system used in this dotfiles configuration. It provides a fast, customizable, and informative prompt that works consistently across macOS and Linux environments.

## Features

- **Cross-platform compatibility** (macOS & Linux)
- **Nerd Font icons** for better visual appeal
- **Git status indicators** with multiple icon styles
- **Development environment detection**
- **Performance optimized** with 1000ms timeout
- **Modular configuration** with easy customization

## Configuration File

Location: `~/.config/starship.toml` (symlinked from `starship/starship.toml`)

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

## Switching Between Icon Styles

1. **Open the configuration file:**
   ```bash
   vim ~/.config/starship.toml
   # or
   vim starship/starship.toml
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
./nerd-font-test.sh
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

### Icons Not Displaying

1. **Check your terminal font:**
   ```bash
   echo $TERM
   fc-list | grep -i "iosevka"
   ```

2. **Verify Nerd Font installation:**
   ```bash
   ./nerd-font-test.sh
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

## Resources

- [Official Starship Documentation](https://starship.rs/config/)
- [Nerd Font Documentation](https://www.nerdfonts.com/)
- [Iosevka Font Family](https://be5invis.github.io/Iosevka/)
- [Ghostty Terminal](https://ghostty.org/)