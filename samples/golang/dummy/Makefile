# dummy Makefile

BINARY_NAME := dummy
BIN_DIR := bin

LDFLAGS := -s -w


## help: Show this help
.PHONY: help
help:
	@echo "Usage: make [task]"
	@echo ""
	@sed -n 's/^## //p' $(MAKEFILE_LIST) | column -t -s ':' | sed 's/^/  /'

## all: Run every task
.PHONY: all
all: test build

## clean: Remove build artifacts
.PHONY: clean
clean:
	@rm -rf $(BIN_DIR)

## build: Compile the binary
.PHONY: build
build:
	@mkdir -p $(BIN_DIR)
	go build -ldflags "$(LDFLAGS)" -o $(BIN_DIR)/$(BINARY_NAME) ./cmd

## test: Run the tests
.PHONY: test
test:
	go test -tags integration -race -count=1 ./...
