import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mapa_screen.dart';
import 'nuevo_reporte_screen.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  // ── Lista local de reportes (sin backend) ──────────────────
  final List<Map<String, dynamic>> _reportes = [
    {
      'id': 1,
      'titulo': 'Exceso de basura en mercado',
      'descripcion': 'Acumulación de residuos sólidos en la entrada principal.',
      'direccion': 'Mercado Central, Cusco',
      'fecha': '2026-06-14',
      'estado': 'Pendiente',
      'color': const Color(0xFFF59E0B),
      'foto': null,
      'latitud': -13.5183,
      'longitud': -71.9784,
    },
    {
      'id': 2,
      'titulo': 'Punto de reciclaje colapsado',
      'descripcion': 'El contenedor está desbordado hace tres días.',
      'direccion': 'Av. La Cultura, Wanchaq',
      'fecha': '2026-06-13',
      'estado': 'En Proceso',
      'color': const Color(0xFF0EA5E9),
      'foto': null,
      'latitud': -13.5255,
      'longitud': -71.9720,
    },
    {
      'id': 3,
      'titulo': 'Residuos en vía pública',
      'descripcion': 'Bolsas de basura tiradas sobre la vereda.',
      'direccion': 'Calle Tupac Amaru, Santiago',
      'fecha': '2026-06-12',
      'estado': 'Resuelto',
      'color': const Color(0xFF10B981),
      'foto': null,
      'latitud': -13.5200,
      'longitud': -71.9950,
    },
  ];

  bool _cargando = false;

  void _mostrarMensaje(String mensaje, {required bool esError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje,
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor:
        esError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.05),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reportes Ciudadanos',
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Color(0xFF9333EA)),
            onPressed: _cargando ? null : _crearNuevoReporte,
            tooltip: 'Nuevo reporte',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargando ? null : _crearNuevoReporte,
        backgroundColor: const Color(0xFF9333EA),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF9333EA), strokeWidth: 2.5),
      );
    }

    if (_reportes.isEmpty) return _buildVacio();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reportes.length,
      itemBuilder: (context, index) =>
          _buildReporteCard(_reportes[index]),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              color: Colors.white.withOpacity(0.3), size: 60),
          const SizedBox(height: 16),
          Text(
            'No hay reportes aún',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca + para reportar un problema',
            style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.3), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReporteCard(Map<String, dynamic> reporte) {
    final Color color = reporte['color'] as Color;
    final String? fotoPath = reporte['foto'] as String?;
    final String descripcion = reporte['descripcion'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Miniatura de foto o ícono placeholder
              if (fotoPath != null && fotoPath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(fotoPath),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _iconPlaceholder(color),
                  ),
                )
              else
                _iconPlaceholder(color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reporte['titulo'] as String,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '📍 ${reporte['direccion'] as String}',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reporte['estado'] as String,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (descripcion.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.55),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: Colors.white.withOpacity(0.3), size: 12),
              const SizedBox(width: 4),
              Text(
                reporte['fecha'] as String,
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.3), fontSize: 11),
              ),
              const Spacer(),
              Icon(Icons.location_searching_rounded,
                  color: Colors.white.withOpacity(0.3), size: 12),
              const SizedBox(width: 4),
              Text(
                '${(reporte['latitud'] as double).toStringAsFixed(4)}, '
                    '${(reporte['longitud'] as double).toStringAsFixed(4)}',
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.3), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconPlaceholder(Color color) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.warning_amber_rounded, color: color, size: 18),
    );
  }

  Future<void> _crearNuevoReporte() async {
    // Paso 1: el usuario elige el punto en el mapa
    final ubicacion = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const MapaScreen()),
    );

    if (ubicacion == null || !mounted) return;

    // Paso 2: el usuario completa el formulario del reporte
    final datosReporte = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => NuevoReporteScreen(
          latitude: ubicacion['latitude'] as double,
          longitude: ubicacion['longitude'] as double,
          address: ubicacion['address'] as String,
        ),
      ),
    );

    if (datosReporte == null || !mounted) return;

    setState(() {
      _reportes.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'titulo': (datosReporte['titulo'] as String?)?.trim().isNotEmpty == true
            ? datosReporte['titulo']
            : 'Reporte sin título',
        'descripcion': datosReporte['descripcion'] as String? ?? '',
        'direccion': datosReporte['direccion'] as String,
        'fecha': DateTime.now().toString().split(' ')[0],
        'estado': 'Pendiente',
        'color': const Color(0xFFF59E0B),
        'foto': datosReporte['foto'] as String?,
        'latitud': datosReporte['latitude'] as double,
        'longitud': datosReporte['longitude'] as double,
      });
    });

    _mostrarMensaje('Reporte registrado correctamente.', esError: false);
  }
}