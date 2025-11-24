#!/usr/bin/env bash

# ==============================================================================
# Conflict Resolution Library for Dotfiles Installation
# ==============================================================================
# Provides interactive and automatic conflict resolution for dotfiles installation
# with intelligent detection, diff viewing, and merge capabilities.
#
# Functions:
#   - detect_conflicts()                Detect stow conflicts before installation
#   - resolve_conflict_interactive()    Interactive conflict resolution
#   - resolve_conflict_auto()           Automatic conflict resolution
#   - show_diff()                       Display file differences
#   - merge_configs()                   Smart merge for known file types
#   - backup_with_conflict_note()       Enhanced backup with metadata
# ==============================================================================

# Ensure utils.sh is sourced
if [ -z "$RED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/utils.sh"
fi

# ==============================================================================
# Global Variables
# ==============================================================================

# Conflict resolution counters
CONFLICTS_DETECTED=0
CONFLICTS_RESOLVED=0
CONFLICTS_SKIPPED=0
CONFLICTS_FAILED=0

# Auto-resolve strategy (if set)
AUTO_RESOLVE_STRATEGY="${AUTO_RESOLVE_STRATEGY:-}"

# Interactive mode (default: true)
INTERACTIVE_MODE="${INTERACTIVE_MODE:-true}"

# Verbose mode (default: false)
VERBOSE="${VERBOSE:-false}"

# Quiet mode (default: false)
QUIET="${QUIET:-false}"

# ==============================================================================
# Diff Tool Detection Functions
# ==============================================================================

# Get the best available diff tool
get_best_diff_tool() {
    if command_exists "delta"; then
        echo "delta"
    elif command_exists "colordiff"; then
        echo "colordiff"
    elif command_exists "diff"; then
        echo "diff"
    else
        echo "none"
    fi
}

# Get diff command with appropriate flags
get_diff_command() {
    local tool="$1"
    local file1="$2"
    local file2="$3"

    case "$tool" in
        delta)
            echo "delta --side-by-side \"$file1\" \"$file2\""
            ;;
        colordiff)
            echo "colordiff -u \"$file1\" \"$file2\""
            ;;
        diff)
            echo "diff -u \"$file1\" \"$file2\""
            ;;
        *)
            echo ""
            ;;
    esac
}

# ==============================================================================
# File Type Detection Functions
# ==============================================================================

# Check if a file is a mergeable configuration file
is_mergeable_config() {
    local file="$1"
    local filename=$(basename "$file")

    case "$filename" in
        .gitconfig|gitconfig)
            echo "gitconfig"
            return 0
            ;;
        .zshrc|zshrc|.bashrc|bashrc)
            echo "shell"
            return 0
            ;;
        .tmux.conf|tmux.conf)
            echo "tmux"
            return 0
            ;;
        .vimrc|vimrc|.nvimrc|nvimrc)
            echo "vim"
            return 0
            ;;
        *)
            echo "unknown"
            return 1
            ;;
    esac
}

# Check if file is binary
is_binary_file() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 1
    fi

    # Use file command to detect binary files
    if command_exists "file"; then
        if file "$file" | grep -q "text"; then
            return 1
        else
            return 0
        fi
    else
        # Fallback: check for null bytes
        if grep -q $'\0' "$file" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    fi
}

# ==============================================================================
# Conflict Detection Functions
# ==============================================================================

# Detect conflicts for a package using stow dry-run
detect_conflicts() {
    local package="$1"
    local target_dir="${2:-$HOME}"
    local conflicts=()

    # Run stow in dry-run mode to detect conflicts
    local stow_output
    stow_output=$(stow -n -v -d "$DOTFILES_DIR" -t "$target_dir" "$package" 2>&1)
    local stow_status=$?

    # Parse stow output for conflicts
    if [ $stow_status -ne 0 ]; then
        while IFS= read -r line; do
            # Match "existing target is" pattern
            if [[ "$line" =~ existing\ target\ is.*:\ (.+) ]]; then
                local conflict_file="${BASH_REMATCH[1]}"
                # Convert relative path to absolute
                if [[ ! "$conflict_file" =~ ^/ ]]; then
                    conflict_file="$target_dir/$conflict_file"
                fi
                conflicts+=("$conflict_file")
            fi
        done <<< "$stow_output"
    fi

    CONFLICTS_DETECTED=${#conflicts[@]}

    # Return conflict list
    echo "${conflicts[@]}"
}

# Get file info for display
get_file_info() {
    local file="$1"

    if [ ! -e "$file" ]; then
        echo "does not exist"
        return 1
    fi

    local size=$(wc -c < "$file" 2>/dev/null || echo "0")
    local lines=$(wc -l < "$file" 2>/dev/null || echo "0")
    local modified=""

    # Get modification time
    if [[ "$OSTYPE" == "darwin"* ]]; then
        modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null)
    else
        modified=$(stat -c "%y" "$file" 2>/dev/null | cut -d'.' -f1)
    fi

    # Format output
    if is_binary_file "$file"; then
        echo "${size} bytes (binary, modified: ${modified})"
    else
        echo "${lines} lines (modified: ${modified})"
    fi
}

