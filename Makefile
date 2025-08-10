# Get the latest version of @anthropic-ai/claude-code
VERSION := $(shell npm view @anthropic-ai/claude-code version)
BUILD_DATE := $(shell date '+%Y-%m-%d %H:%M:%S')

.PHONY: help
help:
	@echo "Claude Code Container - Makefile Help"
	@echo "------------------------------------"
	@echo "This Makefile builds and deploys the Claude Code Docker container"
	@echo
	@echo "Available commands:"
	@echo "  help               : Show this help message"
	@echo "  show-last-version  : Display the latest version of @anthropic-ai/claude-code"
	@echo "  update-version-tag : Update version-tag.txt with build information"
	@echo "  build              : Build Docker images (both latest and version-tagged)"
	@echo "  build-test         : Build a test Docker image"
	@echo "  push               : Push Docker images to Docker Hub"
	@echo "  deploy             : Build and push Docker images (combines build and push)"
	@echo
	@echo "Usage examples:"
	@echo "  make help               # Show this help"
	@echo "  make build              # Build the Docker images"
	@echo "  make deploy             # Build and push the Docker images"

.PHONY: show-last-version
show-last-version:
	@echo "Latest @anthropic-ai/claude-code version: $(VERSION)"

.PHONY: update-version-tag
update-version-tag:
	@echo "Updating version-tag.txt with build information"
	@echo "Claude Code Version: $(VERSION)" > version-tag.txt
	@echo "Build Date: $(BUILD_DATE)" >> version-tag.txt

build: update-version-tag
	@echo "Building with @anthropic-ai/claude-code version: $(VERSION)"
	docker buildx build --platform linux/arm64 \
		--build-arg CLAUDE_CODE_VERSION=$(VERSION) \
		-t giladrm/claude-code:latest \
		-t giladrm/claude-code:$(VERSION) .

build-test:
	docker buildx build --platform linux/arm64 -t giladrm/claude-code:test .

push:
	docker push giladrm/claude-code:latest
	docker push giladrm/claude-code:$(VERSION)

.DEFAULT_GOAL := help

deploy: build push