#!/bin/bash

replacement_policies="crit lru drrip srrip"
warmup=50_000_000
simulate=200_000_000
result_dir="result-$(date +'%Y-%m-%d_%H-%M')"

function compile {
    pushd "ChampSim"
    ./config.sh $1
    make -j $(nproc)
    popd
}

function run {
    mkdir -p $result_dir
    $1 --warmup_instructions $warmup \
       --simulation_instructions $simulate \
       $2 \
       > "$result_dir/$(basename $1).$(basename $2 .champsimtrace.xz)"
}

for repl in $replacement_policies; do
    echo "Compiling ChampSim with $repl replacement"
    compile "$(realpath config/${repl}_config.json)"
done

echo "Done compilation"

for trace in trace/*.champsimtrace.xz; do
    for repl in $replacement_policies; do
        echo "Running ChampSim with $repl replacement on $trace"
        run "ChampSim/$(jq -r '.executable_name' "config/${repl}_config.json")" $trace &
    done
done

wait
echo "Done running"
