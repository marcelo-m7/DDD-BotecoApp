The idea: maintain a single canonical YAML that describes the BotecoPro domain and use it to generate:

- Dart models (Flutter)
- Python models (e.g. SQLAlchemy / Pydantic)
- SQL DDL (`CREATE TABLE`, constraints, indexes)

This document is a refined, English-language specification for that single-source-of-truth YAML, including a compact DSL and a working MVP example (products, orders, order_items, tables, payments, stock_moves). The repository's `PLAN` folder contains related artifacts; consider this file an improved starting point.

---

**1. YAML structure (high level)**

Keep the YAML split into clear top-level sections:

```yaml
version: 1
project: boteco_pro

targets:
  dart:
    null_safety: true
  python:
    orm: sqlalchemy
  sql:
    dialect: postgres

types:
  money:
    base: int        # stored as cents
    description: Monetary value in cents.
  uuid_pk:
    base: uuid
    primary_key: true
    default: gen_random_uuid()

schemas:
  app_config:
    description: Global configuration and multi-tenancy.
  org:
    description: Per-organization schemas (org_{slug})

entities:
  ...
```

Each entry in `entities` describes a table or domain object.

---

**2. Entity model (tables)**

Suggested minimal pattern for each entity:

```yaml
entities:
  products:
    schema: org          # becomes 'org_{slug}' for SQL generation
    table_name: products
    description: Product catalog.
    fields:
      id:
        type: uuid_pk
      sku:
        type: string
        max_length: 64
        unique: true
        nullable: true
      name:
        type: string
        max_length: 255
        nullable: false
      price_cents:
        type: money
        nullable: false
      tax:
        type: numeric
        precision: 10
        scale: 2
        default: 0
      active:
        type: bool
        default: true
      updated_at:
        type: timestamptz
        default: now()
    indexes:
      - name: idx_products_active
        fields: [active]
```

Field options (recommended):

- `type`: logical type (`string`, `int`, `bool`, `date`, `datetime`, `uuid`, `numeric`, `json`, `money`, `uuid_pk`, ...).
- `nullable`: `true`/`false`.
- `default`: text that will be used in SQL (e.g. `now()`, `gen_random_uuid()`) or as a model default.
- `unique`: boolean.
- `max_length`: for strings.
- `precision` / `scale`: for numeric types.
- `ref`: foreign key reference in the form `schema.entity.field` or `entity.field` (same schema assumed).

Example foreign key field:

```yaml
table_id:
  type: uuid
  ref: tables.id    # generates FK to org.tables(id)
  nullable: false
```

---

**3. Full example: BotecoPro MVP (single YAML)**

The example below contains the minimal set of tables used by the MVP: `products`, `tables`, `orders`, `order_items`, `payments`, `stock_moves`.

