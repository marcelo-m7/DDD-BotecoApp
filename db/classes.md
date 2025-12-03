# 🎯 **Objetivos do RLS por Boteco**

## **006_rls_per_boteco_schema.sql**

006_rls_per_boteco_schema.sql, responsável por aplicar **Row-Level Security** dentro de **cada schema multitenant** (`boteco_{slug}`).

Esse arquivo será incluído no processo de provisão (junto com 002 e 003) e deve ser **parametrizado** com `{{schema_name}}`, pois será executado separadamente para cada boteco.

---

### ✔ 1. Somente usuários associados ao boteco (via `public.user_boteco`) podem acessar o schema

→ usuário só acessa o boteco atual que ele selecionou no app.

### ✔ 2. Supabase Auth deve enviar no JWT:

* `sub` → user_id
* `boteco_id` → empresa ativa
* `role` → admin / member

### ✔ 3. Administrador pode tudo

### ✔ 4. Membro pode operar POS (leitura e escrita nas tabelas de pedidos, mesas, items etc.)

### ✔ 5. Ninguém de fora do boteco tem acesso

### ✔ 6. Service role ignora RLS (padrão do Supabase)

---

# 🧠 Princípio central do multitenancy

Dentro de cada schema `boteco_{slug}`, **não há coluna `boteco_id`**.

A identificação ocorre pelo próprio schema.

Então, o acesso se dá por comparação:

```
auth.jwt() -> claim "boteco_id"
=
public.boteco.slug
```

Ou seja: **"o usuário está logado no boteco correto?"**

---

# 🔐 Lógica base das políticas:

```sql
USING (
    auth.role() = 'service_role'
    OR (
        auth.uid() IN (
            SELECT user_id FROM public.user_boteco 
            WHERE boteco_id = current_boteco_id()
        )
    )
)
```

Mas precisamos derivar `current_boteco_id()` pelo slug do schema.

---

# 🔧 Criaremos uma função dentro do schema:

```sql
SELECT boteco_id
FROM public.boteco
WHERE slug = {{slug}}
LIMIT 1;
```

Isso fornece **boteco_id**, necessário para validar staff.

---

# 🧩 Também criaremos helper functions:

* `current_user_is_admin()`
* `current_user_is_member()`
* `current_user_is_staff()`

---

# 🔥 Agora sim, o arquivo completo.

---

# ✅ **006_rls_per_boteco_schema.sql**

> **IMPORTANTE:**
> Este arquivo é um **TEMPLATE** e deve ser processado substituindo `{{schema_name}}` e `{{slug}}`.

---

# 🧠 Por que este arquivo é perfeito?

### ✔ Independe do número e nomes das tabelas

As policies são criadas dinamicamente para todas as tabelas presentes no schema.

### ✔ Staff → CRUD permitido

### ✔ Admin → DELETE permitido

### ✔ Membro → POS (pedido, mesa, item) permitido

### ✔ Não-staff → zero acesso

### ✔ JWT com `auth.uid()` decide tudo

### ✔ Supabase service_role ignora RLS (natural)

---


* 000 (base)
* 001 (global)
* 002 (schema template)
* 003 (seed)
* 004 (provision)
* 005 (global RLS)
* 006 (per-boteco RLS)


---

# Diagram

