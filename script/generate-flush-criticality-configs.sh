#!/bin/bash

config_dir="config-$(git rev-parse --short HEAD)"

mkdir -p $config_dir

for flush_criticality in 100000 200000 400000 800000; do
    jq ".executable_name = \"bin-$(git rev-parse --short HEAD)/champsim-crit-f${flush_criticality}\" |\
        .flush_criticality = $flush_criticality |\
        .L1D.replacement = \"crit\" |\
        .L2C.replacement = \"crit\" |\
        .LLC.replacement = \"crit\"" \
        ChampSim/champsim_config.json > $config_dir/crit_f${flush_criticality}_config.json
done
