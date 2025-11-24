#!/usr/bin/env zsh
# BRENENTECH CLI Logo Display
# Circuit-board style logo with pulse animation

# Get the directory where this script is located
# Use ${(%):-%x} for sourced scripts, fallback to $0 for executed scripts
LOGO_DIR="${${(%):-%x}:A:h}"

# Source color definitions
source "${LOGO_DIR}/colors.sh"

# State file location - always in home directory, not the repo
STATE_FILE="$HOME/.config/brenentech/.logo_enabled"

# Function to check if logo should be displayed
_should_display_logo() {
    # Check if logo is enabled (state file exists)
    [[ ! -f "$STATE_FILE" ]] && return 1

    # Skip in SSH sessions
    [[ -n "$SSH_CONNECTION" ]] && return 1

    # Skip in tmux/screen
    [[ -n "$TMUX" ]] && return 1
    [[ "$TERM" == *"screen"* ]] && return 1

    return 0
}

# Circuit element indices for wave animation
# Path order: 0→1→2→3→4→5→6→7→8→9→10→11
# 0: top-left node (○)      6: middle-left node (●)
# 1: top edge (──)           7: horizontal edge (────)
# 2: top-right node (●)      8: middle-right node (○)
# 3: left vertical (│)       9: lower vertical (│)
# 4: corner edge (└─)        10: bottom edge (└────)
# 5: branch node (○)         11: arrow (»)

