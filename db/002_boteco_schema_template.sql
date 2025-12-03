-- ============================================================
-- boteco schema template
-- Este arquivo deve ser usado pelo script de provisionamento
-- para gerar um schema exclusivo por boteco:
--    boteco_{slug}
-- ============================================================

-- Variável (substituir automaticamente)
-- {{schema_name}} ex: boteco_bardojona_9sd3h

CREATE SCHEMA IF NOT EXISTS {{schema_name}};
SET search_path TO {{schema_name}};

-- ============================================================
-- FUNCTION: updated_at trigger
-- ============================================================
CREATE OR REPLACE FUNCTION {{schema_name}}.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- TABLE: table (mesas)
-- ============================================================
CREATE TABLE table_entity (
    table_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    label        TEXT NOT NULL,
    seats        INTEGER,
    active       BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_table_updated ON table_entity;
CREATE TRIGGER trg_table_updated
BEFORE UPDATE ON table_entity
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: pos_session (sessões PDV)
-- ============================================================
CREATE TABLE pos_session (
    pos_session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    staff_id      UUID NOT NULL,       -- referência ao schema global boteco_pro.staff
    opened_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at     TIMESTAMPTZ,
    opening_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    closing_amount NUMERIC(12,2),
    status         TEXT NOT NULL,  -- open, closed, paused, etc.

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pos_session_staff ON pos_session(staff_id);
CREATE INDEX idx_pos_session_status ON pos_session(status);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_pos_session_updated ON pos_session;
CREATE TRIGGER trg_pos_session_updated
BEFORE UPDATE ON pos_session
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: order (pedidos)
-- ============================================================
CREATE TABLE "order" (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    table_id      UUID,
    pos_session_id UUID NOT NULL,
    staff_id      UUID NOT NULL,       -- staff global
    status        TEXT NOT NULL,
    subtotal      NUMERIC(12,2),
    total         NUMERIC(12,2),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_order_table
        FOREIGN KEY (table_id)
        REFERENCES table_entity(table_id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT fk_order_session
        FOREIGN KEY (pos_session_id)
        REFERENCES pos_session(pos_session_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX idx_order_session ON "order"(pos_session_id);
CREATE INDEX idx_order_table ON "order"(table_id);
CREATE INDEX idx_order_status ON "order"(status);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_order_updated ON "order";
CREATE TRIGGER trg_order_updated
BEFORE UPDATE ON "order"
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: menu_category
-- ============================================================
CREATE TABLE menu_category (
    menu_category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name        TEXT NOT NULL,
    description TEXT,
    position    INTEGER NOT NULL DEFAULT 0,
    active      BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_menu_category_active ON menu_category(active);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_menu_category_updated ON menu_category;
CREATE TRIGGER trg_menu_category_updated
BEFORE UPDATE ON menu_category
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: menu_item
-- ============================================================
CREATE TABLE menu_item (
    menu_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    menu_category_id UUID,
    product_base_id  UUID, -- optional reference to product
    name             TEXT NOT NULL,
    description      TEXT,
    price            NUMERIC(12,2) NOT NULL,
    currency         TEXT NOT NULL DEFAULT 'EUR',
    visible          BOOLEAN DEFAULT TRUE,
    is_featured      BOOLEAN DEFAULT FALSE,
    position         INTEGER DEFAULT 0,
    tags             TEXT[],

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_menu_item_category
        FOREIGN KEY (menu_category_id)
        REFERENCES menu_category(menu_category_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX idx_menu_item_category ON menu_item(menu_category_id);
CREATE INDEX idx_menu_item_visible ON menu_item(visible);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_menu_item_updated ON menu_item;
CREATE TRIGGER trg_menu_item_updated
BEFORE UPDATE ON menu_item
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: product_category
-- ============================================================
CREATE TABLE product_category (
    product_category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name        TEXT NOT NULL,
    description TEXT,
    active      BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_product_category_active ON product_category(active);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_product_category_updated ON product_category;
CREATE TRIGGER trg_product_category_updated
BEFORE UPDATE ON product_category
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: product
-- ============================================================
CREATE TABLE product (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    product_category_id UUID NOT NULL,
    name        TEXT NOT NULL,
    cost        NUMERIC(12,2) NOT NULL DEFAULT 0,
    unit        TEXT NOT NULL, -- g, ml, unit, etc.
    active      BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_product_category
        FOREIGN KEY (product_category_id)
        REFERENCES product_category(product_category_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX idx_product_category ON product(product_category_id);
CREATE INDEX idx_product_active ON product(active);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_product_updated ON product;
CREATE TRIGGER trg_product_updated
BEFORE UPDATE ON product
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: order_item
-- ============================================================
CREATE TABLE order_item (
    order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    order_id     UUID NOT NULL,
    menu_item_id UUID NOT NULL,

    quantity     NUMERIC(12,2) NOT NULL,
    unit_price   NUMERIC(12,2) NOT NULL,
    total_price  NUMERIC(12,2) NOT NULL,
    notes        TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES "order"(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_order_item_menu_item
        FOREIGN KEY (menu_item_id)
        REFERENCES menu_item(menu_item_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_order_item_order ON order_item(order_id);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_order_item_updated ON order_item;
CREATE TRIGGER trg_order_item_updated
BEFORE UPDATE ON order_item
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: recipe
-- ============================================================
CREATE TABLE recipe (
    recipe_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    name            TEXT NOT NULL,
    description     TEXT,
    menu_item_id    UUID,
    active          BOOLEAN DEFAULT TRUE,
    estimated_cost  NUMERIC(12,2),
    yield_quantity  NUMERIC(12,2),
    yield_unit      TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_recipe_menu_item
        FOREIGN KEY (menu_item_id)
        REFERENCES menu_item(menu_item_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX idx_recipe_active ON recipe(active);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_recipe_updated ON recipe;
CREATE TRIGGER trg_recipe_updated
BEFORE UPDATE ON recipe
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: recipe_product
-- ============================================================
CREATE TABLE recipe_product (
    recipe_product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    recipe_id   UUID NOT NULL,
    product_id  UUID NOT NULL,
    quantity    NUMERIC(12,2) NOT NULL,
    unit_override TEXT,
    estimated_unit_cost NUMERIC(12,2),
    position    INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_recipe_product_recipe
        FOREIGN KEY (recipe_id)
        REFERENCES recipe(recipe_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_recipe_product_product
        FOREIGN KEY (product_id)
        REFERENCES product(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_recipe_product_recipe ON recipe_product(recipe_id);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_recipe_product_updated ON recipe_product;
CREATE TRIGGER trg_recipe_product_updated
BEFORE UPDATE ON recipe_product
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: payment
-- ============================================================
CREATE TABLE payment (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    order_id     UUID NOT NULL,
    pos_session_id UUID NOT NULL,

    method        TEXT NOT NULL,  -- cash, card, pix, mbway, voucher...
    amount        NUMERIC(12,2) NOT NULL,
    tip_amount    NUMERIC(12,2),
    change_amount NUMERIC(12,2),
    transaction_code TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES "order"(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_payment_session
        FOREIGN KEY (pos_session_id)
        REFERENCES pos_session(pos_session_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX idx_payment_order ON payment(order_id);
CREATE INDEX idx_payment_method ON payment(method);

-- Drop and recreate the trigger to ensure idempotence
DROP TRIGGER IF EXISTS trg_payment_updated ON payment;
CREATE TRIGGER trg_payment_updated
BEFORE UPDATE ON payment
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- TABLE: payment_summary
-- ============================================================
CREATE TABLE payment_summary (
    payment_summary_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    pos_session_id UUID NOT NULL,

    total_cash        NUMERIC(12,2) DEFAULT 0,
    total_card        NUMERIC(12,2) DEFAULT 0,
    total_pix         NUMERIC(12,2) DEFAULT 0,
    total_tips        NUMERIC(12,2) DEFAULT 0,
    total_change_given NUMERIC(12,2) DEFAULT 0,

    generated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_payment_summary_session
        FOREIGN KEY (pos_session_id)
        REFERENCES pos_session(pos_session_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_payment_summary_unique_session ON payment_summary(pos_session_id);
