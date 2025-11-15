#!/usr/bin/env bash

# ==============================================================================
# ShellCheck Runner Script
# ==============================================================================
# Runs ShellCheck on all shell scripts in the dotfiles repository
# Usage:
#   ./scripts/run-shellcheck.sh              # Run on all scripts
#   ./scripts/run-shellcheck.sh --fix        # Show fixable issues
#   ./scripts/run-shellcheck.sh --summary    # Show summary only
#   ./scripts/run-shellcheck.sh <file>       # Run on specific file
# ==============================================================================

set -euo pipefail

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ==============================================================================
# Helper Functions
# ==============================================================================

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

section() {
    echo -e "\n${BLUE}${BOLD}===${NC} ${BOLD}$1${NC} ${BLUE}${BOLD}===${NC}\n"
}

success() {
    echo -e "${GREEN}${BOLD}✓${NC} $1"
}

# Check if shellcheck is installed
check_shellcheck() {
    if ! command -v shellcheck &> /dev/null; then
        error "ShellCheck is not installed!"
        echo
        echo "Install ShellCheck:"
        echo "  macOS:   brew install shellcheck"
        echo "  Ubuntu:  sudo apt install shellcheck"
        echo "  Fedora:  sudo dnf install ShellCheck"
        echo "  Arch:    sudo pacman -S shellcheck"
        echo
        exit 1
    fi

    local version
    version=$(shellcheck --version | grep "^version:" | awk '{print $2}')
    info "Using ShellCheck version $version"
}

# Find all shell scripts in the repository
find_shell_scripts() {
    local scripts=()

    # Find scripts by shebang
    while IFS= read -r file; do
        scripts+=("$file")
    done < <(find "$DOTFILES_DIR" -type f -not -path "*/.git/*" -not -path "*/node_modules/*" -exec grep -l "^#!/.*sh" {} \; 2>/dev/null | sort)

    # Find .sh files that might not have shebang
    while IFS= read -r file; do
        # Check if already in list
        local found=0
        for existing in "${scripts[@]}"; do
            if [[ "$existing" == "$file" ]]; then
                found=1
                break
            fi
        done
        if [[ $found -eq 0 ]]; then
            scripts+=("$file")
        fi
    done < <(find "$DOTFILES_DIR" -type f -name "*.sh" -not -path "*/.git/*" -not -path "*/node_modules/*" | sort)

    printf '%s\n' "${scripts[@]}"
}

# Run shellcheck on a single file
check_file() {
    local file="$1"
    local show_fix="$2"

    local relative_path="${file#$DOTFILES_DIR/}"

    if [[ "$show_fix" == "true" ]]; then
        # Show only auto-fixable issues
        if shellcheck -f diff "$file" 2>/dev/null | grep -q "^---"; then
            echo -e "${CYAN}$relative_path${NC} (has auto-fixable issues)"
            shellcheck -f diff "$file" 2>/dev/null
            return 1
        fi
        return 0
    else
        # Normal check
        if shellcheck "$file" 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

# Print summary statistics
print_summary() {
    local total="$1"
    local passed="$2"
    local failed="$3"

    section "Summary"

    echo "Total scripts checked: $total"
    echo -e "${GREEN}Passed: $passed${NC}"

    if [[ $failed -gt 0 ]]; then
        echo -e "${RED}Failed: $failed${NC}"
    else
        echo -e "${GREEN}Failed: $failed${NC}"
    fi

    if [[ $failed -eq 0 ]]; then
        success "All scripts passed ShellCheck!"
        return 0
    else
        local percentage=$((passed * 100 / total))
        warn "Pass rate: ${percentage}%"
        return 1
    fi
}

# ==============================================================================
# Main Function
# ==============================================================================

main() {
    local mode="normal"
    local target_file=""

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --fix)
                mode="fix"
                ;;
            --summary)
                mode="summary"
                ;;
            --help|-h)
                cat << EOF
Usage: $0 [OPTIONS] [FILE]

Options:
  --fix        Show auto-fixable issues in diff format
  --summary    Show only summary statistics
  --help, -h   Show this help message

Arguments:
  FILE         Check specific file (optional)

Examples:
  $0                    # Check all scripts
  $0 --summary          # Check all and show summary only
  $0 --fix              # Show fixable issues
  $0 install.sh         # Check specific file
EOF
                exit 0
                ;;
            -*)
                error "Unknown option: $arg"
                exit 1
                ;;
            *)
                target_file="$arg"
                ;;
        esac
    done

    section "ShellCheck Analysis"

    # Check if shellcheck is installed
    check_shellcheck

    # Find scripts to check
    local scripts=()
    if [[ -n "$target_file" ]]; then
        if [[ ! -f "$target_file" ]]; then
            error "File not found: $target_file"
            exit 1
        fi
        scripts=("$target_file")
        info "Checking single file: $target_file"
    else
        info "Finding shell scripts..."
        while IFS= read -r script; do
            scripts+=("$script")
        done < <(find_shell_scripts)
        info "Found ${#scripts[@]} shell scripts"
    fi

    if [[ ${#scripts[@]} -eq 0 ]]; then
        warn "No shell scripts found"
        exit 0
    fi

    # Run shellcheck on all scripts
    echo
    local total=0
    local passed=0
    local failed=0
    local failed_files=()

    for script in "${scripts[@]}"; do
        total=$((total + 1))

        local relative_path="${script#$DOTFILES_DIR/}"

        if [[ "$mode" != "summary" ]]; then
            echo -e "${CYAN}Checking:${NC} $relative_path"
        fi

        if check_file "$script" "$([[ "$mode" == "fix" ]] && echo "true" || echo "false")"; then
            passed=$((passed + 1))
            if [[ "$mode" != "summary" ]]; then
                success "Passed"
            fi
        else
            failed=$((failed + 1))
            failed_files+=("$relative_path")
            if [[ "$mode" != "summary" ]]; then
                error "Failed"
            fi
        fi

        if [[ "$mode" != "summary" ]]; then
            echo
        fi
    done

    # Print summary
    print_summary "$total" "$passed" "$failed"

    # List failed files
    if [[ ${#failed_files[@]} -gt 0 ]]; then
        echo
        echo -e "${YELLOW}Files with issues:${NC}"
        for file in "${failed_files[@]}"; do
            echo "  - $file"
        done
        echo
        echo "Run with --fix to see auto-fixable issues"
        echo "Or run: shellcheck <file> for detailed output"
    fi

    exit $([[ $failed -eq 0 ]] && echo 0 || echo 1)
}

# Run main function
main "$@"
