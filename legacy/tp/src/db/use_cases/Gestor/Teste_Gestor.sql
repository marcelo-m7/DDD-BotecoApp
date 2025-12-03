
-- Inserir categorias de pratos
INSERT INTO Categoria (nome) VALUES ('Entradas');
INSERT INTO Categoria (nome) VALUES ('Pratos Principais');
INSERT INTO Categoria (nome) VALUES ('Sobremesas');
INSERT INTO Categoria (nome) VALUES ('Bebidas');

-- Inserir fornecedores
INSERT INTO Fornecedor (nome, email, telefone)
VALUES ('Fornecedor A', 'fornecedorA@email.com', '1111-1111'),
       ('Fornecedor B', 'fornecedorB@email.com', '2222-2222');

-- Inserir produtos no estoque
INSERT INTO Produto (nome, descricao, preco_custo, stock_atual, stock_minimo, quantidade_encomenda, data_ultima_encomenda, id_fornecedor)
VALUES 
    ('Batata', 'Batata inglesa para fritar', 0.50, 100, 20, 50, GETDATE(), 1),
    ('Carne Bovina', 'Carne para bife', 10.00, 50, 10, 20, GETDATE(), 1),
    ('Ovos', 'Ovos brancos', 0.30, 200, 50, 100, GETDATE(), 2),
    ('Cerveja', 'Cerveja artesanal', 1.20, 80, 30, 40, GETDATE(), 2);

-- Inserir pratos
INSERT INTO Prato (nome, preco_venda, tempo_preparo, id_categoria, observacoes)
VALUES 
    ('Bife com Batatas', 15.00, '00:20:00', 2, 'Servido com arroz e salada'),
    ('Omelete Simples', 8.00, '00:10:00', 2, 'Feito com ovos e temperos'),
    ('Batata Frita', 5.00, '00:08:00', 1, 'Porção individual'),
    ('Cerveja 500ml', 3.00, '00:01:00', 4, NULL);

-- Associar produtos aos pratos (ingredientes)
INSERT INTO Prato_Produto (id_prato, id_produto, quantidade_utilizada)
VALUES 
    (1, 2, 1), -- Bife com Batatas usa 1x Carne
    (1, 1, 2), -- Bife com Batatas usa 2x Batata
    (2, 3, 3), -- Omelete usa 3x Ovos
    (3, 1, 3); -- Batata Frita usa 3x Batata

-- Inserir mesas
INSERT INTO Mesa (numero, lugares)
VALUES 
    (1, 4),
    (2, 2),
    (3, 6),
    (4, 8);
