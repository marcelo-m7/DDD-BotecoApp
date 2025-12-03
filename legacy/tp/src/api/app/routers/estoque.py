from fastapi import APIRouter
from app.db import get_connection

router = APIRouter(prefix="/estoque", tags=["Estoque"])

@router.get("/")
def listar_produtos():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id_produto, nome, descricao, stock_atual, stock_minimo FROM Produto")
    colunas = [col[0] for col in cursor.description]
    return [dict(zip(colunas, row)) for row in cursor.fetchall()]
