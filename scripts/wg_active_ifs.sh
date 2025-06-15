#!/usr/bin/env bash

wgifs=$(ip -o link show up type wireguard \
            | awk -F': ' '{print $2}' \
            | tr '\n' ' ' | sed 's/ $//')
if [[ -n "$wgifs" ]]; then
    echo "<$wgifs>"
fi
exit 0
