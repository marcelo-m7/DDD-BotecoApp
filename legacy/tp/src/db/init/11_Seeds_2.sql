-- Inserção de dados de teste para o sistema Restaurante_Vista_Formosa

-- 1. Categorias e Pratos
INSERT INTO Categoria (nome) VALUES ('Carne'), ('Peixe'), ('Sobremesa'), ('Bebida');

INSERT INTO Prato (nome, preco_venda, tempo_preparo, id_categoria, observacoes)
VALUES 
('Bife com Batatas', 12.50, '00:20:00', 1, NULL),
('Bacalhau à Brás', 14.00, '00:25:00', 2, NULL),
('Mousse de Chocolate', 4.50, '00:10:00', 3, NULL),
('Coca-Cola', 2.50, '00:01:00', 4, NULL);

-- 2. Fornecedor e Produtos
INSERT INTO Fornecedor (nome, email, telefone)
VALUES ('Fornecedor A', 'forn@a.com', '910000000');

INSERT INTO Produto (nome, descricao, preco_custo, stock_atual, stock_minimo, quantidade_encomenda, data_ultima_encomenda, id_fornecedor)
VALUES 
('Batata', 'Para fritar', 0.5, 300, 50, 100, GETDATE(), 1),
('Carne', 'Bovina', 5.0, 100, 20, 50, GETDATE(), 1),
('Ovos', 'Galináceos', 1.2, 60, 10, 30, GETDATE(), 1),
('Chocolate', '70% cacau', 2.0, 30, 5, 20, GETDATE(), 1),
('Refrigerante', 'Coca-Cola', 0.8, 50, 10, 30, GETDATE(), 1);

-- 3. Composição dos pratos
INSERT INTO Prato_Produto (id_prato, id_produto, quantidade_utilizada)
VALUES
(1, 1, 3),
(1, 2, 1),
(2, 3, 2),
(3, 4, 1),
(4, 5, 1);

-- 4. Funcionário, Cliente e Mesa
INSERT INTO Carreira (descricao) VALUES ('Empregado de Mesa');
INSERT INTO Nivel_Carreira (descricao, vencimento_base) VALUES ('1ª Classe', 900.00);

INSERT INTO Funcionario (nome, data_admissao, valor_hora, id_carreira, id_nivel_carreira)
VALUES ('Joana Silva', '2023-12-01', 6.50, 1, 1);

INSERT INTO Cliente (nome, nif, morada, localidade, codigo_postal, tipo_cliente)
VALUES ('Carlos Pinto', '999999999', 'Av. Principal 123', 'Porto', '4000-000', 'Particular');

INSERT INTO Mesa (numero, lugares) VALUES (10, 4);

-- 5. Fazer pedido
DECLARE @pratos Tipo_PedidoPrato;
INSERT INTO @pratos (id_prato, quantidade)
VALUES (1, 1), (4, 2);

EXEC sp_InserirPedidoCompleto 
    @id_mesa = 1,
    @id_funcionario = 1,
    @id_cliente = 1,
    @data_hora = GETDATE(),
    @observacoes = 'Sem sal no bife',
    @pratos = @pratos;

-- 6. Finalizar pedido e gerar fatura
EXEC sp_FinalizarMesaEGerarFatura @id_mesa = 1;

-- 7. Ver dados da fatura
SELECT TOP 1 * FROM Fatura ORDER BY id_fatura DESC;
-- Use o ID retornado abaixo para consultar a fatura detalhada
-- Exemplo:
-- SELECT * FROM dbo.fn_DetalhesFatura(1);
