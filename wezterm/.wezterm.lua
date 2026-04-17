-- ==============================================================================
-- WezTerm Configuration
-- ==============================================================================
-- Ported from Ghostty configuration with Gruvbox custom themes
-- Supports macOS with automatic dark/light theme switching
-- ==============================================================================

local wezterm = require 'wezterm'

-- Initialize config table
local config = {}

-- ==============================================================================
-- Font Configuration
-- ==============================================================================

-- Primary font family (IosevkaTerm Nerd Font for CLI compatibility)
config.font = wezterm.font('IosevkaTerm Nerd Font')
config.font_size = 16

-- Font variants for bold and italic
config.font_rules = {
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font('IosevkaTerm Nerd Font', { weight = 'Bold' }),
  },
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font('IosevkaTerm Nerd Font', { weight = 'Bold', style = 'Italic' }),
  },
  {
    intensity = 'Normal',
    italic = true,
    font = wezterm.font('IosevkaTerm Nerd Font', { style = 'Italic' }),
  },
}

-- ==============================================================================
-- Window Configuration
-- ==============================================================================

-- Window padding (8px all sides)
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- Initial window dimensions
config.initial_cols = 120
config.initial_rows = 40

-- Window decorations (native title bar)
config.window_decorations = 'RESIZE'

-- Native tab bar style (minimal, like Ghostty)
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- Resize overlay configuration
config.window_resize_animation = {
  char_resize_animation = 'none',
  char_resize_delay = 0,
}

-- ==============================================================================
-- Cursor Configuration
-- ==============================================================================

-- Steady block cursor (no blink)
config.default_cursor_style = 'SteadyBlock'

-- ==============================================================================
-- Shell and Terminal Configuration
-- ==============================================================================

-- Default shell
config.default_prog = { '/bin/zsh' }

-- Terminal type
config.term = 'xterm-256color'

-- Environment variables
config.set_environment_variables = {
  TERM = 'xterm-256color',
  COLORTERM = 'truecolor',
}

-- Confirm close when processes are running
config.window_close_confirmation = 'AlwaysPrompt'
config.skip_close_confirmation_for_processes_named = {
  'bash', 'sh', 'zsh', 'fish', 'tmux', 'nu', 'cmd.exe', 'pwsh.exe',
}

-- ==============================================================================
-- macOS-Specific Settings
-- ==============================================================================

-- Option key as Alt
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- ==============================================================================
-- Color Schemes
-- ==============================================================================

-- Gruvbox Dark Custom (ported from Ghostty theme)
config.color_schemes = {
  ['Gruvbox Dark Custom'] = {
    -- Core colors
    background = '#1d2021',
    foreground = '#ebdbb2',

    -- Selection colors
    selection_bg = '#458588',
    selection_fg = '#ebdbb2',

    -- Cursor colors
    cursor_bg = '#ebdbb2',
    cursor_fg = '#1d2021',
    cursor_border = '#ebdbb2',

    -- 16-color palette (Gruvbox dark)
    ansi = {
      '#504945', -- black (dark2)
      '#fb4934', -- red (bright)
      '#98971a', -- green
      '#d79921', -- yellow
      '#458588', -- blue
      '#b16286', -- magenta
      '#689d6a', -- cyan
      '#a89984', -- white (light4)
    },
    brights = {
      '#928374', -- bright black
      '#fb4934', -- bright red
      '#b8bb26', -- bright green
      '#fabd2f', -- bright yellow
      '#83a598', -- bright blue
      '#d3869b', -- bright magenta
      '#8ec07c', -- bright cyan
      '#ebdbb2', -- bright white (light1)
    },

    -- Bold color
    compose_cursor = '#ebdbb2',
  },

  ['Gruvbox Light Custom'] = {
    -- Core colors
    background = '#f9f5d7',
    foreground = '#3c3836',

    -- Selection colors
    selection_bg = '#d5c4a1',
    selection_fg = '#3c3836',

    -- Cursor colors
    cursor_bg = '#d65d0e',
    cursor_fg = '#f9f5d7',
    cursor_border = '#d65d0e',

    -- 16-color palette (Gruvbox light)
    ansi = {
      '#282828', -- black (dark0)
      '#9d0006', -- red (faded)
      '#79740e', -- green (faded)
      '#b57614', -- yellow (faded)
      '#076678', -- blue (faded)
      '#8f3f71', -- purple (faded)
      '#427b58', -- aqua (faded)
      '#7c6f64', -- white (dark4)
    },
    brights = {
      '#928374', -- bright black (gray)
      '#cc241d', -- bright red (neutral)
      '#79740e', -- bright green (faded)
      '#b57614', -- bright yellow (faded)
      '#458588', -- bright blue (neutral)
      '#b16286', -- bright purple (neutral)
      '#427b58', -- bright cyan (faded)
      '#3c3836', -- bright white (dark1)
    },

    -- Bold color
    compose_cursor = '#3c3836',
  },
}

