class Capitulo {
  const Capitulo({
    required this.id,
    required this.titulo,
    required this.contenido,
  });

  final String id;
  final String titulo;
  final String contenido;

  factory Capitulo.fromJson(Map<String, dynamic> json) {
    return Capitulo(
      id: json['id_capitulo']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? 'Sin título',
      contenido: json['contenido']?.toString() ?? '',
    );
  }
}
