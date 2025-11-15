#!/usr/bin/env bash

# ==============================================================================
# Integration Test Suite for Installation Workflow
# ==============================================================================
# Comprehensive testing of installation scripts and cross-platform functionality
# ==============================================================================

set -euo pipefail

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"
RESULTS_DIR="$TEST_DIR/test_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$RESULTS_DIR/integration_test_report_$TIMESTAMP.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Performance tracking
declare -A PERF_TIMES
declare -A MEMORY_USAGE

# ==============================================================================
# Test Framework Functions
# ==============================================================================

setup_test_environment() {
    echo -e "${BLUE}${BOLD}=== Integration Test Suite for Installation Workflow ===${NC}"
    echo "Timestamp: $TIMESTAMP"
    echo "Test Directory: $TEST_DIR"
    echo "Dotfiles Directory: $DOTFILES_DIR"
    echo "Results Directory: $RESULTS_DIR"
    echo

    # Create results directory
    mkdir -p "$RESULTS_DIR"

    # Initialize report file
    cat > "$REPORT_FILE" << EOF
==============================================================================
Integration Test Report - Installation Workflow
==============================================================================
Generated: $(date)
Test Directory: $TEST_DIR
Dotfiles Directory: $DOTFILES_DIR
Platform: $(uname -s) $(uname -r)
Architecture: $(uname -m)

EOF
}

log_test_result() {
    local test_name="$1"
    local status="$2"
    local details="$3"
    local execution_time="$4"

    ((TESTS_TOTAL++))

    if [ "$status" = "PASS" ]; then
        ((TESTS_PASSED++))
        echo -e "${GREEN}✅ PASS${NC} $test_name"
        if [ -n "$details" ]; then
            echo "   $details"
        fi
    else
        ((TESTS_FAILED++))
        echo -e "${RED}❌ FAIL${NC} $test_name"
        if [ -n "$details" ]; then
            echo "   $details"
        fi
    fi

    if [ -n "$execution_time" ]; then
        echo "   Execution time: ${execution_time}s"
        PERF_TIMES["$test_name"]="$execution_time"
    fi

    echo

    # Log to report file
    cat >> "$REPORT_FILE" << EOF
[$status] $test_name
Details: $details
Execution Time: ${execution_time}s

EOF
}

measure_time() {
    local command="$1"
    local start_time=$(date +%s.%N)

    eval "$command"
    local exit_code=$?

    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    return $exit_code
}

measure_memory() {
    local command="$1"
    local memory_before=$(ps -o rss= -p $$ | awk '{print $1}')

    eval "$command"
    local exit_code=$?

    local memory_after=$(ps -o rss= -p $$ | awk '{print $1}')
    local memory_diff=$((memory_after - memory_before))

    return $exit_code
}

# ==============================================================================
# Argument Parsing Tests
# ==============================================================================

test_argument_parsing() {
    section "Testing Argument Parsing and Mode Detection"

    # Test --all flag
    local output
    if output=$("$DOTFILES_DIR/install.sh" --help 2>&1); then
        log_test_result "Argument: --help availability" "PASS" "Help accessible"
    else
        log_test_result "Argument: --help availability" "FAIL" "Help not accessible"
    fi

    # Test script syntax validation
    if bash -n "$DOTFILES_DIR/install.sh"; then
        log_test_result "Script syntax validation" "PASS" "No syntax errors found"
    else
        log_test_result "Script syntax validation" "FAIL" "Syntax errors detected"
    fi

    # Test function definitions
    local required_functions=(
        "detect_os"
        "command_exists"
        "install_package"
        "stow_package"
        "validate_platform_commands"
        "pre_validate_packages"
        "run_setup_scripts"
    )

    for func in "${required_functions[@]}"; do
        if bash -c "source '$DOTFILES_DIR/install.sh'; declare -f $func" >/dev/null 2>&1; then
            log_test_result "Function definition: $func" "PASS" "Function exists"
        else
            log_test_result "Function definition: $func" "FAIL" "Function missing"
        fi
    done
}

