import bcrypt
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.db import get_connection

router = APIRouter(prefix="/auth", tags=["Autenticação"])

class LoginRequest(BaseModel):
    username: str
    password: str

@router.post("/login")
def login(data: LoginRequest):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT id_funcionario, nome, senha_hash FROM Funcionario WHERE nome = ?",
        data.username
    )
    row = cursor.fetchone()
    if row:
        senha_hash = row[2]
        if bcrypt.checkpw(data.password.encode('utf-8'), senha_hash.encode('utf-8')):
            return {
                "token": "mocked-jwt-token",
                "usuario": {
                    "id": row[0],
                    "nome": row[1],
                    "perfil": "gestor"
                }
            }

    raise HTTPException(status_code=401, detail="Credenciais inválidas")
