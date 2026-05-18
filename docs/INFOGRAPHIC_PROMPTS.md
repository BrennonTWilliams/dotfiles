# Infographic Prompts

Image-generation prompts for visual documentation of the dotfiles setup. Each prompt describes content and layout only.

---

## README / Setup Infographics

### 1. Architecture Overview
A diagram showing the dotfiles repo structure as a hub-and-spoke layout. The hub is the `~/.dotfiles` git repo. Spokes radiate outward to labeled destination targets in `$HOME`: `.zshrc`, `.tmux.conf`, `.config/ghostty`, `.config/nvim`, `.gitconfig`, `.config/starship.toml`. Each spoke is labeled with the Stow package name that produces it (`zsh/`, `tmux/`, `ghostty/`, `nvim/`, `git/`, `starship/`). A legend clarifies that arrows represent symlinks created by GNU Stow.

### 2. Cross-Platform Compatibility Map
A split comparison layout. Left side is labeled "macOS" and lists: Ghostty terminal, Homebrew packages, pbcopy clipboard, macOS notifications, `.zprofile` login shell. Right side is labeled "Linux" and lists: Foot terminal, apt/system packages, wl-copy clipboard, notify-send, `.zprofile` login shell. A center column labeled "Shared" lists: tmux, Zsh, Starship, Neovim, Git + delta, `Ctrl+A` prefix, all keybindings. Arrows connect shared items to both platforms.

### 3. Installer Flow
A vertical flowchart of the install process. Steps in order: (1) Clone repo to `~/.dotfiles`, (2) Run `./install.sh` with mode flag (`--all`, `--terminal`, `--dotfiles`, etc.), (3) Decision diamond: "Conflict detected?" — Yes branch leads to "Interactive prompt or `--auto-resolve`", No branch continues, (4) GNU Stow creates symlinks, (5) `health-check.sh` validates install. A side note shows the `--preview` flag bypasses steps 3–5 and prints a dry-run diff instead.

### 4. Local Override Chain
A layered stack diagram showing the Zsh startup file load order. From bottom to top: `.zshenv` → `.zshenv.local`, `.zprofile` → `.zprofile.local`, `.zshrc` → `.zshrc.local`. Each `.local` layer is marked "gitignored / machine-specific." A separate identical stack shows the Git config chain: `git/.gitconfig` → `~/.gitconfig.local` with a callout noting the local file holds `[user]` identity. A third smaller stack shows `.tmux.conf` → `~/.tmux.local`.

### 5. Theme Stack
A vertical stack diagram labeled "Gruvbox across the full stack." Each row is a layer: Terminal emulator (Ghostty / Foot), Shell prompt (Starship), tmux status bar, Neovim, Git diff pager (delta). An arrow labeled "`toggle-theme`" points to the whole stack with the annotation "flips all layers light ↔ dark simultaneously."

### 6. Backup & Conflict Resolution Decision Tree
A decision tree for the conflict-resolution flow during install. Root node: "Target file already exists?" — No → "Create symlink." Yes → branch into three leaf nodes: (1) "User prompted" (default), (2) "`--auto-resolve=overwrite`" → "Timestamped backup created, then symlink", (3) "`--auto-resolve=keep-existing`" → "Skip, leave existing file." Backup files show metadata notation (timestamp + source path).

---

## CHEATSHEET Infographics

### 1. Prefix Map — Sessions, Windows, and Panes
A hierarchical diagram rooted at `Ctrl+A` (the tmux prefix). Three branches extend: **Sessions** (nodes: `T` = project sessionizer, `f` = fzf session switcher), **Windows** (nodes: `c` = new, `x` = close, `n/p` = next/prev, `1–9` = jump, `</>` = swap), **Panes** (nodes: `|` = split right, `-` = split down, `h/j/k/l` = navigate, `H/J/K/L` = resize, `z` = zoom, `S` = sync). Each node shows the key and a one-phrase description.

### 2. Copy Mode Flow
A sequential flow diagram for tmux copy mode. Steps left to right: (1) Enter: `prefix + [`, (2) Move cursor (vi keys), (3) Start selection: `v`, optionally toggle rectangle with `r`, (4) Decision: "Copy and exit?" → Yes: press `y` or `Enter`; No (stay in mode): press `Ctrl+Y`, (5) Result: selection sent to system clipboard (`pbcopy` / `wl-copy`). Below the main flow, three shortcut paths bypass steps 2–4: mouse drag (copies immediately), single-click (fine token — path segment or URL component), double-click (full space-delimited grouping — whole URL or path), triple-click (line; prompt prefix stripped from clipboard). At bottom: `prefix + y` copies from last prompt; `prefix + Y` copies entire scrollback.

### 3. Ghostty ↔ tmux Key Equivalence Table
A two-column visual table. Left column header: "Ghostty (Cmd+*)". Right column header: "tmux (prefix + *)". Rows, paired: `Cmd+T` / `c` (new window), `Cmd+W` / `x` (close), `Cmd+D` / `|` (split right), `Cmd+Shift+D` / `-` (split down), `Cmd+Shift+Z` / `z` (zoom), `Cmd+G` / `G` (lazygit), `Cmd+M` / `M` (btop), `Cmd+Shift+T` / `T` (sessionizer), `Cmd+Shift+R` / rename tab. A caption reads: "Every Ghostty shortcut sends the equivalent tmux key sequence — same muscle memory on both platforms."

### 4. Floating Overlay Popups
A spatial diagram showing a terminal window as the backdrop. Three labeled popup overlays are stacked or arranged over it, each with its trigger key: (1) Scratch terminal — `prefix + g`, (2) lazygit — `Cmd+G` / `prefix + G`, (3) btop system monitor — `Cmd+M` / `prefix + M`. A fourth smaller popup shows extrakto's fzf token picker triggered by `prefix + Tab` with example token types listed inside it: URL, file path, git hash, word.

### 5. Status Bar Anatomy
An annotated diagram of the tmux status bar strip. Left side label: `[session · host]` with callout arrows pointing to "session name" and "hostname." Right side label: `[CPU% RAM% | HH:MM AM/PM DD-Mon-YY]` with callout arrows to "CPU percent," "RAM percent," and "date/time." Center area shows the window tab format: `[icon] index:name` with a `Z` badge annotation for zoomed panes. Below the bar, a small legend maps the icon glyphs used for common window types.
