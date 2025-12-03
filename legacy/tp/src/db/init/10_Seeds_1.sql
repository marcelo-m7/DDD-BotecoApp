/* 
- Verificar os cálculos de custo de ingredientes.
- Ver como os vencimentos são computados.
- Observar a receita gerada pelo pedido.
- Testar filtros por data/mês/ano nas views.
*/

-- 1. Categorias e Pratos
INSERT INTO Categoria (nome)
VALUES ('Carne'), ('Peixe'), ('Sobremesa');

-- Supondo que: Carne = 1, Peixe = 2, Sobremesa = 3
INSERT INTO Prato (nome, preco_venda, tempo_preparo, id_categoria, observacoes)
VALUES 
('Bife com Batatas', 12.50, '00:20:00', 1, 'Bem passado'),
('Bacalhau à Brás', 14.00, '00:25:00', 2, NULL),
('Mousse de Chocolate', 4.50, '00:10:00', 3, NULL);

-- 2. Fornecedores e Produtos
INSERT INTO Fornecedor (nome, email, telefone)
VALUES ('Fornecedor A', 'contato@a.com', '912345678');

-- Supondo id_fornecedor = 1
INSERT INTO Produto (nome, descricao, preco_custo, stock_atual, stock_minimo, quantidade_encomenda, data_ultima_encomenda, id_fornecedor)
VALUES 
('Batata', 'Batata branca', 0.50, 500, 100, 200, '2025-04-01', 1),
('Carne de vaca', 'File mignon', 5.00, 100, 20, 50, '2025-04-02', 1),
('Ovos', 'Caixa 12 unid.', 1.20, 60, 10, 30, '2025-04-02', 1),
('Chocolate', 'Chocolate preto 70%', 2.00, 30, 5, 20, '2025-04-03', 1);


-- 3. Composição dos pratos (Prato_Produto)
-- Exemplo com nomes:
SELECT id_prato, nome FROM Prato;
SELECT id_produto, nome FROM Produto;

-- Depois, use esses IDs (supondo que são coerentes com a ordem dos inserts acima):
INSERT INTO Prato_Produto (id_prato, id_produto, quantidade_utilizada)
VALUES
(1, 1, 3), -- Bife com Batatas usa 3 batatas
(1, 2, 1), -- ... e 1 carne
(2, 3, 2), -- Bacalhau usa 2 ovos
(3, 4, 1); -- Mousse usa 1 chocolate


-- 4. Funcionários, carreiras e horas
INSERT INTO Carreira (descricao)
VALUES ('Cozinheiro');

INSERT INTO Nivel_Carreira (descricao, vencimento_base)
VALUES ('Cozinheiro 1ª', 900.00);

-- Supondo Carreira = 1, Nivel = 1
INSERT INTO Funcionario (nome, data_admissao, valor_hora, id_carreira, id_nivel_carreira)
VALUES ('João Silva', '2024-01-10', 6.50, 1, 1);

INSERT INTO Horas_Trabalhadas (id_funcionario, mes, ano, horas_normais, horas_extra)
VALUES (1, 4, 2025, 160, 6);

-- 5. Cliente, mesa, pedido e pratos pedidos
INSERT INTO Cliente (nome, nif, morada, localidade, codigo_postal, tipo_cliente)
VALUES ('Maria Santos', '123456789', 'Rua A, 123', 'Lisboa', '1000-001', 'Particular');

INSERT INTO Mesa (numero, lugares)
VALUES (5, 4);

-- Supondo Cliente = 1, Mesa = 1, Funcionario = 1
INSERT INTO Pedido (id_mesa, id_funcionario, id_cliente, data_hora, estado, observacoes)
VALUES (1, 1, 1, '2025-04-08 13:00:00', 'Servido', 'Sem sal na carne');

-- Recupere id_pedido e insira os pratos
-- Ex: SELECT id_pedido FROM Pedido;

INSERT INTO Pedido_Prato (id_pedido, id_prato, quantidade)
VALUES 
(1, 1, 2), -- 2 Bifes
(1, 3, 1); -- 1 Mousse
