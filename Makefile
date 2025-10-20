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

build-install-fedora:
	docker build -f $(env-path)/Dockerfile.fedora-install -t nvim-fedora:install .

build-install-ubuntu:
	docker build -f $(env-path)/Dockerfile.fedora-install -t nvim-ubuntu:install-test .

build-fedora:
	docker build -f $(env-path)/Dockerfile.dev-fedora -t nvim-fedora:test .

build-ubuntu:
	docker build -f $(env-path)/Dockerfile.dev-ubuntu -t nvim-ubuntu:test .

test-install-fedora: build-install-fedora
	@regex="^On branch (.*)"; \
	if [[ $$(git status 2>/dev/null | head -1) =~ $${regex} ]]; then \
		docker run --rm \
			-e BRANCH_TO_TEST="$${BASH_REMATCH[1]}" \
			nvim-fedora:install
	fi

test-install-ubuntu: build-install-ubuntu
	docker run --rm nvim-ubuntu:install-test

tests-fedora: build-fedora
	docker run --rm nvim-fedora:test

tests-ubuntu: build-ubuntu
	docker run --rm nvim-ubuntu:test

test-fedora: test-install-fedora tests-fedora

test-ubuntu: test-install-ubuntu test-lua-ubuntu

test: test-fedora test-ubuntu

clean:
	docker image rm nvim-fedora:test
	docker image rm nvim-ubuntu:test
	docker image rm nvim-fedora:install-test
