#!/bin/bash

config_dir="config-$(git rev-parse --short HEAD)"

mkdir -p $config_dir

for threshold_criticality in 1 2 3 4 5; do
    jq ".executable_name = \"bin-$(git rev-parse --short HEAD)/champsim-crit-t${threshold_criticality}\" |\
        .threshold_criticality = $threshold_criticality |\
        .L1D.replacement = \"crit\" |\
        .L2C.replacement = \"crit\" |\
        .LLC.replacement = \"crit\"" \
        ChampSim/champsim_config.json > $config_dir/crit_t${threshold_criticality}_config.json
done
