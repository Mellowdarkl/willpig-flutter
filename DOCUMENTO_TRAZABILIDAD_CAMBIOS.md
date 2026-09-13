# Documento de Trazabilidad de Cambios e Historial de Modificaciones
**Proyecto:** Willpig Flutter  
**Repositorio:** `willpig-flutter`  
**Fecha de generación:** 13 de Septiembre de 2026  

---

## 1. Resumen Ejecutivo del Proyecto

El proyecto **Willpig Flutter** es una aplicación móvil y multiplataforma desarrollada en **Flutter / Dart** orientada a la lectura interactiva de cuentos y libros. El backend del sistema se apoya en **Supabase** para servicios de autenticación de usuarios, base de datos relacional y Edge Functions en TypeScript/Deno.

Este documento consolida la **trazabilidad completa de cambios** realizados en el código fuente, desde la inicialización de la estructura base hasta las optimizaciones de release, autenticación híbrida y configuración para producción.

---

## 2. Matriz de Trazabilidad de Modificaciones

| Identificador (SHA) | Fecha | Categoría | Componente / Área | Descripción Resumida |
| :--- | :--- | :--- | :--- | :--- |
| `8233197` | 2026-08-14 | `Initial` | Raíz | Inicialización del repositorio y estructura básica. |
| `9fec287` | 2026-08-14 | `Feat / Arch` | Core App / UI / Service | Creación de la arquitectura Flutter, pantalla de inicio, lector de cuentos, login, controladores de autenticación y scripts SQL iniciales de Supabase. |
| `671d9b1` | 2026-09-09 | `Fix` | Android Build | Corrección de error de compilación NDK ajustando `build.gradle.kts`. |
| `c662971` | 2026-09-09 | `Feat` | UI / Branding | Integración de `flutter_launcher_icons` y configuración de íconos personalizados para Android e iOS. |
| `6935f07` | 2026-09-09 | `Feat / UX` | UI (Login) | Botón toggle para mostrar/ocultar contraseña en `login_page.dart`. |
| `cf15b7c` | 2026-09-09 | `Feat / Auth` | Backend / Supabase | Integración de autenticación Supabase y Edge Function `legacy-mobile-login` para migración de usuarios. |
| `47d3af9` | 2026-09-09 | `Build` | Dependencias | Actualización de registradores de plugins por plataforma y `pubspec.lock`. |
| `59a0202` | 2026-09-09 | `Chore / Release` | Release / Build | Checksum SHA-1 del APK final y ajustes finales de launcher en Android y iOS Xcode. |

---

## 3. Detalle Desglosado por Hito y Modificación

### Hito 1: Inicialización del Repositorio y Arquitectura Base
- **Commits:** `8233197`, `9fec287`
- **Archivos Clave:**
  - `flutter_app/lib/main.dart`
  - `flutter_app/lib/config/api_config.dart`
  - `flutter_app/lib/services/auth_service.dart`
  - `flutter_app/lib/ui/login_page.dart`
  - `flutter_app/lib/ui/home_page.dart`
  - `flutter_app/lib/ui/story_read_page.dart`
  - `flutter_app/supabase/migrations/20260805_sync_auth_users_to_cuenta_usuario.sql`
- **Descripción:**
  - Se estructuró la aplicación en paquetes: `models`, `controllers`, `services`, `theme`, `ui` y `widgets`.
  - Se creó el tema visual `willpig_theme` con paleta oscura personalizada.
  - Se implementó la visualización de cuentos (`story_read_page.dart`) con soporte para renderizado HTML custom (`html_text.dart`).
  - Se creó la función de migración SQL inicial en Supabase para sincronizar registros de la tabla `auth.users` hacia `cuenta_usuario`.

---

### Hito 2: Corrección de Compilación Android (Gradle & NDK)
- **Commit:** `671d9b1`
- **Archivos Clave:**
  - `flutter_app/android/app/build.gradle.kts`
