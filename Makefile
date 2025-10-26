# NVIM v0.11.4 <==> NVIM v${MAJRO_REQ}.${MINOR_REQ}.${PATCH_REQ}
major-req=0
minor-req=11
patch-req=4

env-fedora="./env/fedora/Dockerfile"

env-path="./env"
env-install="DockerfileInstall"
env-lua="DockerfileLua"

.SILENT:
.ONESHELL:
.PHONY: install

install:
	./install

install-dev:
	./install dev

remote-login:
	[ -z $${GITHUB_USERNAME} ] && read -p "Enter your GitHub username: " GITHUB_USERNAME
	[ -z $${GITHUB_TOKEN} ] && read -p "Enter your GitHub PAT: " GITHUB_TOKEN
	echo "$${GITHUB_TOKEN}" | docker login ghcr.io -u "$${GITHUB_USERNAME}" --password-stdin

fedora-unit-tests-local:
	docker build -f $(env-fedora) \
		--target=local \
		--build-arg MAJOR_REQ=$(major-req) \
		--build-arg MINOR_REQ=$(minor-req) \
		--build-arg PATCH_REQ=$(patch-req) \
		-t fedora-nvim:unit-test .
	docker run --rm fedora-nvim:unit-test

fedora-install-test-local:
	docker build -f $(env-fedora)\
		--target=install-local \
		-t fedora-nvim:install-test .
	@regex="^On branch (.*)"; \
	if [[ $$(git status 2>/dev/null | head -1) =~ $${regex} ]]; then \
		docker run --rm \
			-e BRANCH_TO_TEST="$${BASH_REMATCH[1]}" \
			fedora-nvim:install-test
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
