import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/datos_prueba.dart';
import '../models/servicio.dart';
import '../models/turno.dart';

class EstilistasScreen extends StatelessWidget {
  const EstilistasScreen({super.key});

  int _turnosProgramadosHoy(String estilistaId) {
    final hoy = DateTime.now();

    return DatosPrueba.turnos.where((turno) {
      return turno.estilistaId == estilistaId &&
          turno.fecha.year == hoy.year &&
          turno.fecha.month == hoy.month &&
          turno.fecha.day == hoy.day &&
          turno.estado == EstadoTurno.programado;
    }).length;
  }

  String _nombreCategoria(CategoriaServicio categoria) {
    switch (categoria) {
      case CategoriaServicio.corte:
        return 'Corte';
      case CategoriaServicio.color:
        return 'Color';
      case CategoriaServicio.barba:
        return 'Barba';
      case CategoriaServicio.peinado:
        return 'Peinado';
      case CategoriaServicio.tratamiento:
        return 'Tratamiento';
    }
  }

  @override
  Widget build(BuildContext context) {
    final estilistas = DatosPrueba.estilistas;
    final servicios = DatosPrueba.servicios;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            title: const Text(
              'Estilistas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Text(
                  '${estilistas.length} profesionales en nuestro equipo',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final estilista = estilistas[index];

                final serviciosEstilista = servicios
                    .where(
                      (servicio) =>
                          estilista.serviciosIds.contains(servicio.id),
                    )
                    .toList();

                final categorias = <CategoriaServicio, List<Servicio>>{};

                for (final servicio in serviciosEstilista) {
                  categorias
                      .putIfAbsent(servicio.categoria, () => [])
                      .add(servicio);
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      context.go(
                        '/agenda?estilista=${Uri.encodeQueryComponent(estilista.id)}',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                child: Text(
                                  estilista.nombre.isNotEmpty
                                      ? estilista.nombre[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  estilista.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          const SizedBox(height: 16),

                          for (final entry in categorias.entries) ...[
                            Text(
                              _nombreCategoria(entry.key),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: entry.value
                                  .map(
                                    (servicio) =>
                                        Chip(label: Text(servicio.nombre)),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 10),
                          ],

                          const Divider(),
                          Row(
                            children: [
                              const Icon(
                                Icons.event_available_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${_turnosProgramadosHoy(estilista.id)} turnos programados hoy',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: estilistas.length),
            ),
          ),
        ],
      ),
    );
  }
}
