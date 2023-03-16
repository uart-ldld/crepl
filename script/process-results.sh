#!/bin/bash

results_dir=$1

script/process-results trace/weights-and-simpoints-speccpu $results_dir > $results_dir/ipc.tsv
