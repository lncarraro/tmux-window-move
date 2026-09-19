#!/usr/bin/env bash

set -u

target_index="${1:-}"
client_tty="${TMUX_WINDOW_MOVE_CLIENT:-}"

show_message() {
    local message="$1"

    if [[ -n "$client_tty" ]]; then
        tmux display-message -c "$client_tty" -d 1200 "$message" >/dev/null 2>&1 || true
    else
        tmux display-message -d 1200 "$message" >/dev/null 2>&1 || true
    fi
}

if [[ ! "$target_index" =~ ^[0-9]$ ]]; then
    exit 0
fi

if [[ -n "$client_tty" ]]; then
    session="$(tmux display-message -p -c "$client_tty" '#{session_name}' 2>/dev/null)"
    current_id="$(tmux display-message -p -c "$client_tty" '#{window_id}' 2>/dev/null)"
else
    session="$(tmux display-message -p '#{session_name}' 2>/dev/null)"
    current_id="$(tmux display-message -p '#{window_id}' 2>/dev/null)"
fi

if [[ -z "$session" || -z "$current_id" ]]; then
    show_message 'tmux-window-move: unable to identify the current window'
    exit 0
fi

current_index="$(tmux display-message -p -t "$current_id" '#{window_index}' 2>/dev/null)"
window_indices="$(tmux list-windows -t "$session" -F '#{window_index}' 2>/dev/null)"

if [[ ! "$current_index" =~ ^[0-9]+$ || -z "$window_indices" ]]; then
    show_message 'tmux-window-move: unable to read the windows'
    exit 0
fi

if ! grep -Fxq "$target_index" <<< "$window_indices"; then
    show_message "tmux-window-move: index $target_index does not exist"
    exit 0
fi

if [[ "$current_index" == "$target_index" ]]; then
    exit 0
fi

max_index="$(printf '%s\n' "$window_indices" | sort -n | tail -n 1)"
temporary_index=$((max_index + 1))
renumber_windows="$(tmux show-option -gqv renumber-windows 2>/dev/null || true)"

case "$renumber_windows" in
    on|off) ;;
    *) renumber_windows=off ;;
esac

restore_renumber_windows() {
    tmux set-option -g renumber-windows "$renumber_windows" >/dev/null 2>&1 || true
}

trap restore_renumber_windows EXIT

tmux set-option -g renumber-windows off >/dev/null 2>&1 || {
    show_message 'tmux-window-move: unable to move the window'
    exit 0
}

move_window() {
    tmux move-window -d -s "$1" -t "$2" >/dev/null 2>&1
}

if ! move_window "$current_id" "$session:$temporary_index"; then
    show_message 'tmux-window-move: unable to move the window'
    exit 0
fi

if (( current_index < target_index )); then
    for ((index = current_index + 1; index <= target_index; index++)); do
        if ! move_window "$session:$index" "$session:$((index - 1))"; then
            show_message 'tmux-window-move: unable to move the window'
            exit 0
        fi
    done
else
    for ((index = current_index - 1; index >= target_index; index--)); do
        if ! move_window "$session:$index" "$session:$((index + 1))"; then
            show_message 'tmux-window-move: unable to move the window'
            exit 0
        fi
    done
fi

if ! move_window "$current_id" "$session:$target_index"; then
    show_message 'tmux-window-move: unable to move the window'
    exit 0
fi

if [[ -n "$client_tty" ]]; then
    tmux switch-client -c "$client_tty" -t "$session:$target_index" >/dev/null 2>&1 || true
else
    tmux select-window -t "$current_id" >/dev/null 2>&1 || true
fi
