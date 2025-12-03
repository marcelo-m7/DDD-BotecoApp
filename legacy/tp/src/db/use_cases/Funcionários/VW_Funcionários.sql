
DROP VIEW IF EXISTS vw_ListaFuncionarios;
GO

CREATE VIEW vw_ListaFuncionarios AS
SELECT 
    f.id_funcionario,
    f.nome,
    f.data_admissao,
    f.valor_hora,
    c.descricao AS carreira,
    nc.descricao AS nivel,
    nc.vencimento_base
FROM Funcionario f
JOIN Carreira c ON f.id_carreira = c.id_carreira
JOIN Nivel_Carreira nc ON f.id_nivel_carreira = nc.id_nivel_carreira;
GO
