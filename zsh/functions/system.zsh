# ==============================================================================
# System Monitor Toggle
# ==============================================================================
# CPU/RAM monitors (tmux-cpu plugin + starship custom.memory) are disabled by
# default because they shell out on every poll. This lets you flip them back
# on when you want the visibility, and back off under heavy load.

_sys_monitors_resolve_symlink() {
    local link="$1"
    if [[ -L "$link" ]]; then
        local target
        target="$(readlink "$link")"
        [[ "$target" != /* ]] && target="$HOME/$target"
        echo "$target"
    else
        echo "$link"
    fi
}

toggle-sys-monitors() {
    local state_file="$HOME/.config/sys-monitors-mode"
    local current="disabled"
    [[ -f "$state_file" ]] && current="$(<"$state_file")"

    local new_mode="enabled"
    [[ "$current" == "enabled" ]] && new_mode="disabled"

    local tmux_conf
    tmux_conf="$(_sys_monitors_resolve_symlink "$HOME/.tmux.conf")"
    if [[ ! -f "$tmux_conf" ]]; then
        echo "toggle-sys-monitors: could not locate tmux.conf" >&2
        return 1
    fi
    local dotfiles_root="${tmux_conf:h:h}"
    local starship_standard="$dotfiles_root/starship/.config/starship/standard.toml"
    local starship_overrides="$dotfiles_root/starship/modes/standard-overrides.toml"

    local plugin_disabled_block="# tmux-cpu disabled: shells out to sample CPU/RAM on every status-interval tick,
# the most expensive item in the status bar. Re-enable if the cost is acceptable.
# set -g @plugin 'tmux-plugins/tmux-cpu'"
    local plugin_enabled_line="set -g @plugin 'tmux-plugins/tmux-cpu'"

    local dark_off="#{prefix_highlight}#[fg=#928374] #[fg=#a89984]| #[fg=#a89984]%I:%M %p %d-%b-%y "
    local dark_on="#{prefix_highlight}#[fg=#928374]     #{cpu_percentage}  󰑭  #{ram_percentage} #[fg=#a89984]| #[fg=#a89984]%I:%M %p %d-%b-%y "
    local light_off="#{prefix_highlight}#[fg=#928374] #[fg=#7c6f64]| #[fg=#7c6f64]%I:%M %p %d-%b-%y "
    local light_on="#{prefix_highlight}#[fg=#928374]     #{cpu_percentage}  󰑭  #{ram_percentage} #[fg=#7c6f64]| #[fg=#7c6f64]%I:%M %p %d-%b-%y "

    if [[ "$new_mode" == "enabled" ]]; then
        OLD_TEXT="$plugin_disabled_block" NEW_TEXT="$plugin_enabled_line" \
            perl -i -0777 -pe 's/\Q$ENV{OLD_TEXT}\E/$ENV{NEW_TEXT}/' "$tmux_conf"
        OLD_TEXT="$dark_off" NEW_TEXT="$dark_on" \
            perl -i -pe 's/\Q$ENV{OLD_TEXT}\E/$ENV{NEW_TEXT}/' "$tmux_conf"
        OLD_TEXT="$light_off" NEW_TEXT="$light_on" \
            perl -i -pe 's/\Q$ENV{OLD_TEXT}\E/$ENV{NEW_TEXT}/' "$tmux_conf"
        perl -i -pe 's/^(set -g status-interval) \d+/\1 30/' "$tmux_conf"

        local f
        for f in "$starship_standard" "$starship_overrides"; do
            [[ -f "$f" ]] && perl -i -pe 's/(custom\.memory\.disabled = )true/\1false/' "$f"
        done
    else
        OLD_TEXT="$plugin_enabled_line" NEW_TEXT="$plugin_disabled_block" \
            perl -i -pe 's/\Q$ENV{OLD_TEXT}\E/$ENV{NEW_TEXT}/' "$tmux_conf"
        OLD_TEXT="$dark_on" NEW_TEXT="$dark_off" \
            perl -i -pe 's/\Q$ENV{OLD_TEXT}\E/$ENV{NEW_TEXT}/' "$tmux_conf"
        OLD_TEXT="$light_on" NEW_TEXT="$light_off" \
            perl -i -pe 's/\Q$ENV{OLD_TEXT}\E/$ENV{NEW_TEXT}/' "$tmux_conf"
        perl -i -pe 's/^(set -g status-interval) \d+/\1 15/' "$tmux_conf"

        local f
        for f in "$starship_standard" "$starship_overrides"; do
            [[ -f "$f" ]] && perl -i -pe 's/(custom\.memory\.disabled = )false/\1true/' "$f"
        done
    fi

    echo "$new_mode" > "$state_file"

    [[ -n "$TMUX" ]] && tmux source-file "$HOME/.tmux.conf" 2>/dev/null

    if [[ "$new_mode" == "enabled" ]]; then
        echo "sys-monitors: enabled (tmux status-interval 30s, starship memory module on)"
        echo "  First time enabling tmux-cpu: press prefix + I to install the plugin."
    else
        echo "sys-monitors: disabled"
    fi
}
