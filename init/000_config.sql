-- ============================================================
--  SCHEMA
-- ============================================================
CREATE SCHEMA IF NOT EXISTS boteco_pro;
SET search_path TO boteco_pro;

-- ============================================================
--  EXTENSIONS (boas práticas)
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
--  UPDATED_AT TRIGGER (padrão para todas as tabelas)
-- ============================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
