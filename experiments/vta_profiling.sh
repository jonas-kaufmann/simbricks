#!/bin/bash
# perf record -F 997 -g -o perf_gt-rtl.data python run.py --verbose --force --filter="vtatest-gt-rtl" pyexps/vtatest.py
# perf record -F 997 -g -o perf_gt-lpn.data python run.py --verbose --force --filter="vtatest-gt-lpn" pyexps/vtatest.py
perf record -F 997 -g -o perf_qt-rtl.data python run.py --verbose --force --filter="vtatest-qt-rtl" pyexps/vtatest.py
perf record -F 997 -g -o perf_qt-lpn.data python run.py --verbose --force --filter="vtatest-qt-lpn" pyexps/vtatest.py

perf script -i perf_gt-rtl.data | stackcollapse-perf.pl --all | flamegraph.pl > flamegraph-gt-rtl.svg &
perf script -i perf_gt-lpn.data | stackcollapse-perf.pl --all | flamegraph.pl > flamegraph-gt-lpn.svg &
perf script -i perf_qt-rtl.data | stackcollapse-perf.pl --all | flamegraph.pl > flamegraph-qt-rtl.svg &
perf script -i perf_qt-lpn.data | stackcollapse-perf.pl --all | flamegraph.pl > flamegraph-qt-lpn.svg &
wait
