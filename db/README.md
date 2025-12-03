# supabase-json-models

Small project containing JSON Schemas, TypeScript interfaces and examples derived from the domain model. Intended as a companion to the project's generator pipeline.

Quickstart

1. Install dependencies:

```powershell
cd supabase-json-models
npm install
```

2. Validate example JSONs against schemas:

```powershell
npm run validate
```

Notes

- Three example schemas are provided: `customer`, `tab` (renamed from `comanda`), and `order` in `db/schemas/`.
- Interfaces live under `src/interfaces/` and are intended to mirror the JSON Schemas.
- Keep this folder generated from the canonical YAML (`.mona/_generator/db-meta/schemas/001_domain.yaml`). Recommended generator entrypoint: `boteco-generate --input .mona/_generator/db-meta/schemas/001_domain.yaml --out supabase-json-models`.

If you want, I can add a generator script that parses the YAML and emits these JSON Schema + TS interface files automatically.
