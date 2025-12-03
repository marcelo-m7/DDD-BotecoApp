
-- View 1: Estoque atual de todos os produtos
DROP VIEW IF EXISTS vw_EstoqueAtual;
GO

CREATE VIEW vw_EstoqueAtual AS
SELECT 
    p.id_produto,
    p.nome,
    p.descricao,
    p.stock_atual,
    p.stock_minimo,
    p.quantidade_encomenda,
    f.nome AS fornecedor,
    p.data_ultima_encomenda
FROM Produto p
LEFT JOIN Fornecedor f ON p.id_fornecedor = f.id_fornecedor;
GO

-- View 2: Produtos abaixo do estoque mínimo
DROP VIEW IF EXISTS vw_ProdutosAbaixoMinimo;
GO

CREATE VIEW vw_ProdutosAbaixoMinimo AS
SELECT 
    p.id_produto,
    p.nome,
    p.stock_atual,
    p.stock_minimo,
    (p.stock_minimo - p.stock_atual) AS faltam_unidades,
    f.nome AS fornecedor
FROM Produto p
LEFT JOIN Fornecedor f ON p.id_fornecedor = f.id_fornecedor
WHERE p.stock_atual < p.stock_minimo;
GO

-- Procedure 1: Reposição manual de estoque
DROP PROCEDURE IF EXISTS sp_ReporEstoqueManual;
GO

CREATE PROCEDURE sp_ReporEstoqueManual
    @id_produto INT,
    @quantidade INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Produto
    SET stock_atual = stock_atual + @quantidade,
        data_ultima_encomenda = GETDATE()
    WHERE id_produto = @id_produto;
END;
GO
