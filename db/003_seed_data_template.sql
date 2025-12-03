-- ============================================================
-- 003_seed_data_template.sql
-- Template de dados iniciais insertados em cada schema de boteco
--
-- Substituir {{schema_name}} antes de executar
-- ============================================================

SET search_path TO {{schema_name}};

-- ============================================================
-- PRODUCT CATEGORIES (default)
-- ============================================================
INSERT INTO product_category (product_category_id, name, description, active)
VALUES
    (uuid_generate_v4(), 'Bebidas', 'Todos os tipos de bebidas', TRUE),
    (uuid_generate_v4(), 'Comidas', 'Pratos, snacks, lanches', TRUE),
    (uuid_generate_v4(), 'Outros', 'Produtos diversos', TRUE);

-- ============================================================
-- MENU CATEGORIES (default)
-- ============================================================
INSERT INTO menu_category (menu_category_id, name, description, position, active)
VALUES
    (uuid_generate_v4(), 'Entradas', 'Petiscos e snacks iniciais', 1, TRUE),
    (uuid_generate_v4(), 'Pratos', 'Refeições principais', 2, TRUE),
    (uuid_generate_v4(), 'Bebidas', 'Drinks, refrigerantes e outros', 3, TRUE);

-- ============================================================
-- DEFAULT TABLES (Mesas)
-- ============================================================
-- Obs: Ajuste quantas quiser. Aqui deixo 8 mesas padrão.
INSERT INTO table_entity (table_id, label, seats, active)
VALUES
    (uuid_generate_v4(), 'Mesa 1', 4, TRUE),
    (uuid_generate_v4(), 'Mesa 2', 4, TRUE),
    (uuid_generate_v4(), 'Mesa 3', 4, TRUE),
    (uuid_generate_v4(), 'Mesa 4', 4, TRUE),
    (uuid_generate_v4(), 'Mesa 5', 2, TRUE),
    (uuid_generate_v4(), 'Mesa 6', 2, TRUE),
    (uuid_generate_v4(), 'Mesa 7', 6, TRUE),
    (uuid_generate_v4(), 'Mesa 8', 6, TRUE);

-- ============================================================
-- OPTIONAL: Basic placeholder products for quick testing
-- Comentado por padrão — ativa se quiser preencher automaticamente.
-- ============================================================
-- INSERT INTO product (product_id, product_category_id, name, cost, unit, active)
-- SELECT uuid_generate_v4(), pc.product_category_id, 'Produto Exemplo', 1.00, 'unit', TRUE
-- FROM product_category pc
-- WHERE pc.name = 'Outros'
-- LIMIT 1;

-- ============================================================
-- OPTIONAL: Basic menu items placeholders
-- Comentado por padrão.
-- ============================================================
-- INSERT INTO menu_item (menu_item_id, name, price, currency, visible, is_featured, position)
-- VALUES
--     (uuid_generate_v4(), 'Item de Teste 1', 5.00, 'EUR', TRUE, FALSE, 1),
--     (uuid_generate_v4(), 'Item de Teste 2', 8.50, 'EUR', TRUE, TRUE, 2);

-- ============================================================
-- OPTIONAL: Create a first POS session automatically
-- MUITO IMPORTANTE: Só habilitar se quiser que um boteco comece 
-- com uma sessão automaticamente aberta.
-- ============================================================
-- INSERT INTO pos_session (pos_session_id, staff_id, opening_amount, status)
-- VALUES
--     (uuid_generate_v4(), '{{default_staff_id}}', 0, 'open');

-- ============================================================
-- OPTIONAL: Seed basic tags or metadata
-- ============================================================
-- UPDATE menu_item SET tags = ARRAY['popular'] WHERE is_featured = TRUE;

-- ============================================================
-- FIM DO SEED
-- ============================================================
