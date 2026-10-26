import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/datos_prueba.dart';
import '../models/servicio.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  CategoriaServicio? _categoriaSeleccionada;
  String _filtroPublico = 'Todos';

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

  String _nombrePublico(PublicoServicio publico) {
    switch (publico) {
      case PublicoServicio.mujer:
        return 'Mujeres';
      case PublicoServicio.hombre:
        return 'Hombres';
      case PublicoServicio.unisex:
        return 'Unisex';
    }
  }

  IconData _iconoCategoria(CategoriaServicio categoria) {
    switch (categoria) {
      case CategoriaServicio.corte:
        return Icons.content_cut;
      case CategoriaServicio.color:
        return Icons.palette_outlined;
      case CategoriaServicio.barba:
        return Icons.auto_awesome;
      case CategoriaServicio.peinado:
        return Icons.auto_fix_high;
      case CategoriaServicio.tratamiento:
        return Icons.water_drop_outlined;
    }
  }

  List<Servicio> _filtrarServicios(List<Servicio> servicios) {
    return servicios.where((servicio) {
      final coincideCategoria =
          _categoriaSeleccionada == null ||
          servicio.categoria == _categoriaSeleccionada;

      final coincidePublico = switch (_filtroPublico) {
        'Mujeres' =>
          servicio.publico == PublicoServicio.mujer ||
              servicio.publico == PublicoServicio.unisex,
        'Hombres' =>
          servicio.publico == PublicoServicio.hombre ||
              servicio.publico == PublicoServicio.unisex,
        _ => true,
      };

      return coincideCategoria && coincidePublico;
    }).toList();
  }

  int _columnasSegunAncho(double ancho) {
    if (ancho < 600) return 2;
    if (ancho <= 840) return 3;
    return 4;
  }

  void _abrirFormulario(Servicio servicio) {
    context.push('/formulario', extra: servicio);
  }

  Widget _chipCategoria(
    String nombre,
    bool seleccionado,
    VoidCallback alPulsar,
  ) {
    final colores = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(nombre),
        selected: seleccionado,
        onSelected: (_) => alPulsar(),
        showCheckmark: true,
        checkmarkColor: colores.onSecondaryContainer,
        backgroundColor: colores.surface,
        selectedColor: colores.secondaryContainer,
        side: BorderSide(
          color: seleccionado ? colores.secondaryContainer : colores.outline,
        ),
        labelStyle: TextStyle(
          color: seleccionado
              ? colores.onSecondaryContainer
              : colores.onSurfaceVariant,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _filtrosPublico() {
    final colores = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: colores.outline),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: ['Todos', 'Mujeres', 'Hombres'].map((publico) {
          final seleccionado = _filtroPublico == publico;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filtroPublico = publico;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? colores.secondaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  publico,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: seleccionado
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: seleccionado
                        ? colores.onSecondaryContainer
                        : colores.onSurface,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _tarjetaServicio(Servicio servicio) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colores.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirFormulario(servicio),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colores.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconoCategoria(servicio.categoria),
                    color: colores.onPrimaryContainer,
                    size: 34,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                servicio.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colores.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    color: colores.onSurfaceVariant,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${servicio.duracionMinutos} min',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colores.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '\$${servicio.precio.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: colores.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colores.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _nombrePublico(servicio.publico),
                  style: TextStyle(
                    color: colores.onSecondaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sinResultados() {
    final colores = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, color: colores.primary, size: 48),
          const SizedBox(height: 12),
          Text(
            'No hay servicios con estos filtros',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colores.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _categoriaSeleccionada = null;
                _filtroPublico = 'Todos';
              });
            },
            child: Text(
              'Mostrar todos',
              style: TextStyle(color: colores.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final todos = DatosPrueba.servicios;
    final servicios = _filtrarServicios(todos);

    return Scaffold(
      backgroundColor: tema.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: tema.scaffoldBackgroundColor,
        foregroundColor: colores.onSurface,
        elevation: 0,
        title: const Text(
          'Servicios',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toca un servicio para reservar',
                style: TextStyle(color: colores.onSurfaceVariant, fontSize: 12),
              ),

              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chipCategoria('Todas', _categoriaSeleccionada == null, () {
                      setState(() {
                        _categoriaSeleccionada = null;
                      });
                    }),
                    ...CategoriaServicio.values.map((categoria) {
                      return _chipCategoria(
                        _nombreCategoria(categoria),
                        _categoriaSeleccionada == categoria,
                        () {
                          setState(() {
                            _categoriaSeleccionada = categoria;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _filtrosPublico(),

              const SizedBox(height: 12),

              Expanded(
                child: servicios.isEmpty
                    ? _sinResultados()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final columnas = _columnasSegunAncho(
                            constraints.maxWidth,
                          );

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 4),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnas,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.72,
                                ),
                            itemCount: servicios.length,
                            itemBuilder: (context, index) {
                              return _tarjetaServicio(servicios[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
