# ==============================================================================
# macOS-Specific Functions
# ==============================================================================
# Only loaded on macOS systems

[[ "$OSTYPE" != "darwin"* ]] && return 0

# CPU temperature with sudo and non-sudo alternatives
cpu-temp() {
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        echo "CPU Temperature Monitor"
        echo "Usage: cpu-temp [--no-sudo]"
        echo "  --no-sudo: Try non-sudo methods first"
        echo "  Default: Requires sudo for powermetrics (more accurate)"
        return 0
    fi

    if [[ "$1" == "--no-sudo" ]]; then
        # Try non-sudo methods first (command -v works for both Intel and Apple Silicon paths)
        if command -v osx-cpu-temp >/dev/null 2>&1; then
            osx-cpu-temp
        else
            echo "No non-sudo temperature monitoring tools found"
            echo "Install 'osx-cpu-temp' via brew: brew install osx-cpu-temp"
            echo "Or run 'cpu-temp' without --no-sudo (requires admin password)"
            return 1
        fi
    else
        # Sudo method with powermetrics
        echo "Checking CPU temperature (requires sudo)..."
        if sudo powermetrics --samplers smc -n1 -i1 | grep -i "CPU die temperature" 2>/dev/null; then
            return 0
        else
            echo "Could not get CPU temperature via powermetrics"
            echo "Try 'cpu-temp --no-sudo' or install osx-cpu-temp"
            return 1
        fi
    fi
}

# Wi-Fi network scanning (uses modern system_profiler API)
wifi-scan() {
    echo "Scanning Wi-Fi networks..."
    local wifi_if
    wifi_if=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
    if [[ -z "$wifi_if" ]]; then
        echo "Error: Could not find Wi-Fi interface"
        return 1
    fi
    # Use system_profiler as modern alternative (no deprecated private frameworks)
    system_profiler SPAirPortDataType 2>/dev/null | grep -A 50 "Other Local Wi-Fi Networks" || {
        echo "Could not scan networks. Try: networksetup -listpreferredwirelessnetworks $wifi_if"
    }
}

# QuickLook files without opening them fully
ql() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ql <file1> [file2] ..."
        echo "Quick Look files without opening them fully"
        return 1
    fi
    qlmanage -p "$@" >/dev/null 2>&1 &
}

# Import the generated Terminal.app profiles so Terminal.app matches the
# Ghostty + tmux gruvbox palette and Iosevka Nerd Font.
#
# The profiles are generated from the Ghostty theme files by
# scripts/generate-terminal-profile.sh and live in terminal-app/ (not a Stow
# package - Terminal.app imports them into its preferences rather than reading
# a symlink).
#
# Note: this does not touch toggle-theme. Terminal.app cannot follow the macOS
# appearance the way Ghostty's 'theme = light:...,dark:...' line does, so switch
# afterwards in Terminal > Settings or by re-running with the other mode.
terminal-profile-install() {
    local mode="${1:-dark}"

    if [[ "$mode" == "--help" || "$mode" == "-h" ]]; then
        echo "Usage: terminal-profile-install [dark|light]"
        echo "  Imports the Gruvbox Terminal.app profiles and sets one as default."
        echo "  Defaults to 'dark'. Regenerate with scripts/generate-terminal-profile.sh"
        return 0
    fi

    if [[ "$mode" != "dark" && "$mode" != "light" ]]; then
        echo "[!] Unknown mode: $mode (expected 'dark' or 'light')"
        return 1
    fi

    # Resolve the dotfiles root the same way .zshrc resolves _DOTFILES_STARSHIP_DIR
    local dotfiles_dir
    if [[ -L ~/.zshrc ]]; then
        dotfiles_dir="$HOME/$(dirname "$(dirname "$(readlink ~/.zshrc)")")"
    else
        dotfiles_dir="${${(%):-%x}:A:h:h:h}"
    fi

    local profile_dir="$dotfiles_dir/terminal-app"
    local dark_profile="$profile_dir/Gruvbox Dark Custom.terminal"
    local light_profile="$profile_dir/Gruvbox Light Custom.terminal"

    if [[ ! -f "$dark_profile" || ! -f "$light_profile" ]]; then
        echo "[!] Profiles not found in $profile_dir"
        echo "    Generate them: $dotfiles_dir/scripts/generate-terminal-profile.sh"
        return 1
    fi

    # Importing requires Terminal.app to be running to receive the open event
    open -a Terminal "$dark_profile"
    open -a Terminal "$light_profile"

    local profile_name="Gruvbox Dark Custom"
    [[ "$mode" == "light" ]] && profile_name="Gruvbox Light Custom"

    # Terminal needs a moment to register a freshly imported settings set before
    # it can be assigned as the default.
    sleep 1

    if ! osascript >/dev/null 2>&1 <<EOF
tell application "Terminal"
    set default settings to settings set "$profile_name"
    set startup settings to settings set "$profile_name"
end tell
EOF
    then
        echo "[!] Imported the profiles, but could not set '$profile_name' as default"
        echo "    Set it manually: Terminal > Settings > Profiles > Default"
        return 1
    fi

    echo "[+] Terminal.app profile: $profile_name"
    echo "    Imported: $profile_dir"
    echo "    Set as default and startup profile"
    echo "    Open a new Terminal window to see it (existing windows keep their profile)"
}
