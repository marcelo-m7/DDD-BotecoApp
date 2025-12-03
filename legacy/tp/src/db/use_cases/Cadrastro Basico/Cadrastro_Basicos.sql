/* Procedimentos básico para inserção de novos dados na tabela:
    sp_InserirProduto
    sp_InserirPrato
    sp_InserirBebida
    sp_InserirFornecedor
    sp_InserirFuncionario
    sp_InserirFuncionarioLogin
    sp_InserirCliente
    sp_InserirMesa
    sp_InserirCategoria
    AssociarIngredientesAoPrato
*/

-- Procedimento para sp_inserir um novo Produto
CREATE PROCEDURE sp_InserirProduto
    @nome VARCHAR(100),
    @descricao TEXT,
    @preco_custo DECIMAL(10,2),
    @stock_atual INT,
    @stock_minimo INT,
    @quantidade_encomenda INT,
    @data_ultima_encomenda DATE,
    @id_fornecedor INT
AS
BEGIN
    INSERT INTO Produto (nome, descricao, preco_custo, stock_atual, stock_minimo, quantidade_encomenda, data_ultima_encomenda, id_fornecedor)
    VALUES (@nome, @descricao, @preco_custo, @stock_atual, @stock_minimo, @quantidade_encomenda, @data_ultima_encomenda, @id_fornecedor);
END;
GO

-- Procedimento para sp_inserir um novo Prato
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

-- Procedimento para sp_inserir uma nova Bebida
CREATE PROCEDURE sp_InserirBebida
    @nome VARCHAR(100),
    @preco_venda DECIMAL(10,2),
    @tempo_preparo TIME,
    @id_categoria INT,
    @observacoes TEXT
AS
BEGIN
    INSERT INTO Bebida (nome, preco_venda, tempo_preparo, id_categoria, observacoes)
    VALUES (@nome, @preco_venda, @tempo_preparo, @id_categoria, @observacoes);
END;
GO

-- Procedimento para sp_inserir um novo Fornecedor
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

-- Procedimento para sp_inserir um novo Funcionário
CREATE PROCEDURE sp_InserirFuncionario
    @nome VARCHAR(100),
    @data_admissao DATE,
    @valor_hora DECIMAL(10,2),
    @id_carreira INT,
    @id_nivel_carreira INT,
    @senha_hash VARCHAR(255)
AS
BEGIN
    INSERT INTO Funcionario (nome, data_admissao, valor_hora, id_carreira, id_nivel_carreira, senha_hash)
    VALUES (@nome, @data_admissao, @valor_hora, @id_carreira, @id_nivel_carreira, @senha_hash);
END;
GO

-- Procedimento para criar login de um novo Funcionário
CREATE PROCEDURE sp_InserirFuncionarioLogin
    @id_funcionario INT,
    @username VARCHAR(100),
    @senha_hash VARCHAR(255)
AS
BEGIN
    INSERT INTO Funcionario_Login (id_funcionario, username, senha_hash)
    VALUES (@id_funcionario, @username, @senha_hash);
END;
GO

-- Procedimento para criar um novo Cliente
CREATE PROCEDURE sp_InserirCliente
    @nome VARCHAR(100),
    @nif VARCHAR(15),
    @morada VARCHAR(255),
    @localidade VARCHAR(100),
    @codigo_postal VARCHAR(20),
    @tipo_cliente VARCHAR(50)
AS
BEGIN
    INSERT INTO Cliente (nome, nif, morada, localidade, codigo_postal, tipo_cliente)
    VALUES (@nome, @nif, @morada, @localidade, @codigo_postal, @tipo_cliente);
END;
GO

-- Procedure para criar nova categoria de prato
CREATE PROCEDURE sp_InserirCategoria
    @nome VARCHAR(100)
AS
BEGIN
    INSERT INTO Categoria (nome)
    VALUES (@nome);
END;
GO

-- Procedure para relacionar ingredientes a um prato
GO
CREATE PROCEDURE AssociarIngredientesAoPrato
    @id_prato INT,
    @id_produto INT,
    @quantidade_utilizada INT
AS
BEGIN
    INSERT INTO Prato_Produto (id_prato, id_produto, quantidade_utilizada)
    VALUES (@id_prato, @id_produto, @quantidade_utilizada);
END;
GO

-- Procedure para sp_inserir mesa
CREATE PROCEDURE sp_InserirMesa
    @numero INT,
    @lugares INT
AS
BEGIN
    INSERT INTO Mesa (numero, lugares)
    VALUES (@numero, @lugares);
END;
