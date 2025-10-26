# NVIM v0.11.4 <==> NVIM v${MAJRO_REQ}.${MINOR_REQ}.${PATCH_REQ}
major-req=0
minor-req=11
patch-req=4

env-path="./env"
env-install="DockerfileInstall"
env-lua="DockerfileLua"

.SILENT:
.ONESHELL:
.PHONY: install install-dev build-install build-lua

install:
	./install

install-dev:
	./install dev

build-install-ubuntu:
	docker build -f $(env-path)/Dockerfile.ubuntu-install -t nvim-ubuntu:install .

build-ubuntu:
	docker build -f $(env-path)/Dockerfile.dev-ubuntu -t nvim-ubuntu:test .

test-install-ubuntu: build-install-ubuntu
	@regex="^On branch (.*)"; \
	if [[ $$(git status 2>/dev/null | head -1) =~ $${regex} ]]; then \
		docker run --rm \
			-e BRANCH_TO_TEST="$${BASH_REMATCH[1]}" \
			nvim-ubuntu:install
	fi

tests-ubuntu: build-ubuntu
	docker run --rm nvim-ubuntu:test

test-fedora: test-install-fedora tests-fedora

test-ubuntu: test-install-ubuntu test-lua-ubuntu

test: test-fedora test-ubuntu

clean:
	docker image rm nvim-fedora:test
	docker image rm nvim-ubuntu:test
	docker image rm nvim-fedora:install-test
