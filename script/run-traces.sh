#!/bin/bash

replacement_policies="crit lru drrip srrip"
result_dir="result-$(date +'%Y-%m-%d_%H-%M')-$(git rev-parse --short HEAD)"

mkdir -p $result_dir

for trace in trace/*.champsimtrace.xz; do
    for repl in $replacement_policies; do
        sbatch -A naiss2023-22-203 \
               -p core \
               -n 1 \
               -t 2:00:00 \
               -J "$(basename $repl).$(basename $trace .champsimtrace.xz)" \
               script/slurm-job.sh \
               "ChampSim/$(jq -r '.executable_name' "config/${repl}_config.json")" \
               $trace \
               $result_dir
    done
done

echo "Submitted all jobs"
