from fastapi import APIRouter
from app.db import get_connection

router = APIRouter(prefix="/funcionarios", tags=["Funcionários"])

@router.get("/")
def listar_funcionarios():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT f.id_funcionario, f.nome, c.descricao AS carreira, nc.descricao AS nivel
        FROM Funcionario f
        JOIN Carreira c ON f.id_carreira = c.id_carreira
        JOIN Nivel_Carreira nc ON f.id_nivel_carreira = nc.id_nivel_carreira
    """)
    colunas = [col[0] for col in cursor.description]
    return [dict(zip(colunas, row)) for row in cursor.fetchall()]
