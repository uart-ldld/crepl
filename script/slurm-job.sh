#!/bin/bash -l

warmup=50_000_000
simulate=200_000_000

$1 --warmup_instructions $warmup \
   --simulation_instructions $simulate \
   $2 \
   > "$3/$(basename $1).$(basename $2 .champsimtrace.xz)"
