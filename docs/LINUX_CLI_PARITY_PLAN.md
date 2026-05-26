# Linux CLI Parity Plan

## Goal

Bring the Linux CLI experience (Ghostty + tmux + zsh) to parity with the macOS setup so switching between machines carries zero mental overhead.

## Current State

| Layer | macOS | Linux | Parity |
|---|---|---|---|
| Shell (zsh + Starship) | Full | Full | 95% |
| Terminal emulator | Ghostty (native) | Foot (fallback) | 70% |
| tmux | Full config | Full config | 85% |
| Abbreviations | 125 lines | 11 lines | 15% |
| Shell functions | macos.zsh | none | 0% |
| System hotkeys | Cmd+backtick quick term | none | 0% |
| Theme auto-detect | AppleInterfaceStyle | hardcoded dark | 80% |
| Clipboard in tmux copy-mode | pbcopy/pbpaste | xclip-only (broken under Wayland) | 50% |
| Finder/file-manager integration | Automator workflows | none | 0% |
| Clipboard UX (shell) | pbcopy/pbpaste native | aliased via wl-copy/xclip | 75% |
| Modern tool abbreviations | bat, eza, fd, rg | none | 0% |
| Fonts | same Nerd Fonts | same Nerd Fonts | 100% |
| Neovim | full | full | 100% |
| Git | full | full | 100% |
| Starship prompt | built by build-configs.sh | built by build-configs.sh (but script not auto-run) | 85% |
| Shell completions (bat, eza, fd, rg) | auto-installed via Homebrew | not configured | 0% |
| tmux-sessionizer | on PATH (third-party) | missing; prefix+T silently fails | 0% |
| WezTerm config | stowed on macOS | stale package still in repo | N/A |

---

## Action Plan

### 1. Ghostty as Primary Linux Terminal

**Why.** Ghostty runs natively on Linux today with GTK backend. Using Foot on Linux and Ghostty on macOS means two different terminal emulators with different feature sets, different keybinding surfaces, and different shell integration behavior. Unifying on Ghostty eliminates that drift.

**What to change.**

- `ghostty/.config/ghostty/config` -- update the header (line 2-4) from "Ghostty Terminal Configuration - macOS" to "Ghostty Terminal Configuration - macOS and Linux", and add a `[Linux]` settings block at the bottom:
  ```ini
  # ============================================
  # Linux-Specific Settings
  # ============================================
  # macOS-only keys (macos-titlebar-style, macos-option-as-alt, macos-window-buttons,
  # macos-titlebar-proxy-icon) are silently ignored on Linux and stay in the shared config.

  # GTK window chrome (set to false for client-side decorations if preferred)
  gtk-titlebar = true
  gtk-tabs = true

  # Default to dark. Ghostty's `auto` (line 81 in the shared config) follows the
  # Freedesktop org.freedesktop.appearance color-scheme key, which GNOME 42+ and
  # KDE 6+ publish -- but coverage is uneven across distros and WMs. Force dark
  # for consistency; override in config.local if your DE reliably reports light/dark.
  window-theme = dark

  # 1080p/1440p default (Retina 16 is too large). Override in config.local.
  font-size = 13

  # gtk-adwaita is intentionally left unset -- Ghostty auto-detects GNOME and
  # enables Adwaita styling only when appropriate. Setting it to true
  # unconditionally would apply on Sway/KDE where it looks out of place.
  ```
  The macOS settings above this block are unchanged and harmless on Linux.

- **Super key conflict: Ghostty vs Sway/WMs.** The shared Ghostty config binds ~25 `super+<key>` combos (tab nav, pane nav, splits, tmux window select via `super+1-9`, etc.). On macOS, `super` is Cmd and does not conflict with OS-level window management. On Linux, `super` is `Mod4` -- the standard window manager mod key. In Sway/i3, `$mod+d` (wmenu), `$mod+1-9` (workspace switching), and `$mod+Left/Right/Up/Down` (focus) will intercept Ghostty keybindings before the terminal sees them.

  The specific conflicts with the default Sway config are:
  | Ghostty binding | Purpose | Sway conflict |
  |---|---|---|
  | `super+1` through `super+9` | tmux window select | `$mod+1-9` workspace switch |
  | `super+d` | tmux vertical split | `$mod+d` wmenu |
  | `super+left/right/up/down` | tmux pane nav (escape sequences) | `$mod+Left/Right/Up/Down` focus |
  | `super+shift+left/right/up/down` | tmux window move/reorder | `$mod+Shift+Left/Right/Up/Down` move window |

  Non-conflicting bindings (`super+alt+left`, `super+r`, `super+g`, `super+m`, `super+shift+w`, `super+shift+p`, etc.) work fine -- Sway doesn't bind those combos by default.

  **Resolution:** Add a `[Linux]` section explicitly unbinding the conflicting `super` keys and remapping them to `ctrl+shift` variants. The full `[Linux]` section must:

  1. **Unbind the conflicting `super` keys** so they can never fire on WMs that pass `super` through (openbox, bare X11, GNOME without extensions). Without this, `super+d` and `super+1-9` would trigger both Ghostty AND the WM action simultaneously on those desktops — the terminal splits panes while also launching wmenu, or switches tmux windows while also switching workspaces.
  2. **Rebind the same tmux actions to `ctrl+shift` variants** that are safe across all WMs.

  The non-conflicting `super` bindings (`super+alt+left`, `super+r`, `super+g`, `super+m`, `super+shift+w`, `super+shift+p`, etc.) are left active from the shared config — they have no WM conflicts.
  ```ini
  [Linux]
  # super is the WM mod key on Linux. The shared config's super+1-9, super+d,
  # and super+arrow bindings conflict with Sway/i3/GNOME/KDE defaults. We
  # explicitly unbind them so they can never fire on any WM -- on WMs that pass
  # super through, both the WM action and the Ghostty binding would trigger
  # simultaneously. Non-conflicting super bindings (super+alt+*, super+r,
  # super+g, super+m, etc.) stay active from the shared config.

  # --- Unbind conflicting super keys (safe no-op on Sway/i3/KDE) ---
  keybind = super+1=unbind
  keybind = super+2=unbind
  keybind = super+3=unbind
  keybind = super+4=unbind
  keybind = super+5=unbind
  keybind = super+6=unbind
  keybind = super+7=unbind
  keybind = super+8=unbind
  keybind = super+9=unbind
  keybind = super+d=unbind
  keybind = super+left=unbind
  keybind = super+right=unbind
  keybind = super+up=unbind
  keybind = super+down=unbind
  keybind = super+shift+left=unbind
  keybind = super+shift+right=unbind
  keybind = super+shift+up=unbind
  keybind = super+shift+down=unbind

  # --- Replacement bindings on ctrl+shift (safe across all WMs) ---
  keybind = ctrl+shift+1=text:\x011
  keybind = ctrl+shift+2=text:\x012
  keybind = ctrl+shift+3=text:\x013
  keybind = ctrl+shift+4=text:\x014
  keybind = ctrl+shift+5=text:\x015
  keybind = ctrl+shift+6=text:\x016
  keybind = ctrl+shift+7=text:\x017
  keybind = ctrl+shift+8=text:\x018
  keybind = ctrl+shift+9=text:\x019
  keybind = ctrl+shift+d=text:\x01|
  keybind = ctrl+shift+left=text:\x01H
  keybind = ctrl+shift+right=text:\x01L
  keybind = ctrl+shift+up=text:\x01K
  keybind = ctrl+shift+down=text:\x01J
  keybind = ctrl+alt+left=text:\x1bOH
  keybind = ctrl+alt+right=text:\x1bOF
  ```
  On WMs that intercept `super` (Sway, i3, KDE), the `unbind` directives are harmless no-ops — the WM consumed the key event before Ghostty ever saw it. On WMs that pass `super` through (openbox, bare X11, GNOME without dash-to-dock), the `unbind` directives prevent the simultaneous-Ghostty-and-WM-action hazard. In both cases, only the `ctrl+shift` variants reach tmux — muscle memory is consistent across every Linux desktop.

  Users who prefer `super` on a WM that doesn't intercept it can override in `config.local`:
  ```ini
  [Linux]
  keybind = super+d=text:\x01|
  keybind = ctrl+shift+d=unbind
  ```
  Document the known WM-specific conflicts in the Ghostty README and direct users to `config.local` for one-off adjustments.

  Also change `command = /bin/zsh -l -c "exec tmux new-session -A -s main"` to `command = zsh -l -c "exec tmux new-session -A -s main"`. Ghostty resolves non-absolute paths through `$PATH`, so dropping `/bin` makes this work on Linux (where zsh is at `/usr/bin/zsh`) without breaking macOS.

- `ghostty/.config/ghostty/config.local.template` -- rewrite to be OS-agnostic. Add two clearly labeled sections:
  ```ini
  # --- macOS overrides ---
  # font-size = 16    # Retina
  # background-blur = 20

  # --- Linux overrides ---
  # font-size = 13    # 1080p/1440p
  # gtk-titlebar = false   # prefer client-side decorations
  # window-theme = light   # if your DE reports light mode
  ```
  Remove "older Macs" prose and macOS-only framing.

- `scripts/setup-terminal.sh`
  - `setup_ghostty()` currently short-circuits on Linux with `info "Ghostty setup only applicable to macOS"`. Rewrite to:
    1. Create the Ghostty config directory on both platforms.
    2. On Linux: install Ghostty. The install chain is **distro-dependent**: on Arch and Fedora, Ghostty is in the native repos (`pacman -S ghostty`, `dnf install ghostty`). On Debian/Ubuntu LTS, Ghostty is **not yet in the stable repos** -- skip the `apt install` attempt and go directly to the GitHub release `.deb`. On openSUSE, check `zypper search ghostty` first. Flatpak is a last resort (`flatpak install com.mitchellh.ghostty`) and must print the Flatpak caveat (see Step 6).
    3. Keep the macOS PlistBuddy shortcut remapping guarded behind `[ "$OS" = "macos" ]`.
    4. On Linux, print the appropriate compositor keybinding snippet (Sway, GNOME, KDE) for quick-terminal so the user can set it up manually.
    5. On Linux, ensure the clipboard scripts (`clipboard-copy.sh`, `clipboard-paste.sh`) from Step 4 have the execute bit set. The scripts live in the stowed `tmux/.config/tmux/scripts/` directory, so the installer only needs to `chmod +x` the symlinked paths in `~/.config/tmux/scripts/` -- it does NOT create the files. If the tmux package hasn't been stowed yet, skip with a warning.

