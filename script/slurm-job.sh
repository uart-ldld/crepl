#!/bin/bash -l

warmup=50000000
simulate=200000000

$1 --warmup_instructions $warmup \
   --simulation_instructions $simulate \
   $2 \
   > "$3/$(basename $1).$(basename $2 .champsimtrace.xz)"
