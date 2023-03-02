#!/bin/bash

replacement_policies="crit lru drrip srrip"

if command -v module; then
    module load gcc/12.2.0
fi

function compile {
    pushd "ChampSim"
    ./config.sh $1
    make -j $(nproc)
    make clean
    popd
}

for repl in $replacement_policies; do
    echo "Compiling ChampSim with $repl replacement"
    compile "$(realpath config/${repl}_config.json)"
done

echo "Done compilation"
