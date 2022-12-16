#!/bin/sh

nft -f /usr/local/bin/excludeTraffic.rules
nft add table mullvad-ts
