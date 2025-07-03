# Claude Code Container

This repository contains the Docker container setup for running Claude Code (claude.ai/code) - Anthropic's CLI tool for interacting with Claude in a coding context.

## Overview

The Claude Code Container provides a standardized, reproducible environment for running Claude Code commands. It packages all necessary dependencies in a Docker container, ensuring consistent behavior across different systems and environments.

## Key Features

- Lightweight container based on node:20-slim
- Includes all necessary dependencies for Claude Code
- Automatically uses the latest version of @anthropic-ai/claude-code
- Version-tracked builds with proper tagging
- Security-focused installation methods for dependencies

## Build Instructions

### Prerequisites

- Docker installed on your system
- Docker Buildx for multi-architecture builds
- Make (for using the provided Makefile)

### Building the Container

To build the container with the latest Claude Code version:

```bash
make build
```

This command:
1. Fetches the latest @anthropic-ai/claude-code version from npm
2. Updates version-tag.txt with version and build date information
3. Builds the Docker image for your platform
4. Tags the image with both 'latest' and the specific version

To see the latest version without building:

```bash
make version
```

### Pushing to Registry

To push the built image to Docker Hub:

```bash
make push
```

## Usage

### Running Claude Code in the Container

```bash
docker run --rm -it giladrm/claude-code:latest claude-code <command>
```

### Easy Installation

You can install the run script easily using:

```bash
curl -fsSL https://raw.githubusercontent.com/giladrm/claude-code-container/main/install-claude-docker.sh | bash
```

This will:
1. Download the script to ~/bin/run-claude-docker.sh
2. Add ~/bin to your PATH if not already there
3. Make the script executable

After installation, you can run Claude Code using:

```bash
run-claude-docker.sh <command>
```

## Version Management

This project automatically detects and uses the latest version of the @anthropic-ai/claude-code npm package. Each Docker image is tagged with both:

- `latest`: Always points to the most recent build
- `x.y.z`: Version-specific tag matching the installed @anthropic-ai/claude-code version

This versioning scheme ensures you can pin to a specific version if needed for stability, or always use the latest.

## Development Standards

Please refer to [BUILD.md](BUILD.md) for development standards and best practices when contributing to this repository.

## License

[License information]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.