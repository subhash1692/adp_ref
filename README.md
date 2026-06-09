# Azure Data Platform — NYC Taxi Dataset

Production-grade Azure data platform built on the NYC Taxi (TLC) dataset.
Demonstrates enterprise patterns for Data Architect and Platform Engineer roles.

## Stack
- **Ingestion:** Databricks Autoloader + Azure Data Factory (SHIR/SAP)
- **Storage:** ADLS Gen2 + Delta Lake (Medallion Architecture)
- **Transformation:** PySpark wheel + pytest + DuckDB (local dev)
- **Orchestration:** Apache Airflow + Databricks Workflows
- **Deployment:** Databricks Asset Bundles (DABs)
- **IaC:** Bicep + Terraform
- **CI/CD:** Azure DevOps

## Architecture Decision Records
All major decisions documented in [docs/adr/](docs/adr/)

## Build Status
🚧 In Progress — Phase 1: Infrastructure (Bicep)
