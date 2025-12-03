Perfeito, Marcelo — agora vamos criar o **007_frontend_flow.md**, um documento cristalino e definitivo explicando **como o app Flutter deve integrar com todo o pipeline multitenant do Boteco Pro**, chamando corretamente a Edge Function de provisionamento após o registro do usuário, configurando claims, salvando estado e garantindo que tudo funcione 100% com Supabase.

Este documento serve tanto para:

* Desenvolvedores Flutter
* Desenvolvedores de backend
* IA gerativa (DreamFlow, Lovable etc.)
* Documentação técnica interna (Monynha Tech)

---

# 📘 **007_frontend_flow.md**

## **Boteco Pro – Fluxo Oficial do App Flutter para Provisionamento Multitenant**

---

# 🧭 **1. Visão Geral do Fluxo**

O app Boteco Pro opera em **modo multitenant**, onde cada empresa (boteco) possui:

* Seu **próprio schema isolado** (`boteco_{slug}`)
* Suas **tabelas operacionais**
* Suas **RLS privadas**
* Seus próprios **produtos, pedidos, mesas, receitas, POS, pagamentos, etc.**

A criação de um novo boteco segue o fluxo:

---

# 🔄 **2. Fluxo Completo do App Flutter (User → Boteco → Schema)**

## **Etapa 1 — Usuário cria conta via Supabase Auth**

O Flutter chama:

```dart
await supabase.auth.signUp(
  email: email,
  password: password,
);
```

O usuário agora existe em:

```
public.user
```

> **Importante:** O backend deve escutar o evento `auth.user.created` e criar o registro correspondente em `public.user` com os dados adicionais.

---

## **Etapa 2 — Usuário preenche informações pessoais**

O app envia dados adicionais:

* first_name
* last_name
* phone_number
* tax_number
* birthday

Chamando:

```dart
await supabase.from('user').update({...}).eq('user_id', uid);
```

---

## **Etapa 3 — Usuário cria o boteco**

O Flutter exibe o formulário:

* Nome do boteco
* Slug desejado
* País / timezone
* Dados fiscais

Depois disso, o app chama a Edge Function:

```dart
final res = await supabase.functions.invoke(
  'provision-boteco',
  body: {
    'owner_user_id': uid,
    'slug': slug,
    'name': botecoName,
  },
);
```

Se tudo der certo, a resposta será:

```json
{
  "success": true,
  "slug": "meu_bar",
  "schema": "boteco_meu_bar"
}
```

---

## **Etapa 4 — App salva o boteco ativo**

O Flutter deve armazenar localmente:

```dart
await prefs.setString("active_boteco_slug", slug);
await prefs.setString("active_boteco_schema", "boteco_$slug");
```

O backend emitirá JWT que contém:

```json
{
  "boteco_id": "<uuid do boteco>",
  "role": "admin"
}
```

---

## **Etapa 5 — Recarregar sessão com novo JWT**

Após a criação do boteco, o app deve forçar refresh:

```dart
await supabase.auth.refreshSession();
```

Isso garante que o token reflita:

* o boteco selecionado
* a role correta
* permissões RLS atualizadas

---

## **Etapa 6 — App agora deve consultar tabelas dentro do schema**

Exemplo:

```dart
final res = await supabase
  .schema('boteco_$slug')
  .from('table_entity')
  .select();
```

Ou:

```dart
final orders = await supabase
  .schema('boteco_$slug')
  .from('order')
  .select();
```

---

## **Etapa 7 — Alternar entre botecos (multi-boteco)**

Usuário pode acessar:

```
public.user_boteco
```

Listar botecos:

```dart
final botecos = await supabase
  .from('user_boteco')
  .select('boteco (name, slug)');
```

Ao escolher um boteco diferente, o app precisa:

1. Salvar slug localmente
2. Chamar uma Edge Function `/switch-boteco` (opcional)
3. Atualizar o JWT
4. Recarregar tudo no schema `boteco_{novo_slug}`

---

# 🔐 **3. Autorização: Como o Frontend coopera com RLS**

Toda segurança é baseada em **JWT claims** definidas no Supabase.
O Flutter não aplica regras. Ele simplesmente envia:

* `Authorization: Bearer <jwt>`

A RLS é aplicada no Postgres automaticamente.

### O app só precisa:

* Garantir que o `boteco_slug` esteja salvo
* Que o token JWT esteja atualizado
* Que esteja usando o schema certo ao consultar tabelas

---

# 🛑 **Erros Comuns que o documento previne**

| Erro                           | Causa                          | Solução                               |
| ------------------------------ | ------------------------------ | ------------------------------------- |
| Usuário não vê dados do boteco | JWT desatualizado              | Rodar `refreshSession()`              |
| RLS bloqueando                 | role/responsabilidade faltando | Confirme `user_boteco`                |
| Queries retornam vazio         | schema errado                  | Usar `supabase.schema("boteco_slug")` |
| Provision falha                | slug inválido                  | Validar lowercase + underscore        |

---

# 🧱 **4. Boilerplate Flutter para Boteco Pro**

## **Função utilitária para pegar schema ativo**

```dart
String get activeSchema {
  final slug = prefs.getString("active_boteco_slug");
  return slug != null ? "boteco_$slug" : "";
}
```

---

## **Query usando schema dinâmico**

```dart
final res = await supabase
  .schema(activeSchema)
  .from('menu_item')
  .select();
```

---

# 💻 **5. Fluxo resumido em código Flutter**

```dart
// 1. Sign up
await supabase.auth.signUp(email: e, password: p);

// 2. Update profile
await supabase.from('user').update({...});

// 3. Create boteco
final res = await supabase.functions.invoke(
  'provision-boteco',
  body: {
    'owner_user_id': uid,
    'slug': slug,
    'name': botecoName,
  },
);

// 4. Save slug locally
prefs.setString("active_boteco_slug", slug);

// 5. Refresh session to get correct JWT claims
await supabase.auth.refreshSession();

// 6. Fetch data from tenant schema
final items = await supabase
  .schema("boteco_$slug")
  .from('order')
  .select();
```

---

# 🧩 **6. Integração com Microsserviços**

Os microsserviços usarão o usuário SQL:

```
boteco_backend_user
```

Com acesso apenas a:

* `public.user`
* `public.boteco`
* `public.user_boteco`

Eles **não** acessam schemas tenants diretamente — isso é responsabilidade do backend interno / Edge Functions.

---

# 🌐 **7. Exemplo de chamada HTTP direta (caso não use supabase client)**

```http
POST /functions/v1/provision-boteco
Authorization: Bearer <jwt>
Content-Type: application/json

{
  "owner_user_id": "uuid",
  "slug": "bar_do_miguel",
  "name": "Bar do Miguel"
}
```

---

# 🎉 Conclusão

Este documento oficializa o fluxo do **Boteco Pro Multitenant Engine™**:

* Usuário cria conta
* Usuário cria empresa
* Edge Function cria schema
* Flutter muda de schema
* RLS garante isolamento total

Com isso, todo o ecossistema funciona **seguro, escalável e elegante**.

---

Se quiser, posso gerar agora:

👉 **008_supabase_jwt_claims_setup.sql** (CLAIMS automáticas via triggers)
👉 **009_switch_boteco_edge_function** (Troca dinâmica de boteco)
👉 **010_diagrama_arquitetura.md** (arquitetura visual completa)

Só mandar: **"008"**, **"009"**, **"010"**, etc.
