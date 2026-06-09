
# ─── Azure Data Platform — NYC Taxi ───────────────────────────────────────────
# Common development commands

.PHONY: help install test lint format build clean deploy-dev deploy-svt deploy-prd

# Default target
help:
	@echo "Azure Data Platform — NYC Taxi"
	@echo "────────────────────────────────────────"
	@echo "Setup:"
	@echo "  make install        Install project in editable mode"
	@echo ""
	@echo "Development:"
	@echo "  make test           Run all unit tests"
	@echo "  make test-cov       Run tests with coverage report"
	@echo "  make lint           Run ruff linter"
	@echo "  make format         Format code with black + isort"
	@echo "  make duckdb         Open DuckDB CLI with local Delta"
	@echo ""
	@echo "Build:"
	@echo "  make build          Build Python wheel"
	@echo "  make clean          Remove build artifacts"
	@echo ""
	@echo "Infrastructure:"
	@echo "  make bicep-validate Validate Bicep templates"
	@echo "  make tf-init        Initialize Terraform"
	@echo "  make tf-plan-dev    Terraform plan for DEV"
	@echo ""
	@echo "Databricks:"
	@echo "  make dabs-validate  Validate DABs bundle"
	@echo "  make dabs-dev       Deploy bundle to DEV"
	@echo "  make dabs-run-dev   Deploy and run bronze job in DEV"
	@echo ""
	@echo "Airflow:"
	@echo "  make airflow-up     Start local Airflow (Docker Compose)"
	@echo "  make airflow-down   Stop local Airflow"

# ─── Setup ────────────────────────────────────────────────────────────────────
install:
	pip install -e ".[dev]"

# ─── Testing ──────────────────────────────────────────────────────────────────
test:
	pytest tests/ -v

test-cov:
	pytest tests/ -v --cov=src --cov-report=term-missing --cov-report=html

# ─── Code Quality ─────────────────────────────────────────────────────────────
lint:
	ruff check src/ tests/
	mypy src/ --ignore-missing-imports

format:
	black src/ tests/
	isort src/ tests/

# ─── Local DuckDB ─────────────────────────────────────────────────────────────
duckdb:
	duckdb local-dev/delta-local/dev.duckdb

# ─── Build ────────────────────────────────────────────────────────────────────
build:
	python -m build --wheel
	@echo "✅ Wheel built: $(ls dist/*.whl)"

clean:
	rm -rf dist/ build/ *.egg-info/ .pytest_cache/ htmlcov/ .coverage coverage.xml
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

# ─── Infrastructure — Bicep ───────────────────────────────────────────────────
bicep-validate:
	az bicep build --file infra/bicep/main.bicep

bicep-deploy-dev:
	az deployment group create \
		--resource-group rg-adp-dev \
		--template-file infra/bicep/main.bicep \
		--parameters infra/bicep/parameters/dev.bicepparam

# ─── Infrastructure — Terraform ───────────────────────────────────────────────
tf-init:
	cd infra/terraform && terraform init

tf-plan-dev:
	cd infra/terraform && terraform plan -var-file=environments/dev.tfvars

tf-apply-dev:
	cd infra/terraform && terraform apply -var-file=environments/dev.tfvars -auto-approve

tf-destroy-dev:
	cd infra/terraform && terraform destroy -var-file=environments/dev.tfvars

# ─── Databricks Asset Bundles ─────────────────────────────────────────────────
dabs-validate:
	databricks bundle validate

dabs-dev:
	databricks bundle deploy --target dev

dabs-svt:
	databricks bundle deploy --target svt

dabs-prd:
	databricks bundle deploy --target prd

dabs-run-dev:
	databricks bundle deploy --target dev
	databricks bundle run bronze_ingest_job --target dev

# ─── Airflow ──────────────────────────────────────────────────────────────────
airflow-up:
	docker-compose -f local-dev/docker-compose.yml up -d
	@echo "✅ Airflow UI: http://localhost:8080 (admin/admin)"

airflow-down:
	docker-compose -f local-dev/docker-compose.yml down

airflow-logs:
	docker-compose -f local-dev/docker-compose.yml logs -f
