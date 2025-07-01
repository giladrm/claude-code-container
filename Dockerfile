FROM node:24-slim

ARG TZ
ENV TZ="$TZ"

RUN apt-get update && apt-get install -y \
  less \
  git \
  procps \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  ripgrep \
  jq \
  wget \
  curl \
  ca-certificates \
  python3 \
  python3-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

ENV DEVCONTAINER=true

RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

# Install Delta (safer binary installation)
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${ARCH}.deb" && \
  dpkg -i "git-delta_0.18.2_${ARCH}.deb" && \
  rm "git-delta_0.18.2_${ARCH}.deb"

# Install GitHub CLI using their official repository (more secure than apt package)
RUN mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg && \
  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
  apt-get update && apt-get install -y gh && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Install fzf from binary release instead of apt package
RUN ARCH=$(dpkg --print-architecture) && \
  if [ "$ARCH" = "amd64" ]; then FZF_ARCH="linux_amd64"; elif [ "$ARCH" = "arm64" ]; then FZF_ARCH="linux_arm64"; else FZF_ARCH="linux_$ARCH"; fi && \
  wget -q https://github.com/junegunn/fzf/releases/download/0.45.0/fzf-0.45.0-$FZF_ARCH.tar.gz -O /tmp/fzf.tar.gz && \
  tar -xzf /tmp/fzf.tar.gz -C /usr/local/bin && \
  chmod +x /usr/local/bin/fzf && \
  rm /tmp/fzf.tar.gz

# Set environment variables
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin:/home/node/.local/bin
ENV SHELL=/bin/zsh

# Switch to non-root user
USER node

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
  -p git \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

COPY version-tag.txt /home/node/version-tag.txt

# https://github.com/johnhuang316/code-index-mcp
RUN pip install --upgrade --break-system-packages code-index-mcp \
  && pip install --upgrade --break-system-packages uv \
  && npm install -g @anthropic-ai/claude-code \
  && npm cache clean --force \
  && rm -rf /tmp/* /var/tmp/*
