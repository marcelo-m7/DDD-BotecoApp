/* Procedure para realizar um pedido completo

- Dados do pedido (mesa, cliente, funcionário, data, observações).
- Lista de pratos com quantidades.
- Premissas da Procedure:
    - Recebe os IDs de mesa, cliente e funcionário.
    - Recebe observações do pedido (opcional).
    - Recebe uma tabela como parâmetro com os pratos e quantidades (TVP – Table-Valued Parameter)
*/
-- 1. Criar o tipo de tabela para lista de pratos
CREATE TYPE Tipo_PedidoPrato AS TABLE (
    id_prato INT,
    quantidade INT
);
GO
-- 2. Criar a procedure sp_InserirPedidoCompleto
CREATE PROCEDURE sp_InserirPedidoCompleto
    @id_mesa INT,
    @id_funcionario INT,
    @id_cliente INT,
    @data_hora DATETIME,
    @observacoes TEXT,
    @pratos Tipo_PedidoPrato READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @novo_pedido_id INT;

    -- Inserir pedido e obter ID
    INSERT INTO Pedido (id_mesa, id_funcionario, id_cliente, data_hora, estado, observacoes)
    VALUES (@id_mesa, @id_funcionario, @id_cliente, @data_hora, 'Recebido', @observacoes);

    SET @novo_pedido_id = SCOPE_IDENTITY();

    -- Inserir os pratos no pedido
    INSERT INTO Pedido_Prato (id_pedido, id_prato, quantidade)
    SELECT @novo_pedido_id, id_prato, quantidade
    FROM @pratos;

    -- Retornar o ID do pedido criado
    SELECT @novo_pedido_id AS id_pedido_criado;
END;

/* Exemplo de uso:
-- 1. Declarar e preencher a tabela de pratos
DECLARE @itens Tipo_PedidoPrato;

INSERT INTO @itens (id_prato, quantidade)
VALUES (1, 2), (3, 1); -- Ex: 2 bifes e 1 mousse

-- 2. Executar a procedure
EXEC sp_InserirPedidoCompleto 
    @id_mesa = 1,
    @id_funcionario = 1,
    @id_cliente = 1,
    @data_hora = GETDATE(),
    @observacoes = 'Tirar cebola do prato',
    @pratos = @itens;

*/