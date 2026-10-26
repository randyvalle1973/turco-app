class Cliente {
  final String id;
  final String nombre;
  final String telefono;
  final GeneroCliente genero;
  final String? correo;
  final DateTime fechaRegistro;

  Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.genero,
    this.correo,
    required this.fechaRegistro,
  });
}

enum GeneroCliente { mujer, hombre }
