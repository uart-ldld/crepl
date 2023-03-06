#!/bin/bash -l

#SBATCH -A naiss2023-22-203
#SBATCH -p devcore
#SBATCH -n 8
#SBATCH -t 0:15:00

if command -v module; then
    module load gcc
fi

function compile {
    pushd "ChampSim"
    ./config.sh $1
    make -j $(nproc)
    make clean
    popd
}

echo "Using $(nproc) cores"

for config in config-$(git rev-parse --short HEAD)/*_config.json; do
    echo "Compiling ChampSim with $(basename $config)"
    compile "$(realpath $config)"
done

echo "Done compilation"
