# Enhanced Ghostty Statusline Configuration

This document explains the statusline enhancements added to your Ghostty terminal experience.

## Overview

Since Ghostty doesn't have built-in configurable statuslines, we've enhanced the terminal experience through:

1. **Shell-based statusline** via zsh prompt configuration
2. **Tab bar configuration** for visual status
3. **Resize overlays** for visual feedback
4. **Enhanced theme colors** for better readability
5. **Navigation keybindings** for prompt jumping

## Features

### 1. Enhanced Shell Prompt

Your zsh prompt now includes:

- **Virtual environment info**: Shows Python/conda environments in cyan
- **Git status**: Branch name with color-coded status (green=clean, red=dirty+file count)
- **Working directory**: Shortened path in blue (max 3 directories deep)
- **Command timing**: Shows execution time for commands > 1 second in yellow
- **Visual structure**: Box drawing characters for clean layout
- **Right-side timestamp**: Current time and background job count

### 2. Tab Bar Configuration

- Auto-hiding tab bar (`window-show-tab-bar = auto`)
- New tabs open at current position (`window-new-tab-position = current`)

### 3. Resize Overlays

- Shows after first resize (`resize-overlay = after-first`)
- Centered position (`resize-overlay-position = center`)
- 2-second duration (`resize-overlay-duration = 2000`)

### 4. Enhanced Theme Colors

- Optimized bold colors for better statusline readability
- Enhanced contrast for shell integration

### 5. Navigation Keybindings

- `Cmd+↑`: Jump to previous prompt
- `Cmd+↓`: Jump to next prompt

## Color Scheme

The statusline uses this color scheme (256-color terminal):

- **Magenta** (013): Box drawing characters
- **Cyan** (014): Virtual environments
- **Blue** (012): Directory paths
- **Green** (010): Clean git status
- **Red** (009): Dirty git status
- **Yellow** (011): Command timing
- **Gray** (008): Timestamp
- **Light gray**: Job count indicator

## Usage Examples

### Clean git repository:
```
┌─[(venv) ~/projects]─[± main]─❯
└─❯
```

### Dirty git repository with modified files:
```
┌─[(base) ~/dotfiles]─[± main*3]─2.5s
└─❯
```

### With background jobs:
```
┌─[~/work]─[± feature-branch*1]─❯                    14:32:15 +2
└─❯
```

## Customization

### Adding More Status Information

Edit `~/.config/zsh/.zshrc` to add more functions to the prompt:

```bash
# Example: Add Kubernetes context
kubectl_context() {
    if command -v kubectl >/dev/null 2>&1; then
        local ctx=$(kubectl config current-context 2>/dev/null)
        if [[ -n $ctx ]]; then
            echo "%F{013}☸ $ctx%f "
        fi
    fi
}

# Add to PROMPT:
PROMPT='
%F{013}┌─[%f$(venv_info)$(kubectl_context)$(short_path)%F{013}]─[%f$(git_status)%F{013}]%f$__timer_info
%F{013}└─❯%f '
```

### Changing Colors

Modify the color codes in the zsh functions:
- `%F{###}`: Set foreground color
- `%f`: Reset to default color
- Available colors: 000-255 (256-color palette)

### Adjusting Prompt Layout

Change the `PROMPT` variable to modify the layout. The box characters can be customized:
- `┌─` and `└─`: Corner characters
- `─`: Horizontal line
- `❯`: Prompt character

## Terminal Title Integration

The terminal title automatically updates to show:
- **During command**: `directory: command`
- **After command**: `directory`

This works with Ghostty's native titlebar integration.

## Performance Considerations

- Git status is only calculated when in a git repository
- Command timing uses efficient date calculations
- Prompt updates are minimized using `zle reset-prompt`

## Troubleshooting

### If colors don't appear correctly:
1. Ensure your terminal supports 256 colors
2. Check that `TERM=xterm-256color` is set
3. Restart Ghostty after configuration changes

### If git status is slow:
1. Large repositories may cause delays
2. Consider using `git status --porcelain` optimization
3. Disable git status check if not needed

### If timing doesn't work:
1. Ensure `bc` is installed (should be at `/usr/bin/bc` on macOS)
2. Check that date command supports nanoseconds (`date +%s.%N`)

## Files Modified

- `ghostty/.config/ghostty/config`: Added tab bar, resize overlays, keybindings
- `ghostty/.config/ghostty/themes/bren-dark`: Enhanced colors for statusline
- `zsh/.zshrc`: Added comprehensive statusline functions and prompt

Reload your shell or restart Ghostty to see all changes take effect.