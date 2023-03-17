#!/bin/bash

. script/generate-config-base.sh

make_config_dir

generate_config "crrip" \
                ".load_branch_criticality = true | \
                 .load_load_criticality = true | \
                 .L1D.replacement = \"crit\" | \
                 .L2C.replacement = \"crit\" | \
                 .LLC.replacement = \"crit\""

generate_config "srrip" \
                ".L1D.replacement = \"srrip\" | \
                 .L2C.replacement = \"srrip\" | \
                 .LLC.replacement = \"srrip\""
