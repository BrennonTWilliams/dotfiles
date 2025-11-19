# Third-Party Licenses and Attributions

This project includes or references code from the following third-party sources:

---

## Code Included in Repository

### Gruvbox ZSH Theme
- **Based on:** agnoster's ZSH Theme
- **Source:** https://gist.github.com/agnoster/3712874
- **Modified by:** Brennon Williams
- **Changes:** Adapted for Gruvbox color scheme, added Nerd Font support
- **License:** MIT (assumed from ZSH theme ecosystem)

### Starship Prompt Configuration
- **Based on:** Gruvbox-Rainbow Preset
- **Source:** https://starship.rs/presets/gruvbox-rainbow
- **License:** ISC (Starship project)
- **Changes:** Custom module configuration, added verbose/compact modes

---

## External Dependencies Installed via Scripts

### Shell and Terminal

#### Oh My Zsh
- **Project:** https://github.com/ohmyzsh/ohmyzsh
- **License:** MIT
- **Usage:** Installed via `scripts/setup-ohmyzsh.sh`

#### Zsh Autosuggestions
- **Project:** https://github.com/zsh-users/zsh-autosuggestions
- **License:** MIT
- **Usage:** Installed as Oh My Zsh plugin

#### Zsh Syntax Highlighting
- **Project:** https://github.com/zsh-users/zsh-syntax-highlighting
- **License:** BSD-3-Clause
- **Usage:** Installed as Oh My Zsh plugin

### Tmux Plugins

#### Tmux Plugin Manager (TPM)
- **Project:** https://github.com/tmux-plugins/tpm
- **License:** MIT
- **Usage:** Plugin manager for tmux

#### tmux-sensible
- **Project:** https://github.com/tmux-plugins/tmux-sensible
- **License:** MIT
- **Usage:** Basic tmux settings everyone can agree on

#### tmux-yank
- **Project:** https://github.com/tmux-plugins/tmux-yank
- **License:** MIT
- **Usage:** Copy to system clipboard

#### tmux-resurrect
- **Project:** https://github.com/tmux-plugins/tmux-resurrect
- **License:** MIT
- **Usage:** Persist tmux environment across system restarts

#### tmux-continuum
- **Project:** https://github.com/tmux-plugins/tmux-continuum
- **License:** MIT
- **Usage:** Continuous saving of tmux environment

#### tmux-cpu
- **Project:** https://github.com/tmux-plugins/tmux-cpu
- **License:** MIT
- **Usage:** Display CPU and memory usage in status bar

#### tmux-battery
- **Project:** https://github.com/tmux-plugins/tmux-battery
- **License:** MIT
- **Usage:** Display battery status in status bar

### Prompt and Tools

#### Starship
- **Project:** https://starship.rs/
- **License:** ISC
- **Usage:** Cross-shell prompt

#### Uniclip
- **Project:** https://github.com/quackduck/uniclip
- **License:** MIT
- **Usage:** Universal clipboard sharing (macOS)

---

## Gruvbox Color Scheme

The Gruvbox color scheme used throughout is originally created by:
- **Author:** Pavel Pertsev (morhetz)
- **Project:** https://github.com/morhetz/gruvbox
- **License:** MIT

This repository uses Gruvbox Dark Hard variant across:
- Terminal emulators (Ghostty, Foot)
- Tmux status bar
- VS Code editor
- Starship prompt
- ZSH theme

---

## Nerd Fonts

This repository recommends and is optimized for Nerd Fonts:
- **Project:** https://www.nerdfonts.com/
- **License:** Various (per-font licenses, typically SIL OFL)
- **Usage:** Icon support in prompt and terminal

Recommended fonts:
- FiraCode Nerd Font
- Hack Nerd Font
- JetBrainsMono Nerd Font

---

## License Compatibility

All third-party dependencies use permissive licenses compatible with MIT:
- MIT License
- BSD-2-Clause and BSD-3-Clause
- ISC License

No GPL or AGPL dependencies are included.

---

## Acknowledgments

This dotfiles repository was inspired by:
- [GNU Stow documentation](https://www.gnu.org/software/stow/)
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles)
- [holman/dotfiles](https://github.com/holman/dotfiles)

---

## Updating This File

When adding new third-party dependencies:
1. Add entry with project name, URL, and license
2. Ensure license compatibility (permissive licenses only)
3. Update main README.md credits section
4. Verify attribution is present in code comments where applicable

---

**Last Updated:** 2025-11-16
**Dotfiles Version:** 1.0.0
