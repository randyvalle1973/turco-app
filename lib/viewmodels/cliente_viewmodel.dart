import 'package:flutter/foundation.dart';

import '../data/peluqueria_repository.dart';
import '../models/cliente.dart';
import '../models/turno.dart';

class ClienteViewModel extends ChangeNotifier {
  final PeluqueriaRepository _repository;

  ClienteViewModel({PeluqueriaRepository? repository})
    : _repository = repository ?? PeluqueriaRepository();

  List<Cliente> _clientes = [];

  List<Cliente> get clientes => List.unmodifiable(_clientes);

  void cargarClientes() {
    _clientes = List<Cliente>.from(_repository.obtenerClientes());
    notifyListeners();
  }

  Cliente? buscarCliente(String id) {
    for (final cliente in _clientes) {
      if (cliente.id == id) return cliente;
    }
    return null;
  }

  String _normalizar(String texto) {
    const acentuadas = 'áéíóúüñ';
    const normales = 'aeiouun';

    var resultado = texto.toLowerCase().trim();

    for (var i = 0; i < acentuadas.length; i++) {
      resultado = resultado.replaceAll(acentuadas[i], normales[i]);
    }

    return resultado;
  }

  List<Cliente> buscarClientes(String texto) {
    final consulta = _normalizar(texto);

    if (consulta.isEmpty) return clientes;

    return _clientes.where((cliente) {
      return _normalizar(cliente.nombre).contains(consulta) ||
          cliente.telefono.contains(consulta);
    }).toList();
  }

  // Se conserva por compatibilidad con el código existente.
  List<Cliente> buscarPorNombre(String texto) {
    return buscarClientes(texto);
  }

  void agregarCliente(Cliente cliente) {
    _repository.agregarCliente(cliente);
    cargarClientes();
  }

  void actualizarCliente(Cliente cliente) {
    _repository.actualizarCliente(cliente);
    cargarClientes();
  }

  bool tieneTurnosProgramados(String clienteId) {
    return _repository.obtenerTurnos().any(
      (turno) =>
          turno.clienteId == clienteId &&
          turno.estado == EstadoTurno.programado,
    );
  }

  void eliminarCliente(String id) {
    if (tieneTurnosProgramados(id)) return;

    _repository.eliminarCliente(id);
    cargarClientes();
  }
}
