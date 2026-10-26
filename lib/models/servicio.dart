import 'package:flutter/material.dart';

class Servicio {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracionMinutos;
  final String? imagen;
  final CategoriaServicio categoria;
  final PublicoServicio publico;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracionMinutos,
    required this.categoria,
    required this.publico,
    this.imagen,
  });
}

enum CategoriaServicio { corte, color, barba, peinado, tratamiento }

enum PublicoServicio { mujer, hombre, unisex }