- **Descripción:**
  - Se deshabilitó la especificación explícita `ndkVersion` comentando la línea en `build.gradle.kts`, permitiendo que el plugin de Flutter determine dinámicamente la versión compatible de NDK, resolviendo bloqueos de build en Android.

---

### Hito 3: Personalización Gráfica y Branding (Launcher Icons)
- **Commit:** `c662971`
- **Archivos Clave:**
  - `flutter_app/pubspec.yaml`
  - `flutter_app/assets/images/app_icon.png`
  - Recurso Android `mipmap-*` / `drawable-*` / `colors.xml`
- **Descripción:**
  - Configuración del paquete `flutter_launcher_icons`.
  - Incorporación del logo oficial de la marca Willpig en las distintas resoluciones requeridas para Android (Adaptive Icons) y iOS (`AppIcon.appiconset`).

---

### Hito 4: Mejora en la Experiencia de Usuario (UX de Login)
- **Commit:** `6935f07`
- **Archivos Clave:**
  - `flutter_app/lib/ui/login_page.dart`
- **Descripción:**
  - Incorporación de un botón interactivo (`suffixIcon`) en el campo de contraseña.
  - Gestión del estado local `_isPasswordVisible` mediante un `IconButton` (`Icons.visibility` / `Icons.visibility_off`) para facilitar la verificación del texto introducido por el usuario.

---

### Hito 5: Migración de Autenticación y Supabase Edge Functions
- **Commit:** `cf15b7c`
- **Archivos Clave:**
  - `flutter_app/supabase/functions/legacy-mobile-login/index.ts`
  - `flutter_app/supabase/migrations/20260909_legacy_mobile_login.sql`
  - `flutter_app/lib/services/auth_service.dart`
- **Descripción:**
  - Se desplegó una Edge Function en Supabase denominada `legacy-mobile-login` para atender inicios de sesión de usuarios existentes en la base de datos previa (contraseñas hasheadas en SHA256).
  - Al autenticar un usuario legacy válido, la Edge Function crea el usuario en `auth.users` de Supabase, migrando sus credenciales de manera transparente.
  - En `auth_service.dart`, la aplicación primero consulta el login legacy vía HTTP/Edge Function y, en caso de fallar o ser usuario nativo de Supabase, utiliza la autenticación estándar (`supabase.auth.signInWithPassword`).

---

### Hito 6: Gestión de Dependencias y Plugins
- **Commit:** `47d3af9`
- **Archivos Clave:**
  - `flutter_app/pubspec.lock`
- **Descripción:**
  - Actualización y fijación de dependencias en `pubspec.lock` para garantizar la consistencia de paquetes entre entornos de desarrollo y sistemas de integración continua.

---

### Hito 7: Preparación y Aseguramiento de Release APK
- **Commit:** `59a0202`
- **Archivos Clave:**
  - `flutter_app/app-release.apk.sha1`
  - `flutter_app/android/app/src/main/AndroidManifest.xml`
  - `flutter_app/ios/Runner.xcodeproj/project.pbxproj`
- **Descripción:**
  - Generación e inclusión de la firma/hash `SHA-1` del archivo compilado `app-release.apk` para auditoría y verificación de integridad en la entrega de la aplicación.
  - Ajuste de categorías en `AndroidManifest.xml` e íconos finales de lanzamiento en iOS Xcode.

---

## 4. Estado Actual del Repositorio

- **Rama actual:** `udttstPass`
- **Estado de copia de trabajo:** Limpia (sin cambios pendientes por guardar).
- **Compilabilidad:** Configurada para Android SDK / Gradle y iOS Runner.

---

## 5. Conclusión y Recomendaciones Futuras

1. **Monitoreo de Migración:** Mantener la Edge Function `legacy-mobile-login` activa hasta completar la migración total de usuarios legacy.
2. **Firmado de Producción:** Asegurar el almacenamiento seguro del Keystore de Android y los certificados de aprovisionamiento de iOS para futuras actualizaciones.
3. **Control de Versiones:** Mantener etiquetas (`git tag`) formales al momento de publicar nuevas versiones en las tiendas App Store y Google Play.
