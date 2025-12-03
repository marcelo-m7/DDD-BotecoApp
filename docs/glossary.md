# 📘 **Boteco Pro — Glossário Oficial**

Este glossário define os conceitos fundamentais utilizados em todo o ecossistema do **Boteco Pro** — desde termos técnicos da arquitetura multi-tenant, até conceitos práticos do dia a dia operacional dos estabelecimentos.

A finalidade deste documento é garantir **clareza, consistência e alinhamento** entre equipes, microsserviços, desenvolvedores, design, suporte e agentes de IA.

---

# 📝 **Sobre a Convenção de Nomes (Padrão Boteco Pro)**

O Boteco Pro adota intencionalmente o padrão do português **onde o substantivo vem antes do adjetivo**.
Exemplos:

* *Pedido Aberto*
* *Mesa Atendida*
* *Boteco Ativo*
* *Funcionário Autorizado*
* *Identificador Público*

Essa regra existe para facilitar leitura, navegação e escaneabilidade visual para programadores e agentes automáticos.

> **Lê-se primeiro a entidade maior/abstrata, depois sua modificação.**
> Isso melhora organização, autocomplete, padrões de acesso e consistência across-code.

Este padrão é universal no ecossistema.

---

# 🏪 **Domínio de Negócio**

## **Boteco (ou Company)**

Unidade de negócio atendida pelo Boteco Pro (bar, restaurante, café, pastelaria, lanchonete, food truck, cantina, etc.).

**Regras essenciais do domínio:**

* Um boteco tem **somente um Owner (dono)** por vez.
* Um usuário pode ser **dono de vários botecos** simultaneamente.
* Um usuário pode ser **funcionário de vários botecos** que não necessariamente lhe pertencem.
* Cada boteco é representado tecnicamente como um **tenant isolado**.

No modelo de dados:

* Em Convex → um **schema lógico isolado**
* Em PostgreSQL → um **schema físico isolado** (ou banco completo)

---

## **Slug do Boteco (Identificador Único e Imutável)**

Identificador único permanente que representa o boteco em toda a plataforma.

Exemplo:

* `simpsons-na-lama`
* `bar-do-jonas`
* `cafe-da-dona-rita`

Regras:

* O slug é criado no onboarding.
* **Nunca pode ser alterado.**
* É utilizado como parte da identidade técnica do tenant.

---

## **Owner (Dono / Proprietário)**

Usuário com poder total sobre um boteco.

* cria o estabelecimento
* configura pela primeira vez
* gere assinatura e billing
* define permissões do staff
* controla os módulos ativos

**Cada boteco possui apenas 1 owner.**

O owner pode ter vários botecos sob sua gestão.

---

## **Staff (Funcionários / Equipe)**

Pessoas que operam o estabelecimento usando o App Flutter:

* garçom
* atendente
* cozinha
* copa
* gerente
* operador de caixa

Um usuário pode trabalhar em vários botecos diferentes.

---

## **Usuário (User)**

Pessoa com conta registrada no Boteco Pro.

Cada usuário possui:

* **um identificador único e imutável**
* este identificador é enviado por e-mail no momento da criação da conta
* o identificador **não pode ser alterado**

### Segurança e Verificação de Identidade

Quando o suporte do Boteco Pro / Monynha Softwares precisar confirmar autenticidade:

* o atendente **NUNCA** solicita o identificador completo
* o usuário pode solicitar que o atendente informe:

  * **os 5 primeiros dígitos** (`ref`)
  * ou **os 5 últimos dígitos** (`ref_mirror`)
* se coincidirem, a ligação é autêntica

Regra de ouro:

> **O identificador completo nunca deve ser partilhado. Apenas fragmentos (ref ou ref_mirror).**

---

## **Terminal de Serviço**

Dispositivo que utiliza o App Flutter no dia a dia operacional:

* tablet de garçom
* POS do balcão
* tela de cozinha (KDS)
* tela da copa

