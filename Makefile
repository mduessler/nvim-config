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
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  -v "$$HOME/.local/share/src/nerd-fonts:/home/tester/.local/share/src/nerd-fonts" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-fedora:install

test-install-ubuntu: build-install-ubuntu
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-ubuntu:install-test

tests-fedora: build-fedora
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-fedora:test

tests-ubuntu: build-ubuntu
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-ubuntu:test

test-fedora: test-install-fedora tests-fedora

test-ubuntu: test-install-ubuntu test-lua-ubuntu

test: test-fedora test-ubuntu

clean:
	docker image rm nvim-fedora:test
	docker image rm nvim-ubuntu:test
	docker image rm nvim-fedora:install-test
