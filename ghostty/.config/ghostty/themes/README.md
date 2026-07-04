# Ghostty Themes — Gruvbox Custom Collection

The two active themes for Ghostty terminal, wired into `~/.config/ghostty/config` (the main config) and toggled by `toggle-theme` in `~/.zshrc`.

## Available Themes

### gruvbox-dark-custom

The active **dark** theme (header comment: "Bren Dark"). Built on the Gruvbox dark0_hard background with a full 16-color Gruvbox palette and a darker-blue selection color chosen for readability against cream/gold text.

| Slot | Value | Comment |
|---|---|---|
| Background | `#1d2021` | dark0_hard — deeper than pure black |
| Foreground | `#ebdbb2` | light1 — cream |
| Cursor | `#ebdbb2` | off-white for high visibility |
| Selection bg / fg | `#458588` / `#ebdbb2` | darker blue selection; cream selection text |

### gruvbox-light-custom

The only **light** theme in this directory. Uses Gruvbox light0_hard background and the canonical light-theme orange (`#af3a03`) shared across Ghostty, tmux, and Starship so the "orange = active/accent" semantic reads the same in every layer.

| Slot | Value | Comment |
|---|---|---|
| Background | `#f9f5d7` | light0_hard — warm cream |
| Foreground | `#3c3836` | dark1 |
| Cursor | `#af3a03` | light orange; matches tmux current-window + Starship directory |
| Selection bg / fg | `#d5c4a1` / `#3c3836` | light3 selection; dark1 selection text |

## Theme Switching

`toggle-theme` (see `zsh/.zshrc`) handles the switch. It writes the active theme to `~/.config/ghostty/config.local` and reloads Ghostty via `killall -USR2 ghostty`. Because `config.local` pins a single theme, it overrides the auto `light:...,dark:...` follow declared in the main `config`. To restore automatic light/dark tracking, delete `~/.config/ghostty/config.local` and reload.

## Customization

1. Edit the theme file (`gruvbox-dark-custom` or `gruvbox-light-custom`).
2. Reload Ghostty: `toggle-theme` re-applies the active theme via SIGUSR2, or restart Ghostty for a full reload.
3. If you also change the tmux `if-shell` block (`tmux/.tmux.conf:288-330`) or the Starship palette (`starship/.config/starship/gruvbox-rainbow*`), keep the shared accent color coordinated (the orange family, in particular: `#af3a03` for light, `#fe8019`/`#d65d0e` for dark).

Colors use standard hex format (`#RRGGBB`).

## Compatibility

- **Ghostty Version**: Compatible with modern Ghostty releases
- **System**: Designed for macOS (the main config lives under `ghostty/.config/ghostty/config`); Linux uses `ghostty_x11` packages configured separately
- **Display**: Optimized for Retina and standard displays; solid background for maximum readability
- **Color Profile**: Works with sRGB

## Inspiration

Authentic Gruvbox light/dark palettes extended with explicit selection and cursor tuning for shell-integration use. The light variant was tuned so its orange accent matches tmux and Starship so the same color always means "active element" across the stack.

---

**Created**: 2025-11-18 (gruvbox variants); README revised 2026-07-04 to reflect active themes
**Inspiration**: Pavel Pertsev's Gruvbox + cross-tool UX consistency
