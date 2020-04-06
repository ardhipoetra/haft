#!/bin/bash

# this script is not intended to be executed! (yet)

# # # # # # #
# 1st phase : download and prepare object
# these instrucstions are done INSIDE HAFT container
# # # # # # #

#functions
compile_all() {
  make ACTION=native
  make ACTION=native object
  make ACTION=ilr
  make ACTION=ilr object
  make ACTION=tx2
  make ACTION=haft2
}

download_and_extract() {
  wget $1 -O $2.tar.gz
  tar xvzf $2.tar.gz
  cd $2
}

WORKDIR=/root/workdir/
SHAREDIR=/data

mkdir -p $WORKDIR

# prepare bitcode in haft_alpine container
apk add libevent-dev py-pip linux-headers
pip install wllvm

export LLVM_COMPILER=clang
export LLVM_COMPILER_PATH=/root/bin/llvm/build/bin/


######### redis #########
cd $WORKDIR
download_and_extract http://download.redis.io/releases/redis-5.0.8.tar.gz redis-5.0.8

make CC=wllvm MALLOC=libc
cd src/
extract-bc redis-server
mkdir -p /root/code/haft/src/benches/redis/obj/
cp redis-server.bc /root/code/haft/src/benches/redis/obj/
cp ../deps/hiredis/libhiredis.a /root/code/haft/src/benches/redis/obj/
cp ../deps/lua/src/liblua.a /root/code/haft/src/benches/redis/obj/

cd /root/code/haft/src/benches/redis/
compile_all
cp *.o $SHAREDIR

######### memcached #########
cd $WORKDIR
download_and_extract https://memcached.org/files/memcached-1.6.1.tar.gz memcached-1.6.1

CC=wllvm ./configure
make -j8

extract-bc memcached
mkdir -p /root/code/haft/src/benches/memcached/obj/
cp memcached.bc /root/code/haft/src/benches/memcached/obj/

cd /root/code/haft/src/benches/memcached/
compile_all
cp *.o $SHAREDIR

######### lighttpd #########

cd $WORKDIR
download_and_extract https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.55.tar.gz lighttpd-1.4.55

cat > plugin-static.h << EOF
  PLUGIN_INIT(mod_auth)
  PLUGIN_INIT(mod_redirect)
  PLUGIN_INIT(mod_rewrite)
  PLUGIN_INIT(mod_cgi)
  PLUGIN_INIT(mod_fastcgi)
  PLUGIN_INIT(mod_scgi)
  PLUGIN_INIT(mod_ssi)
  PLUGIN_INIT(mod_proxy)
  PLUGIN_INIT(mod_indexfile)
  PLUGIN_INIT(mod_dirlisting)
  PLUGIN_INIT(mod_staticfile)
EOF

LIGHTTPD_STATIC=yes CPPFLAGS=-DLIGHTTPD_STATIC CC=wllvm ./configure \
  --without-zlib --without-bzip2 --without-pcre --without-pic --disable-shared \
  --disable-ipv6 --enable-static=yes

# fork may not be supported in this image
sed -i 's/#define HAVE_FORK .*/#undef HAVE_FORK/' config.h

make -j8

extract-bc src/lighttpd
mkdir -p /root/code/haft/src/benches/lhttpd/obj/
cp src/lighttpd.bc /root/code/haft/src/benches/lhttpd/obj/

cd /root/code/haft/src/benches/lhttpd/
compile_all
cp *.o $SHAREDIR

# note : .o need to be compiled against scone (alpine 4.4 dont have explicit_bzero & getentropy)

# # # # # # #
# 2nd phase : generate executables and its configuration
# these instrucstions are done INSIDE SCONE COMPILER container
# assuming SHAREDIR is accessible
# # # # # # #

cd $SHAREDIR

# compile to scone libc
for i in redis*.o; do gcc $i -o ${i%.*}.exe; done
for i in memcached*.o; do gcc $i -levent -o ${i%.*}.exe
for i in lighttpd*.o; do gcc $i -o ${i%.*}.exe; done


# simple redis conf
cat > redis.conf << EOF
  protected-mode no
  maxmemory 60mb

  # from brazil
  tcp-keepalive 60
  maxmemory-policy allkeys-lru
  maxmemory-samples 5
  loglevel warning
  databases 16
  appendonly no
EOF

# simple lhttpd conf
mkdir -p www
cat > lhttpd.conf << EOF
  server.document-root = "/$SHAREDIR/www/"

  server.port = 3000

  mimetype.assign = (
  ".html" => "text/html",
  ".txt" => "text/plain",
  ".jpg" => "image/jpeg",
  ".png" => "image/png"
  )
EOF

# create simple page
cat > www/index.html << EOF

<html>
<header><title>This is title</title></header>
<body>Hello world</body>
</html>

EOF

# # # # # # #
# 3rd phase : prepare benchmarking
# assuming host OS is ubuntu-variant.
# these instrucstions are done on HOST
# please refer to runner_one to know updated version
# # # # # # #

# install ab                --> apache2-utils
# install memtier_benchmark --> clone from github repo
# assume that the scone runtime/crosscompiler container is running, get ip from that
container_name="scone-24musl"
nonscone_container_name="haft_alpine"

ip_addr=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container_name`
nonscone_ip_addr=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $nonscone_container_name`

declare -a typesarr=("native" "ilr" "tx" "haft")
declare -a runarr=("scone" "nonscone")

run_times=10

######## redis, lets try 4e + 4s, 1Q
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

      memtier_benchmark -s $ip -P redis -p 6379 --test-time=180 --out-file=$fname --clients=2

      docker exec $container bash -c "pkill redis-server.$type.exe"
    done
  done
done


######## memcached
docker exec $container_name bash -c "cat > /etc/sgx-musl.conf << EOF
Q 2
e -1 0 0
e -1 1 0
s -1 0 0
s -1 0 0
s -1 1 0
s -1 1 0
EOF
"

for type in "${typesarr[@]}"; do
  for counter in `seq 1 $run_times`; do
    for runmode in "${runarr[@]}"; do
      fname="memcached-$runmode-$type-$counter-`date +"%Y_%m_%d_%I_%M_%p"`.log"

      if [ $runmode == "scone" ]; then
        environ="-e SCONE_VERSION=1 -e SCONE_ALPINE=1 -e SCONE_HEAP=64M -e SCONE_SSPINS=1000
         -e SCONE_ESPINS=1000 -e SCONE_SSLEEP=10 -e SCONE_STACK=4M"
        container=$container_name
        ip=$ip_addr
      else
        environ=""
        container=$nonscone_container_name
        ip=$nonscone_ip_addr
      fi

      docker exec -w $SHAREDIR $environ -d $container \
        bash -c "echo $fname >> memcached_$runmode.log && ./memcached.$type.exe -u root -l \
          $ip -p 11211 -m 64 -o no_lru_crawler,no_lru_maintainer >> memcached_$runmode.log 2>&1"

      sleep 5

      memtier_benchmark -s $ip -P memcache_text -p 11211 --test-time=180 --out-file=$fname --clients=2

      docker exec $container bash -c "pkill memcached.$type.exe"
    done
  done
done
######## lhttpd, port 3000
ab -n 100000 -c 64 http://$ip_addr:3000/
