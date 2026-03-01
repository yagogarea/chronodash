# Chronodash

## Project Overview

Chronodash is a multi-datasource monitoring and monitoring application built with **Elixir**, **Phoenix**, and the **Ash Framework**. It is designed to collect time-series metrics from various providers (starting with MeteoSIX) and visualize them in **Grafana** using **TimescaleDB**.


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
feat/add-docs
# Dependencies

This document lists all dependencies used in Chronodash, their purpose, and relevant version information.

---

## Core Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| [Elixir](https://elixir-lang.org/) | `~> 1.15` | Primary programming language |
| [Phoenix Framework](https://phoenixframework.org/) | `~> 1.8.1` | Web framework and API layer |
| [PostgreSQL](https://www.postgresql.org/) | latest | Primary relational database |
| [Docker](https://www.docker.com/) | latest | Local development environment |

---

## Backend Dependencies

### Framework & Web

| Package | Version | Purpose | License |
|---------|---------|---------|---------|
| [`phoenix`](https://hex.pm/packages/phoenix) | `~> 1.8.1` | Web framework — routing, controllers, endpoints | MIT |
| [`bandit`](https://hex.pm/packages/bandit) | `~> 1.5` | HTTP server (replaces Cowboy) | MIT |
| [`phoenix_ecto`](https://hex.pm/packages/phoenix_ecto) | `~> 4.5` | Phoenix and Ecto integration | MIT |
| [`gettext`](https://hex.pm/packages/gettext) | `~> 0.26` | Internationalization and translations | MIT |

### Data Layer

| Package | Version | Purpose | License |
|---------|---------|---------|---------|
| [`ecto_sql`](https://hex.pm/packages/ecto_sql) | `~> 3.13` | SQL query interface for Ecto | Apache 2.0 |
| [`postgrex`](https://hex.pm/packages/postgrex) | `>= 0.0.0` | PostgreSQL driver for Elixir | Apache 2.0 |
| [`ash`](https://hex.pm/packages/ash) | `~> 3.0` | Resource-based framework for domain modeling | MIT |
| [`ash_postgres`](https://hex.pm/packages/ash_postgres) | `~> 2.0` | AshPostgres adapter — manages migrations and repo | MIT |
| [`ash_phoenix`](https://hex.pm/packages/ash_phoenix) | `~> 2.0` | Integration between Ash and Phoenix | MIT |

### API & Documentation

| Package | Version | Purpose | License |
|---------|---------|---------|---------|
| [`open_api_spex`](https://hex.pm/packages/open_api_spex) | `~> 3.16` | OpenAPI 3.0 spec generation and validation | MIT |
| [`jason`](https://hex.pm/packages/jason) | `~> 1.2` | Fast JSON encoding/decoding | Apache 2.0 |

### HTTP & Networking

| Package | Version | Purpose | License |
|---------|---------|---------|---------|
| [`req`](https://hex.pm/packages/req) | `~> 0.5` | HTTP client for outgoing requests | Apache 2.0 |
| [`dns_cluster`](https://hex.pm/packages/dns_cluster) | `~> 0.2.0` | DNS-based node clustering | Apache 2.0 |

### Observability

| Package | Version | Purpose | License |
|---------|---------|---------|---------|
| [`telemetry_metrics`](https://hex.pm/packages/telemetry_metrics) | `~> 1.0` | Metrics definitions and aggregation | Apache 2.0 |
| [`telemetry_poller`](https://hex.pm/packages/telemetry_poller) | `~> 1.0` | Periodic VM and application metrics | Apache 2.0 |
| [`phoenix_live_dashboard`](https://hex.pm/packages/phoenix_live_dashboard) | `~> 0.8.3` | Real-time metrics dashboard (dev/prod) | MIT |

### Email

| Package | Version | Purpose | License |
|---------|---------|---------|---------|
| [`swoosh`](https://hex.pm/packages/swoosh) | `~> 1.16` | Email composition and delivery | MIT |

### Tooling & DX

| Package | Version | Purpose | License |
|---------|---------|---------|---------|
| [`igniter`](https://hex.pm/packages/igniter) | `~> 0.3` | Code generation and project automation | MIT |
| [`credo`](https://hex.pm/packages/credo) | `~> 1.7` | Static code analysis and style enforcement (test only) | MIT |

---

## Development & Infrastructure

| Tool | Purpose |
|------|---------|
| Docker & Docker Compose | Runs PostgreSQL locally without a manual install |
| `.env` / `.env.example` | Environment variable management |

---

## Updating Dependencies

### Elixir

```bash
# Check for outdated packages
mix hex.outdated

# Update a specific package
mix deps.update <package_name>

# Update all packages
mix deps.update --all

# Check for known vulnerabilities
mix hex.audit
```

---

## Notes

- **Ash Framework**: This project uses Ash (`~> 3.0`) as the primary domain layer. Migrations are managed by `AshPostgres` rather than plain Ecto — always use `mix ash_postgres.generate_migrations` when changing resources.
- **Bandit vs Cowboy**: This project uses `bandit` as the HTTP server. Do not add `plug_cowboy` as a dependency.
=======

## Getting Started

### Prerequisites
- Docker & Docker Compose
- Elixir 1.15+ (for local development)

### Quick Start
1. Get your MeteoSIX API Key and add it to `.env`.
2. Configure your DB credentials in `.env`.
3. Deploy the app with telemetry: `make deploy_with_tel`
4. Access Grafana: `http://localhost:3000` (admin/admin)
main

## License
---

## License

Chronodash is licensed under the [GNU GPLv3](https://github.com/yagogarea/chronodash/blob/main/LICENSE.md).
