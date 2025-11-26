# Obsidian Gruvbox Theme Configuration

Custom Obsidian CSS snippet that replicates the gruvbox aesthetic from Ghostty terminal and Starship prompt configurations.

## ▸ Overview

This gruvbox theme snippet brings your terminal's warm, earthy color palette into Obsidian, creating a cohesive development environment across all your tools.

### Color Sources

| Source | Usage |
|--------|-------|
| **Ghostty gruvbox-dark-custom** | Primary backgrounds, foregrounds, and base UI colors |
| **Starship gruvbox-rainbow** | Heading rainbow gradient (h1→h6) and accent colors |
| **Standard Gruvbox** | Fallback colors and light mode palette |

### Features

- ✓ Dark and light mode support
- ✓ Rainbow gradient headings matching Starship prompt
- ✓ Deep `#1d2021` background from Ghostty for reduced eye strain
- ✓ Inter font for body text and headings (optimal readability)
- ✓ IosevkaTerm Nerd Font for code blocks (matches terminal)
- ✓ Syntax highlighting optimized for markdown
- ✓ Enhanced UI elements (code blocks, tags, callouts)
- ✓ Custom task list checkboxes
- ✓ Nerd Font glyph indicators for headings
- ✓ Graph view color customization

## ▸ Installation

### 1. Create Symlink to Obsidian Vault

```bash
# From the dotfiles directory
ln -sf ~/AIProjects/ai-workspaces/dotfiles/obsidian/snippets/gruvbox-theme.css \
       ~/AIProjects/MC-vault/.obsidian/snippets/gruvbox-theme.css
```

This creates a symbolic link from your dotfiles to your Obsidian vault, so edits to the dotfiles version automatically apply to Obsidian.

### 2. Enable in Obsidian

1. Open Obsidian
2. Go to **Settings** (⚙️) → **Appearance** → **CSS snippets**
3. Click the **Reload snippets** button (↻)
4. Toggle **ON** the switch next to `gruvbox-theme`
5. Changes apply immediately!

### 3. Optional: Set Default Theme

For best results, use with Obsidian's **default theme**:
- Settings → Appearance → Themes → Use **Default**
- This lets the snippet have full control over colors

### 4. Install Fonts for Best Experience

This theme uses specific fonts for optimal readability:

#### Inter Font (Body Text & Headings)

**macOS:**
```bash
brew install --cask font-inter
```

