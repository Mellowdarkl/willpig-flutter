# Sincronización de usuarios

Ejecuta `migrations/20260805_sync_auth_users_to_cuenta_usuario.sql` en el SQL
Editor de Supabase. El trigger inserta el perfil faltante en
`cuenta_usuario` cada vez que Flutter crea un usuario móvil. El proyecto web
ya inserta ese perfil por su cuenta, por lo que el trigger se limita a
usuarios con `raw_user_meta_data.source = 'mobile'`.

No sincroniza `cuenta_credenciales`: su `clave_hash` es usado por el login web
con bcrypt y nunca debe ser generado o expuesto desde Flutter.

## Migración de cuentas Web al inicio de sesión móvil

Ejecuta también `migrations/20260909_legacy_mobile_login.sql` y despliega
`functions/legacy-mobile-login`. Configura **solo en secretos de Edge
Functions** `SUPABASE_SERVICE_ROLE_KEY` (nunca en Flutter ni en `.env`). La
función usa la RPC para validar bcrypt sin devolver `clave_hash`, crea el
usuario en Auth con el correo confirmado y deja el token exclusivamente en la
segunda llamada de Flutter a GoTrue.

Las cuentas ya creadas por móvil no se modifican: una colisión de correo solo
se resuelve manualmente. Los logs de la función contienen un `request_id` y un
código operativo, pero no correo, contraseña, hash, clave de servicio ni JWT.

### Diagnóstico operativo

La respuesta al APK es siempre genérica para no convertir este endpoint en un
enumerador de cuentas. Busca el `request_id` en los logs de Edge Functions y
usa únicamente estos códigos: `web_user_not_found`, `hash_not_found`,
`bcrypt_mismatch`, `LEGACY_RPC_PERMISSION_OR_EXECUTION_ERROR`,
`SERVICE_ROLE_UNAVAILABLE_OR_INVALID`, `AUTH_LIST_USERS_ERROR`,
`AUTH_EMAIL_OWNED_BY_NON_LEGACY_ACCOUNT`, `AUTH_CREATE_ERROR` y
`AUTH_UPDATE_ERROR`. Si el proveedor Email está deshabilitado, GoTrue falla en
el segundo `signInWithPassword`; habilítalo antes de probar la migración.

### Pruebas manuales

1. Configure los secretos de la función y aplique la migración SQL. Verifique
   que el proveedor **Email** esté habilitado. No ponga la service role en la
   app ni en ningún archivo versionado.
2. Con una cuenta Web válida que no esté en `auth.users`, inicie sesión desde
   el APK: debe crearse una cuenta Auth confirmada, devolver `migrated: true`
   internamente y el segundo inicio de sesión debe abrir una sesión JWT.
3. Repita el mismo inicio de sesión: debe actualizar solo la cuenta marcada
   `legacy_mobile_migrated` y volver a obtener sesión.
4. Pruebe correo inexistente, credencial sin `clave_hash` y contraseña Web
   equivocada. Los logs deben diferenciar los tres códigos y el APK debe
   mostrar exactamente el mismo mensaje genérico.
5. Cree una cuenta móvil con un correo que también exista en las tablas Web.
   Con una contraseña equivocada, la función debe registrar
   `AUTH_EMAIL_OWNED_BY_NON_LEGACY_ACCOUNT`; confirme que la contraseña móvil
   no cambia. Con la contraseña móvil correcta, el primer login debe funcionar
   sin llamar a la función.
6. Pruebe un proyecto con más de 1,000 usuarios de Auth y una cuenta legacy en
   una página posterior. Debe encontrarse mediante paginación, no duplicarse.
