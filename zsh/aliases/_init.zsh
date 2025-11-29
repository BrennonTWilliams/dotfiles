# ==============================================================================
# Safety Aliases Loader
# ==============================================================================
# Sources only safety aliases (rm -i, cp -i, mv -i)
# These should always be loaded regardless of abbr/alias mode
# extras.zsh is loaded separately based on DOTFILES_ABBR_MODE

local alias_dir="${0:A:h}"

[[ -f "$alias_dir/safety.zsh" ]] && source "$alias_dir/safety.zsh"

unset alias_dir