-- ==============================================================================
-- Dynamic Theme Switching
-- ==============================================================================

-- Function to get color scheme based on theme-mode file or system appearance
local function get_color_scheme()
  -- First, check for explicit theme-mode file (set by toggle-theme)
  local home = os.getenv('HOME') or ''
  local theme_file = home .. '/.config/theme-mode'

  local file = io.open(theme_file, 'r')
  if file then
    local mode = file:read('*l')
    file:close()
    if mode == 'light' then
      return 'Gruvbox Light Custom'
    elseif mode == 'dark' then
      return 'Gruvbox Dark Custom'
    end
  end

  -- Fall back to system appearance if no theme file
  local appearance = wezterm.gui.get_appearance()
  if appearance:find('Dark') then
    return 'Gruvbox Dark Custom'
  else
    return 'Gruvbox Light Custom'
  end
end

-- Apply color scheme
config.color_scheme = get_color_scheme()

-- Event handler for appearance changes
wezterm.on('window-config-reloaded', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local scheme = get_color_scheme()
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)

-- ==============================================================================
-- Selection and Clipboard
-- ==============================================================================

-- Copy on select (similar to Ghostty)
config.selection_word_boundary = " \t\n{}[]()\"'`"
config.audible_bell = 'Disabled'

-- ==============================================================================
-- Mouse Configuration
-- ==============================================================================

-- Focus follows mouse
config.pane_focus_follows_mouse = false

-- ==============================================================================
-- Additional Settings
-- ==============================================================================

-- Scrollback
config.scrollback_lines = 10000

-- Enable true color
config.enable_term256_colors = true

-- Tab bar styling
config.colors = {
  tab_bar = {
    background = 'transparent',
  },
}

-- ==============================================================================
-- Key Bindings
-- ==============================================================================

config.keys = {
  -- CMD+D: Horizontal split (side by side)
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
  },
  -- CMD+Shift+D: Vertical split (stacked)
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
  },
  -- CMD+W: Close current pane
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  -- CMD+Shift+W: Close current window
  {
    key = 'w',
    mods = 'CMD|SHIFT',
    action = wezterm.action.CloseCurrentWindow({ confirm = true }),
  },
  -- CMD+Enter: Send newline to terminal app (for Claude Code multiline input)
  {
    key = 'Enter',
    mods = 'CMD',
    action = wezterm.action.SendKey({ key = 'Enter', mods = 'ALT' }),
  },
}

-- ==============================================================================
-- Machine-Local Overrides
-- ==============================================================================

local home = os.getenv('HOME') or ''
local local_config = home .. '/.wezterm.local.lua'
local f = io.open(local_config, 'r')
if f then
  f:close()
  local local_overrides = dofile(local_config)
  if type(local_overrides) == 'table' then
    for k, v in pairs(local_overrides) do
      config[k] = v
    end
  end
end

return config
