#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Recovery Script
# ==============================================================================
# This script helps restore dotfiles from automatic backups created during
# installation. It provides functionality to list, verify, and restore backups.
#
# USAGE:
#   ./scripts/recover.sh                    # Interactive mode
#   ./scripts/recover.sh --list             # List all available backups
#   ./scripts/recover.sh --latest           # Restore from latest backup
#   ./scripts/recover.sh --backup <path>    # Restore from specific backup
#   ./scripts/recover.sh --verify <path>    # Verify backup integrity
#   ./scripts/recover.sh --interactive      # Interactive selection mode
#   ./scripts/recover.sh --help             # Show this help message
#
# EXAMPLES:
#   # List all available backups
#   ./scripts/recover.sh --list
#
#   # Restore from the latest backup (with confirmation)
#   ./scripts/recover.sh --latest
#
#   # Restore from a specific backup directory
#   ./scripts/recover.sh --backup ~/.dotfiles_backup_20250115_120000
#
#   # Verify backup integrity before restoring
#   ./scripts/recover.sh --verify ~/.dotfiles_backup_20250115_120000
#
#   # Interactive mode - select what to restore
#   ./scripts/recover.sh --interactive
#
# NOTES:
#   - Backups are created automatically during installation
#   - Default backup location: ~/.dotfiles_backup_YYYYMMDD_HHMMSS/
#   - This script will create a backup before restoring (safety measure)
#   - Use --force to skip confirmation prompts
# ==============================================================================

set -euo pipefail

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# ==============================================================================
# Configuration
# ==============================================================================

BACKUP_BASE_DIR="$HOME"
BACKUP_PREFIX=".dotfiles_backup_"
RESTORE_BACKUP_DIR="$HOME/.dotfiles_restore_backup_$(date +%Y%m%d_%H%M%S)"
FORCE=false
DRY_RUN=false

# ==============================================================================
# Helper Functions
# ==============================================================================

# Display usage information
show_usage() {
    cat << EOF
Dotfiles Recovery Script

USAGE:
    $(basename "$0") [OPTIONS]

OPTIONS:
    --list                  List all available backups
    --latest                Restore from the latest backup
    --backup <path>         Restore from specific backup directory
    --verify <path>         Verify backup integrity
    --interactive           Interactive selection mode
    --force                 Skip confirmation prompts
    --dry-run               Show what would be restored without making changes
    --help                  Show this help message

EXAMPLES:
    # List all available backups
    $(basename "$0") --list

    # Restore from latest backup
    $(basename "$0") --latest

    # Restore from specific backup
    $(basename "$0") --backup ~/.dotfiles_backup_20250115_120000

    # Interactive mode
    $(basename "$0") --interactive

NOTES:
    - Backups are created during installation to: ~/.dotfiles_backup_YYYYMMDD_HHMMSS/
    - This script creates a safety backup before restoring
    - Use --dry-run to preview changes before applying them

EOF
}

# Find all available backups
find_backups() {
    local backups=()

    # Find all backup directories matching the pattern
    while IFS= read -r -d '' backup_dir; do
        if [ -d "$backup_dir" ]; then
            backups+=("$backup_dir")
        fi
    done < <(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "${BACKUP_PREFIX}*" -print0 2>/dev/null | sort -rz)

    # Return the array
    printf '%s\n' "${backups[@]}"
}

