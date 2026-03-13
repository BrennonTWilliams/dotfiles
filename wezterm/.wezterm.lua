-- ==============================================================================
-- WezTerm Terminal Configuration
-- ==============================================================================
-- Comprehensive configuration for optimal macOS integration with zsh shell
-- Mirrors Ghostty configuration with Gruvbox theme and proper keybindings
-- ==============================================================================

local wezterm = require 'wezterm'

local config = {}

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
config.window_decorations = 'RESIZE|MACOS_FORCE_DISABLE_SHADOW'

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
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 0
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- ============================================
-- macOS-Specific Settings
-- ============================================

-- Option key behavior (matches Ghostty macos-option-as-alt = true)
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- ============================================
-- Terminal Settings
-- ============================================

-- Terminal type (matches Ghostty term = xterm-256color)
config.term = 'wezterm'

-- ============================================
-- Selection and Clipboard
-- ============================================

-- Copy on select behavior (matches Ghostty copy-on-select = true)
config.selection_word_boundary = " \t\n{}[]()\"'`"

-- ============================================
-- Gruvbox Dark Custom Theme
-- ============================================
-- Enhanced Gruvbox dark palette with bren theme aesthetic
-- Deep background (#1d2021) for reduced eye strain

config.colors = {
  foreground = '#ebdbb2',
  background = '#1d2021',
  cursor_bg = '#ebdbb2',
  cursor_fg = '#1d2021',
  cursor_border = '#ebdbb2',
  selection_fg = '#ebdbb2',
  selection_bg = '#458588',
  scrollbar_thumb = '#504945',
  split = '#504945',

  -- 16-color palette - Full Gruvbox integration
  ansi = {
    '#504945', -- black (dark2 - visible for CLI compatibility)
    '#fb4934', -- red (bright red for readability)
    '#98971a', -- green (Gruvbox dark green)
    '#d79921', -- yellow (Gruvbox dark yellow)
    '#458588', -- blue (darker blue for contrast)
    '#b16286', -- magenta (Gruvbox dark magenta)
    '#689d6a', -- cyan (Gruvbox dark cyan)
    '#a89984', -- white (Gruvbox dark white/light4)
  },
  brights = {
    '#928374', -- bright black (Gruvbox dark2)
    '#fb4934', -- bright red (enhanced)
    '#b8bb26', -- bright green (vibrant)
    '#fabd2f', -- bright yellow (electric)
    '#83a598', -- bright blue (distinct from regular blue)
    '#d3869b', -- bright magenta (bren theme)
    '#8ec07c', -- bright cyan (vibrant)
    '#ebdbb2', -- bright white (Gruvbox light1)
  },
}

-- ============================================
-- Key Bindings
-- ============================================

config.keys = {
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

  -- Tab management
  {
    key = 'T',
    mods = 'CMD',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'W',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentTab { confirm = true },
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
    key = 'D',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'D',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Pane navigation
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

-- ============================================
-- Shell Integration
-- ============================================

-- Default shell is zsh (system default)
-- WezTerm automatically uses the user's default shell

return config
