# 🗺️ **Boteco Pro — Roadmap Oficial**

Este roadmap descreve a evolução planejada do ecossistema **Boteco Pro**, organizado em fases claras. Cada fase representa um conjunto de entregas coesas que fortalecem o produto, mantendo sempre o princípio central:

> **simplicidade operacional na frente + arquitetura sólida e isolada por trás.**

O roadmap cobre Portal, App, Backend, microsserviços, dados, integrações, infraestrutura e visão futura de ERP.

---

# 🔵 **Fase 1 — Fundação Operacional (MVP Real)**

> *Objetivo: permitir que qualquer boteco opere de verdade usando o sistema.*

### ✔️ 1.1 — Portal Básico (Admin)

* onboarding do boteco
* criação do slug
* configuração inicial
* cadastro de produtos e categorias
* gestão básica de preços e estoque
* gestão de funcionários
* permissões fundamentais
* página “Minha Conta” (dados do owner)

### ✔️ 1.2 — App Flutter (POS / Garçom / Cozinha)

* modo POS
* modo Garçom
* modo Cozinha (KDS)
* SQLite com sync básico
* abertura e finalização de pedidos
* operações essenciais funcionando offline

### ✔️ 1.3 — Convex + Postgres

* mutations de criação/edição estrutural
* regras de negócio fundamentais
* sincronização consistente Convex → Postgres
* schemas isolados por tenant
* mapeamento dos tenants no schema global

### ✔️ 1.4 — Autenticação + Identidade

* Clerk integrado ao sistema
* criação de usuário
* envio do identificador único (ref + ref_mirror)
* mecanismo de segurança para suporte

---

# 🟣 **Fase 2 — Consolidação e Confiança**

> *Objetivo: transformar o MVP em um produto confiável, robusto e seguro.*

### 🔄 2.1 — Sincronização Avançada

* sync bidirecional refinado
* melhoria de conflitos de alteração
* sistema de versionamento de dados no Postgres
* logs operacionais por terminal

### 📊 2.2 — Dashboards Operacionais

* vendas do dia
* produtos mais vendidos
* tickets médios
* desempenho do staff

### 🧭 2.3 — Gestão Completa de Staff

* convites por e-mail
* permissões detalhadas
* auditoria de ações do staff
* vinculação de turnos

### 🧩 2.4 — Módulos Internos

* módulo de estoque avançado
* módulo de mesas avançado
* módulo de copa vs cozinha
* módulo de produtos com adicionais, modificadores e combos

### 📚 2.5 — Documentação Técnica Interna

* SSOT completo
* DB schema por tenant
* docs de convívio entre microsserviços
* guia de extensões N8N
* manual de suporte interno

---

# 🟡 **Fase 3 — Plataforma Comercial (SaaS Real)**

> *Objetivo: transformar o Boteco Pro em um produto vendável, automatizado e seguro para escala.*

### 💳 3.1 — Assinatura via Polar.sh

* criação e gestão de planos
* cobrança automática
* suspensão/reativação de contas
* histórico de faturamento
* páginas de assinatura integradas no Portal
* webhooks de faturamento → Convex

### 🌐 3.2 — Painel do Cliente

* histórico da assinatura
* gestão de faturas
* gestão de módulos premium
* exportação de dados da empresa
* configurações avançadas

### 🧾 3.3 — Logs, Auditoria e Segurança

* auditoria por ação
* logs de sincronização
* histórico de acessos
* notificações internas do sistema

### 🧰 3.4 — Ferramentas de Suporte

* central de suporte
* verificação via ref/ref_mirror
* acesso limitado de suporte ao tenant (read-only)

---

# 🟢 **Fase 4 — Automação e Extensões Inteligentes**

> *Objetivo: aumentar a inteligência operacional do produto e reduzir trabalho manual.*

### 🤖 4.1 — Extensões N8N

* geração automática de relatórios
* alertas baseados em vendas/estoque
* integração com e-mail / WhatsApp
* automações com IA (ex.: tradução automática de cardápio)

### 🧠 4.2 — IA Operacional

* sugestões de compra
* previsão de demanda
* análise automática de performance
* categorização inteligente de produtos

### 🕸️ 4.3 — Marketplace de Extensões

* instalação one-click
* módulos premium
* integrações externas (pagamentos, delivery, etc.)

---

# 🟩 **Fase 5 — ERP Boteco Pro**

> *Objetivo: consolidar o Boteco Pro como a plataforma digital unificada de gestão gastronômica.*

### 🧾 5.1 — Módulo Financeiro

* contas a pagar
* contas a receber
* fluxo de caixa
* conciliação automática

### 📦 5.2 — Módulo de Compras

* fornecedores
* cotações
* pedidos de compra
* inventário avançado

### 🧑‍🍳 5.3 — Módulo de Produção

* fichas técnicas avançadas
* controle de custo por receita
* baixa automática de ingredientes
* cálculo dinâmico de margens

### 👫 5.4 — Módulo de RH

* horas trabalhadas
* turnos
* escalas
* folha externa integrada

---

# 🟠 **Fase 6 — Multi-Boteco Corporativo**

> *Objetivo: atender redes, franquias e múltiplos estabelecimentos com gestão centralizada.*

### 🏬 6.1 — Dashboard de Redes

* análise cruzada entre botecos
* métricas agregadas
* ranking de unidades

### 🔗 6.2 — Operações Corporativas

* replicação de catálogos
* configuração global por rede
* estrutura multi-owner avançada

### 📡 6.3 — Sincronização Inter-Tenant

* compartilhamento opcional de dados
* replicação de cardápios
* backups sincronizados

---

# 🔍 **Notas Finais**

* Este roadmap é **vivo** e evolui junto com a plataforma.
* As fases não precisam ser 100% sequenciais; alguns itens podem ser paralelos.
* A prioridade sempre será **operacionalidade + robustez + simplicidade de uso**.
