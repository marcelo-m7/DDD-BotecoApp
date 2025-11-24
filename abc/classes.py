from abc import ABC

class BaseEntity(ABC):
    def __init__(self,
                 id: int = None,
                 table_name: str = None,
                 description: str = None,
                 created_at: str = None,
                 updated_at: str = None):
        pass
    
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
        super().__init__(table_name=self.table_name)
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
        """Add stock to the current stock level."""
        self.current_stock += quantity
        print(f"New stock level: {self.current_stock}")
        return self.current_stock    
        
    def remove_stock(self, quantity: int):
        """Remove stock from the current stock level."""
        if quantity > self.current_stock:
            raise ValueError("Insufficient stock to remove the requested quantity.")
        self.current_stock -= quantity
        print(f"New stock level: {self.current_stock}")
        return self.current_stock
    
class DiningTable(BaseEntity):
    pass

class Order(BaseEntity):
    pass

class Receipt(BaseEntity):
    pass

class Production(BaseEntity):
    pass
