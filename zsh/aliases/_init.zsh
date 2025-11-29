# ==============================================================================
# Aliases Loader
# ==============================================================================
# Sources all alias files in this directory
# These are traditional aliases that should NOT expand (like safety aliases)

local alias_dir="${0:A:h}"

for file in "$alias_dir"/*.zsh; do
    [[ "${file:t}" != "_init.zsh" ]] && source "$file"
done

unset alias_dir
