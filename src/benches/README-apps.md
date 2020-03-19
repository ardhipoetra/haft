# httpd

to configure : 
```
CC=wllvm CCFLAGS="-Wl,--whole-archive" ./configure --enable-static-support --enable-mods-static=reallyall --disable-ssl
```
then make and make install


#light httpd
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
configure
```
CC=wllvm ./configure
```
make

# redis
just make
```
make CC=wllvm MALLOC=libc
```

copy the dependencies
```
../deps/hiredis/libhiredis.a
../deps/lua/src/liblua.a
```

then, compile as usual

