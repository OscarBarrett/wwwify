VERSION := $(shell cat VERSION)

.PHONY: compile
compile:
	./util/CompileSetupScript.sh

.PHONY: build
build:
	docker build -t wwwify:$(VERSION) --build-arg version=$(VERSION) .
