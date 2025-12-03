<!-- Copilot / AI agent instructions for the Boteco Pro codebase -->
# Boteco Pro — AI Coding Assistant Notes

This file contains concise, actionable guidance for AI coding agents working in this repository. Focus on discoverable, project-specific patterns, commands, and locations of truth.

**Big picture:**
- **Architecture:** Portal (admin) → Convex (business rules) → Postgres (source of truth) → App Flutter (offline-first with SQLite + Supabase sync). See `docs/architecture-summary.md` for the full rationale.
- **Boundaries:** Do not mix Portal/Convex responsibilities with App/Supabase responsibilities. Convex is the administrative brain; Supabase/Postgres is the mobile sync surface.

**Where to look first:**
- `docs/architecture-summary.md` : canonical architecture, service responsibilities, and rationale.
- `supabase/config.toml` : local Supabase ports and runtime flags (useful for `supabase start` and local testing).
- `.mona/_generator/AGENTS.md` : detailed spec for the Python→SQLite code generator (domain generator is authoritative for domain code generation tasks).
- `package.json` : minimal devDependencies (Supabase CLI used in dev environment).
- `docs/README.md` and `classes.md` : supplementary diagrams and notes.

**Developer workflows & commands**
- Start local Supabase (config shows ports):
  - `supabase start` (reads `supabase/config.toml` in repo)
- Use Supabase studio on local ports defined in `supabase/config.toml` (default studio port: `54323` in this repo).
- Don't commit secrets: use environment variables (many values in `config.toml` use `env(...)` placeholders).

**Project-specific conventions**
- Microservice boundaries are strict: changes to business rules belong in Convex (not here). If you need to change admin workflows, ask where Convex code lives — this repo documents the separation but may not contain Convex sources.
- Mobile sync/operational behaviour is implemented against Supabase/Postgres and local SQLite. Expect domain generators under `.mona/_generator` to affect mobile schemas.
- Generators: follow the YAML schema source-of-truth under `db/schemas` (see `.mona/_generator/AGENTS.md`). Generated code should live under `generated/` and be idempotent.

**When editing infra or seeds**
- Seeds and schema files referenced by `supabase/config.toml` (e.g., `supabase/seed.sql`) are important for local dev resets — preserve them or coordinate changes.
- Avoid changing `supabase/config.toml` ports or TLS flags without confirming with the team; many local scripts and other services rely on the configured ports.

**Examples of actionable tasks for AI agents**
- Implement the Python generator described in `.mona/_generator/AGENTS.md`.
  - Inputs: YAML files in `db/schemas`.
  - Outputs: `generated/python/` and `generated/sql/`.
- Extract constants or shared enums from YAML into `generated/python/enums.py` as described in the generator spec.
- When adding tests, follow the pattern suggested in `.mona/_generator/AGENTS.md` (use `sqlite3` for SQL verification, pytest for unit tests).

**Do / Don't list (brief)**
- Do: Reference `docs/architecture-summary.md` before proposing cross-service changes.
- Do: Use `supabase` CLI for local DB work and confirm ports from `supabase/config.toml`.
- Don't: Push credentials or signing keys into repo. Use environment substitution (`env(...)`) where present.
- Don't: Change Convex-related responsibilities here — ask where Convex services are hosted before altering rules.

**Files worth referencing in PR descriptions**
- `docs/architecture-summary.md` — explain why change fits architecture.
- `supabase/config.toml` — mention any infra/port implications.
- `.mona/_generator/AGENTS.md` — link when generator-output changes.

If anything in this file is unclear or you'd like more detail (example generator templates, common SQL mapping rules, or local dev commands), say which section to expand and I'll update the instructions.
