-- ============================================================
-- 006_rls_per_boteco_schema.sql
-- Policies de segurança para o schema multitenant {{schema_name}}
-- ============================================================

-- Usar o schema do boteco
SET search_path TO {{schema_name}};

-- ============================================================
-- 1. Helper Functions
-- ============================================================

-- Retorna o boteco_id baseado no slug enviado pela engine
CREATE OR REPLACE FUNCTION {{schema_name}}.current_boteco_id()
RETURNS UUID AS $$
DECLARE
    bid UUID;
BEGIN
    SELECT b.boteco_id INTO bid
    FROM public.boteco b
    WHERE b.slug = '{{slug}}'
    LIMIT 1;

    RETURN bid;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Verifica se o usuário autenticado pertence ao boteco
CREATE OR REPLACE FUNCTION {{schema_name}}.current_user_is_staff()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.user_boteco ub
        WHERE ub.user_id = auth.uid()
        AND ub.boteco_id = {{schema_name}}.current_boteco_id()
        AND ub.active = TRUE
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Verifica se é admin
CREATE OR REPLACE FUNCTION {{schema_name}}.current_user_is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.user_boteco ub
        WHERE ub.user_id = auth.uid()
        AND ub.boteco_id = {{schema_name}}.current_boteco_id()
        AND ub.role = 'admin'
        AND ub.active = TRUE
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Verifica se é membro
CREATE OR REPLACE FUNCTION {{schema_name}}.current_user_is_member()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN {{schema_name}}.current_user_is_staff()
           AND NOT {{schema_name}}.current_user_is_admin();
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;


-- ============================================================
-- 2. Enable Row-Level Security in todas as tabelas do schema
-- ============================================================

DO $rls$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT tablename FROM pg_tables
        WHERE schemaname = '{{schema_name}}'
    LOOP
        EXECUTE format('ALTER TABLE {{schema_name}}.%I ENABLE ROW LEVEL SECURITY', t);
    END LOOP;
END;
$rls$;


-- ============================================================
-- 3. Policies para TODAS AS TABELAS
-- ============================================================
-- Base: acesso permitido apenas se usuário é staff do boteco
-- ============================================================

DO $pol$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT tablename FROM pg_tables WHERE schemaname = '{{schema_name}}'
    LOOP
        EXECUTE format('
            CREATE POLICY p_select_%I_staff
            ON {{schema_name}}.%I
            FOR SELECT
            USING ( {{schema_name}}.current_user_is_staff() );
        ', t, t);

        EXECUTE format('
            CREATE POLICY p_insert_%I_admin_or_member
            ON {{schema_name}}.%I
            FOR INSERT
            WITH CHECK ( {{schema_name}}.current_user_is_staff() );
        ', t, t);

        EXECUTE format('
            CREATE POLICY p_update_%I_admin_or_member
            ON {{schema_name}}.%I
            FOR UPDATE
            USING ( {{schema_name}}.current_user_is_staff() )
            WITH CHECK ( {{schema_name}}.current_user_is_staff() );
        ', t, t);

        EXECUTE format('
            CREATE POLICY p_delete_%I_admin_only
            ON {{schema_name}}.%I
            FOR DELETE
            USING ( {{schema_name}}.current_user_is_admin() );
        ', t, t);
    END LOOP;
END;
$pol$;


-- ============================================================
-- 4. Permissões para roles do supabase
-- ============================================================

GRANT USAGE ON SCHEMA {{schema_name}} TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA {{schema_name}} TO authenticated;

-- Service role pode tudo
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA {{schema_name}} TO service_role;

-- ============================================================
-- FINAL
-- ============================================================
