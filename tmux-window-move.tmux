#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
move_script="$current_dir/move-window.sh"

# Prefix + m enters the key table that captures the target index.
tmux bind-key -T prefix m switch-client -T tmux-window-move

for target_index in 0 1 2 3 4 5 6 7 8 9; do
    tmux bind-key -T tmux-window-move "$target_index" \
        run-shell -b "TMUX_WINDOW_MOVE_CLIENT='#{client_tty}' '$move_script' $target_index"
done
