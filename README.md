# Chronodash

## Project Flow & Structure Info

Chronodash is an Elixir/Phoenix application designed to provide web-based functionality and business logic handling.  
The project follows a clear separation of concerns:

1. **Configuration** – All environment-specific and runtime settings are under `config/`.
2. **Codebase** – Core Elixir modules live in `lib/`, split between backend logic (`chronodash`) and web interface (`chronodash_web`).
3. **Privileged Resources** – `priv/` holds static assets, database migrations, seeds, and translation files.
4. **Dockerization** – All container setup is located in `docker/` for easy deployment.
5. **Tests** – Test files are isolated under `test/` to validate modules and controllers (not detailed here).

---

## Project Structure

```
.
├── AGENTS.md                 # Documentation or definition of system agents
├── Makefile                  # Make script to automate project tasks
├── README.md                 # Main project documentation
├── config                    # Application configuration files
│   ├── config.exs            # General project configuration
│   ├── dev.exs               # Development-specific configuration
│   ├── prod.exs              # Production-specific configuration
│   ├── runtime.exs           # Runtime-loaded configuration
│   └── test.exs              # Test environment configuration
├── docker                    # Docker containerization files
│   ├── Dockerfile
│   ├── docker-compose.tel.yml
│   └── docker-compose.yml
├── lib                       # Main Elixir source code
│   ├── chronodash            # Core business logic modules
│   │   ├── application.ex
│   │   ├── mailer.ex
│   │   └── repo.ex
│   ├── chronodash.ex         # Main project entry point
│   ├── chronodash_web        # Web (Phoenix) layer of the project
│   │   ├── controllers       # Web controllers handling routes and requests
│   │   │   ├── error_json.ex
│   │   │   └── health_controller.ex
│   │   ├── endpoint.ex
│   │   ├── gettext.ex
│   │   ├── router.ex
│   │   └── telemetry.ex
│   └── chronodash_web.ex     # Web module entry point
├── mix.exs                   # Mix configuration file (Elixir build tool)
├── mix.lock                  # Dependency lockfile
├── priv                      # Private application resources
│   ├── gettext               # Translation files
│   │   ├── en
│   │   │   └── LC_MESSAGES
│   │   │       └── errors.po
│   │   └── errors.pot           # Translation template file
│   ├── repo                   # Database-related files
│   │   ├── migrations
│   │   └── seeds.exs
│   ├── specs                  # Specification files
│   │   └── cronodash
│   │       └── openapi.json
│   └── static                 # Static assets served by Phoenix
│       ├── favicon.ico
│       └── robots.txt
└── test                       # Project test files
    ├── chronodash_web
    │   └── controllers
    │       └── error_json_test.exs
    ├── support
    │   ├── conn_case.ex
    │   └── data_case.ex
    └── test_helper.exs
```

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