# ==============================================================================
# Diff Display Functions
# ==============================================================================

# Show diff between two files
show_diff() {
    local existing_file="$1"
    local new_file="$2"

    # Check if files exist
    if [ ! -f "$existing_file" ]; then
        error "Existing file not found: $existing_file"
        return 1
    fi

    if [ ! -f "$new_file" ]; then
        error "New file not found: $new_file"
        return 1
    fi

    # Check if either file is binary
    if is_binary_file "$existing_file" || is_binary_file "$new_file"; then
        warn "Cannot diff binary files"
        info "Existing: $(get_file_info "$existing_file")"
        info "New:      $(get_file_info "$new_file")"
        return 1
    fi

    # Get best diff tool
    local diff_tool=$(get_best_diff_tool)

    if [ "$diff_tool" = "none" ]; then
        error "No diff tool available"
        return 1
    fi

    echo ""
    info "Showing diff using: $diff_tool"
    echo -e "${CYAN}$(printf '─%.0s' {1..70})${NC}"

    # Get and execute diff command
    local diff_cmd=$(get_diff_command "$diff_tool" "$existing_file" "$new_file")

    if [ -n "$diff_cmd" ]; then
        eval "$diff_cmd" || true  # diff returns non-zero when files differ
    fi

    echo -e "${CYAN}$(printf '─%.0s' {1..70})${NC}"
    echo ""
}

# ==============================================================================
# Merge Functions
# ==============================================================================

# Merge gitconfig files
merge_gitconfig() {
    local existing="$1"
    local new="$2"
    local output="$3"

    info "Merging gitconfig files..."

    # Simple merge: combine both files with comments
    {
        echo "# Merged .gitconfig ($(date))"
        echo "# Original configuration:"
        echo ""
        cat "$existing"
        echo ""
        echo "# New dotfiles configuration:"
        echo ""
        cat "$new"
    } > "$output"

    success "Gitconfig files merged"
    return 0
}

# Merge shell rc files (.zshrc, .bashrc)
merge_shell_rc() {
    local existing="$1"
    local new="$2"
    local output="$3"

    info "Merging shell configuration files..."

    # Append new config to existing with separator
    {
        cat "$existing"
        echo ""
        echo "# =============================================================================="
        echo "# Dotfiles configuration added $(date)"
        echo "# =============================================================================="
        echo ""
        cat "$new"
    } > "$output"

    success "Shell configuration files merged"
    return 0
}

# Merge tmux configuration
merge_tmux_conf() {
    local existing="$1"
    local new="$2"
    local output="$3"

    info "Merging tmux configuration files..."

    # Append new config to existing with separator
    {
        cat "$existing"
        echo ""
        echo "# =============================================================================="
        echo "# Dotfiles tmux configuration added $(date)"
        echo "# =============================================================================="
        echo ""
        cat "$new"
    } > "$output"

    success "Tmux configuration files merged"
    return 0
}

# Merge vim/neovim configuration
merge_vim_rc() {
    local existing="$1"
    local new="$2"
    local output="$3"

    info "Merging vim configuration files..."

    # Append new config to existing with separator
    {
        cat "$existing"
        echo ""
        echo "\" =============================================================================="
        echo "\" Dotfiles vim configuration added $(date)"
        echo "\" =============================================================================="
        echo ""
        cat "$new"
    } > "$output"

    success "Vim configuration files merged"
    return 0
}

# Smart merge based on file type
merge_configs() {
    local existing="$1"
    local new="$2"
    local output="$3"

    local file_type=$(is_mergeable_config "$existing")

    case "$file_type" in
        gitconfig)
            merge_gitconfig "$existing" "$new" "$output"
            ;;
        shell)
            merge_shell_rc "$existing" "$new" "$output"
            ;;
        tmux)
            merge_tmux_conf "$existing" "$new" "$output"
            ;;
        vim)
            merge_vim_rc "$existing" "$new" "$output"
            ;;
        *)
            warn "Unknown file type - performing simple concatenation"
            cat "$existing" "$new" > "$output"
            return 1
            ;;
    esac
}

# ==============================================================================
# Backup Functions
# ==============================================================================

