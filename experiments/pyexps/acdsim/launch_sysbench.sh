#!/bin/bash

EXPS=(
sysbench-cpu-1--
sysbench-cpu-2--
sysbench-cpu-4--
sysbench-mem-1-read-seq
sysbench-mem-1-write-seq
sysbench-mem-2-read-seq
sysbench-mem-2-write-seq
sysbench-mem-4-read-seq
sysbench-mem-4-write-seq
sysbench-mem-1-read-rnd
sysbench-mem-1-write-rnd
)

for EXP in ${EXPS[@]}; do
    CMD="python run.py --verbose --force --filter=${EXP} pyexps/acdsim/sysbench.py; bash"
    echo $CMD
    tmux new-window -d -n ${EXP} "$CMD"
done
