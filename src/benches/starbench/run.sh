#!/bin/bash

#set -x #echo on

declare -a benchmarks=( \
"c-ray-mt" \
"kmeans" \
"md5" \
"rgbyuv" \
"rot-cc" \
"streamcluster" \
"tinyjpeg" \
"ray-rot" \
"rotate"
)
# x264

DATA_DIR="/data/starbench-input/"
STR_REPLACE="cn012l" #just random string

declare -a benchinputs=(\
"-o /dev/null -s 1920x1080 -r 2 -t $STR_REPLACE -i $DATA_DIR/c-ray/sphfract "\             # c-ray-mt
"-b -n 4000 -t $STR_REPLACE -p 0 -i $DATA_DIR/kmeans/edge"\                               # kmeans
"-i 4 -c 30 -t $STR_REPLACE -p 0"\                                                         # md5
"-c 500 -t $STR_REPLACE -p 0 -i $DATA_DIR/rotate_rgbyuv_workloads/rgbyuv_4t_64h.ppm"\  # rgbyuv
"$DATA_DIR/rotate_rgbyuv_workloads/rot-cc_4t_64h.ppm /dev/null 50 $STR_REPLACE 0"\     # rot-cc
"10 20 128 200000 100000 5000 none output.txt $STR_REPLACE 0"\                            # streamcluster
"--benchmark $DATA_DIR/tinyjpeg/img_50m_heap.jpg /dev/null $STR_REPLACE 0"\     # tinyjpeg
"$DATA_DIR/c-ray/sphfract /dev/null 50 1920 1080 1 $STR_REPLACE 0"\        # ray-rot
"$DATA_DIR/rotate_rgbyuv_workloads/rot-cc_4t_64h.ppm /dev/null 50 $STR_REPLACE 0"\        # rotate
)
# "--threads $STR_REPLACE --preset slow --keyint infinite --input-res 1920x1080 --rc-lookahead 0 --sync-lookahead 0 --ref 1 --bframes 1 --quiet --no-progress --sliced-threads -o ~/test.mkv $DATA_DIR/h264dec/big_buck_bunny_1080p24.h264"


declare -a threadsarr=(4 8 12)
declare -a typesarr=("native" "ilr" "tx" "haft")
NUM_RUNS=5
# action="perf stat -e cycles,instructions,task-clock,page-faults -e tx-start,tx-commit,tx-abort -e tx-capacity,tx-conflict"
action=""
# compiling
# for bm in "${benchmarks[@]}"; do
#   for type in "${typesarr[@]}"; do
#     # make -C ${bm} ACTION=${type} clean
#     make -C ${bm} ACTION=${type}
#   done
# done

for times in `seq 1 ${NUM_RUNS}`; do
for bmidx in "${!benchmarks[@]}"; do
  bm="${benchmarks[$bmidx]}"

  cd $bm

for type in "${typesarr[@]}"; do
for threads in "${threadsarr[@]}"; do
  in="${benchinputs[$bmidx]}"
  in=${in/$STR_REPLACE/$threads}

  echo "--- Running ${bm} ${threads} ${type} (input: '${in}') --- #$times"
  lastthreadid=$((threads-1))
  echo 3 > /proc/sys/vm/drop_caches 

  $action ./${bm}.${type}.exe ${in}

  sleep 1

done #threads
done #type

cd ../

done #bm
done #times
