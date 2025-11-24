

class BaseEntity:
    def __init__(self,
                 id: int = None,
                 name: str = None,
                 description: str = None,
                 created_at: str = None,
                 updated_at: str = None):
        pass
    
    def create(self):
        pass
    
    def retrieve(self):
        pass
    
    def update(self):
        pass
    
    def delete(self):
        pass

class Product(BaseEntity):
    pass

class DiningTable(BaseEntity):
    pass

class Order(BaseEntity):
    pass

class Receipt(BaseEntity):
    pass

class Production(BaseEntity):
    pass
