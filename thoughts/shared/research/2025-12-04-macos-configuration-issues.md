---
date: 2025-12-04T19:01:33Z
researcher: brennon
git_commit: c8d3bfe08d69c09118fea7d13501c03c264518fb
branch: main
repository: BrennonTWilliams/dotfiles
topic: "macOS Dotfiles Configuration Issues Analysis"
tags: [research, codebase, macos, shell, homebrew, launchd, ghostty]
status: complete
last_updated: 2025-12-04
last_updated_by: brennon
---

# Research: macOS Dotfiles Configuration Issues Analysis

**Date**: 2025-12-04T19:01:33Z
**Researcher**: brennon
**Git Commit**: c8d3bfe08d69c09118fea7d13501c03c264518fb
**Branch**: main
**Repository**: BrennonTWilliams/dotfiles

## Research Question

Analyze dotfiles configurations for macOS to identify potential issues and problems.

## Summary

This analysis identified **27 issues** across macOS configurations, categorized by severity:

| Severity | Count | Description |
|----------|-------|-------------|
| **Critical** | 4 | Breaking issues that cause failures |
| **High** | 5 | Significant issues affecting functionality |
| **Medium** | 10 | Compatibility or logic issues |
| **Low** | 8 | Minor issues or inefficiencies |

The most critical issues are:
1. `readlink -f` flag unsupported on macOS BSD (breaks 3 functions)
2. `sleep` command override breaks all scripts using sleep delays
3. Hardcoded network interface `en0` fails on many Mac configurations
4. Ghostty Automator workflow doesn't actually change directory

---

## Critical Issues

### 1. `readlink -f` Incompatibility
**Files**: `zsh/.zsh_cross_platform:670,698,722`

```bash
local script_dir="$(dirname "$(readlink -f "${(%):-%x}")")"
```

**Problem**: macOS ships with BSD `readlink` which does NOT support the `-f` flag (GNU extension). This causes three functions to fail:
- `uniclip_manager()` - Uniclip service management
- `setup_dev_env()` - Development environment setup
- `dotfiles_health_check()` - Health check functionality

**Error**: `readlink: illegal option -- f`

**Fix**: Use a POSIX-compatible alternative:
```bash
local script_dir="$(cd "$(dirname "${(%):-%x}")" && pwd -P)"
```

---

### 2. POSIX `sleep` Command Override
**File**: `zsh/abbreviations/macos.zsh:52`

```bash
abbr -S --force --quiet sleep='pmset sleepnow'
```

**Problem**: Overrides the standard `/bin/sleep` command which takes time arguments. Any script using `sleep 5` will immediately put the Mac to sleep instead of waiting 5 seconds.

**Impact**: Breaks shell scripts, cron jobs, and any automation using sleep delays.

**Fix**: Remove this abbreviation or rename to `macsleep` or `hibernate`.

---

### 3. Hardcoded Network Interface `en0`
**Files**: `zsh/abbreviations/macos.zsh:33,85`

```bash
wifi-info='networksetup -getairportinfo en0'
ip-local='ipconfig getifaddr en0'
```

**Problem**: Network interface names vary across Mac models:
- Built-in Wi-Fi can be `en0`, `en1`, or other
- USB-C/Thunderbolt adapters create `en7`, `en8`, etc.
- Commands fail silently on systems where primary interface isn't `en0`

**Fix**: Dynamically detect interface:
```bash
wifi_if=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
```

---

### 4. Ghostty Automator Workflow Directory Issue
**File**: `ghostty/automator/Open Ghostty Here.workflow/Contents/document.wflow:75`

```applescript
do shell script "open -a Ghostty " & quoted form of currentPath
```

**Problem**: `open -a Ghostty <path>` launches Ghostty but does NOT change to the specified directory. The path argument is ignored.

**Fix**: Use Ghostty's command-line interface or AppleScript to send `cd` command after launch.

---

## High Severity Issues

### 5. Uniclip Plist Hardcoded Apple Silicon Path
**File**: `macos/com.uniclip.plist:10`

```xml
<string>/opt/homebrew/bin/uniclip</string>
```

**Problem**: Hardcoded to Apple Silicon Homebrew path. Intel Macs use `/usr/local/bin/`.

**Note**: The `uniclip-manager` script patches this dynamically, but direct use of `install-uniclip-service.sh` will fail on Intel Macs.

