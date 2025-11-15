#!/usr/bin/env bash

# ==============================================================================
# Semantic Versioning Management Script
# ==============================================================================
# This script manages semantic versioning for the dotfiles repository.
# It handles version bumping, CHANGELOG updates, and git tagging.
#
# Usage:
#   ./scripts/version.sh current                    # Show current version
#   ./scripts/version.sh bump major                 # Bump major version (breaking changes)
#   ./scripts/version.sh bump minor                 # Bump minor version (new features)
#   ./scripts/version.sh bump patch                 # Bump patch version (bug fixes)
#   ./scripts/version.sh tag                        # Create git tag for current version
#   ./scripts/version.sh validate                   # Validate VERSION file and CHANGELOG
#
# Semantic Versioning (SemVer 2.0.0):
#   MAJOR.MINOR.PATCH
#   - MAJOR: Incompatible changes (breaking changes)
#   - MINOR: Backwards-compatible new features
#   - PATCH: Backwards-compatible bug fixes
# ==============================================================================

set -euo pipefail

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$REPO_ROOT/VERSION"
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${CYAN}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
section() { echo -e "\n${BLUE}==>${NC} $*\n"; }

# Validate that we're in a git repository
validate_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository"
        exit 1
    fi
}

# Read current version from VERSION file
get_current_version() {
    if [ ! -f "$VERSION_FILE" ]; then
        error "VERSION file not found at: $VERSION_FILE"
        exit 1
    fi

    local version
    version=$(cat "$VERSION_FILE" | tr -d '[:space:]')
    echo "$version"
}

# Validate semantic version format
validate_semver() {
    local version="$1"

    # SemVer regex: MAJOR.MINOR.PATCH
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Invalid semantic version format: $version"
        error "Expected format: MAJOR.MINOR.PATCH (e.g., 1.0.0)"
        return 1
    fi

    return 0
}

# Parse version into components
parse_version() {
    local version="$1"
    local major minor patch

    IFS='.' read -r major minor patch <<< "$version"

    echo "$major $minor $patch"
}

# Bump version based on type
bump_version() {
    local bump_type="$1"
    local current_version
    current_version=$(get_current_version)

    if ! validate_semver "$current_version"; then
        exit 1
    fi

    read -r major minor patch <<< "$(parse_version "$current_version")"

    local new_version
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            new_version="$major.$minor.$patch"
            info "Bumping MAJOR version (breaking changes): $current_version -> $new_version"
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            new_version="$major.$minor.$patch"
            info "Bumping MINOR version (new features): $current_version -> $new_version"
            ;;
        patch)
            patch=$((patch + 1))
            new_version="$major.$minor.$patch"
            info "Bumping PATCH version (bug fixes): $current_version -> $new_version"
            ;;
        *)
            error "Invalid bump type: $bump_type"
            error "Valid types: major, minor, patch"
            exit 1
            ;;
    esac

    echo "$new_version"
}

# Update VERSION file
update_version_file() {
    local new_version="$1"

    info "Updating VERSION file: $VERSION_FILE"
    echo "$new_version" > "$VERSION_FILE"
    success "VERSION file updated to $new_version"
}

# Update CHANGELOG with new version
update_changelog() {
    local new_version="$1"
    local current_date
    current_date=$(date +%Y-%m-%d)

    if [ ! -f "$CHANGELOG_FILE" ]; then
        error "CHANGELOG.md not found at: $CHANGELOG_FILE"
        return 1
    fi

    info "Preparing CHANGELOG.md entry for version $new_version"

    # Create a temporary file for the new CHANGELOG
    local temp_changelog="${CHANGELOG_FILE}.tmp"

    # Check if there's already an [Unreleased] section
    if grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
        # Replace [Unreleased] with the new version
        sed "s/## \[Unreleased\]/## [$new_version] - $current_date/" "$CHANGELOG_FILE" > "$temp_changelog"

        # Add a new [Unreleased] section at the top
        {
            head -n 6 "$temp_changelog"  # Keep header
            echo ""
            echo "## [Unreleased]"
            echo ""
            echo "### Added"
            echo ""
            echo "### Changed"
            echo ""
            echo "### Deprecated"
            echo ""
            echo "### Removed"
            echo ""
            echo "### Fixed"
            echo ""
            echo "### Security"
            echo ""
            tail -n +7 "$temp_changelog"  # Keep rest of file
        } > "$CHANGELOG_FILE"

        rm "$temp_changelog"
        success "CHANGELOG.md updated with version $new_version"
    else
        # Add new version section after the header
        {
            head -n 6 "$CHANGELOG_FILE"  # Keep header
            echo ""
            echo "## [Unreleased]"
            echo ""
            echo "### Added"
            echo ""
            echo "### Changed"
            echo ""
            echo "### Deprecated"
            echo ""
            echo "### Removed"
            echo ""
            echo "### Fixed"
            echo ""
            echo "### Security"
            echo ""
            echo "## [$new_version] - $current_date"
            echo ""
            echo "### Added"
            echo "- Initial semantic versioning implementation"
            echo ""
            tail -n +7 "$CHANGELOG_FILE"  # Keep rest of file
        } > "$temp_changelog"

        mv "$temp_changelog" "$CHANGELOG_FILE"
        success "CHANGELOG.md updated with version $new_version"
    fi

    warn "Please review and edit CHANGELOG.md to document your changes"
}