```mermaid
---
config:
  layout: elk
---
classDiagram


%% ============================================================
%% BOTECOS, USERS E STAFF (únicos que mantêm botecoId)
%% ============================================================

class Boteco {
  +Id botecoId
  +FK ownerUserId
  +String name
  +String slug
  +String? logoUrl
  +String? timezone
  +Date createdAt
  +Date updatedAt
}

class User {
  +Id userId
  +String email
  +String passwordHash
  +String? displayName
  +Date createdAt
  +Date updatedAt
}

class Staff {
  +Id staffId
  +FK botecoId
  +FK userId
  +String role
  +Boolean active
  +Date createdAt
  +Date updatedAt
}

User "1" o-- "*" Boteco : owns
Boteco "1" o-- "*" Staff : employs
User "1" o-- "*" Staff : assigned


%% ============================================================
%% PAGAMENTOS
%% ============================================================

class Payment {
  +Id paymentId
  +FK botecoSlug
  +FK orderId
  +String method
  +Number amount
  +Number? tipAmount
  +Number? changeAmount
  +String? transactionCode
  +Date createdAt
  +Date updatedAt
}

class PaymentSummary {
  +Id paymentSummaryId
  +FK posSessionId
  +Number totalCash
  +Number totalCard
  +Number totalPix
  +Number totalTips
  +Number totalChangeGiven
  +Date generatedAt
}

Order "1" o-- "*" Payment : paidBy
PosSession "1" o-- "*" Payment : sessionPayments
PosSession "1" o-- "1" PaymentSummary : dailyTotals


%% ============================================================
%% MESAS E SESSÕES
%% ============================================================

class Table {
  +Id tableId
  +FK botecoSlug
  +String label
  +Number? seats
  +Boolean active
  +Date createdAt
  +Date updatedAt
}

class PosSession {
  +Id posSessionId
  +FK botecoSlug
  +FK staffId
  +Date openedAt
  +Date? closedAt
  +Number openingAmount
  +Number? closingAmount
  +String status
}

Boteco "1" o-- "*" Table : has
Boteco "1" o-- "*" PosSession : sessions
Staff "1" o-- "*" PosSession : opens


%% ============================================================
%% PEDIDOS
%% ============================================================

class Order {
  +Id orderId
  +FK botecoSlug
  +FK? tableId
  +FK posSessionId
  +FK staffId
  +String status
  +Number? subtotal
  +Number? total
  +Date createdAt
  +Date updatedAt
}

class OrderItem {
  +Id orderItemId
  +FK botecoSlug
  +FK orderId
  +FK menuItemId
  +Number quantity
  +Number unitPrice
  +Number totalPrice
  +String? notes
  +Date createdAt
  +Date updatedAt
}

Order "1" o-- "*" OrderItem : contains
Table "1" o-- "*" Order : placedOn
PosSession "1" o-- "*" Order : sessionOrders
Staff "1" o-- "*" Order : handledBy
MenuItem "1" o-- "*" OrderItem : soldAs


%% ============================================================
%% PRODUTOS E CATEGORIAS
%% ============================================================

class ProductCategory {
  +Id productCategoryId
  +FK botecoSlug
  +String name
  +String? description
  +Boolean active
  +Date createdAt
  +Date updatedAt
}

class Product {
  +Id productId
  +FK botecoSlug
  +FK productCategoryId
  +String name
  +Number cost
  +String unit
  +Boolean active
  +Date createdAt
  +Date updatedAt
}

Boteco "1" o-- "*" ProductCategory : has
Boteco "1" o-- "*" Product : has
ProductCategory "1" o-- "*" Product : categorized


%% ============================================================
%% MENU / CARDÁPIO
%% ============================================================

class MenuCategory {
  +Id menuCategoryId
  +FK botecoSlug
  +String name
  +String? description
  +Number position
  +Boolean active
  +Date createdAt
  +Date updatedAt
}

class MenuItem {
  +Id menuItemId
  +FK botecoSlug
  +FK? menuCategoryId
  +FK? productBaseId
  +String name
  +String? description
  +Number price
  +String currency
  +Boolean visible
  +Boolean isFeatured
  +Number position
  +String[]? tags
  +Date createdAt
  +Date updatedAt
}

Boteco "1" o-- "*" MenuCategory : has
Boteco "1" o-- "*" MenuItem : offers
MenuCategory "1" o-- "*" MenuItem : categorized
Product "1" o-- "*" MenuItem : baseProduct


%% ============================================================
%% RECEITAS / BOM
%% ============================================================

class Recipe {
  +Id recipeId
  +FK botecoSlug
  +String name
  +String? description
  +FK? menuItemId
  +Boolean active
  +Number? estimatedCost
  +Number? yieldQuantity
  +String? yieldUnit
  +Date createdAt
  +Date updatedAt
}

class RecipeProduct {
  +Id recipeProductId
  +FK botecoSlug
  +FK recipeId
  +FK productId
  +Number quantity
  +String? unitOverride
  +Number? estimatedUnitCost
  +Number position
  +Date createdAt
  +Date updatedAt
}

MenuItem "1" o-- "0..1" Recipe : hasRecipe
Recipe "1" o-- "*" RecipeProduct : products
Product "1" o-- "*" RecipeProduct : ingredient
