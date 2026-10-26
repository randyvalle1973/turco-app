import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cliente.dart';
import '../models/turno.dart';
import '../data/peluqueria_repository.dart';
import '../viewmodels/cliente_viewmodel.dart';
import '../widgets/cliente_form_dialog.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({super.key});

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  late final ClienteViewModel _viewModel;
  String _busqueda = '';
  String _filtroGenero = 'Todos';

  @override
  void initState() {
    super.initState();
    _viewModel = ClienteViewModel();
    _viewModel.cargarClientes();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  List<Cliente> _filtrarClientes(List<Cliente> clientes) {
    final resultado = _viewModel.buscarClientes(_busqueda);

    return resultado.where((cliente) {
      if (_filtroGenero == 'Mujeres') {
        return cliente.genero == GeneroCliente.mujer;
      }

      if (_filtroGenero == 'Hombres') {
        return cliente.genero == GeneroCliente.hombre;
      }

      return true;
    }).toList();
  }

  int _contarGenero(GeneroCliente genero) {
    return _viewModel.clientes
        .where((cliente) => cliente.genero == genero)
        .length;
  }

  List<Turno> _historialCliente(String clienteId) {
    return PeluqueriaRepository()
        .obtenerTurnos()
        .where((turno) => turno.clienteId == clienteId)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  void _mostrarDetalle(Cliente cliente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final historial = _historialCliente(cliente.id);
        final turnosProgramados = historial
            .where((turno) => turno.estado == EstadoTurno.programado)
            .length;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(
                          cliente.nombre.isNotEmpty
                              ? cliente.nombre[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cliente.nombre,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(cliente.telefono),
                            Text(
                              cliente.genero == GeneroCliente.mujer
                                  ? 'Mujer'
                                  : 'Hombre',
                            ),
                            if (cliente.correo != null &&
                                cliente.correo!.isNotEmpty)
                              Text(cliente.correo!),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Historial de turnos (${historial.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (historial.isEmpty)
                    const Text('Este cliente todavía no tiene turnos.')
                  else
                    ...historial.map(
                      (turno) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          turno.estado == EstadoTurno.programado
                              ? Icons.event
                              : turno.estado == EstadoTurno.completado
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                        ),
                        title: Text(
                          '${turno.fecha.day.toString().padLeft(2, '0')}/'
                          '${turno.fecha.month.toString().padLeft(2, '0')}/'
                          '${turno.fecha.year}',
                        ),
                        subtitle: Text(
                          '${turno.horaInicio} - ${turno.horaFin}',
                        ),
                        trailing: Text(switch (turno.estado) {
                          EstadoTurno.programado => 'Programado',
                          EstadoTurno.completado => 'Completado',
                          EstadoTurno.cancelado => 'Cancelado',
                        }),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _abrirFormulario(cliente: cliente);
                      },

                      icon: const Icon(Icons.add),
                      label: const Text('Nuevo turno'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _abrirFormulario(cliente: cliente);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar cliente'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () {
                        if (turnosProgramados > 0) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No puedes eliminar este cliente porque tiene turnos programados.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context);
                        _confirmarEliminacion(cliente);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar cliente'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _abrirFormulario({Cliente? cliente}) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          ClienteFormDialog(viewModel: _viewModel, clienteEditar: cliente),
    );
  }

  Future<void> _confirmarEliminacion(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          '¿Quieres eliminar a ${cliente.nombre}? '
          'También se eliminará su historial de turnos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      if (_viewModel.tieneTurnosProgramados(cliente.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se puede eliminar: el cliente tiene turnos programados.',
            ),
          ),
        );
        return;
      }

      _viewModel.eliminarCliente(cliente.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente eliminado correctamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clientes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Añadir cliente',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final todos = _viewModel.clientes;
          final clientes = _filtrarClientes(todos);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuestros clientes',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${todos.length} clientes registrados',
                  style: const TextStyle(color: Color(0xFF817A73)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _estadistica('Mujeres', _contarGenero(GeneroCliente.mujer)),
                    _estadistica(
                      'Hombres',
                      _contarGenero(GeneroCliente.hombre),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o teléfono...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              setState(() => _busqueda = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (valor) {
                    setState(() => _busqueda = valor);
                  },
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Todos', label: Text('Todos')),
                    ButtonSegment(value: 'Mujeres', label: Text('Mujeres')),
                    ButtonSegment(value: 'Hombres', label: Text('Hombres')),
                  ],
                  selected: {_filtroGenero},
                  onSelectionChanged: (seleccion) {
                    setState(() => _filtroGenero = seleccion.first);
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: clientes.isEmpty
                      ? Center(
                          child: Text(
                            todos.isEmpty
                                ? 'Todavía no hay clientes registrados.'
                                : 'No se encontraron clientes con esos filtros.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: clientes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final cliente = clientes[index];

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                  child: Text(
                                    cliente.nombre.isNotEmpty
                                        ? cliente.nombre[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  cliente.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${cliente.telefono} · '
                                  '${cliente.genero == GeneroCliente.mujer ? 'Mujer' : 'Hombre'} · '
                                  '${_historialCliente(cliente.id).length} turnos',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _mostrarDetalle(cliente),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo cliente'),
      ),
    );
  }

  Widget _estadistica(String titulo, int cantidad) {
    return Chip(
      avatar: const Icon(Icons.people_outline, size: 18),
      label: Text('$titulo: $cantidad'),
    );
  }
}
