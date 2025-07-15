# Get the latest version of @anthropic-ai/claude-code
VERSION := $(shell npm view @anthropic-ai/claude-code version)
BUILD_DATE := $(shell date '+%Y-%m-%d %H:%M:%S')

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

deploy: build push