CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100),
    nif VARCHAR(15),
    morada VARCHAR(255),
    localidade VARCHAR(100),
    codigo_postal VARCHAR(20),
    tipo_cliente VARCHAR(50)
);