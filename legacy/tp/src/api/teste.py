# teste.py
import pyodbc

try:
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=Marcelo;"
        "DATABASE=Boteco_PRO;"
        "UID=boteco_user;"
        "PWD=SenhaForte123!"
    )
    print("✅ Conexão estabelecida com sucesso!")
except Exception as e:
    print("❌ Erro na conexão:", e)
