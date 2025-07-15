# Claude Code Container

This repository contains the Docker container setup for running Claude Code (claude.ai/code) - Anthropic's CLI tool for interacting with Claude in a coding context.
It is based on Claude Code [devcontainer](https://github.com/anthropics/claude-code/blob/main/.devcontainer/Dockerfile)

The script [run-claude-docker.sh](./run-claude-docker.sh) is mainly aimed for use with bedrock. It supports specifying an AWS profile using the `-p` or `--profile` flag, or by setting the `AWS_PROFILE` environment variable.

use the [install-claude-docker.sh](./install-claude-docker.sh) to quickly add the mentioned run script to your `${HOME}/bin` folder

```bash
curl -fsSL https://raw.githubusercontent.com/giladrm/claude-code-container/main/install-claude-docker.sh | bash
```