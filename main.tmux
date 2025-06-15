#!/usr/bin/env bash

# Replaces #{@active_wg_ifs} with a #() call to our script in both status
# strings

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
replace() {
    local opt="$1"
    local val=$(tmux show -gqv "$opt")
    tmux set -gq "$opt" "${val//\#\{@active_wg_ifs\}/\#\($CURRENT_DIR\/scripts\/wg_active_ifs.sh\)}"
};
replace status-right
replace status-left
