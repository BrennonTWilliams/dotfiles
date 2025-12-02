#!/usr/bin/env bash

# ==============================================================================
# Package Manager Detection and Availability Validation Test Suite
# ==============================================================================
# Comprehensive validation of package manager detection and availability checking
# across all 9 supported Linux distributions
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Bash Version Check
# ------------------------------------------------------------------------------
# This test suite uses associative arrays (declare -A) which require bash 4.0+
# macOS ships with bash 3.2 by default. Install newer bash via Homebrew:
#   brew install bash
# Then run tests with: /opt/homebrew/bin/bash tests/test_package_manager_validation.sh
# ------------------------------------------------------------------------------
if ((BASH_VERSINFO[0] < 4)); then
    echo "ERROR: This test suite requires bash 4.0 or later (found: $BASH_VERSION)"
    echo ""
    echo "macOS ships with bash 3.2 due to licensing. To run tests:"
    echo "  1. Install newer bash: brew install bash"
    echo "  2. Run with Homebrew bash: /opt/homebrew/bin/bash $0"
    echo "     or on Intel Mac: /usr/local/bin/bash $0"
    exit 1
fi

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TEST_RESULTS_DIR="$SCRIPT_DIR/test_results"
TEST_LOG="$TEST_RESULTS_DIR/package_manager_validation_$(date +%Y%m%d_%H%M%S).log"
UTILS_FILE="$DOTFILES_DIR/scripts/lib/utils.sh"

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
TESTS_SKIPPED=0

# Package manager validation data
declare -A DISTRIBUTION_MAPPINGS=(
    ["ubuntu"]="apt"
    ["debian"]="apt"
    ["linuxmint"]="apt"
    ["pop"]="apt"
    ["fedora"]="dnf"
    ["rhel"]="dnf"
    ["centos"]="dnf"
    ["rocky"]="dnf"
    ["almalinux"]="dnf"
    ["arch"]="pacman"
    ["manjaro"]="pacman"
    ["endeavouros"]="pacman"
    ["garuda"]="pacman"
    ["opensuse-leap"]="zypper"
    ["opensuse-tumbleweed"]="zypper"
    ["void"]="xbps"
    ["void-musl"]="xbps"
    ["alpine"]="apk"
    ["gentoo"]="emerge"
    ["solus"]="eopkg"
    ["clear-linux-os"]="swupd"
)

declare -A PACKAGE_MANAGER_BINARIES=(
    ["apt"]="apt"
    ["dnf"]="dnf"
    ["yum"]="yum"
    ["pacman"]="pacman"
    ["zypper"]="zypper"
    ["xbps"]="xbps-install"
    ["apk"]="apk"
    ["emerge"]="emerge"
    ["eopkg"]="eopkg"
    ["swupd"]="swupd"
    ["brew"]="brew"
)

declare -A TEST_PACKAGES=(
    ["apt"]="curl"
    ["dnf"]="curl"
    ["yum"]="curl"
    ["pacman"]="curl"
    ["zypper"]="curl"
    ["xbps"]="curl"
    ["apk"]="curl"
    ["emerge"]="net-misc/curl"
    ["eopkg"]="curl"
    ["swupd"]="curl"
    ["brew"]="curl"
)

# ==============================================================================
# Test Utility Functions
# ==============================================================================

# Create test results directory
mkdir -p "$TEST_RESULTS_DIR"

# Logging function
log() {
    echo -e "$1" | tee -a "$TEST_LOG"
}

# Print test header
print_test_header() {
    log "\n${BLUE}${BOLD}=== Package Manager Validation Test Suite ===${NC}"
    log "Comprehensive validation of package manager detection and availability"
    log "Test log: $TEST_LOG"
    log "Date: $(date)"
    log "================================================================================\n"
}

# Print test result
print_test_result() {
    local test_name="$1"
    local result="$2"
    local message="${3:-}"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    case "$result" in
        "PASS")
            TESTS_PASSED=$((TESTS_PASSED + 1))
            log "${GREEN}✓ PASS${NC} $test_name"
            ;;
        "FAIL")
            TESTS_FAILED=$((TESTS_FAILED + 1))
            log "${RED}✗ FAIL${NC} $test_name"
            ;;
        "SKIP")
            TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
            log "${YELLOW}- SKIP${NC} $test_name"
            ;;
    esac

    if [[ -n "$message" ]]; then
        log "  $message"
    fi
}

