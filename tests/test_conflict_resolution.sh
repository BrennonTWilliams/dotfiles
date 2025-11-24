#!/usr/bin/env bash

# ==============================================================================
# Unit Tests for Conflict Resolution
# ==============================================================================
# Tests the conflict resolution functionality for dotfiles installation
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Export required variables before sourcing
export VERBOSE=false
export QUIET=false

# Source required libraries
source "$DOTFILES_DIR/scripts/lib/utils.sh"
source "$DOTFILES_DIR/scripts/lib/conflict-resolution.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test data directory
TEST_DATA_DIR="$SCRIPT_DIR/.test_conflict_data"

# ==============================================================================
# Test Framework Functions
# ==============================================================================

test_start() {
    local test_name="$1"
    echo
    echo "▸ Testing: $test_name"
    ((TESTS_RUN++)) || true
}

test_pass() {
    local test_name="$1"
    echo "  ✓ PASS: $test_name"
    ((TESTS_PASSED++)) || true
}

test_fail() {
    local test_name="$1"
    local reason="${2:-}"
    echo "  ✗ FAIL: $test_name"
    if [ -n "$reason" ]; then
        echo "    Reason: $reason"
    fi
    ((TESTS_FAILED++)) || true
}

# Setup test environment
setup_test_env() {
    # Create test data directory
    mkdir -p "$TEST_DATA_DIR"

    # Create test files
    echo "existing content" > "$TEST_DATA_DIR/test_file.txt"
    echo "new content" > "$TEST_DATA_DIR/test_file_new.txt"

    # Create test gitconfig
    cat > "$TEST_DATA_DIR/existing_gitconfig" << 'EOF'
[user]
    name = Test User
    email = test@example.com

[core]
    editor = vim
EOF

    cat > "$TEST_DATA_DIR/new_gitconfig" << 'EOF'
[user]
    name = New User
    email = new@example.com

[core]
    editor = nvim
    autocrlf = input

[alias]
    st = status
    co = checkout
EOF

    # Create test shell config
    cat > "$TEST_DATA_DIR/existing_zshrc" << 'EOF'
# Existing zsh configuration
export PATH="$HOME/bin:$PATH"
alias ll='ls -la'
EOF

    cat > "$TEST_DATA_DIR/new_zshrc" << 'EOF'
# New zsh configuration from dotfiles
export EDITOR=nvim
alias gs='git status'
EOF

    # Create binary test file
    printf '\x00\x01\x02\x03' > "$TEST_DATA_DIR/binary_file.bin"
}

# Cleanup test environment
cleanup_test_env() {
    if [ -d "$TEST_DATA_DIR" ]; then
        rm -rf "$TEST_DATA_DIR"
    fi
}

# ==============================================================================
# Diff Tool Detection Tests
# ==============================================================================

test_diff_tool_detection() {
    test_start "Diff tool detection"

    local diff_tool=$(get_best_diff_tool)

    if [ -n "$diff_tool" ] && [ "$diff_tool" != "none" ]; then
        test_pass "Diff tool detected: $diff_tool"
    else
        test_fail "Diff tool detection" "No diff tool found"
    fi
}

test_diff_command_generation() {
    test_start "Diff command generation"

    local diff_tool=$(get_best_diff_tool)
    local cmd=$(get_diff_command "$diff_tool" "/tmp/file1" "/tmp/file2")

    if [ -n "$cmd" ]; then
        test_pass "Diff command generated: ${cmd:0:50}..."
    else
        test_fail "Diff command generation" "Empty command"
    fi
}

# ==============================================================================
# File Type Detection Tests
# ==============================================================================

test_mergeable_config_detection() {
    test_start "Mergeable config file detection"

    local tests=(
        ".gitconfig:gitconfig"
        ".zshrc:shell"
        ".bashrc:shell"
        ".tmux.conf:tmux"
        ".vimrc:vim"
        "random.txt:unknown"
    )

    local all_passed=true
    for test_case in "${tests[@]}"; do
        local file="${test_case%%:*}"
        local expected="${test_case##*:}"

        # is_mergeable_config returns 0 for known types, 1 for unknown
        # It also echoes the type
        if is_mergeable_config "$file" >/dev/null 2>&1; then
            local result=$(is_mergeable_config "$file" 2>/dev/null)
        else
            local result="unknown"
        fi

        if [ "$result" != "$expected" ]; then
            all_passed=false
            test_fail "Mergeable detection" "$file should be $expected, got $result"
            break
        fi
    done

    if [ "$all_passed" = true ]; then
        test_pass "All file type detections correct"
    fi
}

