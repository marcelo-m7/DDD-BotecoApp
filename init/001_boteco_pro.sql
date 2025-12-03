-- ============================================================
--  SCHEMA & SETUP
-- ============================================================
CREATE SCHEMA IF NOT EXISTS boteco_pro;
SET search_path TO boteco_pro;

-- ============================================================
-- GLOBAL EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
--  FUNCTION: updated_at universal
-- ============================================================
CREATE OR REPLACE FUNCTION boteco_pro.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
--  FUNCTION: normalize_slug (base para nomes de schema)
-- ============================================================
CREATE OR REPLACE FUNCTION boteco_pro.normalize_slug(raw_slug TEXT)
RETURNS TEXT AS $$
DECLARE
    cleaned TEXT;
BEGIN
    cleaned := regexp_replace(lower(raw_slug), '[^a-z0-9_]', '_', 'g');
    cleaned := regexp_replace(cleaned, '_+', '_', 'g');       -- remove múltiplos "__"
    cleaned := regexp_replace(cleaned, '^_|_$', '', 'g');     -- remove _ no início/fim
    RETURN cleaned;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================
--  TABLE: user  (Usuário Master da Plataforma)
-- ============================================================
CREATE TABLE IF NOT EXISTS "user" (
    user_id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Login
    email          TEXT UNIQUE NOT NULL CHECK (email <> ''),
    password_hash  TEXT NOT NULL,

    -- Identificação pessoal
    first_name     TEXT NOT NULL,
    last_name      TEXT NOT NULL,
    display_name   TEXT GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,

    -- Dados adicionais
    tax_number     TEXT,
    birthday       DATE,
    phone_number   TEXT,
    postal_code    TEXT,
    address_line1  TEXT,
    address_line2  TEXT,
    city           TEXT,
    country        TEXT DEFAULT 'Portugal',

    -- Auditoria
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_user_updated
BEFORE UPDATE ON "user"
FOR EACH ROW EXECUTE FUNCTION boteco_pro.set_updated_at();

-- ============================================================
--  TABLE: boteco (Empresa / Tenant)
-- ============================================================
CREATE TABLE IF NOT EXISTS boteco (
    boteco_id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_user_id  UUID NOT NULL,

    -- Identificação
    name           TEXT NOT NULL CHECK (name <> ''),
    legal_name     TEXT,
    slug           TEXT NOT NULL UNIQUE CHECK (slug <> ''),
    description    TEXT,
    logo_url       TEXT,
    timezone       TEXT DEFAULT 'Europe/Lisbon',
    phone_number   TEXT,
    email_contact  TEXT,
    website_url    TEXT,

    -- Dados fiscais / endereço
    tax_number     TEXT,
    postal_code    TEXT,
    address_line1  TEXT,
    address_line2  TEXT,
    city           TEXT,
    country        TEXT DEFAULT 'Portugal',

    -- Auditoria
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_boteco_owner
        FOREIGN KEY (owner_user_id)
        REFERENCES "user"(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_boteco_slug ON boteco(slug);

CREATE TRIGGER trg_boteco_updated
BEFORE UPDATE ON boteco
FOR EACH ROW EXECUTE FUNCTION boteco_pro.set_updated_at();

-- ============================================================
--  TABLE: staff (Colaboradores)
-- ============================================================
CREATE TABLE IF NOT EXISTS staff (
    staff_id     UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    boteco_id    UUID NOT NULL,
    user_id      UUID NOT NULL,
    role         TEXT NOT NULL DEFAULT 'member',   -- member, admin
    active       BOOLEAN DEFAULT TRUE,

    -- Auditoria
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- FKs
    CONSTRAINT fk_staff_boteco
        FOREIGN KEY (boteco_id)
        REFERENCES boteco(boteco_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_staff_user
        FOREIGN KEY (user_id)
        REFERENCES "user"(user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    -- Restrições
    CONSTRAINT staff_unique_per_boteco
        UNIQUE (boteco_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_staff_boteco ON staff(boteco_id);
CREATE INDEX IF NOT EXISTS idx_staff_user   ON staff(user_id);

CREATE TRIGGER trg_staff_updated
BEFORE UPDATE ON staff
FOR EACH ROW EXECUTE FUNCTION boteco_pro.set_updated_at();
