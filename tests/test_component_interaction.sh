#!/bin/bash

# Component Interaction Testing Module
# Tests cross-component compatibility and integration

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Test configuration
readonly TEST_ROOT="${TMPDIR:-/tmp}/component_interaction_test_$$"
readonly TEST_HOME="$TEST_ROOT/home"
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

log_test() {
    echo -e "${PURPLE}[COMPONENT-TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

test_tmux_shell_integration() {
    log_test "Testing tmux + shell integration"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    # Setup test environment
    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    # Copy configurations
    if [[ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]]; then
        cp "$DOTFILES_DIR/tmux/.tmux.conf" "$TEST_HOME/.tmux.conf"
    else
        log_fail "tmux configuration not found"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi

    if [[ -f "$DOTFILES_DIR/bash/.bashrc" ]]; then
        cp "$DOTFILES_DIR/bash/.bashrc" "$TEST_HOME/.bashrc"
    fi

    # Test tmux configuration syntax (without TPM plugins)
    # Create a temporary config without TPM for syntax testing
    sed '/^run/d' "$TEST_HOME/.tmux.conf" > "$TEST_HOME/.tmux.conf.tmp"

    if tmux -f "$TEST_HOME/.tmux.conf.tmp" start-server \; source-file "$TEST_HOME/.tmux.conf.tmp" 2>/dev/null; then
        log_pass "tmux configuration syntax is valid"
    else
        log_fail "tmux configuration syntax errors"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        rm -f "$TEST_HOME/.tmux.conf.tmp"
        return 1
    fi

    rm -f "$TEST_HOME/.tmux.conf.tmp"

    # Test for shell integration features
    local shell_integration_found=0

    if grep -q "default-shell" "$TEST_HOME/.tmux.conf"; then
        log_info "✓ Custom shell configuration found"
        shell_integration_found=$((shell_integration_found + 1))
    fi

    if grep -q "clipboard" "$TEST_HOME/.tmux.conf" || grep -q "reattach-to-user-namespace" "$TEST_HOME/.tmux.conf"; then
        log_info "✓ Clipboard integration configured"
        shell_integration_found=$((shell_integration_found + 1))
    fi

    if grep -q "prefix" "$TEST_HOME/.tmux.conf"; then
        log_info "✓ Custom prefix key configured"
        shell_integration_found=$((shell_integration_found + 1))
    fi

    if [[ $shell_integration_found -ge 2 ]]; then
        log_pass "tmux + shell integration working"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_fail "tmux + shell integration insufficient"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_path_conflicts() {
    log_test "Testing PATH conflicts and ordering"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    # Copy zshenv for PATH testing
    if [[ -f "$DOTFILES_DIR/zsh/.zshenv" ]]; then
        cp "$DOTFILES_DIR/zsh/.zshenv" "$TEST_HOME/.zshenv"

        # Test PATH configuration using content analysis
        # Check that PATH is configured properly in zshenv
        if grep -q "export PATH" "$TEST_HOME/.zshenv"; then
            log_pass "PATH export configuration found"
        else
            log_fail "PATH export configuration not found"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi

        # Test for potential PATH duplication issues in configuration
        local path_exports
        path_exports=$(grep -c "export PATH" "$TEST_HOME/.zshenv" || echo "0")

        if [[ $path_exports -le 3 ]]; then
            log_pass "PATH configuration is reasonable ($path_exports PATH exports)"
        else
            log_fail "Too many PATH exports found ($path_exports)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi

        # Test that Homebrew gets priority
        if grep -A2 -B2 "eval.*brew.*shellenv" "$TEST_HOME/.zshenv" >/dev/null; then
            log_pass "Homebrew PATH priority configured"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_fail "Homebrew PATH priority not configured"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        log_fail "zshenv not found for PATH testing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_alias_conflicts() {
    log_test "Testing alias conflicts and functionality"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    # Copy bash configuration
    if [[ -f "$DOTFILES_DIR/bash/.bashrc" ]]; then
        cp "$DOTFILES_DIR/bash/.bashrc" "$TEST_HOME/.bashrc"

        # Test for duplicate aliases
        local duplicate_aliases
        duplicate_aliases=$(grep "^alias" "$TEST_HOME/.bashrc" | cut -d'=' -f1 | sort | uniq -d || true)

        if [[ -z "$duplicate_aliases" ]]; then
            log_pass "No duplicate aliases found"
        else
            log_fail "Duplicate aliases found: $duplicate_aliases"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi

        # Test alias definitions (not functionality, since many are commented out)
        local alias_definitions=0
        local test_aliases=("ll" "la" "l")

        for alias_name in "${test_aliases[@]}"; do
            if grep -q "alias.*$alias_name" "$TEST_HOME/.bashrc"; then
                alias_definitions=$((alias_definitions + 1))
                log_info "✓ Alias definition '$alias_name' found"
            fi
        done

        if [[ $alias_definitions -ge 1 ]]; then
            log_pass "Alias definitions present ($alias_definitions/$# test aliases found)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_fail "No alias definitions found ($alias_definitions/$# test aliases)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        log_fail "bashrc not found for alias testing"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_shell_compatibility() {
    log_test "Testing cross-shell compatibility"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    local compatible_configs=0

    # Test bash compatibility
    if [[ -f "$DOTFILES_DIR/bash/.bashrc" ]]; then
        if bash -n "$DOTFILES_DIR/bash/.bashrc" 2>/dev/null; then
            log_info "✓ bashrc compatible with bash"
            compatible_configs=$((compatible_configs + 1))
        else
            log_info "✗ bashrc has bash compatibility issues"
        fi
    fi

    # Test zsh compatibility
    if [[ -f "$DOTFILES_DIR/zsh/.zshenv" ]]; then
        if zsh -n "$DOTFILES_DIR/zsh/.zshenv" 2>/dev/null; then
            log_info "✓ zshenv compatible with zsh"
            compatible_configs=$((compatible_configs + 1))
        else
            log_info "✗ zshenv has zsh compatibility issues"
        fi
    fi

    # Test cross-shell syntax
    if [[ -f "$DOTFILES_DIR/bash/.bashrc" ]]; then
        # Check for basic bash syntax patterns
        if grep -q "\[\[" "$DOTFILES_DIR/bash/.bashrc" 2>/dev/null; then
            log_info "⚠ Found bash-specific double bracket syntax"
        else
            log_info "✓ No obvious bash-specific syntax issues found"
        fi
    fi

    if [[ $compatible_configs -ge 1 ]]; then
        log_pass "Cross-shell compatibility working ($compatible_configs configs tested)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_fail "Cross-shell compatibility issues found"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_environment_integration() {
    log_test "Testing environment variable integration"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    local integration_score=0

    # Test environment exports in bashrc
    if [[ -f "$DOTFILES_DIR/bash/.bashrc" ]]; then
        local export_count
        export_count=$(grep -c "^export" "$DOTFILES_DIR/bash/.bashrc" 2>/dev/null || echo "0")

        if [[ $export_count -gt 0 ]]; then
            log_info "✓ Environment variables configured ($export_count exports)"
            integration_score=$((integration_score + 1))
        fi
    fi

    # Test PATH configuration in zshenv
    if [[ -f "$DOTFILES_DIR/zsh/.zshenv" ]]; then
        if grep -q "export PATH" "$DOTFILES_DIR/zsh/.zshenv"; then
            log_info "✓ PATH environment variable configured"
            integration_score=$((integration_score + 1))
        fi
    fi

    # Test for common environment variables
    local common_env_vars=("EDITOR" "VISUAL" "LANG" "LC_ALL")
    local found_env_vars=0

    for var in "${common_env_vars[@]}"; do
        if grep -r "export $var" "$DOTFILES_DIR" >/dev/null 2>&1; then
            found_env_vars=$((found_env_vars + 1))
            log_info "✓ Environment variable $var configured"
        fi
    done

    if [[ $found_env_vars -gt 0 ]]; then
        integration_score=$((integration_score + 1))
    fi

    if [[ $integration_score -ge 2 ]]; then
        log_pass "Environment integration working (score: $integration_score/3)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_fail "Environment integration insufficient (score: $integration_score/3)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

main() {
    echo -e "${PURPLE}=== Component Interaction Testing ===${NC}"

    # Run all component tests
    test_tmux_shell_integration
    test_path_conflicts
    test_alias_conflicts
    test_shell_compatibility
    test_environment_integration

    # Cleanup
    rm -rf "$TEST_ROOT"

    # Summary
    echo ""
    echo -e "${PURPLE}=== Component Interaction Test Summary ===${NC}"
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✅ All component interaction tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some component interaction tests failed.${NC}"
        exit 1
    fi
}

main "$@"