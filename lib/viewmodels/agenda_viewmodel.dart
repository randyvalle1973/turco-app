import 'package:flutter/foundation.dart';

import '../data/datos_prueba.dart';
import '../data/peluqueria_repository.dart';
import '../models/turno.dart';

class AgendaViewModel extends ChangeNotifier {
  final PeluqueriaRepository _repository;

  AgendaViewModel({PeluqueriaRepository? repository})
    : _repository = repository ?? PeluqueriaRepository();

  List<Turno> _turnos = [];
  DateTime _fechaSeleccionada = DateTime.now();
  String? _estilistaIdSeleccionado;
  EstadoTurno? _estadoSeleccionado;

  List<Turno> get turnos => List.unmodifiable(_turnos);

  DateTime get fechaSeleccionada => _fechaSeleccionada;

  String? get estilistaIdSeleccionado => _estilistaIdSeleccionado;

  EstadoTurno? get estadoSeleccionado => _estadoSeleccionado;

  void cargarTurnos() {
    _turnos = List<Turno>.from(_repository.obtenerTurnos());
    notifyListeners();
  }

  void seleccionarFecha(DateTime fecha) {
    _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day);
    notifyListeners();
  }

  void seleccionarEstilista(String? estilistaId) {
    _estilistaIdSeleccionado = estilistaId;
    notifyListeners();
  }

  void seleccionarEstado(EstadoTurno? estado) {
    _estadoSeleccionado = estado;
    notifyListeners();
  }

  List<Turno> get turnosDelDia {
    final resultado = _turnos.where((turno) {
      return turno.fecha.year == _fechaSeleccionada.year &&
          turno.fecha.month == _fechaSeleccionada.month &&
          turno.fecha.day == _fechaSeleccionada.day;
    }).toList();

    resultado.sort(
      (a, b) => _minutos(a.horaInicio).compareTo(_minutos(b.horaInicio)),
    );

    return resultado;
  }

  List<Turno> get turnosFiltrados {
    return turnosDelDia.where((turno) {
      final coincideEstilista =
          _estilistaIdSeleccionado == null ||
          turno.estilistaId == _estilistaIdSeleccionado;

      final coincideEstado =
          _estadoSeleccionado == null || turno.estado == _estadoSeleccionado;

      return coincideEstilista && coincideEstado;
    }).toList();
  }

  int get cantidadProgramados => turnosDelDia
      .where((turno) => turno.estado == EstadoTurno.programado)
      .length;

  int get cantidadCompletados => turnosDelDia
      .where((turno) => turno.estado == EstadoTurno.completado)
      .length;

  double get ingresosEstimados {
    var total = 0.0;

    for (final turno in turnosDelDia) {
      if (turno.estado == EstadoTurno.cancelado) {
        continue;
      }

      for (final idServicio in turno.serviciosIds) {
        final servicios = DatosPrueba.servicios.where(
          (servicio) => servicio.id == idServicio,
        );

        if (servicios.isNotEmpty) {
          total += servicios.first.precio;
        }
      }
    }

    return total;
  }

  Turno? buscarTurno(String id) {
    for (final turno in _turnos) {
      if (turno.id == id) {
        return turno;
      }
    }

    return null;
  }

  void completarTurno(String id) {
    final turno = buscarTurno(id);

    if (turno == null || turno.estado != EstadoTurno.programado) {
      return;
    }

    final actualizado = Turno(
      id: turno.id,
      clienteId: turno.clienteId,
      estilistaId: turno.estilistaId,
      serviciosIds: turno.serviciosIds,
      fecha: turno.fecha,
      horaInicio: turno.horaInicio,
      horaFin: turno.horaFin,
      notas: turno.notas,
      estado: EstadoTurno.completado,
    );

    _repository.actualizarTurno(actualizado);
    cargarTurnos();
  }

  void cancelarTurno(String id) {
    final turno = buscarTurno(id);

    if (turno == null || turno.estado != EstadoTurno.programado) {
      return;
    }

    final actualizado = Turno(
      id: turno.id,
      clienteId: turno.clienteId,
      estilistaId: turno.estilistaId,
      serviciosIds: turno.serviciosIds,
      fecha: turno.fecha,
      horaInicio: turno.horaInicio,
      horaFin: turno.horaFin,
      notas: turno.notas,
      estado: EstadoTurno.cancelado,
    );

    _repository.actualizarTurno(actualizado);
    cargarTurnos();
  }

  int _minutos(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }

  int cantidadTurnosHoyEstilista(String estilistaId) {
    final hoy = DateTime.now();

    return _repository.obtenerTurnos().where((turno) {
      return turno.estilistaId == estilistaId &&
          turno.fecha.year == hoy.year &&
          turno.fecha.month == hoy.month &&
          turno.fecha.day == hoy.day &&
          turno.estado == EstadoTurno.programado;
    }).length;
  }
}
