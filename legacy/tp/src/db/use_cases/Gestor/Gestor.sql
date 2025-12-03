
-- Procedure 1: Inserir nova categoria de prato
DROP PROCEDURE IF EXISTS sp_InserirCategoria;
GO
CREATE PROCEDURE sp_InserirCategoria
    @nome VARCHAR(100)
AS
BEGIN
    INSERT INTO Categoria (nome)
    VALUES (@nome);
END;
GO

-- Procedure 2: Inserir novo fornecedor
DROP PROCEDURE IF EXISTS sp_InserirFornecedor;
GO
CREATE PROCEDURE sp_InserirFornecedor
    @nome VARCHAR(100),
    @email VARCHAR(100),
    @telefone VARCHAR(20)
AS
BEGIN
    INSERT INTO Fornecedor (nome, email, telefone)
    VALUES (@nome, @email, @telefone);
END;
GO

-- Procedure 3: Inserir novo produto no estoque
DROP PROCEDURE IF EXISTS sp_InserirProduto;
GO
CREATE PROCEDURE sp_InserirProduto
    @nome VARCHAR(100),
    @descricao TEXT,
    @preco_custo DECIMAL(10,2),
    @stock_atual INT,
    @stock_minimo INT,
    @quantidade_encomenda INT,
    @id_fornecedor INT
AS
BEGIN
    INSERT INTO Produto (nome, descricao, preco_custo, stock_atual, stock_minimo, quantidade_encomenda, data_ultima_encomenda, id_fornecedor)
    VALUES (@nome, @descricao, @preco_custo, @stock_atual, @stock_minimo, @quantidade_encomenda, GETDATE(), @id_fornecedor);
END;
GO

-- Procedure 4: Inserir novo prato no cardápio
DROP PROCEDURE IF EXISTS sp_InserirPrato;
GO
CREATE PROCEDURE sp_InserirPrato
    @nome VARCHAR(100),
    @preco_venda DECIMAL(10,2),
    @tempo_preparo TIME,
    @id_categoria INT,
    @observacoes TEXT
AS
BEGIN
    INSERT INTO Prato (nome, preco_venda, tempo_preparo, id_categoria, observacoes)
    VALUES (@nome, @preco_venda, @tempo_preparo, @id_categoria, @observacoes);
END;
GO

-- Procedure 5: Relacionar ingredientes a um prato
DROP PROCEDURE IF EXISTS sp_AssociarIngredientesAoPrato;
GO
CREATE PROCEDURE sp_AssociarIngredientesAoPrato
    @id_prato INT,
    @id_produto INT,
    @quantidade_utilizada INT
AS
BEGIN
    INSERT INTO Prato_Produto (id_prato, id_produto, quantidade_utilizada)
    VALUES (@id_prato, @id_produto, @quantidade_utilizada);
END;
GO

-- Procedure 6: Inserir mesa
DROP PROCEDURE IF EXISTS sp_InserirMesa;
GO
CREATE PROCEDURE sp_InserirMesa
    @numero INT,
    @lugares INT
AS
BEGIN
    INSERT INTO Mesa (numero, lugares)
    VALUES (@numero, @lugares);
END;
GO
