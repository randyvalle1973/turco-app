import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/datos_prueba.dart';
import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../viewmodels/cliente_viewmodel.dart';
import '../viewmodels/turno_viewmodel.dart';
import '../widgets/cliente_form_dialog.dart';

class FormularioScreen extends StatefulWidget {
  final DateTime? initialDate;
  final Turno? turnoEditar;
  final Servicio? servicioInicial;
  final Cliente? clienteInicial;

  const FormularioScreen({
    super.key,
    this.initialDate,
    this.turnoEditar,
    this.servicioInicial,
    this.clienteInicial,
  });

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notasController = TextEditingController();
  final _turnoViewModel = TurnoViewModel();
  final _clienteViewModel = ClienteViewModel();

  final _clienteFocus = FocusNode();
  final _serviciosFocus = FocusNode();
  final _estilistaFocus = FocusNode();
  final _fechaFocus = FocusNode();
  final _horaFocus = FocusNode();
  final _notasFocus = FocusNode();

  List<Cliente> _clientes = [];
  String? _clienteId;
  String? _estilistaId;
  final List<String> _serviciosSeleccionados = [];

  late DateTime _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  String _filtroPublico = 'Todos';
  String? _errorHora;
  bool _guardando = false;
  bool _cambiosGuardados = false;
  bool _confirmandoSalida = false;

  @override
  void initState() {
    super.initState();

    final turno = widget.turnoEditar;

    _fechaSeleccionada = _soloFecha(
      turno?.fecha ?? widget.initialDate ?? DateTime.now(),
    );

    if (turno != null) {
      _clienteId = turno.clienteId;
      _estilistaId = turno.estilistaId;
      _serviciosSeleccionados.addAll(turno.serviciosIds);
      _horaSeleccionada = _parsearHora(turno.horaInicio);
      _notasController.text = turno.notas ?? '';
    } else {
      _clienteId = widget.clienteInicial?.id;

      if (widget.servicioInicial != null) {
        _serviciosSeleccionados.add(widget.servicioInicial!.id);
      }
    }

    _turnoViewModel.cargarTurnos();
    _clienteViewModel.cargarClientes();

    _clientes = List<Cliente>.from(_clienteViewModel.clientes);

    final cliente = _clienteActual;
    if (cliente != null && turno == null) {
      _filtroPublico = _filtroParaGenero(cliente.genero);
    }

    _filtrarServiciosPorCliente();
  }

  DateTime _soloFecha(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  Cliente? get _clienteActual {
    for (final cliente in _clientes) {
      if (cliente.id == _clienteId) return cliente;
    }
    return null;
  }

  bool get _esDomingo => _fechaSeleccionada.weekday == DateTime.sunday;

  TimeOfDay _parsearHora(String hora) {
    final partes = hora.split(':');
    return TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
  }

  String _filtroParaGenero(GeneroCliente genero) {
    if (genero == GeneroCliente.mujer) return 'Mujeres';
    if (genero == GeneroCliente.hombre) return 'Hombres';
    return 'Todos';
  }

  @override
  void dispose() {
    _notasController.dispose();
    _turnoViewModel.dispose();
    _clienteViewModel.dispose();

    _clienteFocus.dispose();
    _serviciosFocus.dispose();
    _estilistaFocus.dispose();
    _fechaFocus.dispose();
    _horaFocus.dispose();
    _notasFocus.dispose();

    super.dispose();
  }

  List<Estilista> _obtenerEstilistasCompatibles() {
    if (_serviciosSeleccionados.isEmpty) return [];

    return DatosPrueba.estilistas.where((estilista) {
      return _serviciosSeleccionados.every(
        (id) => estilista.serviciosIds.contains(id),
      );
    }).toList();
  }

  void _validarEstilistaSeleccionado() {
    if (_estilistaId == null) return;

    final compatible = _obtenerEstilistasCompatibles().any(
      (estilista) => estilista.id == _estilistaId,
    );

    if (!compatible) {
      setState(() {
        _estilistaId = null;
        _horaSeleccionada = null;
        _errorHora = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El estilista seleccionado no realiza todos los servicios elegidos.',
          ),
        ),
      );
    }
  }

