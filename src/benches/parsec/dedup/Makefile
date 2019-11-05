NAME= dedup
SRC = dedup.opt

CCFLAGS := -pthread $(CCFLAGS)

TX_RUNTIME_FLAGS := $(TX_RUNTIME_FLAGS) -D THRESHOLD=500

TX_PASS_FLAGS := $(TX_PASS_FLAGS) -called-from-outside=Fragment -called-from-outside=FragmentRefine -called-from-outside=Deduplicate -called-from-outside=Compress -called-from-outside=Reorder

include ../../Makefile.$(ACTION)

$(NAME).ilr.exe: obj/$(NAME).ilr.bc $(addprefix obj/, $(LLS2))
	$(LLVM_LLC) -mattr="+sse4.2,+avx" -o obj/$(NAME).ilr.s -I $(INCLUDE_DIRS) -L $(LIB_DIRS) $^
	$(LLVM_CLANGPP) $(CCFLAGS) -o $@ obj/$(NAME).ilr.s -I $(INCLUDE_DIRS) -L $(LIB_DIRS) $(LIBS)

$(NAME).haft.exe: obj/$(NAME).haft.bc $(addprefix obj/, $(LLS2))
	$(LLVM_LLC) -mattr="+sse4.2,+avx,+rtm" -o obj/$(NAME).haft.s -I $(INCLUDE_DIRS) -L $(LIB_DIRS) $^
	$(LLVM_CLANGPP) $(CCFLAGS) -o $@ obj/$(NAME).haft.s -I $(INCLUDE_DIRS) -L $(LIB_DIRS) $(LIBS)

