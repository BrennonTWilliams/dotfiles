# ==============================================================================
# Functions Loader
# ==============================================================================
# Sources all function files in this directory
# These functions are always loaded regardless of DOTFILES_ABBR_MODE

local func_dir="${0:A:h}"

for file in "$func_dir"/*.zsh; do
    [[ "${file:t}" != "_init.zsh" ]] && source "$file"
done

unset func_dir
