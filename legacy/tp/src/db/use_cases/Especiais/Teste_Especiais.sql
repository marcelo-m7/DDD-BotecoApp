
-- Criar evento especial
EXEC sp_CriarEventoEspecial 
    @nome = 'Festival de Inverno',
    @descricao = 'Menu especial com pratos quentes para o inverno.',
    @data_inicio = '2025-07-01',
    @data_fim = '2025-07-31';

-- Criar menu especial para o evento (supondo id_evento = 1)
EXEC sp_CriarMenuEspecial 
    @nome = 'Menu Quente Inverno',
    @preco = 20.00,
    @id_evento = 1;

-- Adicionar pratos ao menu (supondo id_menu = 1)
EXEC sp_AdicionarPratoMenuEspecial @id_menu = 1, @id_prato = 1; -- Bife com Batatas
EXEC sp_AdicionarPratoMenuEspecial @id_menu = 1, @id_prato = 2; -- Omelete Simples
