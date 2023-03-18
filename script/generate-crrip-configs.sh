#!/bin/bash

. script/generate-config-base.sh

make_config_dir

generate_config "crrip-load-load" \
                ".load_load_criticality = true | \
                 .load_branch_criticality = false | \
                 .L1D.replacement = \"crrip\" | \
                 .L2C.replacement = \"crrip\" | \
                 .LLC.replacement = \"crrip\""

generate_config "crrip-load-branch" \
                ".load_load_criticality = false | \
                 .load_branch_criticality = true | \
                 .L1D.replacement = \"crrip\" | \
                 .L2C.replacement = \"crrip\" | \
                 .LLC.replacement = \"crrip\""

generate_config "crrip-both" \
                ".load_load_criticality = true | \
                 .load_branch_criticality = true | \
                 .L1D.replacement = \"crrip\" | \
                 .L2C.replacement = \"crrip\" | \
                 .LLC.replacement = \"crrip\""
