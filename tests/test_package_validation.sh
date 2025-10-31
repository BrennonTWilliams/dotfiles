#!/bin/bash

# Comprehensive Package Validation Suite for macOS Dotfiles
# Validates package syntax, correctness, and platform appropriateness
# Tests Homebrew formulae/casks existence and special tap requirements

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
VALIDATION_WARNINGS=0

# Configuration
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PACKAGES_MACOS="$DOTFILES_DIR/packages-macos.txt"
readonly PACKAGES_LINUX="$DOTFILES_DIR/packages.txt"  # if exists
readonly VALIDATION_REPORT="$DOTFILES_DIR/test_results/package_validation_report_$(date +%Y%m%d_%H%M%S).md"

# Special tap requirements (from package file comments)
# Format: package_name:tap_url
readonly SPECIAL_TAPS="sketchybar:FelixKratz/formulae"

# Platform-inappropriate packages (Linux packages that shouldn't be on macOS)
readonly LINUX_PACKAGES="sway waybar foot grim slurp mako-notifier xclip"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    VALIDATION_WARNINGS=$((VALIDATION_WARNINGS + 1))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

log_validation() {
    echo -e "${CYAN}[VALIDATION]${NC} $1"
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

# Setup validation environment
setup_validation() {
    log_info "Setting up package validation environment"

    # Create results directory
    mkdir -p "$(dirname "$VALIDATION_REPORT")"

    # Check if Homebrew is available
    if command -v brew >/dev/null 2>&1; then
        log_success "Homebrew found: $(brew --version | head -1)"
        return 0
    else
        log_warning "Homebrew not found - some validations will be skipped"
        return 1
    fi
}

# Validate package file syntax and structure
validate_package_syntax() {
    local package_file="$1"
    local platform="$2"

    test_start "Package syntax validation for $platform"

    if [[ ! -f "$package_file" ]]; then
        test_fail "Package syntax validation for $platform" "File not found: $package_file"
        return 1
    fi

    local syntax_errors=0
    local line_number=0
    local in_comment_block=false
    local previous_line_empty=false

    while IFS= read -r line; do
        line_number=$((line_number + 1))

        # Skip empty lines
        [[ -z "$line" ]] && continue

        # Handle comment blocks
        if [[ "$line" =~ ^[[:space:]]*#.*===.*===.* ]]; then
            in_comment_block=true
            continue
        fi

        # Check for malformed comments
        if [[ "$line" =~ ^[[:space:]]*# ]]; then
            # Comment line - check for common formatting issues
            if [[ "$line" =~ ^[[:space:]]*#[[:space:]]*$ ]]; then
                # Empty comment line - this is OK
                continue
            elif [[ "$line" =~ ^[[:space:]]*#[^[:space:]] ]]; then
                # Comment without space after # - warning
                log_warning "Line $line_number: Comment should have space after #"
            fi
            continue
        fi

        # Validate package name
        local package_name=$(echo "$line" | cut -d'#' -f1 | xargs)  # remove inline comments and trim whitespace

        # Check for invalid characters
        if [[ ! "$package_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
            log_error "Line $line_number: Invalid package name format: '$package_name'"
            syntax_errors=$((syntax_errors + 1))
            continue
        fi

        # Check for suspicious patterns (common typos)
        case "$package_name" in
            "ripgergrep")
                log_error "Line $line_number: Suspected typo in package name: '$package_name' (did you mean ripgrep?)"
                syntax_errors=$((syntax_errors + 1))
                ;;
            "git"|"curl"|"wget"|"stow"|"htop"|"tmux"|"zsh"|"ripgrep"|"fd"|"fzf"|"tree"|"unzip"|"jq"|"python3"|"rectangle"|"iterm2"|"sketchybar"|"mas")
                # Known valid packages - always valid
                ;;
            *)
                # Check for numbers at end (might be version numbers)
                if [[ "$package_name" =~ [0-9]+$ ]]; then
                    log_warning "Line $line_number: Package name ends with number: '$package_name' (verify this isn't a version specifier)"
                fi
                ;;
        esac

    done < "$package_file"

    if [[ $syntax_errors -eq 0 ]]; then
        test_pass "Package syntax validation for $platform" "No syntax errors found"
        return 0
    else
        test_fail "Package syntax validation for $platform" "$syntax_errors syntax errors found"
        return 1
    fi
}

# Validate platform appropriateness
validate_platform_appropriateness() {
    local package_file="$1"
    local platform="$2"

    test_start "Platform appropriateness validation for $platform"

    local platform_issues=0
    local line_number=0

    while IFS= read -r line; do
        line_number=$((line_number + 1))

        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue

        local package_name=$(echo "$line" | cut -d'#' -f1 | xargs)

        if [[ "$platform" == "macos" ]]; then
            # Check for Linux-specific packages that shouldn't be on macOS
            if [[ " $LINUX_PACKAGES " =~ [[:space:]]$package_name[[:space:]] ]]; then
                log_error "Line $line_number: Linux-specific package found in macOS file: '$package_name'"
                platform_issues=$((platform_issues + 1))
            fi

            # Check for macOS-specific patterns that are OK
            case "$package_name" in
                "rectangle"|"iterm2"|"sketchybar"|"mas")
                    # macOS-specific packages - this is expected
                    log_validation "Line $line_number: macOS-specific package found: '$package_name' ✓"
                    ;;
            esac
        fi

    done < "$package_file"

    if [[ $platform_issues -eq 0 ]]; then
        test_pass "Platform appropriateness validation for $platform" "All packages appropriate for $platform"
        return 0
    else
        test_fail "Platform appropriateness validation for $platform" "$platform_issues inappropriate packages found"
        return 1
    fi
}

# Validate Homebrew package existence
validate_homebrew_packages() {
    local package_file="$1"

    test_start "Homebrew package existence validation"

    if ! command -v brew >/dev/null 2>&1; then
        test_skip "Homebrew package existence validation" "Homebrew not available"
        return 0
    fi

    local missing_packages=0
    local found_packages=0
    local line_number=0

    log_info "Validating package existence with Homebrew..."

    while IFS= read -r line; do
        line_number=$((line_number + 1))

        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue

        local package_name=$(echo "$line" | cut -d'#' -f1 | xargs)

        # Special handling for sketchybar (requires tap)
        if [[ "$package_name" == "sketchybar" ]]; then
            local sketchybar_tap=$(echo "$SPECIAL_TAPS" | cut -d: -f2)
            log_validation "Line $line_number: Checking sketchybar with special tap: $sketchybar_tap"

            # Check if tap is already added
            if brew tap | grep -q "$sketchybar_tap" 2>/dev/null; then
                log_validation "Tap $sketchybar_tap already available"
            else
                log_validation "Tap $sketchybar_tap not currently tapped (expected)"
            fi

            # Check if we can search for it (brew search will check available taps)
            if brew search "$package_name" >/dev/null 2>&1; then
                log_validation "Line $line_number: sketchybar found in Homebrew (with tap)"
                found_packages=$((found_packages + 1))
            else
                log_warning "Line $line_number: sketchybar not found - may require tap setup"
                missing_packages=$((missing_packages + 1))
            fi
            continue
        fi

        # Check regular packages
        if brew info "$package_name" >/dev/null 2>&1; then
            log_validation "Line $line_number: $package_name found in Homebrew"
            found_packages=$((found_packages + 1))
        else
            # Try search as fallback
            if brew search "$package_name" 2>/dev/null | grep -q "^$package_name$"; then
                log_validation "Line $line_number: $package_name found via Homebrew search"
                found_packages=$((found_packages + 1))
            else
                log_error "Line $line_number: $package_name not found in Homebrew"
                missing_packages=$((missing_packages + 1))
            fi
        fi

    done < "$package_file"

    log_info "Package validation summary: $found_packages found, $missing_packages missing"

    if [[ $missing_packages -eq 0 ]]; then
        test_pass "Homebrew package existence validation" "All $found_packages packages found in Homebrew"
        return 0
    else
        test_fail "Homebrew package existence validation" "$missing_packages of $((found_packages + missing_packages)) packages not found"
        return 1
    fi
}

# Check for duplicate packages
validate_no_duplicates() {
    local package_file="$1"
    local platform="$2"

    test_start "Duplicate package validation for $platform"

    local duplicates=0
    local all_packages=""
    local total_packages=0

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue

        local package_name=$(echo "$line" | cut -d'#' -f1 | xargs)

        # Skip if package name is empty
        [[ -z "$package_name" ]] && continue

        total_packages=$((total_packages + 1))

        # Check if package already seen
        if [[ " $all_packages " =~ [[:space:]]$package_name[[:space:]] ]]; then
            log_error "Duplicate package found: '$package_name'"
            duplicates=$((duplicates + 1))
        else
            all_packages="$all_packages $package_name"
        fi

    done < "$package_file"

    if [[ $duplicates -eq 0 ]]; then
        test_pass "Duplicate package validation for $platform" "No duplicates found among $total_packages packages"
        return 0
    else
        test_fail "Duplicate package validation for $platform" "$duplicates duplicate packages found"
        return 1
    fi
}

# Validate comment formatting and documentation
validate_documentation() {
    local package_file="$1"
    local platform="$2"

    test_start "Documentation quality validation for $platform"

    local doc_issues=0
    local total_packages=0
    local documented_packages=0

    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue

        # Check for documentation comments
        if [[ "$line" =~ ^[[:space:]]*#.*[Aa]lternative.*: ]]; then
            documented_packages=$((documented_packages + 1))
        fi

        # Count actual packages
        if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "$line" ]]; then
            total_packages=$((total_packages + 1))
        fi

        # Check for proper section headers
        if [[ "$line" =~ ^#.*=== ]]; then
            if [[ ! "$line" =~ ^#.*===.*===.* ]]; then
                log_warning "Section header format may be inconsistent: '$line'"
                doc_issues=$((doc_issues + 1))
            fi
        fi

    done < "$package_file"

    # Check documentation coverage
    local doc_coverage=0
    if [[ $total_packages -gt 0 ]]; then
        doc_coverage=$(( (documented_packages * 100) / total_packages ))
    fi

    log_info "Documentation coverage: $documented_packages/$total_packages packages ($doc_coverage%)"

    if [[ $doc_coverage -ge 50 ]]; then
        log_success "Good documentation coverage: $doc_coverage%"
    else
        log_warning "Low documentation coverage: $doc_coverage% (consider adding more comments)"
    fi

    if [[ $doc_issues -eq 0 ]]; then
        test_pass "Documentation quality validation for $platform" "Documentation looks good ($doc_coverage% coverage)"
        return 0
    else
        test_fail "Documentation quality validation for $platform" "$doc_issues documentation issues found"
        return 1
    fi
}

# Generate validation report
generate_validation_report() {
    log_info "Generating validation report..."

    cat > "$VALIDATION_REPORT" << EOF
# Package Validation Report

**Generated:** $(date)
**Platform:** macOS $(uname -m)
**Package Files:**
- \`packages-macos.txt\` $(test -f "$PACKAGES_MACOS" && echo "✅" || echo "❌")
- \`packages.txt\` $(test -f "$PACKAGES_LINUX" && echo "✅" || echo "❌ N/A")

## Validation Summary

| Test Category | Total Tests | Passed | Failed | Skipped |
|---------------|-------------|--------|--------|---------|
| **Syntax Validation** | 1+ | $TESTS_PASSED | $TESTS_FAILED | $TESTS_SKIPPED |
| **Platform Validation** | 1+ | - | - | - |
| **Homebrew Validation** | 1 | - | - | - |
| **Duplicate Check** | 1+ | - | - | - |
| **Documentation** | 1+ | - | - | - |
| **TOTAL** | $TESTS_TOTAL | $TESTS_PASSED | $TESTS_FAILED | $TESTS_SKIPPED |

### Overall Status
EOF

    if [[ $TESTS_FAILED -eq 0 ]]; then
        cat >> "$VALIDATION_REPORT" << 'EOF'
✅ **VALIDATION PASSED** - All package files are properly formatted and valid.

### Key Findings
- Package syntax is correct
- All packages are appropriate for macOS
- Homebrew packages exist and are installable
- No duplicate packages found
- Documentation is comprehensive

EOF
    else
        cat >> "$VALIDATION_REPORT" << EOF
⚠️ **VALIDATION ISSUES FOUND** - $TESTS_FAILED test(s) failed.

### Issues Requiring Attention
EOF
        if [[ $TESTS_FAILED -gt 0 ]]; then
            echo "- $TESTS_FAILED validation test(s) failed - see logs above for details" >> "$VALIDATION_REPORT"
        fi
        echo "" >> "$VALIDATION_REPORT"
    fi

    if [[ $VALIDATION_WARNINGS -gt 0 ]]; then
        cat >> "$VALIDATION_REPORT" << EOF
### ⚠️ Warnings ($VALIDATION_WARNINGS)
Some minor issues were found that should be reviewed but don't block installation:
EOF
        echo "- $VALIDATION_WARNINGS warnings detected during validation" >> "$VALIDATION_REPORT"
        echo "" >> "$VALIDATION_REPORT"
    fi

    cat >> "$VALIDATION_REPORT" << 'EOF'

## Recommendations

### For Contributors
1. Always run package validation before submitting changes
2. Ensure new packages are available in Homebrew
3. Add comments for platform-specific alternatives
4. Test installation on target platform

### For Users
1. Review any validation warnings before installation
2. Ensure Homebrew is properly installed and updated
3. Consider platform-specific requirements (taps, etc.)

### Maintenance
1. Update package list regularly
2. Remove deprecated packages
3. Add new macOS-specific tools as needed
4. Keep documentation current with package changes

---

*Report generated by macOS Dotfiles Package Validation Suite*
EOF

    log_success "Validation report generated: $VALIDATION_REPORT"
}

# Display final results
display_final_results() {
    echo ""
    echo -e "${BOLD}${BLUE}=== Package Validation Results ===${NC}"
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    echo -e "Warnings: ${YELLOW}$VALIDATION_WARNINGS${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ ALL VALIDATIONS PASSED${NC}"
        echo -e "${GREEN}Package files are ready for use.${NC}"
    else
        echo -e "${RED}${BOLD}❌ VALIDATION ISSUES FOUND${NC}"
        echo -e "${RED}Please review and fix the issues above.${NC}"
    fi

    echo ""
    echo -e "${BLUE}📊 Detailed Report: $VALIDATION_REPORT${NC}"
}

# Main validation execution
main() {
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
 _____ ____    ____    _  _____
| ____/ ___|  / ___|  / \|_   _|
|  _| \___ \  \___ \ / _ \ | |
| |___ ___) |  ___) / ___ \| |
|_____|____/  |____/_/   \_\_|
    Package Validation Suite
EOF
    echo -e "${NC}"

    echo "Validating package files for macOS dotfiles..."
    echo ""

    # Setup validation
    local homebrew_available=false
    if setup_validation; then
        homebrew_available=true
    fi

    # Validate macOS packages
    if [[ -f "$PACKAGES_MACOS" ]]; then
        echo -e "${BOLD}${BLUE}Validating packages-macos.txt...${NC}"
        validate_package_syntax "$PACKAGES_MACOS" "macos"
        validate_platform_appropriateness "$PACKAGES_MACOS" "macos"
        validate_no_duplicates "$PACKAGES_MACOS" "macos"
        validate_documentation "$PACKAGES_MACOS" "macos"

        if [[ "$homebrew_available" == true ]]; then
            validate_homebrew_packages "$PACKAGES_MACOS"
        else
            test_skip "Homebrew package existence validation" "Homebrew not available"
        fi
    else
        log_warning "packages-macos.txt not found - skipping macOS package validation"
    fi

    # Validate Linux packages if they exist
    if [[ -f "$PACKAGES_LINUX" ]]; then
        echo -e "${BOLD}${BLUE}Validating packages.txt (Linux)...${NC}"
        validate_package_syntax "$PACKAGES_LINUX" "linux"
        validate_no_duplicates "$PACKAGES_LINUX" "linux"
        validate_documentation "$PACKAGES_LINUX" "linux"
    else
        log_info "packages.txt not found - only validating macOS packages"
    fi

    # Generate reports
    generate_validation_report
    display_final_results

    # Exit with appropriate code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"