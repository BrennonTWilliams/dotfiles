# Dotfiles Health Check System

## Overview

The Health Check System provides comprehensive post-installation validation for your dotfiles setup. It ensures cross-platform compatibility, validates configuration integrity, and provides actionable recommendations for maintaining a healthy development environment.

## Features

### 🔍 **Comprehensive Validation**
- **Shell Environment**: Validates Zsh configuration and cross-platform utilities
- **Path Resolution**: Tests dynamic path resolution across 21 path types
- **Core Tools**: Checks essential development tools (git, curl, tmux, starship)
- **Platform-Specific**: Validates macOS and Linux specific configurations
- **Services**: Monitors background services and system integration
- **Performance**: Measures shell startup time and system performance

### 📊 **Detailed Reporting**
- **Health Score**: Overall system health percentage (0-100%)
- **Categorized Results**: Passed, Warning, and Failed checks
- **Actionable Recommendations**: Specific fixes and improvements
- **Performance Metrics**: Startup times and resource usage

### 🚀 **Automated Integration**
- **Post-Installation**: Runs automatically after installation
- **Convenience Commands**: Multiple aliases for easy access
- **CI/CD Ready**: Can be integrated into automated workflows

## Usage

### Quick Health Check
```bash
# Run comprehensive health check
health-check

# Alternative commands
dotfiles-check
system-health
```

### Manual Execution
```bash
# Run health check script directly
./scripts/health-check.sh

# Run with timeout (useful for CI/CD)
timeout 60s ./scripts/health-check.sh
```

### Integration Points

#### Installation Integration
The health check automatically runs after installation:
```bash
# Complete installation with health check
./install-new.sh --all
```

#### Shell Integration
Health check commands are available in your shell:
```bash
# Check current system health
health-check

# Development environment status
dev-status
```

## Health Check Categories

### 1. Shell Environment
- **Default Shell**: Verifies Zsh is the default shell
- **Configuration Files**: Checks .zshrc and cross-platform utilities
- **Path Resolution**: Tests dynamic path resolution functionality

### 2. Core Development Tools
- **Essential Tools**: git, curl, wget, tmux, starship
- **Optional Tools**: neovim, ripgrep, fzf, fd, jq
- **Installation Status**: Reports installed vs missing tools

### 3. Starship Configuration
- **Installation**: Verifies Starship prompt is installed
- **Configuration**: Checks starship.toml exists and is valid
- **Mode Switching**: Tests Starship mode switching functions

### 4. Conda Integration
- **Installation**: Checks Conda package manager
- **Initialization**: Verifies conda initialization in .zshrc
- **Path Integration**: Tests conda path resolution

### 5. Platform-Specific Configuration
- **macOS**: Homebrew installation, macOS-specific aliases
- **Linux**: Distribution detection, package manager integration
- **Cross-Platform**: Platform-agnostic configuration validation

### 6. Dotfiles Symlink Structure
- **Symlink Validation**: Checks proper symlink structure
- **File Integrity**: Verifies configuration files exist
- **Path Consistency**: Ensures links point to correct targets

### 7. Services and Background Processes
- **macOS**: LaunchAgents detection and status
- **Linux**: systemd user services
- **Uniclip**: Clipboard service status

### 8. Performance Metrics
- **Shell Startup Time**: Measures Zsh initialization speed
- **Memory Usage**: System memory monitoring
- **Path Resolution Performance**: Tests resolution function speed

## Health Scoring System

### Score Ranges
- **90-100%**: 🟢 **EXCELLENT** - Optimal configuration
- **75-89%**: 🟡 **GOOD** - Minor issues or optional components missing
- **50-74%**: 🟡 **FAIR** - Some issues that need attention
- **0-49%**: 🔴 **NEEDS ATTENTION** - Critical issues requiring immediate action

### Check Categories
- **✅ Passed**: Component is working correctly
- **⚠️ Warning**: Non-critical issue or optional component
- **❌ Failed**: Critical issue that needs immediate attention

## Troubleshooting

### Common Issues and Solutions

#### Failed: Shell Environment
```bash
# Issue: .zshrc not found
# Solution: Ensure dotfiles are properly installed
./install-new.sh --dotfiles

# Issue: Cross-platform utilities not found
# Solution: Check file permissions and installation
ls -la ~/.zsh_cross_platform
```

