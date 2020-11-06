NAME= md5
SRC= md5

CCFLAGS := $(CCFLAGS) -DNODPRINTF #-DFAULTINJECTION

TX_RUNTIME_FLAGS := $(TX_RUNTIME_FLAGS) -D THRESHOLD=5000

# LIBS := -pthread $(LIBS)

TX_PASS_FLAGS := $(TX_PASS_FLAGS) -called-from-outside=md5_thread

include ../../Makefile.$(ACTION)
