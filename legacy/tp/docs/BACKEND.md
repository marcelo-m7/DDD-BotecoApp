# Relatório Técnico do Projeto **Boteco_PRO**

Este relatório resume a solução desenvolvida na unidade curricular de **Base de Dados II** para gestão de um pequeno restaurante ou bar. O backend é composto por um conjunto de scripts SQL (Microsoft SQL Server) e uma API REST em Python/FastAPI.

## 1. Objetivos

- Modelar e implementar o esquema de dados do restaurante
- Automatizar pedidos, faturação, estoque e vencimentos
- Disponibilizar endpoints para consumo por uma aplicação móvel

## 2. Organização do Projeto

```
backend/
├── README.md                # Descrição geral
├── docs/                    # Documentação e relatórios
└── src/
    ├── db/                  # Scripts SQL
    │   ├── init/            # Criação completa do BD
    │   └── use_cases/       # Procedures específicas por área
    └── api/                 # Implementação da API REST
```

### Scripts de criação (`src/db/init`)

1. **00_Login.sql** – criação do login/usuário
2. **01_Criação_DB.sql** – tabelas e relações do modelo
3. **02_Base_Views.sql** – views de apoio a relatórios financeiros
4. **03_Materialized_Views.sql** – tabela de materialização e índices
5. **04_Functions.sql** – funções escalares e tabulares
6. **05_SP_Finalizar_Mesa.sql** – procedure para gerar fatura
7. **06_SP_Realizar_Pedido.sql** – procedure para inserir pedidos completos
8. **07_Stored_Procedures.sql** – procedures de consulta a gastos
9. **08_Triggers.sql** – triggers de atualização de estoque e materialized view
10. **09_Function_Detalhes_Fatura.sql** – função de detalhe da fatura
11. **10_Seeds_1.sql / 11_Seeds_2.sql** – dados de exemplo

### Use cases (`src/db/use_cases`)
Procedures agrupadas por domínio (Gestor, Funcionários, Estoque, Pedidos). Servem como base para as rotas da API.

### API (`src/api`)
Implementada com FastAPI e `pyodbc` para ligação ao SQL Server. O ficheiro `app/main.py` instancia a aplicação e inclui os routers responsáveis por autenticação, gestão de pedidos, estoque, funcionários, faturas, pratos e menus.

## 3. Principais Funcionalidades

- **Pedidos**: registro de pedidos e itens, cálculo automático de estoque via triggers.
- **Faturas**: geração e consulta por meio da procedure `sp_FinalizarMesaEGerarFatura` e da função `fn_DetalhesFatura`.
- **Estoque**: visualização por views (`vw_EstoqueAtual`, `vw_ProdutosAbaixoMinimo`) e reposição automática ou manual.
- **Funcionários**: cadastro, controle de horas e cálculo de vencimentos com diferentes faixas de horas extra.
- **Relatórios**: views e funções que consolidam valores gastos e recebidos por período.

## 4. Execução da API

1. Criar um ambiente Python (virtualenv ou similar).
2. Instalar as dependências via `pip install -r requirements.txt` (arquivo em `src/api/requirements.txt`).
3. Configurar a string de conexão em `src/api/app/db.py` conforme o SQL Server configurado.
4. Executar com `uvicorn app.main:app --reload` e aceder a `http://localhost:8000/docs` para explorar os endpoints.

## 5. Conclusões

O sistema atende aos requisitos da disciplina ao integrar modelação de dados, programação T-SQL e disponibilização de uma API. A abordagem modular dos scripts facilita manutenções futuras e possibilita a expansão para novas funcionalidades.
