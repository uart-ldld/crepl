#!/bin/bash

config_dir="config-$(git rev-parse --short HEAD)"
repl=$1

mkdir -p $config_dir

jq ".executable_name = \"bin-$(git rev-parse --short HEAD)/champsim-$repl\" |\
    .L1D.replacement = \"$repl\" |\
    .L2C.replacement = \"$repl\" |\
    .LLC.replacement = \"$repl\"" \
   ChampSim/champsim_config.json > ${config_dir}/${repl}_config.json
