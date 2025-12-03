// ============================================================
// provision-boteco Edge Function
// Cria empresa + schema + seed + RLS multitenant
// ============================================================

import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// =========================
// Load SQL templates
// =========================

const template002 = await Deno.readTextFile(
  `${Deno.cwd()}/supabase/functions/provision-boteco/template-002.sql`
);

const template003 = await Deno.readTextFile(
  `${Deno.cwd()}/supabase/functions/provision-boteco/template-003.sql`
);

const template006 = await Deno.readTextFile(
  `${Deno.cwd()}/supabase/functions/provision-boteco/template-006.sql`
);


// =========================
// Function Handler
// =========================

serve(async (req: Request) => {
  try {
    // --------------------------------------
    // Validate auth
    // --------------------------------------
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response("Missing Authorization", { status: 401 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, // service role (required)
      {
        global: { headers: { Authorization: authHeader } },
      }
    );

    const { data: user, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return new Response("Invalid or missing user", { status: 401 });
    }

    const body = await req.json();
    const { name, slug, owner_user_id } = body;

    if (!name || !slug || !owner_user_id) {
      return new Response("Missing required fields", { status: 400 });
    }

    if (user.user.id !== owner_user_id) {
      return new Response("Unauthorized: owner_user_id mismatch", {
        status: 403,
      });
    }

    // --------------------------------------
    // Derive schema_name
    // --------------------------------------
    const normalizedSlug = slug.toLowerCase().replace(/[^a-z0-9_]/g, "_");
    const schemaName = `boteco_${normalizedSlug}`;

    // --------------------------------------
    // Call SQL procedure to create entries + schema
    // --------------------------------------
    const { error: procError } = await supabase.rpc(
      "create_boteco_schema",
      {
        owner_user_id,
        slug,
        name,
      }
    );

    if (procError) {
      console.error(procError);
      return new Response("Failed at create_boteco_schema", { status: 500 });
    }

    // ---------------------------------------------------------------------
    // Apply schema template (002)
    // ---------------------------------------------------------------------
    const sql002 = template002
      .replace(/{{schema_name}}/g, schemaName)
      .replace(/{{slug}}/g, normalizedSlug);

    const { error: schemaError } = await supabase.rpc("execute_sql", {
      sql: sql002,
    });

    if (schemaError) {
      console.error(schemaError);
      return new Response("Failed applying schema template", {
        status: 500,
      });
    }

    // ---------------------------------------------------------------------
    // Apply seeds (003)
    // ---------------------------------------------------------------------
    const sql003 = template003.replace(/{{schema_name}}/g, schemaName);

    const { error: seedError } = await supabase.rpc("execute_sql", {
      sql: sql003,
    });

    if (seedError) {
      console.error(seedError);
      return new Response("Failed applying seed template", {
        status: 500,
      });
    }

    // ---------------------------------------------------------------------
    // Apply RLS (006)
    // ---------------------------------------------------------------------
    const sql006 = template006
      .replace(/{{schema_name}}/g, schemaName)
      .replace(/{{slug}}/g, normalizedSlug);

    const { error: rlsError } = await supabase.rpc("execute_sql", {
      sql: sql006,
    });

    if (rlsError) {
      console.error(rlsError);
      return new Response("Failed applying RLS policies", {
        status: 500,
      });
    }

    // ----------------------------------------------------------
    // Done!
    // ----------------------------------------------------------
    return new Response(
      JSON.stringify({
        success: true,
        message: `Boteco '${name}' created successfully`,
        slug: normalizedSlug,
        schema: schemaName,
      }),
      { status: 200 }
    );
  } catch (err) {
    console.error(err);
    return new Response("Unexpected error", { status: 500 });
  }
});
