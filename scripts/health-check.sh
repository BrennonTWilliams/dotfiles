#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Health Check System
# ==============================================================================
# Comprehensive post-installation validation script for dotfiles setup
# Validates cross-platform compatibility and configuration integrity

set -euo pipefail

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Health check counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNED_CHECKS=0

# ==============================================================================
# Utility Functions
# ==============================================================================

# Override success, warn, and error functions to include counters
success() {
    echo -e "${GREEN}${BOLD}✓${NC} $1"
    ((PASSED_CHECKS++))
}

warn() {
    echo -e "${YELLOW}${BOLD}⚠${NC} $1"
    ((WARNED_CHECKS++))
}

error() {
    echo -e "${RED}${BOLD}✗${NC} $1"
    ((FAILED_CHECKS++))
}

header() {
    echo -e "\n${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}$(printf '=%.0s' {1..50})${NC}"
}

check_start() {
    ((TOTAL_CHECKS++))
    echo -e "Checking: $1..."
}

# ==============================================================================
# Platform Detection
# ==============================================================================

detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

detect_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif command -v lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

# ==============================================================================
# Core System Health Checks
# ==============================================================================

check_shell_environment() {
    header "Shell Environment"

    check_start "Default shell"
    if [[ "$SHELL" == *"zsh"* ]]; then
        success "Zsh is the default shell ($SHELL)"
    else
        warn "Zsh is not the default shell (current: $SHELL)"
    fi

    check_start "Zsh configuration"
    if [[ -f "$HOME/.zshrc" ]]; then
        success ".zshrc exists"
    else
        error ".zshrc not found"
    fi

    check_start "Cross-platform utilities"
    if [[ -f "$HOME/.zsh_cross_platform" ]]; then
        success "Cross-platform utilities found"
    else
        error "Cross-platform utilities not found"
    fi
}

check_path_resolution() {
    header "Path Resolution System"

    # Source the cross-platform utilities if available
    local cross_platform_file="$HOME/.zsh_cross_platform"
    if [[ -f "$cross_platform_file" ]]; then
        # Temporarily source functions for testing
        source "$cross_platform_file"

        local path_types=("ai_projects" "ai_workspaces" "dotfiles" "conda_root"
                        "conda_bin" "conda_profile" "starship_config" "npm_global_bin")

        for path_type in "${path_types[@]}"; do
            check_start "Path resolution for: $path_type"
            if command -v resolve_platform_path >/dev/null 2>&1; then
                local resolved_path
                resolved_path=$(resolve_platform_path "$path_type" 2>/dev/null || echo "")
                if [[ -n "$resolved_path" ]]; then
                    success "Resolved $path_type → $resolved_path"
                else
                    error "Failed to resolve $path_type"
                fi
            else
                error "resolve_platform_path function not available"
            fi
        done
    else
        error "Cross-platform utilities file not found"
    fi
}

check_core_tools() {
    header "Core Development Tools"

    local core_tools=("git" "curl" "wget" "tmux" "starship")
    local optional_tools=("neovim" "ripgrep" "fzf" "fd" "jq")

    for tool in "${core_tools[@]}"; do
        check_start "$tool"
        if command -v "$tool" >/dev/null 2>&1; then
            success "$tool is installed"
        else
            error "$tool is not installed"
        fi
    done

    for tool in "${optional_tools[@]}"; do
        check_start "$tool (optional)"
        if command -v "$tool" >/dev/null 2>&1; then
            success "$tool is installed"
        else
            warn "$tool is not installed (optional)"
        fi
    done
}

check_starship_configuration() {
    header "Starship Prompt Configuration"

    check_start "Starship installation"
    if command -v starship >/dev/null 2>&1; then
        success "Starship is installed"

        check_start "Starship configuration"
        if [[ -f "$HOME/.config/starship.toml" ]]; then
            success "Starship configuration exists"
        else
            error "Starship configuration not found"
        fi

        check_start "Starship mode switching functions"
        local zshrc_file="$HOME/.zshrc"
        if [[ -f "$zshrc_file" ]] && grep -q "starship-" "$zshrc_file"; then
            success "Starship mode switching functions found"
        else
            warn "Starship mode switching functions not found"
        fi
    else
        error "Starship is not installed"
    fi
}

