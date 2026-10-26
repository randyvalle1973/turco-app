import 'package:flutter/foundation.dart';

import '../data/peluqueria_repository.dart';
import '../models/turno.dart';

class TurnoViewModel extends ChangeNotifier {
  final PeluqueriaRepository _repository;

  TurnoViewModel({PeluqueriaRepository? repository})
    : _repository = repository ?? PeluqueriaRepository();

  List<Turno> _turnos = [];

  List<Turno> get turnos => List.unmodifiable(_turnos);

  void cargarTurnos() {
    _turnos = List<Turno>.from(_repository.obtenerTurnos());
    notifyListeners();
  }

  bool agregarTurno(Turno nuevoTurno) {
    _turnos = List<Turno>.from(_repository.obtenerTurnos());

    if (nuevoTurno.estado == EstadoTurno.programado &&
        hayConflicto(nuevoTurno)) {
      return false;
    }

    _repository.agregarTurno(nuevoTurno);
    _actualizarLista();
    return true;
  }

  bool editarTurno(Turno turnoActualizado) {
    _turnos = List<Turno>.from(_repository.obtenerTurnos());

    final indice = _turnos.indexWhere(
      (turno) => turno.id == turnoActualizado.id,
    );

    if (indice == -1) return false;

    final original = _turnos[indice];

    if (original.estado != EstadoTurno.programado) return false;

    final turnoFinal = Turno(
      id: original.id,
      clienteId: turnoActualizado.clienteId,
      estilistaId: turnoActualizado.estilistaId,
      serviciosIds: turnoActualizado.serviciosIds,
      fecha: turnoActualizado.fecha,
      horaInicio: turnoActualizado.horaInicio,
      horaFin: turnoActualizado.horaFin,
      notas: turnoActualizado.notas,
      estado: EstadoTurno.programado,
      fechaCreacion: original.fechaCreacion,
      fechaModificacion: DateTime.now(),
    );

    if (hayConflicto(turnoFinal, excluirId: original.id)) {
      return false;
    }

    _repository.actualizarTurno(turnoFinal);
    _actualizarLista();
    return true;
  }

  bool hayConflicto(Turno nuevoTurno, {String? excluirId}) {
    if (nuevoTurno.estado != EstadoTurno.programado) return false;

    final inicioNuevo = _minutos(nuevoTurno.horaInicio);
    final finNuevo = _minutos(nuevoTurno.horaFin);

    if (finNuevo <= inicioNuevo) return true;

    for (final existente in _turnos) {
      if (existente.id == excluirId) continue;
      if (existente.estado != EstadoTurno.programado) continue;

      final mismoDia =
          existente.fecha.year == nuevoTurno.fecha.year &&
          existente.fecha.month == nuevoTurno.fecha.month &&
          existente.fecha.day == nuevoTurno.fecha.day;

      if (!mismoDia) continue;

      final inicioExistente = _minutos(existente.horaInicio);
      final finExistente = _minutos(existente.horaFin);

      final seCruzan = inicioNuevo < finExistente && finNuevo > inicioExistente;

      if (seCruzan &&
          (existente.estilistaId == nuevoTurno.estilistaId ||
              existente.clienteId == nuevoTurno.clienteId)) {
        return true;
      }
    }

    return false;
  }

  bool completarTurno(String id) {
    return _cambiarEstado(id, EstadoTurno.completado);
  }

  bool cancelarTurno(String id) {
    return _cambiarEstado(id, EstadoTurno.cancelado);
  }

  bool _cambiarEstado(String id, EstadoTurno estado) {
    _turnos = List<Turno>.from(_repository.obtenerTurnos());

    final indice = _turnos.indexWhere((turno) => turno.id == id);
    if (indice == -1) return false;

    final turno = _turnos[indice];
    if (turno.estado != EstadoTurno.programado) return false;

    final actualizado = Turno(
      id: turno.id,
      clienteId: turno.clienteId,
      estilistaId: turno.estilistaId,
      serviciosIds: turno.serviciosIds,
      fecha: turno.fecha,
      horaInicio: turno.horaInicio,
      horaFin: turno.horaFin,
      notas: turno.notas,
      estado: estado,
      fechaCreacion: turno.fechaCreacion,
      fechaModificacion: DateTime.now(),
    );

    _repository.actualizarTurno(actualizado);
    _actualizarLista();
    return true;
  }

  void _actualizarLista() {
    _turnos = List<Turno>.from(_repository.obtenerTurnos());
    notifyListeners();
  }

  int _minutos(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }
}
