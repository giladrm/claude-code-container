# BUILD.md

This file provides guidance to building Claude Code container (claude.ai/code) when working with code in this repository.

## Development Standards

When modifying this codebase, follow these guidelines:

### Dockerfile Best Practices

- Keep the base image lightweight (node:20-slim)
- Consolidate RUN commands where possible to reduce layers
- Clean up apt cache after installations
- Use specific versions for packages when possible
- Follow security best practices (run as non-root, limit permissions)

### Shell Script Standards

- Include proper error handling and exit codes
- Validate inputs and environment variables
- Use proper quoting for variables
- Include meaningful error messages
- Document script purpose and usage

### Git Workflow

- Commit with descriptive messages
- Group related changes
- Validate functionality before pushing

## Common Development Tasks

### Updating Package Versions

When updating package versions in the Dockerfile:
1. Research compatibility of new versions
2. Update the specific package version
3. Test the build and functionality
4. Document changes in commit message
5. update tagged version in version-tag.txt file

### Adding New Dependencies

When adding new dependencies to the Dockerfile:
1. Add the dependency to the appropriate apt install command
2. Consider impact on image size and build time
3. Ensure compatibility with existing packages
4. Test the build with the new dependency

### Modifying Environment Variables

When adding/modifying environment variables:
1. Update both the Dockerfile and .env-template
2. Document the purpose of the variable
3. Provide sensible defaults where possible
