-- Sincroniza usuarios creados en Supabase Auth con la tabla existente
-- public.cuenta_usuario. No crea ni modifica tablas.
-- Ejecutar una sola vez desde Supabase SQL Editor con permisos de administrador.

create or replace function public.sync_auth_user_to_cuenta_usuario()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  lector_role_id public.roles_usuario.id%type;
  activa_state_id public.estados_usuario.id%type;
  generated_username text;
begin
  select id into lector_role_id
  from public.roles_usuario
  where lower(nombre) = 'lector'
  limit 1;

  select id into activa_state_id
  from public.estados_usuario
  where lower(nombre) = 'activa'
  limit 1;

  generated_username := coalesce(
    new.raw_user_meta_data ->> 'username',
    split_part(new.email, '@', 1)
  );

  insert into public.cuenta_usuario (
    username, email, clave, rol, estado, rol_id, estado_id
  ) values (
    generated_username, new.email, '', 'lector', 'activa',
    lector_role_id, activa_state_id
  ) on conflict (email) do nothing;

  return new;
end;
$$;

-- Sincroniza también los usuarios que ya existían antes del trigger.
insert into public.cuenta_usuario (
  username, email, clave, rol, estado, rol_id, estado_id
)
select
  coalesce(u.raw_user_meta_data ->> 'username', split_part(u.email, '@', 1)),
  u.email,
  '',
  'lector',
  'activa',
  (select id from public.roles_usuario where lower(nombre) = 'lector' limit 1),
  (select id from public.estados_usuario where lower(nombre) = 'activa' limit 1)
from auth.users u
left join public.cuenta_usuario c on c.email = u.email
where c.email is null and u.email is not null;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  when ((new.raw_user_meta_data ->> 'source') = 'mobile')
  execute procedure public.sync_auth_user_to_cuenta_usuario();
