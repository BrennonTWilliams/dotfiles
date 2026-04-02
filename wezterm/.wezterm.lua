-- ==============================================================================
-- WezTerm Terminal Configuration
-- ==============================================================================
-- Comprehensive configuration for optimal macOS integration with zsh shell
-- Mirrors tmux configuration with Gruvbox theme and aligned keybindings
-- ==============================================================================

local wezterm = require 'wezterm'
local resurrect = wezterm.plugin.require 'https://github.com/MLFlexer/resurrect.wezterm'

local config = wezterm.config_builder()

-- ============================================
-- Font Configuration
-- ============================================

-- Primary font family (IosevkaTerm Nerd Font for CLI compatibility)
config.font = wezterm.font('IosevkaTerm Nerd Font')
config.font_size = 16.0

-- ============================================
-- Window Configuration
-- ============================================

-- Window padding for better readability
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- Initial window dimensions
config.initial_cols = 120
config.initial_rows = 40

-- Window decorations (native macOS style)
config.window_decorations = 'RESIZE'

-- Confirm before closing a window (matches Ghostty confirm-close-surface behavior)
config.window_close_confirmation = 'AlwaysPrompt'

-- ============================================
-- Tab Bar Configuration
-- ============================================

-- Auto-hide tab bar when only one tab (matches Ghostty window-show-tab-bar = auto)
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
-- Retro (flat) tab bar unlocks full tab_bar color control via config.colors.tab_bar
config.use_fancy_tab_bar = false
-- Retro tabs default to 16 chars; 128 gives enough room for long process names
config.tab_max_width = 256

-- ============================================
-- Cursor Configuration
-- ============================================

-- Block cursor without blinking (matches Ghostty cursor-style = block, cursor-style-blink = false)
config.default_cursor_style = 'SteadyBlock'

-- ============================================
-- macOS-Specific Settings
-- ============================================

-- Option key acts as Alt/Meta (matches Ghostty macos-option-as-alt = true)
-- false = send ESC sequences; true = send composed characters (accents) — we want ESC
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- IME enabled: required for Apple Dictation (NSTextInputClient channel).
-- NOTE: Dictation still silently fails due to a WezTerm upstream bug — selectedRange()
-- returns NSNotFound instead of NSRange(0,0). Tracked in WezTerm PR #7453/#7536.
-- When that fix lands in a stable release, Dictation will work without further changes.
-- Backspace is explicitly bound below (SendString '\x7f') to bypass the
-- IME composition pipeline and prevent backspace-commits-composition regressions.
config.use_ime = true

-- ============================================
-- Terminal Settings
-- ============================================

-- Terminal type (matches Ghostty term = xterm-256color)
config.term = 'xterm-256color'

