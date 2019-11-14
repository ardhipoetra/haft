#!/bin/bash

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

declare -a typesarr=("native" "ilr" "tx" "haft")

cd /root/code/haft/src/benches/phoenix_pthread/

echo "===== Generate object and executable ====="
for bm in "${benchmarks[@]}"; do
  rm ${bm}/*.o
  for type in "${typesarr[@]}"; do
    make -C ${bm} ACTION=${type} clean
    make -C ${bm} ACTION=${type}
    make -C ${bm} ACTION=${type} object
  done
done

#copy the object to /data/object
mkdir -p /data/objects
find . -name *.o -exec cp {} /data/objects/ \;

#copy the inputs to /data/input
find . -name input* -exec cp -r {} /data/ \;