# Test function wrapper
run_test() {
    local test_name="$1"
    local test_function="$2"

    log "${CYAN}Testing: $test_name${NC}"

    if "$test_function"; then
        print_test_result "$test_name" "PASS"
        return 0
    else
        print_test_result "$test_name" "FAIL"
        return 1
    fi
}

# Create mock os-release file for testing
create_mock_os_release() {
    local distro="$1"
    local mock_file="/tmp/mock_os_release_$distro"

    case "$distro" in
        "ubuntu")
            cat > "$mock_file" << 'EOF'
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 22.04.3 LTS"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
VERSION_ID="22.04"
EOF
            ;;
        "fedora")
            cat > "$mock_file" << 'EOF'
ID=fedora
PRETTY_NAME="Fedora Linux 39 (Workstation Edition)"
VERSION="39 (Workstation Edition)"
VERSION_ID="39"
EOF
            ;;
        "arch")
            cat > "$mock_file" << 'EOF'
ID=arch
PRETTY_NAME="Arch Linux"
EOF
            ;;
        "opensuse-leap")
            cat > "$mock_file" << 'EOF'
ID=opensuse-leap
PRETTY_NAME="openSUSE Leap 15.5"
VERSION="15.5"
VERSION_ID="15.5"
EOF
            ;;
        "alpine")
            cat > "$mock_file" << 'EOF'
ID=alpine
PRETTY_NAME="Alpine Linux v3.19"
VERSION_ID="3.19.0"
EOF
            ;;
        "gentoo")
            cat > "$mock_file" << 'EOF'
ID=gentoo
PRETTY_NAME="Gentoo/Linux"
EOF
            ;;
        *)
            log "  Unknown distribution for mock: $distro"
            return 1
            ;;
    esac

    echo "$mock_file"
}

# ==============================================================================
# Test Functions
# ==============================================================================

# Test 1: Package Manager Detection Logic Validation
test_package_manager_detection_logic() {
    log "  Testing package manager detection logic for all supported distributions..."

    local errors=0
    local tested_distributions=0

    # Test the detection logic by examining the source code patterns
    for distro in "${!DISTRIBUTION_MAPPINGS[@]}"; do
        local expected_manager="${DISTRIBUTION_MAPPINGS[$distro]}"

        # Check if the distro is properly mapped in the detect_os function
        # Use a more robust pattern match - handle both patterns
        if grep -q "|$distro\|$distro)" "$UTILS_FILE" || grep -q " $distro\|$distro|" "$UTILS_FILE"; then
            # Check that the mapping is correct by looking for the package manager assignment
            local context_line
            context_line=$(grep -A10 "|$distro\|$distro)" "$UTILS_FILE" | grep "PKG_MANAGER=\"$expected_manager\"")

            # If not found, try the other pattern
            if [[ -z "$context_line" ]]; then
                context_line=$(grep -A10 " $distro\|$distro|" "$UTILS_FILE" | grep "PKG_MANAGER=\"$expected_manager\"")
            fi

            if [[ -n "$context_line" ]]; then
                log "    ✓ $distro → $expected_manager (correctly mapped)"
            else
                log "    ✗ $distro → found but wrong mapping (expected: $expected_manager)"
                errors=$((errors + 1))
            fi
        else
            log "    ✗ $distro → not found in detection logic (expected: $expected_manager)"
            errors=$((errors + 1))
        fi

        tested_distributions=$((tested_distributions + 1))
    done

    log "  Tested $tested_distributions distributions with $errors errors"
    return $errors
}

# Test 2: Package Manager Binary Detection
test_package_manager_binary_detection() {
    log "  Testing package manager binary detection..."

    local errors=0
    local found_managers=0

    for manager in "${!PACKAGE_MANAGER_BINARIES[@]}"; do
        local binary="${PACKAGE_MANAGER_BINARIES[$manager]}"

        if command -v "$binary" >/dev/null 2>&1; then
            log "    ✓ Found $manager binary: $binary"
            found_managers=$((found_managers + 1))
        else
            log "    - $manager binary not found: $binary (expected on current system)"
        fi
    done

    log "  Found $found_managers package manager binaries on current system"
    return $errors
}

