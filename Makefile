.SILENT:
.ONESHELL:
.PHONY: install install-dev test-fedora

install:
	./install

install-dev:
	./install dev

fedora-unit-tests-local:
	scripts/containers unit-test fedora

fedora-install-test-local:
	scripts/containers install-test fedora

ubuntu-unit-tests-local:
	scripts/containers unit-test ubuntu

ubuntu-install-test-local:
	scripts/containers install-test ubuntu

test-fedora: fedora-install-test-local fedora-unit-tests-local
