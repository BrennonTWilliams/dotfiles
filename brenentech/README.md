# Custom CLI Branding

This directory contains customizable CLI branding elements. By default, the logo display is **disabled** - users can enable it if desired.

## Structure

```
brenentech/
└── .config/brenentech/     # Runtime configuration files
    ├── logo.sh             # Animated logo display script
    └── colors.sh           # Gruvbox color palette definitions
```

## Installation

The `.config/brenentech/` directory is symlinked automatically during dotfiles installation:

```bash
stow brenentech  # Creates ~/.config/brenentech/
```

## Enabling Logo Display

The logo is **disabled by default**. To enable it:

### Option 1: Environment Variable (Recommended)

Add to your `~/.zshrc.local`:

```bash
export DOTFILES_LOGO_ENABLED=true
```

### Option 2: State File

Create the state file:

```bash
touch ~/.config/brenentech/.logo_enabled
```

## Usage

### Commands

- `logo-toggle` - Toggle logo display on/off for future sessions
- `logo-show` - Display logo immediately (one-time, doesn't change settings)

### Skip Conditions

The logo automatically skips display in:
- SSH sessions
- tmux sessions
- screen sessions

## Customization

This branding is provided as an example. Feel free to:

1. **Replace the logo** - Edit `logo.sh` with your own design
2. **Change colors** - Modify `colors.sh` to match your theme
3. **Remove entirely** - Delete the `brenentech/` directory if not needed

### Logo Design Example

The included circuit-board style logo:

```
○──● B R E N E N
│  └─○
●────○   T E C H
     │
     └── [ I wonder what the machines think ]
```

Features:
- Circuit node symbols (○, ●) with pulse animation
- Gruvbox color palette matching Starship theme
- Customizable tagline
