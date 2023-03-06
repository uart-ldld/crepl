#!/bin/bash

result_dir="result-$(date +'%Y-%m-%d_%H-%M')-$(git rev-parse --short HEAD)"
bin_dir="ChampSim/bin-$(git rev-parse --short HEAD)"
trace_dir="trace"

mkdir -p $result_dir

for trace in $trace_dir/*.champsimtrace.xz; do
    for bin in $bin_dir/*; do
        sbatch -A naiss2023-22-203 \
               -p core \
               -n 1 \
               -t 2:00:00 \
               -J "$bin.$(basename $trace .champsimtrace.xz)" \
               script/slurm-job.sh \
               $bin \
               $trace \
               $result_dir
    done
done

echo "Submitted all jobs"
