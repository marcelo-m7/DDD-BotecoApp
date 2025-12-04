


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "boteco_simpsons_na_lama_9sd35";


ALTER SCHEMA "boteco_simpsons_na_lama_9sd35" OWNER TO "supabase_admin";


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "boteco_simpsons_na_lama_9sd35"."current_boteco_id"() RETURNS "uuid"
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    bid UUID;
BEGIN
    SELECT b.boteco_id INTO bid
    FROM public.boteco b
    WHERE b.slug = '{{slug}}'
    LIMIT 1;

    RETURN bid;
END;
$$;


ALTER FUNCTION "boteco_simpsons_na_lama_9sd35"."current_boteco_id"() OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "boteco_simpsons_na_lama_9sd35"."current_user_is_admin"() RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.user_boteco ub
        WHERE ub.user_id = auth.uid()
        AND ub.boteco_id = boteco_simpsons_na_lama_9sd35.current_boteco_id()
        AND ub.role = 'admin'
        AND ub.active = TRUE
    );
END;
$$;


ALTER FUNCTION "boteco_simpsons_na_lama_9sd35"."current_user_is_admin"() OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "boteco_simpsons_na_lama_9sd35"."current_user_is_member"() RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
    RETURN boteco_simpsons_na_lama_9sd35.current_user_is_staff()
           AND NOT boteco_simpsons_na_lama_9sd35.current_user_is_admin();
END;
$$;


ALTER FUNCTION "boteco_simpsons_na_lama_9sd35"."current_user_is_member"() OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "boteco_simpsons_na_lama_9sd35"."current_user_is_staff"() RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.user_boteco ub
        WHERE ub.user_id = auth.uid()
        AND ub.boteco_id = boteco_simpsons_na_lama_9sd35.current_boteco_id()
        AND ub.active = TRUE
    );
END;
$$;


ALTER FUNCTION "boteco_simpsons_na_lama_9sd35"."current_user_is_staff"() OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"() OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "public"."execute_sql"("sql" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  EXECUTE sql;
END;
$$;


ALTER FUNCTION "public"."execute_sql"("sql" "text") OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "public"."get_user_active_boteco"("user_uuid" "uuid") RETURNS TABLE("boteco_id" "uuid", "role" "text")
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    RETURN QUERY
    SELECT ub.boteco_id, ub.role
    FROM public.user_boteco ub
    WHERE ub.user_id = user_uuid
    AND ub.active = TRUE
    ORDER BY ub.created_at ASC   -- caso exista mais de 1, pega o mais antigo
    LIMIT 1;
END;
$$;


