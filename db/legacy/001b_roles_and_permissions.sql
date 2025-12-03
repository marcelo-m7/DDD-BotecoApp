-- ============================================================
-- LEGACY FILE: 001b_roles_and_permissions.sql
-- Este script configurava roles e permissões para o antigo schema
-- `boteco_pro`.  Foi movido para a pasta legacy apenas como
-- referência.  A estrutura atual utiliza as permissões padrão
-- definidas em `000_config.sql` e as políticas RLS em `005_rls_and_policies.sql`.

SET search_path TO boteco_pro;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'boteco_pro_user'
    ) THEN
        CREATE ROLE boteco_pro_user NOINHERIT;
    END IF;
END;
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'boteco_pro_admin'
    ) THEN
        CREATE ROLE boteco_pro_admin NOINHERIT;
    END IF;
END;
$$;

REVOKE ALL ON SCHEMA boteco_pro FROM PUBLIC;
GRANT USAGE ON SCHEMA boteco_pro TO boteco_pro_user;
GRANT USAGE, CREATE ON SCHEMA boteco_pro TO boteco_pro_admin;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA boteco_pro FROM PUBLIC;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA boteco_pro FROM PUBLIC;

GRANT SELECT ON TABLE boteco_pro."user" TO boteco_pro_user;
GRANT SELECT ON TABLE boteco_pro.boteco TO boteco_pro_user;
GRANT SELECT ON TABLE boteco_pro.staff TO boteco_pro_user;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA boteco_pro TO boteco_pro_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA boteco_pro TO boteco_pro_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA boteco_pro
    REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA boteco_pro
    GRANT SELECT ON TABLES TO boteco_pro_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA boteco_pro
    GRANT ALL ON TABLES TO boteco_pro_admin;

GRANT EXECUTE ON FUNCTION boteco_pro.normalize_slug(TEXT)
    TO boteco_pro_user;
GRANT EXECUTE ON FUNCTION boteco_pro.set_updated_at()
    TO boteco_pro_user;
GRANT EXECUTE ON FUNCTION boteco_pro.run_schema_template(TEXT)
    TO boteco_pro_admin;
GRANT EXECUTE ON FUNCTION boteco_pro.run_seed_template(TEXT)
    TO boteco_pro_admin;
GRANT EXECUTE ON PROCEDURE boteco_pro.create_boteco_schema(UUID, TEXT, TEXT)
    TO boteco_pro_admin;