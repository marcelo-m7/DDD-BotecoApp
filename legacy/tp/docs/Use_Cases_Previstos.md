### 🍽️ **PERFIL: Gestor do Restaurante**

O gestor é responsável por **configurar, monitorar e manter o funcionamento** do restaurante no sistema. As tarefas dele podem ser divididas em **5 grandes blocos**:

---

## ✅ 1. **Configuração Inicial do Restaurante**
Funções para preparar o sistema para começar a operar.

| Tarefa                                | Entidade(s) envolvida(s)        | Tipo de objeto sugerido |
|--------------------------------------|----------------------------------|--------------------------|
| Inserir categorias de pratos         | `Categoria`                      | Procedure                |
| Inserir fornecedores                 | `Fornecedor`                     | Procedure                |
| Inserir produtos no estoque          | `Produto`, `Fornecedor`          | Procedure                |
| Inserir pratos no cardápio           | `Prato`, `Categoria`             | Procedure                |
| Relacionar ingredientes ao prato     | `Prato_Produto`, `Produto`       | Procedure                |
| Inserir mesas no sistema             | `Mesa`                           | Procedure                |

---

## 📦 2. **Gestão de Estoque**
O gestor precisa acompanhar e controlar o uso e reposição dos produtos.

| Tarefa                                 | Entidade(s) envolvida(s)   | Tipo de objeto sugerido |
|---------------------------------------|-----------------------------|--------------------------|
| Visualizar nível de estoque atual     | `Produto`                   | View ou Function         |
| Visualizar produtos abaixo do mínimo  | `Produto`                   | View ou Function         |
| Registrar reposição manual de estoque | `Produto`                   | Procedure                |
| Consultar uso de estoque por período  | `vw_ValorGastoStocksPorPeriodo` | View                 |

---

## 👩‍🍳 3. **Gestão de Funcionários**
Organização da equipe de trabalho.

| Tarefa                                 | Entidade(s) envolvida(s)       | Tipo de objeto sugerido |
|---------------------------------------|----------------------------------|--------------------------|
| Inserir carreiras e níveis            | `Carreira`, `Nivel_Carreira`    | Procedure                |
| Cadastrar funcionários                | `Funcionario`                   | Procedure                |
| Registrar horas trabalhadas           | `Horas_Trabalhadas`             | Procedure                |
| Ver vencimentos por período           | `vw_ValorGastoVencimentosPorPeriodo` | View              |

---

## 💵 4. **Gestão Financeira**
Controle dos gastos e receitas do restaurante.

| Tarefa                                | Entidade(s) envolvida(s)     | Tipo de objeto sugerido |
|--------------------------------------|-------------------------------|--------------------------|
| Ver resumo financeiro por período    | `vw_ResumoFinanceiroPorPeriodo` | View                  |
| Gerar relatório de faturamento       | `Fatura`, `Pedido`             | View / Procedure         |
| Calcular valor gasto com salários    | Function `fn_ValorGastoVencimentos` | Function             |
| Calcular valor gasto com estoque     | Function `fn_ValoresGastosStocks` | Function               |

---

## 🛠️ 5. **Administração de Eventos Especiais e Menus**
Controle de menus temáticos ou sazonais.

| Tarefa                              | Entidade(s) envolvida(s)      | Tipo de objeto sugerido |
|------------------------------------|-------------------------------|--------------------------|
| Criar evento especial              | `Evento_Especial`             | Procedure                |
| Criar menu especial para evento    | `Menu_Especial`, `Menu_Especial_Prato` | Procedure         |
| Relacionar pratos ao menu especial | `Menu_Especial_Prato`         | Procedure                |