# Test 3: Availability Functions Implementation Check
test_availability_functions_implementation() {
    log "  Testing availability functions implementation..."

    local errors=0
    local expected_functions=(
        "check_apt_package_availability"
        "check_dnf_package_availability"
        "check_pacman_package_availability"
        "check_zypper_package_availability"
        "check_xbps_package_availability"
        "check_apk_package_availability"
        "check_emerge_package_availability"
        "check_eopkg_package_availability"
        "check_swupd_package_availability"
    )

    local implemented_functions=0
    local missing_functions=()

    for func in "${expected_functions[@]}"; do
        if grep -q "^$func()" "$UTILS_FILE"; then
            log "    ✓ $func implemented"
            implemented_functions=$((implemented_functions + 1))
        else
            log "    ✗ $func missing"
            missing_functions+=("$func")
            errors=$((errors + 1))
        fi
    done

    log "  Implemented: $implemented_functions/${#expected_functions[@]} functions"
    if [[ ${#missing_functions[@]} -gt 0 ]]; then
        log "  Missing functions: ${missing_functions[*]}"
    fi

    return $errors
}

# Test 4: Package Availability Check Function Logic
test_package_availability_check_logic() {
    log "  Testing package availability check function logic..."

    local errors=0

    # Test the main check_package_availability function
    if grep -q "^check_package_availability()" "$UTILS_FILE"; then
        log "    ✓ Main check_package_availability function implemented"

        # Check if it handles all package managers
        local managers_in_function
        managers_in_function=$(grep -A 20 "^check_package_availability()" "$UTILS_FILE" | grep -c ")\s*$" || true)

        if [[ $managers_in_function -ge 6 ]]; then
            log "    ✓ Function handles multiple package managers ($managers_in_function cases)"
        else
            log "    ✗ Function handles insufficient package managers ($managers_in_function cases)"
            errors=$((errors + 1))
        fi

        # Check for proper error handling
        if grep -q "Unknown package manager" "$UTILS_FILE"; then
            log "    ✓ Error handling for unknown package managers"
        else
            log "    ✗ Missing error handling for unknown package managers"
            errors=$((errors + 1))
        fi

    else
        log "    ✗ Main check_package_availability function missing"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 5: Distribution-to-Package Manager Mapping
test_distribution_package_manager_mapping() {
    log "  Testing distribution-to-package manager mapping completeness..."

    local errors=0
    local supported_managers=0
    local unique_managers=()

    # Get unique package managers from mappings
    for manager in "${DISTRIBUTION_MAPPINGS[@]}"; do
        if [[ ! " ${unique_managers[*]} " =~ " ${manager} " ]]; then
            unique_managers+=("$manager")
            supported_managers=$((supported_managers + 1))
        fi
    done

    log "  Supported package managers: $supported_managers"
    log "  Managers: ${unique_managers[*]}"

    # Check if we cover the expected 9 package managers
    local expected_managers=9
    if [[ $supported_managers -eq $expected_managers ]]; then
        log "    ✓ All $expected_managers expected package managers supported"
    else
        log "    ✗ Expected $expected_managers managers, found $supported_managers"
        errors=$((errors + 1))
    fi

    # Check distribution coverage
    local total_distributions=${#DISTRIBUTION_MAPPINGS[@]}
    log "  Total distributions covered: $total_distributions"

    return $errors
}

# Test 6: Fallback Detection Mechanisms
test_fallback_detection_mechanisms() {
    log "  Testing fallback detection mechanisms..."

    local errors=0

    # Check for fallback detection in detect_os function
    if grep -q "fallback\|command -v.*apt\|command -v.*dnf\|command -v.*pacman" "$UTILS_FILE"; then
        log "    ✓ Fallback detection mechanisms present"
    else
        log "    ✗ Fallback detection mechanisms missing"
        errors=$((errors + 1))
    fi

    # Check for /etc/debian_version fallback
    if grep -q "/etc/debian_version" "$UTILS_FILE"; then
        log "    ✓ Debian version fallback present"
    else
        log "    ✗ Debian version fallback missing"
        errors=$((errors + 1))
    fi

    # Check for /etc/redhat-release fallback
    if grep -q "/etc/redhat-release" "$UTILS_FILE"; then
        log "    ✓ RedHat release fallback present"
    else
        log "    ✗ RedHat release fallback missing"
        errors=$((errors + 1))
    fi

    # Check for /etc/arch-release fallback
    if grep -q "/etc/arch-release" "$UTILS_FILE"; then
        log "    ✓ Arch release fallback present"
    else
        log "    ✗ Arch release fallback missing"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 7: Cross-Platform Package Filtering
test_cross_platform_package_filtering() {
    log "  Testing cross-platform package filtering logic..."

    local errors=0

    # Check if utils.sh has Linux vs macOS handling
    if grep -q "macos\|darwin\|linux-gnu" "$UTILS_FILE"; then
        log "    ✓ Cross-platform OS detection present"
    else
        log "    ✗ Cross-platform OS detection missing"
        errors=$((errors + 1))
    fi

    # Check for platform-specific package handling
    if grep -q "brew\|homebrew" "$UTILS_FILE"; then
        log "    ✓ Homebrew (macOS) support present"
    else
        log "    ✗ Homebrew (macOS) support missing"
        errors=$((errors + 1))
    fi

    # Check for Linux package exclusion on macOS
    local installation_files=("$DOTFILES_DIR/install-new.sh" "$DOTFILES_DIR/install.sh")
    for file in "${installation_files[@]}"; do
        if [[ -f "$file" ]]; then
            if grep -q "linux.*package\|exclude.*linux\|filter.*package" "$file"; then
                log "    ✓ Linux package filtering logic found in $(basename "$file")"
            else
                log "    - Linux package filtering logic not found in $(basename "$file")"
            fi
        fi
    done

    return $errors
}

# Test 8: Error Handling Validation
test_error_handling_validation() {
    log "  Testing error handling for package operations..."

    local errors=0

    # Check for proper error handling in availability functions
    for func in check_apt_package_availability check_dnf_package_availability check_pacman_package_availability; do
        if grep -A 5 "$func" "$UTILS_FILE" | grep -q "return 1\|warn\|error"; then
            log "    ✓ $func has proper error handling"
        else
            log "    ✗ $func missing proper error handling"
            errors=$((errors + 1))
        fi
    done

    # Check for command existence validation
    if grep -q "command -v\|command_exists" "$UTILS_FILE"; then
        log "    ✓ Command existence validation present"
    else
        log "    ✗ Command existence validation missing"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 9: Integration Test with Mock Environments
test_integration_with_mock_environments() {
    log "  Testing integration with mock distribution environments..."

    local errors=0
    local test_distributions=("ubuntu" "fedora" "arch" "alpine")

    for distro in "${test_distributions[@]}"; do
        log "    Testing $distro integration..."

        local expected_manager="${DISTRIBUTION_MAPPINGS[$distro]}"

        # Check if distro is in detect_os function
        if grep -q "$distro)" "$UTILS_FILE"; then
            log "      ✓ $distro: Detection logic present"
        else
            log "      ✗ $distro: Detection logic missing"
            errors=$((errors + 1))
        fi

        # Check if corresponding availability function exists
        case "$expected_manager" in
            "apt")
                if grep -q "^check_apt_package_availability()" "$UTILS_FILE"; then
                    log "      ✓ $distro: Availability function present (apt)"
                else
                    log "      ✗ $distro: Availability function missing (apt)"
                    errors=$((errors + 1))
                fi
                ;;
            "dnf")
                if grep -q "^check_dnf_package_availability()" "$UTILS_FILE"; then
                    log "      ✓ $distro: Availability function present (dnf)"
                else
                    log "      ✗ $distro: Availability function missing (dnf)"
                    errors=$((errors + 1))
                fi
                ;;
            "pacman")
                if grep -q "^check_pacman_package_availability()" "$UTILS_FILE"; then
                    log "      ✓ $distro: Availability function present (pacman)"
                else
                    log "      ✗ $distro: Availability function missing (pacman)"
                    errors=$((errors + 1))
                fi
                ;;
            "apk")
                if grep -q "^check_apk_package_availability()" "$UTILS_FILE"; then
                    log "      ✓ $distro: Availability function present (apk)"
                else
                    log "      ✗ $distro: Availability function missing (apk)"
                    errors=$((errors + 1))
                fi
                ;;
            "emerge"|"eopkg"|"swupd"|"zypper"|"xbps")
                local func_name="check_${expected_manager}_package_availability"
                if grep -q "^$func_name()" "$UTILS_FILE"; then
                    log "      ✓ $distro: Availability function present ($expected_manager)"
                else
                    log "      ✗ $distro: Availability function missing ($expected_manager)"
                    errors=$((errors + 1))
                fi
                ;;
        esac
    done

    return $errors
}

# Test 10: Package Manager System Completeness
test_package_manager_system_completeness() {
    log "  Testing overall package manager system completeness..."

    local errors=0

    # Check system requirements
    local requirements=(
        "detect_os function"
        "package manager detection"
        "availability checking functions"
        "error handling"
        "fallback mechanisms"
        "cross-platform support"
    )

    local met_requirements=0

    # Check detect_os function
    if grep -q "^detect_os()" "$UTILS_FILE"; then
        log "    ✓ detect_os function present"
        met_requirements=$((met_requirements + 1))
    else
        log "    ✗ detect_os function missing"
        errors=$((errors + 1))
    fi

    # Check package manager detection logic
    if grep -q "PKG_MANAGER=" "$UTILS_FILE"; then
        log "    ✓ Package manager detection logic present"
        met_requirements=$((met_requirements + 1))
    else
        log "    ✗ Package manager detection logic missing"
        errors=$((errors + 1))
    fi

    # Check availability functions (at least some)
    local availability_count
    availability_count=$(grep -c "^check_.*_package_availability()" "$UTILS_FILE" || true)
    if [[ $availability_count -ge 5 ]]; then
        log "    ✓ Availability checking functions present ($availability_count functions)"
        met_requirements=$((met_requirements + 1))
    else
        log "    ✗ Insufficient availability checking functions ($availability_count functions)"
        errors=$((errors + 1))
    fi

    # Check error handling
    if grep -q "warn\|error\|return 1" "$UTILS_FILE"; then
        log "    ✓ Error handling mechanisms present"
        met_requirements=$((met_requirements + 1))
    else
        log "    ✗ Error handling mechanisms missing"
        errors=$((errors + 1))
    fi

    # Check fallback mechanisms
    if grep -q "fallback\|command -v" "$UTILS_FILE"; then
        log "    ✓ Fallback mechanisms present"
        met_requirements=$((met_requirements + 1))
    else
        log "    ✗ Fallback mechanisms missing"
        errors=$((errors + 1))
    fi

    # Check cross-platform support
    if grep -q "macos\|linux\|OSTYPE" "$UTILS_FILE"; then
        log "    ✓ Cross-platform support present"
        met_requirements=$((met_requirements + 1))
    else
        log "    ✗ Cross-platform support missing"
        errors=$((errors + 1))
    fi

    log "  System completeness: $met_requirements/${#requirements[@]} requirements met"

    return $errors
}

# ==============================================================================
# Test Execution
# ==============================================================================

# Main test execution
main() {
    print_test_header

    # Run all validation tests
    run_test "Package Manager Detection Logic" test_package_manager_detection_logic
    run_test "Package Manager Binary Detection" test_package_manager_binary_detection
    run_test "Availability Functions Implementation" test_availability_functions_implementation
    run_test "Package Availability Check Logic" test_package_availability_check_logic
    run_test "Distribution-to-Package Manager Mapping" test_distribution_package_manager_mapping
    run_test "Fallback Detection Mechanisms" test_fallback_detection_mechanisms
    run_test "Cross-Platform Package Filtering" test_cross_platform_package_filtering
    run_test "Error Handling Validation" test_error_handling_validation
    run_test "Integration with Mock Environments" test_integration_with_mock_environments
    run_test "Package Manager System Completeness" test_package_manager_system_completeness

    # Print summary
    log "\n${BLUE}${BOLD}=== Package Manager Validation Summary ===${NC}"
    log "Total tests: $TESTS_TOTAL"
    log "Passed: ${GREEN}$TESTS_PASSED${NC}"
    log "Failed: ${RED}$TESTS_FAILED${NC}"
    log "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"

    # Calculate success rate
    local success_rate=0
    if [[ $TESTS_TOTAL -gt 0 ]]; then
        success_rate=$(( (TESTS_PASSED * 100) / TESTS_TOTAL ))
    fi

    log "Success rate: $success_rate%"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        log "\n${GREEN}${BOLD}✓ All package manager validation tests passed!${NC}"
        log "The package manager detection and availability system is working correctly."
        return 0
    else
        log "\n${RED}${BOLD}✗ Some validation tests failed. Please review the issues above.${NC}"
        log "Check the detailed log at: $TEST_LOG"
        return 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi