
#!/bin/bash
# ─── Post-create setup script ─────────────────────────────────────────────────
# Runs once after the devcontainer is created
# Sets up the local development environment

set -e

echo "🚀 Setting up Azure Data Platform development environment..."

# ─── Install project in editable mode ────────────────────────────────────────
echo "📦 Installing project package..."
pip install -e ".[dev]" --quiet 2>/dev/null || echo "⚠️  No setup.py yet — skipping editable install"

# ─── Install pre-commit hooks ────────────────────────────────────────────────
echo "🔧 Installing pre-commit hooks..."
if [ -f ".pre-commit-config.yaml" ]; then
    pre-commit install
    echo "✅ Pre-commit hooks installed"
else
    echo "⚠️  No .pre-commit-config.yaml found — skipping"
fi

# ─── Install DuckDB extensions ────────────────────────────────────────────────
echo "🦆 Installing DuckDB extensions..."
python -c "
import duckdb
conn = duckdb.connect()
conn.execute(\"INSTALL delta\")
conn.execute(\"LOAD delta\")
conn.execute(\"INSTALL httpfs\")
conn.execute(\"LOAD httpfs\")
conn.execute(\"INSTALL azure\")
conn.execute(\"LOAD azure\")
print('✅ DuckDB extensions installed: delta, httpfs, azure')
"

# ─── Create local .env if it doesn't exist ───────────────────────────────────
echo "🔐 Creating .env template..."
if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
# ─── Local development environment variables ──────────────────────────────
# DO NOT commit this file — it is in .gitignore

# Azure
AZURE_SUBSCRIPTION_ID=
AZURE_TENANT_ID=
AZURE_CLIENT_ID=
AZURE_CLIENT_SECRET=

# Databricks
DATABRICKS_HOST=
DATABRICKS_TOKEN=

# Azure DevOps
AZURE_DEVOPS_ORG=
AZURE_DEVOPS_PAT=

# Environment
ENV=dev
CATALOG=dev_catalog
SCHEMA=nyc_taxi
EOF
    echo "✅ .env template created — fill in your values"
else
    echo "✅ .env already exists"
fi

# ─── Create local Delta storage directories ──────────────────────────────────
echo "📁 Creating local Delta storage structure..."
mkdir -p local-dev/delta-local/{bronze,silver,gold}/nyc_taxi
echo "✅ Local Delta directories created"

# ─── Verify key tools ────────────────────────────────────────────────────────
echo ""
echo "🔍 Verifying installed tools..."
echo "─────────────────────────────"
python --version
echo "Bicep: $(bicep --version 2>/dev/null || echo 'not found')"
echo "Databricks CLI: $(databricks --version 2>/dev/null || echo 'not found')"
echo "Terraform: $(terraform --version 2>/dev/null | head -1 || echo 'not found')"
echo "Azure CLI: $(az --version 2>/dev/null | head -1 || echo 'not found')"
echo "DuckDB: $(duckdb --version 2>/dev/null || echo 'not found')"
echo "kubectl: $(kubectl version --client 2>/dev/null | head -1 || echo 'not found')"
echo "Docker: $(docker --version 2>/dev/null || echo 'not found')"
echo "─────────────────────────────"
echo ""
echo "✅ Dev environment ready!"
echo ""
echo "📖 Read CONTEXT.md to understand the project architecture."
echo "🏁 Start with: cd infra/bicep && code modules/adls.bicep"
