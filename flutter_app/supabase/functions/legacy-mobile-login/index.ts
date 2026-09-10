import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type LegacyCheck = {
  result_code: string;
  canonical_email: string | null;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
    },
  });

const normaliseEmail = (value: unknown) =>
  typeof value === "string" ? value.trim().toLowerCase() : "";

const requestId = () => crypto.randomUUID();

// Only diagnostic codes are logged. In particular, never log email, password,
// bcrypt hash, service key, Auth response body, access token, or user id.
const diagnostic = (id: string, code: string) =>
  console.log(JSON.stringify({ event: "legacy_mobile_login", id, code }));

const isServiceRoleKey = (key: string) => {
  try {
    const payload = key.split(".")[1];
    if (!payload) return false;
    const base64 = payload.replace(/-/g, "+").replace(/_/g, "/");
    const padded = base64.padEnd(base64.length + (4 - (base64.length % 4)) % 4, "=");
    const decoded = JSON.parse(atob(padded));
    return decoded.role === "service_role";
  } catch (_) {
    // Si la clave no es un JWT estándar de Supabase (por ejemplo, formato sb_secret),
    // comprobamos que al menos exista y no sea vacía.
    return typeof key === "string" && key.length > 20;
  }
};

Deno.serve(async (request) => {
  // Manejo de preflight CORS (OPTIONS)
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const id = requestId();
  if (request.method !== "POST") return json({ migrated: false }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceRoleKey || !isServiceRoleKey(serviceRoleKey)) {
    diagnostic(id, "SERVICE_ROLE_UNAVAILABLE_OR_INVALID");
    return json({ migrated: false, request_id: id }, 500);
  }

  let body: { email?: unknown; password?: unknown };
  try {
    const text = await request.text();
    body = text ? JSON.parse(text) : {};
  } catch (_) {
    diagnostic(id, "INVALID_REQUEST_BODY_PARSE");
    return json({ migrated: false, request_id: id }, 400);
  }

  const email = normaliseEmail(body.email);
  const password = typeof body.password === "string" ? body.password : "";
  if (!email || !password || password.length > 1024) {
    diagnostic(id, "INVALID_REQUEST_CREDENTIALS_EMPTY");
    return json({ migrated: false, request_id: id }, 400);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  // This SECURITY DEFINER RPC checks bcrypt with pgcrypto and returns no hash.
  const { data, error } = await admin.rpc("validar_login_legacy_movil", {
    p_email: email,
    p_password: password,
  });
  if (error) {
    diagnostic(id, "LEGACY_RPC_PERMISSION_OR_EXECUTION_ERROR");
    return json({ migrated: false, request_id: id }, 500);
  }
  const result = Array.isArray(data) ? (data[0] as LegacyCheck | undefined) : undefined;
  if (!result || result.result_code !== "ok" || !result.canonical_email) {
    diagnostic(id, result?.result_code ?? "LEGACY_RPC_INVALID_RESPONSE");
    // Same public response for absent user, absent hash and password mismatch.
    return json({ migrated: false, request_id: id }, 401);
  }

  const canonicalEmail = result.canonical_email;
  const authUser = await findAuthUserByEmail(admin, canonicalEmail);
  if (authUser.error) {
    diagnostic(id, "AUTH_LIST_USERS_ERROR");
    return json({ migrated: false, request_id: id }, 500);
  }

  if (authUser.user) {
    const appMetadata = authUser.user.app_metadata ?? {};
    const userMetadata = authUser.user.user_metadata ?? {};
    // An Auth account created by mobile is authoritative. Never replace its
    // password just because its email also appears in the legacy tables.
    if (userMetadata.source === "mobile" || appMetadata.legacy_mobile_migrated !== true) {
      diagnostic(id, "AUTH_EMAIL_OWNED_BY_NON_LEGACY_ACCOUNT");
      return json({ migrated: false, request_id: id }, 401);
    }
    const { error: updateError } = await admin.auth.admin.updateUserById(
      authUser.user.id,
      {
        password,
        email_confirm: true,
        app_metadata: { ...appMetadata, legacy_mobile_migrated: true },
      },
    );
    if (updateError) {
      diagnostic(id, "AUTH_UPDATE_ERROR");
      return json({ migrated: false, request_id: id }, 500);
    }
    diagnostic(id, "AUTH_LEGACY_USER_UPDATED");
    return json({ migrated: true, request_id: id });
  }

  const { error: createError } = await admin.auth.admin.createUser({
    email: canonicalEmail,
    password,
    email_confirm: true,
    app_metadata: { legacy_mobile_migrated: true },
  });
  if (createError) {
    // A concurrent request can claim the email between the paginated lookup
    // and creation. Do not overwrite the winner; make the caller retry once.
    diagnostic(id, "AUTH_CREATE_ERROR");
    return json({ migrated: false, request_id: id }, 500);
  }
  diagnostic(id, "AUTH_LEGACY_USER_CREATED");
  return json({ migrated: true, request_id: id });
});

async function findAuthUserByEmail(admin: ReturnType<typeof createClient>, email: string) {
  // GoTrue has no get-user-by-email admin endpoint. listUsers is paginated;
  // searching only its first page is the source of false "migrated" results.
  const perPage = 1000;
  for (let page = 1; ; page += 1) {
    const { data, error } = await admin.auth.admin.listUsers({ page, perPage });
    if (error) return { user: null, error };
    const users = data.users;
    const user = users.find((candidate) => candidate.email?.toLowerCase() === email);
    if (user) return { user, error: null };
    if (users.length < perPage) return { user: null, error: null };
  }
}
