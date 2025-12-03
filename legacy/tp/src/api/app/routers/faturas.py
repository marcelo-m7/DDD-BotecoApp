from fastapi import APIRouter
from app.db import get_connection

router = APIRouter(prefix="/faturas", tags=["Faturas"])

@router.get("/")
def listar_faturas():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id_fatura, data, valor_total, valor_iva FROM Fatura")
    colunas = [col[0] for col in cursor.description]
    return [dict(zip(colunas, row)) for row in cursor.fetchall()]
