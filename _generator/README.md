# BotecoPro Domain Generator

Structure:
- db-meta/schemas/001_domain.yaml: single YAML domain definition (entities, types, enums)
- templates/: Jinja2 templates for SQLAlchemy models and SQLite DDL
- generator.py: generator that renders the templates for each entity

How to use:
1. Install dependencies: `pip install -r requirements.txt`
2. Run the generator: `python generator.py`
3. Check `generated/` for the auto-created SQLAlchemy models (under `generated/python`) and SQLite DDL (under `generated/sql`).

---

## Usage

1. Install dependencies (preferably in a virtual environment):

   ```bash
   pip install -e .[dev]
   ```

2. Run the generator pointing to the domain YAML and output directory:

   ```bash
   boteco-generate --input db-meta/tables/001_domain.yaml --out generated
   ```

   The command writes Python models to `generated/python` and SQL scripts to `generated/sql`.

3. Run tests:

   ```bash
   pytest
   ```

---

## Project layout

- `db-meta/tables/001_domain.yaml` - Source domain definition.
- `src/botecopro_meta/` - Generator implementation and Jinja2 templates.
- `templates/` - Legacy templates kept for reference.
- `generated/` - Output directory when running the generator.
- `tests/` - Basic generation tests.
