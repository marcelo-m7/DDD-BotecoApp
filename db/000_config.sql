-- ============================================================
-- 000_config.sql
-- Configuração inicial do banco de dados Boteco Pro
-- Cria tabelas base no schema public e um usuário PostgreSQL
-- para uso dos microsserviços.
-- ============================================================

-- ==============================
-- EXTENSIONS
-- ==============================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ==============================
-- FUNCTIONS
-- ==============================
CREATE OR REPLACE FUNCTION execute_sql(sql TEXT)
RETURNS void AS $$
BEGIN
  EXECUTE sql;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ==============================
-- TABLE: public.user
-- Usuários globais do ecossistema (mínimo necessário p/ microsserviços)
-- ==============================
CREATE TABLE IF NOT EXISTS public.user (
    user_id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email          TEXT UNIQUE NOT NULL,
    password_hash  TEXT NOT NULL,
    first_name     TEXT NOT NULL,
    last_name      TEXT NOT NULL,

    phone_number   TEXT,
    tax_number     TEXT,
    birthday       DATE,

    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
--
-- Drop and recreate the timestamp trigger on the user table to make
-- this script idempotent on successive runs.  Dropping the trigger
-- before re‑creating it avoids duplicate trigger errors when the file
-- is rerun.
--
DROP TRIGGER IF EXISTS trg_public_user_updated ON public.user;

-- Trigger updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--
-- Helper function for normalizing slugs.  Slugs are used to
-- construct schema names and must consist of lowercase letters,
-- digits and underscores only.  Multiple consecutive underscores
-- are collapsed into a single one and leading/trailing underscores
-- are removed.  Defining this function in the public schema makes
-- it available throughout the database so all components can use
-- a single implementation when sanitizing user input.
--
CREATE OR REPLACE FUNCTION public.normalize_slug(raw_slug TEXT)
RETURNS TEXT AS $$
DECLARE
    cleaned TEXT;
BEGIN
    cleaned := regexp_replace(lower(raw_slug), '[^a-z0-9_]', '_', 'g');
    cleaned := regexp_replace(cleaned, '_+', '_', 'g');
    cleaned := regexp_replace(cleaned, '^_|_$', '', 'g');
    RETURN cleaned;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
CREATE TRIGGER trg_public_user_updated
BEFORE UPDATE ON public.user
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ==============================
-- TABLE: public.boteco
-- Empresas do ecossistema (mínimo necessário)
-- ==============================
CREATE TABLE IF NOT EXISTS public.boteco (
    boteco_id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    owner_user_id  UUID NOT NULL,
    name           TEXT NOT NULL,
    slug           TEXT UNIQUE NOT NULL,

    phone_number   TEXT,
    email_contact  TEXT,
    website_url    TEXT,
    tax_number     TEXT,
    timezone       TEXT DEFAULT 'Europe/Lisbon',

    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_boteco_owner
        FOREIGN KEY (owner_user_id)
        REFERENCES public.user(user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
-- Create an index on slug to improve lookup performance.  The
-- IF NOT EXISTS clause makes this idempotent.
CREATE INDEX IF NOT EXISTS idx_boteco_slug ON public.boteco(slug);

-- Drop and recreate the trigger on the boteco table.  Doing this
-- ensures the script can be run multiple times without error.
DROP TRIGGER IF EXISTS trg_public_boteco_updated ON public.boteco;
CREATE TRIGGER trg_public_boteco_updated
BEFORE UPDATE ON public.boteco
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ==============================
-- TABLE: public.user_boteco
-- Relação (N:N controlado) entre user ↔ boteco
-- ==============================
CREATE TABLE IF NOT EXISTS public.user_boteco (
    user_boteco_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id        UUID NOT NULL,
    boteco_id      UUID NOT NULL,
    role           TEXT NOT NULL DEFAULT 'member',  -- admin, member
    active         BOOLEAN DEFAULT TRUE,

    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_boteco_user
        FOREIGN KEY (user_id)
        REFERENCES public.user(user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_user_boteco_boteco
        FOREIGN KEY (boteco_id)
        REFERENCES public.boteco(boteco_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT unique_user_per_boteco
        UNIQUE (user_id, boteco_id)
);
-- Add indexes on the foreign key columns to speed up membership lookups
CREATE INDEX IF NOT EXISTS idx_user_boteco_user ON public.user_boteco(user_id);
CREATE INDEX IF NOT EXISTS idx_user_boteco_boteco ON public.user_boteco(boteco_id);

-- Drop and recreate the trigger on the user_boteco table for idempotence
DROP TRIGGER IF EXISTS trg_public_user_boteco_updated ON public.user_boteco;
CREATE TRIGGER trg_public_user_boteco_updated
BEFORE UPDATE ON public.user_boteco
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ============================================================
-- DATABASE USER FOR MICROSERVICES
-- Only read/write (no schema creation privileges)
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'boteco_backend_user'
    ) THEN
        CREATE ROLE boteco_backend_user LOGIN PASSWORD 'CHANGE_ME_NOW';
    END IF;
END;
$$;

-- Remove permission from PUBLIC to avoid accidental access
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- Backend user can use public schema, but not create objects
GRANT USAGE ON SCHEMA public TO boteco_backend_user;

-- Allow only read/write on the three tables
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user TO boteco_backend_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.boteco TO boteco_backend_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_boteco TO boteco_backend_user;

-- Default privileges so novas tabelas no public não fiquem abertas
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    REVOKE ALL ON TABLES FROM PUBLIC;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO boteco_backend_user;


-- ============================================================
-- FINAL
-- ============================================================
