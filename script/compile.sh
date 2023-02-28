#!/bin/bash

replacement_policies="crit lru drrip srrip"

function compile {
    pushd "ChampSim"
    ./config.sh $1
    make -j $(nproc)
    popd
}

for repl in $replacement_policies; do
    echo "Compiling ChampSim with $repl replacement"
    compile "$(realpath config/${repl}_config.json)"
done

echo "Done compilation"
