# ==============================================================================
# macOS-Specific Functions
# ==============================================================================
# Only loaded on macOS systems

[[ "$OSTYPE" != "darwin"* ]] && return 0

# Airport command with deprecation warning (deprecated in newer macOS versions)
airport() {
    local airport_path="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    if [[ -f "$airport_path" ]]; then
        echo "Warning: airport command is deprecated in newer macOS versions"
        echo "Consider using 'wifi-info' or 'networksetup -listallhardwareports' instead"
        "$airport_path" "$@"
    else
        echo "airport command not found on this macOS version"
        echo "Use 'wifi-info' for current network information"
        return 1
    fi
}

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
        # Try non-sudo methods first
        if command -v osx-cpu-temp >/dev/null 2>&1; then
            osx-cpu-temp
        elif [[ -f "/usr/local/bin/osx-cpu-temp" ]]; then
            /usr/local/bin/osx-cpu-temp
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

# Wi-Fi network scanning
wifi-scan() {
    local airport_path="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    if [[ -f "$airport_path" ]]; then
        echo "Scanning Wi-Fi networks (using deprecated airport command)..."
        "$airport_path" -s
    else
        echo "airport command not available on this macOS version"
        echo "Using modern alternative with networksetup..."
        # Modern alternative for Wi-Fi scanning
        local wifi_interface=$(networksetup -listallhardwareports | grep -A1 "Wi-Fi" | grep "Device:" | awk '{print $2}')
        if [[ -n "$wifi_interface" ]]; then
            echo "Available Wi-Fi networks for interface $wifi_interface:"
            sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s 2>/dev/null || \
            echo "Try: sudo wifi-scan or use 'wifi-info' for current connection info"
        else
            echo "Could not find Wi-Fi interface"
        fi
    fi
}

# QuickLook files without opening them fully
ql() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ql <file1> [file2] ..."
        echo "Quick Look files without opening them fully"
        return 1
    fi
    qlmanage -p "$@" >& /dev/null &
}