# Enhanced backup with conflict metadata
backup_with_conflict_note() {
    local file="$1"
    local backup_dir="$2"
    local reason="${3:-conflict}"

    if [ ! -e "$file" ]; then
        return 1
    fi

    mkdir -p "$backup_dir"
    local basename=$(basename "$file")
    local backup_path="$backup_dir/${basename}.backup"

    # Handle existing backups
    if [ -e "$backup_path" ]; then
        local counter=1
        while [ -e "$backup_path.$counter" ]; do
            ((counter++))
        done
        backup_path="$backup_path.$counter"
    fi

    # Copy file
    cp -R "$file" "$backup_path"

    # Create metadata file
    local metadata_file="${backup_path}.meta"
    {
        echo "original_path=$file"
        echo "backup_date=$(date)"
        echo "backup_reason=$reason"
        echo "file_size=$(wc -c < "$file" 2>/dev/null || echo "0")"
        echo "file_lines=$(wc -l < "$file" 2>/dev/null || echo "0")"
    } > "$metadata_file"

    if [ "$VERBOSE" = true ]; then
        info "Backed up: $file → $backup_path"
    fi

    echo "$backup_path"
    return 0
}

# ==============================================================================
# Interactive Resolution Functions
# ==============================================================================

# Display conflict resolution options
show_conflict_options() {
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo -e "  ${GREEN}1${NC} - Keep existing (skip this dotfile)"
    echo -e "  ${YELLOW}2${NC} - Overwrite with new (backup existing)"
    echo -e "  ${BLUE}3${NC} - View diff"
    echo -e "  ${CYAN}4${NC} - Merge configurations (intelligent merge)"
    echo -e "  ${YELLOW}5${NC} - Keep both (rename existing → .orig)"
    echo -e "  ${RED}6${NC} - Decide later (skip for now)"
    echo ""
}

# Resolve a single conflict interactively
resolve_conflict_interactive() {
    local existing_file="$1"
    local new_file="$2"
    local backup_dir="$3"
    local conflict_num="$4"
    local total_conflicts="$5"

    echo ""
    echo -e "${BOLD}${CYAN}Conflict ${conflict_num}/${total_conflicts}:${NC} ${BOLD}$existing_file${NC}"
    echo -e "${CYAN}$(printf '─%.0s' {1..70})${NC}"

    # Show file info
    echo -e "  ${YELLOW}⚠${NC} Existing: $(get_file_info "$existing_file")"
    echo -e "  ${GREEN}⬡${NC} New:      $(get_file_info "$new_file")"

    # Show options
    show_conflict_options

    # Read user choice
    local choice=""
    while true; do
        read -p "Choice [1-6]: " choice

        case "$choice" in
            1)
                # Keep existing
                info "Keeping existing file"
                ((CONFLICTS_SKIPPED++))
                return 0
                ;;
            2)
                # Overwrite with new
                info "Overwriting with new file..."
                local backup_path=$(backup_with_conflict_note "$existing_file" "$backup_dir" "overwritten")

                if [ -n "$backup_path" ]; then
                    rm -f "$existing_file"
                    success "File backed up to: $backup_path"
                    ((CONFLICTS_RESOLVED++))
                    return 0
                else
                    error "Backup failed"
                    ((CONFLICTS_FAILED++))
                    return 1
                fi
                ;;
            3)
                # View diff
                show_diff "$existing_file" "$new_file"
                show_conflict_options
                ;;
            4)
                # Merge configurations
                info "Attempting intelligent merge..."

                # Check if file is mergeable
                local file_type=$(is_mergeable_config "$existing_file")

                if [ "$file_type" != "unknown" ]; then
                    # Create temporary merged file
                    local temp_merged=$(mktemp)

                    if merge_configs "$existing_file" "$new_file" "$temp_merged"; then
                        # Backup original
                        local backup_path=$(backup_with_conflict_note "$existing_file" "$backup_dir" "merged")

                        # Replace with merged version
                        mv "$temp_merged" "$existing_file"
                        success "Files merged successfully"
                        success "Original backed up to: $backup_path"
                        ((CONFLICTS_RESOLVED++))
                        return 0
                    else
                        warn "Merge completed but may require manual review"
                        rm -f "$temp_merged"
                        show_conflict_options
                    fi
                else
                    warn "File type not supported for automatic merge"
                    warn "Supported types: .gitconfig, .zshrc, .bashrc, .tmux.conf, .vimrc"
                    show_conflict_options
                fi
                ;;
            5)
                # Keep both
                info "Keeping both files..."

                local orig_file="${existing_file}.orig"
                local counter=1

                # Find unique .orig name
                while [ -e "$orig_file" ]; do
                    orig_file="${existing_file}.orig.$counter"
                    ((counter++))
                done

                mv "$existing_file" "$orig_file"
                success "Existing file renamed to: $orig_file"
                ((CONFLICTS_RESOLVED++))
                return 0
                ;;
            6)
                # Decide later
                warn "Skipping this conflict"
                ((CONFLICTS_SKIPPED++))
                return 0
                ;;
            *)
                error "Invalid choice. Please enter 1-6."
                ;;
        esac
    done
}

