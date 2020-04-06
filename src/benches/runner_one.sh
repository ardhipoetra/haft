#!/bin/bash

container_name="scone-24musl"
nonscone_container_name="haft_alpine"

SHAREDIR=/data/exe/

ip_addr=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_name`
nonscone_ip_addr=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $nonscone_container_name`

declare -a typesarr=("ilr")
declare -a runarr=("nonscone")
declare -A apps=([redis]=1)

## examples
## declare -a typesarr=("native" "ilr" "tx" "haft")
## declare -a runarr=("scone" "nonscone")
## declare -A apps=([memcached]=1 [redis]=1 [lhttpd]=1)

run_times=30

mkdir -p logs/

######## redis
if [[ -n "${apps[redis]}" ]]; then
  ## lets try 4e + 4s, 1Q
  docker exec $container_name bash -c "cat > /etc/sgx-musl.conf << EOF
Q 1
e -1 0 0
e -1 0 0
e -1 0 0
e -1 0 0
s -1 0 0
s -1 0 0
s -1 0 0
s -1 0 0
EOF
  "

  for type in "${typesarr[@]}"; do
    for counter in `seq 1 $run_times`; do
      for runmode in "${runarr[@]}"; do
        fname="redis-$runmode-$type-$counter-`date +"%Y_%m_%d_%I_%M_%p"`.log"

        if [ $runmode == "scone" ]; then
          environ="-e SCONE_VERSION=1 -e SCONE_ALPINE=1 -e SCONE_HEAP=70M -e
            SCONE_SSPINS=1000 -e SCONE_SSLEEP=1 -e SCONE_STACK=4M -e SCONE_ESPINS=1000"
          container=$container_name
          ip=$ip_addr
        else
          environ=""
          container=$nonscone_container_name
          ip=$nonscone_ip_addr
        fi

        docker exec -w $SHAREDIR $environ -d $container \
          bash -c "echo $fname >> redis_$runmode.log && ./redis-server.$type.exe redis.conf >> redis_$runmode.log 2>&1"

        sleep 5

        memtier_benchmark -s $ip -P redis -p 6379 --test-time=180 --out-file=logs/$fname --clients=2

        docker exec $container bash -c "pkill redis-server.$type.exe"
      done
    done
  done
fi

######## memcached
if [[ -n "${apps[memcached]}" ]]; then
  docker exec $container_name bash -c "cat > /etc/sgx-musl.conf << EOF
Q 2
e 0 0 0
e 1 1 0
s 2 0 0
s 3 1 0
EOF
  "

  for type in "${typesarr[@]}"; do
    for counter in `seq 1 $run_times`; do
      for runmode in "${runarr[@]}"; do
        fname="memcached-$runmode-$type-$counter-`date +"%Y_%m_%d_%I_%M_%p"`.log"

        if [ $runmode == "scone" ]; then
          environ="-e SCONE_VERSION=1 -e SCONE_ALPINE=1 -e SCONE_HEAP=64M -e SCONE_SSPINS=50
          -e SCONE_ESPINS=1000 -e SCONE_SSLEEP=1 -e SCONE_STACK=4M"
          container=$container_name
          ip=$ip_addr
          task=""
        else
          environ=""
          container=$nonscone_container_name
          ip=$nonscone_ip_addr
          task="taskset -c 0-1" # 2 app threads
        fi

        docker exec -w $SHAREDIR $environ -d $container \
          bash -c "echo $fname >> memcached_$runmode.log && $task ./memcached.$type.exe -u root -l \
            $ip -p 11211 -m 64 -o no_lru_crawler,no_lru_maintainer -t 2 >> memcached_$runmode.log 2>&1"

        sleep 5

        taskset -c 4-5 memtier_benchmark -s $ip -P memcache_text -p 11211 --test-time=180 --out-file=logs/$fname --clients=2

        docker exec $container bash -c "pkill memcached.$type.exe"
      done
    done
  done
fi



######## lhttpd
if [[ -n "${apps[lhttpd]}" ]]; then
  docker exec $container_name bash -c "cat > /etc/sgx-musl.conf << EOF
Q 2
e 0 0 0
e 1 1 0
s 2 0 0
s 3 1 0
EOF
  "

  for type in "${typesarr[@]}"; do
    for counter in `seq 1 $run_times`; do
      for runmode in "${runarr[@]}"; do
        fname="lhttpd-$runmode-$type-$counter-`date +"%Y_%m_%d_%I_%M_%p"`.log"

        if [ $runmode == "scone" ]; then
          environ="-e SCONE_VERSION=1 -e SCONE_ALPINE=1 -e SCONE_HEAP=70M -e
            SCONE_SSPINS=1000 -e SCONE_SSLEEP=1 -e SCONE_STACK=4M -e SCONE_ESPINS=1000"
          container=$container_name
          ip=$ip_addr
        else
          environ=""
          container=$nonscone_container_name
          ip=$nonscone_ip_addr
        fi

        docker exec -w $SHAREDIR $environ -d $container \
          bash -c "echo $fname >> lhttpd_$runmode.log && ./lighttpd.$type.exe -D -f lhttpd.conf >> lhttpd_$runmode.log 2>&1"

        sleep 5

        ab -n 100000 -c 64 http://$ip:3000/ > logs/$fname

        docker exec $container bash -c "pkill lighttpd.$type.exe"

        sleep 2
      done
    done
  done
fi
