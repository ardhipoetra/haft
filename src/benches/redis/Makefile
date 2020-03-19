NAME= redis-server
SRC = redis-server

CCFLAGS := $(CCFLAGS)-lm -ldl -pthread -lrt obj/libhiredis.a obj/liblua.a

include ../Makefile.$(ACTION)
