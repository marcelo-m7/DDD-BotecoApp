from fastapi import APIRouter
from app.db import get_connection

router = APIRouter(prefix="/pratos", tags=["Pratos"])

@router.get("/")
def listar_pratos():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id_prato, nome, preco_venda, observacoes FROM Prato")
    colunas = [col[0] for col in cursor.description]
    return [dict(zip(colunas, row)) for row in cursor.fetchall()]
