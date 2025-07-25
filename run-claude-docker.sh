#!/bin/bash

set -e

# Default values
CONTAINER_NAME="claude-code-$(basename "$PWD")"
IMAGE="giladrm/claude-code"
START_NEW=false
SHELL_ONLY=false
DOCKER_EXTRA_OPTS=""  # Additional docker run options
AWS_PROFILE_ARG=""  # AWS profile name

# Function to show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Run Claude Code in Docker container with automated volume mounting.

OPTIONS:
    -n, --name NAME         Container name (default: claude-code-<current-dir>)
    -i, --image IMAGE       Docker image to use (default: $IMAGE)
    --new                   Start new conversation (ignore existing history)
    -s, --shell             Launch shell instead of Claude Code
    -d, --docker-opts OPTS  Additional docker run options (e.g. "--gpus all")
    -p, --profile NAME     AWS profile name to use
    -h, --help             Show this help message

EXAMPLES:
    $0                                           # Auto-detect: first run or resume
    $0 -n my-container                           # Custom container name
    $0 --new                                     # Start fresh conversation
    $0 -s                                        # Launch shell only
    $0 -d "--gpus all"                           # Run with GPU support
    $0 -d "-p 3000:3000"                         # Expose port 3000
    $0 -p my-aws-profile                         # Use specific AWS profile

ENVIRONMENT VARIABLES:
    AWS_SECRET_ACCESS_KEY   AWS secret access key
    AWS_ACCESS_KEY_ID       AWS access key ID
    AWS_PROFILE            AWS profile name (can also use -p flag)
    AWS_REGION             AWS region (default: us-west-2)

The script will:
- Mount current directory as /$(basename \$PWD)/ in container
- Mount .claude/ directory from current directory
- Create .claude.json in current directory if it doesn't exist
- Auto-detect conversation state:
  * No conversations: run without flags
  * One conversation: use --continue
  * Multiple conversations: use --resume (interactive)
  * Use --new flag to always start fresh
- Automatically change to mounted directory path in container
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -i|--image)
            IMAGE="$2"
            shift 2
            ;;
        --new)
            START_NEW=true
            shift
            ;;
        -s|--shell)
            SHELL_ONLY=true
            shift
            ;;
        -d|--docker-opts)
            DOCKER_EXTRA_OPTS="$2"
            shift 2
            ;;
        -p|--profile)
            AWS_PROFILE_ARG="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
# Use command-line argument for AWS_PROFILE if provided, otherwise use environment variable
AWS_PROFILE="${AWS_PROFILE_ARG:-$AWS_PROFILE}"
# Set default AWS region if not provided
AWS_REGION="${AWS_REGION:-us-west-2}"

# Create .claude.json in current directory if it doesn't exist
CLAUDE_JSON_PATH="$PWD/.claude.json"
if [[ ! -f "$CLAUDE_JSON_PATH" ]]; then
    echo "Creating $CLAUDE_JSON_PATH..."
    echo '{}' > "$CLAUDE_JSON_PATH"
fi

# Create .claude/ directory if it doesn't exist
CLAUDE_DIR="$PWD/.claude"
if [[ ! -d "$CLAUDE_DIR" ]]; then
    echo "Creating $CLAUDE_DIR directory..."
    mkdir -p "$CLAUDE_DIR"
fi

# Count existing conversations by checking .claude/projects directory
CONV_COUNT=0
if [[ -d "$CLAUDE_DIR" ]]; then
    # Create encoded project path (replace / with - and _ with -)
    ENCODED_PATH="-$(basename "$PWD" | sed 's/_/-/g')"
    PROJECT_DIR="$CLAUDE_DIR/projects/$ENCODED_PATH"
    
    if [[ -d "$PROJECT_DIR" ]]; then
        # Count .jsonl files with actual conversation content
        CONV_COUNT=0
        for file in "$PROJECT_DIR"/*.jsonl; do
            if [[ -f "$file" ]]; then
                # Check if file has more than just whitespace/empty lines
                if [[ $(wc -c < "$file" 2>/dev/null || echo 0) -gt 10 ]]; then
                    ((CONV_COUNT++))
                fi
            fi
        done
    fi
fi

echo "Found $CONV_COUNT conversation file(s) for this project"

# Get current directory basename for container path
CONTAINER_PATH="/$(basename "$PWD")/"

# Build command based on flags and conversation count
if [[ "$SHELL_ONLY" == "true" ]]; then
    CLAUDE_CMD="cd $CONTAINER_PATH && /bin/zsh"
    echo "Launching shell only (--shell flag used)"
else
    CLAUDE_CMD="cd $CONTAINER_PATH && claude"
    if [[ "$START_NEW" == "true" ]]; then
        echo "Starting new conversation (--new flag used)"
    elif [[ $CONV_COUNT -eq 0 ]]; then
        echo "No existing conversations - starting fresh"
    elif [[ $CONV_COUNT -eq 1 ]]; then
        CLAUDE_CMD="$CLAUDE_CMD --continue"
        echo "One conversation found - using --continue"
    else
        CLAUDE_CMD="$CLAUDE_CMD --resume"
        echo "Multiple conversations found - using --resume (interactive selection)"
    fi
fi

echo "Running Docker container..."
echo "Container name: $CONTAINER_NAME"
echo "Container path: $CONTAINER_PATH"
echo "Claude command: $CLAUDE_CMD"
echo

# Print extra Docker options if provided
if [[ -n "$DOCKER_EXTRA_OPTS" ]]; then
    echo "Extra Docker options: $DOCKER_EXTRA_OPTS"
fi
echo

# Use eval to properly handle quoted arguments in DOCKER_EXTRA_OPTS
docker run --rm \
    --name "$CONTAINER_NAME" \
    $DOCKER_EXTRA_OPTS \
    -v "${PWD}:${CONTAINER_PATH}" \
    -v "${CLAUDE_DIR}:/home/node/.claude/" \
    --mount type=bind,source="$CLAUDE_JSON_PATH",target=/home/node/.claude.json \
    --mount type=bind,source="${HOME}/.aws",target=/home/node/.aws,ro \
    -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    -e AWS_PROFILE="$AWS_PROFILE" \
    -e CLAUDE_CODE_USE_BEDROCK=1 \
    -e AWS_REGION="$AWS_REGION" \
    -it \
    "$IMAGE" \
    /bin/zsh -c "$CLAUDE_CMD"
