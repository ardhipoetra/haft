IMG_NAME = haftv3
CONTAINER_NAME = haft_container_v3

DOCKER = docker
DOCKER_RUN = $(DOCKER) run --cap-add SYS_ADMIN -it -v `pwd`/data:/data

.PHONY: all build run clean stop clean_all

all: build

build:
	@$(DOCKER) build --rm=true -t $(IMG_NAME) .

run:
	@$(DOCKER_RUN) --name=$(CONTAINER_NAME) $(IMG_NAME)

start:
	@$(DOCKER) start -i $(CONTAINER_NAME)

stop:
	@$(DOCKER) stop $(CONTAINER_NAME)

deploy:
	@$(DOCKER) tag -f $(IMG_NAME) tudinfse/haft
	@$(DOCKER) push tudinfse/haft

clean:
	@$(DOCKER) rm $(CONTAINER_NAME)

clean_all:
	@$(DOCKER) rm $(CONTAINER_NAME)
	@$(DOCKER) rmi $(IMG_NAME)
