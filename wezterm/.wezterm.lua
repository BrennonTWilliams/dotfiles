-- ==============================================================================
-- WezTerm Terminal Configuration
-- ==============================================================================
-- Comprehensive configuration for optimal macOS integration with zsh shell
-- Mirrors tmux configuration with Gruvbox theme and aligned keybindings
-- ==============================================================================

local wezterm = require 'wezterm'

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

-- ============================================
-- Tab Bar Configuration
-- ============================================

-- Auto-hide tab bar when only one tab (matches Ghostty window-show-tab-bar = auto)
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

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

-- Disable macOS IME: WezTerm 20240203+ defaults use_ime=true which causes
-- backspace to commit IME composition as a space character instead of deleting.
config.use_ime = false

-- ============================================
-- Terminal Settings
-- ============================================

-- Terminal type (matches Ghostty term = xterm-256color)
config.term = 'xterm-256color'

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
      selection_bg = '#d5c4a1',
      scrollbar_thumb = '#bdae93',
      -- Active pane border: tmux active border in light mode
      split = '#79740e',

      ansi = {
        '#3c3836', -- black
        '#cc241d', -- red
        '#98971a', -- green
        '#d79921', -- yellow
        '#458588', -- blue
        '#b16286', -- magenta
        '#689d6a', -- cyan
        '#7c6f64', -- white
      },
      brights = {
        '#928374', -- bright black
        '#9d0006', -- bright red
        '#79740e', -- bright green
        '#b57614', -- bright yellow
        '#076678', -- bright blue
        '#8f3f71', -- bright magenta
        '#427b58', -- bright cyan
        '#3c3836', -- bright white
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

  -- Tab management
  {
    key = 'T',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = false },
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
  -- Alt+Arrow: mirrors tmux M-Left/Right/Up/Down prefix-free pane switching
  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },

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
-- Status Bar
-- ============================================
-- Right status: hostname + current time (mirrors tmux right status)
-- Left status (tab title) shows workspace name via WezTerm's default tab handling.
--
-- NOT PORTED from tmux (limitations):
--   - CPU/battery: requires polling wezterm.run_child_process — deferred
--   - Pane synchronization (prefix+S): no native WezTerm equivalent
--   - Session resurrection: not a terminal emulator feature

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

wezterm.on('close-window', function(window)
  window:close()
end)

return config
