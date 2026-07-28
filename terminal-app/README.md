# terminal-app

Generated Terminal.app profiles that give Terminal.app the same gruvbox palette
and Iosevka Nerd Font as the Ghostty + tmux setup.

## This is not a Stow package

Terminal.app does not read a config file from `$HOME`. It stores profiles inside
its own preferences (`com.apple.Terminal`, key `Window Settings`), so these files
are *imported*, not symlinked. `install.sh` discovers Stow packages by looking
for a top-level dot-entry in each directory (`install.sh:60-72`); this directory
has none, so it is skipped automatically.

## Files

| File | Source theme |
| --- | --- |
| `Gruvbox Dark Custom.terminal` | `ghostty/.config/ghostty/themes/gruvbox-dark-custom` |
| `Gruvbox Light Custom.terminal` | `ghostty/.config/ghostty/themes/gruvbox-light-custom` |

Both are generated - do not hand-edit them.

## Install

```bash
terminal-profile-install          # import both, set dark as default (abbr: tp)
terminal-profile-install light    # import both, set light as default
```

Or import by hand:

```bash
open "Gruvbox Dark Custom.terminal"
```

Then Terminal > Settings > Profiles > Default.

## Regenerate

Run this whenever a Ghostty theme file or the font settings in
`ghostty/.config/ghostty/config` change:

```bash
scripts/generate-terminal-profile.sh
```

The generator is deterministic - regenerating without an upstream change
produces no diff, and `tests/test_terminal_profile.sh` asserts that.

## How the palette gets in there

Terminal.app's AppleScript dictionary exposes only `background color`,
`normal text color`, `bold text color`, `cursor color`, `font name` and
`font size` - there is no scriptable access to the 16 ANSI slots. Those live in
the profile plist as `ANSIBlackColor` ... `ANSIBrightWhiteColor`, each an
`NSKeyedArchiver`-encoded `NSColor` (sRGB, `NSColorSpace = 2`, with the channel
values stored as a NUL-terminated ASCII float string). The generator builds
those archives with Python's stdlib `plistlib`, so no `pyobjc` dependency is
needed.

## What does not carry over

- **`selection-foreground`** - Terminal.app has only `SelectionColor`; it
  derives the selected text color itself.
- **`cursor-text`** - same, no equivalent key.
- **Nerd Font glyph pinning** - not needed here, despite Ghostty carrying a
  `font-codepoint-map` block (`ghostty/.config/ghostty/config:52-68`) that pins
  Nerd Font PUA ranges to `Symbols Nerd Font Mono`. Terminal.app has no
  per-codepoint fallback control, but it does not need one: measured against
  `IosevkaTermNerdFont-Regular.ttf`, every Nerd Font PUA codepoint carries an
  advance width of 500/1000 upm - identical to `A` - so nothing renders
  double-width. CoreText also resolves all of them from `IosevkaTermNF` itself
  with zero font fallback. The Ghostty pinning is a legacy workaround.
- **True color** - Terminal.app is 256-color only.
- **Automatic light/dark** - Terminal.app cannot follow the macOS appearance the
  way Ghostty's `theme = light:...,dark:...` line does. `toggle-theme` is
  deliberately not wired to it; switch in Terminal > Settings or re-run
  `terminal-profile-install` with the other mode.

See `docs/TERMINAL_APP_SETUP.md` for the full walkthrough.
