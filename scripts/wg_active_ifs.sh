#!/usr/bin/env bash

human_readable() {
    numfmt --to=iec-i --suffix=B --format="%.0f" "$1"
}

wg_interfaces() {
    command -v wg >/dev/null 2>&1 || return 0
    wg show interfaces
}

tailscale_running() {
    command -v tailscale >/dev/null 2>&1 || return 1
    tailscale status --peers=false >/dev/null 2>&1
}

tailscale_ifname() {
    # The TUN device is normally tailscale0 but the name is configurable, and
    # the device doesn't exist at all in userspace networking mode
    local ifname
    ifname=$(ip -o link show 2>/dev/null \
                 | awk -F': ' '$2 ~ /^tailscale/ {print $2; exit}')
    echo "${ifname:-tailscale}"
}

if [[ "$1" == "verbose" ]]; then
    now=$(date +%s)
    output=""

    for if in $(wg_interfaces); do
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

        output+="$if(↓$rx|↑$tx|$latest_handshake) "
    done

    if tailscale_running; then
        ts_json=$(tailscale status --json 2>/dev/null)

        # Get sum of all peers' received/sent bytes
        read -r rx tx < <(jq -r '[.Peer[]?]
                                 | "\(([.[].RxBytes // 0] | add) // 0) \(([.[].TxBytes // 0] | add) // 0)"' \
                                 <<<"$ts_json")
        rx=$(human_readable "${rx:-0}")
        tx=$(human_readable "${tx:-0}")

        # Get most recent latest handshake across all peers
        # (timestamps from the zero year mean "never")
        read -r latest_handshake < <(jq -r '.Peer[]?.LastHandshake // empty
                                            | select(startswith("0001") | not)' \
                                            <<<"$ts_json" \
                                         | while read -r ts; do
                                               date -d "$ts" +%s 2>/dev/null
                                           done \
                                         | sort -nr \
                                         | head -1)
        if [[ "${latest_handshake:-0}" -gt 0 ]]; then
            latest_handshake="$((now - latest_handshake))s"
        else
            latest_handshake="-"
        fi

        output+="$(tailscale_ifname)(↓$rx|↑$tx|$latest_handshake) "
    fi

    if [[ -n "$output" ]]; then
        echo "<${output% }>"
    fi
else
    ifs=$(wg_interfaces | tr '\n' ' ')
    if tailscale_running; then
        ifs+="$(tailscale_ifname) "
    fi
    ifs="${ifs% }"
    if [[ -n "$ifs" ]]; then
        echo "<$ifs>"
    fi
fi

exit 0
