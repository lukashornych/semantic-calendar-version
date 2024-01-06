CRYSTAL?=$(shell which crystal)
CRYSTAL_FLAGS=--release
CRYSTAL_STATIC_FLAGS=--static

VERSION?=$(shell cat .version)

all: fmt test build ## clean and produce target binary

.PHONY: test
test: ## runs crystal tests
	$(CRYSTAL) spec spec/*.cr

.PHONY: fmt
fmt: ## format the crystal sources
	$(CRYSTAL) tool format

build: ## compiles from crystal sources
	mkdir -p bin
	$(CRYSTAL) build $(CRYSTAL_FLAGS) src/main.cr -o bin/semantic-calendar-version

.PHONY: clean
clean: ## clean target directories
	rm -rf bin

.PHONY: help
help:
	@echo "make help"
	@echo "\n"
	@grep -E '^[a-zA-Z_/%\-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "\n"
