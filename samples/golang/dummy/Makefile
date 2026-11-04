# dummy Makefile

BINARY_NAME := dummy

BUILD_DIR := build
BIN_DIR := bin

DIST_DIR := $(BUILD_DIR)/dist
PACKAGE_DIR := $(BUILD_DIR)/package

OS := $(shell go env GOOS)
ARCH := $(shell go env GOARCH)

LDFLAGS := -s -w

WORKSPACE_FOLDER := $(CURDIR)

## help: Show this help
.PHONY: help
help:
	@echo "Usage: make [task]"
	@echo ""
	@sed -n 's/^## //p' $(MAKEFILE_LIST) | column -t -s ':' | sed 's/^/  /'

## all: Run every task
.PHONY: all
all: clean vet fmt-lint test coverage coverage-html build test-acceptance

## clean: Remove build artifacts
.PHONY: clean
clean:
	@echo "Running clean..."
	@rm -rf $(BIN_DIR) $(BUILD_DIR)

## vet: Run go vet on all packages, including the integration and acceptance tests
.PHONY: vet
vet:
	go vet -tags "integration acceptance" ./...

## fmt-lint: Check source code is formatted, without changing anything
.PHONY: fmt-lint
fmt-lint:
	@echo "Checking source formatting"
	@unformatted=$$(gofmt -l .); \
	if [ -n "$$unformatted" ]; then \
		echo "The following files are not gofmt-formatted:"; \
		echo "$$unformatted"; \
		exit 1; \
	fi

## build: Compile the binary
.PHONY: build
build:
	@echo "Running build..."
	@mkdir -p $(BIN_DIR)
	go build -ldflags "$(LDFLAGS)" -o $(BIN_DIR)/$(BINARY_NAME) ./cmd

## test: Run the tests
.PHONY: test
test:
	@echo "Running tests..."
	go test -v -tags integration -race -count=1 ./...

## test-acceptance: Run the acceptance tests
.PHONY: test-acceptance
test-acceptance: build
	@echo "Running acceptance tests..."
	DUMMY_BINARY=$(WORKSPACE_FOLDER)/$(BIN_DIR)/$(BINARY_NAME) go test -v -tags acceptance -run TestAcceptance -race -count=1 ./...

## coverage: Run unit and integration tests with the race detector, then print a function coverage report
.PHONY: coverage
coverage:
	@mkdir -p $(BUILD_DIR)
	go test -v -tags integration -race -count=1 -coverprofile=$(BUILD_DIR)/coverage.out -covermode=atomic ./...
	go tool cover -func=$(BUILD_DIR)/coverage.out

## coverage-summary: Print the total coverage percentage of an existing coverage profile
.PHONY: coverage-summary
coverage-summary:
	@go tool cover -func=$(BUILD_DIR)/coverage.out | awk '/^total:/ {print $$3}'

## coverage-html: Generate an HTML report from an existing coverage profile
.PHONY: coverage-html
coverage-html:
	go tool cover -html=$(BUILD_DIR)/coverage.out -o $(BUILD_DIR)/coverage.html

## package: Package the binary and related files into a tar.gz archive
.PHONY: package
package: build
	@mkdir -p $(PACKAGE_DIR) $(DIST_DIR)
	cp -r $(BIN_DIR)/$(BINARY_NAME) LICENSE README.md CHANGELOG.md $(PACKAGE_DIR)/
	tar -czf $(DIST_DIR)/$(BINARY_NAME)-$(OS)-$(ARCH).tar.gz -C $(PACKAGE_DIR) .
