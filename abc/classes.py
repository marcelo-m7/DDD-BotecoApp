from abc import ABC
from datetime import date
from typing import List, Optional
from enum import Enum


class BaseEntity(ABC):
    """Representa uma entidade do domínio, sem DB."""
    def __init__(self, description: Optional[str] = None):
        self.description = description
        self.created_at = date.today()
        self.updated_at = date.today()


class Product(BaseEntity):
    def __init__(self,
                 name: str,
                 unit: str,
                 current_stock: int,
                 min_stock: int,
                 max_stock: int,
                 cost: float,
                 price: float,
                 barcode: Optional[str] = None,
                 category: Optional[str] = None,
                 subcategory: Optional[str] = None):
        super().__init__(description=category)
        self.name = name
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


class DiningTable(BaseEntity):
    def __init__(self, table_number: int, capacity: int, status: TableStatus, order_ref: Optional[str] = None):
        super().__init__()
        self.table_number = table_number
        self.capacity = capacity
        self.status = status
        self.order_ref = order_ref


class OrderStatus(Enum):
    OPEN = "open"
    CLOSED = "closed"
    CANCELED = "canceled"


class Order(BaseEntity):
    def __init__(self, ref: str, table_number: int, items: Optional[List[str]] = None, total_amount: float = 0.0, status: OrderStatus = OrderStatus.OPEN):
        super().__init__()
        self.ref = ref
        self.table_number = table_number
        self.items = items or []
        self.total_amount = total_amount
        self.status = status


class Receipt(BaseEntity):
    def __init__(self, name: str, preparation_time: int, type_: str, price: float, instructions: str):
        super().__init__()
        self.name = name
        self.preparation_time = preparation_time
        self.type_ = type_
        self.price = price
        self.instructions = instructions


class Production(BaseEntity):
    def __init__(self, product_ref: str, quantity: int, production_date: Optional[date] = None, expiry_date: Optional[date] = None):
        super().__init__()
        self.product_ref = product_ref
        self.quantity = quantity
        self.production_date = production_date or date.today()
        self.expiry_date = expiry_date

class Supplier(BaseEntity):
    def __init__(self, name: str, address: str, contact_info: str, products_supplied: Optional[List[str]] = None):
        super().__init__()
        self.name = name
        self.address = address
        self.contact_info = contact_info
        self.products_supplied = products_supplied or []
        self.notes = ""
        
    def add_product(self, product_ref: str):
        if product_ref not in self.products_supplied:
            self.products_supplied.append(product_ref)