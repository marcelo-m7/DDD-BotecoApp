-- 1. Criar tabela de materialização
CREATE TABLE mv_StocksUtilizadosPorPeriodo (
    id_produto INT,
    nome_produto VARCHAR(100),
    data DATE,
    quantidade_utilizada INT
);
GO

-- 2. Popular a tabela com base nos dados históricos
INSERT INTO mv_StocksUtilizadosPorPeriodo (id_produto, nome_produto, data, quantidade_utilizada)
SELECT 
    pp.id_produto,
    pr.nome,
    CAST(ped.data_hora AS DATE) AS data,
    SUM(pp.quantidade_utilizada * pped.quantidade) AS quantidade_total
FROM Pedido ped
JOIN Pedido_Prato pped ON ped.id_pedido = pped.id_pedido
JOIN Prato_Produto pp ON pped.id_prato = pp.id_prato
JOIN Produto pr ON pp.id_produto = pr.id_produto
GROUP BY pp.id_produto, pr.nome, CAST(ped.data_hora AS DATE);
GO

-- 3. Criar índice para otimizar busca por nome do produto
CREATE INDEX idx_nome_produto ON mv_StocksUtilizadosPorPeriodo (nome_produto);
