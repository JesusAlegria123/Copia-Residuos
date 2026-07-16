import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Representa una unidad (camión) de recolección de residuos y su ruta.
class UnidadRecoleccion {
  final String id;
  final String nombre;
  final String ruta;
  final Color color;

  /// Puntos (waypoints) que definen el recorrido de la unidad.
  /// En la versión REAL, estos puntos dejarán de usarse para simular
  /// y en su lugar la posición vendrá del GPS del vehículo (ej. Firebase).
  final List<LatLng> puntosRuta;

  const UnidadRecoleccion({
    required this.id,
    required this.nombre,
    required this.ruta,
    required this.color,
    required this.puntosRuta,
  });
}

// ══════════════════════════════════════════════════════════════════
// UNIDADES DE RECOLECCIÓN (datos de ejemplo)
// ──────────────────────────────────────────────────────────────────
// TODO: reemplaza 'puntosRuta' por las coordenadas reales de cada ruta
// (puedes sacarlas caminando/manejando la ruta con Google My Maps y
// exportando los puntos, o levantándolas manualmente en Google Maps).
// ══════════════════════════════════════════════════════════════════
final List<UnidadRecoleccion> unidadesRecoleccion = [
  UnidadRecoleccion(
    id: 'unidad_1',
    nombre: 'Unidad 1',
    ruta: 'Av. de la Cultura · Parte alta',
    color: const Color(0xFF9333EA),
    puntosRuta: const [
      LatLng(-13.5255, -71.9720),
      LatLng(-13.5248, -71.9650),
      LatLng(-13.5240, -71.9580),
      LatLng(-13.5230, -71.9510),
      LatLng(-13.5225, -71.9450),
    ],
  ),
  UnidadRecoleccion(
    id: 'unidad_2',
    nombre: 'Unidad 2',
    ruta: 'Wanchaq',
    color: const Color(0xFF0EA5E9),
    puntosRuta: const [
      LatLng(-13.5400, -71.9600),
      LatLng(-13.5380, -71.9560),
      LatLng(-13.5360, -71.9520),
      LatLng(-13.5340, -71.9490),
      LatLng(-13.5320, -71.9460),
    ],
  ),
  UnidadRecoleccion(
    id: 'unidad_3',
    nombre: 'Unidad 3',
    ruta: 'Santiago',
    color: const Color(0xFF10B981),
    puntosRuta: const [
      LatLng(-13.5200, -71.9950),
      LatLng(-13.5220, -71.9900),
      LatLng(-13.5240, -71.9850),
      LatLng(-13.5260, -71.9800),
      LatLng(-13.5280, -71.9750),
    ],
  ),
];