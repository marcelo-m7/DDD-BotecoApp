
-- Procedure 1: Criar novo evento especial
DROP PROCEDURE IF EXISTS sp_CriarEventoEspecial;
GO
CREATE PROCEDURE sp_CriarEventoEspecial
    @nome VARCHAR(100),
    @descricao TEXT,
    @data_inicio DATE,
    @data_fim DATE
AS
BEGIN
    INSERT INTO Evento_Especial (nome, descricao, data_inicio, data_fim)
    VALUES (@nome, @descricao, @data_inicio, @data_fim);
END;
GO

-- Procedure 2: Criar menu especial para um evento
DROP PROCEDURE IF EXISTS sp_CriarMenuEspecial;
GO
CREATE PROCEDURE sp_CriarMenuEspecial
    @nome VARCHAR(100),
    @preco DECIMAL(10,2),
    @id_evento INT
AS
BEGIN
    INSERT INTO Menu_Especial (nome, preco, id_evento)
    VALUES (@nome, @preco, @id_evento);
END;
GO

-- Procedure 3: Adicionar prato ao menu especial
DROP PROCEDURE IF EXISTS sp_AdicionarPratoMenuEspecial;
GO
CREATE PROCEDURE sp_AdicionarPratoMenuEspecial
    @id_menu INT,
    @id_prato INT
AS
BEGIN
    INSERT INTO Menu_Especial_Prato (id_menu, id_prato)
    VALUES (@id_menu, @id_prato);
END;
GO
