#!/bin/bash

. script/generate-config-base.sh

make_config_dir

for threshold_criticality in 1 2 3 4 5; do
    generate_config "crit-t${threshold_criticality}" \
                    ".threshold_criticality = $threshold_criticality |\
                     .L1D.replacement = \"crit\" |\
                     .L2C.replacement = \"crit\" |\
                     .LLC.replacement = \"crit\""
done
