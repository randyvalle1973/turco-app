import '../models/cliente.dart';
import '../models/estilista.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import 'datos_prueba.dart';

class PeluqueriaRepository {
  static final List<Cliente> _clientes = List<Cliente>.from(
    DatosPrueba.clientes,
  );

  static final List<Turno> _turnos = List<Turno>.from(DatosPrueba.turnos);

  List<Cliente> obtenerClientes() {
    return List.unmodifiable(_clientes);
  }

  void agregarCliente(Cliente cliente) {
    _clientes.add(cliente);
  }

  List<Estilista> obtenerEstilistas() {
    return DatosPrueba.estilistas;
  }

  List<Servicio> obtenerServicios() {
    return DatosPrueba.servicios;
  }

  List<Turno> obtenerTurnos() {
    return List.unmodifiable(_turnos);
  }

  void agregarTurno(Turno turno) {
    _turnos.add(turno);
  }

  void actualizarTurno(Turno turnoActualizado) {
    final indice = _turnos.indexWhere(
      (turno) => turno.id == turnoActualizado.id,
    );

    if (indice != -1) {
      _turnos[indice] = turnoActualizado;
    }
  }

  void actualizarCliente(Cliente clienteActualizado) {
    final indice = _clientes.indexWhere(
      (cliente) => cliente.id == clienteActualizado.id,
    );

    if (indice != -1) {
      _clientes[indice] = clienteActualizado;
    }
  }

  void eliminarCliente(String id) {
    _clientes.removeWhere((cliente) => cliente.id == id);

    _turnos.removeWhere((turno) => turno.clienteId == id);
  }
}
