-- 1. Valor gasto dos stocks de produtos utilizados por período de tempo
CREATE VIEW vw_ValorGastoStocksPorPeriodo AS
SELECT 
    ppt.id_produto,
    pr.nome AS nome_produto,
    SUM(ppd.quantidade * ppt.quantidade_utilizada * pr.preco_custo) AS valor_gasto,
    CAST(ped.data_hora AS DATE) AS data_pedido
FROM Pedido ped
JOIN Pedido_Prato ppd ON ped.id_pedido = ppd.id_pedido
JOIN Prato_Produto ppt ON ppd.id_prato = ppt.id_prato
JOIN Produto pr ON ppt.id_produto = pr.id_produto
GROUP BY ppt.id_produto, pr.nome, CAST(ped.data_hora AS DATE);

GO

-- 2. Valor gasto em vencimentos por período (mês e ano)
CREATE VIEW vw_ValorGastoVencimentosPorPeriodo AS
SELECT 
    ht.ano,
    ht.mes,
    f.id_funcionario,
    f.nome,
    nc.vencimento_base,
    ht.horas_normais * f.valor_hora +
    CASE 
        WHEN ht.horas_extra <= 2 THEN ht.horas_extra * f.valor_hora
        WHEN ht.horas_extra <= 7 THEN (2 * f.valor_hora) + ((ht.horas_extra - 2) * 1.5 * f.valor_hora)
        ELSE (2 * f.valor_hora) + (5 * 1.5 * f.valor_hora) + ((ht.horas_extra - 7) * 2 * f.valor_hora)
    END AS valor_total
FROM Horas_Trabalhadas ht
JOIN Funcionario f ON ht.id_funcionario = f.id_funcionario
JOIN Nivel_Carreira nc ON f.id_nivel_carreira = nc.id_nivel_carreira;
GO

-- 3. Valor recebido em refeições por período de tempo
CREATE VIEW vw_ValorRecebidoPorPeriodo AS
SELECT 
    ped.id_pedido,
    ped.data_hora,
    MONTH(ped.data_hora) AS mes,
    YEAR(ped.data_hora) AS ano,
    SUM(pp.quantidade * pr.preco_venda) AS valor_total
FROM Pedido ped
JOIN Pedido_Prato pp ON ped.id_pedido = pp.id_pedido
JOIN Prato pr ON pp.id_prato = pr.id_prato
GROUP BY ped.id_pedido, ped.data_hora;
GO

-- 4. Valores totais gastos em stocks, vencimentos e receitas por período de tempo
CREATE VIEW vw_ResumoFinanceiroPorPeriodo AS
SELECT 
    vrs.ano,
    vrs.mes,
    COALESCE(vrs.valor_total, 0) AS receita,
    COALESCE(vgs.valor_gasto, 0) AS gasto_em_stocks,
    COALESCE(vgv.valor_total, 0) AS gasto_em_vencimentos
FROM vw_ValorRecebidoPorPeriodo vrs
LEFT JOIN vw_ValorGastoStocksPorPeriodo vgs 
    ON MONTH(vgs.data_pedido) = vrs.mes AND YEAR(vgs.data_pedido) = vrs.ano
LEFT JOIN vw_ValorGastoVencimentosPorPeriodo vgv 
    ON vgv.mes = vrs.mes AND vgv.ano = vrs.ano;
GO