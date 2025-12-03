-- 1. Scalar Function: Valor gasto em vencimentos em determinado mês e ano
CREATE FUNCTION fn_ValorGastoVencimentos (
    @mes INT,
    @ano INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @valor_total DECIMAL(10,2)

    SELECT @valor_total = SUM(
        ht.horas_normais * f.valor_hora +
        CASE 
            WHEN ht.horas_extra <= 2 THEN ht.horas_extra * f.valor_hora
            WHEN ht.horas_extra <= 7 THEN (2 * f.valor_hora) + ((ht.horas_extra - 2) * 1.5 * f.valor_hora)
            ELSE (2 * f.valor_hora) + (5 * 1.5 * f.valor_hora) + ((ht.horas_extra - 7) * 2 * f.valor_hora)
        END
    )
    FROM Horas_Trabalhadas ht
    JOIN Funcionario f ON ht.id_funcionario = f.id_funcionario
    WHERE ht.mes = @mes AND ht.ano = @ano;

    RETURN ISNULL(@valor_total, 0);
END;

GO
-- 2. Table-Valued Function: Valores gastos com stocks de produtos utilizados em determinado mês e ano
CREATE FUNCTION fn_ValoresGastosStocks (
    @mes INT,
    @ano INT
)
RETURNS TABLE
AS
RETURN
    SELECT 
        pr.id_produto,
        pr.nome AS nome_produto,
        SUM(pp.quantidade_utilizada * pr.preco_custo * pped.quantidade) AS valor_gasto
    FROM Pedido ped
    JOIN Pedido_Prato pped ON ped.id_pedido = pped.id_pedido
    JOIN Prato_Produto pp ON pped.id_prato = pp.id_prato
    JOIN Produto pr ON pp.id_produto = pr.id_produto
    WHERE MONTH(ped.data_hora) = @mes AND YEAR(ped.data_hora) = @ano
    GROUP BY pr.id_produto, pr.nome;
