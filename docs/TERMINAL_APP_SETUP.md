# Terminal.app Setup

**Give macOS Terminal.app the same gruvbox palette and Iosevka Nerd Font as the Ghostty + tmux setup, generated directly from the Ghostty theme files.**

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [What Gets Applied](#what-gets-applied)
- [Regenerating the Profiles](#regenerating-the-profiles)
- [Switching Light and Dark](#switching-light-and-dark)
- [Known Limitations](#known-limitations)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

---

## Overview

Ghostty is themed from `ghostty/.config/ghostty/themes/gruvbox-{dark,light}-custom`,
and the tmux status bar is hand-matched to those same hex values
(`tmux/.tmux.conf:288-330`). Terminal.app previously got none of it - opening it
gave the stock `Basic` profile.

This setup generates two Terminal.app profiles from those exact theme files, so
the palette cannot drift out of sync. The generated `.terminal` files live in
`terminal-app/`, which is **not** a Stow package: Terminal.app imports profiles
into its own preferences rather than reading a symlink from `$HOME`.

---

## Quick Start

```bash
# Import both profiles and set the dark one as default
terminal-profile-install

# Abbreviation form (abbr mode) or alias (alias mode)
tp
```

Then open a **new** Terminal window - existing windows keep the profile they
started with.

Verify the palette:

```bash
# Should print 16 color swatches matching the Ghostty palette
for i in {0..15}; do printf "\e[48;5;${i}m  \e[0m"; done; echo
```

---

## What Gets Applied

| Ghostty theme setting | Terminal.app profile key |
| --- | --- |
| `palette = 0..15` | `ANSIBlackColor` ... `ANSIBrightWhiteColor` |
| `background` | `BackgroundColor` |
| `foreground` | `TextColor` |
| `bold-color` | `TextBoldColor` |
| `cursor-color` | `CursorColor` |
| `selection-background` | `SelectionColor` |
| `font-family` + `font-size` from `ghostty/.config/ghostty/config` | `Font` |

The dark profile uses `#1d2021` (Gruvbox dark0-hard), matching
`gruvbox-dark-custom` exactly. The tmux status bar (`#282828`) reads as a
slightly lighter band - the same as it does in Ghostty today.

The font family is read from the Ghostty config rather than hardcoded. Terminal
profiles store the **PostScript** name, not the family name (for
`IosevkaTerm Nerd Font` that is `IosevkaTermNF`), so the generator resolves it
from the installed font database and falls back to `Menlo-Regular` with a
warning when the font is missing.

---

## Regenerating the Profiles

Run this whenever a Ghostty theme file or the font settings change:

```bash
# Preview without writing
scripts/generate-terminal-profile.sh --dry-run

# Write terminal-app/*.terminal
scripts/generate-terminal-profile.sh

# Verify - a clean regeneration produces no diff
git diff --stat terminal-app/
```

Then re-run `terminal-profile-install` to re-import.

The generator is deterministic; `tests/test_terminal_profile.sh` asserts both
determinism and exact palette parity against the Ghostty theme files.

---

## Switching Light and Dark

Terminal.app cannot follow the macOS appearance the way Ghostty's
`theme = light:...,dark:...` line does, and it has no `config.local`-style
override layering. `toggle-theme` is deliberately **not** wired to Terminal.app.

To switch:

```bash
terminal-profile-install light   # or: terminal-profile-install dark
```

Or pick the profile in Terminal > Settings > Profiles > Default.

---

## Known Limitations

| Limitation | Detail |
| --- | --- |
| 256 colors only | Terminal.app has no true-color support. Anything emitting 24-bit escapes degrades to the nearest indexed color. |
| No per-codepoint font fallback (not a problem in practice) | Ghostty pins Nerd Font PUA ranges to `Symbols Nerd Font Mono` via `font-codepoint-map` (`ghostty/.config/ghostty/config:52-68`). Terminal.app has no equivalent and does not need one: every Nerd Font PUA glyph in `IosevkaTerm Nerd Font` already has the same advance width as `A` (500/1000 upm), and CoreText resolves all of them from `IosevkaTermNF` with no fallback. Glyphs render correctly bare and inside tmux. |
| No auto light/dark | See above. |
| No `selection-foreground` / `cursor-text` | Terminal.app derives these itself; the Ghostty values are dropped. |
| Starship stays ASCII-safe | `zsh/.zshrc:495-497` forces `starship/.config/starship/terminal.toml` when `TERM_PROGRAM=Apple_Terminal`. This is intentional. Note that with the Nerd Font profile installed this is now the **only** reason the Terminal.app prompt shows fewer glyphs than Ghostty - the font itself is fully capable. The comment above that block, "no Nerd Font support", describes Terminal.app's stock state, not the state after installing these profiles. |

---

## Troubleshooting

### The profile imported but the colors did not change

Terminal.app applies a profile to **new** windows only. Open a new window, and
confirm the default is set under Terminal > Settings > Profiles.

### `terminal-profile-install` says the profiles were not found

Generate them first:

```bash
scripts/generate-terminal-profile.sh
```

### The generator warns about a fallback font

`IosevkaTerm Nerd Font` is not installed. Install the fonts, then regenerate:

```bash
scripts/setup-terminal.sh
scripts/generate-terminal-profile.sh
```

### Glyphs render as boxes or at the wrong width inside tmux

Expected - see [Known Limitations](#known-limitations). Terminal.app cannot
reproduce Ghostty's codepoint-map fallback. Use Ghostty when glyph fidelity
matters.

### `terminal-profile-install` imported the profiles but could not set the default

The AppleScript step needs Terminal.app to have registered the freshly imported
settings set. Re-run the command, or set the default by hand in
Terminal > Settings > Profiles.

---

## Additional Resources

- `terminal-app/README.md` - how the plist archives are built, and what does not carry over
- `docs/MACOS_SETUP.md` - full macOS setup
- `docs/GHOSTTY_TROUBLESHOOTING.md` - Ghostty-side font and theme issues
- `ghostty/.config/ghostty/themes/README.md` - the palette source of truth