# List all available backups with details
list_backups() {
    section "Available Dotfiles Backups"

    local backups
    mapfile -t backups < <(find_backups)

    if [ ${#backups[@]} -eq 0 ]; then
        warn "No backups found in $BACKUP_BASE_DIR"
        info "Backups are created automatically during installation"
        return 1
    fi

    info "Found ${#backups[@]} backup(s):"
    echo

    local count=1
    for backup_dir in "${backups[@]}"; do
        local backup_name=$(basename "$backup_dir")
        local backup_date=${backup_name#$BACKUP_PREFIX}
        local formatted_date=$(echo "$backup_date" | sed 's/_/ /' | sed 's/_/:/' | sed 's/_/:/')
        local file_count=$(find "$backup_dir" -type f 2>/dev/null | wc -l)
        local dir_size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)

        echo -e "${CYAN}[$count]${NC} $backup_name"
        echo "    Date: $formatted_date"
        echo "    Path: $backup_dir"
        echo "    Files: $file_count"
        echo "    Size: $dir_size"
        echo

        ((count++))
    done

    return 0
}

# Get the latest backup directory
get_latest_backup() {
    local backups
    mapfile -t backups < <(find_backups)

    if [ ${#backups[@]} -eq 0 ]; then
        return 1
    fi

    echo "${backups[0]}"
}

# Verify backup integrity
verify_backup() {
    local backup_dir="$1"

    section "Verifying Backup Integrity"

    if [ ! -d "$backup_dir" ]; then
        error "Backup directory not found: $backup_dir"
        return 1
    fi

    info "Checking backup: $backup_dir"

    local issues=0
    local total_files=0
    local readable_files=0

    # Check if directory is readable
    if [ ! -r "$backup_dir" ]; then
        error "Cannot read backup directory: $backup_dir"
        return 1
    fi

    # Count total files
    total_files=$(find "$backup_dir" -type f 2>/dev/null | wc -l)

    if [ "$total_files" -eq 0 ]; then
        warn "Backup directory is empty"
        return 1
    fi

    info "Found $total_files file(s) in backup"

    # Check each file
    while IFS= read -r -d '' file; do
        if [ -r "$file" ]; then
            ((readable_files++))
        else
            warn "Cannot read file: $file"
            ((issues++))
        fi
    done < <(find "$backup_dir" -type f -print0 2>/dev/null)

    # Report results
    echo
    if [ $issues -eq 0 ]; then
        success "Backup verification passed"
        info "All $readable_files file(s) are readable"
        return 0
    else
        warn "Backup verification found issues"
        warn "$issues file(s) are not readable"
        return 1
    fi
}

# Create a safety backup before restoring
create_safety_backup() {
    local files_to_backup="$1"

    section "Creating Safety Backup"

    info "Creating safety backup at: $RESTORE_BACKUP_DIR"
    mkdir -p "$RESTORE_BACKUP_DIR"

    local backed_up=0

    while IFS= read -r file; do
        if [ -e "$file" ] && [ ! -L "$file" ]; then
            local relative_path="${file#$HOME/}"
            local backup_path="$RESTORE_BACKUP_DIR/$relative_path"
            local backup_parent=$(dirname "$backup_path")

            mkdir -p "$backup_parent"

            if cp -r "$file" "$backup_path" 2>/dev/null; then
                ((backed_up++))
            fi
        fi
    done <<< "$files_to_backup"

    if [ $backed_up -eq 0 ]; then
        info "No existing files to backup"
        rm -rf "$RESTORE_BACKUP_DIR"
    else
        success "Backed up $backed_up file(s) to $RESTORE_BACKUP_DIR"
    fi
}

# Restore files from backup
restore_from_backup() {
    local backup_dir="$1"
    local specific_files="${2:-}"

    section "Restoring from Backup"

    # Verify backup exists and is valid
    if ! verify_backup "$backup_dir"; then
        error "Backup verification failed. Aborting restore."
        return 1
    fi

    info "Restoring from: $backup_dir"

    # Find all files in backup
    local files_to_restore=()

    if [ -n "$specific_files" ]; then
        # Restore specific files
        while IFS= read -r file; do
            if [ -f "$backup_dir/$file" ]; then
                files_to_restore+=("$file")
            else
                warn "File not found in backup: $file"
            fi
        done <<< "$specific_files"
    else
        # Restore all files
        while IFS= read -r -d '' file; do
            local relative_path="${file#$backup_dir/}"
            files_to_restore+=("$relative_path")
        done < <(find "$backup_dir" -type f -print0 2>/dev/null)
    fi

    if [ ${#files_to_restore[@]} -eq 0 ]; then
        warn "No files to restore"
        return 1
    fi

    info "Found ${#files_to_restore[@]} file(s) to restore"

    # Create safety backup of files that will be overwritten
    local existing_files=""
    for file in "${files_to_restore[@]}"; do
        local target="$HOME/$file"
        if [ -e "$target" ]; then
            existing_files+="$target"$'\n'
        fi
    done

    if [ -n "$existing_files" ] && [ "$FORCE" = false ]; then
        create_safety_backup "$existing_files"
    fi

    # Restore files
    local restored=0
    local failed=0

    for file in "${files_to_restore[@]}"; do
        local source="$backup_dir/$file"
        local target="$HOME/$file"
        local target_dir=$(dirname "$target")

        if [ "$DRY_RUN" = true ]; then
            echo "Would restore: $file"
            ((restored++))
            continue
        fi

        # Create target directory if needed
        mkdir -p "$target_dir"

        # Remove existing file/symlink if it exists
        if [ -e "$target" ] || [ -L "$target" ]; then
            rm -rf "$target"
        fi

        # Copy file from backup
        if cp -r "$source" "$target" 2>/dev/null; then
            ((restored++))
        else
            warn "Failed to restore: $file"
            ((failed++))
        fi
    done

    # Report results
    echo
    if [ "$DRY_RUN" = true ]; then
        success "Dry run complete: would restore $restored file(s)"
    else
        if [ $failed -eq 0 ]; then
            success "Successfully restored $restored file(s)"
        else
            warn "Restored $restored file(s), failed to restore $failed file(s)"
        fi
    fi

    return 0
}

# Interactive mode - select what to restore
interactive_restore() {
    section "Interactive Backup Restoration"

    # List available backups
    local backups
    mapfile -t backups < <(find_backups)

    if [ ${#backups[@]} -eq 0 ]; then
        error "No backups found"
        return 1
    fi

    # Display backups
    echo "Available backups:"
    echo

    local count=1
    for backup_dir in "${backups[@]}"; do
        local backup_name=$(basename "$backup_dir")
        local backup_date=${backup_name#$BACKUP_PREFIX}
        local formatted_date=$(echo "$backup_date" | sed 's/_/ /' | sed 's/_/:/' | sed 's/_/:/')
        local file_count=$(find "$backup_dir" -type f 2>/dev/null | wc -l)

        echo -e "${CYAN}[$count]${NC} $formatted_date ($file_count files)"
        ((count++))
    done

    echo
    read -rp "Select backup number (or 'q' to quit): " selection

    if [ "$selection" = "q" ] || [ "$selection" = "Q" ]; then
        info "Cancelled"
        return 0
    fi

    # Validate selection
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#backups[@]} ]; then
        error "Invalid selection"
        return 1
    fi

    local selected_backup="${backups[$((selection - 1))]}"

    # List files in selected backup
    echo
    info "Files in selected backup:"
    echo

    local files=()
    local file_count=1

    while IFS= read -r -d '' file; do
        local relative_path="${file#$selected_backup/}"
        files+=("$relative_path")
        echo -e "${CYAN}[$file_count]${NC} $relative_path"
        ((file_count++))
    done < <(find "$selected_backup" -type f -print0 2>/dev/null | sort -z)

    echo
    echo "Options:"
    echo "  [a] Restore all files"
    echo "  [s] Select specific files"
    echo "  [q] Quit"
    echo
    read -rp "Choose option: " option

    case "$option" in
        a|A)
            # Confirm restore all
            echo
            warn "This will restore ${#files[@]} file(s) from backup"
            read -rp "Continue? (y/N): " confirm

            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                restore_from_backup "$selected_backup"
            else
                info "Cancelled"
            fi
            ;;
        s|S)
            # Select specific files
            echo
            read -rp "Enter file numbers to restore (space-separated, e.g., '1 3 5'): " file_numbers

            local selected_files=""
            for num in $file_numbers; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#files[@]} ]; then
                    selected_files+="${files[$((num - 1))]}"$'\n'
                else
                    warn "Invalid file number: $num"
                fi
            done

            if [ -n "$selected_files" ]; then
                restore_from_backup "$selected_backup" "$selected_files"
            else
                warn "No valid files selected"
            fi
            ;;
        q|Q)
            info "Cancelled"
            ;;
        *)
            error "Invalid option"
            return 1
            ;;
    esac
}

# ==============================================================================
# Main Script Logic
# ==============================================================================

main() {
    local mode=""
    local backup_path=""

    # Parse command-line arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            --list)
                mode="list"
                shift
                ;;
            --latest)
                mode="latest"
                shift
                ;;
            --backup)
                mode="specific"
                backup_path="$2"
                shift 2
                ;;
            --verify)
                mode="verify"
                backup_path="$2"
                shift 2
                ;;
            --interactive)
                mode="interactive"
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Default to interactive mode if no mode specified
    if [ -z "$mode" ]; then
        mode="interactive"
    fi

    # Execute based on mode
    case "$mode" in
        list)
            list_backups
            ;;
        latest)
            local latest_backup
            latest_backup=$(get_latest_backup)

            if [ -z "$latest_backup" ]; then
                error "No backups found"
                exit 1
            fi

            info "Latest backup: $latest_backup"

            if [ "$FORCE" = false ]; then
                echo
                read -rp "Restore from this backup? (y/N): " confirm

                if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                    info "Cancelled"
                    exit 0
                fi
            fi

            restore_from_backup "$latest_backup"
            ;;
        specific)
            if [ -z "$backup_path" ]; then
                error "Backup path not specified"
                exit 1
            fi

            # Expand tilde if present
            backup_path="${backup_path/#\~/$HOME}"

            if [ "$FORCE" = false ]; then
                echo
                read -rp "Restore from $backup_path? (y/N): " confirm

                if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                    info "Cancelled"
                    exit 0
                fi
            fi

            restore_from_backup "$backup_path"
            ;;
        verify)
            if [ -z "$backup_path" ]; then
                error "Backup path not specified"
                exit 1
            fi

            # Expand tilde if present
            backup_path="${backup_path/#\~/$HOME}"

            verify_backup "$backup_path"
            ;;
        interactive)
            interactive_restore
            ;;
        *)
            error "Invalid mode: $mode"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
