# 🏗️ **Boteco Pro — Architecture Summary (Microsserviços, Contextos Isolados)**

O ecossistema **Boteco Pro** foi projetado desde o início para fugir do maior erro dos sistemas de gestão tradicionais: tudo misturado dentro de um único backend.
Aqui, cada parte da plataforma é tratada como um **microsserviço independente**, com um propósito claro e responsabilidades bem definidas.

> **Cada microsserviço resolve exatamente um contexto — nada de acúmulo de tarefas, sobreposição de regras ou dependências desnecessárias.**

O resultado é uma arquitetura limpa, previsível, expansível e fácil de manter a longo prazo.

---

# 🧩 **1. Frontends — cada um no seu domínio**

## **Microsserviço 1 — Portal Web (Administração, Gestão Geral e Assinaturas)**

O Portal é o ambiente de trabalho do administrador e funciona como o centro estratégico da operação.
Aqui é onde a empresa:

* gere o catálogo de produtos
* controla receitas, custos, margens e estoque
* acompanha dashboards operacionais
* define permissões e acessos
* cria e gerencia funcionários
* controla módulos e extensões ativas
* configura a operação
* realiza onboarding
* **administra a assinatura da plataforma**
* **realiza pagamentos via Polar.sh**

O Portal **não acessa o Postgres diretamente**.
Ele interage exclusivamente com o seu backend dedicado:

👉 **Convex**
(onde vivem as regras de negócio administrativas, validações, mutations, controladores e workflows)

Convex processa tudo, garante a consistência e sincroniza o estado final para o Postgres.

---

## **Microsserviço 2 — App Flutter Operacional (POS / Garçom / Cozinha / Copa)**

O aplicativo Flutter é totalmente dedicado à operação ao vivo do estabelecimento:

* POS do balcão
* Tablet do garçom
* Tela de cozinha (KDS)
* Tela de bebidas/copa

Características essenciais:

* **Offline-first real** com SQLite local
* **Sincronização segura via Supabase/Postgres**
* **Performance instantânea na operação**
* **Independência de internet durante o serviço**

O App não conversa com o Convex.
Ele recebe dados já validados, normalizados e consolidados direto do Postgres.

---

# 🗄️ **2. Camada de Dados — um pipeline estruturado, não um monólito**

A arquitetura de dados do Boteco Pro funciona como um fluxo claro de estados:

```
PORTAL (Administração)
        ⇅ via Convex
CONVEX (Regras, Mutations, Workflows, Validações)
        ⇅ sincronização coerente
POSTGRES (Fonte de Verdade Operacional)
        ⇅
APP FLUTTER (POS / Garçom / KDS / Copa)
```

Cada serviço manipula apenas o que lhe pertence.
Nada de domínios misturados.

---

# 🧠 **3. Por que cada camada usa o que usa?**

## 🟦 **Por que o Portal usa Convex?**

Porque qualquer abordagem full-stack tradicional (Next.js, Rails, Laravel, Nest, etc.) cria inevitavelmente um destes problemas:

* regras de negócio espalhadas entre front e backend
* APIs inchadas, cheias de endpoints redundantes
* refactors dolorosos
* interfaces tentando adivinhar lógica do backend
* inconsistência entre diferentes clientes (web, mobile, etc.)

Com Convex, tudo fica centralizado em mutations e queries tipadas, com:

* **regras de negócio aplicadas no lugar certo**
* validação de dados automática
* controle de fluxo e workflows nativos
* sincronização simples com Postgres
* zero necessidade de criar APIs REST/GraphQL

Convex é o “cérebro administrativo” do Boteco Pro.

---

## 🟩 **Por que o App usa Supabase/Postgres?**

Somente por um motivo simples e prático:

> **Supabase dá a melhor integração possível com apps mobile modernos.**

Não é por causa de SQL complexo.
Não é por querer depender do ecossistema Supabase.
Não é por preferir PostgREST ou Edge Functions.

É porque:

* fornece SDKs excelentes para Flutter e outras tecnologias
* permite sincronização incremental eficiente
* facilita integrações futuras (e-mail, jobs, webhooks)
* combina perfeitamente com SQLite local
* é fácil de auto-hospedar
* suporta multi-tenancy via schemas
* tem ferramentas sólidas para segurança e permissões

E por baixo de tudo:

**é PostgreSQL puro — rápido, estável, robusto, comprovado.**

Nenhuma magia. Nenhum vendor lock-in.

Apenas **Postgres do jeito certo**.

---

# 🧩 **4. Microsserviços — cada um no seu quadrado**

O Boteco Pro segue o princípio:

> **“Contextos isolados + comunicação indireta mediada por estados consistentes”.**

Consequências diretas:

* O Portal não tenta operar o restaurante.
* O App não tenta administrar a empresa.
* Convex nunca tenta substituir Supabase.
* Supabase nunca tenta assumir responsabilidade de lógica de negócio.

E ainda:

## **N8N como extensões plugáveis (“microsserviços anexados”)**

Usado para:

* automações com IA
* extração de dados
* rotinas assíncronas
* integrações externas
* jobs executados por evento

N8N nunca interfere no core.
São serviços complementares.

---

# 🔐 **5. Infraestrutura (Self-Hosted First, Open-Source First)**

A maior parte dos serviços do Boteco Pro são **auto-hospedados** por decisão estratégica:

* **Coolify + Hetzner** para deploy e gestão
* **Docker Compose** para desenvolvimento
* **Convex** e **Supabase** com foco em independência
* **Clerk Auth** para autenticação universal
* Sem Vercel
* Sem Cloudflare
* Sem plataformas fechadas que travam portabilidade

Essa escolha dá:

* **custos reduzidos**,
* **independência de provedores**,
* **controle total sobre dados**,
* e a possibilidade de o cliente final também rodar sua instância.

Sim: o Boteco Pro pode rodar **100% offline** ou **apenas numa rede interna**, caso o cliente tenha infraestrutura local.

Nenhum componente depende de um provedor específico para funcionar.

---

# 🧭 **6. Filosofia da Arquitetura**

* Microsserviços de contexto único
* Backend desacoplado de frontend
* Portal administrativo separado da operação
* Sincronização inteligente (e não dezenas de APIs)
* Zero duplicação de regras
* Zero mistura de responsabilidades
* Estado consistente entre todos os serviços
* Independência completa de provedores
* Infraestrutura auto-hospedada por padrão
* “O cliente deve sempre poder controlar seus dados”

---

# ⭐ **Resumo técnico em 1 frase**

> **O Boteco Pro é um ecossistema auto-hospedado de microsserviços isolados — Portal via Convex, App via Supabase/Postgres — que se comunicam por estados consistentes, garantindo escalabilidade, independência e uma experiência operacional impecável.**
