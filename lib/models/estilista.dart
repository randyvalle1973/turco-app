class Estilista {
  final String id;
  final String nombre;
  final String avatar;
  final List<String> serviciosIds;
  final PublicoEstilista publico;

  Estilista({
    required this.id,
    required this.nombre,
    required this.avatar,
    required this.serviciosIds,
    required this.publico,
  });
}

enum PublicoEstilista { mujer, hombre, ambos }