- `packages-linux.txt`
  - Replace `foot` with `ghostty` (keep `foot` commented as fallback).
  - Add `wl-clipboard` (provides `wl-copy`/`wl-paste` for Wayland clipboard).
  - Ghostty provides native `.deb`, `.rpm`, and Arch packages.

- `sway/.config/sway/config`
  - Update `set $term foot` to `set $term ghostty`.
  - Add quick-terminal keybind (see Step 8).

- `foot/README.md` and `sway/README.md`
  - Update `foot/README.md` to note it is now a fallback terminal, not the primary.
  - Update `sway/README.md` to reference Ghostty instead of Foot in the keybindings table, default applications, and dependency list.

- **Foot stow transition.** Users with `stow foot` already deployed will have a stale `~/.config/foot/foot.ini` symlink after switching to Ghostty. `setup-terminal.sh` should detect this and offer to `stow -D foot` (or leave it as an intentional fallback). Without this prompt, users end up with a working-but-unexpected Foot config.

- **Sway config include ordering.** The Sway config has `include /etc/sway/config-vars.d/*` (line 21) and `include /etc/sway/config.d/*` (line 233). Distro packages sometimes drop snippets in `/etc/sway/config.d/` that set `$term` to `foot`. The `set $term ghostty` line must be placed **after** the includes so it cannot be overridden. Move the `$term` assignment from its current position (line 17, before includes) to the bottom of the config, after all includes.

- **`wezterm/` package removal.** The `wezterm/` directory is a stale Stow package -- it was replaced by Ghostty on macOS but never cleaned up. Contains `.wezterm.lua` (28KB config), `README.md`, and `.stow-local-ignore`. Delete the entire `wezterm/` directory. If a user still wants WezTerm, `git log -- wezterm/` will recover it.

**Risks.** Ghostty on Linux is newer than Foot and may lack some Wayland-native polish (e.g., fractional scaling on mixed-DPI setups). Foot remains available as a backup. Ghostty is not in Debian/Ubuntu LTS repos yet; the installer's distro-specific fallback chain handles this. On non-systemd distros (Void, Alpine), Ghostty's GTK backend may have rough edges. The `unbind` directives on `super+*` keys are explicitly supported in Ghostty >=1.0; if an older build lacks `unbind`, those `keybind` lines are silently ignored and the shared config's `super` bindings remain active — this is harmless on Sway/i3/KDE (where the WM intercepts `super`), but on other WMs it creates the double-action hazard described above. The mitigation is to upgrade Ghostty or override in `config.local`.

---

### 2. Fill Out Linux Abbreviations

**Why.** The macOS `abbreviations/macos.zsh` has 125 lines covering package management, system info, networking, hardware, clipboard, file system, and developer tools. The Linux equivalent has 2 abbreviations (apt update, apt autoremove). On Linux, you manually type commands that are single abbreviations on macOS.

**Design constraint: distro-agnostic package management.** Rather than inlining `if command -v apt; then ... elif command -v dnf; then ...` in every abbreviation, a single helper function `__pkmgr()` is defined once in `zsh/functions/linux.zsh` (see Step 3) and all package abbreviations reference it. This keeps the abbreviations file readable and makes adding a new distro family a one-line change.

**What to change.**

`zsh/abbreviations/linux.zsh` -- expand to cover:

- **Package management** (all delegate to `__pkmgr`)

  ```
  update    -> __pkmgr update
  cleanup   -> __pkmgr cleanup
  install   -> __pkmgr install
  remove    -> __pkmgr remove
  search    -> __pkmgr search
  pkg-info  -> __pkmgr info
  pkg-list  -> __pkmgr list
  pkg-files -> __pkmgr files
  ```

- **System info**

  ```
  sys-info   -> inxi -Fxz || neofetch || hostnamectl
  cpu-info   -> lscpu
  mem-info   -> free -h
  disk-info  -> lsblk -f || df -h
  gpu-info   -> lspci | grep -i vga || glxinfo | grep "OpenGL renderer"
  usb-info   -> lsusb
  pci-info   -> lspci
  kernel-ver -> uname -a
  os-version -> cat /etc/os-release
  uptime     -> uptime
  ```

  Requires: `inxi` or `neofetch` (both optional; `hostnamectl` from systemd is the fallback).

- **Networking**

  ```
  ip-info     -> ip -br addr || ifconfig
  ip-public   -> curl -s ifconfig.me
  ip-local    -> hostname -I | awk '{print $1}'
  dns-servers -> grep nameserver /etc/resolv.conf
  ports       -> ss -tulanp
  wifi-info   -> nmcli dev wifi || (iw dev 2>/dev/null | grep -A5 Interface) || iwconfig
  wifi-list   -> nmcli dev wifi list
  ping-google -> ping -c 4 8.8.8.8
  ```

- **Hardware monitoring**

  ```
  cpu-temp     -> sensors | grep -i temp  (lm-sensors)
  battery      -> (upower -e 2>/dev/null | grep -q BAT) && upower -i $(upower -e | grep BAT) | grep percentage || echo "No battery found"
  brightness   -> brightnessctl
  volume       -> pactl list sinks | grep Volume
  ```

  Requires: `lm-sensors` (for `sensors`), `upower` (from systemd, usually pre-installed).

- **Modern tool replacements** (matches macOS abbreviations for daily workflow)

  Each abbreviation must inline a `command -v` check at expansion time because `abbr` has no native conditional mechanism. The pattern (shown for `ls`) is:
  ```
  ls -> if command -v eza >/dev/null 2>&1; then eza --icons --group-directories-first; else command ls; fi
  ```

  Full list:
  ```
  cat   -> if command -v batcat >/dev/null 2>&1; then batcat --paging=never; elif command -v bat >/dev/null 2>&1; then bat --paging=never; else command cat; fi
  ls    -> if command -v eza >/dev/null 2>&1; then eza --icons --group-directories-first; else command ls; fi
  tree  -> if command -v eza >/dev/null 2>&1; then eza --tree --icons; else command tree; fi
  fd    -> if command -v fdfind >/dev/null 2>&1; then fdfind --hidden; elif command -v fd >/dev/null 2>&1; then fd --hidden; else command find; fi
  rg    -> if command -v rg >/dev/null 2>&1; then rg --smart-case; else command grep -r; fi
  ```

  **Debian/Ubuntu binary name traps:** `bat` is installed as `batcat` (conflict with `bacula-console-qt`) and `fd-find` is installed as `fdfind` (conflict with another `fd` package). The abbreviations above check both names. An alternative is to create symlinks in `~/.local/bin`:
  ```sh
  mkdir -p ~/.local/bin
  command -v batcat >/dev/null 2>&1 && ln -sf "$(command -v batcat)" ~/.local/bin/bat
  command -v fdfind >/dev/null 2>&1 && ln -sf "$(command -v fdfind)" ~/.local/bin/fd
  ```
  The symlink approach keeps the abbreviations simple (`bat`, `fd`) but requires `~/.local/bin` on `$PATH`.

  **Decision: use the dual-name abbreviation approach.** The symlink approach is cleaner but requires an external setup step that can silently fail if `~/.local/bin` is not on `$PATH`. The dual-name `command -v batcat || command -v bat` check works regardless of distro packaging, requires no extra setup, and the small verbosity cost in the abbreviations file is a one-time write. The abbreviations above already use this pattern. No symlink creation is needed.