-- Kitty keyboard protocol: extended key encoding for Neovim and modern terminal apps
-- Allows apps to distinguish Esc vs Ctrl+[, Tab vs Ctrl+I, Enter vs Ctrl+M, etc.
-- Requires apps that opt in (Neovim 0.10+); falls back gracefully for others.
-- Disable if any tool shows unexpected key output.
config.enable_kitty_keyboard = true

-- ============================================
-- Selection and Clipboard
-- ============================================

-- Copy on select behavior (matches Ghostty copy-on-select = true)
config.selection_word_boundary = " \t\n{}[]()\"'`"

-- ============================================
-- Theme: Auto Dark/Light via macOS Appearance
-- ============================================
-- Uses wezterm.gui.get_appearance() to detect macOS dark/light mode.
-- Dark: Gruvbox dark palette (deep #1d2021 bg for reduced eye strain)
-- Light: Gruvbox light palette (mirrors tmux THEME_MODE=light colors)

local function get_colors()
  local appearance = wezterm.gui.get_appearance()
  if appearance:find 'Dark' then
    return {
      foreground = '#ebdbb2',
      background = '#1d2021',
      cursor_bg = '#ebdbb2',
      cursor_fg = '#1d2021',
      cursor_border = '#ebdbb2',
      selection_fg = '#ebdbb2',
      selection_bg = '#458588',
      scrollbar_thumb = '#504945',
      -- Active pane border matches tmux active border color (#b8bb26 bright green)
      split = '#b8bb26',

      ansi = {
        '#504945', -- black (dark2)
        '#fb4934', -- red
        '#98971a', -- green
        '#d79921', -- yellow
        '#458588', -- blue
        '#b16286', -- magenta
        '#689d6a', -- cyan
        '#a89984', -- white
      },
      brights = {
        '#928374', -- bright black
        '#fb4934', -- bright red
        '#b8bb26', -- bright green
        '#fabd2f', -- bright yellow
        '#83a598', -- bright blue
        '#d3869b', -- bright magenta
        '#8ec07c', -- bright cyan
        '#ebdbb2', -- bright white
      },
      tab_bar = {
        background = '#1d2021',
        active_tab = {
          bg_color  = '#458588',
          fg_color  = '#1d2021',
          intensity = 'Bold',
        },
        inactive_tab = {
          bg_color = '#3c3836',
          fg_color = '#a89984',
        },
        inactive_tab_hover = {
          bg_color = '#504945',
          fg_color = '#ebdbb2',
        },
        new_tab = {
          bg_color = '#1d2021',
          fg_color = '#a89984',
        },
        new_tab_hover = {
          bg_color = '#3c3836',
          fg_color = '#ebdbb2',
        },
      },
    }
  else
    -- Gruvbox Light — mirrors tmux light theme values
    return {
      foreground = '#3c3836',
      background = '#f9f5d7',
      cursor_bg = '#3c3836',
      cursor_fg = '#f9f5d7',
      cursor_border = '#3c3836',
      selection_fg = '#3c3836',
      selection_bg = '#bdae93',
      scrollbar_thumb = '#bdae93',
      -- Active pane border: tmux active border in light mode
      split = '#79740e',

      ansi = {
        '#3c3836', -- black
        '#cc241d', -- red
        '#6f6908', -- green   (was #79740e at 4.41:1 — just below AA; #6f6908 → 5.15:1)
        '#886000', -- yellow  (5.14:1 — dark ochre; Gruvbox palette yellows all fail AA on cream bg)
        '#076678', -- blue    (was #458588 neutral; faded variant has ~6.0:1 vs ~3.8:1)
        '#8f3f71', -- magenta (was #b16286 neutral; faded variant has ~6.1:1 vs ~3.8:1)
        '#3d7253', -- cyan    (was #427b58 at 4.53:1 — too close to floor; #3d7253 → 5.11:1)
        '#5a524a', -- white   (was #7c6f64; darkened 1 stop to ~6.5:1 vs ~4.4:1)
      },
      brights = {
        '#796c61', -- bright black  (was #7c6f64 at 4.42:1 — just below AA; #796c61 → 4.62:1)
        '#9d0006', -- bright red
        '#6f6908', -- bright green  (matches ansi green; 5.15:1)
        '#9a6208', -- bright yellow  (was #b57614 at 3.43:1 — AA fail; #9a6208 → 4.63:1)
        '#076678', -- bright blue
        '#8f3f71', -- bright magenta
        '#3d7253', -- bright cyan
        '#3c3836', -- bright white
      },
      tab_bar = {
        background = '#f9f5d7',
        active_tab = {
          bg_color  = '#076678',
          fg_color  = '#f9f5d7',
          intensity = 'Bold',
        },
        inactive_tab = {
          bg_color = '#ebdbb2',
          fg_color = '#3c3836',
        },
        inactive_tab_hover = {
          bg_color = '#d5c4a1',
          fg_color = '#3c3836',
        },
        new_tab = {
          bg_color = '#f9f5d7',
          fg_color = '#7c6f64',
        },
        new_tab_hover = {
          bg_color = '#ebdbb2',
          fg_color = '#3c3836',
        },
      },
    }
  end
end

config.colors = get_colors()

-- Dim inactive panes visually (mirrors tmux inactive border dimming)
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.7,
}

-- ============================================
-- Key Bindings
-- ============================================

config.keys = {
  -- Shift+Enter: send newline (0x0a) so apps can distinguish it from plain Enter (0x0d)
  {
    key = 'Return',
    mods = 'SHIFT',
    action = wezterm.action.SendString '\n',
  },
  -- Explicit backspace: bypass macOS IME which can intercept Backspace
  -- and commit composition as a space. SendString injects raw bytes
  -- directly into the pane, skipping WezTerm's key -> IME pipeline.
  {
    key = 'Backspace',
    mods = '',
    action = wezterm.action.SendString '\x7f',
  },
  -- Copy/Paste with Cmd+C/V
  {
    key = 'C',
    mods = 'CMD',
    action = wezterm.action.CopyTo 'Clipboard',
  },
  {
    key = 'V',
    mods = 'CMD',
    action = wezterm.action.PasteFrom 'Clipboard',
  },

  -- Config reload (fixes README claim; WezTerm also auto-reloads on save)
  {
    key = 'R',
    mods = 'CMD',
    action = wezterm.action.ReloadConfiguration,
  },

  -- CMD+SHIFT+R: rename current tab (mirrors tmux prefix+,)
  {
    key = 'R',
    mods = 'CMD|SHIFT',
    action = wezterm.action.PromptInputLine {
      description = 'Rename tab:',
      action = wezterm.action_callback(function(window, _, line)
        if line then window:active_tab():set_title(line) end
      end),
    },
  },

  -- CMD+Enter: toggle fullscreen (mirrors Ghostty default)
  { key = 'Return', mods = 'CMD', action = wezterm.action.ToggleFullScreen },

  -- Tab management
  {
    key = 'T',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
  {
    key = 'W',
    mods = 'CMD|SHIFT',
    action = wezterm.action.EmitEvent 'close-window',
  },
  {
    key = 'Tab',
    mods = 'CTRL',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'Tab',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTabRelative(-1),
  },

  -- Tab navigation with Cmd+number
  {
    key = '1',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(0),
  },
  {
    key = '2',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(1),
  },
  {
    key = '3',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(2),
  },
  {
    key = '4',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(3),
  },
  {
    key = '5',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(4),
  },
  {
    key = '6',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(5),
  },
  {
    key = '7',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(6),
  },
  {
    key = '8',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(7),
  },
  {
    key = '9',
    mods = 'CMD',
    action = wezterm.action.ActivateTab(-1),
  },

  -- Split panes
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'D',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- CMD+SHIFT+Z: toggle pane zoom (mirrors tmux prefix+z)
  { key = 'z', mods = 'CMD|SHIFT', action = wezterm.action.TogglePaneZoomState },

  -- Pane navigation: Cmd+Alt+Arrow (original) + Alt+Arrow (tmux M-Arrow muscle memory)
  {
    key = 'LeftArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  -- CMD+SHIFT+Arrow: resize current pane (5-cell increments)
  { key = 'UpArrow',    mods = 'CMD|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up',    5 } },
  { key = 'DownArrow',  mods = 'CMD|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down',  5 } },
  { key = 'LeftArrow',  mods = 'CMD|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left',  5 } },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },

  -- ALT+Arrow: word navigation (readline ESC+b / ESC+f)
  -- CMD+ALT+Arrow handles pane switching (see above)
  { key = 'LeftArrow',  mods = 'ALT', action = wezterm.action.SendString '\x1bb' },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.SendString '\x1bf' },

  -- CMD+Arrow: line navigation and scrollback (macOS Terminal.app conventions)
  { key = 'LeftArrow',  mods = 'CMD', action = wezterm.action.SendString '\x1bOH' },
  { key = 'RightArrow', mods = 'CMD', action = wezterm.action.SendString '\x1bOF' },
  { key = 'UpArrow',    mods = 'CMD', action = wezterm.action.ScrollByPage(-1) },
  { key = 'DownArrow',  mods = 'CMD', action = wezterm.action.ScrollByPage(1) },

  -- CMD+Backspace: delete to beginning of line (macOS convention, mirrors Ghostty default)
  -- Sends \x15 (Ctrl+U / unix-line-discard) which readline/zsh interpret as kill-line.
  { key = 'Backspace', mods = 'CMD', action = wezterm.action.SendString '\x15' },

  -- Copy mode: Cmd+[ mirrors tmux `prefix + [` to enter vi copy mode
  -- WezTerm copy mode uses vi keys by default (v=select, y=copy, q=quit)
  {
    key = '[',
    mods = 'CMD',
    action = wezterm.action.ActivateCopyMode,
  },

  -- Font size
  {
    key = '=',
    mods = 'CMD',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = '-',
    mods = 'CMD',
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = '0',
    mods = 'CMD',
    action = wezterm.action.ResetFontSize,
  },

  -- Clear scrollback and screen
  {
    key = 'K',
    mods = 'CMD',
    action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
  },

  -- Search
  {
    key = 'F',
    mods = 'CMD',
    action = wezterm.action.Search 'CurrentSelectionOrEmptyString',
  },

  -- CMD+Y: Quick Select — highlights URLs/hashes/paths for instant copy (WezTerm-native)
  -- Y for "yank"; type prefix of highlighted text to copy without entering copy mode
  { key = 'y', mods = 'CMD', action = wezterm.action.QuickSelect },

  -- CMD+P: command palette — fuzzy search tabs, panes, workspaces, commands
  { key = 'p', mods = 'CMD', action = wezterm.action.ActivateCommandPalette },

  -- CMD+SHIFT+S: manually save current workspace state (resurrect.wezterm)
  -- Must call write_current_state in addition to save_state so that
  -- resurrect_on_gui_startup knows which workspace to restore on next launch.
  {
    key = 'S',
    mods = 'CMD|SHIFT',
    action = wezterm.action_callback(function(win, _)
      local workspace = wezterm.mux.get_active_workspace()
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
      resurrect.state_manager.write_current_state(workspace, 'workspace')
    end),
  },
  -- CMD+SHIFT+L: fuzzy-pick a saved session to restore (resurrect.wezterm)
  {
    key = 'L',
    mods = 'CMD|SHIFT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, _)
        local session_type = string.match(id, '([a-z]+)/.+')
        local state = resurrect.state_manager.load_state(id, session_type)
        if session_type == 'workspace' then
          resurrect.workspace_state.restore_workspace(state, { window = win:mux_window() })
        elseif session_type == 'window' then
          resurrect.window_state.restore_window(win:mux_window(), state)
        elseif session_type == 'tab' then
          resurrect.tab_state.restore_tab(win:active_tab(), state)
        end
      end)
    end),
  },
}

-- ============================================
-- Mouse Bindings
-- ============================================

-- Copy on select (matches Ghostty behavior)
config.mouse_bindings = {
  -- Copy selection to clipboard on release
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  -- Open links with Cmd+Click
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- ============================================
-- Bell Configuration
-- ============================================

config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 75,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}

-- ============================================
-- Performance Settings
-- ============================================

config.front_end = 'WebGpu'
config.max_fps = 120
config.enable_scroll_bar = false

-- Align scrollback with tmux (tmux default: 50,000 lines)
config.scrollback_lines = 50000

-- ============================================
-- Shell Integration
-- ============================================

-- Explicit zsh login shell (matches Ghostty command = /bin/zsh)
-- Note: pane splits inherit cwd automatically when zsh sets OSC 7 in PROMPT
config.default_prog = { '/bin/zsh', '-l' }

-- ============================================
-- Environment Variables
-- ============================================

-- Explicit truecolor hint (matches Ghostty env = COLORTERM=truecolor)
config.set_environment_variables = {
  COLORTERM = 'truecolor',
}

-- ============================================
-- Session Persistence
-- ============================================
-- resurrect.wezterm: auto-saves workspace/tab/pane state every 5 minutes.
-- On next launch, gui-startup restores the last saved session automatically.
-- Plugin is cloned to ~/.local/share/wezterm/plugins/ on first use.
-- State files (JSON) live in the plugin's data directory within that path.

-- Auto-save every 5 minutes
resurrect.state_manager.periodic_save {
  interval_seconds = 300,
  save_workspaces = true,
  save_windows = true,
  save_tabs = true,
}

-- Auto-restore on startup
wezterm.on('gui-startup', resurrect.state_manager.resurrect_on_gui_startup)

-- ============================================
-- Status Bar
-- ============================================
-- Right status: hostname + current time (mirrors tmux right status)
-- Left status (tab title) shows workspace name via WezTerm's default tab handling.
--
-- NOT PORTED from tmux (limitations):
--   - CPU/battery: requires polling wezterm.run_child_process — deferred
--   - Pane synchronization (prefix+S): no native WezTerm equivalent
--   - Session resurrection: not a terminal emulator feature

-- Left status: active workspace name (mirrors tmux session name in status-left)
-- Default workspace is 'default'; named workspaces surface here when set via palette
wezterm.on('update-left-status', function(window, _)
  local workspace = window:active_workspace()
  window:set_left_status(wezterm.format {
    { Attribute = { Intensity = 'Bold' } },
    { Text = '  ' .. workspace .. '  ' },
    { Attribute = { Intensity = 'Normal' } },
  })
end)

wezterm.on('update-right-status', function(window, _pane)
  local hostname = wezterm.hostname()
  -- Strip domain suffix for brevity (e.g. "host.local" -> "host")
  hostname = hostname:gsub('%..*', '')

  local time = wezterm.strftime '%H:%M'

  window:set_right_status(wezterm.format {
    { Attribute = { Intensity = 'Bold' } },
    { Text = '  ' .. hostname .. '  ' .. time .. '  ' },
  })
end)

-- Per-process Nerd Font icon map (IosevkaTerm Nerd Font code points)
local PROC_ICONS = {
  -- Editors
  nvim    = '\u{e62b}',  -- nf-custom-vim
  vim     = '\u{e62b}',
  vi      = '\u{e62b}',

  -- AI tools
  claude  = '\u{f0d0}',  -- nf-fa-magic (wand)

  -- Version control
  git     = '\u{e702}',  -- nf-dev-git
  lazygit = '\u{e702}',  -- nf-dev-git (lazygit is a git TUI)
  gh      = '\u{e709}',  -- nf-dev-github

  -- Python
  python  = '\u{e73c}',  -- nf-dev-python
  python3 = '\u{e73c}',

  -- JavaScript / Node ecosystem
  node    = '\u{e718}',  -- nf-dev-nodejs_small
  npm     = '\u{e718}',
  yarn    = '\u{e718}',
  pnpm    = '\u{e718}',
  bun     = '\u{e718}',
  deno    = '\u{e718}',

  -- Go
  go      = '\u{e724}',  -- nf-dev-go

  -- Java / JVM
  java    = '\u{e738}',  -- nf-dev-java
  javac   = '\u{e738}',
  mvn     = '\u{e738}',
  gradle  = '\u{e738}',

  -- Rust
  cargo   = '\u{e7a8}',  -- nf-dev-rust
  rust    = '\u{e7a8}',

  -- Ruby
  ruby    = '\u{e739}',  -- nf-dev-ruby

  -- Lua
  lua     = '\u{e620}',  -- nf-dev-lua

  -- Systems / build
  make    = '\u{e779}',  -- nf-dev-gnu
  ssh     = '\u{f233}',  -- nf-fa-server

  -- Containers / devops
  docker  = '\u{f308}',  -- nf-linux-docker
  kubectl = '\u{f308}',  -- nf-linux-docker (K8s is container-adjacent)
  k9s     = '\u{f308}',
  helm    = '\u{f308}',
  terraform = '\u{f0c2}',  -- nf-fa-cloud

  -- Databases
  psql    = '\u{f1c0}',  -- nf-fa-database
  mysql   = '\u{f1c0}',
  sqlite3 = '\u{f1c0}',
  mongosh = '\u{f1c0}',
  ['redis-cli'] = '\u{f1c0}',

  -- Network tools
  curl    = '\u{f0ac}',  -- nf-fa-globe
  wget    = '\u{f0ac}',

  -- Search / fuzzy find
  fzf     = '\u{f002}',  -- nf-fa-search
  rg      = '\u{f002}',

  -- System monitors
  htop    = '\u{f080}',  -- nf-fa-bar-chart
  top     = '\u{f080}',
  btop    = '\u{f080}',

  -- Pagers / docs
  man     = '\u{f02d}',  -- nf-fa-book
  less    = '\u{f02d}',

  -- Package managers (non-Node)
  brew    = '\u{f0fc}',  -- nf-fa-beer
}
local DEFAULT_ICON = '\u{f489}'  -- nf-fa-terminal (fallback)
-- Processes considered "idle shell" — show CWD instead of process name
local SHELL_PROCS = { zsh = true, bash = true, fish = true, sh = true }

-- Shorten a cwd Uri to a compact display path (~/a/b form, last 2 components)
local function short_path(cwd_uri)
  if not cwd_uri then return '~' end
  local path = cwd_uri.file_path or ''
  if path == '' then return '~' end
  local home = os.getenv('HOME') or ''
  if home ~= '' and path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end
  return path:match('[^/]+/[^/]+$') or path:match('[^/]+$') or path
end

-- Theme-aware colors for tab label segments
local function tab_seg_colors()
  if wezterm.gui.get_appearance():find 'Dark' then
    return {
      icon     = '#83a598',  -- muted bright-blue
      label    = '#ebdbb2',  -- cream (primary)
      meta     = '#928374',  -- dim gray (pane count)
      activity = '#fabd2f',  -- bright yellow (activity dot)
    }
  else
    return {
      icon     = '#076678',  -- deep teal
      label    = '#3c3836',  -- dark (primary)
      meta     = '#7c6f64',  -- medium gray
      activity = '#b57614',  -- amber
    }
  end
end

-- Tab title: icon + label (cwd when idle, process when busy) + pane count + activity dot
wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local pane   = tab.active_pane
  local colors = tab_seg_colors()

  -- Resolve label: user-set title wins; otherwise derive from process / cwd
  local icon, label
  local user_title = tab.tab_title
  if user_title and user_title ~= '' then
    icon  = DEFAULT_ICON
    label = user_title
  else
    local proc_name = pane.foreground_process_name or ''
    local proc      = proc_name:match('([^/\\]+)$') or ''
    if proc == '' then proc = pane.title end
    icon = PROC_ICONS[proc] or DEFAULT_ICON
    if SHELL_PROCS[proc] then
      label = short_path(pane.current_working_dir)
    else
      label = proc
    end
  end

  -- Pane count badge (shown only when tab has splits)
  local pane_count  = #panes
  local pane_suffix = pane_count > 1 and (' [' .. pane_count .. ']') or ''

  -- Activity dot: any pane with unseen output
  local has_activity = false
  for _, p in ipairs(panes) do
    if p.has_unseen_output then has_activity = true; break end
  end

  -- Truncate label to fit within max_width
  local reserved = 4 + #pane_suffix + (has_activity and 2 or 0)
  if #label > max_width - reserved then
    label = wezterm.truncate_right(label, max_width - reserved - 1) .. '\u{2026}'
  end

  -- Build colored segments
  local seg = {
    { Text = ' ' },
    { Foreground = { Color = colors.icon } },
    { Text = icon },
    { Foreground = { Color = colors.label } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' ' .. label },
    { Attribute = { Intensity = 'Normal' } },
  }
  if pane_suffix ~= '' then
    table.insert(seg, { Foreground = { Color = colors.meta } })
    table.insert(seg, { Text = pane_suffix })
  end
  if has_activity then
    table.insert(seg, { Foreground = { Color = colors.activity } })
    table.insert(seg, { Text = ' \u{25cf}' })  -- ●
  end
  table.insert(seg, { Text = '  ' })
  return seg
end)

wezterm.on('close-window', function(window)
  window:close()
end)

return config
