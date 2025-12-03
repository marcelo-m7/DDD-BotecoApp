-- ============================================================
-- 007_supabase_jwt_claims_setup.sql
-- Configuração de claims customizadas no JWT para o Boteco Pro
-- ============================================================

SET search_path TO public;

-- ============================================================
-- 1. Função para obter o boteco ativo do usuário
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_user_active_boteco(user_uuid UUID)
RETURNS TABLE (boteco_id UUID, role TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT ub.boteco_id, ub.role
    FROM public.user_boteco ub
    WHERE ub.user_id = user_uuid
    AND ub.active = TRUE
    ORDER BY ub.created_at ASC   -- caso exista mais de 1, pega o mais antigo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;


-- ============================================================
-- 2. Função para atualizar claims customizadas no JWT
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_jwt_claims(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
    active_boteco UUID;
    user_role TEXT;
BEGIN
    -- Obter boteco atual
    SELECT boteco_id, role INTO active_boteco, user_role
    FROM public.get_user_active_boteco(user_uuid);

    IF active_boteco IS NULL THEN
        -- Sem boteco selecionado, limpar claims
        UPDATE auth.users
        SET raw_app_metadata = jsonb_set(
            COALESCE(raw_app_metadata, '{}'::jsonb),
            '{boteco_id}',
            'null'::jsonb,
            TRUE
        ),
        raw_app_metadata = jsonb_set(
            COALESCE(raw_app_metadata, '{}'::jsonb),
            '{role}',
            '"none"'::jsonb,
            TRUE
        )
        WHERE id = user_uuid;
    ELSE
        -- Atualizar claims com boteco ativo
        UPDATE auth.users
        SET raw_app_metadata = raw_app_metadata
            || jsonb_build_object(
                'boteco_id', active_boteco,
                'role', user_role
            )
        WHERE id = user_uuid;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- 3. Trigger: atualizar JWT claims quando mudar user_boteco
-- ============================================================

CREATE OR REPLACE FUNCTION public.trigger_update_jwt_claims()
RETURNS TRIGGER AS $$
BEGIN
    -- Sempre atualiza claims para o usuário associado
    PERFORM public.update_jwt_claims(
        COALESCE(NEW.user_id, OLD.user_id)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Apagar trigger se já existir
DROP TRIGGER IF EXISTS trg_update_jwt_claims ON public.user_boteco;

CREATE TRIGGER trg_update_jwt_claims
AFTER INSERT OR UPDATE OR DELETE ON public.user_boteco
FOR EACH ROW EXECUTE FUNCTION public.trigger_update_jwt_claims();


-- ============================================================
-- 4. Atualizar claims automaticamente quando criar usuário
-- ============================================================

DROP TRIGGER IF EXISTS trg_update_jwt_on_user_create ON public."user";

CREATE TRIGGER trg_update_jwt_on_user_create
AFTER INSERT ON public."user"
FOR EACH ROW
EXECUTE FUNCTION public.update_jwt_claims(NEW.user_id);


-- ============================================================
-- FINAL
-- ============================================================
