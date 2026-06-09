
# Base image — Python 3.11 on Debian Bullseye
FROM mcr.microsoft.com/devcontainers/python:3.11-bullseye

# ─── System dependencies ──────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    openjdk-11-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ─── Java (required for PySpark local mode) ──────────────────────────────────
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# ─── Bicep CLI ────────────────────────────────────────────────────────────────
RUN curl -Lo /usr/local/bin/bicep \
    https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 \
    && chmod +x /usr/local/bin/bicep

# ─── Databricks CLI ──────────────────────────────────────────────────────────
RUN curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh \
    | sh

# ─── DuckDB CLI ──────────────────────────────────────────────────────────────
RUN wget -q https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip \
    && unzip duckdb_cli-linux-amd64.zip \
    && mv duckdb /usr/local/bin/duckdb \
    && chmod +x /usr/local/bin/duckdb \
    && rm duckdb_cli-linux-amd64.zip

# ─── Python packages ─────────────────────────────────────────────────────────
COPY .devcontainer/requirements-dev.txt /tmp/requirements-dev.txt
RUN pip install --upgrade pip \
    && pip install -r /tmp/requirements-dev.txt

# ─── Non-root user (Codespaces default) ──────────────────────────────────────
USER vscode
