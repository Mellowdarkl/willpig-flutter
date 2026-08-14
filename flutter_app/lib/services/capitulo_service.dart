import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/capitulo.dart';

class CapituloService {
  CapituloService(this._client);
  final SupabaseClient _client;

  Future<List<Capitulo>> fetchCapitulos(String cuentoId) async {
    final rows = await _client
        .from('capitulos')
        .select('id_capitulo, titulo, contenido')
        .eq('cuento_id', cuentoId)
        .order('created_at', ascending: true);
    
    return (rows as List).map((row) => Capitulo.fromJson(row)).toList();
  }
}
