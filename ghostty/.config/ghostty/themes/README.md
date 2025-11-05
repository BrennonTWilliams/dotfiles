# Ghostty Themes - Cyberpunk Collection

This directory contains custom themes for Ghostty terminal, designed to provide a modern cyberpunk aesthetic while maintaining excellent readability and functionality.

## Available Themes

### cyberpunk-dark
A dark theme inspired by high-contrast cyberpunk aesthetics, based on visual analysis of modern terminal setups.

**Key Features:**
- Deep charcoal background (`#1e1e1e`) for maximum contrast
- Vibrant orange accent colors (`#ff9e64`) for keywords and functions
- Enhanced syntax highlighting with neon-inspired colors
- Subtle transparency (0.95 opacity) with blur effects
- Optimized for low-light development environments

**Color Scheme:**
- Background: `#1e1e1e` (deep charcoal)
- Foreground: `#ffffff` (bright white)
- Cursor: `#ff9e64` (vibrant orange)
- Selection: `#3e3e3e` background with white text

### cyberpunk-light
A light theme companion that maintains the cyberpunk aesthetic while providing optimal visibility in bright environments.

**Key Features:**
- Clean white background (`#ffffff`) for daytime use
- Dark text (`#1e1e1e`) for excellent contrast
- Consistent orange accent (`#ff9e64`) for brand continuity
- Muted color palette for reduced eye strain
- Professional appearance suitable for office environments

**Color Scheme:**
- Background: `#ffffff` (pure white)
- Foreground: `#1e1e1e` (dark charcoal)
- Cursor: `#ff9e64` (vibrant orange)
- Selection: `#f0f0f0` background with dark text

## Installation

These themes are automatically integrated with the main Ghostty configuration. To use them:

1. Ensure the themes are located in `~/.config/ghostty/themes/`
2. The main configuration file should reference them:
   ```
   theme = light:cyberpunk-light,dark:cyberpunk-dark
   ```

## Configuration

The themes include the following enhancements:

### Visual Effects
- **Dark Theme**: 0.95 background opacity with blur for depth
- **Light Theme**: Solid background for maximum clarity
- Consistent tab styling with orange accent for active tabs
- Enhanced window borders with color-coded active states

### Syntax Highlighting
Both themes feature optimized color palettes for common programming languages:
- **Red tones**: Error messages, warnings
- **Green tones**: Success messages, string literals
- **Orange/Yellow tones**: Keywords, important variables
- **Blue tones**: Functions, types, identifiers
- **Magenta tones**: Special variables, operators
- **Cyan tones**: Constants, numbers

### Search & Selection
- High-contrast search highlighting
- Clear selection visibility
- Consistent color application across both themes

## Customization

To modify the themes:

1. Edit the respective theme file (`cyberpunk-dark` or `cyberpunk-light`)
2. Modify color values as needed
3. Restart Ghostty to see changes take effect

### Color Format
Colors use standard hex format (`#RRGGBB`). Ghostty supports:
- 16-color palette definitions
- Direct color assignments for UI elements
- Opacity and blur effects for visual enhancement

## Compatibility

- **Ghostty Version**: Compatible with modern Ghostty releases
- **System**: Designed for macOS but should work on other platforms
- **Display**: Optimized for both Retina and standard displays
- **Color Profile**: Works well with sRGB and wider color gamuts

## Theme Switching

The themes are configured to automatically switch based on system appearance:
- Light mode → `cyberpunk-light`
- Dark mode → `cyberpunk-dark`

Manual switching can be done through Ghostty's theme selection interface or by modifying the configuration.

## Troubleshooting

If themes don't apply correctly:

1. Verify Ghostty is restarted after configuration changes
2. Check theme file permissions (should be readable)
3. Ensure theme syntax is valid (no typos in color codes)
4. Test with a simple configuration to isolate issues

## Inspiration

These themes are inspired by modern terminal aesthetics, particularly:
- High-contrast cyberpunk visuals
- Developer-friendly syntax highlighting
- Minimalist design with functional color coding
- Visual analysis of contemporary terminal setups

## Support

For issues or suggestions:
1. Check Ghostty documentation for theme compatibility
2. Verify color values are in correct format
3. Test with different font configurations for optimal results
4. Consider display calibration for accurate color reproduction

---

**Created**: 2025-11-05
**Inspiration**: Sway Ghostty screenshot analysis
**Aesthetic**: Cyberpunk with high contrast readability
