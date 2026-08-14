import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Solo configuración pública: nunca credenciales de PostgreSQL.
abstract final class ApiConfig {
  static String get supabaseUrl => dotenv.maybeGet('SUPABASE_URL') ?? '';
  static String get supabaseAnonKey =>
      dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

  /// Falla antes de renderizar la aplicación cuando falta la configuración
  /// pública necesaria para comunicarse con Supabase.
  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Falta SUPABASE_URL o SUPABASE_ANON_KEY en el archivo .env.',
      );
    }
    final uri = Uri.tryParse(supabaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('SUPABASE_URL no tiene un formato válido.');
    }
  }
}
