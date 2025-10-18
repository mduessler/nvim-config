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
	docker build -f $(env-path)/Dockerfile.fedora-install -t nvim-fedora:install-test .

build-install-ubuntu:
	docker build -f $(env-path)/Dockerfile.fedora-install -t nvim-ubuntu:install-test .

build-fedora:
	docker build -f $(env-path)/Dockerfile.dev-fedora -t nvim-fedora:test .

build-lua-ubuntu:
	docker build -f $(env-path)/Dockerfile.ubuntu-lua -t nvim-ubuntu:test .

test-install-fedora: build-install-fedora
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-fedora:install-test

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

test-lua-ubuntu: build-lua-ubuntu
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
