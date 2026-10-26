import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/peluqueria_repository.dart';
import '../models/turno.dart';

class TurnoScreen extends StatefulWidget {
  final String? turnoId;

  const TurnoScreen({super.key, this.turnoId});

  @override
  State<TurnoScreen> createState() => _TurnoScreenState();
}

class _TurnoScreenState extends State<TurnoScreen> {
  final PeluqueriaRepository _repository = PeluqueriaRepository();

  Turno? get _turno {
    final id = widget.turnoId;
    if (id == null) return null;

    for (final turno in _repository.obtenerTurnos()) {
      if (turno.id == id) return turno;
    }
    return null;
  }

  String _nombreEstado(EstadoTurno estado) {
    switch (estado) {
      case EstadoTurno.programado:
        return 'Programado';
      case EstadoTurno.completado:
        return 'Completado';
      case EstadoTurno.cancelado:
        return 'Cancelado';
    }
  }

  Color _colorEstado(EstadoTurno estado) {
    switch (estado) {
      case EstadoTurno.programado:
        return Colors.blue;
      case EstadoTurno.completado:
        return Colors.green;
      case EstadoTurno.cancelado:
        return Colors.red;
    }
  }

  int _minutos(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }

  String _duracion(int minutos) {
    final horas = minutos ~/ 60;
    final resto = minutos % 60;

    if (horas == 0) return '$resto min';
    if (resto == 0) return '$horas h';
    return '$horas h $resto min';
  }

  String _fecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

  String _fechaHora(DateTime fecha) =>
      '${_fecha(fecha)} ${fecha.hour.toString().padLeft(2, '0')}:'
      '${fecha.minute.toString().padLeft(2, '0')}';

  Future<bool> _confirmar(String titulo, String mensaje) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Volver'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _cambiarEstado(EstadoTurno nuevoEstado) async {
    final turno = _turno;
    if (turno == null || turno.estado != EstadoTurno.programado) return;

    final completar = nuevoEstado == EstadoTurno.completado;
    final confirmado = await _confirmar(
      completar ? 'Completar cita' : 'Cancelar cita',
      completar
          ? '¿Confirmas que esta cita se ha completado?'
          : '¿Seguro que deseas cancelar esta cita?',
    );

    if (!confirmado || !mounted) return;

    final actualizado = Turno(
      id: turno.id,
      clienteId: turno.clienteId,
      estilistaId: turno.estilistaId,
      serviciosIds: turno.serviciosIds,
      fecha: turno.fecha,
      horaInicio: turno.horaInicio,
      horaFin: turno.horaFin,
      notas: turno.notas,
      estado: nuevoEstado,
      fechaCreacion: turno.fechaCreacion,
      fechaModificacion: DateTime.now(),
    );

    _repository.actualizarTurno(actualizado);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(completar ? 'Cita completada.' : 'Cita cancelada.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final turno = _turno;

    if (turno == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de cita')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_busy, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'No se encontró la cita solicitada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cliente = _repository.obtenerClientes().where(
      (item) => item.id == turno.clienteId,
    );
    final estilista = _repository.obtenerEstilistas().where(
      (item) => item.id == turno.estilistaId,
    );
    final servicios = _repository
        .obtenerServicios()
        .where((item) => turno.serviciosIds.contains(item.id))
        .toList();

    final duracion = _minutos(turno.horaFin) - _minutos(turno.horaInicio);
    final total = servicios.fold<double>(
      0,
      (suma, servicio) => suma + servicio.precio,
    );
    final esProgramado = turno.estado == EstadoTurno.programado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de cita'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de la cita',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(_nombreEstado(turno.estado)),
                          backgroundColor: _colorEstado(turno.estado)
                              .withValues(alpha: 0.13),
                          labelStyle: TextStyle(
                            color: _colorEstado(turno.estado),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _DatoTurno(
                      icono: Icons.person_outline,
                      titulo: 'Cliente',
                      valor: cliente.isEmpty
                          ? 'No encontrado'
                          : cliente.first.nombre,
                    ),
                    _DatoTurno(
                      icono: Icons.phone_outlined,
                      titulo: 'Teléfono',
                      valor: cliente.isEmpty
                          ? 'No disponible'
                          : cliente.first.telefono,
                    ),
                    _DatoTurno(
                      icono: Icons.content_cut,
                      titulo: 'Estilista',
                      valor: estilista.isEmpty
                          ? 'No encontrado'
                          : estilista.first.nombre,
                    ),
                    _DatoTurno(
                      icono: Icons.calendar_month,
                      titulo: 'Fecha de la cita',
                      valor: _fecha(turno.fecha),
                    ),
                    _DatoTurno(
                      icono: Icons.access_time,
                      titulo: 'Horario',
                      valor: '${turno.horaInicio} - ${turno.horaFin}',
                    ),
                    _DatoTurno(
                      icono: Icons.timelapse,
                      titulo: 'Duración total',
                      valor: _duracion(duracion),
                    ),
                    _DatoTurno(
                      icono: Icons.add_circle_outline,
                      titulo: 'Fecha de creación',
                      valor: _fechaHora(turno.fechaCreacion),
                    ),
                    _DatoTurno(
                      icono: Icons.edit_calendar_outlined,
                      titulo: 'Última modificación',
                      valor: _fechaHora(turno.fechaModificacion),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Servicios',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (servicios.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Esta cita no tiene servicios registrados.'),
                ),
              ),
            ...servicios.map(
              (servicio) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.spa_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              servicio.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${servicio.duracionMinutos} minutos'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('\$${servicio.precio.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Notas',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: SizedBox(
                height: 150,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      turno.notas == null || turno.notas!.trim().isEmpty
                          ? 'No hay notas para esta cita.'
                          : turno.notas!,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (esProgramado) ...[
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/formulario', extra: turno);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar cita'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _cambiarEstado(EstadoTurno.completado),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Completar cita'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _cambiarEstado(EstadoTurno.cancelado),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar cita'),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DatoTurno extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _DatoTurno({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF817A73),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
