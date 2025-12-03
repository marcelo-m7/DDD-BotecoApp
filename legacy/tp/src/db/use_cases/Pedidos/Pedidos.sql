
-- Procedure 1: Realizar um novo pedido
DROP PROCEDURE IF EXISTS sp_RealizarPedido;
GO
CREATE PROCEDURE sp_RealizarPedido
    @id_mesa INT,
    @id_funcionario INT,
    @id_cliente INT,
    @observacoes TEXT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Pedido (id_mesa, id_funcionario, id_cliente, data_hora, estado, observacoes)
    VALUES (@id_mesa, @id_funcionario, @id_cliente, GETDATE(), 'Aberto', @observacoes);
END;
GO

-- Procedure 2: Adicionar prato ao pedido
DROP PROCEDURE IF EXISTS sp_AdicionarPratoPedido;
GO
CREATE PROCEDURE sp_AdicionarPratoPedido
    @id_pedido INT,
    @id_prato INT,
    @quantidade INT
AS
BEGIN
    INSERT INTO Pedido_Prato (id_pedido, id_prato, quantidade)
    VALUES (@id_pedido, @id_prato, @quantidade);
END;
GO

-- Procedure 3: Finalizar mesa (gerar fatura e fechar pedido)
DROP PROCEDURE IF EXISTS sp_FinalizarMesa;
GO
CREATE PROCEDURE sp_FinalizarMesa
    @id_pedido INT,
    @tipo_iva_comida DECIMAL(5,2),
    @tipo_iva_bebida DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @valor_total DECIMAL(10,2) = 0;
    DECLARE @valor_iva DECIMAL(10,2) = 0;

    SELECT @valor_total = SUM(pp.quantidade * pr.preco_venda)
    FROM Pedido_Prato pp
    JOIN Prato pr ON pp.id_prato = pr.id_prato
    WHERE pp.id_pedido = @id_pedido;

    -- Para simplificação, aplicar IVA único baseado no tipo do prato (comida/bebida)
    SET @valor_iva = (@valor_total * (@tipo_iva_comida / 100)); -- Ajustar se quiser separar comidas/bebidas

    INSERT INTO Fatura (id_pedido, data, valor_total, valor_iva, tipo_iva_comida, tipo_iva_bebida)
    VALUES (@id_pedido, GETDATE(), @valor_total, @valor_iva, @tipo_iva_comida, @tipo_iva_bebida);

    UPDATE Pedido
    SET estado = 'Fechado'
    WHERE id_pedido = @id_pedido;
END;
GO
