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

build-lua-fedora:
	docker build -f $(env-path)/Dockerfile.fedora-lua -t nvim-fedora-lua:test .

build-lua-ubuntu:
	docker build -f $(env-path)/Dockerfile.ubuntu-lua -t nvim-ubuntu-lua:test .

test-lua-fedora: build-lua-fedora
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-fedora-lua:test

test-lua-ubuntu: build-lua-ubuntu
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-ubuntu-lua:test

test-fedora: test-lua-fedora

test-ubuntu: test-lua-fedora
