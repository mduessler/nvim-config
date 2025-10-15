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

build-lua:
	docker build -f $(env-path)/$(env-lua).fedora -t nvim-fedora-lua:test .
	docker build -f $(env-path)/$(env-lua).ubuntu -t nvim-ubuntu-lua:test .

run-lua-fedora:
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-fedora-lua:test

run-lua-ubuntu:
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-ubuntu-lua:test