- **Clipboard**

  ```
  clipboard -> wl-paste 2>/dev/null || xclip -selection clipboard -o
  pbcopy    -> wl-copy 2>/dev/null || xclip -selection clipboard
  pbpaste   -> wl-paste 2>/dev/null || xclip -selection clipboard -o
  ```

	  **Reconciliation with `.zsh_cross_platform`.** `.zsh_cross_platform` (sourced from `.zshrc:10-11`) already defines `clipboard_copy()` and `clipboard_paste()` shell functions with full Wayland detection (lines 290-337). The abbreviations (`pbcopy`/`pbpaste`) exist primarily so muscle-memory `| pbcopy` / `pbpaste` commands work identically on both platforms. The functions remain available for scripting use. The abbreviations and functions are intentionally redundant -- abbreviations for interactive pipe/typing use, functions for scripts.

  Note: `cpb` (`cat | pbcopy`) is already defined in `development.zsh`. Because `_init.zsh` glob-sources files alphabetically, `development.zsh` loads before `linux.zsh`. At that point `pbcopy` is not yet defined (it's an abbreviation in `linux.zsh`, which loads later). This means `cpb` captures the literal string `pbcopy` at definition time, not the abbreviation's expansion. On macOS where `pbcopy` is a real binary this works fine; on Linux the `cpb` abbreviation would try to execute `pbcopy` which doesn't exist.

  ```
  # Shadow development.zsh's cpb (which captures pbcopy at expansion time -- pbcopy
  # is an abbreviation on Linux, not a real binary, so cpb must inline the tool).
  abbr -S cpb='cat | wl-copy 2>/dev/null || cat | xclip -selection clipboard'
  ```

- **Desktop / window manager**

  ```
  lock       -> loginctl lock-session || swaylock
  screenshot -> grim -g "$(slurp)" 2>/dev/null || grim 2>/dev/null || import -window root
  ```

  The `screenshot` abbreviation handles both selection (via `slurp`) and full-screen capture. The `screenshot-area()` function originally planned in Step 3 is removed -- one abbreviation is sufficient.

  Requires: `grim` and `slurp` (both already in `packages-linux.txt` via Step 7).

- **System maintenance**

  ```
  system-cleanup -> sudo journalctl --vacuum-time=7d && __pkmgr cleanup
  clear-logs     -> sudo journalctl --vacuum-time=1d
  ```

**Risks.** Low. Abbreviations are loaded conditionally (`[[ "$OSTYPE" == "darwin"* ]] && return 0` guard already present). `command -v` checks prevent errors when a tool is not installed. The `__pkmgr` dependency is documented at the top of the file.

---

### 3. Create Linux-Specific Functions File

**Why.** macOS has `zsh/functions/macos.zsh` with `cpu-temp()`, `wifi-scan()`, `ql()`. Linux has no equivalent. Several CLI operations that are a single command on macOS require multi-step pipelines on Linux -- wrapping them in named functions reduces cognitive load. Additionally, a `__pkmgr()` helper is needed to keep the abbreviations from becoming unreadable distro-detection chains.

**What to change.**

`zsh/functions/linux.zsh` (new file) -- define:

- **`__pkmgr()`** -- distro-agnostic package manager wrapper. Detects the active package manager once at load time and caches it, then dispatches subcommands. Maps `update`, `cleanup`, `install`, `remove`, `search`, `info`, `list`, `files` to apt, dnf, or pacman equivalents. Called by all package-management abbreviations.


  Implementation:

  ```zsh
  # Cache the detected package manager so we only probe once per shell session.
  # Usage: __pkmgr <subcommand> [args...]
  # Subcommands: update, cleanup, install, remove, search, info, list, files
  __pkmgr() {
    # Detect and cache
    if [[ -z "$__PKMGR" ]]; then
      if command -v apt >/dev/null 2>&1; then        __PKMGR=apt
      elif command -v dnf >/dev/null 2>&1; then       __PKMGR=dnf
      elif command -v pacman >/dev/null 2>&1; then    __PKMGR=pacman
      elif command -v zypper >/dev/null 2>&1; then    __PKMGR=zypper
      elif command -v apk >/dev/null 2>&1; then       __PKMGR=apk
      elif command -v xbps-install >/dev/null 2>&1; then __PKMGR=xbps
      elif command -v emerge >/dev/null 2>&1; then    __PKMGR=emerge
      elif command -v eopkg >/dev/null 2>&1; then     __PKMGR=eopkg
      elif command -v swupd >/dev/null 2>&1; then     __PKMGR=swupd
      else
        echo "[__pkmgr] No supported package manager found" >&2; return 1
      fi
    fi

    local cmd="$1"; shift
    case "$__PKMGR" in
      apt)
        case "$cmd" in
          update)  sudo apt update && sudo apt upgrade -y ;;
          cleanup) sudo apt autoremove -y && sudo apt autoclean ;;
          install) sudo apt install -y "$@" ;;
          remove)  sudo apt remove -y "$@" ;;
          search)  apt search "$@" ;;
          info)    apt show "$@" ;;
          list)    apt list --installed ;;
          files)   dpkg -L "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      dnf)
        case "$cmd" in
          update)  sudo dnf upgrade -y ;;
          cleanup) sudo dnf autoremove -y ;;
          install) sudo dnf install -y "$@" ;;
          remove)  sudo dnf remove -y "$@" ;;
          search)  dnf search "$@" ;;
          info)    dnf info "$@" ;;
          list)    dnf list --installed ;;
          files)   rpm -ql "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      pacman)
        case "$cmd" in
          update)  sudo pacman -Syu ;;
          cleanup) sudo pacman -Sc && sudo pacman -Rns "$(pacman -Qdtq 2>/dev/null)" ;;
          install) sudo pacman -S --needed "$@" ;;
          remove)  sudo pacman -R "$@" ;;
          search)  pacman -Ss "$@" ;;
          info)    pacman -Qi "$@" ;;
          list)    pacman -Q ;;
          files)   pacman -Ql "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      zypper)
        case "$cmd" in
          update)  sudo zypper dup -y ;;
          cleanup) sudo zypper clean ;;
          install) sudo zypper install -y "$@" ;;
          remove)  sudo zypper remove -y "$@" ;;
          search)  zypper search "$@" ;;
          info)    zypper info "$@" ;;
          list)    zypper packages --installed-only ;;
          files)   rpm -ql "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      apk)
        case "$cmd" in
          update)  sudo apk update && sudo apk upgrade ;;
          cleanup) sudo apk cache clean ;;
          install) sudo apk add "$@" ;;
          remove)  sudo apk del "$@" ;;
          search)  apk search "$@" ;;
          info)    apk info "$@" ;;
          list)    apk info -v ;;
          files)   apk info -L "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      xbps)
        case "$cmd" in
          update)  sudo xbps-install -Su ;;
          cleanup) sudo xbps-remove -Oo ;;
          install) sudo xbps-install "$@" ;;
          remove)  sudo xbps-remove -R "$@" ;;
          search)  xbps-query -Rs "$@" ;;
          info)    xbps-query -S "$@" ;;
          list)    xbps-query -l ;;
          files)   xbps-query -f "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      emerge)
        case "$cmd" in
          update)  sudo emerge --sync && sudo emerge -uDN @world ;;
          cleanup) sudo emerge --depclean ;;
          install) sudo emerge "$@" ;;
          remove)  sudo emerge --deselect "$@" ;;
          search)  emerge --search "$@" ;;
          info)    equery meta "$@" 2>/dev/null || emerge -pv "$@" ;;
          list)    qlist -I ;;
          files)   equery files "$@" 2>/dev/null || echo "Requires app-portage/gentoolkit" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      eopkg)
        case "$cmd" in
          update)  sudo eopkg upgrade ;;
          cleanup) sudo eopkg remove-orphans && sudo eopkg clean ;;
          install) sudo eopkg install "$@" ;;
          remove)  sudo eopkg remove "$@" ;;
          search)  eopkg search "$@" ;;
          info)    eopkg info "$@" ;;
          list)    eopkg list-installed ;;
          files)   eopkg files "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      swupd)
        case "$cmd" in
          update)  sudo swupd update ;;
          cleanup) sudo swupd clean ;;
          install) sudo swupd bundle-add "$@" ;;
          remove)  sudo swupd bundle-remove "$@" ;;
          search)  swupd search "$@" ;;
          info)    swupd info "$@" ;;
          list)    swupd bundle-list ;;
          files)   swupd bundle-info "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
    esac
  }
  ```

  The `__pkmgr` cache is set once at shell init; if the user changes distros mid-session (essentially never), they can `unset __PKMGR` to force re-detection. All subcommands that require root use `sudo` inline so the function itself never escalates silently.

  Implementation:

  ```zsh
  # Cache the detected package manager so we only probe once per shell session.
  # Usage: __pkmgr <subcommand> [args...]
  # Subcommands: update, cleanup, install, remove, search, info, list, files
  __pkmgr() {
    # Detect and cache
    if [[ -z "$__PKMGR" ]]; then
      if command -v apt >/dev/null 2>&1; then        __PKMGR=apt
      elif command -v dnf >/dev/null 2>&1; then       __PKMGR=dnf
      elif command -v pacman >/dev/null 2>&1; then    __PKMGR=pacman
      elif command -v zypper >/dev/null 2>&1; then    __PKMGR=zypper
      elif command -v apk >/dev/null 2>&1; then       __PKMGR=apk
      elif command -v xbps-install >/dev/null 2>&1; then __PKMGR=xbps
      elif command -v emerge >/dev/null 2>&1; then    __PKMGR=emerge
      elif command -v eopkg >/dev/null 2>&1; then     __PKMGR=eopkg
      elif command -v swupd >/dev/null 2>&1; then     __PKMGR=swupd
      else
        echo "[__pkmgr] No supported package manager found" >&2; return 1
      fi
    fi

    local cmd="$1"; shift
    case "$__PKMGR" in
      apt)
        case "$cmd" in
          update)  sudo apt update && sudo apt upgrade -y ;;
          cleanup) sudo apt autoremove -y && sudo apt autoclean ;;
          install) sudo apt install -y "$@" ;;
          remove)  sudo apt remove -y "$@" ;;
          search)  apt search "$@" ;;
          info)    apt show "$@" ;;
          list)    apt list --installed ;;
          files)   dpkg -L "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      dnf)
        case "$cmd" in
          update)  sudo dnf upgrade -y ;;
          cleanup) sudo dnf autoremove -y ;;
          install) sudo dnf install -y "$@" ;;
          remove)  sudo dnf remove -y "$@" ;;
          search)  dnf search "$@" ;;
          info)    dnf info "$@" ;;
          list)    dnf list --installed ;;
          files)   rpm -ql "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      pacman)
        case "$cmd" in
          update)  sudo pacman -Syu ;;
          cleanup) sudo pacman -Sc && sudo pacman -Rns "$(pacman -Qdtq 2>/dev/null)" ;;
          install) sudo pacman -S --needed "$@" ;;
          remove)  sudo pacman -R "$@" ;;
          search)  pacman -Ss "$@" ;;
          info)    pacman -Qi "$@" ;;
          list)    pacman -Q ;;
          files)   pacman -Ql "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      zypper)
        case "$cmd" in
          update)  sudo zypper dup -y ;;
          cleanup) sudo zypper clean ;;
          install) sudo zypper install -y "$@" ;;
          remove)  sudo zypper remove -y "$@" ;;
          search)  zypper search "$@" ;;
          info)    zypper info "$@" ;;
          list)    zypper packages --installed-only ;;
          files)   rpm -ql "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      apk)
        case "$cmd" in
          update)  sudo apk update && sudo apk upgrade ;;
          cleanup) sudo apk cache clean ;;
          install) sudo apk add "$@" ;;
          remove)  sudo apk del "$@" ;;
          search)  apk search "$@" ;;
          info)    apk info "$@" ;;
          list)    apk info -v ;;
          files)   apk info -L "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      xbps)
        case "$cmd" in
          update)  sudo xbps-install -Su ;;
          cleanup) sudo xbps-remove -Oo ;;
          install) sudo xbps-install "$@" ;;
          remove)  sudo xbps-remove -R "$@" ;;
          search)  xbps-query -Rs "$@" ;;
          info)    xbps-query -S "$@" ;;
          list)    xbps-query -l ;;
          files)   xbps-query -f "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      emerge)
        case "$cmd" in
          update)  sudo emerge --sync && sudo emerge -uDN @world ;;
          cleanup) sudo emerge --depclean ;;
          install) sudo emerge "$@" ;;
          remove)  sudo emerge --deselect "$@" ;;
          search)  emerge --search "$@" ;;
          info)    equery meta "$@" 2>/dev/null || emerge -pv "$@" ;;
          list)    qlist -I ;;
          files)   equery files "$@" 2>/dev/null || echo "Requires app-portage/gentoolkit" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      eopkg)
        case "$cmd" in
          update)  sudo eopkg upgrade ;;
          cleanup) sudo eopkg remove-orphans && sudo eopkg clean ;;
          install) sudo eopkg install "$@" ;;
          remove)  sudo eopkg remove "$@" ;;
          search)  eopkg search "$@" ;;
          info)    eopkg info "$@" ;;
          list)    eopkg list-installed ;;
          files)   eopkg files "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
      swupd)
        case "$cmd" in
          update)  sudo swupd update ;;
          cleanup) sudo swupd clean ;;
          install) sudo swupd bundle-add "$@" ;;
          remove)  sudo swupd bundle-remove "$@" ;;
          search)  swupd search "$@" ;;
          info)    swupd info "$@" ;;
          list)    swupd bundle-list ;;
          files)   swupd bundle-info "$@" ;;
          *) echo "[__pkmgr] Unknown subcommand: $cmd" >&2; return 1 ;;
        esac ;;
    esac
  }
  ```

  The `__pkmgr` cache is set once at shell init; if the user changes distros mid-session (essentially never), they can `unset __PKMGR` to force re-detection. All subcommands that require root use `sudo` inline so the function itself never escalates silently.
- `cpu-temp()` -- wrap `sensors` from lm-sensors with filtering to show only CPU core temps.
- `wifi-scan()` -- wrap `nmcli dev wifi list` or `iwlist scan` with pretty output.
- `brightness()` -- wrap `brightnessctl` to get/set display brightness.
- `audio()` -- wrap `pactl` / `wpctl` to get/set volume and list sinks.
- `workspace()` -- when running Sway, list or switch workspaces.

Guard clause at top:

```zsh
[[ "$OSTYPE" == "darwin"* ]] && return 0
```

**Loader check.** The `zsh/functions/_init.zsh` already sources all `*.zsh` files in the directory with a glob, so no loader change is needed. Verify this during validation.

**Risks.** Low. Functions are opt-in; they only define helpers, nothing is auto-executed. `command -v` guards produce a clear "install X" message instead of cryptic errors. The `__pkmgr` cache is set once at shell init; if the user changes distros mid-session (essentially never), they can `unset` it to force re-detection.

---

### 4. Fix tmux Clipboard for Wayland

**Why.** The tmux config has four `if-shell "uname | grep -q Darwin"` blocks (copy-mode-vi yank, copy-mode-vi double/triple-click, prefix+Y/y, extrakto config) that all fall back to `xclip` on Linux. Under Wayland (the default on modern Linux), `xclip` silently fails because there is no X11 clipboard. Selecting text in tmux copy-mode on a Wayland machine does nothing.

This is a higher-priority gap than most of the plan because it is a **silent failure** on a core interaction (selecting and copying text), not a missing convenience.

**What to change.**

- `tmux/.tmux.conf` -- replace every `xclip -in -selection clipboard` with a reference to a single wrapper script:
  ```sh
  # Instead of inline xclip:
  bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "$HOME/.config/tmux/scripts/clipboard-copy.sh"
  ```
  And every `xclip -in -selection clipboard` in the copy-mode click bindings with the same script reference.

- `tmux/.config/tmux/scripts/clipboard-copy.sh` (new file) -- auto-detect the display server and route to the right clipboard tool:
  ```sh
  #!/bin/sh
  # Routes stdin to the system clipboard, auto-detecting Wayland vs X11.
  # Falls back to OSC 52 escape sequences when no native clipboard tool is
  # available (e.g., bare Wayland with no wl-clipboard, or tmux launched
  # from a systemd service where $WAYLAND_DISPLAY is unset).
  #
  # OSC 52 is an ANSI escape sequence that instructs the outer terminal
  # (Ghostty) to write to the system clipboard. It works over SSH, inside
  # nested tmux sessions, and in headless/TTY-launched contexts where
  # $WAYLAND_DISPLAY and $DISPLAY are both absent. Ghostty accepts OSC 52
  # writes from tmux because tmux forwards them (set-clipboard=on) and
  # Ghostty has clipboard-write=allow.
  if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    xclip -in -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    # Last resort: OSC 52 escape sequence. Strips terminal newline so
    # the output is a single OSC sequence. Maximum payload is ~768KB
    # after base64 inflation; tmux clips oversized OSC sequences.
    printf '\x1b]52;c;'
    base64 | tr -d '\n'
    printf '\x1b\\'
  fi
  ```

  **OSC 52 clipboard-read path.** `clipboard-paste.sh` cannot use OSC 52 to *read* the clipboard (OSC 52 is write-only; the terminal responds asynchronously and tmux has no mechanism to capture that reply into a paste buffer). When neither `wl-paste` nor `xclip -out` is available, `clipboard-paste.sh` should print a clear diagnostic: "No clipboard paste tool found. Install wl-clipboard or xclip." This is inherently a narrower gap — pasting requires a cooperating application on the other side, which implies a desktop environment that almost certainly ships a clipboard tool.

- Same treatment for `pbpaste | tmux load-buffer -` (prefix + ] paste): replace with a `clipboard-paste.sh` script that detects `$WAYLAND_DISPLAY` and uses `wl-paste` or `xclip -out`.

