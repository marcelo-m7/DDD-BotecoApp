from fastapi import APIRouter
from app.db import get_connection

router = APIRouter(prefix="/menus", tags=["Menus Especiais"])

@router.get("/ativos")
def listar_menus_ativos():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT me.id_menu, me.nome AS nome_menu, me.preco, ee.nome AS evento
        FROM Menu_Especial me
        JOIN Evento_Especial ee ON me.id_evento = ee.id_evento
        WHERE CAST(GETDATE() AS DATE) BETWEEN ee.data_inicio AND ee.data_fim
    """)
    colunas = [col[0] for col in cursor.description]
    return [dict(zip(colunas, row)) for row in cursor.fetchall()]
