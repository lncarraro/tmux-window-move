# tmux-window-move

tmux plugin for moving the current window to an existing index by shifting the other windows instead of swapping them.

The moved window remains selected after the operation.

## Usage

Press:

```text
prefix + m + index
```

The target index must be a number from `1` to `9`.

For example, with window 2 selected:

```text
prefix + m + 1   # window 2 -> index 1
prefix + m + 3   # window 2 -> index 3
```

The target index must already exist. If it does not exist, the plugin displays a brief message and leaves the windows unchanged. Moving to the current index does nothing.

## Installation with TPM

Add the plugin to `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'lncarraro/tmux-window-move'

# Keep this line at the end of the file.
run '~/.tmux/plugins/tpm/tpm'
```

Reload the tmux configuration and press `prefix + I` to install the plugins:

```sh
tmux source-file ~/.tmux.conf
```

The default tmux prefix is `Ctrl-b`. If you use a different prefix, such as `Ctrl-a`, use it as usual. After installation, the command is available as `prefix + m + 1` through `prefix + m + 9`.

## Manual installation

```sh
git clone https://github.com/lncarraro/tmux-window-move ~/.tmux/plugins/tmux-window-move
```

Add the following to `~/.tmux.conf`:

```tmux
run '~/.tmux/plugins/tmux-window-move/tmux-window-move.tmux'
```

Then reload the configuration:

```sh
tmux source-file ~/.tmux.conf
```
