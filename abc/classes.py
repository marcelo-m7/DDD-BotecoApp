from abc import ABC
import logging
from datetime import date
from typing import List, Optional

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)


class BaseEntity(ABC):
    """Base class for all entities."""
    def __init__(self,
                 table_name: str,
                 view_name: Optional[str] = None,
                 description: Optional[str] = None,
                 created_at: Optional[date] = None,
                 updated_at: Optional[date] = None):
        self.table_name = table_name
        self.view_name = view_name
        self.description = description
        self.created_at = created_at or date.today()
        self.updated_at = updated_at or date.today()
        self.logger = logging.getLogger(self.__class__.__name__)

    # Placeholder methods for CRUD
    def create(self):
        """Create a new record in the database."""
        pass

    def retrieve(self):
        """Retrieve a record from the database."""
        pass

    def update(self):
        """Update a record in the database."""
        pass

    def delete(self):
        """Delete a record from the database."""
        pass


class Product(BaseEntity):
    table_name = "products"
    view_name = "ProductsView"

    def __init__(self,
                 name: str,
                 description: str,
                 unit: str,
                 current_stock: int,
                 min_stock: int,
                 max_stock: int,
                 cost: float,
                 price: float,
                 barcode: str,
                 category: str,
                 subcategory: str):
        super().__init__(
            table_name=self.table_name,
            view_name=self.view_name,
            description=description
        )
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
        self.logger.info(f"New stock level: {self.current_stock}")
        return self.current_stock

    def remove_stock(self, quantity: int):
        if quantity > self.current_stock:
            self.logger.warning(
                f"Tried to remove {quantity} but current stock is only {self.current_stock}"
            )
            raise ValueError("Insufficient stock to remove the requested quantity.")
        self.current_stock -= quantity
        self.logger.info(f"New stock level: {self.current_stock}")
        return self.current_stock


class DiningTable(BaseEntity):
    table_name = "dining_tables"
    view_name = "DiningTablesView"

    def __init__(self,
                 table_number: int,
                 capacity: int,
                 status: str,
                 order_ref: Optional[str] = None):
        super().__init__(
            table_name=self.table_name,
            view_name=self.view_name
        )
        self.table_number = table_number
        self.capacity = capacity
        self.status = status
        self.order_ref = order_ref


class Order(BaseEntity):
    table_name = "orders"
    view_name = "OrdersView"

    def __init__(self,
                 ref: str,
                 table_number: int,
                 items: Optional[List[str]] = None,
                 total_amount: float = 0.0,
                 status: str = "open"):
        super().__init__(table_name=self.table_name, view_name=self.view_name)
        self.ref = ref
        self.table_number = table_number
        self.items = items or []
        self.total_amount = total_amount
        self.status = status


class Receipt(BaseEntity):
    table_name = "receipts"
    view_name = "ReceiptsView"

    def __init__(self,
                 name: str,
                 description: str,
                 preparation_time: int,
                 type_: str,
                 price: float,
                 instructions: str):
        super().__init__(table_name=self.table_name, view_name=self.view_name)
        self.name = name
        self.description = description
        self.preparation_time = preparation_time
        self.type_ = type_
        self.price = price
        self.instructions = instructions


class Production(BaseEntity):
    table_name = "production"
    view_name = "ProductionView"

    def __init__(self,
                 product_ref: str,
                 quantity: int,
                 production_date: Optional[date] = None,
                 expiry_date: Optional[date] = None):
        super().__init__(table_name=self.table_name, view_name=self.view_name)
        self.product_ref = product_ref
        self.quantity = quantity
        self.production_date = production_date or date.today()
        self.expiry_date = expiry_date
