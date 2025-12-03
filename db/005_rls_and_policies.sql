-- ============================================================
-- 005_rls_and_policies.sql
-- Policies de Segurança e RLS do schema boteco_pro
-- ============================================================

SET search_path TO boteco_pro;

-- ============================================================
-- 1. Habilitar RLS nas tabelas globais
-- ============================================================

ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE boteco ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. POLICIES PARA user
-- ============================================================

-- Usuários só podem ver seus próprios dados
CREATE POLICY user_select_own
ON "user"
FOR SELECT
USING (auth.uid() = user_id);

-- Usuários só podem atualizar seus próprios dados
CREATE POLICY user_update_own
ON "user"
FOR UPDATE
USING (auth.uid() = user_id);

-- Nenhum usuário pode deletar outro
-- (Somente service_role poderá via servidor)
CREATE POLICY user_delete_none
ON "user"
FOR DELETE
USING (false);

-- Criar usuários será permitido apenas a partir do supabase auth
-- (não via insert direto)
CREATE POLICY user_insert_none
ON "user"
FOR INSERT
WITH CHECK (false);

-- ============================================================
-- 3. POLICIES PARA staff
-- ============================================================

-- Usuário autenticado pode visualizar apenas linhas onde ele participa
CREATE POLICY staff_read_related
ON staff
FOR SELECT
USING (auth.uid() = user_id);

-- Apenas serviço administrativo pode criar ou alterar staff
CREATE POLICY staff_mutation_none
ON staff
FOR ALL
USING (false)
WITH CHECK (false);

-- ============================================================
-- 4. POLICIES PARA boteco
-- ============================================================

-- Usuário só pode ver botecos onde ele é staff
CREATE POLICY boteco_select_if_staff
ON boteco
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM staff s
        WHERE s.boteco_id = boteco.boteco_id
        AND s.user_id = auth.uid()
    )
);

-- Apenas o service_role pode criar botecos (via Edge Function)
CREATE POLICY boteco_insert_none
ON boteco
FOR INSERT
WITH CHECK (false);

-- Usuário só pode atualizar dados do boteco se for admin desse boteco
CREATE POLICY boteco_update_if_admin
ON boteco
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM staff s
        WHERE s.boteco_id = boteco.boteco_id
        AND s.user_id = auth.uid()
        AND s.role = 'admin'
    )
);

-- Usuários nunca podem deletar botecos
CREATE POLICY boteco_delete_none
ON boteco
FOR DELETE
USING (false);

-- ============================================================
-- 5. PERMISSÃO DE LEITURA GLOBAL SEGURA (opcional)
-- Evita que o usuário fique sem resposta ao tentar buscar empresas associadas
-- ============================================================

GRANT SELECT ON boteco_pro.boteco TO boteco_pro_user;
GRANT SELECT ON boteco_pro.staff TO boteco_pro_user;
GRANT SELECT ON boteco_pro."user" TO boteco_pro_user;

-- ============================================================
-- 6. FORÇAR QUE service_role ignore RLS (padrão do Supabase)
-- Não modificar
-- ============================================================

-- Nada precisa ser feito aqui. O Supabase já ignora RLS para service_role.

-- ============================================================
-- FIM
-- ============================================================
