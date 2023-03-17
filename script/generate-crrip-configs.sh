#!/bin/bash

. script/generate-config-base.sh

make_config_dir

generate_config "crrip" \
                ".load_branch_criticality = true | \
                 .load_load_criticality = true | \
                 .L1D.replacement = \"crrip\" | \
                 .L2C.replacement = \"crrip\" | \
                 .LLC.replacement = \"crrip\""

generate_config "srrip" \
                ".L1D.replacement = \"srrip\" | \
                 .L2C.replacement = \"srrip\" | \
                 .LLC.replacement = \"srrip\""
