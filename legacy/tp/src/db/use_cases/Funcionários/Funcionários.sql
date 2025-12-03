
-- Procedure 1: Inserir nova carreira
DROP PROCEDURE IF EXISTS sp_InserirCarreira;
GO
CREATE PROCEDURE sp_InserirCarreira
    @descricao VARCHAR(100)
AS
BEGIN
    INSERT INTO Carreira (descricao)
    VALUES (@descricao);
END;
GO

-- Procedure 2: Inserir novo nível de carreira
DROP PROCEDURE IF EXISTS sp_InserirNivelCarreira;
GO
CREATE PROCEDURE sp_InserirNivelCarreira
    @descricao VARCHAR(100),
    @vencimento_base DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Nivel_Carreira (descricao, vencimento_base)
    VALUES (@descricao, @vencimento_base);
END;
GO

-- Procedure 3: Inserir novo funcionário
DROP PROCEDURE IF EXISTS sp_InserirFuncionario;
GO
CREATE PROCEDURE sp_InserirFuncionario
    @nome VARCHAR(100),
    @data_admissao DATE,
    @valor_hora DECIMAL(10,2),
    @id_carreira INT,
    @id_nivel_carreira INT
AS
BEGIN
    INSERT INTO Funcionario (nome, data_admissao, valor_hora, id_carreira, id_nivel_carreira)
    VALUES (@nome, @data_admissao, @valor_hora, @id_carreira, @id_nivel_carreira);
END;
GO

-- Procedure 4: Registrar horas trabalhadas
DROP PROCEDURE IF EXISTS sp_RegistrarHorasTrabalhadas;
GO
CREATE PROCEDURE sp_RegistrarHorasTrabalhadas
    @id_funcionario INT,
    @mes INT,
    @ano INT,
    @horas_normais INT,
    @horas_extra INT
AS
BEGIN
    MERGE Horas_Trabalhadas AS alvo
    USING (SELECT @id_funcionario AS id_funcionario, @mes AS mes, @ano AS ano) AS origem
    ON alvo.id_funcionario = origem.id_funcionario AND alvo.mes = origem.mes AND alvo.ano = origem.ano
    WHEN MATCHED THEN
        UPDATE SET horas_normais = @horas_normais, horas_extra = @horas_extra
    WHEN NOT MATCHED THEN
        INSERT (id_funcionario, mes, ano, horas_normais, horas_extra)
        VALUES (@id_funcionario, @mes, @ano, @horas_normais, @horas_extra);
END;
GO
