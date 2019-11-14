IMG_NAME = haft-alpine
CONTAINER_NAME = haft_alpine

DOCKER = docker
DOCKER_RUN = $(DOCKER) run --privileged --cap-add SYS_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -it -v `pwd`/data:/data # -v /home/ardhi/Public/sde:/sde

.PHONY: all build run clean stop clean_all

all: build

build:
	@$(DOCKER) build --rm=true -t $(IMG_NAME) -f Dockerfile-alpine .

run:
	@$(DOCKER_RUN) --name=$(CONTAINER_NAME) $(IMG_NAME)

start:
	@$(DOCKER) start -i $(CONTAINER_NAME)

stop:
	@$(DOCKER) stop $(CONTAINER_NAME)

clean:
	@$(DOCKER) rm $(CONTAINER_NAME)

clean_all:
	@$(DOCKER) rm $(CONTAINER_NAME)
	@$(DOCKER) rmi $(IMG_NAME)