```yaml
version: 1
project: boteco_pro

targets:
  dart:
    null_safety: true
  python:
    orm: sqlalchemy
  sql:
    dialect: postgres

types:
  uuid_pk:
    base: uuid
    primary_key: true
    default: gen_random_uuid()

  money:
    base: int
    description: Monetary value in cents.

schemas:
  app_config:
    description: Global configuration and multi-tenancy.
  org:
    description: Per-organization schemas (org_{slug})

entities:
  products:
    schema: org
    table_name: products
    description: Product catalog (menu items, SKUs).
    fields:
      id:
        type: uuid_pk
      sku:
        type: string
        max_length: 64
        unique: true
        nullable: true
      name:
        type: string
        max_length: 255
        nullable: false
      price_cents:
        type: money
        nullable: false
      tax:
        type: numeric
        precision: 10
        scale: 2
        default: 0
      active:
        type: bool
        default: true
      updated_at:
        type: timestamptz
        default: now()
    indexes:
      - name: idx_products_active
        fields: [active]

  tables:
    schema: org
    table_name: tables
    description: Physical tables in the restaurant/bar.
    fields:
      id:
        type: uuid_pk
      name:
        type: string
        max_length: 64
        nullable: false
      status:
        type: string
        enum: [free, occupied, reserved]
        default: free
      seats:
        type: int
        default: 0

  orders:
    schema: org
    table_name: orders
    description: Orders associated with tables.
    fields:
      id:
        type: uuid_pk
      table_id:
        type: uuid
        ref: tables.id
        nullable: false
      status:
        type: string
        enum: [open, closed, cancelled]
        default: open
      total_cents:
        type: money
        default: 0
      opened_at:
        type: timestamptz
        default: now()
      closed_at:
        type: timestamptz
        nullable: true
    indexes:
      - name: idx_orders_table_status
        fields: [table_id, status]

  order_items:
    schema: org
    table_name: order_items
    description: Items inside an order.
    fields:
      id:
        type: uuid_pk
      order_id:
        type: uuid
        ref: orders.id
        nullable: false
      product_id:
        type: uuid
        ref: products.id
        nullable: false
      qty:
        type: numeric
        precision: 10
        scale: 2
        default: 1
      note:
        type: string
        max_length: 512
        nullable: true
      price_cents:
        type: money
        nullable: false

  payments:
    schema: org
    table_name: payments
    description: Payments associated with an order.
    fields:
      id:
        type: uuid_pk
      order_id:
        type: uuid
        ref: orders.id
        nullable: false
      method:
        type: string
        enum: [cash, card, pix, voucher]
        nullable: false
      amount_cents:
        type: money
        nullable: false
      paid_at:
        type: timestamptz
        default: now()

  stock_moves:
    schema: org
    table_name: stock_moves
    description: Stock movements for products.
    fields:
      id:
        type: uuid_pk
      product_id:
        type: uuid
        ref: products.id
        nullable: false
      qty_delta:
        type: numeric
        precision: 10
        scale: 3
        nullable: false
      reason:
        type: string
        max_length: 128
        nullable: false
      at:
        type: timestamptz
        default: now()
```

This single YAML should be sufficient to:

- generate SQL DDL (`CREATE TABLE`, `ALTER TABLE ADD CONSTRAINT`, indexes...),
- generate Dart classes,
- generate Python models.

---

**4. Mapping ideas for target languages**

These are suggested type mappings and generator outputs.

**Dart (Freezed / json_serializable)**

- `uuid` → `String` (or a small wrapper value object)
- `timestamptz` → `DateTime`
- `money` → `int` (cents)
- YAML enums → Dart `enum` or `String` with generator helpers

Example generated model for `orders` (conceptual):

```dart
@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String tableId,
    @Default('open') String status,
    @Default(0) int totalCents,
    required DateTime openedAt,
    DateTime? closedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
```

**Python (SQLAlchemy + Pydantic)**

- `uuid` → `UUID(as_uuid=True)`
- `timestamptz` → `DateTime(timezone=True)`
- `money` → `Integer`

Example SQLAlchemy mapping (conceptual):

```python
class Order(Base):
    __tablename__ = "orders"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    table_id = Column(UUID(as_uuid=True), ForeignKey("tables.id"), nullable=False)
    status = Column(String, default="open")
    total_cents = Column(Integer, default=0)
    opened_at = Column(DateTime(timezone=True), server_default=func.now())
    closed_at = Column(DateTime(timezone=True), nullable=True)
```

**Postgres SQL**

Example DDL for `orders` (conceptual):

```sql
create table org_{slug}.orders (
  id uuid primary key default gen_random_uuid(),
  table_id uuid not null references org_{slug}.tables(id),
  status text not null default 'open',
  total_cents int not null default 0,
  opened_at timestamptz not null default now(),
  closed_at timestamptz
);

create index idx_orders_table_status
  on org_{slug}.orders(table_id, status);
```

---

**5. Practical next steps**

1. Expand the YAML to cover more domain objects (advanced inventory, suppliers, staff, permissions).
2. Implement a generator script (Python recommended) that:
   - reads this YAML,
   - emits `.sql` DDL files per schema and entity,
   - emits Dart model files (Freezed/json_serializable),
   - emits Python models (SQLAlchemy + Pydantic).
3. Add a small CLI and tests to validate round-trip expectations (YAML → code → basic linting).

This file now serves as a clearer, English-language specification and a basis for building the generator.

---

If you want, I can now:

- generate a first-pass Python generator script scaffold,
- produce example generated files for one entity (e.g., `orders`), or
- expand the YAML with additional domain tables.

