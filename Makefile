env-path="./env"
env-install="DockerfileInstall"
env-lua="DockerfileLua"

.PHONY: install build-install build-lua

.ONEHSELL:
install:
	$(MAKE) ./install

.SILENT:
.ONEHSELL:
build-install:
	docker build -f $(env-path)/$(env-install).fedora -t nvim-fedora-install:test .
	docker build -f $(env-path)/$(env-install).ubuntu -t nvim-ubuntu-install:test .

.SILENT:
.ONEHSELL:
build-lua:
	docker build -f $(env-path)/$(env-lua).ubuntu -t nvim-fedora-lua:test .
	docker build -f $(env-path)/$(env-lua).ubuntu -t nvim-ubuntu-lua:test .