- `tmux/.config/tmux/scripts/copy.sh` and `copy-strip-prompt.sh` (existing scripts referenced by double/triple-click binds) -- update to use the same detection logic (`$WAYLAND_DISPLAY` + `wl-copy`) instead of hardcoding `pbcopy` / `xclip`.

- `set -g @extrakto_clip_tool` (line 357-359) -- point at `clipboard-copy.sh` instead of the platform-specific inline value. Confirm that extrakto pipes stdin to this value as a command (it does).

**Risks.** Low. The wrapper script is ~20 lines; the detection logic is well-established. The macOS path is unaffected because the `if-shell "uname"` guard still routes macOS to `pbcopy`. The existing `copy.sh` and `copy-strip-prompt.sh` already have the execute bit tracked in git (mode 100755). The new `clipboard-copy.sh` and `clipboard-paste.sh` must be `chmod +x` -- this is handled by `setup-terminal.sh` (added to Step 1). The OSC 52 fallback has a ~768KB payload limit after base64 inflation (imposed by tmux, which clips oversized OSC sequences); this is sufficient for any text a human would select in copy-mode. The OSC 52 path requires `set-clipboard=on` in tmux (already set) and `clipboard-write=allow` in Ghostty (already set); verify both are present during validation.

**Neovim clipboard on Wayland.** Neovim's `"+y`/`"+p` use the system clipboard. Neovim >=0.10 auto-detects `wl-copy`/`wl-paste` on Wayland; earlier versions need explicit `g:clipboard` configuration. On Debian stable (Neovim ~0.7.x), add to `~/.config/nvim/lua/config/settings.lua`:
  ```lua
  if vim.fn.has('wayland') == 1 then
    vim.g.clipboard = {
      name = 'wl-clipboard',
      copy = { ['+'] = 'wl-copy', ['*'] = 'wl-copy' },
      paste = { ['+'] = 'wl-paste', ['*'] = 'wl-paste' },
      cache_enabled = 0,
    }
  end
  ```
  The existing `vim.opt.clipboard = "unnamedplus"` (neovim/.config/nvim/lua/config/settings.lua:32) is correct. `wl-clipboard` is added to the package list in Step 7. Validate during Step 11 on both new and old Neovim versions.

**Existing `linux/` Uniclip package.** The `linux/` directory contains `uniclip.service` (a systemd user service) and `install-uniclip-service.sh`. Uniclip is a third-party clipboard synchronization daemon that bridges X11 and Wayland clipboards. With `wl-clipboard` installed and modern compositors (wlroots, Mutter) providing built-in XWayland clipboard bridging, Uniclip is redundant for most users.

Decision: Remove `linux/uniclip.service` and `linux/install-uniclip-service.sh`, then delete the `linux/` Stow package (it contains nothing else). If a user needs X11↔Wayland clipboard bridging beyond what the compositor provides, `wl-clipboard`'s built-in bridging covers it. Add this cleanup to Step 9.

---

### 5. Theme Auto-Detection on Linux (Both Blocks)

**Why.** The tmux config detects macOS light/dark mode via `defaults read -g AppleInterfaceStyle` and applies the correct Gruvbox variant. On Linux, it always falls back to dark mode. GNOME and KDE both expose the current color scheme preference.

There are **two** blocks in `tmux/.tmux.conf` that duplicate this detection logic:
1. The main theme block (line 292-331) -- status bar, pane borders, window status
2. The CPU color block (line 370-383) -- `@cpu_low_fg_color`, `@cpu_medium_fg_color`, etc.

Both must be updated, and the detection should be refactored into a single shared variable so they cannot drift apart.

**Design decision: externalize to a script.** The current inline `run-shell` approach (a multi-escaped one-liner) is fragile and hard to debug. Externalize detection to a script, following the same pattern as the clipboard scripts in Step 4.

**What to change.**

- `tmux/.config/tmux/scripts/theme-detect.sh` (new file) -- detects the current theme mode and prints `dark` or `light`:
  ```sh
  #!/bin/sh
  # Detects system theme mode. Respects $THEME_MODE override.
  # Prints "dark" or "light". Exit code is always 0.
  _m="${THEME_MODE}"
  if [ -n "$_m" ]; then
    echo "$_m"
    exit 0
  fi
  # macOS: AppleInterfaceStyle
  if command -v defaults >/dev/null 2>&1; then
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark; then
      echo "dark"; exit 0
    elif defaults read -g AppleInterfaceStyle 2>/dev/null >/dev/null 2>&1; then
      echo "light"; exit 0
    fi
  fi
  # Linux: GNOME gsettings
  if command -v gsettings >/dev/null 2>&1; then
    if gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | grep -q "prefer-light"; then
      echo "light"; exit 0
    fi
  fi
  # Linux: KDE 6 (kreadconfig6)
  if command -v kreadconfig6 >/dev/null 2>&1; then
    if kreadconfig6 --group General --key ColorScheme 2>/dev/null | grep -qi "light"; then
      echo "light"; exit 0
    fi
  # Linux: KDE 5 fallback (kreadconfig5 + kdeglobals)
  elif command -v kreadconfig5 >/dev/null 2>&1; then
    if kreadconfig5 --group General --key ColorScheme 2>/dev/null | grep -qi "light"; then
      echo "light"; exit 0
    fi
  fi
  # Linux: GTK_THEME env var (catches Xfce, Cinnamon, and KDE without kreadconfig)
  if echo "$GTK_THEME" | grep -qi "light"; then
    echo "light"; exit 0
  fi
  # Fallback
  echo "dark"
  ```

  Detection order: `$THEME_MODE` env var > macOS `defaults` > GNOME `gsettings` > KDE `kreadconfig6`/`kreadconfig5` > `$GTK_THEME` substring > fallback dark.

- `tmux/.tmux.conf` -- replace both inline `_m=${THEME_MODE}; ...` shell expressions with:
  ```sh
  run-shell 'tmux set -g @theme_mode "$("$HOME/.config/tmux/scripts/theme-detect.sh")"'
  ```

- Both the main theme block and the CPU color block then switch on `#{@theme_mode}` with `if-shell -F '#{==:#{@theme_mode},dark}'` instead of running the shell expression inline. This eliminates ~40 lines of duplication and ensures the two blocks never disagree.

**Risks.** Low. The `$THEME_MODE` env var override still works. If `gsettings` is unavailable and `$GTK_THEME` is unset (bare TTY, minimal WMs), the fallback to dark is the safe default. The external script is easier to test in isolation than the inline `run-shell` expression.

---

### 6. System-Wide Quick Terminal Hotkey (Linux)

**Why.** macOS has `Cmd+backtick` bound to `global:super+backquote=toggle_quick_terminal`. On Linux, Ghostty's quick terminal works but must be bound at the compositor level (Sway, GNOME, KDE) -- there is no `global:` keybind support on Linux.

