

-- Esquema Relacional com IDENTITY para chaves primárias

CREATE TABLE Categoria (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE Sub_Categoria (
    id_sub_categoria INT IDENTITY(1,1) PRIMARY KEY,
    id_categoria INT,
    nome VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)   
);

CREATE TABLE Fornecedor (
    id_fornecedor INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(20),
    observacoes TEXT
);

CREATE TABLE Produto (
    id_produto INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_custo DECIMAL(10,2),
    -- preco_venda DECIMAL(10,2),
    stock_atual INT,
    stock_minimo INT,
    ativo BIT DEFAULT 1,
    -- quantidade_encomenda INT,
    -- data_ultima_encomenda DATE,
);

CREATE TABLE Produto_Fornecedor (
    id_produto INT,
    id_fornecedor INT,
    preco_fornecedor DECIMAL(10,2),
    observacoes TEXT,
    PRIMARY KEY (id_produto, id_fornecedor),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto),
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor)
);

CREATE TABLE Prato (
    id_prato INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_venda DECIMAL(10,2),
    custo_unidade DECIMAL(10,2),
    tempo_preparo TIME,
    id_categoria INT,
    id_sub_categoria INT,
    ativo BIT DEFAULT 1,
    observacoes TEXT,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    FOREIGN KEY (id_sub_categoria) REFERENCES Sub_Categoria(id_sub_categoria)
);

CREATE TABLE Bebida (
    id_bebida INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_venda DECIMAL(10,2),
    custo_unidade DECIMAL(10,2),
    tempo_preparo TIME,
    id_categoria INT,
    id_sub_categoria INT,
    ativo BIT DEFAULT 1,
    observacoes TEXT,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    FOREIGN KEY (id_sub_categoria) REFERENCES Sub_Categoria(id_sub_categoria)
);

CREATE TABLE Artigo (
    id_artigo INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_venda DECIMAL(10,2),
    custo_unidade DECIMAL(10,2),
    tempo_preparo TIME,
    id_categoria INT,
    id_sub_categoria INT,
    ativo BIT DEFAULT 1,
    observacoes TEXT,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
    FOREIGN KEY (id_sub_categoria) REFERENCES Sub_Categoria(id_sub_categoria)
);

CREATE TABLE Prato_Produto (
    id_prato INT,
    id_produto INT,
    quantidade_utilizada INT,
    PRIMARY KEY (id_prato, id_produto),
    FOREIGN KEY (id_prato) REFERENCES Prato(id_prato),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

CREATE TABLE Bebida_Produto (
    id_bebida INT,
    id_produto INT,
    quantidade_utilizada INT,
    PRIMARY KEY (id_bebida, id_produto),
    FOREIGN KEY (id_bebida) REFERENCES Bebida(id_bebida),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

CREATE TABLE Artigo_Produto (
    id_artigo INT,
    id_produto INT,
    quantidade_utilizada INT,
    PRIMARY KEY (id_artigo, id_produto),
    FOREIGN KEY (id_artigo) REFERENCES Artigo(id_artigo),
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto)
);

---



CREATE TABLE Mesa (
    id_mesa INT IDENTITY(1,1) PRIMARY KEY,
    numero INT,
    lugares INT,
    disponivel BIT DEFAULT 1
);

CREATE TABLE Comanda (
    id_comanda UNIQUEIDENTIFIER PRIMARY KEY,
    id_mesa INT,
    estado VARCHAR(50), -- aberta, fechada, cancelada
    data_abertura DATETIME,
    data_fechamento DATETIME,
    total DECIMAL(10,2),
    quantidade_pratos INT,
    quantidade_bebidas INT,
    quantidade_artigos INT,
    FOREIGN KEY (id_mesa) REFERENCES Mesa(id_mesa)
);

abrir pedid -> comanda associada

CREATE TABLE Pedido (
    id_pedido INT IDENTITY(1,1) PRIMARY KEY,
    id_comanda UNIQUEIDENTIFIER,
    origem VARCHAR(50), -- mesa, take-away, delivery
    id_item_pedido INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    perc_imposto DECIMAL(10,2),
    perc_desconto DECIMAL(10,2),
    id_funcionario INT,
    id_cliente INT,
    data_hora DATETIME,
    pedido_estado VARCHAR(50)
    observacoes TEXT,
    valor_total DECIMAL(10,2),
    FOREIGN KEY (id_comanda) REFERENCES Comanda(id_comanda),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE Fatura (
    id_fatura INT IDENTITY(1,1) PRIMARY KEY,
    id_pedido INT,
    id_comanda UNIQUEIDENTIFIER,
    id_cliente INT,
    valor_sem_imposto DECIMAL(10,2),
    total_imposto DECIMAL(10,2),
    tipo_iva_comida DECIMAL(5,2),
    tipo_iva_bebida DECIMAL(5,2),
    valor_total DECIMAL(10,2),
    data_fechamento DATE,
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
);

CREATE TABLE Funcionario (
    id_funcionario INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100),
    nif VARCHAR(15),
    morada VARCHAR(255),
    localidade VARCHAR(100),
    codigo_postal VARCHAR(20),
    telefone VARCHAR(20),
    email VARCHAR(100),
    cargo VARCHAR(50),
    data_contratacao DATE,
    salario_base_hora DECIMAL(10,2)
);

CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100),
    nif VARCHAR(15),
    morada VARCHAR(255),
    localidade VARCHAR(100),
    codigo_postal VARCHAR(20),
    tipo_cliente VARCHAR(50)
);

CREATE TABLE Fatura (
    id_fatura INT IDENTITY(1,1) PRIMARY KEY,
    id_pedido INT,
    data DATE,
    valor_total DECIMAL(10,2),
    valor_iva DECIMAL(10,2),
    tipo_iva_comida DECIMAL(5,2),
    tipo_iva_bebida DECIMAL(5,2),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
);

