DOCKER ?= $(shell which docker 2>/dev/null || which podman)
FEDORA_VERSION ?= 37
BUILD_ARGS ?= --no-cache --pull
REGISTRY ?= localhost

default: build

build:
	$(DOCKER) build $(BUILD_ARGS) --build-arg FEDORA_VERSION=$(FEDORA_VERSION) -t $(REGISTRY)/fedora-toolbox:$(FEDORA_VERSION) .

create:
	toolbox create -i fedora-toolbox:$(FEDORA_VERSION)

enter:
	toolbox enter fedora-toolbox-$(FEDORA_VERSION)

pre-commit:
	pre-commit install
	pre-commit run --all

.PHONY: build create default enter pre-commit
