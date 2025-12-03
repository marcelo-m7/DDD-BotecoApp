-- ============================================================
-- 004_provision_schema.sql
-- Provisionamento completo de um novo boteco
-- usando tabelas base no schema PUBLIC.
--
-- Cria:
--   1) Registro na tabela public.boteco
--   2) Relação em public.user_boteco (owner = admin)
--   3) Schema físico boteco_{slug}
--   4) Chamada dos templates estruturais (002 + 003)
-- ============================================================

SET search_path TO public;

-- ============================================================
-- slug normalization
-- ============================================================
-- Normalization of slugs is now provided by public.normalize_slug(),
-- defined in the 000_config.sql.  Reuse that function here instead
-- of redefining it, so all components share the same sanitization rules.


-- ============================================================
-- PLACEHOLDER FUNCTIONS to be replaced by Supabase/Edge Functions
-- ============================================================
-- 002_template executor
CREATE OR REPLACE FUNCTION run_schema_template(schema_name TEXT)
RETURNS VOID AS $$
BEGIN
    RAISE NOTICE 'TODO: Apply 002_boteco_schema_template.sql for schema %', schema_name;
END;
$$ LANGUAGE plpgsql;

-- 003_seed executor
CREATE OR REPLACE FUNCTION run_seed_template(schema_name TEXT)
RETURNS VOID AS $$
BEGIN
    RAISE NOTICE 'TODO: Apply 003_seed_data_template.sql for schema %', schema_name;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- MAIN PROCEDURE
-- ============================================================
CREATE OR REPLACE PROCEDURE create_boteco_schema(
    owner_user_id UUID,
    slug TEXT,
    name TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    normalized_slug TEXT;
    schema_name TEXT;
    new_boteco_id UUID;
BEGIN
    -- Normalize slug using the shared helper in the public schema
    normalized_slug := public.normalize_slug(slug);
    schema_name := 'boteco_' || normalized_slug;

    RAISE NOTICE 'Creating boteco with slug: % -> schema %', normalized_slug, schema_name;

    -- ============================================================
    -- 1. Criar registro em public.boteco
    -- ============================================================
    INSERT INTO public.boteco (
        boteco_id, owner_user_id, name, slug
    )
    VALUES (
        uuid_generate_v4(),
        owner_user_id,
        name,
        normalized_slug
    )
    RETURNING boteco_id INTO new_boteco_id;

    RAISE NOTICE 'Boteco created with ID: %', new_boteco_id;

    -- ============================================================
    -- 2. Criar relação user ↔ boteco como ADMIN
    -- ============================================================
    INSERT INTO public.user_boteco (
        user_id, boteco_id, role, active
    )
    VALUES (
        owner_user_id,
        new_boteco_id,
        'admin',
        TRUE
    );

    RAISE NOTICE 'Owner % linked to boteco % as ADMIN', owner_user_id, new_boteco_id;

    -- ============================================================
    -- 3. Criar schema do boteco
    -- ============================================================
    EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', schema_name);

    RAISE NOTICE 'Schema % created.', schema_name;

    -- ============================================================
    -- 4. Aplicar template 002 (estrutura)
    -- ============================================================
    PERFORM run_schema_template(schema_name);

    -- ============================================================
    -- 5. Aplicar seed inicial 003
    -- ============================================================
    PERFORM run_seed_template(schema_name);

    RAISE NOTICE 'Boteco % fully provisioned.', normalized_slug;

END;
$$;


-- ============================================================
-- FINISH
-- ============================================================
