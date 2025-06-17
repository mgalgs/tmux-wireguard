#!/usr/bin/env bash

wgifs=$(wg show interfaces | tr '\n' ' ' | sed 's/ $//')
if [[ -n "$wgifs" ]]; then
    echo "<$wgifs>"
fi
exit 0
