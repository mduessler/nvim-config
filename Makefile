tests-install-dir="tests/install"
tests-lua-dir="tests/lua"
env-fedora="Dockerfile.fedora"
env-ubuntu="Dockerfile.ubuntu"

.PHONY: install

.SILENT:
.ONEHSELL:
build-install:
	docker build -f $(tests-install-dir)/$(env-fedora) -t nvim-fedora-install:test .
	docker build -f $(tests-install-dir)/$(env-ubuntu) -t nvim-ubuntu-install:test .

.SILENT:
.ONEHSELL:
build-lua:
	docker build -f $(tests-lua-dir)/$(env-fedora) -t nvim-fedora-lua:test .
	docker build -f $(tests-lua-dir)/$(env-ubuntu) -t nvim-ubuntu-lua:test .

.ONEHSELL:
install:
	$(MAKE) ./install