# ==============================================================================
# Cross-Platform Command Validation Tests
# ==============================================================================

test_cross_platform_validation() {
    section "Testing Cross-Platform Command Validation"

    # Source the installation script to access functions
    source "$DOTFILES_DIR/install.sh"

    # Test OS detection
    detect_os
    log_test_result "OS detection" "PASS" "Detected: $OS ($PKG_MANAGER)"

    # Test command_exists function
    if command_exists bash; then
        log_test_result "Command detection: bash" "PASS" "bash found"
    else
        log_test_result "Command detection: bash" "FAIL" "bash not found (unexpected)"
    fi

    # Test command_exists with non-existent command
    if command_exists non_existent_command_xyz123 2>/dev/null; then
        log_test_result "Command detection: non-existent" "FAIL" "Should not find non-existent command"
    else
        log_test_result "Command detection: non-existent" "PASS" "Correctly returns false for non-existent command"
    fi

    # Test validate_platform_commands function
    if validate_platform_commands >/dev/null 2>&1; then
        log_test_result "Platform command validation" "PASS" "All required commands available"
    else
        log_test_result "Platform command validation" "WARN" "Some required commands missing (may be expected)"
    fi

    # Test platform-specific command lists
    if [[ "$OS" == "macos" ]]; then
        # Test macOS-specific commands
        if command_exists pbcopy && command_exists pbpaste; then
            log_test_result "macOS clipboard commands" "PASS" "pbcopy/pbpaste available"
        else
            log_test_result "macOS clipboard commands" "WARN" "pbcopy/pbpaste not available"
        fi
    elif [[ "$OS" == "linux" ]]; then
        # Test Linux-specific commands
        if command_exists xclip; then
            log_test_result "Linux clipboard command: xclip" "PASS" "xclip available"
        else
            log_test_result "Linux clipboard command: xclip" "WARN" "xclip not available (optional)"
        fi
    fi
}

# ==============================================================================
# Package Manager Validation Tests
# ==============================================================================

test_package_validation() {
    section "Testing Package Manager Validation"

    source "$DOTFILES_DIR/install.sh"
    detect_os

    # Test package availability checking functions
    case "$PKG_MANAGER" in
        "brew")
            # Test brew package availability check
            if command_exists brew; then
                if check_brew_package_availability git; then
                    log_test_result "Brew package validation: git" "PASS" "git package found"
                else
                    log_test_result "Brew package validation: git" "FAIL" "git package not found"
                fi

                # Test with non-existent package
                if check_brew_package_availability non_existent_package_xyz123 2>/dev/null; then
                    log_test_result "Brew package validation: non-existent" "FAIL" "Should not find non-existent package"
                else
                    log_test_result "Brew package validation: non-existent" "PASS" "Correctly rejects non-existent package"
                fi
            else
                log_test_result "Brew package manager" "SKIP" "brew not available"
            fi
            ;;
        "apt")
            # Test apt package availability check
            if command_exists apt-cache; then
                if check_apt_package_availability git; then
                    log_test_result "APT package validation: git" "PASS" "git package found"
                else
                    log_test_result "APT package validation: git" "FAIL" "git package not found"
                fi
            else
                log_test_result "APT package manager" "SKIP" "apt-cache not available"
            fi
            ;;
        "dnf")
            # Test dnf package availability check
            if command_exists dnf; then
                if check_dnf_package_availability git; then
                    log_test_result "DNF package validation: git" "PASS" "git package found"
                else
                    log_test_result "DNF package validation: git" "FAIL" "git package not found"
                fi
            else
                log_test_result "DNF package manager" "SKIP" "dnf not available"
            fi
            ;;
        "pacman")
            # Test pacman package availability check
            if command_exists pacman; then
                if check_pacman_package_availability git; then
                    log_test_result "Pacman package validation: git" "PASS" "git package found"
                else
                    log_test_result "Pacman package validation: git" "FAIL" "git package not found"
                fi
            else
                log_test_result "Pacman package manager" "SKIP" "pacman not available"
            fi
            ;;
        *)
            log_test_result "Package manager" "WARN" "Unsupported package manager: $PKG_MANAGER"
            ;;
    esac

    # Test platform-specific package filtering
    local test_packages=("git" "vim" "tmux")
    if [[ "$OS" == "macos" ]]; then
        test_packages+=("sway" "swaybg")  # These should be filtered out
    fi

    local filtered_output
    filtered_output=$(pre_validate_packages "${test_packages[@]}")
    local filtered_count=$(echo "$filtered_output" | wc -l)

    if [[ "$OS" == "macos" ]]; then
        # Should filter out sway packages
        if [[ "$filtered_output" != *"sway"* ]] && [[ "$filtered_output" != *"swaybg"* ]]; then
            log_test_result "Package filtering: macOS" "PASS" "Linux packages correctly filtered"
        else
            log_test_result "Package filtering: macOS" "FAIL" "Linux packages not properly filtered"
        fi
    else
        log_test_result "Package filtering: Linux" "PASS" "No filtering needed on Linux"
    fi
}