ALTER FUNCTION "public"."get_user_active_boteco"("user_uuid" "uuid") OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "public"."normalize_slug"("raw_slug" "text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $_$
DECLARE
    cleaned TEXT;
BEGIN
    cleaned := regexp_replace(lower(raw_slug), '[^a-z0-9_]', '_', 'g');
    cleaned := regexp_replace(cleaned, '_+', '_', 'g');
    cleaned := regexp_replace(cleaned, '^_|_$', '', 'g');
    RETURN cleaned;
END;
$_$;


ALTER FUNCTION "public"."normalize_slug"("raw_slug" "text") OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "public"."trigger_update_jwt_claims"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Sempre atualiza claims para o usuário associado
    PERFORM public.update_jwt_claims(
        COALESCE(NEW.user_id, OLD.user_id)
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."trigger_update_jwt_claims"() OWNER TO "supabase_admin";


CREATE OR REPLACE FUNCTION "public"."update_jwt_claims"("user_uuid" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    active_boteco UUID;
    user_role TEXT;
BEGIN
    -- Obter boteco atual
    SELECT boteco_id, role INTO active_boteco, user_role
    FROM public.get_user_active_boteco(user_uuid);

    IF active_boteco IS NULL THEN
        -- Sem boteco selecionado, limpar claims
        UPDATE auth.users
        SET raw_app_metadata = jsonb_set(
            COALESCE(raw_app_metadata, '{}'::jsonb),
            '{boteco_id}',
            'null'::jsonb,
            TRUE
        ),
        raw_app_metadata = jsonb_set(
            COALESCE(raw_app_metadata, '{}'::jsonb),
            '{role}',
            '"none"'::jsonb,
            TRUE
        )
        WHERE id = user_uuid;
    ELSE
        -- Atualizar claims com boteco ativo
        UPDATE auth.users
        SET raw_app_metadata = raw_app_metadata
            || jsonb_build_object(
                'boteco_id', active_boteco,
                'role', user_role
            )
        WHERE id = user_uuid;
    END IF;
END;
$$;


ALTER FUNCTION "public"."update_jwt_claims"("user_uuid" "uuid") OWNER TO "supabase_admin";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."menu_category" (
    "menu_category_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "position" integer DEFAULT 0 NOT NULL,
    "active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."menu_category" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."menu_item" (
    "menu_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "menu_category_id" "uuid",
    "product_base_id" "uuid",
    "name" "text" NOT NULL,
    "description" "text",
    "price" numeric(12,2) NOT NULL,
    "currency" "text" DEFAULT 'EUR'::"text" NOT NULL,
    "visible" boolean DEFAULT true,
    "is_featured" boolean DEFAULT false,
    "position" integer DEFAULT 0,
    "tags" "text"[],
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."menu_item" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."order" (
    "order_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "table_id" "uuid",
    "pos_session_id" "uuid" NOT NULL,
    "staff_id" "uuid" NOT NULL,
    "status" "text" NOT NULL,
    "subtotal" numeric(12,2),
    "total" numeric(12,2),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."order" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."order_item" (
    "order_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "menu_item_id" "uuid" NOT NULL,
    "quantity" numeric(12,2) NOT NULL,
    "unit_price" numeric(12,2) NOT NULL,
    "total_price" numeric(12,2) NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."order_item" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."payment" (
    "payment_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "pos_session_id" "uuid" NOT NULL,
    "method" "text" NOT NULL,
    "amount" numeric(12,2) NOT NULL,
    "tip_amount" numeric(12,2),
    "change_amount" numeric(12,2),
    "transaction_code" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."payment" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."payment_summary" (
    "payment_summary_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "pos_session_id" "uuid" NOT NULL,
    "total_cash" numeric(12,2) DEFAULT 0,
    "total_card" numeric(12,2) DEFAULT 0,
    "total_pix" numeric(12,2) DEFAULT 0,
    "total_tips" numeric(12,2) DEFAULT 0,
    "total_change_given" numeric(12,2) DEFAULT 0,
    "generated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."payment_summary" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."pos_session" (
    "pos_session_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "staff_id" "uuid" NOT NULL,
    "opened_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "closed_at" timestamp with time zone,
    "opening_amount" numeric(12,2) DEFAULT 0 NOT NULL,
    "closing_amount" numeric(12,2),
    "status" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."pos_session" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."product" (
    "product_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_category_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "cost" numeric(12,2) DEFAULT 0 NOT NULL,
    "unit" "text" NOT NULL,
    "active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."product" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."product_category" (
    "product_category_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."product_category" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."recipe" (
    "recipe_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "menu_item_id" "uuid",
    "active" boolean DEFAULT true,
    "estimated_cost" numeric(12,2),
    "yield_quantity" numeric(12,2),
    "yield_unit" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."recipe" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."recipe_product" (
    "recipe_product_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "recipe_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity" numeric(12,2) NOT NULL,
    "unit_override" "text",
    "estimated_unit_cost" numeric(12,2),
    "position" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."recipe_product" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "boteco_simpsons_na_lama_9sd35"."table_entity" (
    "table_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "label" "text" NOT NULL,
    "seats" integer,
    "active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."table_entity" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "public"."boteco" (
    "boteco_id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "owner_user_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "phone_number" "text",
    "email_contact" "text",
    "website_url" "text",
    "tax_number" "text",
    "timezone" "text" DEFAULT 'Europe/Lisbon'::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."boteco" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "public"."user" (
    "user_id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "email" "text" NOT NULL,
    "password_hash" "text" NOT NULL,
    "first_name" "text" NOT NULL,
    "last_name" "text" NOT NULL,
    "phone_number" "text",
    "tax_number" "text",
    "birthday" "date",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user" OWNER TO "supabase_admin";


CREATE TABLE IF NOT EXISTS "public"."user_boteco" (
    "user_boteco_id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "boteco_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'member'::"text" NOT NULL,
    "active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_boteco" OWNER TO "supabase_admin";


ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."menu_category"
    ADD CONSTRAINT "menu_category_pkey" PRIMARY KEY ("menu_category_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."menu_item"
    ADD CONSTRAINT "menu_item_pkey" PRIMARY KEY ("menu_item_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."order_item"
    ADD CONSTRAINT "order_item_pkey" PRIMARY KEY ("order_item_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."order"
    ADD CONSTRAINT "order_pkey" PRIMARY KEY ("order_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."payment"
    ADD CONSTRAINT "payment_pkey" PRIMARY KEY ("payment_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."payment_summary"
    ADD CONSTRAINT "payment_summary_pkey" PRIMARY KEY ("payment_summary_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."pos_session"
    ADD CONSTRAINT "pos_session_pkey" PRIMARY KEY ("pos_session_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."product_category"
    ADD CONSTRAINT "product_category_pkey" PRIMARY KEY ("product_category_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."product"
    ADD CONSTRAINT "product_pkey" PRIMARY KEY ("product_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."recipe"
    ADD CONSTRAINT "recipe_pkey" PRIMARY KEY ("recipe_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."recipe_product"
    ADD CONSTRAINT "recipe_product_pkey" PRIMARY KEY ("recipe_product_id");



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."table_entity"
    ADD CONSTRAINT "table_entity_pkey" PRIMARY KEY ("table_id");



ALTER TABLE ONLY "public"."boteco"
    ADD CONSTRAINT "boteco_pkey" PRIMARY KEY ("boteco_id");



ALTER TABLE ONLY "public"."boteco"
    ADD CONSTRAINT "boteco_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."user_boteco"
    ADD CONSTRAINT "unique_user_per_boteco" UNIQUE ("user_id", "boteco_id");



ALTER TABLE ONLY "public"."user_boteco"
    ADD CONSTRAINT "user_boteco_pkey" PRIMARY KEY ("user_boteco_id");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_pkey" PRIMARY KEY ("user_id");



CREATE INDEX "idx_menu_category_active" ON "boteco_simpsons_na_lama_9sd35"."menu_category" USING "btree" ("active");



CREATE INDEX "idx_menu_item_category" ON "boteco_simpsons_na_lama_9sd35"."menu_item" USING "btree" ("menu_category_id");



CREATE INDEX "idx_menu_item_visible" ON "boteco_simpsons_na_lama_9sd35"."menu_item" USING "btree" ("visible");



CREATE INDEX "idx_order_item_order" ON "boteco_simpsons_na_lama_9sd35"."order_item" USING "btree" ("order_id");



CREATE INDEX "idx_order_session" ON "boteco_simpsons_na_lama_9sd35"."order" USING "btree" ("pos_session_id");



CREATE INDEX "idx_order_status" ON "boteco_simpsons_na_lama_9sd35"."order" USING "btree" ("status");



CREATE INDEX "idx_order_table" ON "boteco_simpsons_na_lama_9sd35"."order" USING "btree" ("table_id");



CREATE INDEX "idx_payment_method" ON "boteco_simpsons_na_lama_9sd35"."payment" USING "btree" ("method");



CREATE INDEX "idx_payment_order" ON "boteco_simpsons_na_lama_9sd35"."payment" USING "btree" ("order_id");



CREATE UNIQUE INDEX "idx_payment_summary_unique_session" ON "boteco_simpsons_na_lama_9sd35"."payment_summary" USING "btree" ("pos_session_id");



CREATE INDEX "idx_pos_session_staff" ON "boteco_simpsons_na_lama_9sd35"."pos_session" USING "btree" ("staff_id");



CREATE INDEX "idx_pos_session_status" ON "boteco_simpsons_na_lama_9sd35"."pos_session" USING "btree" ("status");



CREATE INDEX "idx_product_active" ON "boteco_simpsons_na_lama_9sd35"."product" USING "btree" ("active");



CREATE INDEX "idx_product_category" ON "boteco_simpsons_na_lama_9sd35"."product" USING "btree" ("product_category_id");



CREATE INDEX "idx_product_category_active" ON "boteco_simpsons_na_lama_9sd35"."product_category" USING "btree" ("active");



CREATE INDEX "idx_recipe_active" ON "boteco_simpsons_na_lama_9sd35"."recipe" USING "btree" ("active");



CREATE INDEX "idx_recipe_product_recipe" ON "boteco_simpsons_na_lama_9sd35"."recipe_product" USING "btree" ("recipe_id");



CREATE INDEX "idx_boteco_slug" ON "public"."boteco" USING "btree" ("slug");



CREATE INDEX "idx_user_boteco_boteco" ON "public"."user_boteco" USING "btree" ("boteco_id");



CREATE INDEX "idx_user_boteco_user" ON "public"."user_boteco" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "trg_menu_category_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."menu_category" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_menu_item_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."menu_item" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_order_item_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."order_item" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_order_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."order" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_payment_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."payment" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_pos_session_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."pos_session" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_product_category_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."product_category" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_product_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."product" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_recipe_product_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."recipe_product" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_recipe_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."recipe" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_table_updated" BEFORE UPDATE ON "boteco_simpsons_na_lama_9sd35"."table_entity" FOR EACH ROW EXECUTE FUNCTION "boteco_simpsons_na_lama_9sd35"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_public_boteco_updated" BEFORE UPDATE ON "public"."boteco" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_public_user_boteco_updated" BEFORE UPDATE ON "public"."user_boteco" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_public_user_updated" BEFORE UPDATE ON "public"."user" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trg_update_jwt_claims" AFTER INSERT OR DELETE OR UPDATE ON "public"."user_boteco" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_update_jwt_claims"();



CREATE OR REPLACE TRIGGER "trg_update_jwt_on_user_create" AFTER INSERT ON "public"."user" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_update_jwt_claims"();



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."menu_item"
    ADD CONSTRAINT "fk_menu_item_category" FOREIGN KEY ("menu_category_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."menu_category"("menu_category_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."order_item"
    ADD CONSTRAINT "fk_order_item_menu_item" FOREIGN KEY ("menu_item_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."menu_item"("menu_item_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."order_item"
    ADD CONSTRAINT "fk_order_item_order" FOREIGN KEY ("order_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."order"("order_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."order"
    ADD CONSTRAINT "fk_order_session" FOREIGN KEY ("pos_session_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."pos_session"("pos_session_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."order"
    ADD CONSTRAINT "fk_order_table" FOREIGN KEY ("table_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."table_entity"("table_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."payment"
    ADD CONSTRAINT "fk_payment_order" FOREIGN KEY ("order_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."order"("order_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."payment"
    ADD CONSTRAINT "fk_payment_session" FOREIGN KEY ("pos_session_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."pos_session"("pos_session_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."payment_summary"
    ADD CONSTRAINT "fk_payment_summary_session" FOREIGN KEY ("pos_session_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."pos_session"("pos_session_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."product"
    ADD CONSTRAINT "fk_product_category" FOREIGN KEY ("product_category_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."product_category"("product_category_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."recipe"
    ADD CONSTRAINT "fk_recipe_menu_item" FOREIGN KEY ("menu_item_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."menu_item"("menu_item_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."recipe_product"
    ADD CONSTRAINT "fk_recipe_product_product" FOREIGN KEY ("product_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."product"("product_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "boteco_simpsons_na_lama_9sd35"."recipe_product"
    ADD CONSTRAINT "fk_recipe_product_recipe" FOREIGN KEY ("recipe_id") REFERENCES "boteco_simpsons_na_lama_9sd35"."recipe"("recipe_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."boteco"
    ADD CONSTRAINT "fk_boteco_owner" FOREIGN KEY ("owner_user_id") REFERENCES "public"."user"("user_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."user_boteco"
    ADD CONSTRAINT "fk_user_boteco_boteco" FOREIGN KEY ("boteco_id") REFERENCES "public"."boteco"("boteco_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_boteco"
    ADD CONSTRAINT "fk_user_boteco_user" FOREIGN KEY ("user_id") REFERENCES "public"."user"("user_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE "boteco_simpsons_na_lama_9sd35"."menu_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."menu_item" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."order" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."order_item" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "p_delete_menu_category_admin_only" ON "boteco_simpsons_na_lama_9sd35"."menu_category" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_menu_item_admin_only" ON "boteco_simpsons_na_lama_9sd35"."menu_item" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_order_admin_only" ON "boteco_simpsons_na_lama_9sd35"."order" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_order_item_admin_only" ON "boteco_simpsons_na_lama_9sd35"."order_item" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_payment_admin_only" ON "boteco_simpsons_na_lama_9sd35"."payment" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_payment_summary_admin_only" ON "boteco_simpsons_na_lama_9sd35"."payment_summary" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_pos_session_admin_only" ON "boteco_simpsons_na_lama_9sd35"."pos_session" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_product_admin_only" ON "boteco_simpsons_na_lama_9sd35"."product" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_product_category_admin_only" ON "boteco_simpsons_na_lama_9sd35"."product_category" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_recipe_admin_only" ON "boteco_simpsons_na_lama_9sd35"."recipe" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_recipe_product_admin_only" ON "boteco_simpsons_na_lama_9sd35"."recipe_product" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_delete_table_entity_admin_only" ON "boteco_simpsons_na_lama_9sd35"."table_entity" FOR DELETE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_admin"());



CREATE POLICY "p_insert_menu_category_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."menu_category" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_menu_item_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."menu_item" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_order_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."order" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_order_item_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."order_item" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_payment_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."payment" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_payment_summary_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."payment_summary" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_pos_session_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."pos_session" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_product_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."product" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_product_category_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."product_category" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_recipe_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."recipe" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_recipe_product_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."recipe_product" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_insert_table_entity_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."table_entity" FOR INSERT WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_menu_category_staff" ON "boteco_simpsons_na_lama_9sd35"."menu_category" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_menu_item_staff" ON "boteco_simpsons_na_lama_9sd35"."menu_item" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_order_item_staff" ON "boteco_simpsons_na_lama_9sd35"."order_item" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_order_staff" ON "boteco_simpsons_na_lama_9sd35"."order" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_payment_staff" ON "boteco_simpsons_na_lama_9sd35"."payment" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_payment_summary_staff" ON "boteco_simpsons_na_lama_9sd35"."payment_summary" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_pos_session_staff" ON "boteco_simpsons_na_lama_9sd35"."pos_session" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_product_category_staff" ON "boteco_simpsons_na_lama_9sd35"."product_category" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_product_staff" ON "boteco_simpsons_na_lama_9sd35"."product" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_recipe_product_staff" ON "boteco_simpsons_na_lama_9sd35"."recipe_product" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_recipe_staff" ON "boteco_simpsons_na_lama_9sd35"."recipe" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_select_table_entity_staff" ON "boteco_simpsons_na_lama_9sd35"."table_entity" FOR SELECT USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_menu_category_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."menu_category" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_menu_item_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."menu_item" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_order_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."order" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_order_item_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."order_item" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_payment_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."payment" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_payment_summary_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."payment_summary" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_pos_session_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."pos_session" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_product_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."product" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_product_category_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."product_category" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_recipe_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."recipe" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_recipe_product_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."recipe_product" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



CREATE POLICY "p_update_table_entity_admin_or_member" ON "boteco_simpsons_na_lama_9sd35"."table_entity" FOR UPDATE USING ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"()) WITH CHECK ("boteco_simpsons_na_lama_9sd35"."current_user_is_staff"());



ALTER TABLE "boteco_simpsons_na_lama_9sd35"."payment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."payment_summary" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."pos_session" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."product" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."product_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."recipe" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."recipe_product" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "boteco_simpsons_na_lama_9sd35"."table_entity" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."boteco" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "boteco_delete_none" ON "public"."boteco" FOR DELETE USING (false);



CREATE POLICY "boteco_insert_none" ON "public"."boteco" FOR INSERT WITH CHECK (false);



CREATE POLICY "boteco_select_if_staff" ON "public"."boteco" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_boteco" "ub"
  WHERE (("ub"."boteco_id" = "boteco"."boteco_id") AND ("ub"."user_id" = "auth"."uid"()) AND ("ub"."active" = true)))));



CREATE POLICY "boteco_update_if_admin" ON "public"."boteco" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."user_boteco" "ub"
  WHERE (("ub"."boteco_id" = "boteco"."boteco_id") AND ("ub"."user_id" = "auth"."uid"()) AND ("ub"."role" = 'admin'::"text") AND ("ub"."active" = true)))));



ALTER TABLE "public"."user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_boteco" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_boteco_mutation_none" ON "public"."user_boteco" USING (false) WITH CHECK (false);



CREATE POLICY "user_boteco_read_related" ON "public"."user_boteco" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "user_delete_none" ON "public"."user" FOR DELETE USING (false);



CREATE POLICY "user_insert_none" ON "public"."user" FOR INSERT WITH CHECK (false);



CREATE POLICY "user_select_own" ON "public"."user" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "user_update_own" ON "public"."user" FOR UPDATE USING (("auth"."uid"() = "user_id"));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "boteco_simpsons_na_lama_9sd35" TO "authenticated";






REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT USAGE ON SCHEMA "public" TO "boteco";































































































































































GRANT ALL ON FUNCTION "public"."execute_sql"("sql" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."execute_sql"("sql" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."execute_sql"("sql" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."execute_sql"("sql" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_active_boteco"("user_uuid" "uuid") TO "postgres";
GRANT ALL ON FUNCTION "public"."get_user_active_boteco"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_active_boteco"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_active_boteco"("user_uuid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."normalize_slug"("raw_slug" "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."normalize_slug"("raw_slug" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."normalize_slug"("raw_slug" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."normalize_slug"("raw_slug" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "postgres";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_update_jwt_claims"() TO "postgres";
GRANT ALL ON FUNCTION "public"."trigger_update_jwt_claims"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_update_jwt_claims"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_update_jwt_claims"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_jwt_claims"("user_uuid" "uuid") TO "postgres";
GRANT ALL ON FUNCTION "public"."update_jwt_claims"("user_uuid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_jwt_claims"("user_uuid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_jwt_claims"("user_uuid" "uuid") TO "service_role";












GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."menu_category" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."menu_category" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."menu_item" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."menu_item" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."order" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."order" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."order_item" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."order_item" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."payment" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."payment" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."payment_summary" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."payment_summary" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."pos_session" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."pos_session" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."product" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."product" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."product_category" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."product_category" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."recipe" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."recipe" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."recipe_product" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."recipe_product" TO "service_role";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "boteco_simpsons_na_lama_9sd35"."table_entity" TO "authenticated";
GRANT ALL ON TABLE "boteco_simpsons_na_lama_9sd35"."table_entity" TO "service_role";









GRANT ALL ON TABLE "public"."boteco" TO "postgres";
GRANT ALL ON TABLE "public"."boteco" TO "anon";
GRANT ALL ON TABLE "public"."boteco" TO "authenticated";
GRANT ALL ON TABLE "public"."boteco" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."boteco" TO "boteco";



GRANT ALL ON TABLE "public"."user" TO "postgres";
GRANT ALL ON TABLE "public"."user" TO "anon";
GRANT ALL ON TABLE "public"."user" TO "authenticated";
GRANT ALL ON TABLE "public"."user" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user" TO "boteco";



GRANT ALL ON TABLE "public"."user_boteco" TO "postgres";
GRANT ALL ON TABLE "public"."user_boteco" TO "anon";
GRANT ALL ON TABLE "public"."user_boteco" TO "authenticated";
GRANT ALL ON TABLE "public"."user_boteco" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."user_boteco" TO "boteco";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































