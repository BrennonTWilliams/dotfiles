#!/usr/bin/env zsh
# BRENENTECH Logo Color Definitions
# Monochrome palette - BASE_GRAY to FG_LIGHT progression

# Base monochrome palette
BASE_GRAY='\033[38;5;241m'   # Dim gray for inactive structure (665c54 → 241)
FG_LIGHT='\033[38;5;230m'    # Light foreground for active/text (fbf1c7 → 230)

# Accent colors
BLUE='\033[38;5;109m'        # Blue for tagline (83a598 → 109)
ORANGE='\033[38;5;208m'      # Gruvbox orange (fe8019 → 208)

# Text effects
BOLD='\033[1m'               # Bold text (for emphasis)
ITALIC='\033[3m'             # Italic text (for tagline)
RESET='\033[0m'              # Reset all attributes

# Animation brightness levels (for smooth wave transitions)
BRIGHT_0='\033[38;5;241m'    # Dim (base inactive state)
BRIGHT_1='\033[38;5;245m'    # Slightly brighter (trail fade)
BRIGHT_2='\033[38;5;250m'    # Medium bright (near trail)
BRIGHT_3='\033[38;5;254m'    # Bright (approaching peak)
BRIGHT_4="${BOLD}\033[38;5;230m"  # Peak brightness (active glow)
