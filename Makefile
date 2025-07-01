build:
	docker buildx build --platform linux/arm64 -t giladrm/claude-code:latest .

build-test:
	docker buildx build --platform linux/arm64 -t giladrm/claude-code:test .

push:
	docker push giladrm/claude-code:latest
