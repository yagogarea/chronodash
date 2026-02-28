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
