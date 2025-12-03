# Instruções para Configuração do Banco de Dados `Boteco_PRO`

Este documento descreve o passo a passo para preparar o ambiente de banco de dados utilizado no projeto da disciplina **Base de Dados II**.

## Pré‑requisitos

- SQL Server instalado (local ou remoto)
- Permissão para criação de base de dados e objetos
- Driver ODBC e ferramenta de administração (por exemplo, SSMS)

## 1. Criação do utilizador

Execute o script `00_Login.sql` para criar um login e um utilizador com privilégios de **db_owner** na base de dados.

```sql
USE master;
CREATE LOGIN boteco_user WITH PASSWORD = 'SenhaForte123!';
USE Boteco_PRO;
CREATE USER boteco_user FOR LOGIN boteco_user;
EXEC sp_addrolemember 'db_owner', 'boteco_user';
```

Ajuste a palavra‑passe conforme as políticas de segurança da sua instância.

## 2. Criação das tabelas e relações

O script `01_Criação_DB.sql` cria a base de dados e todo o esquema relacional, incluindo tabelas de produtos, pedidos, funcionários, clientes e outros objetos necessários.

Execute o ficheiro na seguinte ordem para evitar problemas de dependência:

1. `01_Criação_DB.sql`
2. `02_Base_Views.sql`
3. `03_Materialized_Views.sql`
4. `04_Functions.sql`
5. `05_SP_Finalizar_Mesa.sql`
6. `06_SP_Realizar_Pedido.sql`
7. `07_Stored_Procedures.sql`
8. `08_Triggers.sql`
9. `09_Function_Detalhes_Fatura.sql`

## 3. Popular a base de dados

Existem dois conjuntos de dados de teste (`10_Seeds_1.sql` e `11_Seeds_2.sql`). Execute-os após a criação de todos os objetos para inserir categorias, produtos, funcionários, clientes e pedidos de exemplo.

## 4. Atualizações e testes

Após executar os scripts acima, o sistema estará pronto para utilização e testes. Utilize as procedures de inserção e as views para validar o funcionamento das triggers de estoque, cálculo de vencimentos e geração automática de faturas.

---

Consulte o documento `RELATORIO_TECNICO.md` para detalhes sobre a estrutura do projeto e a organização dos scripts.
