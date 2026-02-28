# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| main    | ✅        |
| older   | ❌        |

---

## Reporting a Vulnerability

If you discover a security vulnerability in Chronodash, please **do NOT open a public issue**. Public disclosure before a fix is available puts all users at risk.

Instead, report it through one of these two channels:

- **GitHub Private Advisory** → [Open a security advisory](https://github.com/saulzascarballal/chronodash/security/advisories/new)
- **Email** → [saulzascarballal@gmail.com](mailto:saulzascarballal@gmail.com)

Please include as much detail as possible:

- Clear description of the vulnerability
- Steps to reproduce it
- Affected component (auth, API, database, etc.)
- Potential impact
- Suggested fix if you have one

We will acknowledge receipt **within 48 hours** and aim to release a patch **within 7 days** for critical issues.

---

## Security Scope

The following areas are actively monitored and considered in scope:

### 🔐 Authentication & Users

- Unauthorized access to user accounts
- Password hashing weaknesses
- Session or token hijacking
- Brute force vulnerabilities on login endpoints

### 🔑 API Keys & Tokens

- Exposure of API keys or secrets in logs, responses, or source code
- Insufficient token expiration or revocation
- Tokens with overly broad permissions

### 🗄️ Database

- SQL injection or query manipulation
- Unauthorized access to user data
- Data leakage through API responses
- Insecure database configuration

---

## Out of Scope

The following are **not** considered security vulnerabilities for this project:

- Issues in unsupported/older versions
- Bugs that require physical access to the server
- Social engineering attacks
- Denial of service (DoS) via excessive requests without proof of exploitability

---

## Disclosure Policy

We follow a **responsible disclosure** process:

1. You report the vulnerability privately
2. We confirm and investigate within 48 hours
3. We develop and test a fix
4. We release the fix and credit you (if desired)
5. Public disclosure happens after the fix is deployed

We genuinely appreciate the work of security researchers and will always credit contributors who report valid vulnerabilities responsibly.

---

## Security Best Practices for Contributors

If you are contributing to Chronodash, please follow these guidelines:

- Never commit secrets, API keys, or credentials to the repository
- Use environment variables for all sensitive configuration (see `.env.example`)
- Validate and sanitize all user inputs
- Do not log sensitive data (passwords, tokens, personal data)
- Keep dependencies up to date — run `mix hex.audit` regularly

---

_Last updated: February 2026_
