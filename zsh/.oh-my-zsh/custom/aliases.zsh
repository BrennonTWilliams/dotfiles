# Custom Aliases
# Place your custom aliases here

# ============================================
# Directory Navigation
# ============================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# ============================================
# File Operations
# ============================================
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lh'

# ============================================
# Git Shortcuts (complement to git plugin)
# ============================================
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# ============================================
# System Shortcuts
# ============================================
alias update='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'
alias h='history'
alias c='clear'

# ============================================
# Tmux Shortcuts
# ============================================
alias tls='tmux ls'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# ============================================
# Utility Functions
# ============================================
# Create and enter directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick find
qfind() {
  find . -name "*$1*"
}

# Extract based on extension (complements extract plugin)
# The extract plugin should handle most cases, but this is a backup

# ============================================
# Development
# ============================================
alias serve='python3 -m http.server'
alias ports='netstat -tulanp'

# ============================================
# macOS-Specific Aliases
# ============================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  # File operations
  alias show='open'                      # Open files with default app
  alias finder='open .'                  # Open current directory in Finder
  alias textedit='open -a TextEdit'      # Open file in TextEdit

  # Homebrew management
  alias brew-upgrade='brew update && brew upgrade'
  alias brew-clean='brew cleanup && brew doctor'
  alias brew-list='brew list --formula'
  alias brew-cask-list='brew list --cask'

  # System information
  # Airport command with deprecation warning (deprecated in newer macOS versions)
  airport() {
    local airport_path="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    if [[ -f "$airport_path" ]]; then
      echo "⚠️  Warning: airport command is deprecated in newer macOS versions"
      echo "💡 Consider using 'wifi-info' or 'networksetup -listallhardwareports' instead"
      "$airport_path" "$@"
    else
      echo "❌ airport command not found on this macOS version"
      echo "💡 Use 'wifi-info' for current network information"
      return 1
    fi
  }

  # Modern Wi-Fi information alternative
  alias wifi-info='networksetup -getairportinfo en0'
  alias wifi-list='networksetup -listallhardwareports'
  alias system-info='system_profiler SPHardwareDataType'
  alias battery='pmset -g batt'

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
        echo "❌ No non-sudo temperature monitoring tools found"
        echo "💡 Install 'osx-cpu-temp' via brew: brew install osx-cpu-temp"
        echo "💡 Or run 'cpu-temp' without --no-sudo (requires admin password)"
        return 1
      fi
    else
      # Sudo method with powermetrics
      echo "🔧 Checking CPU temperature (requires sudo)..."
      if sudo powermetrics --samplers smc -n1 -i1 | grep -i "CPU die temperature" 2>/dev/null; then
        return 0
      else
        echo "❌ Could not get CPU temperature via powermetrics"
        echo "💡 Try 'cpu-temp --no-sudo' or install osx-cpu-temp"
        return 1
      fi
    fi
  }

  # macOS app shortcuts
  alias lock='pmset displaysleepnow'     # Lock screen
  alias sleep='pmset sleepnow'          # Put Mac to sleep
  alias screensaver='open -a ScreenSaverEngine'

  # Clipboard management
  alias clipboard='pbpaste'              # Paste from clipboard
  alias copy='pbcopy'                   # Copy to clipboard (pipe)

  # Quick Look
  alias ql='qlmanage -p'                # Quick Look file

  # macOS-specific development
  alias xcode-info='xcode-select -p'
  alias simulators='xcrun simctl list devices'

  # Networking
  wifi-scan() {
    local airport_path="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    if [[ -f "$airport_path" ]]; then
      echo "📡 Scanning Wi-Fi networks (using deprecated airport command)..."
      "$airport_path" -s
    else
      echo "❌ airport command not available on this macOS version"
      echo "💡 Using modern alternative with networksetup..."
      # Modern alternative for Wi-Fi scanning
      local wifi_interface=$(networksetup -listallhardwareports | grep -A1 "Wi-Fi" | grep "Device:" | awk '{print $2}')
      if [[ -n "$wifi_interface" ]]; then
        echo "📡 Available Wi-Fi networks for interface $wifi_interface:"
        sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s 2>/dev/null || \
        echo "💡 Try: sudo wifi-scan or use 'wifi-info' for current connection info"
      else
        echo "❌ Could not find Wi-Fi interface"
      fi
    fi
  }

  alias ip-info='ifconfig | grep "inet " | grep -v 127.0.0.1'
  alias ip-public='curl -s ifconfig.me || curl -s ipinfo.io/ip'
  alias ip-local='ipconfig getifaddr en0'
  alias dns-servers='scutil --dns | grep "nameserver\[0\]"'
  alias network-interfaces='ifconfig -l'
  alias ping-google='ping -c 4 8.8.8.8'

  # ============================================
  # Apple Silicon Specific Aliases
  # ============================================
  alias arch-info='arch && uname -m'
  alias rosetta-info='arch -x86_64 uname -m'
  alias is-rosetta='arch | grep -q "i386" && echo "Running under Rosetta 2" || echo "Running natively on Apple Silicon"'
  alias apps-rosetta='lsof | grep -i "Translate" | head -10'
  alias sysctl-arm='sysctl -n machdep.cpu.brand_string'
  alias memory-info='vm_stat | perl -ne "/page size of (\d+)/ and $ps=$1; /Pages\s+([^:]+).(\d+)/ and printf(\"%-22s: % 16.2f MB\n\", \"$1\", $2*$ps/1048576); /Pageouthistories/ and exit'
  alias cores='sysctl -n hw.ncpu'
  alias perf-cores='sysctl -n hw.perflevel0.physicalcpu 2>/dev/null || echo "N/A"'
  alias eff-cores='sysctl -n hw.perflevel1.physicalcpu 2>/dev/null || echo "N/A"'

  # ============================================
  # Enhanced macOS Development Aliases
  # ============================================

  # QuickLook improvements
  ql() {
    if [[ $# -eq 0 ]]; then
      echo "Usage: ql <file1> [file2] ..."
      echo "Quick Look files without opening them fully"
      return 1
    fi
    qlmanage -p "$@" >& /dev/null &
  }

  # System information enhancements
  alias os-version='sw_vers'
  alias build-version='sw_vers -buildVersion'
  alias kernel-version='uname -a'
  alias hardware-overview='system_profiler SPHardwareDataType SPDisplaysDataType'
  alias storage-info='system_profiler SPStorageDataType'
  alias usb-info='system_profiler SPUSBDataType'
  alias bluetooth-info='system_profiler SPBluetoothDataType'
  alias network-info='system_profiler SPNetworkDataType'
  alias power-info='system_profiler SPPowerDataType'

  # Application management
  alias apps='/Applications'
  alias utils='/Applications/Utilities'
  alias show-hidden-files='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
  alias hide-hidden-files='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
  alias show-desktop-icons='defaults write com.apple.finder CreateDesktop YES && killall Finder'
  alias hide-desktop-icons='defaults write com.apple.finder CreateDesktop NO && killall Finder'

  # Developer tools
  alias xcode-path='xcode-select --print-path'
  alias xcode-version='xcodebuild -version'
  alias simulators-list='xcrun simctl list devices available'
  alias simulators-all='xcrun simctl list devices'
  alias swift-version='swift --version'
  alias clang-version='clang --version'
  alias make-info='make --version'

  # Homebrew enhancements
  alias brew-services='brew services'
  alias brew-doctor='brew doctor'
  alias brew-cask-upgrade='brew upgrade --cask'
  alias brew-dependencies='brew deps --tree'
  alias brew-uses='brew uses --installed'
  alias brew-info='brew info --json=v2'
  alias brew-stats='brew info --json=v2 | jq -r ".formulae | length" | xargs echo "Installed formulae:"'

  # File system utilities
  alias show-extended-attrs='xattr -l'
  alias remove-quarantine='xattr -d com.apple.quarantine'
  alias make-executable='chmod +x'
  alias show-permissions='ls -la'
  alias hide-file='chflags hidden'
  alias show-file='chflags nohidden'

  # System maintenance
  alias update-macos='sudo softwareupdate -i -a'
  alias flush-dns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
  alias clear-logs='sudo rm -rf /var/log/*'
  alias system-cleanup='echo "Running macOS maintenance..."; brew cleanup; brew doctor; sudo softwareupdate -i -a'

fi

# ============================================
# Safety Nets
# ============================================
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