#### Failed: Path Resolution
```bash
# Issue: resolve_platform_path function not available
# Solution: Source cross-platform utilities
source ~/.zsh_cross_platform

# Issue: Failed to resolve specific path type
# Solution: Check path type definition in cross-platform utilities
grep -A 5 '"path_type"' ~/.zsh_cross_platform
```

#### Failed: Core Tools
```bash
# Issue: Missing essential tools
# Solution: Install missing tools
dev-install  # Installs all core development tools

# Issue: Specific tool missing
# Solution: Install individual tool
brew install <tool>  # macOS
sudo apt install <tool>  # Linux
```

#### Failed: Starship Configuration
```bash
# Issue: Starship not installed
# Solution: Install Starship
curl -sS https://starship.rs/install.sh | sh

# Issue: Configuration not found
# Solution: Reinstall Starship configuration
./install-new.sh --dotfiles
```

### Performance Issues

#### Slow Shell Startup
```bash
# Profile shell startup time
time zsh -i -c 'echo "Shell started"'

# Check for slow functions in .zshrc
zsh -x -i -c 'exit' 2>&1 | grep -v "^+"
```

#### Slow Path Resolution
```bash
# Test path resolution performance
time for i in {1..100}; do resolve_platform_path "ai_projects" >/dev/null; done

# Optimize by reducing function calls
export AI_PROJECTS_DIR="$(resolve_platform_path "ai_projects")"
```

## Integration Examples

### CI/CD Pipeline
```yaml
# GitHub Actions example
- name: Run dotfiles health check
  run: |
    timeout 60s ./scripts/health-check.sh
    if [ $? -ne 0 ]; then
      echo "Health check failed"
      exit 1
    fi
```

### Automated Maintenance
```bash
# Add to crontab for weekly health checks
0 9 * * 1 cd ~/AIProjects/ai-workspaces/dotfiles && ./scripts/health-check.sh >> ~/dotfiles-health.log 2>&1

# Or use as a systemd timer (Linux)
systemctl --user enable dotfiles-health-check.timer
```

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit
echo "Running dotfiles health check..."
./scripts/health-check.sh --quiet
```

## Customization

### Adding Custom Health Checks

1. **Create custom check function**:
```bash
check_custom_tool() {
    header "Custom Tool Check"

    check_start "Custom tool installation"
    if command -v custom-tool >/dev/null 2>&1; then
        success "Custom tool is installed"
    else
        warn "Custom tool not found (optional)"
    fi
}
```

2. **Add to main execution**:
```bash
# In scripts/health-check.sh main() function
main() {
    # ... existing checks ...
    check_custom_tool
    generate_report
}
```

### Modifying Check Categories

1. **Adjust core tools list**:
```bash
# In scripts/health-check.sh
local core_tools=("git" "curl" "wget" "tmux" "starship" "your-tool")
```

2. **Add new path types**:
```bash
# In zsh/.zsh_cross_platform
"custom_path")
    echo "$(resolve_platform_path "ai_projects")/custom-path"
    ;;
```

## Best Practices

### Regular Maintenance
- **Weekly**: Run `health-check` to monitor system health
- **Monthly**: Review and address any warnings or failed checks
- **After Updates**: Run health check after system or tool updates

### Performance Monitoring
- **Monitor startup time**: Track shell startup performance over time
- **Resource usage**: Keep an eye on memory and CPU usage
- **Path resolution**: Ensure path resolution remains fast

### Documentation Updates
- **Health Check Log**: Maintain a log of health check results
- **Issue Tracking**: Document and track recurring issues
- **Improvement Plan**: Plan and implement based on health check recommendations

## FAQ

**Q: How often should I run health checks?**
A: Run after installation, system updates, or when experiencing issues. Weekly checks are recommended for maintenance.

**Q: Can health checks fix issues automatically?**
A: Health checks identify issues and provide recommendations. Some fixes require manual intervention.

**Q: What's the difference between `health-check` and `dev-status`?**
A: `health-check` provides comprehensive system validation, while `dev-status` focuses on development environment status.

**Q: How do I add new health checks?**
A: Create custom check functions and add them to the main execution flow in the health check script.

**Q: Can health checks run in CI/CD?**
A: Yes, health checks are designed to work in automated environments with proper timeout handling.