# ==============================================================================
# Automatic Resolution Functions
# ==============================================================================

# Resolve conflict automatically based on strategy
resolve_conflict_auto() {
    local existing_file="$1"
    local new_file="$2"
    local backup_dir="$3"
    local strategy="${4:-$AUTO_RESOLVE_STRATEGY}"

    case "$strategy" in
        keep-existing)
            if [ "$VERBOSE" = true ]; then
                info "Auto-resolve: Keeping existing file: $existing_file"
            fi
            ((CONFLICTS_SKIPPED++))
            return 0
            ;;
        overwrite)
            if [ "$VERBOSE" = true ]; then
                info "Auto-resolve: Overwriting: $existing_file"
            fi
            local backup_path=$(backup_with_conflict_note "$existing_file" "$backup_dir" "auto-overwritten")
            if [ -n "$backup_path" ]; then
                rm -f "$existing_file"
                ((CONFLICTS_RESOLVED++))
                return 0
            else
                ((CONFLICTS_FAILED++))
                return 1
            fi
            ;;
        backup-all)
            if [ "$VERBOSE" = true ]; then
                info "Auto-resolve: Creating backup: $existing_file"
            fi
            local orig_file="${existing_file}.orig"
            local counter=1
            while [ -e "$orig_file" ]; do
                orig_file="${existing_file}.orig.$counter"
                ((counter++))
            done
            mv "$existing_file" "$orig_file"
            ((CONFLICTS_RESOLVED++))
            return 0
            ;;
        fail-on-conflict)
            echo -e "${RED}[ERROR]${NC} Conflict detected: $existing_file" >&2
            ((CONFLICTS_FAILED++))
            return 1
            ;;
        *)
            error "Unknown auto-resolve strategy: $strategy"
            ((CONFLICTS_FAILED++))
            return 1
            ;;
    esac
}

# ==============================================================================
# Main Conflict Resolution Functions
# ==============================================================================

# Resolve all conflicts for a package
resolve_package_conflicts() {
    local package="$1"
    local target_dir="${2:-$HOME}"
    local backup_dir="${3:-$BACKUP_DIR}"

    # Detect conflicts
    local conflicts=($(detect_conflicts "$package" "$target_dir"))

    if [ ${#conflicts[@]} -eq 0 ]; then
        if [ "$VERBOSE" = true ]; then
            success "No conflicts detected for package: $package"
        fi
        return 0
    fi

    echo ""
    warn "Found ${#conflicts[@]} conflict(s) for package: ${BOLD}$package${NC}"
    echo ""

    # Resolve each conflict
    local conflict_num=1
    for conflict_file in "${conflicts[@]}"; do
        # Get corresponding new file from package
        local relative_path="${conflict_file#$target_dir/}"
        local new_file="$DOTFILES_DIR/$package/$relative_path"

        if [ ! -f "$new_file" ]; then
            warn "New file not found: $new_file (skipping)"
            ((CONFLICTS_SKIPPED++))
            ((conflict_num++))
            continue
        fi

        # Resolve based on mode
        if [ "$INTERACTIVE_MODE" = true ]; then
            resolve_conflict_interactive "$conflict_file" "$new_file" "$backup_dir" "$conflict_num" "${#conflicts[@]}"
        else
            resolve_conflict_auto "$conflict_file" "$new_file" "$backup_dir"
        fi

        ((conflict_num++))
    done

    # Summary
    if [ ${#conflicts[@]} -gt 0 ]; then
        echo ""
        echo -e "${BOLD}Conflict Resolution Summary for $package:${NC}"
        echo -e "  ${CYAN}◆${NC} Detected: $CONFLICTS_DETECTED"
        echo -e "  ${GREEN}✓${NC} Resolved: $CONFLICTS_RESOLVED"
        echo -e "  ${YELLOW}⊘${NC} Skipped:  $CONFLICTS_SKIPPED"
        [ $CONFLICTS_FAILED -gt 0 ] && echo -e "  ${RED}✗${NC} Failed:   $CONFLICTS_FAILED"
        echo ""
    fi

    # Return failure if any conflicts failed
    if [ $CONFLICTS_FAILED -gt 0 ]; then
        return 1
    fi

    return 0
}

# ==============================================================================
# Export Functions
# ==============================================================================

# Export functions for use in other scripts
export -f detect_conflicts
export -f resolve_conflict_interactive
export -f resolve_conflict_auto
export -f resolve_package_conflicts
export -f show_diff
export -f merge_configs
export -f backup_with_conflict_note
export -f get_best_diff_tool
export -f is_mergeable_config
export -f is_binary_file
