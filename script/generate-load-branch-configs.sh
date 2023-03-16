#!/bin/bash

. script/generate-config-base.sh

make_config_dir

generate_config "load-branch-only" \
                ".load_branch_criticality = true | \
                 .load_load_criticality = false | \
                 .L1D.replacement = \"crit\" | \
                 .L2C.replacement = \"crit\" | \
                 .LLC.replacement = \"crit\""

generate_config "both" \
                ".load_branch_criticality = true | \
                 .load_load_criticality = true | \
                 .L1D.replacement = \"crit\" | \
                 .L2C.replacement = \"crit\" | \
                 .LLC.replacement = \"crit\""
