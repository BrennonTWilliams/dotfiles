#!/usr/bin/env bash

# Quick Package Manager Validation
set -euo pipefail

UTILS_FILE="$(dirname "$0")/../scripts/lib/utils.sh"

echo "=== Quick Package Manager Validation ==="

# Check detection logic
echo "1. Distribution Detection Logic:"
distributions=("ubuntu" "debian" "fedora" "arch" "alpine" "gentoo" "solus" "void" "opensuse-leap")
for distro in "${distributions[@]}"; do
    if grep -q "$distro" "$UTILS_FILE"; then
        echo "  ✓ $distro found"
    else
        echo "  ✗ $distro missing"
    fi
done

# Check availability functions
echo -e "\n2. Availability Functions:"
functions=("check_apt_package_availability" "check_dnf_package_availability" "check_pacman_package_availability" "check_zypper_package_availability" "check_xbps_package_availability" "check_apk_package_availability" "check_emerge_package_availability" "check_eopkg_package_availability" "check_swupd_package_availability")
implemented=0
missing=0
for func in "${functions[@]}"; do
    if grep -q "^$func()" "$UTILS_FILE"; then
        echo "  ✓ $func implemented"
        implemented=$((implemented + 1))
    else
        echo "  ✗ $func missing"
        missing=$((missing + 1))
    fi
done

echo -e "\n3. Summary:"
echo "  Implemented: $implemented/${#functions[@]} functions"
echo "  Missing: $missing functions"

# Check main function
echo -e "\n4. Main check_package_availability function:"
if grep -q "^check_package_availability()" "$UTILS_FILE"; then
    echo "  ✓ Main function implemented"

    # Count cases in main function
    cases=$(grep -A 50 "^check_package_availability()" "$UTILS_FILE" | grep -E "^\s*[a-z]+\)|dnf\|yum" | wc -l || echo "0")
    echo "  - Handles $cases package manager cases (including dnf|yum and brew)"

    # Check specific managers
    managers=("apt" "dnf|yum" "pacman" "zypper" "xbps" "apk" "emerge" "eopkg" "swupd" "brew")
    for manager in "${managers[@]}"; do
        if grep -A 50 "^check_package_availability()" "$UTILS_FILE" | grep -q "$manager)"; then
            echo "  - ✓ $manager handled"
        else
            echo "  - ✗ $manager missing"
        fi
    done
else
    echo "  ✗ Main function missing"
fi

# Check error handling
echo -e "\n5. Error Handling:"
if grep -q "warn\|error\|return 1" "$UTILS_FILE"; then
    echo "  ✓ Error handling present"
else
    echo "  ✗ Error handling missing"
fi

# Check cross-platform support
echo -e "\n6. Cross-Platform Support:"
if grep -q "macos\|linux\|brew" "$UTILS_FILE"; then
    echo "  ✓ Cross-platform support present"
else
    echo "  ✗ Cross-platform support missing"
fi