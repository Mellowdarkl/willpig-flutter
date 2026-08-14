import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cuento.dart';

class CuentoService {
  CuentoService(this._client);
  final SupabaseClient _client;

  /// Columnas explícitas alineadas con el esquema Supabase de willpig_studio.
  /// La tabla usa `descripcion`, no `contenido` (ese campo vive en `capitulos`).
  static const _storySelect =
      'id_cuento,titulo,descripcion,portada_url,vistas,created_at,'
      'cuenta_usuario(id_cuenta_usuario,username,avatar_url),'
      'categorias(nombre)';

  Future<List<Cuento>> fetchCuentos() async {
    final rows = await _client
        .from('cuentos')
        .select(_storySelect)
        .isFilter('deleted_at', null)
        .eq('estado', 'publicado')
        .eq('visibilidad', 'publica')
        .order('created_at', ascending: false);

    return (rows as List).map((row) => Cuento.fromJson(row)).toList();
  }
}
