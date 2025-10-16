#!/usr/bin/env bash

human_readable() {
    numfmt --to=iec-i --suffix=B --format="%.0f" "$1"
}

if [[ "$1" == "verbose" ]]; then
    wgifs=$(wg show interfaces)
    if [[ -z "$wgifs" ]]; then exit 0; fi

    now=$(date +%s)
    output=""
    for if in $wgifs; do
        # Get sum of all peers' received/sent bytes
        read -r rx tx < <(sudo wg show "$if" transfer \
                              | awk '{rx+=$2; tx+=$3} END {print rx, tx}')
        rx=$(human_readable "$rx")
        tx=$(human_readable "$tx")

        # Get most recent latest handshake across all peers
        read -r latest_handshake < <(sudo wg show "$if" latest-handshakes \
                                         | awk '{print $2}' \
                                         | sort -nr \
                                         | head -1)
        if [[ "$latest_handshake" -gt 0 ]]; then
            latest_handshake="$((now - latest_handshake))s"
        else
            latest_handshake="-"
        fi

        output+="$if(↑$tx|↓$rx|$latest_handshake) "
    done
    echo "<${output% }>"
else
    wgifs=$(wg show interfaces | tr '\n' ' ' | sed 's/ $//')
    if [[ -n "$wgifs" ]]; then
        echo "<$wgifs>"
    fi
fi

exit 0
