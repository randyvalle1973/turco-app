class Turno {
  final String id;
  final String clienteId;
  final String estilistaId;
  final List<String> serviciosIds;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final String? notas;
  final EstadoTurno estado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required this.serviciosIds,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.notas,
    this.estado = EstadoTurno.programado,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now(),
       fechaModificacion = fechaModificacion ?? DateTime.now();
}

enum EstadoTurno { programado, completado, cancelado }
