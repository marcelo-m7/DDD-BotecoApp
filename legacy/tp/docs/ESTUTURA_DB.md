# Relatorio de Estrutura do Banco de Dados Boteco_PRO

Este documento resume os objetos criados para a base de dados **Boteco_PRO**, implementada em Microsoft SQL Server como parte do trabalho prático da disciplina **Base de Dados II**.

## 1. Esquema Geral
Os scripts localizados em `src/db/init` criam todas as tabelas, views, funções, procedures e triggers utilizadas na solução. O diagrama entidade-relacionamento encontra-se em `docs/Modelo Entidade Relacionamento.png`.

## 2. Tabelas Principais
As seguintes tabelas compõem o núcleo do sistema (arquivo `01_Criação_DB.sql`):

- `Categoria` – categorias de pratos e bebidas
- `Fornecedor` – dados de fornecedores
- `Produto` – produtos de estoque
- `Prato` – pratos servidos
- `Bebida` – bebidas servidas
- `Prato_Produto` – ingredientes utilizados em pratos
- `Bebida_Produto` – ingredientes utilizados em bebidas
- `Carreira` – tipos de carreira dos funcionários
- `Nivel_Carreira` – níveis e vencimento base
- `Funcionario` – dados principais dos funcionários
- `Funcionario_Login` – credenciais de acesso
- `Horas_Trabalhadas` – registo mensal de horas
- `Cliente` – clientes do restaurante
- `Mesa` – mesas disponíveis
- `Pedido` – pedidos abertos para cada mesa
- `Pedido_Prato` – pratos incluídos num pedido
- `Pedido_Bebida` – bebidas incluídas num pedido
- `Fatura` – faturas geradas ao finalizar pedidos
- `Evento_Especial` – eventos e promoções
- `Menu_Especial` – menus dedicados a eventos
- `Menu_Especial_Prato` – relação pratos ↔ menus especiais
- `mv_StocksUtilizadosPorPeriodo` – tabela de materialização criada em `03_Materialized_Views.sql`

## 3. Views (`02_Base_Views.sql`)
- `vw_ValorGastoStocksPorPeriodo` – custo de ingredientes por data
- `vw_ValorGastoVencimentosPorPeriodo` – vencimentos pagos por mês/ano
- `vw_ValorRecebidoPorPeriodo` – valor faturado em pedidos por data
- `vw_ResumoFinanceiroPorPeriodo` – consolida gastos e receitas por período

## 4. Funções
Arquivo `04_Functions.sql` define:
- `fn_ValorGastoVencimentos(@mes, @ano)` – retorna o valor gasto em vencimentos
- `fn_ValoresGastosStocks(@mes, @ano)` – retorna o valor gasto em produtos

Arquivo `09_Function_Detalhes_Fatura.sql` define:
- `fn_DetalhesFatura(@id_fatura)` – devolve o detalhe completo de uma fatura

## 5. Stored Procedures
- `sp_FinalizarMesaEGerarFatura(@id_mesa)` – fecha um pedido, calcula total e gera a fatura (`05_SP_Finalizar_Mesa.sql`)
- `sp_InserirPedidoCompleto` – insere um pedido com lista de pratos (`06_SP_Realizar_Pedido.sql`)
- `sp_MostrarValorGastoVencimentos` – consulta o valor pago em vencimentos (`07_Stored_Procedures.sql`)
- `sp_MostrarValoresGastosStocks` – consulta valores gastos com produtos (`07_Stored_Procedures.sql`)
- Procedimentos adicionais de cadastro e gestão localizam-se em `src/db/use_cases`

## 6. Triggers (`08_Triggers.sql`)
- `trg_AtualizarStock_Produtos` – decrementa estoque ao inserir pratos em pedidos
- `trg_ReporEstoque` – repõe estoque automaticamente quando abaixo do mínimo
- `trg_AtualizarMV_Stocks` – alimenta a tabela `mv_StocksUtilizadosPorPeriodo`

## 7. Dados de Teste
Os scripts `10_Seeds_1.sql` e `11_Seeds_2.sql` inserem categorias, produtos, funcionários, clientes e exemplos completos de pedidos e faturas.

## 8. Execução
Para criar todo o banco execute os scripts na ordem apresentada em `docs/INSTRUCOES_BANCO.md`. Após a carga inicial, utilize as procedures e funções para validar os cálculos de estoque, vencimentos e faturamento.

