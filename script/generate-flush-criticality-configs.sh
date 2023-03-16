#!/bin/bash

. script/generate-config-base.sh

make_config_dir

for flush_criticality in 100000 200000 400000 800000; do
    generate_config \
        "crit-f${flush_criticality}" \
        ".flush_criticality = $flush_criticality |\
         .L1D.replacement = \"crit\" |\
         .L2C.replacement = \"crit\" |\
         .LLC.replacement = \"crit\""
done
