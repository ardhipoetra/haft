#!/bin/bash

#==============================================================================#
# Run Phoenix benchmarks:
#   - on large inputs
#   - use taskset -c 0-.. to limit number of CPUs
#==============================================================================#

set -x #echo on

#============================== PARAMETERS ====================================#
MATRIXMULSIZE=4000

declare -a benchmarks=( \
"histogram" \
"kmeans" \
"kmeans_nosharing" \
"linear_regression" \
"matrix_multiply" \
"pca" \
"string_match" \
"word_count" \
"word_count_nosharing" \
)

declare -a benchinputs=(\
"input/large.bmp"\                 # histogram
"-d 4 -c 400 -p 400000 -s 4000"\   # kmeans -- dont need anything
"-d 4 -c 400 -p 400000 -s 4000"\   # kmeans_nosharing -- dont need anything
"input/key_file_500MB.txt"\        # linear
"$MATRIXMULSIZE"\                  # matrix multiply (requires created files)
"-r 2000 -c 5000"\                 # pca
"input/key_file_500MB.txt"\        # string match
"input/word_100MB.txt"\            # word count
"input/word_100MB.txt"\            # take input from word count
)

declare -a threadsarr=(1 2 4 8 12 14)
declare -a typesarr=("native" "tx" "ilr" "haft")

#action="perf stat -e cpu/cpu-cycles/,cpu/cycles-t/,cpu/cycles-ct/"
#action="perf stat -e cycles,instructions -e tx-start,tx-commit,tx-abort -e tx-capacity,tx-conflict"
action="perf stat -e cycles,instructions -e tx-start,tx-commit,tx-abort -e tx-capacity,tx-conflict
        -e page-faults,context-switches,migrations,branches,branch-misses
        -e L1-dcache-load-misses,LLC-load-misses,cache-misses,dTLB-load-misses,iTLB-load-misses"

#========================== EXPERIMENT SCRIPT =================================#
echo "===== Results for Phoenix benchmark ====="

# special case of matrix_multiply: need to create files
# Use TX version because it's safer.
./matrix_multiply.tx.exe $MATRIXMULSIZE 1 > /dev/null 2>&1

echo "=================== DOING SCONE-HW MODE ========================="
export SCONE_MODE=hw
export SCONE_STACK=64k
export SCONE_HEAP=64m
export SCONE_ESPINS=10000000

for bmidx in "${!benchmarks[@]}"; do
  bm="${benchmarks[$bmidx]}"
  in="${benchinputs[$bmidx]}"

  # dry run to load files into RAM.
  ./${bm}.tx.exe ${in} > /dev/null 2>&1

  for threads in "${threadsarr[@]}"; do
    for type in "${typesarr[@]}"; do

      echo "--- Running ${bm} ${threads} ${type} (input: '${in}') ---"
      lastthreadid=$((threads-1))
      ${action} taskset -c 0-${lastthreadid} ~/franz-perf/ld-scone-x86_64.so.1 ./${bm}.${type}.exe ${in}

    done  # type
  done  # threads
done # benchmarks

exit
echo "=================== DOING NATIVE MODE ========================="

for bmidx in "${!benchmarks[@]}"; do
  bm="${benchmarks[$bmidx]}"
  in="${benchinputs[$bmidx]}"

  # dry run to load files into RAM
  ./${bm}.tx.exe ${in} > /dev/null 2>&1

  for threads in "${threadsarr[@]}"; do
    for type in "${typesarr[@]}"; do

      echo "--- Running ${bm} ${threads} ${type} (input: '${in}') ---"
      lastthreadid=$((threads-1))
      ${action} taskset -c 0-${lastthreadid} ./scone/${bm}.${type}.exe ${in}


    done  # type
  done  # threads
done # benchmarks # times
