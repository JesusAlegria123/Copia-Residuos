import 'package:flutter/material.dart';

class ReporteModel {
  final int idReporte;
  final String? titulo;
  final String descripcion;
  final String distrito;
  final double latitud;
  final double longitud;
  final String? fotoUrl;
  final String estado;
  final DateTime createdAt;

  const ReporteModel({
    required this.idReporte,
    this.titulo,
    required this.descripcion,
    required this.distrito,
    required this.latitud,
    required this.longitud,
    this.fotoUrl,
    required this.estado,
    required this.createdAt,
  });

  String get tituloDisplay =>
      (titulo != null && titulo!.trim().isNotEmpty) ? titulo!.trim() : 'Reporte sin título';

  String get direccionDisplay => '$distrito · $latitud, $longitud';

  Color get estadoColor {
    switch (estado) {
      case 'En Proceso':
        return const Color(0xFF0EA5E9);
      case 'Resuelto':
        return const Color(0xFF10B981);
      case 'Rechazado':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  factory ReporteModel.fromJson(Map<String, dynamic> json) => ReporteModel(
        idReporte: json['idReporte'] as int,
        titulo: json['titulo'] as String?,
        descripcion: json['descripcion'] as String,
        distrito: json['distrito'] as String,
        latitud: (json['latitud'] as num).toDouble(),
        longitud: (json['longitud'] as num).toDouble(),
        fotoUrl: json['fotoUrl'] as String?,
        estado: json['estado'] as String? ?? 'Pendiente',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ReporteException implements Exception {
  final String message;
  final String? code;

  const ReporteException(this.message, {this.code});

  @override
  String toString() => message;
}