**Manual Installation:**
1. Download from [https://rsms.me/inter/](https://rsms.me/inter/)
2. Install the font files
3. Restart Obsidian

#### IosevkaTerm Nerd Font (Code Blocks)

Already installed on your system. If needed, install via:
```bash
brew install --cask font-iosevka-term-nerd-font
```

#### Font Fallbacks

If Inter isn't installed, the theme gracefully falls back to:
- macOS: San Francisco (system font)
- Windows: Segoe UI
- Linux: Roboto

Code blocks fall back to: JetBrains Mono → Fira Code → Consolas → Monaco

## ▸ Font Configuration

### Typography Overview

| Element | Font | Weight | Purpose |
|---------|------|--------|---------|
| **Body text** | Inter | 400 (Regular) | Maximum readability for paragraphs |
| **Headings** | Inter | 600 (SemiBold) | Visual hierarchy and emphasis |
| **Code blocks** | IosevkaTerm Nerd Font | — | Monospace for code with Nerd Font glyphs |
| **Inline code** | IosevkaTerm Nerd Font | — | Matches code block aesthetic |
| **UI elements** | Inter | 400 (Regular) | Consistent interface font |
| **Frontmatter** | IosevkaTerm Nerd Font | — | Metadata as code |

### Why These Fonts?

**Inter:**
- Designed specifically for screen readability
- Clean, modern sans-serif
- Excellent at small sizes
- Wide range of weights (100-900)
- Open source and actively maintained

**IosevkaTerm Nerd Font:**
- Matches your terminal and Starship prompt
- Contains programming ligatures
- Includes Nerd Font glyphs for icons (     )
- Optimized for code readability
- Narrow width fits more code per line

### Font Scoping

The theme carefully scopes fonts to avoid conflicts:

```css
/* ✓ Inter applies to: */
- Note content (reading and edit modes)
- Headings (h1-h6)
- Sidebar navigation
- Settings and modals
- Status bar and titlebar

/* ✓ IosevkaTerm applies ONLY to: */
- Inline code: `code`
- Code blocks: ```code```
- Frontmatter/properties
- Nothing else!
```

This ensures your prose is readable in Inter while code remains in a proper monospace font.

## ▸ Color Palette Reference

### Dark Mode (Primary)

```css
Background:   #1d2021  (dark0-hard from Ghostty)
Foreground:   #ebdbb2  (light1 from Ghostty)
Selection:    #458588  (aqua from Ghostty)
Accent:       #d79921  (yellow)
```

### Heading Rainbow Gradient (Starship)

| Heading | Color | Hex |
|---------|-------|-----|
| h1 | Red | `#fb4934` |
| h2 | Orange | `#fe8019` |
| h3 | Yellow | `#fabd2f` |
| h4 | Green | `#b8bb26` |
| h5 | Aqua | `#8ec07c` |
| h6 | Purple | `#d3869b` |

### Syntax Highlighting

| Element | Color | Hex |
|---------|-------|-----|
| Keywords | Red | `#cc241d` |
| Strings | Green | `#98971a` |
| Functions | Yellow | `#d79921` |
| Comments | Gray | `#928374` |
| Properties | Aqua | `#458588` |
| Values | Purple | `#b16286` |

## ▸ Customization

### Adjust Colors

Edit the `:root` variables in `snippets/gruvbox-theme.css`:

```css
:root {
  --gb-dark0-hard: #1d2021;  /* Change main background */
  --gb-yellow:     #d79921;  /* Change accent color */
  /* ... etc */
}
```

### Change Heading Colors

Modify the heading color assignments in `.theme-dark`:

```css
.theme-dark {
  --h1-color: var(--gb-red-bright);
  --h2-color: var(--gb-orange-bright);
  /* ... customize as desired */
}
```

### Disable Heading Glyphs

Comment out or remove the heading indicator section:

```css
/* Remove or comment out these lines:
.cm-header-1::before { content: ' '; color: var(--h1-color); }
.cm-header-2::before { content: ' '; color: var(--h2-color); }
*/
```

### Toggle Light Mode

Switch between dark and light mode in Obsidian:
- Settings → Appearance → Base color scheme → Dark/Light

Both modes are fully styled with appropriate gruvbox colors.

## ▸ Recommended Settings

### Fonts

For best consistency with your terminal setup:

**Editor Font:**
- IosevkaTerm Nerd Font (recommended - matches Ghostty/Starship)
- JetBrains Mono
- Fira Code

**UI Font:**
- System default
- Inter
- SF Pro (macOS)

### Theme Settings

- **Base color scheme**: Dark (or Light for gruvbox light mode)
- **Base theme**: Default
- **Translucent window**: Off (for solid `#1d2021` background)

## ▸ Troubleshooting

### Snippet Not Appearing

1. Check symlink exists:
   ```bash
   ls -la ~/AIProjects/MC-vault/.obsidian/snippets/
   ```

2. Verify symlink target:
   ```bash
   readlink ~/AIProjects/MC-vault/.obsidian/snippets/gruvbox-theme.css
   ```

3. Click "Reload snippets" in Obsidian settings

### Colors Don't Match

- Ensure you're using a Nerd Font that supports the glyphs
- Check that no other theme or snippet is conflicting
- Try disabling other CSS snippets temporarily
- Use Obsidian's Developer Tools (Cmd+Option+I) to inspect elements

### Headings Don't Show Glyphs

- Install IosevkaTerm Nerd Font or another Nerd Font
- Set it as your editor font in Settings → Appearance → Font
- Reload Obsidian

## ▸ File Structure

```
dotfiles/
└── obsidian/
    ├── README.md                    ← This file
    └── snippets/
        └── gruvbox-theme.css        ← Main theme snippet

MC-vault/
└── .obsidian/
    └── snippets/
        └── gruvbox-theme.css        ← Symlink to dotfiles version
```

## ▸ Version Control

This theme is version controlled as part of your dotfiles repository. Any changes made to the file in `dotfiles/obsidian/snippets/` will automatically apply to your Obsidian vault via the symlink.

To commit changes:

```bash
cd ~/AIProjects/ai-workspaces/dotfiles
git add obsidian/
git commit -m "Update Obsidian gruvbox theme"
git push
```

## ▸ Credits

- **Color Scheme**: [morhetz/gruvbox](https://github.com/morhetz/gruvbox)
- **Inspired by**: Ghostty terminal, Starship prompt
- **Nerd Fonts**: [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts)

## ▸ Related Configurations

- `ghostty/.config/ghostty/themes/gruvbox-dark-custom` - Ghostty terminal theme
- `starship/.config/starship/gruvbox-rainbow.toml` - Starship prompt config
- `neovim/.config/nvim/lua/plugins/gruvbox.lua` - Neovim gruvbox plugin

---

**Note**: This is a CSS snippet, not a full theme. It overrides Obsidian's default theme colors while preserving the base functionality. For more extensive customization, consider converting it to a full Obsidian theme.