# Create git tag for current version
create_git_tag() {
    local version
    version=$(get_current_version)

    if ! validate_semver "$version"; then
        exit 1
    fi

    validate_git_repo

    local tag_name="v$version"

    # Check if tag already exists
    if git rev-parse "$tag_name" >/dev/null 2>&1; then
        error "Tag $tag_name already exists"
        info "Use 'git tag -d $tag_name' to delete it first, or bump the version"
        exit 1
    fi

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        warn "You have uncommitted changes"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Aborted"
            exit 0
        fi
    fi

    info "Creating git tag: $tag_name"

    # Create annotated tag
    git tag -a "$tag_name" -m "Release version $version"

    success "Created git tag: $tag_name"
    info "To push the tag to remote, run: git push origin $tag_name"
}

# Validate VERSION file and CHANGELOG consistency
validate_versioning() {
    section "Validating Versioning"

    # Check VERSION file exists
    if [ ! -f "$VERSION_FILE" ]; then
        error "VERSION file not found"
        return 1
    fi

    # Check CHANGELOG exists
    if [ ! -f "$CHANGELOG_FILE" ]; then
        error "CHANGELOG.md not found"
        return 1
    fi

    # Validate VERSION format
    local version
    version=$(get_current_version)
    info "Current version: $version"

    if ! validate_semver "$version"; then
        return 1
    fi
    success "VERSION file format is valid"

    # Check if version exists in CHANGELOG
    if grep -q "\[$version\]" "$CHANGELOG_FILE"; then
        success "Version $version found in CHANGELOG.md"
    else
        warn "Version $version not found in CHANGELOG.md"
        warn "Consider running: ./scripts/version.sh bump <type>"
    fi

    # Check for [Unreleased] section
    if grep -q "\[Unreleased\]" "$CHANGELOG_FILE"; then
        success "CHANGELOG.md has [Unreleased] section"
    else
        warn "CHANGELOG.md missing [Unreleased] section"
    fi

    success "Versioning validation complete"
}

# Display current version information
show_current_version() {
    local version
    version=$(get_current_version)

    echo -e "${CYAN}Current Version:${NC} ${GREEN}$version${NC}"

    if validate_semver "$version" >/dev/null 2>&1; then
        read -r major minor patch <<< "$(parse_version "$version")"
        echo -e "  ${BLUE}Major:${NC} $major (Breaking changes)"
        echo -e "  ${BLUE}Minor:${NC} $minor (New features)"
        echo -e "  ${BLUE}Patch:${NC} $patch (Bug fixes)"
    fi

    # Check for git tag
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local tag_name="v$version"
        if git rev-parse "$tag_name" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Git tag exists: $tag_name"
        else
            echo -e "  ${YELLOW}!${NC} Git tag not created yet"
            echo -e "    Run: ${CYAN}./scripts/version.sh tag${NC}"
        fi
    fi
}

# Display help
show_help() {
    cat << 'EOF'
Semantic Versioning Management Script

Usage:
  ./scripts/version.sh <command> [options]

Commands:
  current              Show current version
  bump <type>          Bump version (major|minor|patch)
                       - major: Breaking changes (1.0.0 -> 2.0.0)
                       - minor: New features (1.0.0 -> 1.1.0)
                       - patch: Bug fixes (1.0.0 -> 1.0.1)
  tag                  Create git tag for current version
  validate             Validate VERSION file and CHANGELOG

Semantic Versioning (SemVer 2.0.0):
  MAJOR.MINOR.PATCH
  - MAJOR: Incompatible API changes (breaking changes)
  - MINOR: Backwards-compatible functionality additions
  - PATCH: Backwards-compatible bug fixes

Workflow:
  1. Make your changes
  2. Update CHANGELOG.md [Unreleased] section
  3. Run: ./scripts/version.sh bump <type>
  4. Review the updated VERSION and CHANGELOG.md
  5. Commit changes: git add VERSION CHANGELOG.md && git commit
  6. Create tag: ./scripts/version.sh tag
  7. Push: git push && git push --tags

Examples:
  ./scripts/version.sh current
  ./scripts/version.sh bump patch
  ./scripts/version.sh tag
  ./scripts/version.sh validate

For more information, see:
  - https://semver.org/
  - CONTRIBUTING.md
EOF
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    local command="${1:-help}"

    case "$command" in
        current)
            show_current_version
            ;;
        bump)
            if [ $# -lt 2 ]; then
                error "Bump type required: major, minor, or patch"
                echo "Usage: $0 bump <major|minor|patch>"
                exit 1
            fi

            local bump_type="$2"
            local new_version
            new_version=$(bump_version "$bump_type")

            # Update VERSION file
            update_version_file "$new_version"

            # Update CHANGELOG
            update_changelog "$new_version"

            echo
            success "Version bumped to $new_version"
            info "Next steps:"
            echo "  1. Review and edit CHANGELOG.md"
            echo "  2. Commit changes: git add VERSION CHANGELOG.md && git commit -m 'Bump version to $new_version'"
            echo "  3. Create tag: ./scripts/version.sh tag"
            echo "  4. Push: git push && git push --tags"
            ;;
        tag)
            create_git_tag
            ;;
        validate)
            validate_versioning
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main with all arguments
main "$@"