---

## **Mesa**

Recurso físico associado a um pedido. Pode representar:

* mesa tradicional
* comanda
* balcão
* zona específica

---

## **Pedido (Order)**

Conjunto de itens consumidos por clientes, gerido via App (POS/Garçom).

---

## **Produto (Product)**

Item vendável gerido no Portal (pratos, bebidas, combos, adicionais etc.).

---

# 🧱 **Domínio de Dados e Estrutura**

## **Tenant**

Representa um estabelecimento (boteco) dentro da plataforma.
Cada tenant possui:

* slug próprio
* estrutura isolada de dados
* configurações independentes

---

## **Schema (da Empresa)**

Espaço de dados isolado de um boteco.

* Em Convex → schema lógico
* Em PostgreSQL → schema físico com tabelas independentes

Exemplos:

* `boteco_joao_3H45HD`
* `cantina_ualg_X9K2PZ`

Cada schema contém as tabelas completas de:

* produtos
* pedidos
* mesas
* funcionários
* configurações
* preços
* fluxos internos

---

## **System Schema**

Schemas globais do sistema:

* mapeamento de tenants
* logs e auditoria
* assinaturas (quando não forem por tenant)
* integrações globais

---

## **Fonte de Verdade Operacional**

O **PostgreSQL** armazena o estado final consolidado da operação do boteco.

---

# 🧩 **Domínio de Aplicações e Microsserviços**

## **Portal**

Aplicação web administrativa usada para:

* gerir o boteco
* gerir produtos
* gerir estoque
* gerir funcionários
* configurar módulos
* acompanhar dados e dashboards
* onboarding de empresa
* **gestão da assinatura**
* **pagamento via Polar.sh**

O Portal usa **Convex** como backend exclusivo.

---

## **App de Serviço (Flutter App)**

Aplicativo operacional que fornece:

* modo POS (balcão)
* modo Garçom (tablet)
* modo Cozinha (KDS)
* modo Copa

Características:

* **Offline-first real**
* SQLite local + sync
* conexão via Supabase/Postgres
* otimizado para operação rápida

---

## **Convex**

Backend administrativo do Portal.

Responsável por:

* regras de negócio administrativas
* mutations e queries
* validações
* workflows
* gestão inicial de tenants
* sincronização com Postgres

Convex nunca interfere no domínio do App.

---

## **Supabase**

Camada de integração usada principalmente pelo App Flutter.

Motivações:

* SDK excelente para Flutter
* facilita acesso seguro ao Postgres
* integra bem com auth, jobs e outros serviços
* ajuda a manter sincronização limpa
* abstrai complexidades sem impor vendor lock-in

Supabase **não define regras de negócio** — ele só facilita comunicação com o Postgres.

---

## **PostgreSQL**

Banco de dados principal do Boteco Pro.
Armazena os dados operacionais e administrativos por tenant.

Robusto, open-source e auto-hospedável.

---

## **N8N**

Plataforma externa usada como microsserviço anexado para automações:

* IA
* jobs assíncronos
* relatórios
* integrações externas
* rotinas de limpeza

---

## **Clerk Auth**

Serviço de autenticação universal usado pelo Portal e pelo App.

---

## **Polar.sh**

Solução de pagamento e billing usada para gerir assinaturas.

---

# ⚙️ **Conceitos Técnicos**

## **Offline-First**

O App deve operar mesmo sem internet, sincronizando quando possível.

---

## **Sincronização (Sync)**

Processo que mantém dados coerentes entre Portal → Convex → Postgres → App.

---

## **Microsserviço**

Componente isolado que resolve um único contexto sem interferir em outros.

---

## **Self-Hosted First**

Princípio onde todo o ecossistema pode ser executado em infraestrutura própria (ex.: Coolify + Hetzner), garantindo:

* independência
* soberania de dados
* custos reduzidos
* possibilidade de operação 100% offline
