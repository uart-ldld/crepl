#!/bin/bash

mkdir -p config

for repl in $(ls ChampSim/replacement); do
    jq ".L1D.replacement = \"$repl\" |\
        .L2C.replacement = \"$repl\" |\
        .LLC.replacement = \"$repl\"" \
       ChampSim/champsim_config.json > config/${repl}_config.json
done