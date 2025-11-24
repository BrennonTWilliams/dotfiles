#!/usr/bin/env bash

# ==============================================================================
# Nerd Font Complete Glyph Reference Generator
# ==============================================================================
# Generates a complete reference of all ~9,000 Nerd Font glyphs
# Output: starship/nerd-fonts-complete-reference.txt
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/../starship/nerd-fonts-complete-reference.txt"
FONT_NAME="IosevkaTerm Nerd Font"
FONT_VERSION="v3.3.0"
GENERATION_DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Helper function to convert hex string to decimal
hex_to_dec() {
    echo $((16#$1))
}

# Helper function to render glyph from hex codepoint
render_glyph() {
    local hex=$1
    local dec=$(hex_to_dec "$hex")
    printf "\\U$(printf '%08x' $dec)"
}

# Helper function to print section header
print_section() {
    local title="$1"
    local count="$2"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo " $title ($count glyphs)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    printf "%-12s │ %-8s │ %-30s\n" "Codepoint" "Glyph" "Icon Set"
    printf "%-12s─┼─%-8s─┼─%-30s\n" "────────────" "────────" "──────────────────────────────"
}

# Helper function to print glyph row
print_glyph() {
    local hex=$1
    local set=$2
    local glyph=$(render_glyph "$hex")
    printf "U+%-10s │ %-8s │ %-30s\n" "$hex" "$glyph" "$set"
}

# Helper function to iterate through range
print_range() {
    local start_hex=$1
    local end_hex=$2
    local set_name=$3

    local start_dec=$(hex_to_dec "$start_hex")
    local end_dec=$(hex_to_dec "$end_hex")

    for ((i=start_dec; i<=end_dec; i++)); do
        local hex=$(printf '%04X' $i)
        print_glyph "$hex" "$set_name"
    done
}

# Helper function to iterate through 5-digit range (for Material Design)
print_range_5digit() {
    local start_hex=$1
    local end_hex=$2
    local set_name=$3

    local start_dec=$(hex_to_dec "$start_hex")
    local end_dec=$(hex_to_dec "$end_hex")

    for ((i=start_dec; i<=end_dec; i++)); do
        local hex=$(printf '%05X' $i)
        print_glyph "$hex" "$set_name"
    done
}

# Start generating the reference file
echo "Generating Nerd Font Complete Glyph Reference..."
echo "Output: $OUTPUT_FILE"

{
    # Header
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo "                    NERD FONTS COMPLETE GLYPH REFERENCE                        "
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "Font:              $FONT_NAME"
    echo "Nerd Fonts:        $FONT_VERSION"
    echo "Generated:         $GENERATION_DATE"
    echo "Total Glyphs:      ~9,000+"
    echo ""
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "TABLE OF CONTENTS"
    echo "─────────────────"
    echo ""
    echo "  1. Pomicons                           (E000-E00A)      ~11 glyphs"
    echo "  2. Powerline Symbols                  (E0A0-E0D7)      ~56 glyphs"
    echo "  3. Font Awesome Extension             (E200-E2A9)     ~170 glyphs"
    echo "  4. Weather Icons                      (E300-E3E3)     ~215 glyphs"
    echo "  5. Seti-UI + Custom                   (E5FA-E6B7)     ~195 glyphs"
    echo "  6. Devicons                           (E700-E8EF)     ~496 glyphs"
    echo "  7. Codicons                           (EA60-EC1E)     ~447 glyphs"
    echo "  8. Font Awesome                       (ED00-F2FF)   ~1,536 glyphs"
    echo "  9. Font Logos                         (F300-F381)     ~130 glyphs"
    echo " 10. Octicons                           (F400-F533)     ~308 glyphs"
    echo " 11. Material Design Icons              (F0001-F1AF0) ~6,896 glyphs"
    echo " 12. IEC Power Symbols                  (23FB-23FE)       ~4 glyphs"
    echo " 13. Heavy Angle Brackets               (276C-2771)       ~6 glyphs"
    echo " 14. Box Drawing                        (2500-259F)     ~160 glyphs"
    echo ""

    # 1. Pomicons (E000-E00A)
    print_section "1. POMICONS" "11"
    print_range "E000" "E00A" "Pomicons"

    # 2. Powerline Symbols (E0A0-E0D7)
    print_section "2. POWERLINE SYMBOLS" "56"
    print_range "E0A0" "E0A2" "Powerline"
    print_range "E0A3" "E0A3" "Powerline Extra"
    print_range "E0B0" "E0B3" "Powerline"
    print_range "E0B4" "E0C8" "Powerline Extra"
    print_range "E0CA" "E0CA" "Powerline Extra"
    print_range "E0CC" "E0D7" "Powerline Extra"

    # 3. Font Awesome Extension (E200-E2A9)
    print_section "3. FONT AWESOME EXTENSION" "170"
    print_range "E200" "E2A9" "Font Awesome Extension"

    # 4. Weather Icons (E300-E3E3)
    print_section "4. WEATHER ICONS" "215"
    print_range "E300" "E3E3" "Weather Icons"

    # 5. Seti-UI + Custom (E5FA-E6B7)
    print_section "5. SETI-UI + CUSTOM" "195"
    print_range "E5FA" "E6B7" "Seti-UI"

    # 6. Devicons (E700-E8EF)
    print_section "6. DEVICONS" "496"
    print_range "E700" "E8EF" "Devicons"

    # 7. Codicons (EA60-EC1E)
    print_section "7. CODICONS (VS CODE)" "447"
    print_range "EA60" "EC1E" "Codicons"

    # 8. Font Awesome (ED00-F2FF with gaps)
    print_section "8. FONT AWESOME" "1536"
    print_range "ED00" "EDFF" "Font Awesome"
    print_range "EE00" "EE0B" "Progress Indicators"
    print_range "EE0C" "F2FF" "Font Awesome"

    # 9. Font Logos (F300-F381)
    print_section "9. FONT LOGOS (LINUX)" "130"
    print_range "F300" "F381" "Font Logos"

    # 10. Octicons (F400-F533)
    print_section "10. OCTICONS (GITHUB)" "308"
    print_range "F400" "F533" "Octicons"
    # Special Octicons
    print_glyph "2665" "Octicons (special)"
    print_glyph "26A1" "Octicons (special)"

    # 11. Material Design Icons (F0001-F1AF0) - This is the BIG one
    print_section "11. MATERIAL DESIGN ICONS" "6896"
    echo "NOTE: Material Design Icons range is very large. Generating..."
    print_range_5digit "F0001" "F1AF0" "Material Design"

    # 12. IEC Power Symbols (23FB-23FE)
    print_section "12. IEC POWER SYMBOLS" "4"
    print_range "23FB" "23FE" "IEC Power"
    print_glyph "2B58" "IEC Power (special)"

    # 13. Heavy Angle Brackets (276C-2771)
    print_section "13. HEAVY ANGLE BRACKETS" "6"
    print_range "276C" "2771" "Heavy Brackets"

    # 14. Box Drawing (2500-259F)
    print_section "14. BOX DRAWING CHARACTERS" "160"
    print_range "2500" "259F" "Box Drawing"

    # Footer
    echo ""
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo "                              END OF REFERENCE                                  "
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "SOURCES:"
    echo "  • Nerd Fonts Official: https://www.nerdfonts.com"
    echo "  • Cheat Sheet: https://www.nerdfonts.com/cheat-sheet"
    echo "  • GitHub Wiki: https://github.com/ryanoasis/nerd-fonts/wiki"
    echo ""
    echo "NOTES:"
    echo "  • Some glyphs may not render correctly depending on your terminal"
    echo "  • Ensure you have $FONT_NAME installed"
    echo "  • Material Design Icons (F0001-F1AF0) is the largest set"
    echo "  • Deprecated ranges (F500-FD46) are NOT included (use new F0001+ range)"
    echo ""
    echo "Generated by: scripts/generate-nerd-font-reference.sh"
    echo "════════════════════════════════════════════════════════════════════════════════"

} > "$OUTPUT_FILE"

echo ""
echo "✓ Reference file generated successfully!"
echo "  Location: $OUTPUT_FILE"
echo "  File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""
echo "To view:"
echo "  cat $OUTPUT_FILE"
echo "  less $OUTPUT_FILE"
echo ""
