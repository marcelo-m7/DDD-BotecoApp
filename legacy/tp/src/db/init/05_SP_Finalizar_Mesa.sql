/* Stored Procedure sp_FinalizarMesaEGerarFatura
Recebe o id_mesa.

Verifica se há um pedido em aberto para essa mesa.

Calcula o total do pedido (com IVA).

Gera a fatura automaticamente.

Atualiza o estado do pedido para "Finalizado"
*/
CREATE PROCEDURE sp_FinalizarMesaEGerarFatura
    @id_mesa INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_pedido INT;
    DECLARE @valor_comida DECIMAL(10,2) = 0;
    DECLARE @valor_bebida DECIMAL(10,2) = 0;
    DECLARE @valor_total DECIMAL(10,2);
    DECLARE @valor_iva DECIMAL(10,2);
    DECLARE @iva_comida DECIMAL(5,2) = 13;
    DECLARE @iva_bebida DECIMAL(5,2) = 23;

    -- 1. Obter pedido em aberto da mesa
    SELECT TOP 1 @id_pedido = id_pedido
    FROM Pedido
    WHERE id_mesa = @id_mesa AND estado <> 'Finalizado'
    ORDER BY data_hora DESC;

    IF @id_pedido IS NULL
    BEGIN
        RAISERROR('Nenhum pedido em aberto encontrado para essa mesa.', 16, 1);
        RETURN;
    END

    -- 2. Calcular valores com base nas categorias (simplificação)
    SELECT 
        @valor_comida = SUM(pp.quantidade * pr.preco_venda)
    FROM Pedido_Prato pp
    JOIN Prato pr ON pp.id_prato = pr.id_prato
    JOIN Categoria c ON pr.id_categoria = c.id_categoria
    WHERE pp.id_pedido = @id_pedido AND c.nome <> 'Bebida';

    SELECT 
        @valor_bebida = SUM(pp.quantidade * pr.preco_venda)
    FROM Pedido_Prato pp
    JOIN Prato pr ON pp.id_prato = pr.id_prato
    JOIN Categoria c ON pr.id_categoria = c.id_categoria
    WHERE pp.id_pedido = @id_pedido AND c.nome = 'Bebida';

    -- 3. Calcular valores finais
    SET @valor_total = ISNULL(@valor_comida,0) + ISNULL(@valor_bebida,0);
    SET @valor_iva = ROUND((ISNULL(@valor_comida,0) * @iva_comida / 100.0) + 
                           (ISNULL(@valor_bebida,0) * @iva_bebida / 100.0), 2);

    -- 4. Inserir fatura
    INSERT INTO Fatura (id_pedido, data, valor_total, valor_iva, tipo_iva_comida, tipo_iva_bebida)
    VALUES (@id_pedido, GETDATE(), @valor_total, @valor_iva, @iva_comida, @iva_bebida);

    -- 5. Atualizar pedido para finalizado
    UPDATE Pedido
    SET estado = 'Finalizado'
    WHERE id_pedido = @id_pedido;

    -- 6. Exibir resumo
    SELECT 
        @id_pedido AS id_pedido,
        @valor_total AS total_sem_iva,
        @valor_iva AS valor_iva,
        (@valor_total + @valor_iva) AS total_com_iva;
END;

/* Para usar
EXEC sp_FinalizarMesaEGerarFatura @id_mesa = 1;
*/