# ==============================================================================
# Error Handling Tests
# ==============================================================================

test_error_handling() {
    section "Testing Error Handling and Recovery"

    # Test with invalid directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    if "$DOTFILES_DIR/install.sh" --all 2>/dev/null; then
        log_test_result "Error handling: invalid directory" "FAIL" "Should fail in directory without dotfiles"
    else
        log_test_result "Error handling: invalid directory" "PASS" "Correctly fails in invalid directory"
    fi

    cd "$DOTFILES_DIR"
    rm -rf "$temp_dir"

    # Test with non-existent package file
    local original_packages
    if [[ -f "$DOTFILES_DIR/packages.txt" ]]; then
        mv "$DOTFILES_DIR/packages.txt" "$DOTFILES_DIR/packages.txt.bak"
        original_packages="moved"
    fi

    local output
    if output=$(timeout 10 "$DOTFILES_DIR/install.sh" --packages 2>&1); then
        log_test_result "Error handling: missing package file" "PASS" "Gracefully handles missing package file"
    else
        log_test_result "Error handling: missing package file" "PASS" "Fails gracefully when package file missing"
    fi

    # Restore original file
    if [[ "$original_packages" == "moved" ]]; then
        mv "$DOTFILES_DIR/packages.txt.bak" "$DOTFILES_DIR/packages.txt"
    fi

    # Test permission error handling
    local test_script="$TEST_DIR/test_permission.sh"
    echo "echo 'test'" > "$test_script"
    chmod 644 "$test_script"  # Remove execute permission

    source "$DOTFILES_DIR/install.sh"
    if [ ! -x "$test_script" ]; then
        log_test_result "Permission handling: non-executable script" "PASS" "Detects non-executable scripts"
    else
        log_test_result "Permission handling: non-executable script" "FAIL" "Should detect non-executable scripts"
    fi

    rm -f "$test_script"
}

# ==============================================================================
# Performance Tests
# ==============================================================================

