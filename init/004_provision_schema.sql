-- ============================================================
-- 004_provision_schema.sql
-- Procedure oficial para criação de um novo schema de boteco
-- ============================================================

SET search_path TO boteco_pro;

-- ============================================================
-- Helper: normalize slug (somente letras, números e underscore)
-- ============================================================
CREATE OR REPLACE FUNCTION normalize_slug(raw_slug TEXT)
RETURNS TEXT AS $$
DECLARE
    cleaned TEXT;
BEGIN
    cleaned := regexp_replace(lower(raw_slug), '[^a-z0-9_]', '_', 'g');
    RETURN cleaned;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


-- ============================================================
-- Procedure principal
-- create_boteco_schema(owner_user_id UUID, slug TEXT, name TEXT)
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
BEGIN
    -- Normaliza o slug para ser válido como schema
    normalized_slug := normalize_slug(slug);
    schema_name := 'boteco_' || normalized_slug;

    RAISE NOTICE 'Creating new boteco schema: %', schema_name;

    -- ============================================================
    -- 1. Criar novo registro na tabela global boteco
    -- ============================================================
    INSERT INTO boteco (
        boteco_id,
        owner_user_id,
        name,
        slug
    )
    VALUES (
        uuid_generate_v4(),
        owner_user_id,
        name,
        normalized_slug
    );

    -- ============================================================
    -- 2. Criar schema do boteco
    -- ============================================================
    EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', schema_name);

    -- ============================================================
    -- 3. Executar template estrutural 002
    -- ============================================================
    PERFORM boteco_pro.run_schema_template(schema_name);

    -- ============================================================
    -- 4. Executar seeds iniciais 003
    -- ============================================================
    PERFORM boteco_pro.run_seed_template(schema_name);

    RAISE NOTICE 'Boteco schema % created successfully.', schema_name;

END;
$$;

