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
