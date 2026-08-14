class Cuento {
  const Cuento({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.portadaUrl,
    this.autor,
    this.autorAvatarUrl,
    this.categoria,
    this.vistas = 0,
  });
  final String id;
  final String titulo;
  final String? descripcion;
  final String? portadaUrl;
  final String? autor;
  final String? autorAvatarUrl;
  final String? categoria;
  final int vistas;

  factory Cuento.fromJson(Map<String, dynamic> json) {
    final account = json['cuenta_usuario'] as Map<String, dynamic>?;
    final category = json['categorias'] as Map<String, dynamic>?;
    return Cuento(
      id: json['id_cuento'].toString(),
      titulo: json['titulo']?.toString() ?? 'Sin título',
      descripcion: json['descripcion']?.toString(),
      portadaUrl: json['portada_url']?.toString(),
      autor: account?['username']?.toString(),
      autorAvatarUrl: account?['avatar_url']?.toString(),
      categoria: category?['nombre']?.toString(),
      vistas: (json['vistas'] as num?)?.toInt() ?? 0,
    );
  }
}
