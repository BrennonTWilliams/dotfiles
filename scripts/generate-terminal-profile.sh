#!/usr/bin/env bash

# ==============================================================================
# Terminal.app Profile Generator
# ==============================================================================
# Generates Terminal.app .terminal profiles from the Ghostty gruvbox themes so
# Terminal.app renders with the same palette and font as Ghostty + tmux.
#
# Terminal.app's AppleScript dictionary exposes only background/text/bold/cursor
# colors - not the 16 ANSI slots - so the palette has to be written directly
# into the profile plist as NSKeyedArchiver-encoded NSColor blobs. This script
# builds those archives with Python's stdlib plistlib (no pyobjc required).
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source utilities
source "$SCRIPT_DIR/lib/utils.sh"

# ==============================================================================
# Configuration
# ==============================================================================

# Ghostty theme directory (source of truth for the palette)
THEMES_DIR="$DOTFILES_DIR/ghostty/.config/ghostty/themes"

# Ghostty config (source of truth for font family and size)
GHOSTTY_CONFIG="$DOTFILES_DIR/ghostty/.config/ghostty/config"

# Default output directory for the generated .terminal files
OUTPUT_DIR="$DOTFILES_DIR/terminal-app"

# Ghostty theme name -> Terminal.app profile name
declare -a PROFILE_MAP=(
    "gruvbox-dark-custom:Gruvbox Dark Custom"
    "gruvbox-light-custom:Gruvbox Light Custom"
)

# Fallback font when the configured family is not installed on this machine
FALLBACK_FONT_PS_NAME="Menlo-Regular"

DRY_RUN=false

# ==============================================================================
# Usage
# ==============================================================================

show_usage() {
    cat <<'USAGE'
Usage: generate-terminal-profile.sh [OPTIONS]

Generates Terminal.app profiles from the Ghostty gruvbox themes.

Options:
  --output-dir DIR   Write .terminal files to DIR (default: <dotfiles>/terminal-app)
  --dry-run          Show what would be generated without writing files
  -h, --help         Show this help message

The generated profiles are imported with 'terminal-profile-install' (abbr: tp)
or by running: open "<dotfiles>/terminal-app/Gruvbox Dark Custom.terminal"
USAGE
}

# ==============================================================================
# Font Resolution
# ==============================================================================

# Read a single-valued setting out of the Ghostty config.
# Ghostty allows repeated font-family lines (the glyph fallback stack); we want
# the first one, which is the primary family.
ghostty_setting() {
    local key="$1"
    grep -E "^[[:space:]]*${key}[[:space:]]*=" "$GHOSTTY_CONFIG" \
        | head -n1 \
        | sed -E "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*//" \
        | sed -E 's/[[:space:]]+$//'
}

# Terminal.app profiles store the PostScript name, not the family name. For
# IosevkaTerm Nerd Font these differ ("IosevkaTermNF"), so resolve it from the
# installed font database rather than guessing.
resolve_postscript_name() {
    local family="$1"

    if [ "$(uname -s)" != "Darwin" ]; then
        echo ""
        return 0
    fi

    /usr/bin/python3 - "$family" <<'PYTHON'
import json
import subprocess
import sys

family = sys.argv[1]

try:
    raw = subprocess.run(
        ["system_profiler", "-json", "SPFontsDataType"],
        capture_output=True, text=True, timeout=120,
    ).stdout
    entries = json.loads(raw).get("SPFontsDataType", [])
except Exception:
    sys.exit(0)

fallback = ""
for entry in entries:
    for face in entry.get("typefaces", []):
        if face.get("family") != family:
            continue
        name = face.get("_name") or ""
        if face.get("style") == "Regular":
            print(name)
            sys.exit(0)
        fallback = fallback or name

print(fallback)
PYTHON
}

# ==============================================================================
# Profile Generation
# ==============================================================================