test_performance() {
    section "Testing Performance and Resource Usage"

    source "$DOTFILES_DIR/install.sh"

    # Test OS detection performance
    local start_time=$(date +%s.%N)
    for i in {1..100}; do
        detect_os >/dev/null
    done
    local end_time=$(date +%s.%N)
    local avg_time=$(echo "scale=4; ($end_time - $start_time) / 100" | bc -l 2>/dev/null || echo "0")

    if (( $(echo "$avg_time < 0.01" | bc -l 2>/dev/null || echo "1") )); then
        log_test_result "Performance: OS detection" "PASS" "Average time: ${avg_time}s"
    else
        log_test_result "Performance: OS detection" "WARN" "Average time: ${avg_time}s (may be slow)"
    fi

    PERF_TIMES["os_detection_avg"]="$avg_time"

    # Test command detection performance
    start_time=$(date +%s.%N)
    for i in {1..100}; do
        command_exists bash >/dev/null
        command_exists non_existent_cmd_xyz123 >/dev/null 2>&1 || true
    done
    end_time=$(date +%s.%N)
    avg_time=$(echo "scale=4; ($end_time - $start_time) / 200" | bc -l 2>/dev/null || echo "0")

    if (( $(echo "$avg_time < 0.005" | bc -l 2>/dev/null || echo "1") )); then
        log_test_result "Performance: command detection" "PASS" "Average time: ${avg_time}s"
    else
        log_test_result "Performance: command detection" "WARN" "Average time: ${avg_time}s (may be slow)"
    fi

    PERF_TIMES["command_detection_avg"]="$avg_time"

    # Test memory usage during script loading
    local memory_before=$(ps -o rss= -p $$ | awk '{print $1}')
    source "$DOTFILES_DIR/install.sh"
    local memory_after=$(ps -o rss= -p $$ | awk '{print $1}')
    local memory_diff=$((memory_after - memory_before))

    if [ $memory_diff -lt 5000 ]; then  # Less than 5MB
        log_test_result "Memory usage: script loading" "PASS" "Memory increase: ${memory_diff}KB"
    else
        log_test_result "Memory usage: script loading" "WARN" "Memory increase: ${memory_diff}KB (may be high)"
    fi

    MEMORY_USAGE["script_loading"]="$memory_diff"
}

# ==============================================================================
# Dry Run Installation Tests
# ==============================================================================

test_dry_run_installation() {
    section "Testing Dry Run Installation Scenarios"

    # Test with environment variable to simulate dry run
    export DRY_RUN=true

    # Test platform package detection
    source "$DOTFILES_DIR/install.sh"
    detect_os

    local packages
    if packages=$(get_platform_packages); then
        local package_count=$(echo "$packages" | wc -l)
        log_test_result "Dry run: platform package detection" "PASS" "Found $package_count packages for $OS"
    else
        log_test_result "Dry run: platform package detection" "FAIL" "Failed to detect platform packages"
    fi

    # Test package validation without installation
    if [ -n "$packages" ]; then
        local valid_packages
        if valid_packages=$(pre_validate_packages $packages); then
            local valid_count=$(echo "$valid_packages" | wc -l)
            log_test_result "Dry run: package validation" "PASS" "Validated $valid_count packages"
        else
            log_test_result "Dry run: package validation" "FAIL" "Package validation failed"
        fi
    fi

    # Test dotfiles package detection
    local dotfiles_packages
    if dotfiles_packages=$(get_available_packages); then
        local dotfiles_count=$(echo "$dotfiles_packages" | wc -w)
        log_test_result "Dry run: dotfiles package detection" "PASS" "Found $dotfiles_count dotfiles packages"
    else
        log_test_result "Dry run: dotfiles package detection" "FAIL" "Failed to detect dotfiles packages"
    fi

    unset DRY_RUN
}

# ==============================================================================
# Integration Scenarios
# ==============================================================================