check_conda_integration() {
    header "Conda Integration"

    check_start "Conda installation"
    if command -v conda >/dev/null 2>&1; then
        success "Conda is installed"

        check_start "Conda initialization in .zshrc"
        local zshrc_file="$HOME/.zshrc"
        if [[ -f "$zshrc_file" ]] && grep -q "conda initialize" "$zshrc_file"; then
            success "Conda initialization found in .zshrc"
        else
            warn "Conda initialization not found in .zshrc"
        fi
    else
        warn "Conda is not installed (optional)"
    fi
}

check_platform_specific() {
    header "Platform-Specific Configuration"

    local os=$(detect_os)

    case "$os" in
        "macos")
            check_start "Homebrew"
            if command -v brew >/dev/null 2>&1; then
                success "Homebrew is installed"
            else
                warn "Homebrew is not installed"
            fi

            check_start "macOS-specific aliases"
            local zshrc_file="$HOME/.zshrc"
            if [[ -f "$zshrc_file" ]] && grep -q "show-files\|hide-files" "$zshrc_file"; then
                success "macOS-specific aliases found"
            else
                warn "macOS-specific aliases not found"
            fi
            ;;

        "linux")
            check_start "Package manager detection"
            if [[ -f /etc/os-release ]]; then
                local distro=$(detect_linux_distro)
                success "Linux distribution detected: $distro"
            else
                warn "Linux distribution detection failed"
            fi

            check_start "Linux-specific aliases"
            local zshrc_file="$HOME/.zshrc"
            if [[ -f "$zshrc_file" ]] && grep -q "xdg-open\|pbcopy" "$zshrc_file"; then
                success "Linux-specific aliases found"
            else
                warn "Linux-specific aliases not found"
            fi
            ;;

        *)
            warn "Unsupported or unknown OS: $os"
            ;;
    esac
}

check_dotfiles_symlinks() {
    header "Dotfiles Symlink Structure"

    local dotfiles_dirs=("zsh" "tmux" "starship" "ghostty" "vscode" "git")
    local expected_configs=(
        "$HOME/.zshrc:zsh/.zshrc"
        "$HOME/.tmux.conf:tmux/.tmux.conf"
        "$HOME/.config/starship.toml:starship/starship.toml"
        "$HOME/.config/ghostty/config:ghostty/.config/ghostty/config"
        "$HOME/.config/Code/User/settings.json:vscode/settings.json"
        "$HOME/.gitconfig:git/.gitconfig"
    )

    for config_pair in "${expected_configs[@]}"; do
        local target_path="${config_pair%%:*}"
        local source_path="${config_pair##*:}"

        check_start "Symlink: $(basename "$target_path")"
        if [[ -L "$target_path" ]]; then
            local resolved_link=$(readlink "$target_path")
            if [[ "$resolved_link" == *"$source_path"* ]]; then
                success "Symlink points to correct file"
            else
                warn "Symlink exists but points to unexpected location: $resolved_link"
            fi
        elif [[ -f "$target_path" ]]; then
            warn "File exists but is not a symlink: $target_path"
        else
            warn "File not found: $target_path"
        fi
    done
}

check_services() {
    header "Services and Background Processes"

    local os=$(detect_os)

    case "$os" in
        "macos")
            check_start "LaunchAgents"
            if [[ -d "$HOME/Library/LaunchAgents" ]]; then
                local agent_count=$(find "$HOME/Library/LaunchAgents" -name "*.plist" | wc -l)
                success "$agent_count LaunchAgents found"
            else
                warn "LaunchAgents directory not found"
            fi
            ;;

        "linux")
            check_start "systemd user services"
            if command -v systemctl >/dev/null 2>&1; then
                local service_count=$(systemctl --user list-unit-files --type=service --state=enabled 2>/dev/null | wc -l)
                success "$service_count enabled user services"
            else
                warn "systemd not available"
            fi
            ;;
    esac

    check_start "Uniclip service"
    if command -v uniclip >/dev/null 2>&1; then
        if pgrep -f uniclip >/dev/null 2>&1; then
            success "Uniclip service is running"
        else
            warn "Uniclip is installed but not running"
        fi
    else
        warn "Uniclip is not installed"
    fi
}

