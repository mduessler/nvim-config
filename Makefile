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

build-lua-fedora:
	docker build -f $(env-path)/Dockerfile.fedora-lua -t nvim-fedora:lua-test .

build-lua-ubuntu:
	docker build -f $(env-path)/Dockerfile.ubuntu-lua -t nvim-ubuntu:lua-test .

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

test-lua-fedora: build-lua-fedora
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-fedora:lua-test

test-lua-ubuntu: build-lua-ubuntu
	docker run --rm \
	  -v "$$HOME/.config/nvim:/home/tester/.config/nvim:ro" \
	  --tmpfs /home/tester/.local/share/nvim \
	  --tmpfs /home/tester/.local/state/nvim \
	  --tmpfs /home/tester/.cache/nvim \
	  nvim-ubuntu:lua-test

test-fedora: test-install-fedora test-lua-fedora

test-ubuntu: test-install-ubuntu test-lua-ubuntu

clean:
	docker image rm nvim-fedora:lua-test
	docker image rm nvim-ubuntu:lua-test
	docker image rm nvim-fedora:install-test
