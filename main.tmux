#!/usr/bin/env bash

# Replaces #{@active_wg_ifs...} variables with a #() call to our script in
# both status strings

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

replace() {
    local opt="$1"
    local var_name="$2"
    local script_args="$3"

    local val
    val=$(tmux show -gqv "$opt")

    if [[ "$val" == *"$var_name"* ]]; then
        local script_path="#($CURRENT_DIR/scripts/wg_active_ifs.sh$script_args)"
        local new_val="${val//$var_name/$script_path}"
        tmux set -gq "$opt" "$new_val"
    fi
}

for opt in status-right status-left; do
    replace "$opt" '#{@active_wg_ifs}' ''
    replace "$opt" '#{@active_wg_ifs_verbose}' ' verbose'
done
