# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04 AS linux-base

# Utilities
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends build-essential \
    sudo curl git htop less rsync screen vim nano wget ca-certificates \
    openssh-client zsh clang graphviz

FROM linux-base AS python-base

# Workdir
WORKDIR /workspaces/causica

# Environment variables
ENV UV_PROJECT_ENVIRONMENT="/venv"
ENV UV_PYTHON_INSTALL_DIR="/python"
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_PYTHON=python3.10
ENV PATH="$UV_PROJECT_ENVIRONMENT/bin:$PATH"
ENV PYTHONPATH="/workspaces/causica:$PYTHONPATH"

# Install uv
COPY --from=ghcr.io/astral-sh/uv:0.6.6 /uv /usr/local/bin/uv

# Environment
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --extra cu117