# Render tagline with per-character brightness based on wave position
# Args: wave_pos (position of brightness peak in the text)
_render_tagline_with_wave() {
    local wave_pos=$1
    local tagline="I wonder what the machines think"
    local tagline_len=${#tagline}
    local result=""

    # Build string with per-character brightness
    for (( i=0; i<$tagline_len; i++ )); do
        local char="${tagline:$i:1}"
        local distance=$((i - wave_pos))

        # Wave profile: trailing glow effect
        # distance < 0: character is behind wave (already revealed)
        # distance = 0: character at wave peak
        # distance > 0: character ahead of wave (not yet revealed)

        if [[ $distance -gt 0 ]]; then
            # Not yet revealed - invisible
            result+=" "
        elif [[ $distance -eq 0 ]]; then
            # Peak brightness
            result+="${BRIGHT_4}${char}${RESET}"
        elif [[ $distance -eq -1 ]]; then
            # Close trail
            result+="${BRIGHT_3}${char}${RESET}"
        elif [[ $distance -eq -2 ]]; then
            # Medium trail
            result+="${BRIGHT_2}${char}${RESET}"
        elif [[ $distance -eq -3 ]]; then
            # Fading trail
            result+="${BRIGHT_1}${char}${RESET}"
        else
            # Already revealed (distance < -3) - normal brightness, no glow
            result+="${char}"
        fi
    done

    echo "${result}"
}

# Render logo with specific brightness levels for each element
# Args: 12 brightness levels (0-4) for circuit, then tagline_mode, then optional wave_pos
_render_logo_with_brightness() {
    local -a circuit_brightness=("${@:1:12}")  # First 12 args are circuit brightness
    local tagline_mode="${13:-show}"  # 13th arg: "hide", "show", or "wave"
    local tagline_wave_pos="${14:-0}"  # 14th arg: wave position if mode is "wave"

    # Get brightness color codes (1-indexed array - natural for zsh)
    local colors=("$BRIGHT_0" "$BRIGHT_1" "$BRIGHT_2" "$BRIGHT_3" "$BRIGHT_4")
    # colors[1]=BRIGHT_0, colors[2]=BRIGHT_1, ..., colors[5]=BRIGHT_4

    # Element colors based on brightness levels (add 1 to map 0-4 brightness to 1-5 indices)
    local c0="${colors[$((circuit_brightness[1] + 1))]}"   # top-left node
    local c1="${colors[$((circuit_brightness[2] + 1))]}"   # top edge
    local c2="${colors[$((circuit_brightness[3] + 1))]}"   # top-right node
    local c3="${colors[$((circuit_brightness[4] + 1))]}"   # left vertical
    local c4="${colors[$((circuit_brightness[5] + 1))]}"   # corner edge
    local c5="${colors[$((circuit_brightness[6] + 1))]}"   # branch node
    local c6="${colors[$((circuit_brightness[7] + 1))]}"   # middle-left node
    local c7="${colors[$((circuit_brightness[8] + 1))]}"   # horizontal edge
    local c8="${colors[$((circuit_brightness[9] + 1))]}"   # middle-right node
    local c9="${colors[$((circuit_brightness[10] + 1))]}"  # lower vertical
    local c10="${colors[$((circuit_brightness[11] + 1))]}" # bottom edge
    local c11="${colors[$((circuit_brightness[12] + 1))]}" # arrow

    # Render tagline based on mode
    local tagline_output=""
    if [[ "$tagline_mode" == "hide" ]]; then
        tagline_output=""  # Completely hidden
    elif [[ "$tagline_mode" == "wave" ]]; then
        tagline_output="${ITALIC}${BLUE}$(_render_tagline_with_wave $tagline_wave_pos)${RESET}"
    else
        # Default: show normally
        tagline_output="${ITALIC}${BLUE}I wonder what the machines think${RESET}"
    fi

    # Build entire frame as single string
    local frame=""
    frame+="\n"
    frame+="${c0}○${RESET}${c1}──${RESET}${c2}●${RESET} ${BOLD}${ORANGE}B${RESET} ${BOLD}${FG_LIGHT}R E N E N${RESET}\n"
    frame+="   ${c3}│${RESET}  ${c4}└─${RESET}${c5}○${RESET}\n"
    frame+="   ${c6}●${RESET}${c7}────${RESET}${c8}○${RESET}   ${FG_LIGHT}T E C H${RESET}\n"
    frame+="   ${c9}│${RESET}\n"
    frame+="   ${c10}└────${RESET}${c11}»${RESET} ${tagline_output}\n"
    frame+="\n"

    # Return frame string (caller will output)
    printf "%s" "${frame}"
}

# Display logo frame with normal brightness (final resting state)
_display_logo_normal() {
    local frame=""
    frame+="\n"
    frame+="${BASE_GRAY}○──●${RESET} ${ORANGE}B${RESET} ${FG_LIGHT}R E N E N${RESET}\n"
    frame+="${BASE_GRAY}   │  └─○${RESET}\n"
    frame+="${BASE_GRAY}   ●────○${RESET}   ${FG_LIGHT}T E C H${RESET}\n"
    frame+="${BASE_GRAY}   │${RESET}\n"
    frame+="${BASE_GRAY}   └────»${RESET} ${ITALIC}${BLUE}I wonder what the machines think${RESET}\n"
    frame+="\n"
    printf "%s" "${frame}"
}

# Calculate brightness level for element at given position with wave at wave_pos
# Returns brightness level 0-4 based on distance from wave peak
_get_element_brightness() {
    local elem_pos=$1
    local wave_pos=$2
    local distance=$((elem_pos - wave_pos))

    # Wave profile: creates trailing glow effect
    # Peak (4) at wave position, then fade trail: 3, 2, 1, 0
    if [[ $distance -eq 0 ]]; then
        echo 4  # Peak brightness
    elif [[ $distance -eq -1 ]]; then
        echo 3  # Close trail
    elif [[ $distance -eq -2 ]]; then
        echo 2  # Medium trail
    elif [[ $distance -eq -3 ]]; then
        echo 1  # Fading trail
    else
        echo 0  # Dim/inactive
    fi
}

# Final pulse - all nodes and edges bright white
_display_logo_pulse() {
    local frame=""
    frame+="\n"
    frame+="${BOLD}${FG_LIGHT}○──●${RESET} ${BOLD}${ORANGE}B${RESET} ${BOLD}${FG_LIGHT}R E N E N${RESET}\n"
    frame+="${BASE_GRAY}   ${RESET}${BOLD}${FG_LIGHT}│${RESET}${BASE_GRAY}  ${RESET}${BOLD}${FG_LIGHT}└─○${RESET}\n"
    frame+="${BASE_GRAY}   ${RESET}${BOLD}${FG_LIGHT}●────○${RESET}   ${BOLD}${FG_LIGHT}T E C H${RESET}\n"
    frame+="${BASE_GRAY}   ${RESET}${BOLD}${FG_LIGHT}│${RESET}\n"
    frame+="${BASE_GRAY}   ${RESET}${BOLD}${FG_LIGHT}└────»${RESET} ${ITALIC}${BLUE}I wonder what the machines think${RESET}\n"
    frame+="\n"
    printf "%s" "${frame}"
}

# Clear screen area for animation (move cursor up 7 lines)
_clear_logo_area() {
    # Move cursor up 7 lines and clear them
    for i in {1..7}; do
        echo -ne "\033[1A\033[2K"
    done
}

# Animate logo with smooth wave flowing through circuit, then text reveal
_animate_logo() {
    # Hide cursor to prevent flickering during animation
    echo -ne "\033[?25l"

    # Ensure cursor is restored on exit (even if interrupted)
    trap 'echo -ne "\033[?25h"' EXIT INT TERM

    local num_elements=12  # Total circuit elements (0-11)
    local wave_start=-3    # Start wave off-screen for smooth entry
    local wave_end=$((num_elements + 4))  # End wave off-screen for smooth exit
    local circuit_frame_delay=0.08  # 80ms per frame for circuit
    local text_frame_delay=0.04     # 40ms per frame for text (faster to match pace)

    # === PHASE 1: Circuit flow animation (tagline hidden) ===
    # Note: Wave starts at -3, so first frames will be dim (normal color)
    for wave_pos in {$wave_start..$wave_end}; do
        # Calculate brightness for each element based on wave position
        local brightness=()
        for elem_idx in {0..$((num_elements - 1))}; do
            brightness+=($(_get_element_brightness $elem_idx $wave_pos))
        done

        # Pre-build frame before clearing (minimizes flicker)
        local frame=$(_render_logo_with_brightness "${brightness[@]}" "hide")

        # Clear previous frame (except first iteration)
        if [[ $wave_pos -gt $wave_start ]]; then
            _clear_logo_area
        fi
        echo -ne "$frame"

        sleep $circuit_frame_delay
    done

    # Brief pause: circuit complete, arrow bright, tagline still hidden
    sleep 0.03

    # === PHASE 2: Tagline character-by-character reveal ===
    local tagline_len=35  # Length of "I wonder what the machines think"
    local text_wave_start=-3
    local text_wave_end=$((tagline_len + 4))

    # Keep circuit at normal state (brightness 0) while text reveals
    local final_brightness=(0 0 0 0 0 0 0 0 0 0 0 0)

    for text_wave_pos in {$text_wave_start..$text_wave_end}; do
        # Pre-build frame before clearing (minimizes flicker)
        local frame=$(_render_logo_with_brightness "${final_brightness[@]}" "wave" "$text_wave_pos")

        # Clear and immediately output
        _clear_logo_area
        echo -ne "$frame"

        sleep $text_frame_delay
    done

    # Ensure final frame uses true normal state colors (BASE_GRAY for circuit)
    local frame=$(_display_logo_normal)
    _clear_logo_area
    echo -ne "$frame"

    # Restore cursor visibility
    echo -ne "\033[?25h"
    trap - EXIT INT TERM
}

# Main execution logic
if _should_display_logo; then
    _animate_logo
fi

# Clean up functions to avoid polluting shell environment
unfunction _should_display_logo _display_logo_normal _render_tagline_with_wave _render_logo_with_brightness _get_element_brightness _display_logo_pulse _clear_logo_area _animate_logo 2>/dev/null
