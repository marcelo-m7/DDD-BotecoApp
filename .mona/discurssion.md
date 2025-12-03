**estrutura unificada e padronizada de domínio**, onde **todas as entidades** possuem uma estrutura base com:

* `title` e `description`: metadados.
* `status`: geralmente um Enum de controle.
* `content`: um objeto encapsulando os **atributos de domínio específicos** da entidade.

Esse conceito segue os princípios de **Domain-Driven Design (DDD)** com uso de **Value Objects**, e facilita:

* **Reuso e consistência entre entidades**.
* **Séries de validações reutilizáveis**.
* **Serialização / exportação** padronizada.
* **Separação clara entre metadados e dados de domínio**.

---

## ✅ Proposta de Estrutura Unificada

### 1. `Content` genérico (interface base)

Podemos usar um `@dataclass` abstrato ou genérico como base para os "conteúdos" de cada domínio:

```python
from dataclasses import dataclass, asdict
from abc import ABC

@dataclass
class ContentBase(ABC):
    """Interface base para conteúdos específicos das entidades."""
    def as_dict(self):
        return asdict(self)
```

---

### 2. `BaseEntity` com suporte a `ContentBase`

```python
from datetime import date
from typing import Optional
from enum import Enum

class Status(Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"

class BaseEntity:
    def __init__(self,
                 title: Optional[str] = None,
                 description: Optional[str] = None,
                 content: Optional[ContentBase] = None,
                 status: Status = Status.ACTIVE):
        self.title = title
        self.description = description
        self.content = content
        self.status = status
        self.created_at = date.today()
        self.updated_at = date.today()

    def content_dict(self):
        return self.content.as_dict() if self.content else {}
```

---

### 3. Exemplo: `ProductContent`

```python
@dataclass
class ProductContent(ContentBase):
    unit: str
    current_stock: int
    min_stock: int
    max_stock: int
    cost: float
    price: float
    barcode: Optional[str] = None
    category: Optional[ProductCategory] = None
    subcategory: Optional[ProductSubcategory] = None

    def __post_init__(self):
        if self.min_stock > self.max_stock:
            raise ValueError("min_stock cannot be greater than max_stock")
        if self.current_stock < 0 or self.min_stock < 0 or self.max_stock < 0:
            raise ValueError("stock values cannot be negative")
        if self.cost < 0 or self.price < 0:
            raise ValueError("cost and price must be non-negative")
```

---

### 4. Exemplo: `Product` como entidade com `ProductContent`

```python
class Product(BaseEntity):
    def __init__(self,
                 name: str,
                 description: str,
                 content: ProductContent):
        super().__init__(title=name, description=description, content=content)
```

---

### 5. Outras entidades seguindo o mesmo padrão

Exemplo para uma mesa (`DiningTableContent`):

```python
@dataclass
class DiningTableContent(ContentBase):
    table_number: int
    capacity: int
    order_ref: Optional[str] = None
```

```python
class DiningTable(BaseEntity):
    def __init__(self,
                 title: str,
                 description: str,
                 content: DiningTableContent):
        super().__init__(title=title, description=description, content=content)
```

---

## 🧪 Exemplo de uso

```python
p_content = ProductContent(
    unit="L",
    current_stock=10,
    min_stock=2,
    max_stock=50,
    cost=3.0,
    price=5.0
)

product = Product(name="Refrigerante", description="Bebida gaseificada", content=p_content)

print(product.title)
print(product.content.price)
print(product.content_dict())  # serializa conteúdo como dicionário
```

---

## ✅ Vantagens dessa arquitetura

| Benefício                   | Descrição                                                                                   |
| --------------------------- | ------------------------------------------------------------------------------------------- |
| **Padronização**            | Todas as entidades seguem o mesmo modelo base (`title`, `description`, `content`, `status`) |
| **Flexibilidade**           | Cada `Content` pode conter validações e atributos próprios                                  |
| **Serialização fácil**      | Com `asdict()`, você exporta o conteúdo direto                                              |
| **Manutenção mais simples** | Pode alterar a estrutura central facilmente                                                 |
| **Extensível**              | Suporte a composição, herança e validação                                                   |

