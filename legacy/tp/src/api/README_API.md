# Boteco_PRO API

API REST desenvolvida com [FastAPI](https://fastapi.tiangolo.com/) para gerenciar as operações do restaurante Boteco_PRO. Essa API se conecta a um banco de dados **Microsoft SQL Server** e serve como backend para o aplicativo Flutter.

## 🚀 Funcionalidades

- Autenticação segura com hash de senha (`bcrypt`)
- Gestão de:
  - Funcionários
  - Produtos e Estoque
  - Pedidos e Pratos
  - Faturas
  - Menus Especiais
- Proteção CORS para integração com web/mobile

## 🧰 Tecnologias

- FastAPI
- SQL Server
- pyodbc
- bcrypt
- uvicorn

## 🔌 Requisitos

- Python 3.9+
- ODBC Driver 17 for SQL Server
- SQL Server (local ou remoto)
- pipenv ou virtualenv

## ⚙️ Setup Rápido

```bash
# Clone o repositório
cd boteco_pro_api

# Instale as dependências
pip install -r requirements.txt

# Edite seu .env
cp .env.example .env  # depois configure os dados de conexão

# Rode a aplicação
uvicorn app.main:app --reload
```

Acesse a documentação Swagger em:
📚 http://localhost:8000/docs

## 🔐 Autenticação

- Envie `username` e `password` para `/auth/login`
- Receba `token` e dados do usuário
- Envie `Authorization: Bearer <token>` nos headers das demais rotas

## 📁 Organização

```
app/
├── db.py                 # Conexão SQL Server
├── main.py               # Entrypoint
└── routers/              # Endpoints organizados
```

## 👨‍💻 Autor

Marcelo (UAlg · Computação Móvel 2024–2025)