  Future<void> _agregarNuevoCliente() async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ClienteFormDialog(viewModel: _clienteViewModel),
    );

    if (!mounted || guardado != true) return;

    _clienteViewModel.cargarClientes();

    setState(() {
      _clientes = List<Cliente>.from(_clienteViewModel.clientes);

      if (_clientes.isNotEmpty) {
        final nuevoCliente = _clientes.last;
        _clienteId = nuevoCliente.id;
        _filtroPublico = _filtroParaGenero(nuevoCliente.genero);
        _filtrarServiciosPorCliente();
      }

      _horaSeleccionada = null;
      _errorHora = null;
    });

    _validarEstilistaSeleccionado();
  }

  bool _servicioCompatible(Servicio servicio) {
    final cliente = _clienteActual;
    if (cliente == null) return true;

    switch (servicio.publico) {
      case PublicoServicio.mujer:
        return cliente.genero == GeneroCliente.mujer;
      case PublicoServicio.hombre:
        return cliente.genero == GeneroCliente.hombre;
      case PublicoServicio.unisex:
        return true;
    }
  }

  bool _coincideFiltro(Servicio servicio) {
    if (!_servicioCompatible(servicio)) return false;

    switch (_filtroPublico) {
      case 'Mujeres':
        return servicio.publico == PublicoServicio.mujer ||
            servicio.publico == PublicoServicio.unisex;
      case 'Hombres':
        return servicio.publico == PublicoServicio.hombre ||
            servicio.publico == PublicoServicio.unisex;
      default:
        return true;
    }
  }

  void _filtrarServiciosPorCliente() {
    _serviciosSeleccionados.removeWhere((id) {
      final encontrados = DatosPrueba.servicios.where((s) => s.id == id);
      return encontrados.isEmpty || !_servicioCompatible(encontrados.first);
    });
  }

  int _duracionTotal() {
    return DatosPrueba.servicios
        .where((s) => _serviciosSeleccionados.contains(s.id))
        .fold<int>(0, (total, servicio) {
          return total + servicio.duracionMinutos;
        });
  }

  double _precioTotal() {
    return DatosPrueba.servicios
        .where((s) => _serviciosSeleccionados.contains(s.id))
        .fold<double>(0, (total, servicio) {
          return total + servicio.precio;
        });
  }

  String _formatearHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }

  String _calcularHoraFin([TimeOfDay? hora]) {
    final inicio = hora ?? _horaSeleccionada;
    if (inicio == null) return '--:--';

    final minutos = inicio.hour * 60 + inicio.minute + _duracionTotal();

    return '${(minutos ~/ 60).toString().padLeft(2, '0')}:'
        '${(minutos % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _seleccionarFecha() async {
    final hoy = _soloFecha(DateTime.now());

    var inicial = _fechaSeleccionada.isBefore(hoy) ? hoy : _fechaSeleccionada;

    while (inicial.weekday == DateTime.sunday) {
      inicial = inicial.add(const Duration(days: 1));
    }

    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      selectableDayPredicate: (date) =>
          date.weekday != DateTime.sunday && !_soloFecha(date).isBefore(hoy),
      helpText: 'Selecciona una fecha de lunes a sábado',
    );

    if (fecha == null || !mounted) return;

    setState(() {
      _fechaSeleccionada = _soloFecha(fecha);
      _horaSeleccionada = null;
      _errorHora = null;
    });
  }

  List<TimeOfDay> _obtenerHorariosDisponibles() {
    final horarios = <TimeOfDay>[];
    final duracion = _duracionTotal();

    if (_clienteId == null ||
        _estilistaId == null ||
        _serviciosSeleccionados.isEmpty ||
        duracion <= 0 ||
        _esDomingo) {
      return horarios;
    }

    final ahora = DateTime.now();
    final hoy = _soloFecha(ahora);
    final esHoy = _soloFecha(_fechaSeleccionada) == hoy;

    for (int minutos = 9 * 60; minutos + duracion <= 19 * 60; minutos += 30) {
      final inicio = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        minutos ~/ 60,
        minutos % 60,
      );

      if (esHoy && !inicio.isAfter(ahora)) continue;

      final finMinutos = minutos + duracion;

      final candidato = Turno(
        id: widget.turnoEditar?.id ?? 'temporal_$minutos',
        clienteId: _clienteId!,
        estilistaId: _estilistaId!,
        serviciosIds: List<String>.from(_serviciosSeleccionados),
        fecha: _soloFecha(_fechaSeleccionada),
        horaInicio: _formatearHora(
          TimeOfDay(hour: minutos ~/ 60, minute: minutos % 60),
        ),
        horaFin:
            '${(finMinutos ~/ 60).toString().padLeft(2, '0')}:'
            '${(finMinutos % 60).toString().padLeft(2, '0')}',
        estado: EstadoTurno.programado,
      );

      if (!_turnoViewModel.hayConflicto(
        candidato,
        excluirId: widget.turnoEditar?.id,
      )) {
        horarios.add(TimeOfDay(hour: minutos ~/ 60, minute: minutos % 60));
      }
    }

    return horarios;
  }

  bool get _hayCambios {
    final original = widget.turnoEditar;

    if (original == null) {
      return _clienteId != null ||
          _serviciosSeleccionados.isNotEmpty ||
          _estilistaId != null ||
          _horaSeleccionada != null ||
          _notasController.text.trim().isNotEmpty;
    }

    return _clienteId != original.clienteId ||
        _estilistaId != original.estilistaId ||
        _fechaSeleccionada != _soloFecha(original.fecha) ||
        _horaSeleccionada == null ||
        _formatearHora(_horaSeleccionada!) != original.horaInicio ||
        !_listasIguales(_serviciosSeleccionados, original.serviciosIds) ||
        _notasController.text.trim() != (original.notas ?? '');
  }

  bool _listasIguales(List<String> a, List<String> b) {
    return a.length == b.length && a.toSet().containsAll(b);
  }

  Future<bool> _confirmarSalida() async {
    if (_cambiosGuardados || !_hayCambios) return true;
    if (_confirmandoSalida) return false;

    _confirmandoSalida = true;

    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Salir sin guardar?'),
        content: const Text(
          'Tienes cambios sin guardar. Si sales ahora, se perderán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Salir sin guardar'),
          ),
        ],
      ),
    );

    _confirmandoSalida = false;
    return salir ?? false;
  }

  Future<void> _cancelar() async {
    if (await _confirmarSalida() && mounted) {
      context.pop();
    }
  }

  void _guardarTurno() {
    FocusScope.of(context).unfocus();

    if (_clienteId == null) {
      _clienteFocus.requestFocus();
      return;
    }

    if (_serviciosSeleccionados.isEmpty) {
      _serviciosFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un servicio.')),
      );
      return;
    }

    if (_estilistaId == null ||
        !_obtenerEstilistasCompatibles().any((e) => e.id == _estilistaId)) {
      _estilistaFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un estilista compatible.')),
      );
      return;
    }

    if (_esDomingo ||
        _soloFecha(_fechaSeleccionada).isBefore(_soloFecha(DateTime.now()))) {
      _fechaFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha válida.')),
      );
      return;
    }

    final horarios = _obtenerHorariosDisponibles();

    if (_horaSeleccionada == null ||
        !horarios.any(
          (hora) =>
              hora.hour == _horaSeleccionada!.hour &&
              hora.minute == _horaSeleccionada!.minute,
        )) {
      setState(() {
        _errorHora = 'Selecciona una hora disponible.';
      });
      _horaFocus.requestFocus();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _notasFocus.requestFocus();
      return;
    }

    final hora = _horaSeleccionada!;
    final fecha = _soloFecha(_fechaSeleccionada);
    final original = widget.turnoEditar;

    final turno = Turno(
      id: original?.id ?? 't${DateTime.now().microsecondsSinceEpoch}',
      clienteId: _clienteId!,
      estilistaId: _estilistaId!,
      serviciosIds: List<String>.from(_serviciosSeleccionados),
      fecha: fecha,
      horaInicio: _formatearHora(hora),
      horaFin: _calcularHoraFin(hora),
      notas: _notasController.text.trim(),
      estado: EstadoTurno.programado,
      fechaCreacion: original?.fechaCreacion ?? DateTime.now(),
      fechaModificacion: DateTime.now(),
    );

    setState(() => _guardando = true);

    final guardado = original == null
        ? _turnoViewModel.agregarTurno(turno)
        : _turnoViewModel.editarTurno(turno);

    if (!mounted) return;

    setState(() => _guardando = false);

    if (!guardado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar. Revisa los conflictos de horario.',
          ),
        ),
      );
      return;
    }

    _cambiosGuardados = true;
    context.pop<Turno>(turno);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final servicios = DatosPrueba.servicios;
    final compatibles = _obtenerEstilistasCompatibles();
    final horarios = _obtenerHorariosDisponibles();

    final ancho = MediaQuery.sizeOf(context).width;
    final columnas = ancho < 420
        ? 2
        : ancho < 700
        ? 3
        : 4;

    final serviciosVisibles = servicios.where(_coincideFiltro).toList();

    final categorias = <String, List<Servicio>>{};
    String nombreCategoria(CategoriaServicio categoria) {
      switch (categoria) {
        case CategoriaServicio.corte:
          return 'Cortes';
        case CategoriaServicio.color:
          return 'Coloración';
        case CategoriaServicio.barba:
          return 'Barba';
        case CategoriaServicio.peinado:
          return 'Peinados';
        case CategoriaServicio.tratamiento:
          return 'Tratamientos';
      }
    }

    for (final servicio in serviciosVisibles) {
      categorias
          .putIfAbsent(nombreCategoria(servicio.categoria), () => [])
          .add(servicio);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmarSalida() && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.turnoEditar == null ? 'Nueva cita' : 'Editar cita',
          ),
          leading: IconButton(
            tooltip: 'Cancelar y volver',
            icon: const Icon(Icons.arrow_back),
            onPressed: _cancelar,
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Text(
                  'Datos de la cita',
                  style: tema.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        focusNode: _clienteFocus,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Cliente *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        initialValue: _clientes.any((c) => c.id == _clienteId)
                            ? _clienteId
                            : null,
                        items: _clientes.map((cliente) {
                          return DropdownMenuItem(
                            value: cliente.id,
                            child: Text(
                              cliente.nombre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() {
                            _clienteId = valor;

                            final cliente = _clienteActual;
                            if (cliente != null) {
                              _filtroPublico = _filtroParaGenero(
                                cliente.genero,
                              );
                            }

                            _filtrarServiciosPorCliente();
                            _horaSeleccionada = null;
                            _errorHora = null;
                          });

                          _validarEstilistaSeleccionado();
                        },
                        validator: (valor) =>
                            valor == null ? 'Selecciona un cliente.' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Crear cliente',
                      onPressed: _agregarNuevoCliente,
                      icon: const Icon(Icons.person_add_alt_1),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text('Servicios *', style: tema.textTheme.titleLarge),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Mostrar servicios para',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  initialValue: _filtroPublico,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'Mujeres', child: Text('Mujeres')),
                    DropdownMenuItem(value: 'Hombres', child: Text('Hombres')),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _filtroPublico = valor ?? 'Todos';
                      _serviciosSeleccionados.removeWhere((id) {
                        final encontrados = servicios.where((s) => s.id == id);
                        return encontrados.isEmpty ||
                            !_coincideFiltro(encontrados.first);
                      });
                      _horaSeleccionada = null;
                      _errorHora = null;
                    });

                    _validarEstilistaSeleccionado();
                  },
                ),

                Focus(
                  focusNode: _serviciosFocus,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entrada in categorias.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 4),
                          child: Text(
                            entrada.key,
                            style: tema.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        for (final servicio in entrada.value)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _serviciosSeleccionados.contains(
                              servicio.id,
                            ),
                            title: Text(servicio.nombre),
                            subtitle: Text(
                              '${servicio.duracionMinutos} min · '
                              '\$${servicio.precio.toStringAsFixed(2)}',
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (seleccionado) {
                              setState(() {
                                if (seleccionado == true) {
                                  if (!_serviciosSeleccionados.contains(
                                    servicio.id,
                                  )) {
                                    _serviciosSeleccionados.add(servicio.id);
                                  }
                                } else {
                                  _serviciosSeleccionados.remove(servicio.id);
                                }

                                _horaSeleccionada = null;
                                _errorHora = null;
                              });

                              _validarEstilistaSeleccionado();
                            },
                          ),
                      ],
                      if (_serviciosSeleccionados.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Selecciona al menos un servicio.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  focusNode: _estilistaFocus,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Estilista *',
                    prefixIcon: Icon(Icons.content_cut),
                  ),
                  initialValue: compatibles.any((e) => e.id == _estilistaId)
                      ? _estilistaId
                      : null,
                  items: compatibles.map((estilista) {
                    return DropdownMenuItem(
                      value: estilista.id,
                      child: Text(
                        estilista.nombre,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _estilistaId = valor;
                      _horaSeleccionada = null;
                      _errorHora = null;
                    });
                  },
                  validator: (valor) => valor == null
                      ? 'Selecciona un estilista compatible.'
                      : null,
                ),

                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen de la cita',
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Duración total: ${_duracionTotal()} minutos'),
                        Text('Hora de fin: ${_calcularHoraFin()}'),
                        Text(
                          'Precio total: \$${_precioTotal().toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                OutlinedButton.icon(
                  focusNode: _fechaFocus,
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    'Fecha: ${_fechaSeleccionada.day}/'
                    '${_fechaSeleccionada.month}/'
                    '${_fechaSeleccionada.year}',
                  ),
                ),

                if (_esDomingo)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'No se pueden reservar citas los domingos.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 16),

                Text('Hora de inicio *', style: tema.textTheme.titleMedium),
                const SizedBox(height: 8),

                Focus(
                  focusNode: _horaFocus,
                  child: horarios.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _clienteId == null ||
                                    _estilistaId == null ||
                                    _serviciosSeleccionados.isEmpty
                                ? 'Selecciona cliente, servicios y estilista para ver los horarios.'
                                : 'No hay horarios disponibles para esta fecha y selección.',
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: horarios.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columnas,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 2.2,
                              ),
                          itemBuilder: (context, index) {
                            final hora = horarios[index];
                            final seleccionada =
                                _horaSeleccionada?.hour == hora.hour &&
                                _horaSeleccionada?.minute == hora.minute;

                            return OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _horaSeleccionada = hora;
                                  _errorHora = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: seleccionada
                                    ? tema.colorScheme.primaryContainer
                                    : null,
                                side: BorderSide(
                                  color: seleccionada
                                      ? tema.colorScheme.primary
                                      : tema.colorScheme.outline,
                                ),
                              ),
                              child: Text(_formatearHora(hora)),
                            );
                          },
                        ),
                ),

                if (_errorHora != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _errorHora!,
                      style: TextStyle(color: tema.colorScheme.error),
                    ),
                  ),

                if (_horaSeleccionada != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Fin estimado: ${_calcularHoraFin()}'),
                  ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _notasController,
                  focusNode: _notasFocus,
                  textInputAction: TextInputAction.done,
                  maxLines: 4,
                  minLines: 2,
                  maxLength: 500,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Detalles adicionales de la cita',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelar,
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _guardando ? null : _guardarTurno,
                        icon: const Icon(Icons.check),
                        label: Text(
                          widget.turnoEditar == null
                              ? 'Guardar cita'
                              : 'Guardar cambios',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
