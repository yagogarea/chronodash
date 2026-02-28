# Chronodash

## Project Overview

Chronodash is a multi-datasource monitoring and monitoring application built with **Elixir**, **Phoenix**, and the **Ash Framework**. It is designed to collect time-series metrics from various providers (starting with MeteoSIX) and visualize them in **Grafana** using **TimescaleDB**.

---

## Key Architecture Concepts

1. **Generic Polling Engine** – Orchestrates data collection from multiple sources using a standardized pipeline.
2. **Standardized Data Contract** – All DataSources return a unified `ObservationData` struct, decoupling fetching logic from persistence.
3. **Ash Framework** – Manages the domain logic and persistence layer with high-performance bulk operations.
4. **TimescaleDB** – Optimized storage for time-series observations, enabling efficient long-term data retention and fast queries.
5. **Observability** – Integrated with **PromEx** for system metrics and **Grafana** for business/weather metrics.

---

## Project Structure

```
.
├── .env                        # Environment variables (API keys, DB credentials, etc.)
├── .gitignore                  # Git ignore rules
├── Makefile                    # Automation scripts (deploy, attach, db-up, etc.)
├── config/                     # Configuration files
├── docker/                     # Deployment infrastructure
├── etc/                        # Provisioning and configuration
│   ├── grafana/                # Dashboards and Datasource provisioning
│   └── prometheus/             # Scraping configuration
├── lib                         # Main Elixir source code
│   ├── chronodash/             # Core Application
│   │   ├── accounts/           # Ash Domain: User management
│   │   ├── datasource/         # High-level data orchestration
│   │   ├── metrics/            # Ash Domain: Locations and Observations
│   │   ├── models/             # Standardized DTOs and internal contracts
│   │   ├── polling/            # Generic Polling Engine (Supervisors/Workers)
│   │   └── prom_ex/            # Custom metrics plugins
│   ├── chronodash_web/         # Phoenix Web Layer
│   ├── http_client/            # Centralized HTTP client (Finch + Req)
│   └── meteosix/               # MeteoSIX API v5 Client
├── priv                        # Database and static resources
│   ├── repo/migrations/        # TimescaleDB hypertable migrations
│   └── specs/schema.dbml       # Database design documentation
└── test                        # Unit and integration tests
    ├── chronodash/             # Core logic tests
    └── support/                # Mock clients and test cases
```


## Getting Started

### Prerequisites
- Docker & Docker Compose
- Elixir 1.15+ (for local development)

### Quick Start
1. Get your MeteoSIX API Key and add it to `.env`.
2. Configure your DB credentials in `.env`.
3. Deploy the app with telemetry: `make deploy_with_tel`
4. Access Grafana: `http://localhost:3000` (admin/admin)
