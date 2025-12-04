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