check_performance() {
    header "Performance Metrics"

    check_start "Shell startup time"
    local startup_time
    startup_time=$(zsh -i -c 'echo $EPOCHREALTIME' 2>/dev/null || echo "0")
    if [[ "$startup_time" != "0" ]] && [[ "${startup_time%.*}" -lt 2 ]]; then
        success "Shell startup time: ${startup_time}s"
    else
        warn "Shell startup time could not be measured or is slow"
    fi

    check_start "Memory usage"
    if command -v free >/dev/null 2>&1; then
        local mem_info=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
        success "Memory usage: $mem_info"
    elif command -v vm_stat >/dev/null 2>&1; then
        success "Memory monitoring available (vm_stat)"
    else
        warn "Memory usage information not available"
    fi

    check_start "Path resolution performance"
    if [[ -f "$HOME/.zsh_cross_platform" ]]; then
        local start_time=$(date +%s%N)
        source "$HOME/.zsh_cross_platform"
        resolve_platform_path "ai_projects" >/dev/null 2>&1 || true
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds

        if [[ $duration -lt 100 ]]; then
            success "Path resolution: ${duration}ms"
        else
            warn "Path resolution slow: ${duration}ms"
        fi
    fi
}

# ==============================================================================
# Final Report
# ==============================================================================

generate_report() {
    header "Health Check Summary"

    echo -e "Total Checks: ${BOLD}$TOTAL_CHECKS${NC}"
    echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "${YELLOW}Warnings: $WARNED_CHECKS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"

    local success_rate=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        success_rate=$(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))
    fi

    echo -e "\nOverall Health: ${BOLD}"
    if [[ $success_rate -ge 90 ]]; then
        echo -e "${GREEN}EXCELLENT ($success_rate%)${NC}"
    elif [[ $success_rate -ge 75 ]]; then
        echo -e "${YELLOW}GOOD ($success_rate%)${NC}"
    elif [[ $success_rate -ge 50 ]]; then
        echo -e "${YELLOW}FAIR ($success_rate%)${NC}"
    else
        echo -e "${RED}NEEDS ATTENTION ($success_rate%)${NC}"
    fi

    # Recommendations
    echo -e "\n${CYAN}${BOLD}Recommendations:${NC}"
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        echo -e "• Address ${RED}$FAILED_CHECKS failed check(s)${NC} urgently"
    fi
    if [[ $WARNED_CHECKS -gt 0 ]]; then
        echo -e "• Review ${YELLOW}$WARNED_CHECKS warning(s)${NC} when possible"
    fi
    if [[ $success_rate -ge 90 ]]; then
        echo -e "🎉 Your dotfiles setup is in excellent condition!"
    fi

    echo -e "\nQuick fixes:"
    echo -e "• Run 'dev-status' for detailed development environment status"
    echo -e "• Use 'dev-install' to install missing core tools"
    echo -e "• Check individual components with test scripts in tests/"

    return $FAILED_CHECKS
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    echo -e "${CYAN}${BOLD}Dotfiles Health Check System${NC}"
    echo -e "${CYAN}Comprehensive post-installation validation${NC}"
    echo -e "${CYAN}Platform: $(detect_os) $(if [[ "$(detect_os)" == "linux" ]]; then echo "($(detect_linux_distro))"; fi)${NC}"

    # Run all health checks
    check_shell_environment
    check_path_resolution
    check_core_tools
    check_starship_configuration
    check_conda_integration
    check_platform_specific
    check_dotfiles_symlinks
    check_services
    check_performance

    # Generate final report
    generate_report
}

# Execute main function
main "$@"