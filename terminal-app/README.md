# terminal-app

Generated Terminal.app profiles that give Terminal.app the same gruvbox palette
and font size as the Ghostty + tmux setup.

The font *family* deliberately differs: Ghostty renders IosevkaTerm Nerd Font,
Terminal.app renders Hack Nerd Font Mono, because Iosevka's box-drawing glyphs
break apart in Terminal.app. See [Box-drawing continuity](#box-drawing-continuity)
below.

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

## Box-drawing continuity

Ghostty rasterizes box-drawing characters itself, stretching them to the full
cell, so tmux pane borders join into one unbroken line no matter what the font's
own glyphs look like. Terminal.app has no such override - it draws the font's
glyph inside its own line box, and whether the borders connect is therefore a
property of the font.

Measured by printing 14 stacked `U+2502` and 20 adjacent `U+2500` into a real
Terminal.app window, capturing it with `screencapture -l` on a 2x display at
16pt, and counting unlit pixel rows/columns between cells:

| Font | Vertical `U+2502` x14 | Horizontal `U+2500` x20 |
| --- | --- | --- |
| IosevkaTerm Nerd Font | 14 broken runs, **7px black gap per cell** | connected |
| **Hack Nerd Font Mono** | **one 489px run, 0 unlit rows** | one 401px run, 0 unlit cols |
| Menlo | one 490px run, 0 unlit rows | one 401px run, 0 unlit cols |

Terminal.app lays out a 48px line box for Iosevka's 41px `U+2502` glyph, which
is flush to the font's own 1.25em line box with zero overshoot - hence the gap.
Hack's box-drawing overdraws its cell (104% of the font line box), so adjacent
cells overlap and no seam can appear. Hack is the default for that reason; it is
also a Nerd Font, so starship and tmux glyph coverage is unaffected. The cost is
a wider cell (0.602em advance vs Iosevka's 0.500em), so a given column count
yields a wider window.

Hack's vertical seams do still dip to 28% of peak luminance - fully lit, no black
rows, but faintly visible on close inspection. Menlo holds 61% and is the most
robust option, at the cost of all Nerd Font glyph coverage.

To trade pane borders back for exact font parity with Ghostty:

```bash
scripts/generate-terminal-profile.sh --font ghostty
```

### Line spacing is not a fix

`FontHeightSpacing` / `FontWidthSpacing` (Terminal's Text tab) are written to
the profile and settable via `--line-spacing` / `--char-spacing`, but they
cannot repair broken box-drawing: Terminal.app clamps its minimum line height,
so at 16pt on a 2x display `0.86`, `0.84` and `0.82` all measure the same 42px
cell pitch, and a gap survives against a 41px glyph. Both default to `1.0`.

## What does not carry over

- **`selection-foreground`** - Terminal.app has only `SelectionColor`; it
  derives the selected text color itself.
- **`cursor-text`** - same, no equivalent key.
- **Nerd Font glyph pinning** - not needed here, despite Ghostty carrying a
  `font-codepoint-map` block (`ghostty/.config/ghostty/config:52-68`) that pins
  Nerd Font PUA ranges to `Symbols Nerd Font Mono`. Terminal.app has no
  per-codepoint fallback control, but it does not need one: measured against
  `HackNerdFontMono-Regular.ttf`, all 9304 Nerd Font PUA codepoints it carries
  have an advance width of 1233/2048 upm - identical to `A` - so nothing renders
  double-width. Coverage matches Iosevka's for practical purposes (23 codepoints
  in the scanned ranges absent from Hack vs 21 from IosevkaTerm; the two extra
  are `U+E0AE`/`U+E0AF` powerline variants). The Ghostty pinning is a legacy
  workaround.
- **True color** - Terminal.app is 256-color only.
- **Automatic light/dark** - Terminal.app cannot follow the macOS appearance the
  way Ghostty's `theme = light:...,dark:...` line does. `toggle-theme` is
  deliberately not wired to it; switch in Terminal > Settings or re-run
  `terminal-profile-install` with the other mode.

See `docs/TERMINAL_APP_SETUP.md` for the full walkthrough.
