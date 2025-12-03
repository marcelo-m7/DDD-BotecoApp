**Project**: DDD-Boteco.pt

**Purpose of this refactor**
- **Goal**: clarify and begin a Domain-Driven Design (DDD) approach by mapping domain concepts into individual Python classes and preparing the codebase for generator-driven scaffolding.
- **Why**: the repository contains a generator and templates (see `_generator/`) that produce models, SQL and other artifacts. This refactor centralizes the core domain entities into a single, explicit module to make the domain model easier to read, extend, and feed into the generator.

**Main file**: `classes.py`
- **What it contains**: the primary domain entity classes (e.g. `BaseEntity`, `Product`, `DiningTable`, `Order`, `Receipt`, `Production`, `Supplier`) and related enums. These types represent the initial domain mapping used for DDD planning and to drive generators/templates.
- **Highlights**:
	- `BaseEntity` provides shared fields (`description`, `created_at`, `updated_at`).
	- `Product` models inventory fields and basic stock operations (`add_stock`, `remove_stock`).
	- `DiningTable`, `Order`, `Receipt`, `Production`, `Supplier` present a concise domain representation aligned with the generator's expectations.

**Where this fits in the codebase**
- `_generator/` contains the generator logic and templates used to generate Python models, SQL tables, and other artifacts built from domain descriptions. The refactor makes `classes.py` a clear, human-readable map of the domain that the generator and future viewers can reference.

**Intended outcomes**
- Easier domain modeling and design reviews.
- A stable input for generator templates to produce DB schemas and model classes consistently.
- A clearer starting point for splitting domain logic into per-class modules or packages in later iterations.

**Next steps / Suggestions**
- Split `classes.py` into a `domain/` package with one file per aggregate/entity when comfortable (e.g., `domain/product.py`, `domain/order.py`).
- Add small unit tests that validate behavior (e.g., `Product.remove_stock` error paths).
- Wire the generator to import or read structured metadata from these domain classes (or a YAML/JSON equivalent) to fully automate model generation.

**Contributing**
- Keep domain logic focused and small: only behavior and attributes that belong to the entity.
- Document any new entity added to `classes.py` with a short rationale and sample usage.

---
Generated on update: see `classes.py` for the current canonical domain mapping.

