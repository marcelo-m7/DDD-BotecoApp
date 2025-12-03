# API REST - Boteco_PRO

Esta estrutura define os endpoints RESTful que representam as ações possíveis com base nas procedures, views e funções do banco de dados Boteco_PRO.

---

## 📋 Cadastro / Configuração Inicial

### POST /categorias
- Cria uma nova categoria
- Params: { nome }

### POST /fornecedores
- Cria um novo fornecedor
- Params: { nome, email, telefone }

### POST /produtos
- Cria um novo produto
- Params: { nome, descricao, preco_custo, stock_atual, stock_minimo, quantidade_encomenda, id_fornecedor }

### POST /pratos
- Cria um novo prato
- Params: { nome, preco_venda, tempo_preparo, id_categoria, observacoes }

### POST /pratos/{id}/ingredientes
- Associa ingredientes a um prato
- Params: { id_produto, quantidade_utilizada }

### POST /mesas
- Cadastra uma nova mesa
- Params: { numero, lugares }

---

## 📦 Estoque

### GET /estoque
- Retorna todos os produtos com seus níveis de estoque

### GET /estoque/baixo
- Retorna produtos abaixo do estoque mínimo

### POST /estoque/repor
- Reposição manual de produto
- Params: { id_produto, quantidade }

---

## 👥 Funcionários

### POST /carreiras
- Cria nova carreira

### POST /niveis-carreira
- Cria novo nível de carreira

### POST /funcionarios
- Cadastra novo funcionário

### POST /funcionarios/{id}/horas
- Registra ou atualiza horas trabalhadas
- Params: { mes, ano, horas_normais, horas_extra }

### GET /funcionarios
- Lista todos os funcionários com cargo e nível

---

## 🧾 Pedidos e Faturamento

### POST /pedidos
- Realiza um novo pedido
- Params: { id_mesa, id_funcionario, id_cliente, observacoes }

### POST /pedidos/{id}/pratos
- Adiciona prato ao pedido
- Params: { id_prato, quantidade }

### POST /pedidos/{id}/finalizar
- Finaliza o pedido, gera fatura
- Params: { tipo_iva_comida, tipo_iva_bebida }

---

## 🎉 Eventos e Menus

### POST /eventos
- Cria um novo evento

### POST /menus
- Cria um novo menu especial para um evento

### POST /menus/{id}/pratos
- Adiciona prato ao menu

### GET /menus/ativos
- Lista menus especiais ativos no dia atual com seus pratos

---

## 📈 Financeiro

### GET /financeiro/resumo
- View de resumo financeiro por período

### GET /financeiro/salarios?mes=3&ano=2025
- Chama fn_ValorGastoVencimentos()

### GET /financeiro/estoque?mes=3&ano=2025
- Chama fn_ValoresGastosStocks()

---

## Extras

### GET /relatorios/uso-estoque
- View: vw_ValorGastoStocksPorPeriodo

### GET /relatorios/vendas
- View: vw_ValorRecebidoPorPeriodo