generate_profile() {
    local theme_file="$1"
    local profile_name="$2"
    local output_file="$3"
    local font_ps_name="$4"
    local font_size="$5"

    /usr/bin/python3 - "$theme_file" "$profile_name" "$output_file" "$font_ps_name" "$font_size" <<'PYTHON'
import plistlib
import re
import sys

theme_file, profile_name, output_file, font_ps_name, font_size = sys.argv[1:6]

# Ghostty palette index -> Terminal.app profile key
ANSI_KEYS = [
    "ANSIBlackColor", "ANSIRedColor", "ANSIGreenColor", "ANSIYellowColor",
    "ANSIBlueColor", "ANSIMagentaColor", "ANSICyanColor", "ANSIWhiteColor",
    "ANSIBrightBlackColor", "ANSIBrightRedColor", "ANSIBrightGreenColor",
    "ANSIBrightYellowColor", "ANSIBrightBlueColor", "ANSIBrightMagentaColor",
    "ANSIBrightCyanColor", "ANSIBrightWhiteColor",
]

# Ghostty scalar setting -> Terminal.app profile key. Ghostty's
# selection-foreground and cursor-text have no Terminal.app equivalent
# (Terminal derives them), so they are intentionally dropped.
SCALAR_KEYS = {
    "background": "BackgroundColor",
    "foreground": "TextColor",
    "bold-color": "TextBoldColor",
    "cursor-color": "CursorColor",
    "selection-background": "SelectionColor",
}


def parse_theme(path):
    """Parse a Ghostty theme file into (scalars, palette)."""
    scalars = {}
    palette = {}
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            # Skip comment lines. Values are not comment-stripped because hex
            # colors legitimately contain '#'.
            if line.lstrip().startswith("#") or "=" not in line:
                continue

            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip()
            if key == "palette":
                match = re.match(r"^(\d+)\s*=\s*(#[0-9a-fA-F]{6})$", value)
                if match:
                    palette[int(match.group(1))] = match.group(2)
            elif key in SCALAR_KEYS and re.match(r"^#[0-9a-fA-F]{6}$", value):
                scalars[key] = value
    return scalars, palette


def archived_color(hex_color):
    """Build the NSKeyedArchiver plist Terminal.app expects for an NSColor.

    Terminal stores colors as an sRGB (NSColorSpace 2) NSColor whose NSRGB
    payload is a NUL-terminated ASCII string of space-separated floats.
    """
    hex_color = hex_color.lstrip("#")
    channels = [int(hex_color[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
    rgb = " ".join("{:.9f}".format(channel).rstrip("0").rstrip(".") or "0"
                   for channel in channels)
    return plistlib.dumps({
        "$version": 100000,
        "$archiver": "NSKeyedArchiver",
        "$top": {"root": plistlib.UID(1)},
        "$objects": [
            "$null",
            {
                "NSRGB": (rgb + "\x00").encode("ascii"),
                "NSColorSpace": 2,
                "$class": plistlib.UID(2),
            },
            {"$classname": "NSColor", "$classes": ["NSColor", "NSObject"]},
        ],
    }, fmt=plistlib.FMT_BINARY)


def archived_font(ps_name, size):
    """Build the NSKeyedArchiver plist Terminal.app expects for an NSFont."""
    return plistlib.dumps({
        "$version": 100000,
        "$archiver": "NSKeyedArchiver",
        "$top": {"root": plistlib.UID(1)},
        "$objects": [
            "$null",
            {
                "NSSize": float(size),
                "NSfFlags": 16,
                "NSName": plistlib.UID(2),
                "$class": plistlib.UID(3),
            },
            ps_name,
            {"$classname": "NSFont", "$classes": ["NSFont", "NSObject"]},
        ],
    }, fmt=plistlib.FMT_BINARY)


scalars, palette = parse_theme(theme_file)

missing = [str(i) for i in range(16) if i not in palette]
if missing:
    sys.stderr.write(
        "theme {} is missing palette entries: {}\n".format(theme_file, ", ".join(missing))
    )
    sys.exit(1)

for key in SCALAR_KEYS:
    if key not in scalars:
        sys.stderr.write("theme {} is missing '{}'\n".format(theme_file, key))
        sys.exit(1)

profile = {
    "name": profile_name,
    "type": "Window Settings",
    "ProfileCurrentVersion": 2.07,
    "Font": archived_font(font_ps_name, font_size),
    "FontAntialias": True,
    "columnCount": 120,
    "rowCount": 40,
}

for index, key in enumerate(ANSI_KEYS):
    profile[key] = archived_color(palette[index])

for ghostty_key, terminal_key in SCALAR_KEYS.items():
    profile[terminal_key] = archived_color(scalars[ghostty_key])

# DynamicANSIForegroundColors is deliberately omitted: it lets Terminal.app
# recolor text against the background, which would break exact parity with the
# Ghostty palette.

with open(output_file, "wb") as handle:
    plistlib.dump(profile, handle, fmt=plistlib.FMT_XML)
PYTHON
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    section "Generating Terminal.app Profiles"

    if ! command_exists /usr/bin/python3 && ! command_exists python3; then
        error "python3 is required to build the profile plists"
    fi

    [ -f "$GHOSTTY_CONFIG" ] || error "Ghostty config not found: $GHOSTTY_CONFIG"
    [ -d "$THEMES_DIR" ] || error "Ghostty themes directory not found: $THEMES_DIR"

    local font_family font_size font_ps_name
    font_family="$(ghostty_setting 'font-family')"
    font_size="$(ghostty_setting 'font-size')"
    [ -n "$font_family" ] || error "Could not read font-family from $GHOSTTY_CONFIG"
    [ -n "$font_size" ] || font_size="16"

    info "Font family from Ghostty config: $font_family"
    info "Font size from Ghostty config: $font_size"

    font_ps_name="$(resolve_postscript_name "$font_family")"
    if [ -z "$font_ps_name" ]; then
        warn "Font '$font_family' is not installed - falling back to $FALLBACK_FONT_PS_NAME"
        warn "Install it first (scripts/setup-terminal.sh) and re-run for full parity"
        font_ps_name="$FALLBACK_FONT_PS_NAME"
    else
        info "Resolved PostScript name: $font_ps_name"
    fi

    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$OUTPUT_DIR"
    fi

    local entry theme_name profile_name theme_file output_file
    for entry in "${PROFILE_MAP[@]}"; do
        theme_name="${entry%%:*}"
        profile_name="${entry#*:}"
        theme_file="$THEMES_DIR/$theme_name"
        output_file="$OUTPUT_DIR/$profile_name.terminal"

        if [ ! -f "$theme_file" ]; then
            error "Ghostty theme not found: $theme_file"
        fi

        if [ "$DRY_RUN" = true ]; then
            info "[dry-run] $theme_name -> $output_file"
            continue
        fi

        generate_profile "$theme_file" "$profile_name" "$output_file" \
            "$font_ps_name" "$font_size"
        success "$theme_name -> $output_file"
    done

    if [ "$DRY_RUN" = true ]; then
        info "Dry run complete - no files written"
        return 0
    fi

    echo ""
    info "Import the profiles with: terminal-profile-install (abbr: tp)"
}

main "$@"