---

### 6. Deprecated Airport Utility
**File**: `zsh/functions/macos.zsh:9-20,58-76`

**Problem**: The airport command (`/System/Library/PrivateFrameworks/Apple80211.framework/...`) is deprecated as of macOS Monterey and may be removed in future versions.

---

### 7. Dangerous Auto-Update Command
**File**: `zsh/abbreviations/macos.zsh:121`

```bash
update-macos='sudo softwareupdate -i -a'
```

**Problem**: The `-a` flag installs ALL updates without confirmation, including major macOS version upgrades. Can break software compatibility unexpectedly.

**Fix**: Remove `-a` flag or add confirmation prompt.

---

### 8. DYLD_LIBRARY_PATH and SIP
**File**: `bash/.bashrc:10`

```bash
Darwin*) export DYLD_LIBRARY_PATH="$HOME/.local/lib:$DYLD_LIBRARY_PATH" ;;
```

**Problem**: macOS System Integrity Protection (SIP) strips `DYLD_LIBRARY_PATH` from protected binaries in `/usr/bin`, `/bin`, etc. The variable is silently ignored for most system commands.

---

### 9. Missing Homebrew PATH Initialization
**File**: `bash/.bashrc:39-40`

**Problem**: Only sources Homebrew's bash completion, but never initializes PATH for Homebrew binaries. The `brew` command won't be available unless PATH is set elsewhere.

**Fix**: Add `eval "$(/opt/homebrew/bin/brew shellenv)"` or equivalent.

---

## Medium Severity Issues

### 10. CPU Temperature Hardcoded Intel Path
**File**: `zsh/functions/macos.zsh:36`

```bash
/usr/local/bin/osx-cpu-temp
```

**Problem**: Assumes Intel Mac Homebrew location. Apple Silicon uses `/opt/homebrew/bin/`.

---

### 11. Uniclip Service Running Detection Flawed
**File**: `scripts/uniclip-manager:75-77`

```bash
macos_service_running() {
    launchctl list | grep "$SERVICE_NAME" | grep -v "0" >/dev/null 2>&1
}
```

**Problem**: `grep -v "0"` excludes any line containing character "0", causing false positives/negatives for PIDs or status codes containing 0.

---

### 12. `pbs -flush` May Not Exist
**File**: `ghostty/automator/install-quick-actions.sh:148`

**Problem**: The `pbs` (pasteboard server) command path and usage may have changed in recent macOS versions.

---

### 13. Bash 3.2 `globstar` Incompatibility
**File**: `bash/.bashrc:25`

```bash
shopt -s globstar 2>/dev/null
```

**Problem**: `globstar` requires bash 4.0+. macOS ships with bash 3.2. Feature silently unavailable.

---

### 14. Xcode Simulator Filter Case-Sensitivity
**File**: `zsh/abbreviations/macos.zsh:74`

```bash
simulators-list='xcrun simctl list devices available'
```

**Problem**: Filter should be `Available` (capital A), not `available`.

---

### 15. Lock Command Doesn't Actually Lock
**File**: `zsh/abbreviations/macos.zsh:50`

```bash
lock='pmset displaysleepnow'
```

**Problem**: Only sleeps display, doesn't lock screen. Misleading name suggests security that isn't provided.

---

### 16. Brew Stats Output Order Wrong
**File**: `zsh/abbreviations/macos.zsh:28`

```bash
brew-stats='brew info --json=v2 | jq -r ".formulae | length" | xargs echo "Installed formulae:"'
```

**Problem**: Outputs `42 Installed formulae:` instead of `Installed formulae: 42`.

---

### 17. Airport Fallback Still Uses Deprecated Command
**File**: `zsh/functions/macos.zsh:70`

**Problem**: The wifi-scan fallback branch still attempts to use the deprecated airport command after detecting it's unavailable.

---

### 18. Font Name May Not Match
**File**: `ghostty/.config/ghostty/config:27`

```
font-family = IosevkaTerm Nerd Font
```

**Problem**: Font names are case-sensitive. Nerd Font variants may be installed with different names (e.g., "IosevkaTerm Nerd Font Mono").

---

### 19. Conda PATH Duplication
**File**: `bash/.bash_profile:25,37`

