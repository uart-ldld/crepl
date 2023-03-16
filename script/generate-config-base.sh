#!/bin/bash

config_dir="config-$(git rev-parse --short HEAD)"
base_config="ChampSim/champsim_config.json"

function make_config_dir {
    mkdir -p $config_dir
}

function generate_config {
    jq ".executable_name = \"bin-$(git rev-parse --short HEAD)/champsim-${1}\"" $base_config \
        | jq "$2" > "${config_dir}/${1}_config.json"
}
