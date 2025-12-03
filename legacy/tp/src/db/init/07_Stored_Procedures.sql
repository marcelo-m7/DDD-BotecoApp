-- 1. Procedure para mostrar o valor gasto em vencimentos em determinado mês e ano
CREATE PROCEDURE sp_MostrarValorGastoVencimentos
    @mes INT,
    @ano INT
AS
BEGIN
    DECLARE @valor DECIMAL(10,2)

    SET @valor = dbo.fn_ValorGastoVencimentos(@mes, @ano)

    SELECT @valor AS valor_gasto_vencimentos
END;

GO

-- 2. Procedure para mostrar os valores gastos com stocks em determinado mês e ano
CREATE PROCEDURE sp_MostrarValoresGastosStocks
    @mes INT,
    @ano INT
AS
BEGIN
    SELECT *
    FROM dbo.fn_ValoresGastosStocks(@mes, @ano)
END;

/*
EXEC sp_MostrarValorGastoVencimentos @mes = 4, @ano = 2025;
EXEC sp_MostrarValoresGastosStocks @mes = 4, @ano = 2025;
*/
