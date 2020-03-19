# Note

- compile the application using the following configurations. 
- Do not forget to use wllvm or gllvm to generate bitcode (.bc) after compilation.
	- apk add py-pip
	- pip install wllvm
	- config wllvm (set `LLVM_COMPILER` etc
- copy the bitcode to src/benches/<apps>/obj

# httpd

to configure : 
```
CC=wllvm CCFLAGS="-Wl,--whole-archive" ./configure --enable-static-support --enable-mods-static=reallyall --disable-ssl
```
then make and make install


# light httpd
configure
```
LIGHTTPD_STATIC=yes CPPFLAGS=-DLIGHTTPD_STATIC CC=wllvm ./configure --without-zlib --without-bzip2 --without-pcre --without-pic --disable-shared --disable-ipv6 --enable-static=yes
```

also, change the file(s) inside the source(s). See INSTALL
I didn't change the Makefile.am, but add stuff in plugin-static.h (those may be reduced, maybe)

```
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
```

then make

# memcached
download tar.gz from memcached website (or clone).
install libevent (dev?)
configure
```
CC=wllvm ./configure
```
make

## running
```
./memcached.native.exe -u root -l 172.17.0.3 -p 11211 -m 64 -o no_lru_crawler,no_lru_maintainer
```

# redis
install linux-headers (find linux/version.h)
just make
```
make CC=wllvm MALLOC=libc
```

copy the dependencies
```
../deps/hiredis/libhiredis.a
../deps/lua/src/liblua.a
```

then, compile with HAFT as usual

# cherokee

configure and make as usual
