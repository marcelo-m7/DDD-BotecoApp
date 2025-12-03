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
    (gen_random_uuid(), 'Bebidas', 'Todos os tipos de bebidas', TRUE),
    (gen_random_uuid(), 'Comidas', 'Pratos, snacks, lanches', TRUE),
    (gen_random_uuid(), 'Outros', 'Produtos diversos', TRUE);

-- ============================================================
-- MENU CATEGORIES (default)
-- ============================================================
INSERT INTO menu_category (menu_category_id, name, description, position, active)
VALUES
    (gen_random_uuid(), 'Entradas', 'Petiscos e snacks iniciais', 1, TRUE),
    (gen_random_uuid(), 'Pratos', 'Refeições principais', 2, TRUE),
    (gen_random_uuid(), 'Bebidas', 'Drinks, refrigerantes e outros', 3, TRUE);

-- ============================================================
-- DEFAULT TABLES (Mesas)
-- ============================================================
-- Obs: Ajuste quantas quiser. Aqui deixo 8 mesas padrão.
INSERT INTO table_entity (table_id, label, seats, active)
VALUES
    (gen_random_uuid(), 'Mesa 1', 4, TRUE),
    (gen_random_uuid(), 'Mesa 2', 4, TRUE),
    (gen_random_uuid(), 'Mesa 3', 4, TRUE),
    (gen_random_uuid(), 'Mesa 4', 4, TRUE),
    (gen_random_uuid(), 'Mesa 5', 2, TRUE),
    (gen_random_uuid(), 'Mesa 6', 2, TRUE),
    (gen_random_uuid(), 'Mesa 7', 6, TRUE),
    (gen_random_uuid(), 'Mesa 8', 6, TRUE);

-- ============================================================
-- OPTIONAL: Basic placeholder products for quick testing
-- Comentado por padrão — ativa se quiser preencher automaticamente.
-- ============================================================
-- INSERT INTO product (product_id, product_category_id, name, cost, unit, active)
-- SELECT gen_random_uuid(), pc.product_category_id, 'Produto Exemplo', 1.00, 'unit', TRUE
-- FROM product_category pc
-- WHERE pc.name = 'Outros'
-- LIMIT 1;

-- ============================================================
-- OPTIONAL: Basic menu items placeholders
-- Comentado por padrão.
-- ============================================================
-- INSERT INTO menu_item (menu_item_id, name, price, currency, visible, is_featured, position)
-- VALUES
--     (gen_random_uuid(), 'Item de Teste 1', 5.00, 'EUR', TRUE, FALSE, 1),
--     (gen_random_uuid(), 'Item de Teste 2', 8.50, 'EUR', TRUE, TRUE, 2);

-- ============================================================
-- OPTIONAL: Create a first POS session automatically
-- MUITO IMPORTANTE: Só habilitar se quiser que um boteco comece 
-- com uma sessão automaticamente aberta.
-- ============================================================
-- INSERT INTO pos_session (pos_session_id, staff_id, opening_amount, status)
-- VALUES
--     (gen_random_uuid(), '{{default_staff_id}}', 0, 'open');

-- ============================================================
-- OPTIONAL: Seed basic tags or metadata
-- ============================================================
-- UPDATE menu_item SET tags = ARRAY['popular'] WHERE is_featured = TRUE;

-- ============================================================
-- FIM DO SEED
-- ============================================================
