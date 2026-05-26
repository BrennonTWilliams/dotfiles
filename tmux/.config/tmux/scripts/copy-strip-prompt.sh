#!/usr/bin/env bash
# Strips a leading shell prompt symbol ($ % # > ❯) and surrounding whitespace
# from piped text before sending to the system clipboard. Used by tmux triple-click.
if [[ "$(uname)" == "Darwin" ]]; then
    sed 's/^[[:space:]]*[$%#>❯][[:space:]]*//' | pbcopy
else
    sed 's/^[[:space:]]*[$%#>❯][[:space:]]*//' | xclip -in -selection clipboard
fi
