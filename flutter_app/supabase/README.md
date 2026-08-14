# Sincronización de usuarios

Ejecuta `migrations/20260805_sync_auth_users_to_cuenta_usuario.sql` en el SQL
Editor de Supabase. El trigger inserta el perfil faltante en
`cuenta_usuario` cada vez que Flutter crea un usuario móvil. El proyecto web
ya inserta ese perfil por su cuenta, por lo que el trigger se limita a
usuarios con `raw_user_meta_data.source = 'mobile'`.

No sincroniza `cuenta_credenciales`: su `clave_hash` es usado por el login web
con bcrypt y nunca debe ser generado o expuesto desde Flutter.
