-- Validates legacy Web passwords without ever returning clave_hash to callers.
-- Run from the Supabase SQL Editor before deploying legacy-mobile-login.
create extension if not exists pgcrypto with schema extensions;

drop function if exists public.validar_login_legacy_movil(text, text);

create or replace function public.validar_login_legacy_movil(
  p_email text,
  p_password text
)
returns table(result_code text, canonical_email text)
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  legacy_user_id public.cuenta_usuario.id_cuenta_usuario%type;
  stored_email text;
  stored_hash text;
begin
  select u.id_cuenta_usuario, u.email
    into legacy_user_id, stored_email
  from public.cuenta_usuario u
  where lower(trim(u.email)) = lower(trim(p_email))
  limit 1;

  if legacy_user_id is null then
    return query select 'web_user_not_found'::text, null::text;
    return;
  end if;

  select c.clave_hash
    into stored_hash
  from public.cuenta_credenciales c
  where c.cuenta_usuario_id = legacy_user_id
    and nullif(trim(c.clave_hash), '') is not null
  limit 1;

  if stored_hash is null then
    return query select 'hash_not_found'::text, null::text;
    return;
  end if;

  -- pgcrypto natively uses $2a$ / $2bf$. If stored hash was generated with
  -- $2y$ (PHP) or $2b$ (Node bcrypt), normalize prefix to $2a$ for crypt().
  if extensions.crypt(p_password, regexp_replace(stored_hash, '^\$2[yb]\$', '$2a$')) <> regexp_replace(stored_hash, '^\$2[yb]\$', '$2a$') then
    return query select 'bcrypt_mismatch'::text, null::text;
    return;
  end if;

  return query select 'ok'::text, lower(trim(stored_email));
exception when others then
  -- Do not leak schema or crypt errors through the RPC response.
  return query select 'legacy_validation_error'::text, null::text;
end;
$$;

revoke all on function public.validar_login_legacy_movil(text, text) from public;
revoke all on function public.validar_login_legacy_movil(text, text) from anon;
revoke all on function public.validar_login_legacy_movil(text, text) from authenticated;
grant execute on function public.validar_login_legacy_movil(text, text) to service_role;
