#!/usr/bin/env bash

# Basic Integration Test - Focused testing without complex timing/measurement
set -euo pipefail

# Configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"
RESULTS_DIR="$TEST_DIR/test_results"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

log_test() {
    local name="$1"
    local status="$2"
    local details="$3"

    ((TESTS_TOTAL++))

    if [ "$status" = "PASS" ]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✅ $name${NC}"
    else
        ((TESTS_FAILED++))
        echo -e "${RED}❌ $name${NC}"
    fi

    if [ -n "$details" ]; then
        echo "   $details"
    fi
}

echo -e "${BLUE}${BOLD}=== Basic Integration Tests ===${NC}\n"

# Test 1: Script syntax
echo "Testing script syntax..."
if bash -n "$DOTFILES_DIR/install.sh"; then
    log_test "Script syntax validation" "PASS"
else
    log_test "Script syntax validation" "FAIL"
fi

# Test 2: Script accessibility
echo "Testing script accessibility..."
if [ -x "$DOTFILES_DIR/install.sh" ]; then
    log_test "Script executable" "PASS"
else
    log_test "Script executable" "FAIL" "Script is not executable"
fi

# Test 3: Basic function loading
echo "Testing function loading..."
if source "$DOTFILES_DIR/install.sh"; then
    log_test "Script loading" "PASS"
else
    log_test "Script loading" "FAIL"
fi

# Test 4: Core functions availability
echo "Testing core functions..."
if declare -f detect_os >/dev/null 2>&1; then
    log_test "Function: detect_os" "PASS"
else
    log_test "Function: detect_os" "FAIL"
fi

if declare -f command_exists >/dev/null 2>&1; then
    log_test "Function: command_exists" "PASS"
else
    log_test "Function: command_exists" "FAIL"
fi

if declare -f install_package >/dev/null 2>&1; then
    log_test "Function: install_package" "PASS"
else
    log_test "Function: install_package" "FAIL"
fi

# Test 5: OS detection
echo "Testing OS detection..."
if detect_os >/dev/null 2>&1; then
    log_test "OS detection" "PASS" "Detected: $OS"
else
    log_test "OS detection" "FAIL"
fi

# Test 6: Command detection
echo "Testing command detection..."
if command_exists bash; then
    log_test "Command detection: bash" "PASS"
else
    log_test "Command detection: bash" "FAIL" "bash should always exist"
fi

if ! command_exists non_existent_command_xyz123 2>/dev/null; then
    log_test "Command detection: non-existent" "PASS" "Correctly returns false"
else
    log_test "Command detection: non-existent" "FAIL" "Should return false"
fi

# Test 7: Package detection
echo "Testing package detection..."
if get_available_packages >/dev/null 2>&1; then
    local count=$(get_available_packages | wc -w)
    log_test "Dotfiles package detection" "PASS" "Found $count packages"
else
    log_test "Dotfiles package detection" "FAIL"
fi

if get_platform_packages >/dev/null 2>&1; then
    local count=$(get_platform_packages | wc -l)
    log_test "Platform package detection" "PASS" "Found $count packages"
else
    log_test "Platform package detection" "FAIL"
fi

# Test 8: Validation functions
echo "Testing validation functions..."
if validate_platform_commands >/dev/null 2>&1; then
    log_test "Platform command validation" "PASS" "All required commands available"
else
    log_test "Platform command validation" "WARN" "Some commands missing"
fi

# Test 9: Package validation
echo "Testing package validation..."
local test_packages=("git" "vim" "tmux")
local filtered_output
filtered_output=$(pre_validate_packages "${test_packages[@]}" 2>/dev/null || echo "")

if [ -n "$filtered_output" ]; then
    local count=$(echo "$filtered_output" | wc -l)
    log_test "Package validation" "PASS" "Validated $count packages"
else
    log_test "Package validation" "WARN" "No packages validated"
fi

echo -e "\n${BOLD}Test Summary:${NC}"
echo "Total: $TESTS_TOTAL"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
else
    echo -e "\n${RED}Some tests failed.${NC}"
fi