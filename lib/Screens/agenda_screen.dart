import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/turno.dart';
import '../data/datos_prueba.dart';
import '../viewmodels/agenda_viewmodel.dart';
import '../theme/theme_controller.dart';

class AgendaScreen extends StatefulWidget {
  final String? estilistaId;

  const AgendaScreen({super.key, this.estilistaId});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late final AgendaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AgendaViewModel();
    _viewModel.cargarTurnos();

    if (widget.estilistaId != null) {
      _viewModel.seleccionarEstilista(widget.estilistaId);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  DateTime _inicioSemana(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day - fecha.weekday + 1);
  }

  String _fechaTexto(DateTime fecha) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${dias[fecha.weekday - 1]}, ${fecha.day} de ${meses[fecha.month - 1]}';
  }

  Color _colorEstado(BuildContext context, EstadoTurno estado) {
    switch (estado) {
      case EstadoTurno.programado:
        return Theme.of(context).colorScheme.primary;
      case EstadoTurno.completado:
        return Colors.green;
      case EstadoTurno.cancelado:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _textoEstado(EstadoTurno estado) {
    switch (estado) {
      case EstadoTurno.programado:
        return 'Programada';
      case EstadoTurno.completado:
        return 'Completada';
      case EstadoTurno.cancelado:
        return 'Cancelada';
    }
  }

  Future<void> _elegirFecha() async {
    final fecha = _viewModel.fechaSeleccionada;

    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (elegida != null && mounted) {
      _viewModel.seleccionarFecha(elegida);
    }
  }

  Future<void> _crearTurno() async {
    final turno = await context.push<Turno>(
      '/formulario',
      extra: _viewModel.fechaSeleccionada,
    );

    if (!mounted || turno == null) return;

    _viewModel.cargarTurnos();
    _viewModel.seleccionarFecha(turno.fecha);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Cita creada correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _mostrarAccionesTurno(Turno turno) async {
    if (turno.estado != EstadoTurno.programado) return;

    final accion = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                title: const Text('Completar cita'),
                onTap: () => Navigator.pop(context, 'completar'),
              ),
              ListTile(
                leading: Icon(
                  Icons.cancel_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Cancelar cita'),
                onTap: () => Navigator.pop(context, 'cancelar'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || accion == null) return;

    final completar = accion == 'completar';
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(completar ? 'Completar cita' : 'Cancelar cita'),
          content: Text(
            completar
                ? '¿Confirmas que esta cita se ha completado?'
                : '¿Seguro que quieres cancelar esta cita?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(completar ? 'Completar' : 'Cancelar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmado != true) return;

    if (completar) {
      _viewModel.completarTurno(turno.id);
    } else {
      _viewModel.cancelarTurno(turno.id);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(completar ? 'Cita completada.' : 'Cita cancelada.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final hoy = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Turco',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: ThemeController.toggle,
            icon: Icon(
              ThemeController.mode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Cambiar tema',
          ),
          IconButton(
            onPressed: () => context.go('/clientes'),
            icon: const Icon(Icons.people_outline),
            tooltip: 'Clientes',
          ),
          IconButton(
            onPressed: () => context.go('/estilistas'),
            icon: const Icon(Icons.groups_outlined),
            tooltip: 'Estilistas',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final turnosDia = _viewModel.turnosDelDia;
          final turnos = _viewModel.turnosFiltrados;
          final fecha = _viewModel.fechaSeleccionada;

          final filtroEstado = _viewModel.estadoSeleccionado;
          final estadoUi = filtroEstado == null
              ? 'Todos'
              : switch (filtroEstado) {
                  EstadoTurno.programado => 'Programados',
                  EstadoTurno.completado => 'Completados',
                  EstadoTurno.cancelado => 'Cancelados',
                };

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Text(
                'Agenda',
                style: tema.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _fechaTexto(fecha),
                style: tema.textTheme.bodyLarge?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  final ancho = (constraints.maxWidth - 24) / 3;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: ancho,
                        child: _ResumenCard(
                          titulo: 'Programadas',
                          valor: '${_viewModel.cantidadProgramados}',
                          icono: Icons.event_available,
                        ),
                      ),
                      SizedBox(
                        width: ancho,
                        child: _ResumenCard(
                          titulo: 'Completadas',
                          valor: '${_viewModel.cantidadCompletados}',
                          icono: Icons.check_circle_outline,
                        ),
                      ),
                      SizedBox(
                        width: ancho,
                        child: _ResumenCard(
                          titulo: 'Ingresos',
                          valor:
                              '\$${_viewModel.ingresosEstimados.toStringAsFixed(2)}',
                          icono: Icons.attach_money,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _viewModel.seleccionarFecha(
                        DateTime(fecha.year, fecha.month - 1, fecha.day),
                      );
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      _fechaTexto(fecha),
                      textAlign: TextAlign.center,
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _viewModel.seleccionarFecha(
                        DateTime(fecha.year, fecha.month + 1, fecha.day),
                      );
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                  IconButton(
                    onPressed: _elegirFecha,
                    tooltip: 'Elegir fecha',
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: List.generate(7, (index) {
                  final dia = _inicioSemana(fecha).add(Duration(days: index));

                  final seleccionado =
                      dia.year == fecha.year &&
                      dia.month == fecha.month &&
                      dia.day == fecha.day;

                  const nombresDias = [
                    'Lun',
                    'Mar',
                    'Mié',
                    'Jue',
                    'Vie',
                    'Sáb',
                    'Dom',
                  ];

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: seleccionado
                            ? tema.colorScheme.primary
                            : tema.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _viewModel.seleccionarFecha(dia),
                          child: SizedBox(
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  nombresDias[index],
                                  style: tema.textTheme.labelSmall?.copyWith(
                                    color: seleccionado
                                        ? tema.colorScheme.onPrimary
                                        : tema.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${dia.day}',
                                  style: tema.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: seleccionado
                                        ? tema.colorScheme.onPrimary
                                        : tema.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              if (fecha.weekday == DateTime.sunday)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Domingo: salón cerrado',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              Text(
                'Filtrar por estilista',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('Todos'),
                        selected: _viewModel.estilistaIdSeleccionado == null,
                        onSelected: (_) =>
                            _viewModel.seleccionarEstilista(null),
                      ),
                    ),
                    ...DatosPrueba.estilistas.map((estilista) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(estilista.nombre),
                          selected:
                              _viewModel.estilistaIdSeleccionado ==
                              estilista.id,
                          onSelected: (_) => _viewModel.seleccionarEstilista(
                            _viewModel.estilistaIdSeleccionado == estilista.id
                                ? null
                                : estilista.id,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Filtrar por estado',
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Todos', label: Text('Todos')),
                    ButtonSegment(
                      value: 'Programados',
                      label: Text('Programados'),
                    ),
                    ButtonSegment(
                      value: 'Completados',
                      label: Text('Completados'),
                    ),
                    ButtonSegment(
                      value: 'Cancelados',
                      label: Text('Cancelados'),
                    ),
                  ],
                  selected: {estadoUi},
                  showSelectedIcon: false,
                  onSelectionChanged: (seleccion) {
                    final valor = seleccion.first;

                    _viewModel.seleccionarEstado(switch (valor) {
                      'Programados' => EstadoTurno.programado,
                      'Completados' => EstadoTurno.completado,
                      'Cancelados' => EstadoTurno.cancelado,
                      _ => null,
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Citas del día',
                      style: tema.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (fecha.year == hoy.year &&
                      fecha.month == hoy.month &&
                      fecha.day == hoy.day)
                    Text(
                      'Hoy',
                      style: tema.textTheme.labelLarge?.copyWith(
                        color: tema.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (turnos.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          turnosDia.isEmpty
                              ? Icons.event_available
                              : Icons.filter_list_off,
                          size: 48,
                          color: tema.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          turnosDia.isEmpty
                              ? 'No hay citas para este día'
                              : 'No hay citas con estos filtros',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          turnosDia.isEmpty
                              ? 'Puedes crear una nueva cita para esta fecha.'
                              : 'Prueba con otro estilista o estado.',
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (turnosDia.isEmpty) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _crearTurno,
                            icon: const Icon(Icons.add),
                            label: const Text('Nueva cita'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                ...turnos.map((turno) {
                  final cliente = DatosPrueba.clientes.firstWhere(
                    (elemento) => elemento.id == turno.clienteId,
                  );

                  final estilista = DatosPrueba.estilistas.firstWhere(
                    (elemento) => elemento.id == turno.estilistaId,
                  );

                  final servicios = DatosPrueba.servicios
                      .where(
                        (servicio) => turno.serviciosIds.contains(servicio.id),
                      )
                      .map((servicio) => servicio.nombre)
                      .toList();

                  final color = _colorEstado(context, turno.estado);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        context.go('/turno?turnoId=${turno.id}');
                      },
                      onLongPress: () => _mostrarAccionesTurno(turno),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 5,
                              height: 105,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${turno.horaInicio} - ${turno.horaFin}',
                                    style: tema.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cliente.nombre,
                                    style: tema.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    servicios.isEmpty
                                        ? 'Sin servicios'
                                        : servicios.join(', '),
                                    style: tema.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Estilista: ${estilista.nombre}',
                                    style: tema.textTheme.bodySmall?.copyWith(
                                      color: tema.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _textoEstado(turno.estado),
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearTurno,
        icon: const Icon(Icons.add),
        label: const Text('Agregar turno'),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const _ResumenCard({
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: tema.colorScheme.primary),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
