
-- View: Menus Especiais Ativos com Pratos
DROP VIEW IF EXISTS vw_MenusEspeciaisAtivos;
GO

CREATE VIEW vw_MenusEspeciaisAtivos AS
SELECT 
    me.id_menu,
    me.nome AS nome_menu,
    me.preco,
    ee.nome AS evento,
    ee.data_inicio,
    ee.data_fim,
    p.id_prato,
    p.nome AS nome_prato,
    p.preco_venda
FROM Menu_Especial me
JOIN Evento_Especial ee ON me.id_evento = ee.id_evento
JOIN Menu_Especial_Prato mp ON me.id_menu = mp.id_menu
JOIN Prato p ON mp.id_prato = p.id_prato
WHERE CAST(GETDATE() AS DATE) BETWEEN ee.data_inicio AND ee.data_fim;
GO
