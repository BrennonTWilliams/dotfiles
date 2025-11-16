#!/bin/bash
# Test Nerd Font Icons Rendering in Starship
# This script displays the new Nerd Font icons for Git status

set -euo pipefail

echo "🔍 Testing Nerd Font Icons for Starship Git Status"
echo "=================================================="
echo

echo "Material Design Icons (currently active):"
echo "  Conflicted:  "
echo "  Ahead:       "
echo "  Behind:      "
echo "  Diverged:    "
echo "  Up to date:  "
echo "  Untracked:   "
echo "  Stashed:     "
echo "  Modified:    "
echo "  Renamed:     "
echo "  Deleted:     "
echo

echo "Font Awesome Icons:"
echo "  Conflicted:  "
echo "  Ahead:       "
echo "  Behind:      "
echo "  Diverged:    "
echo "  Up to date:  "
echo "  Untracked:   "
echo "  Stashed:     "
echo "  Modified:    "
echo "  Renamed:     "
echo "  Deleted:     "
echo

echo "Minimalist Icons:"
echo "  Conflicted:  "
echo "  Ahead:       "
echo "  Behind:      "
echo "  Diverged:    "
echo "  Up to date:  "
echo "  Untracked:   "
echo "  Stashed:     "
echo "  Modified:    "
echo "  Renamed:     "
echo "  Deleted:     "
echo

echo "📝 Current Git Status should now show: [●✓?]"
echo "   • = modified files"
echo "   ✓ = up to date"
echo "   ? = untracked files"
echo

echo "✅ If you can see all the icons above, your Nerd Font setup is working!"
echo "🔧 To switch styles, edit ~/.config/starship.toml"
echo "   Comment out Material Design section"
echo "   Uncomment Font Awesome or Minimalist section"