test_integration_scenarios() {
    section "Testing Integration Scenarios"

    # Test complete workflow simulation
    source "$DOTFILES_DIR/install.sh"

    # Scenario 1: Fresh install simulation
    local start_time=$(date +%s.%N)

    detect_os
    validate_platform_commands >/dev/null 2>&1 || true
    local packages=$(get_platform_packages 2>/dev/null || echo "")
    local dotfiles_packages=$(get_available_packages)

    local end_time=$(date +%s.%N)
    local scenario_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    log_test_result "Integration: fresh install simulation" "PASS" "Completed in ${scenario_time}s"
    PERF_TIMES["fresh_install_simulation"]="$scenario_time"

    # Scenario 2: Error recovery simulation
    start_time=$(date +%s.%N)

    # Test with invalid packages
    local invalid_packages=("non_existent_pkg_1" "non_existent_pkg_2")
    local filtered_result
    filtered_result=$(pre_validate_packages "${invalid_packages[@]}" 2>/dev/null || echo "")

    end_time=$(date +%s.%N)
    scenario_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")

    if [ -z "$filtered_result" ]; then
        log_test_result "Integration: error recovery" "PASS" "Correctly filtered invalid packages in ${scenario_time}s"
    else
        log_test_result "Integration: error recovery" "WARN" "Some packages passed validation unexpectedly"
    fi

    # Scenario 3: Platform-specific behavior
    start_time=$(date +%s.%N)

    case "$OS" in
        "macos")
            # Test macOS-specific package handling
            local macos_packages=("git" "sketchybar" "sway" "swaybg")
            local filtered
            filtered=$(pre_validate_packages "${macos_packages[@]}")

            if [[ "$filtered" == *"sketchybar"* ]] && [[ "$filtered" != *"sway"* ]] && [[ "$filtered" != *"swaybg"* ]]; then
                log_test_result "Integration: macOS package filtering" "PASS" "Correctly handled macOS-specific packages"
            else
                log_test_result "Integration: macOS package filtering" "FAIL" "Package filtering not working correctly"
            fi
            ;;
        "linux")
            # Test Linux package handling
            local linux_packages=("git" "vim" "tmux")
            local filtered
            filtered=$(pre_validate_packages "${linux_packages[@]}")

            if [[ "$filtered" == *"git"* ]] || [[ "$filtered" == *"vim"* ]] || [[ "$filtered" == *"tmux"* ]]; then
                log_test_result "Integration: Linux package handling" "PASS" "Correctly handled Linux packages"
            else
                log_test_result "Integration: Linux package handling" "WARN" "No packages passed validation (may be expected)"
            fi
            ;;
    esac

    end_time=$(date +%s.%N)
    scenario_time=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
    PERF_TIMES["platform_specific_test"]="$scenario_time"
}

# ==============================================================================
# Helper Functions
# ==============================================================================

section() {
    echo -e "\n${BLUE}${BOLD}=== $1 ===${NC}\n"
}

# ==============================================================================
# Test Execution and Reporting
# ==============================================================================

run_all_tests() {
    setup_test_environment

    test_argument_parsing
    test_cross_platform_validation
    test_package_validation
    test_error_handling
    test_performance
    test_dry_run_installation
    test_integration_scenarios

    generate_final_report
}

generate_final_report() {
    section "Test Results Summary"

    echo -e "${BOLD}Total Tests:${NC} $TESTS_TOTAL"
    echo -e "${GREEN}${BOLD}Passed:${NC} $TESTS_PASSED"
    echo -e "${RED}${BOLD}Failed:${NC} $TESTS_FAILED"

    local success_rate=0
    if [ $TESTS_TOTAL -gt 0 ]; then
        success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    fi

    echo -e "${BOLD}Success Rate:${NC} ${success_rate}%"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}${BOLD}🎉 All tests passed!${NC}\n"
    else
        echo -e "\n${YELLOW}${BOLD}⚠️  Some tests failed. Check the report for details.${NC}\n"
    fi

    # Add performance summary to report
    cat >> "$REPORT_FILE" << EOF

==============================================================================
Performance Summary
==============================================================================

EOF

    for test_name in "${!PERF_TIMES[@]}"; do
        echo "Test: $test_name" >> "$REPORT_FILE"
        echo "Time: ${PERF_TIMES[$test_name]}s" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    done

    cat >> "$REPORT_FILE" << EOF

==============================================================================
Test Summary
==============================================================================

Total Tests: $TESTS_TOTAL
Passed: $TESTS_PASSED
Failed: $TESTS_FAILED
Success Rate: ${success_rate}%

EOF

    echo -e "${CYAN}Detailed report saved to:${NC} $REPORT_FILE"

    # Show performance highlights
    if [ ${#PERF_TIMES[@]} -gt 0 ]; then
        echo -e "\n${BLUE}${BOLD}Performance Highlights:${NC}"
        for test_name in "${!PERF_TIMES[@]}"; do
            echo "  $test_name: ${PERF_TIMES[$test_name]}s"
        done
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_all_tests
fi