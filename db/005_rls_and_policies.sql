-- ============================================================
-- 005_rls_and_policies.sql
-- Policies de segurança e Row Level Security para as tabelas
-- globais utilizadas pelo Boteco Pro. Estas políticas se aplicam
-- às tabelas no schema `public`, que armazenam usuários, botecos e
-- vínculos entre usuários e botecos (user_boteco).
--
-- A lógica aqui assume que os tokens JWT gerados pelo Supabase
-- contêm a claim `sub` (user_id) e que a lista de botecos nos quais
-- o usuário participa está na tabela public.user_boteco.
-- ============================================================

SET search_path TO public;

-- ============================================================
-- 1. Habilitar Row Level Security nas tabelas globais
-- ============================================================

ALTER TABLE public.user       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.boteco     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_boteco ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. POLÍTICAS PARA public.user
-- ============================================================

-- Usuários só podem ver seus próprios dados
CREATE POLICY user_select_own
ON public.user
FOR SELECT
USING (auth.uid() = user_id);

-- Usuários só podem atualizar seus próprios dados
CREATE POLICY user_update_own
ON public.user
FOR UPDATE
USING (auth.uid() = user_id);

-- Nenhum usuário pode deletar outro (apenas service_role via servidor)
CREATE POLICY user_delete_none
ON public.user
FOR DELETE
USING (false);

-- Inserts em public.user devem ser realizados pelo mecanismo de
-- autenticação do Supabase, não diretamente pelo cliente.
CREATE POLICY user_insert_none
ON public.user
FOR INSERT
WITH CHECK (false);

-- ============================================================
-- 3. POLÍTICAS PARA public.user_boteco (relações de staff)
-- ============================================================

-- Usuário autenticado pode ver apenas suas próprias entradas de
-- relacionamento (user_boteco)
CREATE POLICY user_boteco_read_related
ON public.user_boteco
FOR SELECT
USING (auth.uid() = user_id);

-- Bloqueamos a criação, atualização ou remoção de relações
-- via API normal. Essas operações devem passar por funções
-- privilegiadas no backend (Edge Functions).
CREATE POLICY user_boteco_mutation_none
ON public.user_boteco
FOR ALL
USING (false)
WITH CHECK (false);

-- ============================================================
-- 4. POLÍTICAS PARA public.boteco
-- ============================================================

-- Usuário só pode visualizar botecos onde ele está registrado em
-- public.user_boteco como ativo
CREATE POLICY boteco_select_if_staff
ON public.boteco
FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM public.user_boteco ub
        WHERE ub.boteco_id = boteco.boteco_id
          AND ub.user_id = auth.uid()
          AND ub.active = TRUE
    )
);

-- Apenas a service_role insere novos botecos (via Edge Function)
CREATE POLICY boteco_insert_none
ON public.boteco
FOR INSERT
WITH CHECK (false);

-- Usuário só pode atualizar dados de um boteco se for um admin
-- ativo nesse boteco
CREATE POLICY boteco_update_if_admin
ON public.boteco
FOR UPDATE
USING (
    EXISTS (
        SELECT 1
        FROM public.user_boteco ub
        WHERE ub.boteco_id = boteco.boteco_id
          AND ub.user_id = auth.uid()
          AND ub.role = 'admin'
          AND ub.active = TRUE
    )
);

-- Impede deletes de botecos via API normal (apenas service_role)
CREATE POLICY boteco_delete_none
ON public.boteco
FOR DELETE
USING (false);

-- ============================================================
-- 5. PERMISSÕES DE LEITURA PARA MICROSSERVIÇOS
-- ============================================================

-- O papel boteco_backend_user, criado em 000_config.sql,
-- precisa de acesso de leitura às tabelas globais para operar.
GRANT SELECT ON public.user TO boteco_backend_user;
GRANT SELECT ON public.boteco TO boteco_backend_user;
GRANT SELECT ON public.user_boteco TO boteco_backend_user;

-- ============================================================
-- 6. SERVICE ROLE
-- ============================================================

-- O Supabase service_role ignora automaticamente RLS. Nenhuma
-- configuração adicional é necessária aqui.

-- ============================================================
-- FIM
-- ============================================================