test_binary_file_detection() {
    test_start "Binary file detection"

    if [ -f "$TEST_DATA_DIR/binary_file.bin" ]; then
        if is_binary_file "$TEST_DATA_DIR/binary_file.bin"; then
            test_pass "Binary file detected correctly"
        else
            test_fail "Binary file detection" "Failed to detect binary file"
        fi
    else
        test_fail "Binary file detection" "Test binary file not found"
    fi

    # Test text file
    if [ -f "$TEST_DATA_DIR/test_file.txt" ]; then
        if is_binary_file "$TEST_DATA_DIR/test_file.txt"; then
            test_fail "Binary file detection" "Text file incorrectly detected as binary"
        else
            test_pass "Text file detected correctly"
        fi
    fi
}

# ==============================================================================
# File Info Tests
# ==============================================================================

test_file_info_display() {
    test_start "File info display"

    if [ -f "$TEST_DATA_DIR/test_file.txt" ]; then
        local info=$(get_file_info "$TEST_DATA_DIR/test_file.txt")

        if [[ "$info" =~ "line" ]] && [[ "$info" =~ "modified" ]]; then
            test_pass "File info includes lines and modification date"
        else
            test_fail "File info display" "Missing expected info: $info"
        fi
    else
        test_fail "File info display" "Test file not found"
    fi
}

test_nonexistent_file_info() {
    test_start "Nonexistent file info handling"

    local info=$(get_file_info "/nonexistent/file.txt" 2>&1 || echo "does not exist")

    if [[ "$info" =~ "does not exist" ]]; then
        test_pass "Nonexistent file handled correctly"
    else
        test_fail "Nonexistent file info" "Unexpected output: $info"
    fi
}

# ==============================================================================
# Backup Tests
# ==============================================================================

test_backup_with_metadata() {
    test_start "Backup with conflict metadata"

    local backup_dir="$TEST_DATA_DIR/backups"
    local test_file="$TEST_DATA_DIR/test_file.txt"

    if [ -f "$test_file" ]; then
        local backup_path=$(backup_with_conflict_note "$test_file" "$backup_dir" "test")

        if [ -f "$backup_path" ] && [ -f "${backup_path}.meta" ]; then
            # Check metadata file
            if grep -q "original_path=$test_file" "${backup_path}.meta" && \
               grep -q "backup_reason=test" "${backup_path}.meta"; then
                test_pass "Backup created with metadata"
            else
                test_fail "Backup metadata" "Metadata file missing expected content"
            fi
        else
            test_fail "Backup with metadata" "Backup or metadata file not created"
        fi

        # Cleanup
        rm -rf "$backup_dir"
    else
        test_fail "Backup with metadata" "Test file not found"
    fi
}

test_backup_collision_handling() {
    test_start "Backup collision handling"

    local backup_dir="$TEST_DATA_DIR/backups2"
    local test_file="$TEST_DATA_DIR/test_file.txt"

    if [ -f "$test_file" ]; then
        # Create first backup
        local backup1=$(backup_with_conflict_note "$test_file" "$backup_dir" "test1")

        # Create second backup
        local backup2=$(backup_with_conflict_note "$test_file" "$backup_dir" "test2")

        # They should be different
        if [ "$backup1" != "$backup2" ] && [ -f "$backup1" ] && [ -f "$backup2" ]; then
            test_pass "Backup collision handled correctly"
        else
            test_fail "Backup collision" "Backups not unique: $backup1 vs $backup2"
        fi

        # Cleanup
        rm -rf "$backup_dir"
    else
        test_fail "Backup collision handling" "Test file not found"
    fi
}

# ==============================================================================
# Merge Function Tests
# ==============================================================================

test_gitconfig_merge() {
    test_start "Gitconfig merge"

    local existing="$TEST_DATA_DIR/existing_gitconfig"
    local new="$TEST_DATA_DIR/new_gitconfig"
    local merged="$TEST_DATA_DIR/merged_gitconfig"

    if [ -f "$existing" ] && [ -f "$new" ]; then
        if merge_gitconfig "$existing" "$new" "$merged"; then
            # Check that merged file contains content from both
            if grep -q "Test User" "$merged" && grep -q "autocrlf" "$merged"; then
                test_pass "Gitconfig files merged successfully"
            else
                test_fail "Gitconfig merge" "Merged file missing expected content"
            fi
        else
            test_fail "Gitconfig merge" "Merge function failed"
        fi

        rm -f "$merged"
    else
        test_fail "Gitconfig merge" "Test files not found"
    fi
}

