import 'package:flutter_test/flutter_test.dart';
import 'package:willpig/models/cuento.dart';

void main() {
  test('Cuento interpreta la fila existente de la tabla cuentos', () {
    final cuento = Cuento.fromJson({
      'id_cuento': 7,
      'titulo': 'El viaje',
      'descripcion': 'Contenido de prueba',
      'vistas': 3,
    });

    expect(cuento.id, '7');
    expect(cuento.titulo, 'El viaje');
    expect(cuento.vistas, 3);
  });
}
