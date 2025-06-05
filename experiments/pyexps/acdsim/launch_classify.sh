#!/bin/bash

WORKLOAD_OPTS=(resnet18 resnet34 resnet50 resnet101)
CLK_FREQ_OPTS=(100 174)
LOG_OPTS=(s10 s100 v100)

for WORKLOAD_OPT in ${WORKLOAD_OPTS[@]}; do
  for CLK_FREQ_OPT in ${CLK_FREQ_OPTS[@]}; do
    for LOG_OPT in ${LOG_OPTS[@]}; do
      EXP="${WORKLOAD_OPT}-vta-ga-4-${CLK_FREQ_OPT}-1x16-verilator-${LOG_OPT}"
      CMD="rm out/${EXP}-1.json; python run.py --verbose --filter=${EXP} pyexps/acdsim/classify_simple.py; bash"
      echo $CMD
      tmux new-window -d -n ${EXP} "$CMD"
    done
  done
done

LOG_OPTS=(v100)

for WORKLOAD_OPT in ${WORKLOAD_OPTS[@]}; do
  for LOG_OPT in ${LOG_OPTS[@]}; do
    EXP="${WORKLOAD_OPT}-cpu_arm64-ga-4-100-1x16-verilator-${LOG_OPTS}"
    CMD="rm out/${EXP}-1.json; python run.py --verbose --filter=${EXP} pyexps/acdsim/classify_simple.py; bash"
    echo $CMD
    tmux new-window -d -n ${EXP} "$CMD"
  done
done
