# tmux WireGuard status

tmux plugin to add active WireGuard interfaces to your status bar.

## Pre-requisites

- `ip` (from `iproute2`)

## Installation

### Via TPM (recommended)

```
set -g @plugin 'mgalgs/tmux-wireguard'
```

Hit `prefix + I` to fetch the plugin and source it.

Now you can add `#{@active_wg_ifs}` to your `status-left` and
`status-right` options, as described in the Usage section below.

### Manual

Clone the repo:

```
git clone https://github.com/mgalgs/tmux-wireguard
```

Add this to the bottom of your `.tmux.conf`:

```
run-shell /path/to/tmux-wireguard/main.tmux
```

And reload your tmux environment:

```
tmux source-file ~/.tmux.conf
```

## Usage

This plugin adds the following variables for use in your `status-left` or
`status-right` strings:

  - `#{@active_wg_ifs}` :: Space-separated list of WireGuard interface names

### Example

```
set -g status-right '#[fg=colour226,bg=colour017,bright]#{@active_wg_ifs}#[fg=green,bg=black,nobright] #[default]'
```

Will look something like this:

![image](https://github.com/user-attachments/assets/3923eb58-eb61-4720-8f90-340148aed427)

