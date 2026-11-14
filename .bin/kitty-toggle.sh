#!/bin/zsh

# Pattern using bracket notation [k] to prevent pgrep from matching itself
PATTERN="[k]itty.*--title=yazi-float"

if pgrep -f "$PATTERN" > /dev/null; then
    pkill -f "$PATTERN"
else
    /Applications/kitty.app/Contents/MacOS/kitty \
        --title="yazi-float" \
        --directory="$HOME" \
        -o macos_quit_when_last_window_closed=yes \
        zsh -lc yazi &!
fi