test_shell_rc_merge() {
    test_start "Shell RC merge"

    local existing="$TEST_DATA_DIR/existing_zshrc"
    local new="$TEST_DATA_DIR/new_zshrc"
    local merged="$TEST_DATA_DIR/merged_zshrc"

    if [ -f "$existing" ] && [ -f "$new" ]; then
        if merge_shell_rc "$existing" "$new" "$merged"; then
            # Check that merged file contains content from both
            if grep -q "Existing zsh configuration" "$merged" && \
               grep -q "New zsh configuration" "$merged" && \
               grep -q "alias ll=" "$merged" && \
               grep -q "alias gs=" "$merged"; then
                test_pass "Shell RC files merged successfully"
            else
                test_fail "Shell RC merge" "Merged file missing expected content"
            fi
        else
            test_fail "Shell RC merge" "Merge function failed"
        fi

        rm -f "$merged"
    else
        test_fail "Shell RC merge" "Test files not found"
    fi
}

test_smart_merge_dispatch() {
    test_start "Smart merge type dispatch"

    # Test gitconfig dispatch
    local existing="$TEST_DATA_DIR/existing_gitconfig"
    local new="$TEST_DATA_DIR/new_gitconfig"
    local merged="$TEST_DATA_DIR/merged_auto"

    if [ -f "$existing" ] && [ -f "$new" ]; then
        # Rename to .gitconfig to trigger type detection
        local temp_existing="$TEST_DATA_DIR/.gitconfig"
        cp "$existing" "$temp_existing"

        if merge_configs "$temp_existing" "$new" "$merged"; then
            if grep -q "Merged .gitconfig" "$merged"; then
                test_pass "Smart merge dispatched to gitconfig merge"
            else
                test_fail "Smart merge dispatch" "Wrong merge type used"
            fi
        else
            test_fail "Smart merge dispatch" "Merge failed"
        fi

        rm -f "$merged" "$temp_existing"
    else
        test_fail "Smart merge dispatch" "Test files not found"
    fi
}

# ==============================================================================
# Auto-Resolve Strategy Tests
# ==============================================================================

test_auto_resolve_keep_existing() {
    test_start "Auto-resolve: keep-existing strategy"

    local existing="$TEST_DATA_DIR/test_file.txt"
    local new="$TEST_DATA_DIR/test_file_new.txt"
    local backup_dir="$TEST_DATA_DIR/backups_auto1"

    # Reset counters
    CONFLICTS_SKIPPED=0

    if resolve_conflict_auto "$existing" "$new" "$backup_dir" "keep-existing"; then
        if [ $CONFLICTS_SKIPPED -eq 1 ]; then
            test_pass "Keep-existing strategy works"
        else
            test_fail "Keep-existing strategy" "Counter not incremented"
        fi
    else
        test_fail "Keep-existing strategy" "Function returned error"
    fi

    rm -rf "$backup_dir"
}

test_auto_resolve_overwrite() {
    test_start "Auto-resolve: overwrite strategy"

    # Create a copy to test with
    local test_copy="$TEST_DATA_DIR/test_overwrite.txt"
    cp "$TEST_DATA_DIR/test_file.txt" "$test_copy"

    local new="$TEST_DATA_DIR/test_file_new.txt"
    local backup_dir="$TEST_DATA_DIR/backups_auto2"

    # Reset counters
    CONFLICTS_RESOLVED=0

    if resolve_conflict_auto "$test_copy" "$new" "$backup_dir" "overwrite"; then
        # Check that file was backed up and removed
        if [ ! -f "$test_copy" ] && [ -f "$backup_dir/test_overwrite.txt.backup" ]; then
            test_pass "Overwrite strategy works"
        else
            test_fail "Overwrite strategy" "File not backed up or not removed"
        fi
    else
        test_fail "Overwrite strategy" "Function returned error"
    fi

    rm -rf "$backup_dir" "$test_copy"
}

test_auto_resolve_backup_all() {
    test_start "Auto-resolve: backup-all strategy"

    # Create a copy to test with
    local test_copy="$TEST_DATA_DIR/test_backup_all.txt"
    cp "$TEST_DATA_DIR/test_file.txt" "$test_copy"

    local new="$TEST_DATA_DIR/test_file_new.txt"
    local backup_dir="$TEST_DATA_DIR/backups_auto3"

    # Reset counters
    CONFLICTS_RESOLVED=0

    if resolve_conflict_auto "$test_copy" "$new" "$backup_dir" "backup-all"; then
        # Check that file was renamed to .orig
        if [ -f "${test_copy}.orig" ] && [ ! -f "$test_copy" ]; then
            test_pass "Backup-all strategy works"
        else
            test_fail "Backup-all strategy" "File not renamed to .orig"
        fi
    else
        test_fail "Backup-all strategy" "Function returned error"
    fi

    rm -f "${test_copy}.orig"
}

