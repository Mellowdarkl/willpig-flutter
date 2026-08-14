# WillPig Flutter

Cliente de WillPig con autenticación, sesión segura y acceso a libros mediante
una API REST. La aplicación no se conecta directamente a la base de datos.

## Ejecutar

```powershell
Copy-Item .env.example .env
# Edita .env y define la URL de tu API.
flutter pub get
flutter run
```

La especificación de las rutas y las respuestas esperadas está en
[`API_CONTRACT.md`](API_CONTRACT.md). No subas tokens, URL privadas o claves de
la base de datos al repositorio.

Para despliegues se puede reemplazar el valor de `.env` sin editar archivos:

```powershell
flutter run --dart-define=API_BASE_URL=https://tu-dominio/api
```

En Windows, `flutter_secure_storage` necesita el modo desarrollador habilitado
para crear enlaces simbólicos. Si Flutter lo solicita, actívalo en
**Configuración > Para desarrolladores > Modo de desarrollador** y vuelve a
ejecutar `flutter pub get`.
