import 'package:flutter/material.dart';

import '../../models/cliente.dart';
import '../../viewmodels/cliente_viewmodel.dart';

class ClienteFormDialog extends StatefulWidget {
  final ClienteViewModel viewModel;
  final Cliente? clienteEditar;

  const ClienteFormDialog({
    super.key,
    required this.viewModel,
    this.clienteEditar,
  });

  @override
  State<ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends State<ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  GeneroCliente? _genero;

  bool get _editando => widget.clienteEditar != null;

  @override
  void initState() {
    super.initState();

    final cliente = widget.clienteEditar;

    if (cliente != null) {
      _nombreController.text = cliente.nombre;
      _telefonoController.text = cliente.telefono;
      _correoController.text = cliente.correo ?? '';
      _genero = cliente.genero;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  String _normalizarTelefono(String telefono) {
    return telefono.replaceAll(RegExp(r'\s+'), '');
  }

  bool _telefonoExiste(String telefono) {
    final buscado = _normalizarTelefono(telefono);

    return widget.viewModel.clientes.any((cliente) {
      if (_editando && cliente.id == widget.clienteEditar!.id) {
        return false;
      }

      return _normalizarTelefono(cliente.telefono) == buscado;
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final clienteOriginal = widget.clienteEditar;

    final cliente = Cliente(
      id: clienteOriginal?.id ?? 'c${DateTime.now().microsecondsSinceEpoch}',
      nombre: _nombreController.text.trim(),
      telefono: _telefonoController.text.trim(),
      genero: _genero!,
      correo: _correoController.text.trim().isEmpty
          ? null
          : _correoController.text.trim(),
      fechaRegistro: clienteOriginal?.fechaRegistro ?? DateTime.now(),
    );

    if (_editando) {
      widget.viewModel.actualizarCliente(cliente);
    } else {
      widget.viewModel.agregarCliente(cliente);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _editando ? 'Editar cliente' : 'Nuevo cliente',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final nombre = valor?.trim() ?? '';

                    if (nombre.isEmpty) {
                      return 'Introduce el nombre';
                    }
                    if (nombre.length < 3) {
                      return 'Debe tener al menos 3 caracteres';
                    }
                    if (nombre.length > 60) {
                      return 'No puede superar los 60 caracteres';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final telefono = valor?.trim() ?? '';

                    if (telefono.isEmpty) {
                      return 'Introduce el teléfono';
                    }
                    if (!RegExp(r'^\d{8}$').hasMatch(telefono)) {
                      return 'Debe contener exactamente 8 dígitos';
                    }
                    if (_telefonoExiste(telefono)) {
                      return 'Este teléfono ya está registrado';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<GeneroCliente>(
                  value: _genero,
                  decoration: const InputDecoration(
                    labelText: 'Género',
                    prefixIcon: Icon(Icons.people_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: GeneroCliente.mujer,
                      child: Text('Mujer'),
                    ),
                    DropdownMenuItem(
                      value: GeneroCliente.hombre,
                      child: Text('Hombre'),
                    ),
                  ],
                  onChanged: (valor) {
                    setState(() => _genero = valor);
                  },
                  validator: (valor) {
                    if (valor == null) {
                      return 'Selecciona el género';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo (opcional)',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final correo = valor?.trim() ?? '';

                    if (correo.isNotEmpty &&
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(correo)) {
                      return 'Introduce un correo válido';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _guardar,
                        child: Text(_editando ? 'Guardar cambios' : 'Guardar'),
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
