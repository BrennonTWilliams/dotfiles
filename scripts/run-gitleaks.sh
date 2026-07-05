#!/usr/bin/env bash

# ==============================================================================
# Gitleaks Runner Script
# ==============================================================================
# Scans the repository for hardcoded secrets using gitleaks.
# Usage:
#   ./scripts/run-gitleaks.sh              # Scan full repo history
#   ./scripts/run-gitleaks.sh --staged     # Scan staged changes (pre-commit)
# ==============================================================================

set -euo pipefail

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gitleaks is installed
check_gitleaks() {
    if ! command -v gitleaks &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} gitleaks is not installed!"
        echo
        echo "Install gitleaks:"
        echo "  macOS:   brew install gitleaks"
        echo "  Linux:   see https://github.com/gitleaks/gitleaks#installing"
        echo
        exit 1
    fi
}

main() {
    local mode="repo"

    for arg in "$@"; do
        case "$arg" in
            --staged)
                mode="staged"
                ;;
            --help|-h)
                cat << EOF
Usage: $0 [OPTIONS]

Options:
  --staged     Scan only staged changes (used by the pre-commit hook)
  --help, -h   Show this help message

Examples:
  $0             # Scan full repo history
  $0 --staged    # Scan staged changes
EOF
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR]${NC} Unknown option: $arg"
                exit 1
                ;;
        esac
    done

    check_gitleaks

    cd "$DOTFILES_DIR" || exit 1

    if [[ "$mode" == "staged" ]]; then
        echo -e "${YELLOW}Scanning staged changes for secrets...${NC}"
        echo
        if gitleaks protect --staged --redact -v; then
            echo
            echo -e "${GREEN}✓ No secrets detected in staged changes${NC}"
        else
            echo
            echo -e "${RED}✗ Potential secrets detected in staged changes${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}Scanning repository history for secrets...${NC}"
        echo
        if gitleaks git --redact -v; then
            echo
            echo -e "${GREEN}✓ No secrets detected${NC}"
        else
            echo
            echo -e "${RED}✗ Potential secrets detected${NC}"
            return 1
        fi
    fi
}

main "$@"