**What to change.**

- `sway/.config/sway/config` (Stow package at `sway/` symlinks this to `~/.config/sway/config`)
  - Add: `bindsym $mod+grave exec ghostty --quick-terminal`
  - Also update `set $term foot` to `set $term ghostty` (noted in Step 1).

- `ghostty/.config/ghostty/config`
  - The macOS `global:super+backquote` binding (line 210) is silently ignored on Linux; leave it as-is.
  - The `quick-terminal-position`, `quick-terminal-size`, and `quick-terminal-animation-duration` settings (lines 273-275) apply on Linux too -- no change needed.

- `scripts/setup-terminal.sh`
  - After installing Ghostty on Linux, print compositor-specific binding instructions:
    - **Sway:** `bindsym $mod+grave exec ghostty --quick-terminal`
    - **GNOME:** Settings > Keyboard > Keyboard Shortcuts > Custom Shortcuts
    - **KDE:** System Settings > Shortcuts > Custom Shortcuts > New > Global Shortcut

**Risks.** Low. Sway config changes are opt-in via stow. The Ghostty config settings are harmless on all platforms.

**Flatpak caveat.** If Ghostty is installed via Flatpak (the last-resort fallback in Step 1's install chain), the binary is namespaced under `flatpak run com.mitchellh.ghostty`. This affects:

  - **Sway quick-terminal binding:** Must be `exec flatpak run com.mitchellh.ghostty --quick-terminal`.
  - **Sway terminal binding (`$mod+Return`):** Must be `exec flatpak run com.mitchellh.ghostty`.
  - **Ghostty config settings:** `gtk-titlebar`, `gtk-tabs`, and `window-theme` may behave differently under Flatpak's sandbox (GTK theme access is restricted).
  - **Shell integration:** The `command = zsh -l -c "exec tmux ..."` line in the Ghostty config still works -- Flatpak Ghostty can execute host binaries on `$PATH`.

  The plan's default assumes a native/system package install. When Flatpak is the chosen install method, `setup-terminal.sh` must print all three binding adjustments (quick-terminal, terminal launcher, and Sway `$term` variable) and note the GTK theme caveat.

---

### 7. Add Ghostty and Wayland Tools to Linux Package List and Installer

**Why.** `packages-linux.txt` lists `foot` as the terminal emulator and `xclip` as the only clipboard tool. `setup-terminal.sh` skips Ghostty setup on Linux. `wl-clipboard` (Wayland clipboard) is missing entirely. Several packages needed by the new abbreviations and tmux keybindings are also absent. Beyond packages, the installer has pre-existing bugs (wrong tmux prefix in post-install instructions) and missing steps (Starship config build, shell completions, tmux-sessionizer installation) that prevent a working system out of the box.

**What to change.**

- `packages-linux.txt` -- new entries (keeping existing ones):

  - **Terminal:** Replace `foot` with `ghostty` (keep `foot` commented as fallback).
  - **Clipboard:** Add `wl-clipboard` alongside `xclip` for Wayland clipboard support. Demote `xclip` to a comment since Wayland is the primary target on modern Linux, but keep it available for X11 fallback.
  - **Modern CLI tools:** Add `bat`, `eza` (NB: `fd-find` and `ripgrep` are already present; `bat` and `eza` are not).
  - **Tmux popup dependencies:** Add `lazygit` and `btop` (used by prefix+G and prefix+M).
  - **Screenshot:** Add `slurp` alongside existing `grim` (screenshot abbreviation uses both).
  - **System info:** Add `lm-sensors` (for `cpu-temp` abbreviation), `inxi` or `neofetch` (optional, for `sys-info` abbreviation).
  - **Markdown preview:** Add `glow` (used by `development.zsh`'s `g`/`glip` abbreviations).
  - **Font tools:** Add `fontconfig` (provides `fc-cache` for font cache rebuild after Nerd Font install). Note: `install_fonts()` in `setup-terminal.sh` already downloads Nerd Font tarballs to `~/.local/share/fonts/` and runs `fc-cache -fv` on Linux -- wiring already exists and just needs to be called.
	  - **Audio:** Add `pulseaudio-utils` or `pipewire-pulse` (provides `pactl` for the `volume` abbreviation and Sway media keys). On a minimal Sway install without a desktop metapackage, `pactl` is absent.
	  - **Desktop integration:** Add `polkit-gnome` or `lxpolkit` (polkit auth agent, needed for GUI auth dialogs in Sway). Add `swayidle` (auto-lock on idle, paired with `swaylock`). Add `xdg-desktop-portal-wlr` and `xdg-desktop-portal-gtk` (screen sharing in Wayland-native apps). Add `noto-fonts-emoji` (emoji fallback for Starship prompt and Nerd Font coverage gaps). Add `qt5-wayland` and `qt6-wayland` (native Wayland for Qt apps).

- `scripts/setup-packages.sh` -- `get_platform_packages()` is the function the installer actually reads from (NOT `packages-linux.txt`, which is a reference manifest). It is hardcoded per-distro. Update every Linux distro entry to include the new packages:

  - **debian|ubuntu|linuxmint|pop**: Add `ghostty`, `wl-clipboard`, `bat`, `eza`, `slurp`, `lm-sensors`, `glow`, `fontconfig`, `btop`, `lazygit`. Also add `xclip` (currently missing from ALL `get_platform_packages()` entries -- it exists only in `packages-linux.txt`). Keep `foot` and `xclip` as active packages (not commented); they remain as fallbacks for X11 and non-Ghostty users respectively.
  - **arch|manjaro|endeavouros|garuda**: Add `ghostty`, `wl-clipboard`, `bat`, `eza`, `slurp`, `lm-sensors`, `glow`, `fontconfig`, `btop`, `lazygit`, `xclip`. (Arch uses `fd` not `fd-find`; verify the current entry is correct.)
  - **redhat|fedora|rhel|centos|rocky|almalinux**: Same additions, using RPM Fusion / COPR package names where needed.
  - **opensuse-leap|tumbleweed**: Add `ghostty`, `wl-clipboard`, `bat`, `eza`, `slurp`, `lm-sensors`, `glow`, `fontconfig`, `btop`, `lazygit`, `xclip`. Package names may differ (e.g., `fd` vs `fd-find`); map to what the distro provides.
  - **All other distro entries** (void, alpine, gentoo, solus, clear-linux-os): Add at minimum `ghostty`, `wl-clipboard`, `bat`, `eza`, `xclip`. Other packages (`slurp`, `lm-sensors`, `glow`, `fontconfig`, `btop`, `lazygit`) may have different names or be unavailable; add what the distro provides and document remaining gaps. The parity gap narrows but does not fully close on these distros.

- `scripts/setup-terminal.sh` -- changes beyond Step 1's `setup_ghostty()` rewrite:

  - **`setup_ghostty()`**: rewrite to handle both platforms (detailed in Step 1).
  - The `command` path in Ghostty's config is changed to `command = zsh` (non-absolute, resolved via `$PATH`). See Step 1.
  - Ensure clipboard scripts are `chmod +x` after creation (Step 4).

  - **`tmux-sessionizer` installation.** The tmux config binds `prefix+T` to `tmux-sessionizer` -- a third-party script from ThePrimeagen's dotfiles. On Linux, this is missing and the binding silently fails. `setup-terminal.sh` should:
    1. Check if `tmux-sessionizer` is already on `$PATH`. If so, skip.
    2. Clone `https://github.com/theprimeagen/.dotfiles` to a temp directory and copy `bin/.local/bin/tmux-sessionizer` to `~/.local/bin/tmux-sessionizer`.
    3. **Linux audit:** scan the copied script for macOS-isms before installing. Known risks in ThePrimeagen's dotfiles (as of 2025):
       - The script uses GNU `find` / GNU `sed` syntax. On macOS these differ; on Linux they match the GNU variants, so the script is safe for this use case.
       - `tmux` commands inside the script are platform-agnostic (`tmux new-session`, `tmux switch-client`, etc.).
       - The script reads `$HOME/Projects` — no hardcoded `/Users/` paths.
       
       The audit should grep for `pbcopy`, `pbpaste`, `/Users/`, `brew`, `open` (macOS file-opener), and `osascript`. If any are found, patch the script in-place with a `sed` one-liner or print a warning with the offending line numbers. If the script has changed upstream since this analysis, the audit catches newly introduced macOS-isms before they become silent failures.
    4. Ensure `~/.local/bin` is on `$PATH`. Read `zsh/.zshenv` to verify it adds `~/.local/bin` to `$PATH`. If `.zshenv` does not exist or does not reference `~/.local/bin`, add the PATH entry: `export PATH="$HOME/.local/bin:$PATH"`.
    5. If the clone fails (no network), print a warning with the manual install URL.

    **Session ordering caveat.** `setup-terminal.sh` installs `tmux-sessionizer` to `~/.local/bin`, but if the current shell session hasn't sourced `.zshenv` yet (or the installer runs before the user opens a new shell), `tmux-sessionizer` won't be on `PATH` and `prefix+T` will fail until the next shell restart. The post-install message should note: "tmux-sessionizer installed to ~/.local/bin. Restart your shell or run `hash -r` before using prefix+T."

  - **Starship binary install.** `setup_starship()` currently installs via Homebrew or curl. On Linux, `starship` is available in apt/dnf/pacman/zypper. Check for a distro package first (`command -v starship`), then try the distro's native install, falling back to curl. Installing via the package manager keeps starship updated through system updates.

  - **Starship config build.** The `starship/` package uses a modular build system (`build-configs.sh` assembles `modules/`/`modes/`/`formats/` into `starship.toml`). The setup script copies `starship/starship.toml` to `~/.config/starship/` but the file doesn't exist at that path -- it's built to `starship/.config/starship/`. Fix the copy source to use `starship/.config/starship/starship.toml` or run `build-configs.sh` first to generate the file at the expected location. The installer copies `starship.toml` to `~/.config/starship/` but the file does not exist in the repo -- it must be built first. Add a step that runs `starship/build-configs.sh` before copying. If the build script fails, print a warning and skip (the user can run it manually later).

    The build output is `starship/.config/starship/starship.toml` (474 lines, currently tracked in git). The `.gitignore` comment on lines 258-262 says "Generated output in starship/.config/starship/ is now tracked," indicating this was an intentional decision. Leave the file tracked -- the `build-configs.sh` step is only needed when the user first clones the repo, and the committed artifact means the prompt works without running the build script. `setup-terminal.sh` should still call `build-configs.sh` to regenerate `starship.toml` so local module edits are reflected.

  - **fzf and zoxide shell integration.** `.zshrc` lines 202-220 already source both fzf and zoxide with platform-agnostic logic (`fzf --zsh` for modern fzf, `zoxide init zsh`). No additional file is needed. Verify during validation that `Ctrl+R` history search and `z`/`zi` work on a fresh Linux install; if the distro's fzf package is older and lacks `fzf --zsh`, the existing `.zshrc` fallback paths handle it.

  - **zsh completions directory.** The repo has no `~/.zsh/completions/` directory, and nothing ensures it is on `$fpath`. Create `zsh/.zsh_completions` that:
    1. Ensures `~/.zsh/completions/` exists (`mkdir -p`).
    2. Adds it to `$fpath` with `fpath=(~/.zsh/completions $fpath)`.
    3. Is sourced from `zsh/.zshrc` before `compinit` runs.
    
    `setup-terminal.sh` should create the directory if it doesn't exist, but defer completion *installation* to the user (the post-install note from the plan already covers this). Individual tools like `eza`, `bat`, `fd`, and `ripgrep` each have their own `--completions` flag; automating this is fragile across distros.

    The existing completions note in post-install output is still valid but should also mention `~/.zsh/completions/` as the destination and `fpath` setup as a prerequisite.

  - **`zsh-abbr` distro-native check.** `setup_zsh_abbr()` only checks Homebrew paths and falls back to `git clone`. On Linux without Homebrew, it always clones from GitHub even when a native package exists. Add a check before the clone that covers all 10 supported package managers: `apt list --installed 2>/dev/null | grep -q zsh-abbr` / `dnf list installed zsh-abbr` / `pacman -Q zsh-abbr` / `zypper search -i zsh-abbr` / `xbps-query zsh-abbr` / `apk info -e zsh-abbr` / `equery list zsh-abbr` (Gentoo) / `eopkg info zsh-abbr` / `swupd search zsh-abbr`. Implement as a `command -v abbr >/dev/null 2>&1` check first (fast path -- if `abbr` is already on PATH, skip the package manager query entirely), then fall back to distro-specific queries. The `_init.zsh` loader already checks `/usr/share/zsh/site-functions/` implicitly via the fallback paths; verify that distro-installed `zsh-abbr` is discoverable. If the distro installs to a non-standard location, add that path to the loader's search list.

  **Loader also needs distro-native paths.** The abbreviation loader (`zsh/abbreviations/_init.zsh`) only checks Homebrew paths (lines 18-29). If `zsh-abbr` is installed via `apt`/`dnf`/`pacman`, it lands at `/usr/share/zsh/site-functions/` or `/usr/share/zsh/plugins/zsh-abbr/`, which the loader never checks. Add a check for `/usr/share/zsh/plugins/zsh-abbr/zsh-abbr.zsh` and `/usr/share/zsh/site-functions/zsh-abbr.zsh` before the existing Homebrew checks. Without this, every new shell prints "zsh-abbr not found" even though the package is installed.

  - **btop / lazygit graceful fallback.** The tmux config unconditionally binds `prefix+M` (btop) and `prefix+G` (lazygit). If these aren't installed, the popups open and immediately fail with "command not found" -- the user can't read the error before it closes. `setup-terminal.sh` should warn at install time if `btop` or `lazygit` are missing, and suggest either installing them or adding a conditional guard in `~/.tmux.local`. (The tmux bindings themselves are left unconditional to keep the main config simple; local overrides handle the per-machine case.)

  - **Wayland environment variables.** Several popular apps (VS Code, Discord, Spotify, Electron apps, Firefox) need environment variables to run natively on Wayland instead of falling back to XWayland. Add a section to `zsh/.zshenv` (or a new `zsh/.zsh_wayland` sourced from `.zshenv` with an `[[ -n "$WAYLAND_DISPLAY" ]]` guard):

    ```zsh
    # Force native Wayland for Electron/Chromium, Firefox, Qt, and GTK
    if [[ -n "$WAYLAND_DISPLAY" ]]; then
        export ELECTRON_OZONE_PLATFORM_HINT=auto
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export GDK_BACKEND=wayland
    fi
    ```

    `ELECTRON_OZONE_PLATFORM_HINT=auto` covers VS Code, Discord, Slack, Spotify, and other Electron apps. `MOZ_ENABLE_WAYLAND=1` covers Firefox. `QT_QPA_PLATFORM=wayland` covers Qt apps (may cause issues with some older Qt5 apps -- remove if an app renders as a black window). `GDK_BACKEND=wayland` covers GTK3/GTK4 apps. All are safe to set when `$WAYLAND_DISPLAY` is set; apps that don't support Wayland will fall back to XWayland automatically.

  - **Git credential helper.** macOS uses the Keychain for `git credential.helper`. On Linux, `libsecret` (GNOME) or `pass` is the equivalent. Without a credential helper, `git push` prompts for credentials on every operation. `setup-terminal.sh` should detect if `git config --global credential.helper` is unset and print a setup hint:

    ```
    Git credential helper is not configured. Consider:
      sudo apt install libsecret-1-0 libsecret-1-dev
      git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
    Or use gh (GitHub CLI): gh auth login
    ```

    This is a one-time per-machine setup; the dotfiles do not force a specific credential helper since the choice is distro- and preference-dependent.

  - **Sway auto-start dependencies.** The Sway config auto-starts `waybar`, `mako`, `nm-applet`, and references `swaybg` for wallpaper. Verify that `get_platform_packages()` includes `waybar`, `mako-notifier`, `network-manager-applet`, and `swaybg` for every Linux distro entry. `packages-linux.txt` already lists these, but the installer function is the authoritative source.

- `install.sh` (root-level installer, NOT `scripts/install.sh` which does not exist)

  - **Fix `post_install()` tmux prefix on all Linux distros.** The `case "$OS"` block under `post_install()` has explicit branches for `linux`, `debian`, `redhat`, and `arch` that all say `Ctrl-b` is the prefix. The tmux config sets `Ctrl-a` unconditionally (line 77 of `.tmux.conf`). Change ALL Linux distro post-install messages to `Prefix + I (Ctrl-a + Shift-i)`, or better, remove the per-distro duplication and use a single platform-based message (`macOS` vs `linux*`) that reads the actual prefix from the tmux config. This is a pre-existing bug that silently wastes users' time across all Linux distros.

  - Verify `install.sh` calls the updated `setup-terminal.sh` correctly and that the Ghostty install path is exercised on Linux. No structural changes expected, but validate during Step 9.

- **Shell completions for new CLI tools.** `bat`, `eza`, `fd-find`, `ripgrep`, `zoxide`, `fzf` all ship shell completions. On macOS, Homebrew auto-installs them. On Linux, they typically need explicit setup via the tool's `--completion` flag. Rather than handling each tool individually (fragile and distro-dependent), add a note to `setup-terminal.sh`'s post-install output directing the user to run each tool's completion setup command if completions don't work out of the box. Example output:

  ```
  Shell completions may need manual setup on Linux. If tab-completion is
  missing for eza, bat, fd, or rg, run:
    eza --completions zsh > ~/.zsh/completions/_eza   (or distro-appropriate path)
    bat --completions zsh > ~/.zsh/completions/_bat
  Or install completions via your package manager (e.g., apt install eza-completions).
  ```

- **Swaylock minimal config.** The `lock` abbreviation wraps `swaylock`. Without a config file, `swaylock` renders an unstyled lock screen. Create `sway/.config/swaylock/config` with a minimal Gruvbox-dark-matching color scheme so the lock screen looks intentional rather than broken. Reference it from the Sway README.

  ```ini
  # Gruvbox Dark color scheme for swaylock
  inside-color=282828
  inside-clear-color=282828
  inside-ver-color=458588
  inside-wrong-color=cc241d
  key-hl-color=b8bb26
  ring-color=665c54
  ring-clear-color=665c54
  ring-ver-color=458588
  ring-wrong-color=cc241d
  text-color=ebdbb2
  text-clear-color=ebdbb2
  text-ver-color=ebdbb2
  text-wrong-color=ebdbb2
  line-color=282828
  separator-color=00000000
  font="IosevkaTerm Nerd Font"
  indicator-radius=100
  indicator-thickness=10
  ```

**Risks.** Ghostty packaging on Linux is newer and may not be available in all distro repositories. The installer's fallback chain handles this per-distro. `tmux-sessionizer` requires network access to clone; the installer degrades gracefully with a warning. Starship's `build-configs.sh` may fail on minimal systems without `cat`/`sed`; this is unlikely on any system that already has zsh installed. `brightnessctl` requires the user to be in the `video` group on some distros; mention this in the post-install output if `brightnessctl` is installed but the user lacks group membership.

---

### 8. Modernize Sway Config + Quick-Terminal Binding

**Why.** `sway/.config/sway/config` already exists (7,777 bytes) but is a stock/default Sway config (opens with "Copy this to ~/.config/sway/config and edit it to your liking"). It lacks vim-style navigation, a Gruvbox color scheme, quick-terminal binding, and uses `foot` as the default terminal. It needs modernization to match the dotfiles' conventions and the Ghostty-first approach.

**What to change.**

- `sway/.config/sway/config` -- rewrite the existing config to be a proper dotfiles config. Key elements to change:

  - **`$term` assignment:** Change `set $term foot` (line 17) to `set $term ghostty`. The `$term` assignment must be placed **after** the `include` directives so distro snippets cannot override it. The current position (line 17, before the includes on lines 21 and 233) is vulnerable to silent override by `/etc/sway/config.d/` snippets. Move it to the bottom of the config, after all includes.

  - **Color scheme:** Replace the default color configuration with Gruvbox Dark colors for `client.focused`, `client.unfocused`, `client.focused_inactive`, `client.urgent`, and `client.placeholder`.

  - **Window behavior:** Add `default_border pixel 3` and `focus_follows_mouse no` for a vim-like experience.

  - **Font:** Set `font pango:IosevkaTerm Nerd Font 10` for title bars.

  - **Quick-terminal:** Add `bindsym $mod+grave exec ghostty --quick-terminal`.

  - **Vim-style navigation:** Add vim-style directional bindings (`$left h`, `$down j`, `$up k`, `$right l`) and corresponding workspace/container movement bindings from the README.

  - **Auto-start:** Keep the existing `exec waybar`, `exec mako`, `exec nm-applet` lines. Add:
    - `exec swaybg -i ~/.config/sway/wallpaper` (if a wallpaper file exists; otherwise commented out).
    - `exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1` (or the distro-appropriate polkit agent path; enables GUI auth dialogs).
    - `exec swayidle -w timeout 300 'swaylock -f' timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' before-sleep 'swaylock -f'` (auto-lock after 5 min idle, screen off after 10 min).

  - **Keybindings:** Preserve the existing media key bindings, workspace switching, and container management from the stock config. Add any documented in `sway/README.md` that are missing.

  Include ordering in the rewritten config:

  ```ini
  # ... (all settings, colors, keybindings) ...

  # Include system config snippets (distro packages may override $term here)
  include /etc/sway/config-vars.d/*
  include /etc/sway/config.d/*

  # Re-assign $term after includes so distro snippets cannot override it
  set $term ghostty
  ```

  The `$term` assignment appears twice in the config: once early (for use by keybindings before the includes) and once at the bottom after includes (as the final override). Distro packages can drop snippets in `/etc/sway/config.d/` that set `$term` to `foot` or `alacritty`. The final assignment prevents silent override.

- `sway/README.md` -- update keybindings table, default applications, and dependency list to reference Ghostty instead of Foot. Add quick-terminal binding to the keybindings table. Update the `$term` reference in the "Default Applications" code block from `foot` to `ghostty`.

- `ghostty/.config/ghostty/config`
  - The macOS `global:super+backquote` binding (line 210) is silently ignored on Linux; leave it as-is.
  - The `quick-terminal-position`, `quick-terminal-size`, and `quick-terminal-animation-duration` settings (lines 273-275) apply on Linux too -- no change needed.

- `scripts/setup-terminal.sh`
  - After installing Ghostty on Linux, print compositor-specific binding instructions:
    - **Sway:** `bindsym $mod+grave exec ghostty --quick-terminal`
    - **GNOME:** Settings > Keyboard > Keyboard Shortcuts > Custom Shortcuts
    - **KDE:** System Settings > Shortcuts > Custom Shortcuts > New > Global Shortcut

**Risks.** Medium. The Sway config is being rewritten in-place, which requires preserving existing media key bindings, workspace management, and output configuration from the current stock config. Existing Linux users with a stowed `sway` package will get the new config on their next `git pull && stow sway`, which could overwrite local customizations. See Step 9 for migration detection.

---

### 9. Delete wezterm/ + linux/ + Update READMEs + Swaylock Config + Migration Path

**Why.** The `wezterm/` directory is a stale Stow package replaced by Ghostty on macOS but never cleaned up. The `linux/` package contains only Uniclip (a clipboard sync daemon) which is now redundant -- Wayland compositors and `wl-clipboard` provide built-in XWayland clipboard bridging. Additionally, `foot/README.md` and `sway/README.md` still document Foot-first workflows. A migration path for existing Linux users is needed so they aren't surprised by the changes.

**What to change.**

- `wezterm/` -- delete the entire directory. Contains `.wezterm.lua` (28KB config), `README.md`, and `.stow-local-ignore`. The package was replaced by Ghostty on macOS but never cleaned up. If a user still wants WezTerm, `git log -- wezterm/` recovers it.

- `linux/` -- delete the entire directory. Contains `uniclip.service` (systemd user service for clipboard synchronization) and `install-uniclip-service.sh`. Rationale: with `wl-clipboard` providing `wl-copy`/`wl-paste` and modern Wayland compositors (wlroots, Mutter) providing built-in XWayland clipboard bridging, Uniclip is redundant. If a user still wants Uniclip, `git log -- linux/` recovers it.

- `foot/README.md` -- update to note Foot is now a fallback terminal, not the primary. Change the comparison table to reflect that Ghostty is the primary terminal on both platforms, with Foot as a Wayland-native backup.

- `sway/README.md` -- update keybindings table, default applications, and dependency list to reference Ghostty instead of Foot. Add quick-terminal binding to the keybindings table. Update the `$term` reference in the "Default Applications" code block from `foot` to `ghostty`.

- `sway/.config/swaylock/config` (new file) -- create with Gruvbox-dark-matching colors (specified in Step 7 above) so the lock screen looks intentional rather than broken. Reference it from the Sway README.

- **Migration path for existing Linux users.** `setup-terminal.sh` should detect prior-state markers and surface them:

  1. **Foot stow detection:** If `~/.config/foot/foot.ini` exists as a symlink (i.e., stow-managed), print: "Foot is currently your stowed terminal. Ghostty is now the primary terminal. To switch: `stow -D foot && stow ghostty`. Foot remains available as a fallback."
  2. **xclip-only clipboard detection:** If `$WAYLAND_DISPLAY` is set and `~/.config/tmux/scripts/clipboard-copy.sh` doesn't exist yet, print: "Wayland detected -- the new clipboard scripts (Step 4) handle clipboard under Wayland. After stowing the updated tmux package, run: `chmod +x ~/.config/tmux/scripts/clipboard-*.sh`."
  3. **tmux-sessionizer detection:** If `prefix+T` was previously failing (detected by checking for tmux config with the sessionizer binding but no binary on PATH), print the install URL.
  4. **Stale wezterm stow:** If `~/.config/wezterm/` exists as a symlink, print: "The wezterm package has been removed from the repo. Consider: `stow -D wezterm`."
  5. **Stale linux/uniclip stow:** If `~/.config/systemd/user/uniclip.service` exists as a symlink, print: "The linux/uniclip package has been removed from the repo. Consider: `stow -D linux`. The service will stop on next reboot; wl-clipboard provides equivalent functionality."
  6. **Hand-edited Sway config detection:** If `~/.config/sway/config` exists and is NOT a symlink (i.e., hand-edited, not stow-managed), print: "A hand-edited Sway config was detected at ~/.config/sway/config. The updated dotfiles Sway config will overwrite it when you `stow sway`. Back up your local config first: `cp ~/.config/sway/config ~/.config/sway/config.bak`."

**Risks.** Medium. The Sway config rewrite (Step 8) will overwrite hand-edited configs on the next `stow sway`. The migration detection above catches un-stowed configs and warns, but cannot detect local modifications to an already stowed config (git would flag a merge conflict). Deletions are recoverable via git. README changes are non-functional. Swaylock config is a new file; safe.

---

## Implementation Order

| # | AP Ref | Action | Files Touched | Effort |
|---|---|---|---|---|---|
| 1 | AP 3 (functions) | Create `__pkmgr()` helper + Linux functions | `zsh/functions/linux.zsh` (new) | L |
| 2 | AP 2 (abbrevs) | Expand Linux abbreviations (includes cpb shadow, clipboard abbrevs, .zsh_cross_platform reconciliation, modern tools, system maintenance) | `zsh/abbreviations/linux.zsh` | M |
| 3 | AP 4 (clipboard) | Fix tmux clipboard for Wayland (includes copy.sh/copy-strip-prompt.sh update, clipboard-copy/paste.sh creation, Uniclip reconciliation) | `tmux/.tmux.conf`, `tmux/.config/tmux/scripts/clipboard-copy.sh` (new), `tmux/.config/tmux/scripts/clipboard-paste.sh` (new), `tmux/.config/tmux/scripts/copy.sh`, `tmux/.config/tmux/scripts/copy-strip-prompt.sh` | M |
| 4 | AP 1 (Ghostty) | Add Linux defaults to Ghostty main config + fix zsh path + update header + super key unbind + ctrl+shift remap | `ghostty/.config/ghostty/config` | M |
| 5 | AP 1 (Ghostty) | Rewrite config.local.template (OS-agnostic) | `ghostty/.config/ghostty/config.local.template` | S |
| 6 | AP 5 (theme) | Theme auto-detect (externalize to script, refactor both tmux blocks, add GNOME/KDE/GTK_THEME detection) | `tmux/.config/tmux/scripts/theme-detect.sh` (new), `tmux/.tmux.conf` | M |
| 7 | AP 7 (packages) | Packages + installer + setup (Ghostty install with distro-specific chain, get_platform_packages() update, tmux-sessionizer, Starship build + binary, zsh-abbr distro-native check + loader path fix, foot transition, btop/lazygit warnings, Wayland env vars + Qt/GDK, git credential helper, completions dir, swaylock config, migration detection, brightnessctl group, polkit, swayidle, xdg-desktop-portal) | `packages-linux.txt`, `scripts/setup-packages.sh`, `scripts/setup-terminal.sh`, `install.sh`, `zsh/.zsh_completions` (new), `zsh/.zshenv`, `zsh/.zshrc`, `zsh/abbreviations/_init.zsh` | L |
| 8 | AP 8 (Sway) | Sway config modernization + quick-terminal binding + $term fix + include ordering + swayidle auto-lock + polkit agent auto-start | `sway/.config/sway/config` (rewrite), `sway/README.md`, `ghostty/.config/ghostty/config` | M |
| 9 | AP 9 (cleanup) | Delete wezterm/ + linux/ + update READMEs + swaylock config + migration path (6 checks) | `wezterm/` (delete), `linux/` (delete), `foot/README.md`, `sway/README.md`, `sway/.config/swaylock/config` (new) | M |
| 10 | AP 7 (installer) | Fix install.sh post_install() wrong tmux prefix on Linux (all distro branches) | `install.sh` | XS |
| 11 | -- | Validate end-to-end (includes VM/container testing, KDE theme, super key conflicts, Neovim clipboard version) | See checklist below | S |

**Dependencies:**

- Steps 1 and 3 can be done in parallel (different files, no dependencies).
- Step 2 depends on Step 1 (needs `__pkmgr`).
- Steps 4, 5, and 6 can be done in parallel (different files).
- Step 6 touches `tmux/.tmux.conf` -- it **conflicts** with Step 3 which also touches `tmux/.tmux.conf`. Do Step 3 first, then Step 6, or combine them.
- Step 7 depends on Step 4 (needs to know Ghostty config changes are settled) and Step 6 (needs theme-detect.sh as the canonical detection script).
- Step 8 depends on Step 4 (Ghostty on PATH) and Step 7 (swaylock config created, packages updated including swayidle/polkit/xdg-desktop-portal). The Sway config exists but is stock; the rewrite should preserve existing media keys, workspace management, and output configuration.
- Steps 9 and 10 are independent and can be done any time.
- Step 11 is last.

**Total estimated effort:** ~12-15 hours (up from original 8-9; super key conflict resolution, KDE theme detection, Uniclip package removal, `get_platform_packages()` xclip fix, expanded `setup_zsh_abbr()` check, and VM testing strategy add ~4-6 hours on top of the prior estimate).

---

### 11. End-to-End Validation Checklist

Run on a Linux machine with the updated dotfiles stowed. For distro-specific testing, a VM or container (podman/docker with `--privileged` for systemd) is recommended -- see the expanded distro coverage notes in Step 7. At minimum, test on one Debian-based and one Arch-based system.

**Ghostty terminal:**
- [ ] Ghostty launches and drops into tmux (`zsh -l -c "exec tmux new-session -A -s main"`)
- [ ] `window-theme = dark` is applied (verify with `ghostty +show-config`)
- [ ] `gtk-adwaita` auto-detection works (enabled on GNOME, disabled on Sway/KDE)
- [ ] `font-size = 13` renders legibly at 1080p/1440p
- [ ] Quick-terminal toggle works (`$mod+grave` on Sway; or check printed instructions for other compositors)
- [ ] Non-conflicting `super` keybindings (`super+alt+left`, `super+r`, `super+g`, `super+m`) work under Sway and under a non-intercepting WM
- [ ] Conflicting `super` keys are **unbound** on Linux: `super+1-9`, `super+d`, `super+arrows`, `super+shift+arrows` do NOT reach tmux (verify with `ghostty +show-config` or by pressing them and confirming no action)
- [ ] `ctrl+shift` alternatives (`ctrl+shift+d`, `ctrl+shift+1-9`, `ctrl+shift+arrows`) work correctly in tmux under both Sway and a non-intercepting WM
- [ ] `ctrl+tab` / `ctrl+shift+tab` switch tmux windows

**tmux clipboard:**
- [ ] Text selected in copy-mode-vi (y) copies to Wayland clipboard (test: paste into a GTK/Qt app)
- [ ] `prefix+Y` copies the current pane content to clipboard
- [ ] `prefix+]` pastes from system clipboard
- [ ] Double-click word selection copies to clipboard
- [ ] Triple-click line selection copies to clipboard
- [ ] extrakto (`prefix+Tab`) selected text copies to clipboard
- [ ] Clipboard copy works with `WAYLAND_DISPLAY` unset (OSC 52 fallback): launch tmux from a TTY or `unset WAYLAND_DISPLAY`, copy text, paste in a GUI app
- [ ] `clipboard-paste.sh` prints a clear diagnostic when no paste tool is available

**tmux theme:**
- [ ] `$THEME_MODE=light` in shell triggers light theme after re-attach
- [ ] `$THEME_MODE=dark` triggers dark theme
- [ ] No `$THEME_MODE` set: dark fallback on Linux (unless GNOME light mode is detected)
- [ ] CPU color bar uses consistent theme (same dark/light as status bar)
- [ ] GNOME light mode detected correctly (if running GNOME with light color-scheme)
- [ ] KDE light mode detected correctly via `kreadconfig6` (if running KDE 6 with light ColorScheme)
- [ ] `$GTK_THEME` substring detection works (light theme if GTK_THEME contains "light")

**Abbreviations:**
- [ ] `update` runs the correct package manager command (apt/dnf/pacman)
- [ ] `ls` uses `eza` if installed, falls back to `command ls`
- [ ] `cat` uses `bat`/`batcat` if installed
- [ ] `fd` uses `fd`/`fdfind` if installed
- [ ] `rg` uses `ripgrep` if installed
- [ ] `cpb` pipes stdin to Wayland/X11 clipboard
- [ ] `screenshot` captures screen (both `grim -g "$(slurp)"` and plain `grim`)
- [ ] `lock` triggers `loginctl lock-session` or `swaylock`
- [ ] `sys-info` outputs system details

**Functions:**
- [ ] `__pkmgr update` updates via the detected package manager
- [ ] `__pkmgr install <pkg>` installs a package
- [ ] `__pkmgr search <term>` searches packages
- [ ] `cpu-temp` outputs CPU temperature data
- [ ] `wifi-scan` lists available networks
- [ ] `brightness get` / `brightness set 50` works (if brightnessctl is installed)

**Shell integration:**
- [ ] `Ctrl+R` opens fzf history search
- [ ] `z <dir>` jumps with zoxide
- [ ] `~/.zsh/completions/` is on `$fpath`
- [ ] tab-completion works for common commands

**Tmux popups:**
- [ ] `prefix+G` opens lazygit (or fails with a clear install message)
- [ ] `prefix+M` opens btop (or fails with a clear install message)
- [ ] `prefix+T` runs tmux-sessionizer (or warns if missing)
- [ ] `tmux-sessionizer` has no macOS-isms (grep for `pbcopy`, `pbpaste`, `/Users/`, `brew`, `osascript`; all must be absent)

**Installer:**
- [ ] `install.sh` post-install message says `Ctrl-a + Shift-i` (not `Ctrl-b`)
- [ ] `setup_ghostty()` on Linux attempts native package install, falls back to GitHub release, then Flatpak
- [ ] `get_platform_packages()` includes all new packages for the detected distro
- [ ] `starship/build-configs.sh` runs and produces a valid `starship.toml`
- [ ] Clipboard scripts in `~/.config/tmux/scripts/` have execute bit set
- [ ] Migration warnings fire correctly (Foot stow, xclip-only, tmux-sessionizer missing, wezterm stow, uniclip stow, hand-edited Sway config)
- [ ] `zsh-abbr` distro-native check skips clone when `abbr` is already on PATH
- [ ] `tmux-sessionizer` post-install message mentions `hash -r` for current shell sessions

**Sway config (if applicable):**
- [ ] `$mod+Return` opens Ghostty
- [ ] `$mod+d` opens wmenu-run
- [ ] `$mod+grave` toggles quick terminal
- [ ] Window borders use Gruvbox Dark colors
- [ ] vim-style navigation (`$mod+h/j/k/l`) works
- [ ] Distro snippets do NOT override `$term` (verify with `swaymsg -t get_config | grep '\$term'`)
	- [ ] `swayidle` auto-locks after 5 min idle (verify with `swaymsg -t get_runtime | grep idle`)
	- [ ] Polkit agent is running (`pgrep polkit-gnome` or equivalent)
	- [ ] `$mod+grave` toggles quick terminal

---

## Out of Scope (Intentional)

- **Window manager parity.** Sway (auto-tiling) and macOS Rectangle (manual snapping) are fundamentally different paradigms. Accepting this difference reduces friction more than forcing one to emulate the other.
- **Finder/file-manager integration on Linux.** Nautilus/Files scripts and Thunar custom actions are distro- and DE-specific. Document the pattern but do not build a one-size-fits-all solution.
- **Status bar parity.** Waybar on Linux and SketchyBar on macOS serve the same purpose but with completely different configuration models. Waybar uses its default config (no custom waybar config exists in the repo); SketchyBar config does exist. Bringing these to parity is a significant effort and intentionally deferred.
- **Apple Silicon-specific abbreviations.** No Linux equivalents needed (arch detection, Rosetta checks, Xcode tools).
- **macOS-specific functions.** `ql()` (QuickLook) has no Linux equivalent and is not worth emulating.
- **Ghostty Nerd Font codepoint maps.** The extensive `font-codepoint-map` block in the Ghostty config (lines 52-68) is platform-agnostic and works identically on Linux -- no changes needed.
- **Full swaylock theming.** A minimal Gruvbox-dark-matching config is included (Step 9) so the lock screen doesn't look broken. Full wallpaper integration, blur, and clock styling are intentionally deferred.
- **Waybar custom configuration.** The Sway config auto-starts Waybar, but no custom waybar config exists in the repo. Creating and maintaining one across distros is deferred.

- **Mako (notification daemon) configuration.** The Sway config auto-starts `mako` but no `mako/.config/mako/config` exists in the repo. Notifications render with stock styling (light background, default font). Same situation as Waybar -- intentionally deferred; users can create their own `~/.config/mako/config`.

- **Non-primary distro coverage.** The plan adds full package lists for Debian/Ubuntu, Arch, Fedora/RHEL, and openSUSE. Void, Alpine, Gentoo, Solus, and Clear Linux get `ghostty` + `wl-clipboard` + core modern tools only. Several packages (`slurp`, `lm-sensors`, `glow`, `btop`, `lazygit`) may be unavailable or named differently on these distros. The parity gap narrows but does not fully close on these platforms. Users on these distros should refer to their distro's package registry for equivalents.

- **Font installation automation on Linux.** The status table rates fonts at 100% parity because both platforms use the same Nerd Fonts, but there is no automated installation mechanism for Linux. On macOS, Homebrew casks handle this (`font-iosevka-nerd-font`). On Linux, the user must manually download font files, place them in `~/.local/share/fonts/`, and run `fc-cache -fv`. The plan adds `fontconfig` (for `fc-cache`) to the package list but does not add a font download/install step. This is intentionally left to the user; font preference is too personal to automate.

- **swaybg/wallpaper handling.** The Sway config references wallpaper (`output * bg ... fill`) but no wallpaper file is included in the repo. On a fresh Linux install, `swaybg` may show a black background. Users should set their own wallpaper path in the Sway config or via `~/.config/sway/config.local`.

- **Neovim Wayland clipboard verification.** The plan adds `wl-clipboard` to the package list and notes that Neovim's clipboard integration may need `clipboard=unnamedplus` (see Step 4's Neovim note), but does not extensively test or modify the Neovim config. The existing Neovim config should be verified during Step 11 validation.

- **Flatpak Ghostty divergence.** If Ghostty is installed via Flatpak, the binary path and GTK sandboxing differ from native packages. See the expanded caveat in Step 6 (Sway quick-terminal binding, Sway `$mod+Return` binding, GTK theme access). Users on the Flatpak path must adjust keybindings and `$term` manually.

- **Ghostty GTK CSS customization.** Ghostty on Linux supports `gtk-css` for custom window styling. The plan intentionally leaves `gtk-adwaita` unset so Ghostty auto-detects GNOME. Full CSS theming is deferred.
- **Shell completion auto-installation.** The plan creates the completions directory and sets up `$fpath`, but does not run each tool's `--completions` flag to generate completion files. Automatically detecting the correct system completion path and running each tool is fragile across distros and intentionally left to the user.

- **XWayland clipboard bridging.** The clipboard scripts select `wl-copy` (Wayland) or `xclip` (X11) based on `$WAYLAND_DISPLAY`. They do not handle the edge case where tmux captures text from an XWayland app and the user pastes into a Wayland-native app (or vice versa). This is niche and well-handled by `wl-clipboard`'s built-in XWayland bridging in most compositors.

- **SSH agent / keychain parity.** macOS Keychain integrates with `ssh-agent`. On Linux, `gnome-keyring` or `ssh-agent` + `keychain` serve the same role but with different setup steps. This is a well-documented per-distro concern and not specific to the dotfiles configuration.

- **Bluetooth and audio device abbreviations.** macOS has `bt-devices`, `bt-connect`, `airpods-battery`, etc. Linux equivalents exist (`bluetoothctl`, `pactl`) but the UX is fundamentally different (CLI pairing vs. system menu). Not worth abbreviating given the low frequency of use.

