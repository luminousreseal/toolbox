DOCKER ?= $(shell which docker 2>/dev/null || which podman)
FEDORA_VERSION ?= 37
BUILD_ARGS ?= --pull
REGISTRY ?= localhost
IMAGE ?= $(REGISTRY)/fedora-toolbox:$(FEDORA_VERSION)

default: build

build:
	$(DOCKER) build $(BUILD_ARGS) --file $(PWD)/Containerfile --build-arg FEDORA_VERSION=$(FEDORA_VERSION) --tag $(IMAGE) .

create:
	toolbox create -i fedora-toolbox:$(FEDORA_VERSION)

enter:
	toolbox enter fedora-toolbox-$(FEDORA_VERSION)

pre-commit:
	export PRE_COMMIT_HOME=.cache/pre-commit ; \
	pre-commit install && \
	pre-commit run --all

submodules:
	git submodule update --remote

test: build
ifdef CI
	$(DOCKER) run --rm -v $(PWD):/src:z $(IMAGE) bats /src/test
else
	$(DOCKER) run -it --rm -v $(PWD):/src:z $(IMAGE) bats /src/test
endif

.PHONY: default build create enter pre-commit submodules test
