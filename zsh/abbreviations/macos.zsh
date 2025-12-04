# ==============================================================================
# macOS-Specific Abbreviations
# ==============================================================================
# Only loaded on macOS systems

[[ "$OSTYPE" != "darwin"* ]] && return 0

# ==============================================================================
# File Operations
# ==============================================================================
abbr -S show='open'
abbr -S finder='open .'
abbr -S textedit='open -a TextEdit'

# ==============================================================================
# Homebrew Management
# ==============================================================================
abbr -S brew-upgrade='brew update && brew upgrade'
abbr -S brew-clean='brew cleanup && brew doctor'
abbr -S brew-list='brew list --formula'
abbr -S brew-cask-list='brew list --cask'
abbr -S brew-services='brew services'
abbr -S brew-doctor='brew doctor'
abbr -S brew-cask-upgrade='brew upgrade --cask'
abbr -S brew-dependencies='brew deps --tree'
abbr -S brew-uses='brew uses --installed'
abbr -S brew-info='brew info --json=v2'
abbr -S brew-stats='echo "Installed formulae: $(brew info --json=v2 | jq -r ".formulae | length")"'

# ==============================================================================
# System Information
# ==============================================================================
abbr -S wifi-info='networksetup -getairportnetwork "$(networksetup -listallhardwareports | awk '\''/Wi-Fi/{getline; print $2}'\'')"'
abbr -S wifi-list='networksetup -listallhardwareports'
abbr -S system-info='system_profiler SPHardwareDataType'
abbr -S battery='pmset -g batt'
abbr -S os-version='sw_vers'
abbr -S build-version='sw_vers -buildVersion'
abbr -S kernel-version='uname -a'
abbr -S hardware-overview='system_profiler SPHardwareDataType SPDisplaysDataType'
abbr -S storage-info='system_profiler SPStorageDataType'
abbr -S usb-info='system_profiler SPUSBDataType'
abbr -S bluetooth-info='system_profiler SPBluetoothDataType'
abbr -S network-info='system_profiler SPNetworkDataType'
abbr -S power-info='system_profiler SPPowerDataType'

# ==============================================================================
# macOS App Shortcuts
# ==============================================================================
abbr -S display-sleep='pmset displaysleepnow'
abbr -S macsleep='pmset sleepnow'
abbr -S lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
abbr -S screensaver='open -a ScreenSaverEngine'

# ==============================================================================
# Clipboard
# ==============================================================================
abbr -S clipboard='pbpaste'
abbr -S copy='pbcopy'
abbr -S clipboard-sync='uniclip ${UNICLIP_SERVER:-localhost:53168}'

# ==============================================================================
# Quick Look
# ==============================================================================
abbr -S qlfile='qlmanage -p'

# ==============================================================================
# Developer Tools
# ==============================================================================
abbr -S xcode-info='xcode-select -p'
abbr -S xcode-path='xcode-select --print-path'
abbr -S xcode-version='xcodebuild -version'
abbr -S simulators='xcrun simctl list devices'
abbr -S simulators-list='xcrun simctl list devices available'
abbr -S simulators-all='xcrun simctl list devices'
abbr -S swift-version='swift --version'
abbr -S clang-version='clang --version'
abbr -S make-info='make --version'

# ==============================================================================
# Networking
# ==============================================================================
abbr -S ip-info='ifconfig | grep "inet " | grep -v 127.0.0.1'
abbr -S ip-public='curl -s ifconfig.me || curl -s ipinfo.io/ip'
abbr -S ip-local='ipconfig getifaddr "$(networksetup -listallhardwareports | awk '\''/Wi-Fi/{getline; print $2}'\'')" 2>/dev/null || echo "No Wi-Fi interface found"'
abbr -S dns-servers='scutil --dns | grep "nameserver\[0\]"'
abbr -S network-interfaces='ifconfig -l'
abbr -S ping-google='ping -c 4 8.8.8.8'
abbr -S flush-dns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

# ==============================================================================
# Apple Silicon
# ==============================================================================
abbr -S arch-info='arch && uname -m'
abbr -S rosetta-info='arch -x86_64 uname -m'
abbr -S is-rosetta='arch | grep -q "i386" && echo "Running under Rosetta 2" || echo "Running natively on Apple Silicon"'
abbr -S apps-rosetta='lsof | grep -i "Translate" | head -10'
abbr -S sysctl-arm='sysctl -n machdep.cpu.brand_string'
abbr -S memory-info='vm_stat | perl -ne "/page size of (\d+)/ and $ps=$1; /Pages\s+([^:]+).(\d+)/ and printf(\"%-22s: % 16.2f MB\n\", \"$1\", $2*$ps/1048576); /Pageouthistories/ and exit"'
abbr -S cores='sysctl -n hw.ncpu'
abbr -S perf-cores='sysctl -n hw.perflevel0.physicalcpu 2>/dev/null || echo "N/A"'
abbr -S eff-cores='sysctl -n hw.perflevel1.physicalcpu 2>/dev/null || echo "N/A"'

# ==============================================================================
# File System Utilities
# ==============================================================================
abbr -S show-extended-attrs='xattr -l'
abbr -S remove-quarantine='xattr -d com.apple.quarantine'
abbr -S make-executable='chmod +x'
abbr -S show-permissions='ls -la'
abbr -S hide-file='chflags hidden'
abbr -S show-file='chflags nohidden'
abbr -S show-hidden-files='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
abbr -S hide-hidden-files='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
abbr -S show-desktop-icons='defaults write com.apple.finder CreateDesktop YES && killall Finder'
abbr -S hide-desktop-icons='defaults write com.apple.finder CreateDesktop NO && killall Finder'

# ==============================================================================
# System Maintenance
# ==============================================================================
abbr -S update-macos='sudo softwareupdate -l && echo "Run: sudo softwareupdate -i <update-name> to install"'
abbr -S update-macos-all='sudo softwareupdate -i -a'
abbr -S clear-logs='echo "Use: sudo log files --clear or journalctl --vacuum-time=1d"'
abbr -S system-cleanup='echo "Running macOS maintenance..."; brew cleanup; brew doctor; sudo softwareupdate -i -a'
