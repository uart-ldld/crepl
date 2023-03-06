#!/bin/bash

mkdir -p config

for repl in $(ls ChampSim/replacement); do
    jq ".executable_name = \"bin-$(git rev-parse --short HEAD)/champsim-$repl\" |\
        .L1D.replacement = \"$repl\" |\
        .L2C.replacement = \"$repl\" |\
        .LLC.replacement = \"$repl\"" \
       ChampSim/champsim_config.json > config/${repl}_config.json
done
