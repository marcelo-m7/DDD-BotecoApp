# TODO: Need to start planning the views to reproduce the layout and begin mapping titles for the translation mechanism.
# from abc import ABC
from datetime import date
from typing import List, Optional
from enum import Enum


# Entities
# Value Objects
# Domain Services
# Enums como “ubiquitous language”

class Entity:
    """Representa uma entidade do domínio, sem DB."""
    def __init__(self, 
                 title: Optional[str] = None,
                 description: Optional[str] = None, 
                 content: Optional[str] = None,
                 active: bool = True):
        self.title = title
        self.description = description
        self.content = content
        self.active = active
        self.created_at = date.today()
        self.updated_at = date.today()

class EntityAttributes:
    TITLE = "title"
    DESCRIPTION = "description"
    CONTENT = "content"
    ACTIVE = "active"
    CREATED_AT = "created_at"
    UPDATED_AT = "updated_at"
    
class EntityMethods:
    ACTIVATE = "activate"
    DEACTIVATE = "deactivate"
    UPDATE_CONTENT = "update_content"
    
class EntityEnums:
    STATUS = "status"
    TAG = "tag"    

class ProductCategory(Enum):
    FOOD = "food"
    BEVERAGE = "beverage"
    SUPPLY = "supply"

class ProductSubcategory(Enum):
    ALCOHOLIC = "alcoholic"
    NON_ALCOHOLIC = "non_alcoholic"

class Product(Entity):
    def __init__(self,
                 name: str,
                 description: str,
                 unit: str,
                 current_stock: int,
                 min_stock: int,
                 max_stock: int,
                 cost: float,
                 price: float,
                 barcode: Optional[str] = None,
                 category: Optional[ProductCategory] = None,
                 subcategory: Optional[ProductSubcategory] = None):
        # Initialize inherited fields
        super().__init__(title=name, description=description)
        self.content: Optional[str] = None

        # Basic validations
        if min_stock > max_stock:
            raise ValueError("min_stock cannot be greater than max_stock")
        if current_stock < 0 or min_stock < 0 or max_stock < 0:
            raise ValueError("stock values cannot be negative")
        if cost < 0 or price < 0:
            raise ValueError("cost and price must be non-negative")

        self.unit = unit
        self.current_stock = current_stock
        self.min_stock = min_stock
        self.max_stock = max_stock
        self.cost = cost
        self.price = price
        self.barcode = barcode
        self.category = category
        self.subcategory = subcategory
        

    def add_stock(self, quantity: int):
        self.current_stock += quantity

    def remove_stock(self, quantity: int):
        if quantity > self.current_stock:
            raise ValueError("Insufficient stock.")
        self.current_stock -= quantity


class TableStatus(Enum):
    AVAILABLE = "available"
    OCCUPIED = "occupied"
    RESERVED = "reserved"
    CLEANING = "cleaning"


class DiningTable(Entity):
    def __init__(self, table_number: int, capacity: int, status: TableStatus, order_ref: Optional[str] = None):
        # Use the table number as the title (string) to keep `title` textual
        super().__init__(title=str(table_number))
        self.capacity = capacity
        self.status = status
        self.order_ref = order_ref


class OrderStatus(Enum):
    OPEN = "open"
    CLOSED = "closed"
    CANCELED = "canceled"


class Order(Entity):
    def __init__(self, ref: str, table_number: int, items: Optional[List[str]] = None, total_amount: float = 0.0, status: OrderStatus = OrderStatus.OPEN):
        # Use ref as title and table_number as a textual description
        super().__init__(title=ref, description=str(table_number))
        self.items = items or []
        self.total_amount = total_amount
        self.status = status


class Receipt(Entity):
    def __init__(self, name: str, preparation_time: int, type_: str, price: float, instructions: str):
        # Use name as title and instructions as description for clarity
        super().__init__(title=name, description=instructions)
        self.preparation_time = preparation_time
        self.type_ = type_
        if preparation_time < 0:
            raise ValueError("preparation_time cannot be negative")
        if price < 0:
            raise ValueError("price cannot be negative")
        self.price = price
        self.instructions = instructions


class Production(Entity):
    def __init__(self, product_ref: str, quantity: int, production_date: Optional[date] = None, expiry_date: Optional[date] = None):
        super().__init__()
        if quantity <= 0:
            raise ValueError("quantity must be positive")
        self.product_ref = product_ref
        self.quantity = quantity
        self.production_date = production_date or date.today()
        self.expiry_date = expiry_date

class Supplier(Entity):
    def __init__(self, name: str, address: str, contact_info: str, products_supplied: Optional[List[str]] = None):
        # Use supplier name/address for inherited title/description
        super().__init__(title=name, description=address)
        self.name = name
        self.address = address
        self.contact_info = contact_info
        self.products_supplied = products_supplied or []
        self.notes = ""
        
    def add_product(self, product_ref: str):
        if product_ref not in self.products_supplied:
            self.products_supplied.append(product_ref)