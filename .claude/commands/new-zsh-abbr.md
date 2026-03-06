---
description: Add a new ZSH abbreviation to the appropriate category file
---

# Add ZSH Abbreviation

Parse the user's input to create a new ZSH abbreviation with automatic category detection and duplicate checking.

## Input Format
The argument follows the pattern: `<abbreviation>= <expanded command>`

Example: `dirs= eza -T scripts/ -D --git-ignore`

## Steps

### 1. Parse the Input
- Extract abbreviation name (text before `=`)
- Extract expansion (text after `=` and any following whitespace)
- Trim whitespace from both

### 2. Check for Duplicates
Before adding, search all files in `zsh/abbreviations/` for:

**Exact abbreviation match:**
```
Grep pattern: "abbr -[gS]*S.*<name>=" in zsh/abbreviations/*.zsh
```

**Exact expansion match:**
```
Grep pattern: "abbr -[gS]*S.*='<expansion>'" in zsh/abbreviations/*.zsh
```

If duplicates found, use AskUserQuestion with options:
- **Replace**: Delete the existing abbreviation and add the new one
- **Rename**: Keep both, suggest alternative name for new one (e.g., `<name>2`)
- **Cancel**: Don't add anything

### 3. Auto-Detect Category
Apply detection rules in priority order:

| Priority | Category | Detection Rules |
|----------|----------|-----------------|
| 1 | git | Expansion starts with `git ` |
| 2 | tmux | Expansion starts with `tmux ` |
| 3 | navigation | Expansion starts with `cd `, `z `, `zi `, `eza -T`, `ls -T`, `tree ` |
| 4 | macos | Expansion contains: `brew`, `open -a`, `pbpaste`, `pbcopy`, `networksetup`, `pmset`, `sw_vers`, `system_profiler`, `xcode`, `xcrun`, `defaults `, `xattr`, `chflags`, `arch ` |
| 5 | linux | Expansion contains: `apt`, `dpkg`, `dnf`, `yum`, `pacman`, `systemctl` |
| 6 | development | Expansion contains: `python`, `pip`, `node`, `npm`, `yarn`, `pnpm`, `cargo`, `rustc`, `go run`, `netstat`, `lsof`, `claude`, `nvim`, `docker`, `kubectl`, `make` |
| 7 | system | Default fallback |

**Confidence Levels:**
- **HIGH** (proceed without asking): git, tmux, navigation categories detected
- **MEDIUM** (ask to confirm): macos/linux/development detected
- **LOW** (ask user to select): No patterns matched, falls back to system

### 4. Confirm Category (if needed)
Only ask the user when confidence is MEDIUM or LOW.

For MEDIUM confidence, use AskUserQuestion with:
- Show detected category with "(Recommended)" label
- Include description explaining the match
- Allow user to override

For LOW confidence, use AskUserQuestion with:
- Present all category options
- Default selection: system

### 5. Add the Abbreviation
Append to the selected file in format:
```zsh
abbr -S <name>='<expansion>'
```

The target file is: `zsh/abbreviations/<category>.zsh`

### 6. Confirm Completion
Show the user what was added and where:
```
Added abbreviation '<name>' to <category>.zsh:
  <name> -> <expansion>
```

## Examples

| Input | Auto-Detected Category | Confidence |
|-------|------------------------|------------|
| `gs= git status` | git | HIGH |
| `tls= tmux ls` | tmux | HIGH |
| `..= cd ..` | navigation | HIGH |
| `ports= netstat -tulanp` | development | MEDIUM |
| `brewinfo= brew info` | macos | MEDIUM |
| `mycmd= some unknown command` | system (fallback) | LOW |
