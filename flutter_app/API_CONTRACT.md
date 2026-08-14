# Contrato de API de WillPig

La app Flutter no debe conectarse directamente a la base de datos. La API debe
ser el único componente con acceso a sus credenciales y aplicar autorización,
validación y migraciones en el servidor.

Inicie la app configurando la URL del backend:

```powershell
flutter run --dart-define=API_BASE_URL=https://tu-dominio/api
```

Endpoints que consume el cliente:

| Método | Ruta | Cuerpo | Respuesta exitosa |
| --- | --- | --- | --- |
| POST | `/auth/login` | `email`, `password` | `{ "token": "jwt", "user": { "id", "name", "email" } }` |
| POST | `/auth/register` | `name`, `email`, `password` | Igual a login |
| GET | `/books` | — | `[book]` o `{ "data": [book] }` |
| POST | `/books` | `title`, `author`, `category?` | `book` o `{ "data": book }` |

Todas las rutas de libros requieren `Authorization: Bearer <token>`. Si el
backend actual de WillPig usa nombres o rutas distintos, adapte **solo**
`lib/services/auth_service.dart` y `lib/services/book_service.dart`; las
pantallas no necesitan conocer SQL ni detalles de transporte.
