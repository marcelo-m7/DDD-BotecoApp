from abc import ABC
import logging
from datetime import date

logging.basicConfig(
    level=logging.INFO,  
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)


class BaseEntity(ABC):
    def __init__(self,
                 table_name: str,
                 view_name: str,
                 description: str,
                 created_at = None = None,
                 updated_at: date = None):
        """Initialize a BaseEntity instance."""
        self.table_name = table_name
        self.view_name = view_name
        self.logger = logging.getLogger(self.__class__.__name__)
    
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
    logger = logging.getLogger("Product")    
    
    def __init__(self,
                 name: str,
                 description: str,
                 unit: str,
                 current_stock: int,
                 min_stock: int,
                 max_stock: int,
                 cost: int,
                 sell_price: int,
                 barcode: str,
                 category: str,
                 subcategory: str):
        """Initialize a Product instance."""
        super().__init__(
            table_name=self.table_name,
            view_name=self.view_name,
            description=description,
            created_at=date.today(),
        )
        self.name = name
        self.description = description
        self.unit = unit
        self.current_stock = current_stock    
        self.min_stock = min_stock
        self.max_stock = max_stock
        self.cost = cost
        self.sell_price = sell_price
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
    logger = logging.getLogger("DiningTable")
    
    
    def __init__(self,
                 table_number: int,
                 capacity: int,
                 status: str,
                 tab: str):
        """Initialize a DiningTable instance."""
        super().__init__(table_name=self.table_name)
        self.table_number = table_number
        self.capacity = capacity
        self.status = status
        self.tab = tab
        self.table_number = table_number
        self.capacity = capacity
        self.status = status
        self.tab = tab

class Order(BaseEntity):
    pass

class Receipt(BaseEntity):
    pass

class Production(BaseEntity):
    pass
