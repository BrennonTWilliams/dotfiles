# ==============================================================================
# Terminal / Tab Title Functions
# ==============================================================================
# OSC 2 helpers for setting terminal tab/window titles.
# Works in Ghostty, WezTerm, iTerm2, and any VTE-compatible terminal.
#
# MANUAL_TAB_TITLE: when non-empty, suppresses the auto-title preexec/precmd
# hooks so a pinned title persists across commands.

# Pin the current tab/window title via OSC 2. Persists until tab-title-reset.
# Usage: tab-title my-task
tab-title() {
    MANUAL_TAB_TITLE="${1}"
    print -n "\e]2;${1}\a"
}

# Clear the pinned title and restore automatic directory/command titles.
tab-title-reset() {
    MANUAL_TAB_TITLE=""
}

# ==============================================================================
# Auto Tab Title (OSC 2, preexec/precmd hooks)
# ==============================================================================
# Sends a Nerd Font process icon + short cwd as the tab/window title via OSC 2.
# Ported from the PROC_ICONS map in wezterm/.wezterm.lua.
#
# Unicode: BMP PUA codepoints (<=U+FFFF) use $'\uXXXX'.
# Supplementary PUA-A (U+F0000-U+FFFFF) use $'\Uxxxxxxxx'.

typeset -gA _TAB_ICONS=(
  nvim        $''   # nf-custom-vim
  vim         $''
  vi          $''

  claude      $'\U000f167a'  # nf-md-robot_outline (supplementary PUA-A)

  ll-loop     $''   # nf-oct-sync
  ll-issues   $''
  ll-auto     $'\U000f006a'  # nf-md-autorenew (supplementary PUA-A)
  ll-parallel $'\U000f1860'  # nf-md-format_list_group (supplementary PUA-A)
  ll-sprint   $''   # nf-cod-group_by_ref_type

  git         $''   # nf-dev-git
  lazygit     $''
  gh          $''   # nf-dev-github

  python      $''   # nf-dev-python
  python3     $''

  node        $''   # nf-dev-nodejs_small
  npm         $''
  yarn        $''
  pnpm        $''
  bun         $''
  deno        $''

  go          $''   # nf-dev-go

  java        $''   # nf-dev-java
  javac       $''
  mvn         $''
  gradle      $''

  cargo       $''   # nf-dev-rust
  rust        $''

  ruby        $''   # nf-dev-ruby

  lua         $''   # nf-dev-lua

  make        $''   # nf-dev-gnu
  ssh         $''   # nf-fa-server

  docker      $''   # nf-linux-docker
  kubectl     $''
  k9s         $''
  helm        $''
  terraform   $''   # nf-fa-cloud

  psql        $''   # nf-fa-database
  mysql       $''
  sqlite3     $''
  mongosh     $''
  redis-cli   $''

  curl        $''   # nf-fa-globe
  wget        $''

  fzf         $''   # nf-fa-search
  rg          $''

  htop        $''   # nf-fa-bar-chart
  top         $''
  btop        $''

  man         $''   # nf-fa-book
  less        $''

  brew        $''   # nf-fa-beer
)

# nf-fa-terminal U+F489 — shown when idle (no command running)
_TAB_ICON_DEFAULT=$''

# Emits OSC 2 with icon + short cwd. No subshells — runs on every prompt.
# Shows last 2 path components; substitutes $HOME with ~.
_tab_title_emit() {
  local icon="${_TAB_ICONS[$1]:-$_TAB_ICON_DEFAULT}"
  local cwd="${PWD/#$HOME/~}"
  local -a parts=("${(@s:/:)cwd}")
  local short
  if (( $#parts <= 2 )); then
    short="$cwd"
  else
    short="${parts[-2]}/${parts[-1]}"
  fi
  print -n "\e]2;${icon} ${short}\a"
}

# Called before a command runs — icon derives from the executable name.
_tab_title_preexec() {
  [[ -n "$MANUAL_TAB_TITLE" ]] && return
  _tab_title_emit "${${1%% *}:t}"
}

# Called after a command completes — idle terminal icon + cwd.
_tab_title_precmd() {
  [[ -n "$MANUAL_TAB_TITLE" ]] && return
  _tab_title_emit ""
}
