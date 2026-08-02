.SILENT:
.ONESHELL:
.PHONY: install install-dev remote-login build-remote-environments test-fedora

install:
	./install

install-dev:
	./install dev

remote-login:
	scripts/containers login

fedora-unit-tests-local:
	scripts/containers unit-test fedora

fedora-install-test-local:
	scripts/containers install-test fedora

fedora-build-remote:
	scripts/containers build-remote fedora

ubuntu-unit-tests-local:
	scripts/containers unit-test ubuntu

ubuntu-install-test-local:
	scripts/containers install-test ubuntu

ubuntu-build-remote:
	scripts/containers build-remote ubuntu

build-remote-environments:
	scripts/containers build-remote

test-fedora: fedora-install-test-local fedora-unit-tests-local
