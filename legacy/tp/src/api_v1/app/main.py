from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import login, pedidos, estoque, funcionarios, faturas, pratos, menus

app = FastAPI(title="Boteco_PRO API")

# Adicione este middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ou use ['http://localhost:xxxx'] se quiser restringir
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(login.router)
app.include_router(pedidos.router)
app.include_router(estoque.router)
app.include_router(funcionarios.router)
app.include_router(faturas.router)
app.include_router(pratos.router)
app.include_router(menus.router)
