BotecoPro metamodel - DRAFT
================================

Location: /mnt/data/botecopro-db-meta

Structure:
- db-meta/schemas: YAML definitions per entity (schemas grouped by folder)
- db-meta/relations.yaml: top-level relations map
- db-meta/enums.yaml: enums used across the model
- db-meta/config.yaml: metamodel configuration
- templates/: Jinja2 templates for Python(SQLModel), Postgres SQL and Dart
- generator.py: simple generator example that renders templates

How to use:
1. Install dependencies: pip install pyyaml jinja2 sqlmodel
2. Run: python generator.py
3. Check generated/ for output files (models and SQL)
