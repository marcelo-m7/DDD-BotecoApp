
-- Inserir carreiras
INSERT INTO Carreira (descricao) VALUES ('Cozinheiro');
INSERT INTO Carreira (descricao) VALUES ('Atendente');
INSERT INTO Carreira (descricao) VALUES ('Gerente');

-- Inserir níveis de carreira
INSERT INTO Nivel_Carreira (descricao, vencimento_base)
VALUES 
    ('Júnior', 1000.00),
    ('Pleno', 1500.00),
    ('Sênior', 2000.00);

-- Inserir funcionários
INSERT INTO Funcionario (nome, data_admissao, valor_hora, id_carreira, id_nivel_carreira)
VALUES 
    ('Maria Cozinheira', '2023-01-10', 8.50, 1, 2),
    ('João Atendente', '2023-02-15', 7.00, 2, 1),
    ('Ana Gerente', '2022-11-01', 12.00, 3, 3);

-- Registrar horas trabalhadas
-- Maria (Cozinheira) - Março de 2025
EXEC sp_RegistrarHorasTrabalhadas @id_funcionario = 1, @mes = 3, @ano = 2025, @horas_normais = 160, @horas_extra = 5;

-- João (Atendente) - Março de 2025
EXEC sp_RegistrarHorasTrabalhadas @id_funcionario = 2, @mes = 3, @ano = 2025, @horas_normais = 150, @horas_extra = 10;

-- Ana (Gerente) - Março de 2025
EXEC sp_RegistrarHorasTrabalhadas @id_funcionario = 3, @mes = 3, @ano = 2025, @horas_normais = 170, @horas_extra = 3;
