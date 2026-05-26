#!/usr/bin/env bash
# Pipes stdin to the system clipboard. Used by tmux double-click word selection.
if [[ "$(uname)" == "Darwin" ]]; then
    pbcopy
else
    xclip -in -selection clipboard
fi
