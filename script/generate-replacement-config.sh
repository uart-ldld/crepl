#!/bin/bash

repl=$1

. script/generate-config-base.sh

make_config_dir

generate_config "$repl" \
                ".L1D.replacement = \"$repl\" |\
                 .L2C.replacement = \"$repl\" |\
                 .LLC.replacement = \"$repl\""