**Problem**: Conda bin directory added twice to PATH - once immediately and once during lazy-init.

---

## Low Severity Issues

### 20. Duplicate `window-decoration` Setting
**File**: `ghostty/.config/ghostty/config:48,61`

**Problem**: Setting appears twice (redundant but harmless).

---

### 21. Lock Alias Path Escaping
**File**: `zsh/.zsh_cross_platform:649`

```bash
alias lock='/System/Library/CoreServices/Menu\\ Extras/User.menu/...'
```

**Problem**: Unnecessary double-escaping inside single quotes.

---

### 22. Bash Completion Fallback Order
**File**: `bash/.bashrc:35-41`

**Problem**: Checks Linux paths before macOS, causing two failed checks on every shell startup.

---

### 23. QuickLook Redirection Syntax
**File**: `zsh/functions/macos.zsh:85`

```bash
qlmanage -p "$@" >& /dev/null &
```

**Problem**: `>& /dev/null` is not POSIX-compliant. Should be `>/dev/null 2>&1`.

---

### 24. `zoxide` Missing from Reference Package List
**File**: `packages-macos-reference.txt`

**Problem**: `zoxide` is in `packages-macos.txt` but missing from `packages-macos-reference.txt`.

---

### 25. Uniclip Logs to /tmp (No Rotation)
**File**: `macos/com.uniclip.plist:20-24`

**Problem**: Logs grow unbounded until reboot. No log rotation configured.

---

### 26. Apple Silicon Sysctls Silent Failure
**File**: `zsh/abbreviations/macos.zsh:101-102`

**Problem**: `hw.perflevel` sysctls only exist on Apple Silicon, silently return "N/A" on Intel.

---

### 27. Font Installation Not Implemented
**File**: `scripts/setup-terminal.sh:50`

**Problem**: Font installation function is defined but only prints warnings, doesn't actually install fonts.

---

## Code References

### Shell Configuration
- `zsh/.zsh_cross_platform:670,698,722` - readlink -f incompatibility
- `zsh/abbreviations/macos.zsh:52` - sleep override
- `zsh/abbreviations/macos.zsh:33,85` - hardcoded en0
- `zsh/functions/macos.zsh:9-76` - deprecated airport command
- `bash/.bashrc:10` - DYLD_LIBRARY_PATH
- `bash/.bashrc:25` - globstar bash 3.2

### Services
- `macos/com.uniclip.plist:10` - hardcoded path
- `scripts/uniclip-manager:75-77` - service detection logic

### Ghostty
- `ghostty/.config/ghostty/config:27` - font configuration
- `ghostty/automator/Open Ghostty Here.workflow/Contents/document.wflow:75` - directory change

### Installation
- `scripts/setup-terminal.sh:50` - font installation stub
- `scripts/setup-packages.sh:141-142` - hardcoded package list

---

## Architecture Documentation

### Platform Detection Methods

1. **OSTYPE variable**: `[[ "$OSTYPE" == "darwin"* ]]`
2. **uname command**: `case "$(uname -s)" in Darwin*)`
3. **Homebrew path detection**: Checks `/opt/homebrew` (ARM) vs `/usr/local` (Intel)

### Shell Sourcing Chain

**Zsh**:
1. `.zshenv` - PATH, JetBrains Toolbox
2. `.zshrc` - Sources `.zsh_cross_platform`
3. `.zshrc` - Sources `functions/_init.zsh` -> `functions/macos.zsh`
4. `.zshrc` - Sources `abbreviations/_init.zsh` -> `abbreviations/macos.zsh`

**Bash**:
1. `.bash_profile` - Conda, sources `.bashrc`
2. `.bashrc` - DYLD_LIBRARY_PATH, completions, integrations

### Service Architecture

- **Uniclip**: launchd user agent in `~/Library/LaunchAgents/`
- **Configuration**: `KeepAlive=true` + `StartInterval=300`
- **Logs**: `/tmp/uniclip.log`, `/tmp/uniclip.error.log`

---

## Related Research

None currently.

## Open Questions

1. Should deprecated `airport` functions be removed entirely or replaced with modern alternatives?
2. What is the best approach for cross-architecture Homebrew path handling?
3. Should the `sleep` override be removed completely given its breaking nature?
4. Is the Ghostty Quick Action feature used enough to warrant fixing the directory change issue?
