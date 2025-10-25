# NVIM v0.11.4 <==> NVIM v${MAJRO_REQ}.${MINOR_REQ}.${PATCH_REQ}
major-req=0
minor-req=11
patch-req=4

env-path="./env"
env-install="DockerfileInstall"
env-lua="DockerfileLua"
env-fedora="./env/fedora/Dockerfile"
env-ubuntu="./env/ubuntu/Dockerfile"

.SILENT:
.ONESHELL:
.PHONY: install install-dev build-install build-lua

install:
	./install

install-dev:
	./install dev

remote-login:
	@read -p "Enter your GitHub username: " GITHUB_USERNAME;
	@read -p "Enter your GitHub PAT: " GITHUB_TOKEN; \
	echo "$$GITHUB_TOKEN" | docker login ghcr.io -u "$$GITHUB_USERNAME" --password-stdin

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

fedora-tests-remote: remote-login
	docker build -f $(env-fedora) \
		--pull=false \
		--target=remote \
		--build-arg MAJOR_REQ=$(major-req) \
		--build-arg MINOR_REQ=$(minor-req) \
		--build-arg PATCH_REQ=$(patch-req) \
		-t ghcr.io/mduessler/fedora-nvim:unit-test .
	docker build -f $(env-fedora)\
		--target=install \
		-t ghcr.io/mduessler/fedora-nvim:install-test .
	docker push ghcr.io/mduessler/fedora-nvim:unit-test
	docker push ghcr.io/mduessler/fedora-nvim:install-test

ubuntu-unit-tests-local:
	docker build -f $(env-ubuntu) \
		--target=local \
		--build-arg MAJOR_REQ=$(major-req) \
		--build-arg MINOR_REQ=$(minor-req) \
		--build-arg PATCH_REQ=$(patch-req) \
		-t ubuntu-nvim:unit-test .
	docker run --rm ubuntu-nvim:unit-test

ubuntu-install-test-local:
	docker build -f $(env-ubuntu) \
		--target=install-local \
		-t ubuntu-nvim:install-test .
	@regex="^On branch (.*)"; \
	if [[ $$(git status 2>/dev/null | head -1) =~ $${regex} ]]; then \
		docker run --rm \
			-e BRANCH_TO_TEST="$${BASH_REMATCH[1]}" \
			ubuntu-nvim:install-test
	fi

ubuntu-tests-remote: remote-login
	docker build -f $(env-ubuntu) \
		--pull=false \
		--target=remote \
		--build-arg MAJOR_REQ=$(major-req) \
		--build-arg MINOR_REQ=$(minor-req) \
		--build-arg PATCH_REQ=$(patch-req) \
		-t ghcr.io/mduessler/ubuntu-nvim:unit-test .
	docker build -f $(env-ubuntu)\
		--target=install \
		-t ghcr.io/mduessler/ubuntu-nvim:install-test .
	docker push ghcr.io/mduessler/ubuntu-nvim:unit-test
	docker push ghcr.io/mduessler/ubuntu-nvim:install-test


test-fedora: fedora-install-test-local fedora-unit-tests-local

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
