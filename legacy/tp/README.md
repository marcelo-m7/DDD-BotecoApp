# Projeto de Base de Dados II

**Aluno:** Marcelo Santos  
**Email:** a79433@ualg.pt  
**Disciplina:** Base de Dados II  
**Instituição:** Universidade do Algarve  
**Data:** Abril de 2025  

**[Repositório do Projeto GitHub](https://github.com/marcelo-m7/Boteco_PRO)**

---

## 1. Introdução

Este trabalho tem como objetivo o desenvolvimento de um sistema de base de dados para pequenos comércios (bares/restaurantes). O sistema foi modelado e implementado utilizando o Microsoft SQL Server, com foco na gestão de pedidos, faturamento, estoque de produtos, vencimentos de funcionários e eventos especiais.

Tecnologias utilizadas:
- Microsoft SQL Server
- SQL (T-SQL)
- SQL Server Management Studio (SSMS)

---

## 2. Modelo Entidade-Relacionamento

O modelo entidade-relacionamento foi gerado através do Microsoft SQL Server e contempla as seguintes entidades principais:
- `Categoria`
- `Fornecedor`
- `Produto`
- `Prato`
- `Bebida`
- `Prato_Produto`
- `Bebida_Produto`
- `Carreira`
- `Nivel_Carreira`
- `Funcionario`
- `Funcionario_Login`
- `Horas_Trabalhadas`
- `Cliente`
- `Mesa`
- `Pedido`
- `Pedido_Prato`
- `Pedido_Bebida`
- `Fatura`
- `Evento_Especial`
- `Menu_Especial`
- `Menu_Especial_Prato`

Cada entidade foi devidamente normalizada até a 3ª Forma Normal.

[Imagem do Modelo ER - Anexada separadamente no projeto]

---

## 3. Esquema Relacional

O esquema relacional foi criado com a utilização de `IDENTITY` para garantir o autoincremento dos identificadores. Todas as chaves primárias e estrangeiras foram definidas, garantindo a integridade referencial.

As tabelas principais incluem:
- `Produto(id_produto, nome, preco_custo, stock_atual, ...)`
- `Pedido(id_pedido, id_cliente, id_mesa, ...)`
- `Funcionario(id_funcionario, nome, valor_hora, ...)`
- `Fatura(id_fatura, valor_total, valor_iva, ...)`

---

## 4. Queries Criadas

### Views
- `vw_ValorGastoStocksPorPeriodo`
- `vw_ValorGastoVencimentosPorPeriodo`
- `vw_ValorRecebidoPorPeriodo`
- `vw_ResumoFinanceiroPorPeriodo`

### Materialized View (simulada via tabela e trigger)
- `mv_StocksUtilizadosPorPeriodo` +
- Trigger `trg_AtualizarMV_Stocks`

### Scalar Function
- `fn_ValorGastoVencimentos(@mes, @ano)`

### Table-Valued Function
- `fn_ValoresGastosStocks(@mes, @ano)`
- `fn_DetalhesFatura(@id_fatura)`

### Stored Procedures
- `sp_InserirPedidoCompleto(...)`
- `sp_MostrarValorGastoVencimentos(...)`
- `sp_MostrarValoresGastosStocks(...)`
- `sp_FinalizarMesaEGerarFatura(@id_mesa)`

### Triggers
- `trg_AtualizarStock_Produtos`
- `trg_ReporEstoque`

---

## 5. Conclusão

O sistema desenvolvido cobre todas as funcionalidades propostas no enunciado da disciplina. As funcionalidades principais incluem:
- Criação automática de faturas
- Controle de estoque com reposição automática
- Cálculo de vencimentos com diferentes faixas de horas extra
- Geração de relatórios financeiros e de uso de produtos

---

## 6. Documentação Complementar
- [Relatório TP1](docs/Relatório_TP1.md)
- [Instruções para configuração do banco de dados](docs/INSTRUCOES_DB.md)
- [Relatório técnico detalhado](docs/BACKEND.md)
- [Relatório da estrutura do banco](docs/ESTUTURA_DB.md)

---
## 7. Referências
- Enunciado oficial da UC de Base de Dados II
- Documentação oficial Microsoft SQL Server
- W3Schools SQL Reference
- Stack Overflow

