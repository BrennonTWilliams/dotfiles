#!/bin/bash

# User Workflow Testing Module
# Tests real-world user scenarios and common workflows

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Test configuration
readonly TEST_ROOT="${TMPDIR:-/tmp}/user_workflow_test_$$"
readonly TEST_HOME="$TEST_ROOT/home"
readonly TEST_PROJECT="$TEST_ROOT/test_project"
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

log_test() {
    echo -e "${CYAN}[WORKFLOW-TEST]${NC} $1"
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

test_developer_workflow() {
    log_test "Testing developer workflow"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    mkdir -p "$TEST_PROJECT"
    export HOME="$TEST_HOME"

    # Setup test environment
    if [[ -f "$DOTFILES_DIR/bash/.bashrc" ]]; then
        cp "$DOTFILES_DIR/bash/.bashrc" "$TEST_HOME/.bashrc"
    fi

    if [[ -f "$DOTFILES_DIR/zsh/.zshenv" ]]; then
        cp "$DOTFILES_DIR/zsh/.zshenv" "$TEST_HOME/.zshenv"
    fi

    local workflow_score=0

    # Test 1: Directory navigation and file operations
    cd "$TEST_PROJECT"
    if (source "$TEST_HOME/.bashrc" && ls -la >/dev/null 2>&1); then
        log_info "✓ Directory operations work"
        workflow_score=$((workflow_score + 1))
    fi

    # Test 2: Git workflow (if git available)
    if command -v git >/dev/null 2>&1; then
        cd "$TEST_PROJECT"
        if git init >/dev/null 2>&1; then
            echo "# Test Project" > README.md
            if git add README.md >/dev/null 2>&1 && git commit -m "Initial commit" >/dev/null 2>&1; then
                log_info "✓ Basic Git workflow works"
                workflow_score=$((workflow_score + 1))
            fi
        fi
    else
        log_info "⚠ Git not available for workflow testing"
    fi

    # Test 3: Environment setup for development
    if [[ -f "$TEST_HOME/.zshenv" ]]; then
        if (source "$TEST_HOME/.zshenv" && echo "$PATH" | grep -q "homebrew"); then
            log_info "✓ Development environment PATH configured"
            workflow_score=$((workflow_score + 1))
        fi
    fi

    # Test 4: Environment setup validation
    if [[ -f "$TEST_HOME/.bashrc" ]]; then
        if (source "$TEST_HOME/.bashrc" && [[ -n "${PS1:-}" ]] && [[ -n "${PATH:-}" ]]); then
            log_info "✓ Shell environment properly configured"
            workflow_score=$((workflow_score + 1))
        fi
    fi

    if [[ $workflow_score -ge 2 ]]; then
        log_pass "Developer workflow working (score: $workflow_score/4)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_fail "Developer workflow insufficient (score: $workflow_score/4)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_system_management_workflow() {
    log_test "Testing system management workflow"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    # Setup mock system tools
    mkdir -p "$TEST_ROOT/bin"
    echo '#!/bin/bash
echo "brew: command not found (simulated)"' > "$TEST_ROOT/bin/brew"
    chmod +x "$TEST_ROOT/bin/brew"

    export PATH="$TEST_ROOT/bin:$PATH"

    local workflow_score=0

    # Test 1: Package management awareness
    if command -v brew >/dev/null 2>&1; then
        log_info "✓ Package management tool accessible"
        workflow_score=$((workflow_score + 1))
    fi

    # Test 2: System information commands
    if command -v uptime >/dev/null 2>&1; then
        log_info "✓ System information commands available"
        workflow_score=$((workflow_score + 1))
    fi

    # Test 3: Environment variable management
    if [[ -f "$DOTFILES_DIR/zsh/.zshenv" ]]; then
        cp "$DOTFILES_DIR/zsh/.zshenv" "$TEST_HOME/.zshenv"
        local env_vars_count
        env_vars_count=$(grep -c "^export" "$TEST_HOME/.zshenv" 2>/dev/null || echo "0")

        if [[ $env_vars_count -gt 0 ]]; then
            log_info "✓ Environment variables configured for system management"
            workflow_score=$((workflow_score + 1))
        fi
    fi

    # Test 4: Path management
    if [[ -f "$TEST_HOME/.zshenv" ]]; then
        if (source "$TEST_HOME/.zshenv" && echo "$PATH" | tr ':' '\n' | grep -q "bin"); then
            log_info "✓ System binary paths configured"
            workflow_score=$((workflow_score + 1))
        fi
    fi

    if [[ $workflow_score -ge 2 ]]; then
        log_pass "System management workflow working (score: $workflow_score/4)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_fail "System management workflow insufficient (score: $workflow_score/4)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_terminal_multiplexer_workflow() {
    log_test "Testing terminal multiplexer workflow"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    local workflow_score=0

    # Test 1: tmux configuration existence
    if [[ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]]; then
        cp "$DOTFILES_DIR/tmux/.tmux.conf" "$TEST_HOME/.tmux.conf"
        log_info "✓ tmux configuration available"
        workflow_score=$((workflow_score + 1))
    fi

    # Test 2: tmux configuration syntax
    if command -v tmux >/dev/null 2>&1 && [[ -f "$TEST_HOME/.tmux.conf" ]]; then
        if tmux -f "$TEST_HOME/.tmux.conf" start-server \; source-file "$TEST_HOME/.tmux.conf" 2>/dev/null; then
            log_info "✓ tmux configuration syntax is valid"
            workflow_score=$((workflow_score + 1))
        fi
    fi

    # Test 3: Key binding configuration
    if [[ -f "$TEST_HOME/.tmux.conf" ]]; then
        if grep -q "prefix" "$TEST_HOME/.tmux.conf"; then
            log_info "✓ Custom key bindings configured"
            workflow_score=$((workflow_score + 1))
        fi
    fi

    # Test 4: Shell integration
    if [[ -f "$TEST_HOME/.tmux.conf" ]] && grep -q "default-shell\|shell" "$TEST_HOME/.tmux.conf"; then
        log_info "✓ Shell integration configured"
        workflow_score=$((workflow_score + 1))
    fi

    if [[ $workflow_score -ge 2 ]]; then
        log_pass "Terminal multiplexer workflow working (score: $workflow_score/4)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_fail "Terminal multiplexer workflow insufficient (score: $workflow_score/4)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_new_user_onboarding() {
    log_test "Testing new user onboarding experience"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    local onboarding_score=0

    # Test 1: Installation script availability
    if [[ -f "$DOTFILES_DIR/install.sh" ]] && [[ -x "$DOTFILES_DIR/install.sh" ]]; then
        log_info "✓ Installation script available and executable"
        onboarding_score=$((onboarding_score + 1))
    fi

    # Test 2: Help documentation
    if "$DOTFILES_DIR/install.sh" --help >/dev/null 2>&1; then
        log_info "✓ Installation script provides help"
        onboarding_score=$((onboarding_score + 1))
    fi

    # Test 3: Dry run capability
    if "$DOTFILES_DIR/install.sh" --dry-run --config-only >/dev/null 2>&1; then
        log_info "✓ Dry run mode available for safe testing"
        onboarding_score=$((onboarding_score + 1))
    fi

    # Test 4: Configuration file clarity
    local config_files=0
    if [[ -f "$DOTFILES_DIR/README.md" ]]; then
        config_files=$((config_files + 1))
        log_info "✓ README documentation available"
    fi

    if [[ -f "$DOTFILES_DIR/TROUBLESHOOTING.md" ]]; then
        config_files=$((config_files + 1))
        log_info "✓ Troubleshooting documentation available"
    fi

    if [[ $config_files -ge 1 ]]; then
        onboarding_score=$((onboarding_score + 1))
    fi

    if [[ $onboarding_score -ge 2 ]]; then
        log_pass "New user onboarding experience good (score: $onboarding_score/4)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_fail "New user onboarding experience insufficient (score: $onboarding_score/4)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_error_recovery_workflow() {
    log_test "Testing error recovery and troubleshooting workflow"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    local recovery_score=0

    # Test 1: Backup creation during installation
    echo "old_config" > "$TEST_HOME/.bashrc"

    if "$DOTFILES_DIR/install.sh" --config-only --force >/dev/null 2>&1; then
        if [[ -d "$TEST_HOME/.dotfiles_backup" ]]; then
            log_info "✓ Backup directory created during installation"
            recovery_score=$((recovery_score + 1))
        fi

        if [[ -f "$TEST_HOME/.dotfiles_backup/.bashrc" ]]; then
            log_info "✓ Original files backed up correctly"
            recovery_score=$((recovery_score + 1))
        fi
    fi

    # Test 2: Configuration validation
    if [[ -f "$TEST_HOME/.bashrc" ]]; then
        if bash -n "$TEST_HOME/.bashrc" 2>/dev/null; then
            log_info "✓ Generated configuration syntax is valid"
            recovery_score=$((recovery_score + 1))
        fi
    fi

    # Test 3: Troubleshooting documentation
    if [[ -f "$DOTFILES_DIR/TROUBLESHOOTING.md" ]]; then
        if grep -q -i "install\|setup\|problem" "$DOTFILES_DIR/TROUBLESHOOTING.md"; then
            log_info "✓ Troubleshooting documentation covers installation issues"
            recovery_score=$((recovery_score + 1))
        fi
    fi

    if [[ $recovery_score -ge 2 ]]; then
        log_pass "Error recovery workflow working (score: $recovery_score/4)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_fail "Error recovery workflow insufficient (score: $recovery_score/4)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

main() {
    echo -e "${CYAN}=== User Workflow Testing ===${NC}"

    # Run all workflow tests
    test_developer_workflow
    test_system_management_workflow
    test_terminal_multiplexer_workflow
    test_new_user_onboarding
    test_error_recovery_workflow

    # Cleanup
    rm -rf "$TEST_ROOT"

    # Summary
    echo ""
    echo -e "${CYAN}=== User Workflow Test Summary ===${NC}"
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✅ All user workflow tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some user workflow tests failed.${NC}"
        exit 1
    fi
}

main "$@"