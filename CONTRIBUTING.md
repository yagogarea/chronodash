# Contributing to Chronodash

Thank you for taking the time to contribute to Chronodash 🚀  
Please read this guide before opening a PR to keep the codebase clean and consistent.

---

## Table of Contents

- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Branching Strategy](#branching-strategy)
- [Commit Convention](#commit-convention)
- [Pull Requests](#pull-requests)
- [Code Style](#code-style)
- [Testing](#testing)
- [Reporting Bugs](#reporting-bugs)

---

## Development Setup

### Prerequisites

Make sure you have the following installed:

- **Elixir** `~> 1.15`
- **PostgreSQL** (or use the included Docker setup)
### Steps

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd chronodash
   ```

2. **Install Elixir dependencies**

   ```bash
   mix deps.get
   ```

3. **Configure environment variables**

   ```bash
   cp .env.example .env
   # Edit .env with your local database credentials
   ```

4. **Start PostgreSQL with Docker (optional)**

   ```bash
   docker compose up -d
   ```

5. **Create and migrate the database**

   ```bash
   mix ecto.setup
   ```

6. **Start the backend server**

   ```bash
   mix phx.server
   # API available at http://localhost:4000
   ```

---

## Project Structure

```
chronodash/
├── lib/
│   ├── chronodash/              # Business logic (Ash resources, contexts)
│   │   └── accounts/            # User authentication context
│   └── chronodash_web/          # Phoenix web layer
│       ├── controllers/         # API controllers
│       └── router.ex            # Route definitions
├── priv/
│   └── repo/migrations/         # Ecto database migrations
├── config/                      # Environment configuration
└── test/                        # Tests
```

---

## Branching Strategy

Always branch off from `main`. Use descriptive names with the following prefixes:

| Prefix      | Use case                                   |
| ----------- | ------------------------------------------ |
| `feat/`     | New feature                                |
| `fix/`      | Bug fix                                    |
| `docs/`     | Documentation only                         |
| `refactor/` | Code restructuring without behavior change |
| `test/`     | Adding or updating tests                   |
| `chore/`    | Maintenance, dependencies, config          |

**Examples:**

```
feat/user-registration-endpoint
fix/cors-preflight-headers
docs/update-security-policy
chore/update-ash-dependency
```

---

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <short description>

[optional body]
```

### Types

| Type       | When to use                     |
| ---------- | ------------------------------- |
| `feat`     | A new feature                   |
| `fix`      | A bug fix                       |
| `docs`     | Documentation changes           |
| `refactor` | Refactoring without feature/fix |
| `test`     | Adding or updating tests        |
| `chore`    | Maintenance, deps, tooling      |
| `perf`     | Performance improvements        |

### Examples

```bash
feat(auth): add user registration endpoint
fix(router): handle missing CORS preflight options
docs(contributing): add project structure section
chore(deps): update ash_postgres to 2.1
```

---

## Pull Requests

Before submitting a PR, make sure all of the following pass:

```bash
# 1. All tests pass
mix test

# 2. Code is properly formatted
mix format

# 3. No unused dependencies
mix deps.unlock --unused

# 4. Full precommit check (runs all of the above)
mix precommit
```

### PR Checklist

- [ ] Branch is up to date with `main`
- [ ] `mix precommit` passes without errors
- [ ] New functionality has tests
- [ ] No secrets or credentials committed
- [ ] PR description explains **what** changed and **why**

### PR Description Template

```
## What does this PR do?
Brief description of the change.

## Why?
Context or motivation.

## How to test it?
Steps to verify the change works.

## Related issues
Closes #<issue-number> (if applicable)
```

---

## Code Style

This project uses `mix format` for automatic formatting. Run it before every commit.

Additional guidelines:

- Keep functions small and focused — one responsibility per function
- Use descriptive variable and function names in English
- Add `@doc` comments to public functions in contexts and modules
- Avoid hardcoding values — use environment variables or config files
- In the frontend, keep components in `PascalCase` and utilities in `camelCase`

---

## Testing

Run the full test suite with:

```bash
mix test
```

When adding new features:

- Add unit tests for context functions (`Chronodash.Accounts`, etc.)
- Add controller tests for new API endpoints
- Test both the happy path and error cases (invalid input, missing fields, duplicate email, etc.)

---

## Reporting Bugs

Found a bug? Please check if it's already reported in the [issues](../../issues) before opening a new one.

For **security vulnerabilities**, do NOT open a public issue — see [SECURITY.md](./SECURITY.md) instead.

When opening a bug report, include:

- What you expected to happen
- What actually happened
- Steps to reproduce
- Elixir/Node version and OS

---

_We appreciate every contribution, big or small. Thanks for helping make Chronodash better!_ 🙌
