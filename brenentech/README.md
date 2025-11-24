# BRENENTECH CLI Configuration

This directory contains BRENENTECH-branded CLI elements and configurations.

## Structure

```
brenentech/
├── .config/brenentech/     # Runtime configuration files
│   ├── logo.sh             # Animated logo display script
│   └── colors.sh           # Gruvbox color palette definitions
└── assets/                 # Logo design files
    ├── brenentech-cli-logo.txt        # Simple circuit-board style logo
    └── brenentech-logo-unicode.txt    # Large ASCII art version
```

## Installation

The `.config/brenentech/` directory should be symlinked to `~/.config/brenentech/`:

```bash
ln -sf "$(pwd)/brenentech/.config/brenentech" ~/.config/brenentech
```

## Usage

The logo is automatically displayed on shell startup via `.zprofile` if enabled.

### Commands

- `logo-on` - Enable logo display on startup
- `logo-off` - Disable logo display on startup
- `logo-show` - Display logo immediately (bypasses state check)

### Logo Design

The circuit-board style logo represents a technical, AI-focused brand:

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
- Tagline reflecting AI/technology focus
