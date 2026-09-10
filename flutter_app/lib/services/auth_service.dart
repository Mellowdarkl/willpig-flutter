import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_session.dart';

class AuthService {
  AuthService(this._client);
  final SupabaseClient _client;
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _from(
        await _client.auth.signInWithPassword(email: email, password: password),
      );
    } on AuthException catch (error) {
      // Solo intentamos la migración después de la respuesta normal de GoTrue
      // para credenciales inválidas. No se debe usar la función como un login
      // alterno para errores de red, configuración o cuentas bloqueadas.
      if (!_isInvalidCredentials(error)) rethrow;
    }

    try {
      final response = await _client.functions.invoke(
        'legacy-mobile-login',
        body: {'email': email, 'password': password},
      );
      final body = response.data;
      if (body is! Map || body['migrated'] != true) {
        throw const LegacyMigrationException();
      }
      // La función nunca entrega tokens: la sesión se obtiene únicamente de
      // GoTrue mediante este segundo inicio de sesión.
      return await _from(
        await _client.auth.signInWithPassword(email: email, password: password),
      );
    } on LegacyMigrationException {
      rethrow;
    } on AuthException {
      // La migración se completó pero GoTrue no pudo iniciar sesión. No se
      // expone el motivo ni se convierte este flujo en un enumerador de emails.
      throw const LegacyMigrationException();
    } on FunctionException {
      throw const LegacyMigrationException();
    }
  }

  bool _isInvalidCredentials(AuthException error) =>
      error.code == 'invalid_credentials' ||
      error.message.toLowerCase().contains('invalid login credentials');
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      // El trigger de Supabase solo crea perfiles para registros móviles.
      data: {'username': name, 'source': 'mobile'},
    );
    // Cuando la confirmación de correo está activada, Supabase puede ocultar
    // usuarios existentes devolviendo una respuesta sin identidades.
    if (response.user?.identities?.isEmpty ?? false) {
      throw StateError(
        'Este correo ya está registrado. Inicia sesión o recupera tu contraseña.',
      );
    }
    return _from(response);
  }

  Future<AuthSession?> currentSession() async {
    final s = _client.auth.currentSession;
    return s == null ? null : _fromSession(s);
  }

  Future<void> logout() => _client.auth.signOut();

  /// Supabase envía el enlace de recuperación al correo ya registrado.
  Future<void> requestPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email);
  Future<AuthSession> _from(AuthResponse response) async {
    if (response.session == null) {
      throw StateError('Confirma tu correo antes de iniciar sesión.');
    }
    return _fromSession(response.session!);
  }

  Future<AuthSession> _fromSession(Session s) async {
    final email = s.user.email ?? '';
    Map<String, dynamic>? profile;
    try {
      profile = await _client
          .from('cuenta_usuario')
          .select('id_cuenta_usuario,username,email')
          .eq('email', email)
          .maybeSingle();
    } on PostgrestException {
      // El acceso al perfil depende de RLS; una política pendiente no debe
      // impedir que una sesión válida de Supabase llegue a la pantalla inicial.
    }
    return AuthSession(
      token: s.accessToken,
      user: AppUser(
        id: (profile?['id_cuenta_usuario'] ?? s.user.id).toString(),
        name: (profile?['username'] ?? s.user.userMetadata?['username'] ?? '')
            .toString(),
        email: email,
      ),
    );
  }
}

/// Mensaje deliberadamente genérico: los detalles quedan en los logs seguros
/// de la Edge Function, asociados a su identificador de correlación.
class LegacyMigrationException implements Exception {
  const LegacyMigrationException();

  @override
  String toString() =>
      'No fue posible iniciar sesión con ese correo o contraseña. Si el problema continúa, contacta a soporte.';
}
