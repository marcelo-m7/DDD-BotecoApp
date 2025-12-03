-- 1. Trigger para diminuir o estoque ao inserir um prato no pedido
DROP TRIGGER IF EXISTS trg_AtualizarStock_Produtos;
GO

CREATE TRIGGER trg_AtualizarStock_Produtos
ON Pedido_Prato
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Produto
    SET stock_atual = stock_atual - usado.qtd_utilizada
    FROM Produto p
    JOIN (
        SELECT 
            pp.id_produto,
            SUM(pp.quantidade_utilizada * i.quantidade) AS qtd_utilizada
        FROM inserted i
        JOIN Prato_Produto pp ON i.id_prato = pp.id_prato
        GROUP BY pp.id_produto
    ) AS usado ON p.id_produto = usado.id_produto;
END;
GO

-- 2. Reposição automática de estoque quando o nível mínimo for atingido
DROP TRIGGER IF EXISTS trg_ReporEstoque;
GO

CREATE TRIGGER trg_ReporEstoque
ON Produto
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.stock_atual = p.stock_atual + (p.quantidade_encomenda - p.stock_atual + p.stock_minimo),
        p.data_ultima_encomenda = GETDATE()
    FROM Produto p
    JOIN inserted i ON p.id_produto = i.id_produto
    WHERE i.stock_atual < i.stock_minimo;
END;
GO

-- 3. Atualização da materialized view mv_StocksUtilizadosPorPeriodo
DROP TRIGGER IF EXISTS trg_AtualizarMV_Stocks;
GO

CREATE TRIGGER trg_AtualizarMV_Stocks
ON Pedido_Prato
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mv_StocksUtilizadosPorPeriodo (id_produto, nome_produto, data, quantidade_utilizada)
    SELECT 
        pp.id_produto,
        p.nome,
        CAST(pe.data_hora AS DATE),
        SUM(pp.quantidade_utilizada * i.quantidade)
    FROM inserted i
    JOIN Pedido pe ON i.id_pedido = pe.id_pedido
    JOIN Prato_Produto pp ON i.id_prato = pp.id_prato
    JOIN Produto p ON pp.id_produto = p.id_produto
    GROUP BY pp.id_produto, p.nome, CAST(pe.data_hora AS DATE);
END;
GO
