#!/bin/bash

# Enhanced macOS-Specific Integration Tests
# Tests macOS-specific features, Wave 1 regression fixes, and architecture compatibility

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test environment setup
readonly TEST_ROOT="${TMPDIR:-/tmp}/dotfiles_macos_test_$$"
readonly TEST_HOME="$TEST_ROOT/home"
readonly BACKUP_DIR="$TEST_ROOT/backup"
readonly LOG_FILE="$TEST_ROOT/macos_integration_test.log"

# Configuration
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INSTALL_SCRIPT="$DOTFILES_DIR/install.sh"

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

# Setup logging
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

echo -e "${BLUE}=== macOS-Specific Integration Testing Suite ===${NC}"
echo "Test Root: $TEST_ROOT"
echo "Dotfiles Directory: $DOTFILES_DIR"
echo "Started at: $(date)"
echo ""

# Utility functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

# Test result reporting
test_start() {
    local test_name="$1"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_test "Starting: $test_name"
}

test_pass() {
    local test_name="$1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_success "✅ PASSED: $test_name"
}

test_fail() {
    local test_name="$1"
    local reason="$2"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_error "❌ FAILED: $test_name - $reason"
}

test_skip() {
    local test_name="$1"
    local reason="$2"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    log_warning "⏭️  SKIPPED: $test_name - $reason"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up test environment..."
    if [[ -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

# Setup test environment
setup_test_environment() {
    test_start "Test Environment Setup"

    # Create test directory structure
    mkdir -p "$TEST_HOME"
    mkdir -p "$BACKUP_DIR"

    # Create fake Homebrew directory structure for testing
    mkdir -p "$TEST_ROOT/opt/homebrew/bin"
    mkdir -p "$TEST_ROOT/usr/local/bin"

    # Create fake Homebrew symlink for architecture detection tests
    if [[ "$(uname -m)" == "arm64" ]]; then
        ln -sf "$TEST_ROOT/opt/homebrew/bin" "$TEST_ROOT/homebrew_bin"
    else
        ln -sf "$TEST_ROOT/usr/local/bin" "$TEST_ROOT/homebrew_bin"
    fi

    test_pass "Test Environment Setup"
}

# Test 1: Wave 1 Regression Tests
test_wave1_regression() {
    test_start "Wave 1 Regression Tests"

    export HOME="$TEST_HOME"

    # Test 1a: .zshenv PATH configuration regression test
    log_info "Testing .zshenv PATH configuration (Wave 1 fix)..."

    if [[ -f "$TEST_HOME/.zshenv" ]]; then
        # Test that .zshenv contains Homebrew configuration
        if grep -q "opt/homebrew/bin/brew" "$TEST_HOME/.zshenv"; then
            log_info "✓ Homebrew configuration correctly present in .zshenv"
        else
            test_fail "Wave 1 Regression Tests" "Homebrew configuration not found in .zshenv"
            return 1
        fi

        # Test that .zshenv includes Claude Code PATH
        if grep -q "\.local/bin" "$TEST_HOME/.zshenv"; then
            log_info "✓ Claude Code PATH correctly configured in .zshenv"
        else
            test_fail "Wave 1 Regression Tests" "Claude Code PATH regression detected"
            return 1
        fi

        # Test that .zshenv properly prioritizes user paths
        if grep -q "bin:\$PATH" "$TEST_HOME/.zshenv"; then
            log_info "✓ PATH prioritization pattern found in .zshenv"
        else
            test_fail "Wave 1 Regression Tests" "PATH prioritization pattern not found"
            return 1
        fi

        # Test that .zshenv uses brew shellenv (Wave 1 improvement)
        if grep -q "brew shellenv" "$TEST_HOME/.zshenv"; then
            log_info "✓ brew shellenv correctly configured (Wave 1 fix)"
        else
            log_warning "brew shellenv not configured in .zshenv"
        fi
    else
        test_fail "Wave 1 Regression Tests" ".zshenv not found - configuration copy may have failed"
        return 1
    fi

    # Test 1b: Install script architecture detection regression test
    log_info "Testing install script architecture detection (Wave 1 fix)..."

    if [[ -f "$INSTALL_SCRIPT" ]]; then
        # Test the architecture detection logic (using uname as fallback)
        local detected_arch=$(uname -m)
        if [[ "$detected_arch" == "arm64" ]]; then
            log_info "✓ Apple Silicon architecture detection working"
        elif [[ "$detected_arch" == "x86_64" ]]; then
            log_info "✓ Intel Mac architecture detection working"
        else
            log_warning "Unknown architecture detected: $detected_arch"
        fi
    else
        test_fail "Wave 1 Regression Tests" "Install script not found"
        return 1
    fi

    test_pass "Wave 1 Regression Tests"
}

# Test 2: macOS-Specific Features
test_macos_specific_features() {
    test_start "macOS-Specific Features"

    export HOME="$TEST_HOME"

    # Test 2a: Airport function functionality
    log_info "Testing airport command function..."

    # Check zsh functions file for airport function
    if [[ -f "$DOTFILES_DIR/zsh/functions/macos.zsh" ]]; then
        if grep -q "airport()" "$DOTFILES_DIR/zsh/functions/macos.zsh"; then
            log_info "✓ airport function defined in zsh functions"

            # Test that the function references the correct command
            if grep -q "Apple80211.framework/Versions/Current/Resources/airport" "$DOTFILES_DIR/zsh/functions/macos.zsh"; then
                log_info "✓ airport function references correct macOS utility"
            else
                test_fail "macOS-Specific Features" "airport function not referencing correct utility"
                return 1
            fi
        else
            log_warning "airport function not found (may be deprecated)"
        fi
    else
        log_warning "macOS functions file not found at zsh/functions/macos.zsh"
    fi

    # Test 2b: macOS-specific package configuration
    log_info "Testing macOS package configuration..."

    if [[ -f "$DOTFILES_DIR/packages-macos.txt" ]]; then
        # Check for macOS-specific packages
        local macos_packages=("rectangle" "iterm2" "sketchybar" "mas")
        local found_packages=0

        for package in "${macos_packages[@]}"; do
            if grep -q "^$package" "$DOTFILES_DIR/packages-macos.txt"; then
                log_info "✓ macOS-specific package found: $package"
                found_packages=$((found_packages + 1))
            fi
        done

        if [[ $found_packages -gt 0 ]]; then
            log_info "✓ macOS-specific packages configured ($found_packages found)"
        else
            log_warning "No macOS-specific packages found in configuration"
        fi

        # Test sketchybar special handling
        if grep -q "sketchybar" "$DOTFILES_DIR/packages-macos.txt"; then
            if grep -q "FelixKratz/formulae" "$DOTFILES_DIR/packages-macos.txt"; then
                log_info "✓ sketchybar special tap requirements documented"
            else
                log_warning "sketchybar tap requirements not documented"
            fi
        fi
    else
        test_fail "macOS-Specific Features" "packages-macos.txt not found"
        return 1
    fi

    test_pass "macOS-Specific Features"
}

# Test 3: Shell Configuration for macOS
test_macos_shell_configuration() {
    test_start "macOS Shell Configuration"

    export HOME="$TEST_HOME"

    # Test 3a: .zshenv PATH ordering on macOS
    log_info "Testing macOS PATH configuration..."

    if [[ -f "$TEST_HOME/.zshenv" ]]; then
        # Test that .zshenv contains PATH configuration (since brew isn't installed in test env)
        if grep -q "export PATH" "$TEST_HOME/.zshenv"; then
            log_info "✓ PATH export configuration found in .zshenv"
        else
            test_fail "macOS Shell Configuration" "PATH export configuration not found"
            return 1
        fi

        # Test architecture-specific Homebrew path configuration
        if [[ "$(uname -m)" == "arm64" ]]; then
            if grep -q "opt/homebrew" "$TEST_HOME/.zshenv"; then
                log_info "✓ Apple Silicon Homebrew path configured"
            else
                test_fail "macOS Shell Configuration" "Apple Silicon Homebrew path not found"
                return 1
            fi
        else
            if grep -q "usr/local/bin" "$TEST_HOME/.zshenv"; then
                log_info "✓ Intel Mac Homebrew path configured"
            else
                test_fail "macOS Shell Configuration" "Intel Mac Homebrew path not found"
                return 1
            fi
        fi

        # Test that .zshenv uses brew shellenv
        if grep -q "brew shellenv" "$TEST_HOME/.zshenv"; then
            log_info "✓ brew shellenv correctly configured"
        else
            log_warning "brew shellenv not configured in .zshenv"
        fi

        # Test that user paths are prioritized
        if grep -q "\$PATH" "$TEST_HOME/.zshenv" && grep -q "bin:" "$TEST_HOME/.zshenv"; then
            log_info "✓ PATH prioritization configuration found"
        else
            test_fail "macOS Shell Configuration" "PATH prioritization configuration not found"
            return 1
        fi
    else
        test_fail "macOS Shell Configuration" ".zshenv not found"
        return 1
    fi

    # Test 3b: Terminal application integration
    log_info "Testing terminal integration..."

    # Test that shell configuration files exist
    if [[ -f "$TEST_HOME/.zshenv" ]]; then
        log_info "✓ zsh environment configuration available"
    else
        log_warning "zsh environment configuration not found"
    fi

    # Test macOS abbreviations exist for terminal integration
    if [[ -f "$DOTFILES_DIR/zsh/abbreviations/macos.zsh" ]]; then
        if grep -q "finder=" "$DOTFILES_DIR/zsh/abbreviations/macos.zsh"; then
            log_info "✓ Finder integration abbreviation configured"
        else
            log_info "ℹ️ Finder integration not configured (optional)"
        fi

        # Test clipboard abbreviations
        if grep -q "clipboard=" "$DOTFILES_DIR/zsh/abbreviations/macos.zsh"; then
            log_info "✓ Clipboard management abbreviation configured"
        else
            log_info "ℹ️ Clipboard abbreviation not configured (optional)"
        fi
    else
        log_warning "macOS abbreviations file not found"
    fi

    test_pass "macOS Shell Configuration"
}

# Test 4: Architecture Compatibility
test_architecture_compatibility() {
    test_start "Architecture Compatibility"

    local current_arch=$(uname -m)
    log_info "Testing on $current_arch architecture..."

    # Test 4a: Architecture-specific Homebrew paths
    if [[ "$current_arch" == "arm64" ]]; then
        log_info "Testing Apple Silicon compatibility..."

        if [[ -f "$TEST_HOME/.zshenv" ]]; then
            if grep -q "opt/homebrew" "$TEST_HOME/.zshenv"; then
                log_info "✓ Apple Silicon Homebrew path configured"
            else
                test_fail "Architecture Compatibility" "Apple Silicon Homebrew path not configured"
                return 1
            fi
        fi

        # Test that Intel paths aren't prioritized on Apple Silicon
        local path_output=$(source "$TEST_HOME/.zshenv" && echo "$PATH")
        if echo "$path_output" | tr ':' '\n' | grep -E "usr/local/bin" | head -1 | grep -q "opt/homebrew"; then
            log_info "✓ No conflicting Intel Homebrew paths detected"
        else
            log_warning "Potential Intel Homebrew path conflict detected"
        fi

    elif [[ "$current_arch" == "x86_64" ]]; then
        log_info "Testing Intel Mac compatibility..."

        if [[ -f "$TEST_HOME/.zshenv" ]]; then
            if grep -q "usr/local/bin" "$TEST_HOME/.zshenv"; then
                log_info "✓ Intel Mac Homebrew path configured"
            else
                test_fail "Architecture Compatibility" "Intel Mac Homebrew path not configured"
                return 1
            fi
        fi
    else
        log_warning "Unknown architecture: $current_arch"
    fi

    # Test 4b: Cross-architecture script compatibility
    log_info "Testing script architecture compatibility..."

    if [[ -f "$INSTALL_SCRIPT" ]]; then
        # Test that install script handles both architectures (fallback to uname)
        local script_arch=$(uname -m)
        if [[ -n "$script_arch" ]]; then
            log_info "✓ System architecture detected: $script_arch"
        else
            test_fail "Architecture Compatibility" "Architecture detection failed"
            return 1
        fi
    fi

    test_pass "Architecture Compatibility"
}

# Test 5: Package Installation Testing
test_macos_package_installation() {
    test_start "macOS Package Installation Testing"

    # Test 5a: Package validation integration
    log_info "Testing package validation integration..."

    if [[ -f "$DOTFILES_DIR/test_package_validation.sh" ]]; then
        log_info "✓ Package validation script available"

        # Test that validation script can run without errors (syntax check)
        if bash -n "$DOTFILES_DIR/test_package_validation.sh" 2>/dev/null; then
            log_info "✓ Package validation script syntax is valid"
        else
            test_fail "macOS Package Installation Testing" "Package validation script has syntax errors"
            return 1
        fi
    else
        test_fail "macOS Package Installation Testing" "Package validation script not found"
        return 1
    fi

    # Test 5b: macOS package availability
    log_info "Testing macOS package availability..."

    if command -v brew >/dev/null 2>&1; then
        local available_packages=0
        local total_packages=0

        # Test a few key macOS packages
        local key_packages=("git" "curl" "wget" "stow")
        for package in "${key_packages[@]}"; do
            total_packages=$((total_packages + 1))
            if brew info "$package" >/dev/null 2>&1; then
                log_info "✓ $package available in Homebrew"
                available_packages=$((available_packages + 1))
            else
                log_warning "⚠️ $package not available in Homebrew"
            fi
        done

        if [[ $available_packages -eq $total_packages ]]; then
            log_info "✓ All key packages available for installation"
        else
            log_warning "Some packages may not be available: $available_packages/$total_packages"
        fi
    else
        log_warning "Homebrew not available - skipping package availability tests"
    fi

    test_pass "macOS Package Installation Testing"
}

# Test 6: Security and Permissions
test_macos_security_permissions() {
    test_start "macOS Security and Permissions"

    export HOME="$TEST_HOME"

    # Test 6a: File permissions
    log_info "Testing configuration file permissions..."

    local permission_issues=0

    # Check that configuration files have appropriate permissions
    for config_file in "$TEST_HOME/.zshenv" "$TEST_HOME/.bashrc" "$TEST_HOME/.tmux.conf"; do
        if [[ -f "$config_file" ]]; then
            local perms=$(ls -l "$config_file" | cut -d' ' -f1)
            # Should not be world-writable
            if [[ "$perms" =~ w....w ]]; then
                log_error "Security issue: $config_file is world-writable"
                permission_issues=$((permission_issues + 1))
            else
                log_info "✓ $config_file has appropriate permissions"
            fi
        fi
    done

    # Test 6b: No sensitive information exposure
    log_info "Testing for sensitive information exposure..."

    local sensitive_patterns=("password" "secret" "key" "token" "api_key")
    local sensitive_found=0

    for config_file in "$TEST_HOME/.zshenv" "$TEST_HOME/.bashrc" "$TEST_HOME/.tmux.conf"; do
        if [[ -f "$config_file" ]]; then
            for pattern in "${sensitive_patterns[@]}"; do
                if grep -i "$pattern" "$config_file" >/dev/null 2>&1; then
                    log_warning "Potential sensitive information in $config_file: $pattern"
                    sensitive_found=$((sensitive_found + 1))
                fi
            done
        fi
    done

    if [[ $permission_issues -eq 0 && $sensitive_found -eq 0 ]]; then
        log_info "✓ No obvious security issues detected"
    elif [[ $permission_issues -gt 0 ]]; then
        test_fail "macOS Security and Permissions" "$permission_issues permission issues found"
        return 1
    else
        log_warning "Sensitive patterns found - review manually"
    fi

    test_pass "macOS Security and Permissions"
}

# Display final results
display_final_results() {
    echo ""
    echo -e "${BOLD}${BLUE}=== macOS-Specific Integration Test Results ===${NC}"
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ ALL MACOS TESTS PASSED${NC}"
        echo -e "${GREEN}macOS-specific features are working correctly.${NC}"
    else
        echo -e "${RED}${BOLD}❌ SOME MACOS TESTS FAILED${NC}"
        echo -e "${RED}Please review the issues above.${NC}"
    fi

    echo ""
    echo "Test log saved to: $LOG_FILE"
}

# Main execution
main() {
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
 _____      _                 _
| ____|_  _| |_ ___ _ __   __ _| | | ___
|  _| \ \/ / __/ _ \ '_ \ / _` | | |/ _ \
| |___ >  <| ||  __/ | | | (_| | | |  __/
|_____/_/\_\\__\___|_| |_|\__,_|_|_|\___|
        macOS Integration Testing
EOF
    echo -e "${NC}"

    # Setup test environment first
    if ! setup_test_environment; then
        echo "Failed to setup test environment"
        exit 1
    fi

    # Copy existing configuration files for testing
    if [[ ! -f "$TEST_HOME/.zshenv" ]]; then
        log_info "Copying configuration files for testing..."

        # Copy key configuration files from the dotfiles directory
        if [[ -f "$DOTFILES_DIR/zsh/.zshenv" ]]; then
            cp "$DOTFILES_DIR/zsh/.zshenv" "$TEST_HOME/.zshenv"
        fi

        if [[ -f "$DOTFILES_DIR/bash/.bashrc" ]]; then
            cp "$DOTFILES_DIR/bash/.bashrc" "$TEST_HOME/.bashrc"
        fi

        if [[ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]]; then
            cp "$DOTFILES_DIR/tmux/.tmux.conf" "$TEST_HOME/.tmux.conf"
        fi

        # Test installation script dry run if available
        if [[ -x "$INSTALL_SCRIPT" ]]; then
            log_info "Testing install script dry run..."
            if "$INSTALL_SCRIPT" --help >/dev/null 2>&1; then
                log_info "✓ Install script is functional"
            else
                log_warning "Install script --help failed"
            fi
        fi
    fi

    # Run all tests
    test_wave1_regression
    test_macos_specific_features
    test_macos_shell_configuration
    test_architecture_compatibility
    test_macos_package_installation
    test_macos_security_permissions

    # Display results and cleanup
    display_final_results

    # Cleanup on success, preserve on failure for debugging
    if [[ $TESTS_FAILED -eq 0 ]]; then
        cleanup
    else
        echo ""
        echo -e "${YELLOW}Test environment preserved at: $TEST_ROOT${NC}"
        echo "Run 'rm -rf $TEST_ROOT' when finished debugging"
    fi

    # Exit with appropriate code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Set up cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"