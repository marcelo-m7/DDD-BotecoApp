-- ============================================================
-- 001b_roles_and_permissions.sql
-- Configuração das roles técnicas e permissões base
-- para o ecossistema Boteco Pro.
-- ============================================================

-- ============================================================
-- Safety: nunca rodar sem schema definido
-- ============================================================
SET search_path TO boteco_pro;

-- ============================================================
-- CREATE ROLES
-- (Obs: Supabase usa 'authenticated' e 'service_role' — não tocar neles)
-- ============================================================

-- Role global para usuários do app Boteco Pro
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'boteco_pro_user'
    ) THEN
        CREATE ROLE boteco_pro_user NOINHERIT;
    END IF;
END;
$$;

-- Role técnica que Edge Functions usarão para provisionamento
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'boteco_pro_admin'
    ) THEN
        CREATE ROLE boteco_pro_admin NOINHERIT;
    END IF;
END;
$$;

-- ============================================================
-- SCHEMA PERMISSIONS
-- ============================================================

-- Remove permissões públicas no schema
REVOKE ALL ON SCHEMA boteco_pro FROM PUBLIC;

-- Apenas roles administradoras podem criar objetos
GRANT USAGE ON SCHEMA boteco_pro TO boteco_pro_user;
GRANT USAGE, CREATE ON SCHEMA boteco_pro TO boteco_pro_admin;

-- ============================================================
-- TABLE PERMISSIONS (INICIAL)
-- ============================================================

-- Bloqueia tudo para PUBLIC
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA boteco_pro FROM PUBLIC;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA boteco_pro FROM PUBLIC;

-- Usuários comuns só podem SELECT nas tabelas globais básicas
GRANT SELECT ON TABLE boteco_pro."user" TO boteco_pro_user;
GRANT SELECT ON TABLE boteco_pro.boteco TO boteco_pro_user;
GRANT SELECT ON TABLE boteco_pro.staff TO boteco_pro_user;

-- Administrador técnico pode tudo
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA boteco_pro TO boteco_pro_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA boteco_pro TO boteco_pro_admin;

-- ============================================================
-- DEFAULT PRIVILEGES para tabelas futuras
-- ============================================================

ALTER DEFAULT PRIVILEGES IN SCHEMA boteco_pro
    REVOKE ALL ON TABLES FROM PUBLIC;

ALTER DEFAULT PRIVILEGES IN SCHEMA boteco_pro
    GRANT SELECT ON TABLES TO boteco_pro_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA boteco_pro
    GRANT ALL ON TABLES TO boteco_pro_admin;

-- ============================================================
-- FUNCTION EXECUTION PERMISSIONS
-- ============================================================

-- Usuários podem ler funções seguras
GRANT EXECUTE ON FUNCTION boteco_pro.normalize_slug(TEXT)
    TO boteco_pro_user;

-- Trigger de updated_at deve ser executável por todos
GRANT EXECUTE ON FUNCTION boteco_pro.set_updated_at()
    TO boteco_pro_user;

-- Edge function / provisioning deverá executar estas
GRANT EXECUTE ON FUNCTION boteco_pro.run_schema_template(TEXT)
    TO boteco_pro_admin;

GRANT EXECUTE ON FUNCTION boteco_pro.run_seed_template(TEXT)
    TO boteco_pro_admin;

GRANT EXECUTE ON PROCEDURE boteco_pro.create_boteco_schema(UUID, TEXT, TEXT)
    TO boteco_pro_admin;

-- ============================================================
-- FINISH
-- ============================================================
