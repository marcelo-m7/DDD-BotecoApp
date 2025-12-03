from fastapi import APIRouter
from app.db import get_connection

router = APIRouter(prefix="/pedidos", tags=["Pedidos"])

@router.get("/")
def listar_pedidos():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id_pedido, estado, data_hora FROM Pedido")
    colunas = [col[0] for col in cursor.description]
    return [dict(zip(colunas, row)) for row in cursor.fetchall()]