test_auto_resolve_fail_on_conflict() {
    test_start "Auto-resolve: fail-on-conflict strategy"

    local existing="$TEST_DATA_DIR/test_file.txt"
    local new="$TEST_DATA_DIR/test_file_new.txt"
    local backup_dir="$TEST_DATA_DIR/backups_auto4"

    # Reset counters
    CONFLICTS_FAILED=0

    # This should return error
    if resolve_conflict_auto "$existing" "$new" "$backup_dir" "fail-on-conflict"; then
        test_fail "Fail-on-conflict strategy" "Should have returned error"
    else
        if [ $CONFLICTS_FAILED -eq 1 ]; then
            test_pass "Fail-on-conflict strategy works"
        else
            test_fail "Fail-on-conflict strategy" "Counter not incremented"
        fi
    fi

    rm -rf "$backup_dir"
}

# ==============================================================================
# Diff Display Tests
# ==============================================================================

test_diff_text_files() {
    test_start "Diff display for text files"

    local file1="$TEST_DATA_DIR/test_file.txt"
    local file2="$TEST_DATA_DIR/test_file_new.txt"

    if [ -f "$file1" ] && [ -f "$file2" ]; then
        # Capture output
        local output=$(show_diff "$file1" "$file2" 2>&1)

        if [ $? -eq 0 ] && [ -n "$output" ]; then
            test_pass "Diff displayed for text files"
        else
            test_fail "Diff display" "No output or error occurred"
        fi
    else
        test_fail "Diff display" "Test files not found"
    fi
}

test_diff_binary_files() {
    test_start "Diff handling for binary files"

    local binary="$TEST_DATA_DIR/binary_file.bin"
    local text="$TEST_DATA_DIR/test_file.txt"

    if [ -f "$binary" ] && [ -f "$text" ]; then
        # This should fail gracefully
        local output=$(show_diff "$binary" "$text" 2>&1 || true)

        if [[ "$output" =~ "binary" ]] || [[ "$output" =~ "Cannot diff" ]]; then
            test_pass "Binary files handled correctly in diff"
        else
            test_fail "Binary file diff" "Expected warning about binary files"
        fi
    else
        test_fail "Binary file diff" "Test files not found"
    fi
}

# ==============================================================================
# Integration Tests
# ==============================================================================

test_function_exports() {
    test_start "Function exports"

    local required_functions=(
        "detect_conflicts"
        "resolve_conflict_interactive"
        "resolve_conflict_auto"
        "resolve_package_conflicts"
        "show_diff"
        "merge_configs"
        "backup_with_conflict_note"
    )

    local all_exported=true
    for func in "${required_functions[@]}"; do
        if ! declare -F "$func" > /dev/null; then
            all_exported=false
            test_fail "Function export" "$func not found"
            break
        fi
    done

    if [ "$all_exported" = true ]; then
        test_pass "All required functions are exported"
    fi
}

# ==============================================================================
# Run All Tests
# ==============================================================================

print_test_header() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Conflict Resolution Unit Tests"
    echo "═══════════════════════════════════════════════════════════════"
}

print_test_results() {
    echo
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Test Results"
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Total tests run:    $TESTS_RUN"
    echo "  Tests passed:       $TESTS_PASSED"
    echo "  Tests failed:       $TESTS_FAILED"
    echo "═══════════════════════════════════════════════════════════════"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo "  ✓ ALL TESTS PASSED"
        return 0
    else
        echo "  ✗ SOME TESTS FAILED"
        return 1
    fi
}

main() {
    print_test_header

    # Setup test environment
    echo
    echo "Setting up test environment..."
    setup_test_env

    # Diff tool tests
    test_diff_tool_detection
    test_diff_command_generation

    # File type detection tests
    test_mergeable_config_detection
    test_binary_file_detection

    # File info tests
    test_file_info_display
    test_nonexistent_file_info

    # Backup tests
    test_backup_with_metadata
    test_backup_collision_handling

    # Merge function tests
    test_gitconfig_merge
    test_shell_rc_merge
    test_smart_merge_dispatch

    # Auto-resolve strategy tests
    test_auto_resolve_keep_existing
    test_auto_resolve_overwrite
    test_auto_resolve_backup_all
    test_auto_resolve_fail_on_conflict

    # Diff display tests
    test_diff_text_files
    test_diff_binary_files

    # Integration tests
    test_function_exports

    # Cleanup test environment
    echo
    echo "Cleaning up test environment..."
    cleanup_test_env

    # Print results
    print_test_results
}

# Run tests
main "$@"
