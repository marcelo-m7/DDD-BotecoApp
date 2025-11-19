
CREATE TABLE Carreira (
    id_carreira INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
);

CREATE TABLE Nivel_Carreira (
    id_nivel_carreira INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(100),
    vencimento_base DECIMAL(10,2)
);

CREATE TABLE Funcionario (
    id_funcionario INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_admissao DATE,
    valor_hora DECIMAL(10,2),
    id_carreira INT,
    id_nivel_carreira INT,
    senha_hash VARCHAR(255),
    FOREIGN KEY (id_carreira) REFERENCES Carreira(id_carreira),
    FOREIGN KEY (id_nivel_carreira) REFERENCES Nivel_Carreira(id_nivel_carreira)
);

CREATE TABLE Funcionario_Login (
    id_funcionario INT,
    username VARCHAR(100),
    senha_hash VARCHAR(255),
    PRIMARY KEY (id_funcionario),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Horas_Trabalhadas (
    id_funcionario INT,
    mes INT,
    ano INT,
    horas_normais INT,
    horas_extra INT,
    PRIMARY KEY (id_funcionario, mes, ano),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
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

CREATE TABLE Mesa (
    id_mesa INT IDENTITY(1,1) PRIMARY KEY,
    numero INT,
    lugares INT,
    disponivel BIT DEFAULT 1
);

CREATE TABLE Pedido (
    id_pedido INT IDENTITY(1,1) PRIMARY KEY,
    id_mesa INT,
    id_funcionario INT,
    id_cliente INT,
    data_hora DATETIME,
    estado VARCHAR(50),
    observacoes TEXT,
    FOREIGN KEY (id_mesa) REFERENCES Mesa(id_mesa),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE Pedido_Prato (
    id_pedido INT,
    id_prato INT,
    quantidade INT,
    PRIMARY KEY (id_pedido, id_prato),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_prato) REFERENCES Prato(id_prato)
);

CREATE TABLE Pedido_Bebida (
    id_pedido INT,
    id_bebida INT,
    quantidade INT,
    PRIMARY KEY (id_pedido, id_bebida),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_bebida) REFERENCES Bebida(id_bebida)
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

CREATE TABLE Evento_Especial (
    id_evento INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100),
    descricao TEXT,
    data_inicio DATE,
    data_fim DATE
);

CREATE TABLE Menu_Especial (
    id_menu INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100),
    preco DECIMAL(10,2),
    id_evento INT,
    FOREIGN KEY (id_evento) REFERENCES Evento_Especial(id_evento)
);

CREATE TABLE Menu_Especial_Prato (
    id_menu INT,
    id_prato INT,
    PRIMARY KEY (id_menu, id_prato),
    FOREIGN KEY (id_menu) REFERENCES Menu_Especial(id_menu),
    FOREIGN KEY (id_prato) REFERENCES Prato(id_prato)
);


CREATE TABLE Fornecedor (
    id_fornecedor INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(20)
);

CREATE TABLE Produto (
    id_produto INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco_custo DECIMAL(10,2),
    stock_atual INT,
    stock_minimo INT,
    quantidade_encomenda INT,
    data_ultima_encomenda DATE,
    id_fornecedor INT,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedor(id_fornecedor)
);

CREATE TABLE Prato (
    id_prato INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco_venda DECIMAL(10,2),
    tempo_preparo TIME,
    id_categoria INT,
    observacoes TEXT,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
);

CREATE TABLE Bebida (
    id_bebida INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco_venda DECIMAL(10,2),
    tempo_preparo TIME,
    id_categoria INT,
    observacoes TEXT,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
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

CREATE TABLE Carreira (
    id_carreira INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
);

CREATE TABLE Nivel_Carreira (
    id_nivel_carreira INT IDENTITY(1,1) PRIMARY KEY,
    descricao VARCHAR(100),
    vencimento_base DECIMAL(10,2)
);

CREATE TABLE Funcionario (
    id_funcionario INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_admissao DATE,
    valor_hora DECIMAL(10,2),
    id_carreira INT,
    id_nivel_carreira INT,
    senha_hash VARCHAR(255),
    FOREIGN KEY (id_carreira) REFERENCES Carreira(id_carreira),
    FOREIGN KEY (id_nivel_carreira) REFERENCES Nivel_Carreira(id_nivel_carreira)
);

CREATE TABLE Funcionario_Login (
    id_funcionario INT,
    username VARCHAR(100),
    senha_hash VARCHAR(255),
    PRIMARY KEY (id_funcionario),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Horas_Trabalhadas (
    id_funcionario INT,
    mes INT,
    ano INT,
    horas_normais INT,
    horas_extra INT,
    PRIMARY KEY (id_funcionario, mes, ano),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
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

CREATE TABLE Mesa (
    id_mesa INT IDENTITY(1,1) PRIMARY KEY,
    numero INT,
    lugares INT,
    disponivel BIT DEFAULT 1
);

CREATE TABLE Pedido (
    id_pedido INT IDENTITY(1,1) PRIMARY KEY,
    id_mesa INT,
    id_funcionario INT,
    id_cliente INT,
    data_hora DATETIME,
    estado VARCHAR(50),
    observacoes TEXT,
    FOREIGN KEY (id_mesa) REFERENCES Mesa(id_mesa),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE Pedido_Prato (
    id_pedido INT,
    id_prato INT,
    quantidade INT,
    PRIMARY KEY (id_pedido, id_prato),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_prato) REFERENCES Prato(id_prato)
);

CREATE TABLE Pedido_Bebida (
    id_pedido INT,
    id_bebida INT,
    quantidade INT,
    PRIMARY KEY (id_pedido, id_bebida),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_bebida) REFERENCES Bebida(id_bebida)
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

