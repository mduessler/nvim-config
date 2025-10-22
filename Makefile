# NVIM v0.11.4 <==> NVIM v${MAJRO_REQ}.${MINOR_REQ}.${PATCH_REQ}
major-req=0
minor-req=11
patch-req=4

env-path="./env"
env-install="DockerfileInstall"
env-lua="DockerfileLua"
env-fedora-base="./env/fedora/Dockerfile.base"
env-fedora-local="./env/fedora/Dockerfile.local"
env-fedora-remote="./env/fedora/Dockerfile.remote"
env-fedora-install="./env/fedora/Dockerfile.install"

.SILENT:
.ONESHELL:
.PHONY: install install-dev build-install build-lua

install:
	./install

install-dev:
	./install dev

build-fedora-base-environment:
	docker build -f $(env-fedora-base) \
		--build-arg MAJOR_REQ=$(major-req) \
		--build-arg MINOR_REQ=$(minor-req) \
		--build-arg PATCH_REQ=$(patch-req) \
		-t fedora-nvim:base .

fedora-unit-tests-local: build-fedora-base-environment
	docker build -f $(env-fedora-local) \
		--pull=false \
		-t nvim-fedora:test .
	docker run nvim-fedora:test

fedora-unit-tests-remote:
	@read -p "Enter your GitHub username: " GITHUB_USERNAME;
	@read -p "Enter your GitHub PAT: " GITHUB_TOKEN; \
	echo "$$GITHUB_TOKEN" | docker login ghcr.io -u "$$GITHUB_USERNAME" --password-stdin
	docker build -f $(env-fedora-remote) \
		--pull=false \
		-t ghcr.io/mduessler/nvim:fedora .
	docker push ghcr.io/mduessler/nvim:fedora

fedora-install-tests:
	docker build -f $(env-fedora-install)\
		-t nvim-fedora:install .
	@regex="^On branch (.*)"; \
	if [[ $$(git status 2>/dev/null | head -1) =~ $${regex} ]]; then \
		docker run --rm \
			-e BRANCH_TO_TEST="$${BASH_REMATCH[1]}" \
			nvim-fedora:install
	fi

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

test-ubuntu: test-install-ubuntu test-lua-ubuntu

clean:
	docker image rm nvim-fedora:test
	docker image rm nvim-ubuntu:test
	docker image rm nvim-fedora:install-test
