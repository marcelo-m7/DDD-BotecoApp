
-- Inserir clientes
INSERT INTO Cliente (nome, nif, morada, localidade, codigo_postal, tipo_cliente)
VALUES 
('Carlos Silva', '123456789', 'Rua A, 123', 'Lisboa', '1000-000', 'Regular'),
('Joana Costa', '987654321', 'Rua B, 456', 'Porto', '4000-111', 'Ocasional');

-- Realizar um pedido
EXEC sp_RealizarPedido 
    @id_mesa = 1,
    @id_funcionario = 2,
    @id_cliente = 1,
    @observacoes = 'Cliente pediu sem sal';

-- Verificar o último pedido gerado (simulação)
-- Supondo que o ID seja 1 para fins de exemplo:
-- Adicionar pratos ao pedido
EXEC sp_AdicionarPratoPedido @id_pedido = 1, @id_prato = 1, @quantidade = 1; -- Bife com Batatas
EXEC sp_AdicionarPratoPedido @id_pedido = 1, @id_prato = 3, @quantidade = 2; -- Batata Frita

-- Finalizar o pedido (gerar fatura)
EXEC sp_FinalizarMesa 
    @id_pedido = 1,
    @tipo_iva_comida = 13.00,
    @tipo_iva_bebida = 23.00;
