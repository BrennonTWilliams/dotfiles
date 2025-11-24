#!/usr/bin/env bash

# ==============================================================================
# Unit Tests for Pre-flight Dependency Check
# ==============================================================================
# Tests the preflight-check.sh script functionality
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source the preflight check script functions
source "$DOTFILES_DIR/scripts/lib/utils.sh"
source "$DOTFILES_DIR/scripts/preflight-check.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ==============================================================================
# Test Framework Functions
# ==============================================================================

test_start() {
    local test_name="$1"
    echo
    echo "▸ Testing: $test_name"
    ((TESTS_RUN++)) || true
}

test_pass() {
    local test_name="$1"
    echo "  ✓ PASS: $test_name"
    ((TESTS_PASSED++)) || true
}

test_fail() {
    local test_name="$1"
    local reason="${2:-}"
    echo "  ✗ FAIL: $test_name"
    if [ -n "$reason" ]; then
        echo "    Reason: $reason"
    fi
    ((TESTS_FAILED++)) || true
}

# ==============================================================================
# Test Cases
# ==============================================================================

test_command_version_detection() {
    test_start "Command version detection"

    # Test git version detection
    if command -v git &> /dev/null; then
        local git_version=$(get_installed_version "git")
        if [[ "$git_version" =~ ^[0-9]+\.[0-9]+ ]]; then
            test_pass "Git version detected: $git_version"
        else
            test_fail "Git version detection" "Invalid version format: $git_version"
        fi
    else
        test_fail "Git version detection" "Git not installed"
    fi

    # Test curl version detection
    if command -v curl &> /dev/null; then
        local curl_version=$(get_installed_version "curl")
        if [[ "$curl_version" =~ ^[0-9]+\.[0-9]+ ]]; then
            test_pass "Curl version detected: $curl_version"
        else
            test_fail "Curl version detection" "Invalid version format: $curl_version"
        fi
    else
        test_fail "Curl version detection" "Curl not installed"
    fi
}

test_check_command() {
    test_start "Check command function"

    # Test with a command that should exist (sh is universal)
    local result=$(check_command "sh" "Shell")
    if [[ "$result" == installed:* ]]; then
        test_pass "check_command detects installed command (sh)"
    else
        test_fail "check_command" "Should detect sh as installed, got: $result"
    fi

    # Test with a command that should not exist
    result=$(check_command "nonexistent_command_xyz123" "Fake command") || true
    if [[ "$result" == missing:* ]]; then
        test_pass "check_command detects missing command"
    else
        test_fail "check_command" "Should detect missing command, got: $result"
    fi
}

test_homebrew_detection() {
    test_start "Homebrew detection"

    detect_os

    if [ "$OS" = "macos" ]; then
        local brew_result=$(check_homebrew)

        if command -v brew &> /dev/null; then
            if [[ "$brew_result" == installed:* ]]; then
                local version=$(echo "$brew_result" | cut -d':' -f2)
                test_pass "Homebrew detected: version $version"
            else
                test_fail "Homebrew detection" "Homebrew installed but not detected properly"
            fi
        else
            if [[ "$brew_result" == missing:* ]]; then
                test_pass "Homebrew correctly identified as missing"
            else
                test_fail "Homebrew detection" "Should report as missing"
            fi
        fi
    else
        test_pass "Homebrew check skipped (not macOS)"
    fi
}

test_disk_space_check() {
    test_start "Disk space check"

    detect_os
    local result=$(check_disk_space)

    if [[ "$result" == sufficient:* ]]; then
        local space=$(echo "$result" | cut -d':' -f2)
        test_pass "Disk space check: $space"
    elif [[ "$result" == insufficient:* ]]; then
        test_pass "Disk space check detected low space (expected on minimal systems)"
    else
        test_fail "Disk space check" "Invalid result format: $result"
    fi
}

test_internet_check() {
    test_start "Internet connectivity check"

    local result=$(check_internet)

    if [ "$result" = "active" ]; then
        test_pass "Internet connection detected"
    elif [ "$result" = "inactive" ]; then
        test_pass "Internet check detected offline (expected in air-gapped systems)"
    else
        test_fail "Internet check" "Invalid result: $result"
    fi
}

test_critical_dependencies() {
    test_start "Critical dependencies check"

    local missing_count=0

    for dep_info in "${CRITICAL_DEPS[@]}"; do
        IFS=':' read -r dep desc <<< "$dep_info"
        if ! command -v "$dep" &> /dev/null; then
            ((missing_count++)) || true
            echo "  ⚠ Missing critical dependency: $dep"
        fi
    done

    if [ $missing_count -eq 0 ]; then
        test_pass "All critical dependencies present"
    else
        test_fail "Critical dependencies" "$missing_count critical dependencies missing"
    fi
}

test_os_detection() {
    test_start "Operating system detection"

    detect_os

    if [ -n "$OS" ] && [ "$OS" != "unknown" ]; then
        test_pass "OS detected: $OS"
    else
        test_fail "OS detection" "OS not detected or unknown"
    fi

    if [ -n "$PKG_MANAGER" ] && [ "$PKG_MANAGER" != "unknown" ]; then
        test_pass "Package manager detected: $PKG_MANAGER"
    else
        test_fail "Package manager detection" "Package manager unknown"
    fi
}

test_version_parsing() {
    test_start "Version string parsing"

    # Test various version formats
    local commands=("git" "curl" "bash" "sh")
    local parsed_count=0

    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            local version=$(get_installed_version "$cmd")
            if [ "$version" != "unknown" ]; then
                ((parsed_count++)) || true
            fi
        fi
    done

    if [ $parsed_count -ge 2 ]; then
        test_pass "Version parsing works for $parsed_count commands"
    else
        test_fail "Version parsing" "Could only parse $parsed_count versions"
    fi
}

# ==============================================================================
# Test Runner
# ==============================================================================

run_all_tests() {
    echo "═══════════════════════════════════════════════════════════════════"
    echo "PRE-FLIGHT CHECK UNIT TESTS"
    echo "═══════════════════════════════════════════════════════════════════"

    # Run all test cases
    test_os_detection
    test_command_version_detection
    test_check_command
    test_homebrew_detection
    test_disk_space_check
    test_internet_check
    test_critical_dependencies
    test_version_parsing

    # Print summary
    echo
    echo "═══════════════════════════════════════════════════════════════════"
    echo "TEST SUMMARY"
    echo "═══════════════════════════════════════════════════════════════════"
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo

    if [ $TESTS_FAILED -eq 0 ]; then
        echo "✓ All tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_all_tests
fi
